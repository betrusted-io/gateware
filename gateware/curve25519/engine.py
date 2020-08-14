from migen import *
from migen.genlib.cdc import MultiReg

from litex.soc.interconnect.csr import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect import wishbone
from litex.soc.interconnect.csr_eventmanager import *

prime_string = "$2^{{255}}-19$"  # 2\ :sup:`255`-19
field_latex = "$\mathbf{{F}}_{{{{2^{{255}}}}-19}}$"

opcode_bits = 6  # number of bits used to encode the opcode field
opcodes = {  # mnemonic : [bit coding, docstring]
    "UDF" : [-1, "Placeholder for undefined opcodes"],
    "PSA" : [0, "Wd $\gets$ Ra  // pass A"],
    "PSB" : [1, "Wd $\gets$ Rb  // pass B"],
    "MSK" : [2, "Wd $\gets$ Replicate(Ra[0], 256) & Rb  // for doing cswap()"],
    "XOR" : [3, "Wd $\gets$ Ra ^ Rb  // bitwise XOR"],
    "NOT" : [4, "Wd $\gets$ ~Ra   // binary invert"],
    "ADD" : [5, "Wd $\gets$ Ra + Rb  // 256-bit binary add, must be followed by TRD,SUB"],
    "SUB" : [6, "Wd $\gets$ Ra - Rb  // 256-bit binary subtraction, this is not the same as a subtraction in the finite field"],
    "MUL" : [7, f"Wd $\gets$ Ra * Rb  // multiplication in {field_latex} - result is reduced"],
    "TRD" : [8, "If Ra $\geqq 2^{{255}}-19$ then Wd $\gets$ $2^{{255}}-19$, else Wd $\gets$ 0  // Test reduce"],
    "BRZ" : [9, "If Ra == 0 then mpc[9:0] $\gets$ mpc[9:0] + immediate[9:0], else mpc $\gets$ mpc + 1  // Branch if zero"],
    "FIN" : [10, "hast execution and assert interrupt to host CPU that microcode execution is done"],
    "MAX" : [11, "Maximum opcode number (for bounds checking)"]
}

num_registers = 32
instruction_layout = [
    ("opcode", opcode_bits, "opcode to be executed"),
    ("ra", log2_int(num_registers), "operand A read register"),
    ("ca", 1, "set to substitute constant table value for A"),
    ("rb", log2_int(num_registers), "operand B read register"),
    ("cb", 1, "set to substitute constant table value for B"),
    ("wd", log2_int(num_registers), "write register"),
    ("immediate", 9, "Used by jumps to load the next PC value")
]

class RegisterFile(Module, AutoDoc):
    def __init__(self, depth=512, width=256, bypass=False):
        reset_cycles = 4
        self.intro = ModuleDoc(title="Register File", body="""
This implements the register file for the Curve25519 engine. It's implemented using
7-series specific block RAMs in order to take advantage of architecture-specific features
to ensure a compact and performant implementation.

The core primitive is the RAMB36E1. This can be configured as a 64/72-bit wide memory
but only if used in "SDP" (simple dual port) mode. In SDP, you have one read, one write port.
However, the register file needs to produce two operands per cycle, while accepting up to
one operand per cycle. 

In order to do this, we stipulate that the RF runs at `rf_clk` (200MHz), but uses four phases 
to produce/consume data. "Engine clock" `eng_clk` (50MHz) runs at a lower rate to accommodate
large-width arithmetic in a single cycle.

The phasing is defined as follows:

Phase 0:
  - read from port A
Phase 1:
  - read from port B
Phase 2:
  - write data
Phase 3:
  - quite cycle, used to create extra setup time for next stage (requires multicycle-path constraints)
  
The writing of data is done in the second phase so that in the case you are writing
to the same address as being read, we guarantee the value read is the old value.

The register file is unavailable for {} `eng_clk` cycles after reset.

When configured as a 64 bit memory, the depth of the block is 512 bits, corresponding to 
an address width of 9 bits.

        """.format(reset_cycles))

        instruction = Record(instruction_layout)
        phase = Signal(2)  # internal phase
        self.phase = Signal()  # external phase
        self.comb += self.phase.eq(phase[1]) # divide down internal phase so slower modules can capture it

        # these are the signals in and out of the register file
        self.ra_dat = Signal(width) # this is passed in from outside the module because we want to mux with e.g. memory bus
        self.ra_adr = Signal(log2_int(depth))
        self.rb_dat = Signal(width)
        self.rb_adr = Signal(log2_int(depth))

        # register file pipelines the write target address, going to the exec units; also needs the window to be complete
        # window is assumed to be static and does not change throughout a give program run, so it's not pipelined
        self.instruction_pipe_in = Signal(len(instruction))
        self.instruction_pipe_out = Signal(len(instruction))
        self.window = Signal(log2_int(depth) - log2_int(num_registers))

        # this is the immediate data to write in, coming from the exec units
        self.wd_dat = Signal(width)
        self.wd_adr = Signal(log2_int(depth))
        self.wd_bwe = Signal(width//8)  # byte masks for writing
        self.we = Signal()
        self.clear = Signal()

        self.running = Signal() # used for activity gating to RAM

        eng_sync = Signal(reset=1)

        rf_adr = Signal(log2_int(depth))
        self.comb += [
            If(phase == 0,
                rf_adr.eq(self.ra_adr),
            ).Elif(phase == 1,
                rf_adr.eq(self.rb_adr),
            )
        ]
        rf_dat = Signal(width)
        self.sync.eng_clk += [
            # TODO: check that this is in sync with expected values
            self.instruction_pipe_out.eq(self.instruction_pipe_in),
        ]
        # unfortunately, -1L speed grade is too slow to support pipeline bypassing of the register file:
        # bypass path closes at about 5.4ns, which fails to meet the 5ns cycle time target for the four-phase RF
        if bypass:
            self.sync.rf_clk += [
                If(phase == 1,
                    If((self.wd_adr != self.ra_adr) | ~self.we,
                        self.ra_dat.eq(rf_dat),
                       ).Else(
                        self.ra_dat.eq(self.wd_dat),
                    ),
                    self.rb_dat.eq(self.rb_dat),
                   ).Elif(phase == 2,
                    self.ra_dat.eq(self.ra_dat),
                    If((self.wd_adr != self.rb_adr) | ~self.we,
                        self.rb_dat.eq(rf_dat),
                       ).Else(
                        self.rb_dat.eq(self.wd_dat),
                    )
                          ).Else(
                    self.ra_dat.eq(self.ra_dat),
                    self.rb_dat.eq(self.rb_dat),
                ),
            ]
        else:
            self.sync.rf_clk += [
                If(phase == 1,
                    self.ra_dat.eq(rf_dat),
                    self.rb_dat.eq(self.rb_dat),
                ).Elif(phase == 2,
                    self.ra_dat.eq(self.ra_dat),
                    self.rb_dat.eq(rf_dat),
                ).Else(
                    self.ra_dat.eq(self.ra_dat),
                    self.rb_dat.eq(self.rb_dat),
                ),
            ]
        wren_pipe = Signal()
        self.sync.rf_clk += [
            If(eng_sync,
                phase.eq(0),
            ).Else(
                phase.eq(phase + 1),
            ),
            wren_pipe.eq((phase == 1) & self.we),  # we want wren to hit on phase==2, but we pipeline it to relax timing. so capture the input to the pipe on phase == 1
        ]

        for word in range(int(256/64)):
            self.specials += Instance("BRAM_SDP_MACRO", name="RF_RAMB" + str(word),
                p_BRAM_SIZE = "36Kb",
                p_DEVICE = "7SERIES",
                p_WRITE_WIDTH = 64,
                p_READ_WIDTH = 64,
                p_DO_REG = 0,
                p_INIT_FILE = "NONE",
                p_SIM_COLLISION_CHECK = "ALL", # "WARNING_ONLY", "GENERATE_X_ONLY", "NONE"
                p_SRVAL = 0,
                p_WRITE_MODE = "READ_FIRST",
                i_RDCLK = ClockSignal("rf_clk"),
                i_WRCLK = ClockSignal("rf_clk"),
                i_RDADDR = rf_adr,
                i_WRADDR = self.wd_adr,
                i_DI = self.wd_dat[word*64 : word*64 + 64],
                o_DO = rf_dat[word*64 : word*64 + 64],
                i_RDEN = self.running, # reduce power when not running
                i_WREN = wren_pipe, # (phase == 2) & self.we, but pipelined one stage
                i_RST = eng_sync,
                i_WE = self.wd_bwe[word*8 : word*8 + 8],

                i_REGCE = 1, # should be ignored, but added to quiet down simulation warnings
            )

        # create an internal reset signal that synchronizes the "eng" to the "rf" domains
        # it will also reset the register file on demand
        reset_counter = Signal(log2_int(reset_cycles), reset=reset_cycles - 1)
        self.sync.eng_clk += [
            If(self.clear,
                reset_counter.eq(reset_cycles - 1),
                eng_sync.eq(1),
            ).Else(
                If(reset_counter != 0,
                   reset_counter.eq(reset_counter - 1),
                    eng_sync.eq(1),
                ).Else(
                   eng_sync.eq(0)
                ),
            )
        ]

class Curve25519Const(Module, AutoDoc):
    def __init__(self, insert_docs=False):
        global did_const_doc
        constant_defs = {
            0: [0, "zero", "The number zero"],
            1: [121665, "a24", "The value $\\frac{{A-2}}{{4}}$"],
            2: [0x7FFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFED, "field", f"Binary coding of {prime_string}"],
            3: [0xFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF, "neg1", "Binary -1"],
            4: [1, "one", "The number one"],
        }
        self.adr = Signal(5)
        self.const = Signal(256)
        constant_str = "This module encodes the constants that can be substituted for any register value. Therefore, up to 32 constants can be encoded.\n\n"
        for code, const in constant_defs.items():
            self.comb += [
                If(self.adr == code,
                    self.const.eq(const[0]),
                )
            ]
            constant_str += """
**{}**

  Substitute register {} with {}: {}\n""".format(const[1], code, const[2], const[0])
        if insert_docs:
            self.constants = ModuleDoc(title="Curve25519 Constants", body=constant_str)

# ------------------------------------------------------------------------ EXECUTION UNITS
class ExecUnit(Module, AutoDoc):
    def __init__(self, width=256, opcode_list=["UDF"], insert_docs=False):
        if insert_docs:
            self.intro = ModuleDoc(title="ExecUnit class", body="""
    ExecUnit is the superclass template for execution units.
    
    Configuration Arguments:
      - `opcode_list` is the list of opcodes that an ExecUnit can process
      - `width` is the bit-width of the execution pathway
    
    Signal API for an exec unit:
      - `a` and `b` are the inputs. 
      - `instruction_in` is the instruction corresponding to the currently present `a` and `b` inputs
      - `start` is a single-clock signal which indicates processing should start
      - `q` is the output
      - `instruction_out` is the instruction for the result present at the `q` output 
      - `q_valid` is a single cycle pulse that indicates that the `q` result and `wa_out` value is valid
      
      
            """)
        self.instruction = Record(instruction_layout)

        self.a = Signal(width)
        self.b = Signal(width)
        self.q = Signal(width)
        self.start = Signal()
        self.q_valid = Signal()
        # pipeline the instruction
        self.instruction_in = Signal(len(self.instruction))
        self.instruction_out = Signal(len(self.instruction))

        self.opcode_list = opcode_list
        self.comb += [
            self.instruction.raw_bits().eq(self.instruction_in)
        ]

class ExecMask(ExecUnit):
    def __init__(self, width=256):
        ExecUnit.__init__(self, width, ["MSK"], insert_docs=True)  # we insert_docs to be true for exactly once module exactly once
        self.intro = ModuleDoc(title="Masking ExecUnit Subclass", body=f"""
This execution unit implements the bit-mask and operation. It takes Ra[0] (the
zeroth bit of Ra) and replicates it to {str(width)} bits wide, and then ANDs it with
the full contents of Rb. This operation is introduced as one of the elements of
the `cswap()` routine, which is a constant-time swap of two variables based on a `swap` flag.

Here is an example of how to swap the contents of `ra` and `rb` based on the value of the 0th bit of `swap`::

  XOR  dummy, ra, rb       // dummy $\gets$ ra ^ rb
  MSK  dummy, swap, dummy  // If swap[0] then dummy $\gets$ dummy, else dummy $\gets$ 0
  XOR  ra, dummy, ra       // ra $\gets$ ra ^ dummy
  XOR  rb, dummy, rb       // rb $\gets$ rb ^ dummy  
""")
        self.sync.eng_clk += [
            self.q_valid.eq(self.start),
            self.q.eq(self.b & Replicate(self.a[0], width)),
            self.instruction_out.eq(self.instruction_in),
        ]

class ExecLogic(ExecUnit):
    def __init__(self, width=256):
        ExecUnit.__init__(self, width, ["XOR", "NOT", "PSA", "PSB"])
        self.intro = ModuleDoc(title="Logic ExecUnit Subclass", body=f"""
This execution unit implements bit-wise logic operations: XOR, NOT, and 
passthrough. 

* XOR returns the result of A^B
* NOT returns the result of !A
* PSA returns the value of A
* PSB returns the value of B

""")

        self.sync.eng_clk += [
            self.q_valid.eq(self.start),
            If(self.instruction.opcode == opcodes["XOR"][0],
               self.q.eq(self.a ^ self.b)
            ).Elif(self.instruction.opcode == opcodes["NOT"][0],
               self.q.eq(~self.a)
            ).Elif(self.instruction.opcode == opcodes["PSA"][0],
                self.q.eq(self.a),
            ).Elif(self.instruction.opcode == opcodes["PSB"][0],
                self.q.eq(self.b),
            ),
            self.instruction_out.eq(self.instruction_in),
        ]

class ExecAddSub(ExecUnit, AutoDoc):
    def __init__(self, width=256):
        ExecUnit.__init__(self, width, ["ADD", "SUB"])
        self.notes = ModuleDoc(title="Add/Sub ExecUnit Subclass", body=f"""
This execution module implements 256-bit binary addition and subtraction.

Note that to implement operations in $\mathbf{{F}}_p$, where *p* is $2^{{255}}-19$, this must be compounded
with other operators as follows:

Addition of Ra + Rb into Rc in {field_latex}:

.. code-block:: c

  ADD Rc, Ra, Rb    // Rc <- Ra + Rb
  TRD Rd, Rc        // Rd <- ReductionValue(Rc)
  SUB Rc, Rc, Rd    // Rc <- Rc - Rd 

Negation of Ra into Rc in {field_latex}:

.. code-block:: c

  SUB Rc, #FIELDPRIME, Ra   //  Rc <- 2^255-19 - Ra

Note that **#FIELDPRIME** is one of the 32 available hard-coded constants
that can be substituted for any register in any arithmetic operation, please
see the section on "Constants" for more details.

Subtraction of Ra - Rb into Rc in {field_latex}:

.. code-block:: c

  SUB Rb, #FIELDPRIME, Rb   //  Rb <- 2^255-19 - Rb
  ADD Rc, Ra, Rb    // Rc <- Ra + Rb
  TRD Rd, Rc        // Rd <- ReductionValue(Rc)
  SUB Rc, Rc, Rd    // Rc <- Rc - Rd 

In all the examples above, Ra and Rb must be members of {field_latex}. 
        """)

        self.sync.eng_clk += [
            self.q_valid.eq(self.start),
            If(self.instruction.opcode == opcodes["ADD"][0],
               self.q.eq(self.a + self.b),
            ).Elif(self.instruction.opcode == opcodes["SUB"][0],
               self.q.eq(self.a - self.b),
            ),

            self.instruction_out.eq(self.instruction_in),
        ]

class ExecTestReduce(ExecUnit, AutoDoc):
    def __init__(self, width=256):
        ExecUnit.__init__(self, width, ["TRD"])

        self.notes = ModuleDoc(title="Modular Reduction Test ExecUnit Subclass", body=f"""
First, observe that $2^n-19$ is 0x07FF....FFED.
Next, observe that arithmetic in the field of {prime_string} will never
the 256th bit.

Modular reduction must happen when an arithmetic operation
overflows the bounds of the modulus. When this happens, one must
subtract the modulus (in this case {prime_string}). 

The reduce operation is done in two halves. The first half is
to check if a reduction must happen. The second is to do the subtraction.
In order to allow for constant-time operation, we always do the subtraction,
even if it is not strictly necessary. 

We use this to our advantage, and compute a reduction using
a test operator that produces a residue, and a subtraction operation.

It's up to the programmer to ensure that the two instruction sequence
is never broken up.

Thus the reduction algorithm is as follows:

1. TestReduce
  - If the 256th bit is set (e.g, ra[255]), then return {prime_string}
  - If bits ra[255:5] are all 1, and bits ra[4:0] are greater than or equal to 0x1D, then return {prime_string}
  - Otherwise return 0
2. Subtract
  - Subtract the return value of TestReduce from the tested value

        """)
        self.sync.eng_clk += [
            If( (self.a >= 0x7FFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFED),
                self.q.eq(0x7FFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFED)
            ).Else(
                self.q.eq(0x0)
            ),
            self.q_valid.eq(self.start),
            self.instruction_out.eq(self.instruction_in),
        ]

class ExecMul(ExecUnit, AutoDoc):
    def __init__(self, width=256, sim=False):
        ExecUnit.__init__(self, width, ["MUL"])

        self.sync.eng_clk += [ # pipeline the instruction
            self.instruction_out.eq(self.instruction_in),
        ]
        self.notes = ModuleDoc(title=f"Multiplication in {field_latex} ExecUnit Subclass", body=f"""
Unlike the ADD/SUB module, this operator explicitly works in {field_latex}. It takes in two inputs,
Ra and Rb, and both must be members of {field_latex}. The result is also reduced to a member of {field_latex}.

The multiplier is designed with a separate clock, `mul_clk` so that it can be remapped to a faster
domain than `engine_clk` for better performance. The nominal target for `mul_clk` is 100MHz.

The base algorithm for this implementation is lifted from the paper "Compact and Flexible FPGA Implementation
of Ed25519 and X25519" by Furkan Turan and Ingrid Verbauwhede (https://doi.org/10.1145/3312742).  The algorithm
specified in this paper is optimized for the DSP48E blocks found inside a 7-Series Xilinx FPGA. In particular,
we can compute 17-bit multiplies using this hardware block, and 255 divides evenly into 17 to produce
a requirement of 15x DSP48E blocks. 

At a high level, the steps to compute the multiplication are:

1. Schoolbook multiplication 
2. Collapse partial sums
3. Propagate carries
4. Catch the special case of results $\geq$ $2^{{255}}-19$, or the 256th bit set
5. Add 19 or 0 depending on the outcome of (4)
6. Propagate carries again, in case these overflow (rarely, but they do)

The multiplier would run about 30% faster if step (6) were skipped. This step happens
in a fairly small minority of cases, maybe a fraction of 1%, and the worst-case
carry propagate is diminishingly rare. The test for
whether or not to propagate carries is fairly straightforward. However, this creates
a timing side-channel, therefore we prefer a slower but safer implementation, even if
we are spending a bunch of cycles most of the time doing nothing.

A constant-time optimization would be for the multiplier to simply produce a 256-bit
result, and then use a subsequent TRD/SUB instruction pair. However, the non-pipelined
version of this core takes 60ns per instrution, or 120ns total to compute this, whereas
iterating another carry would take 140ns total (as the mul core runs 2x speed of the
rest of the engine). This is basically a wash. However, if pipelining (and bypassing) 
were implemented, this might be a viable optimization, but bypassing such a wide core
would also have resource and speed implications of its own.

The above steps are coordinated by the `mseq` state machine. Control lines for 
the DSP48E blocks are grouped into two sets, one controls the global state of
things such as the operation mode and input modes, and the other controls the
routing of individual 17-bit limbs (e.g. "digits" of our 17-bit representation of
numbers) to various sources and destinations.

The following sections walk through the algorithm in detail.

Schoolbook Multiplication
-------------------------

The first step in the algorithm is called "schoolbook multiplication". It's
almost that, but with a twist. Below is what actual schoolbook multiplication
would be like, if you had a pair of numbers that were broken into three "limbs" (digits)
A[2:0] and B[2:0]. 

::

                   |    A2        A1       A0
    x              |    B2        B1       B0 
   ------------------------------------------
                   | A2*B0     A1*B0    A0*B0
            A2*B1  | A1*B1     A0*B1
   A2*B2    A1*B2  | A0*B2
     (overflow)         (not overflowing)

The result of schoolbook multiplication is a result that potentially has
2x the number of bits than the either multiplicand. Since we're doing modular
multiplication in a finite field, the overflow "wraps around", so that the
result is always a number within the finite field. 

Mapping the overflow around is a process called reduction. There's a magical
trick that happens which I don't understand the math behind that makes this
operation really easy with the parameters chosen for Curve25519, but it 
looks like this:

::

                   |    A2        A1       A0
    x              |    B2        B1       B0 
   ------------------------------------------
                   | A2*B0     A1*B0    A0*B0
                   | A1*B1     A0*B1 19*A2*B1
                 + | A0*B2  19*A2*B2 19*A1*B2
                 ----------------------------
                        P2        P1       P0

Basically, by taking each overflowed limb and multiplying it by 19, you can
"wrap the result" around, creating a number of partial sums P[2:0] that are
equal to your limbs, but each partial sum potentially overflowing the limb.

In C, the code basically looks like this:

.. code-block:: c

   // initialize the a_bar set of data                                                                                                                                                                                                        
   for( int i = 0; i < DSP17_ARRAY_LEN; i++ ) {{
      a_bar_dsp[i] = a_dsp[i] * 19;
   }}
   operand p;
   for( int i = 0; i < DSP17_ARRAY_LEN; i++ ) {{ 
      p[i] = 0; 
   }}

   // core multiply
   for( int col = 0; col < 15; col++ ) {{
     for( int row = 0; row < 15; row++ ) {{
       if( row >= col ) {{
         p[row] += a_dsp[row-col] * b_dsp[col];
       }} else {{
         p[row] += a_bar_dsp[15+row-col] * b_dsp[col];
       }}
     }}
   }}

Collapse Partial Sums
---------------------

The potential width of the partial sum is up to 43 bits wide. This step
divides the partial sums up into 17-bit words, and then shifts the higher
to the next limbs over, allowing them to collapse into a smaller sum that 
overflows less.

   ... P2[16:0]   P1[16:0]      P0[16:0]
   ... P1[33:17]  P0[33:17]     P14[33:17]*19
   ... P0[50:34]  P14[50:34]*19 P13[50:34]*19

Again, the magic number 19 shows up to allow sums which "wrapped around"
to add back in. This is what the C code looks like for this operation.

.. code-block:: c

     prop[0] = (p[0] & 0x1ffff) +
       (((p[14] * 1) >> 17) & 0x1ffff) * 19 +
       (((p[13] * 1) >> 34) & 0x1ffff) * 19;
     prop[1] = (p[1] & 0x1ffff) +
       ((p[0] >> 17) & 0x1ffff) +
       (((p[14] * 1) >> 34) & 0x1ffff) * 19;
     for(int bitslice = 2; bitslice < 15; bitslice += 1) {{
         prop[bitslice] = (p[bitslice] & 0x1ffff) + ((p[bitslice - 1] >> 17) & 0x1ffff) + ((p[bitslice - 2] >> 34));
     }}

Propagate Carries
-----------------

The partial sums will generate carries, which need to be propagated down the
chain. The C-code equivalent of this looks as follows:

.. code-block:: c

   for(int i = 0; i < 15; i++) {{
     if ( i+1 < 15 ) {{
        prop[i+1] = (prop[i] >> 17) + prop[i+1];
        prop[i] = prop[i] & 0x1ffff;
     }}
   }}

Normalize
---------

Unfortunately, at this point, the carries can generate carries, so a second round
of this partial sum and carry is required.

The result at this point is basically correct, except there is one case that
is not handled well: where the result is between $2^{{255}}-19$ and $2^{{256}}-1$.
In this case, the number will basically be somewhere in between 0x7ff....ffed and
0x7ff....ffff, or the 255th bit will be set. In this case, we need to add 19 to 
the result, so that the result is a member of the field $2^{{255}}-19$.

We do a simple pattern detect to detect the "1's" in bit positions 255-5, and a
LUT to check the final 5 bits, OR'd with a check of the 256th bit being 1. 
If it falls within this special case, we add the number 19, otherwise, we add 0.

After adding the number 19, we have to once again propagate carries. For simplicity,
in this implementation we repeat the whole sum-and-propagate process once again. For
constant time, regardless of whether we need to add 0 or 19, we do this process,
even if we are just adding 0.

Once this is finished, we have the final result.

""")
        # array of 15, 17-bit wide signals = 255 bits
        a_17 = [Signal(17),Signal(17),Signal(17),Signal(17),Signal(17),
                Signal(17),Signal(17),Signal(17),Signal(17),Signal(17),
                Signal(17),Signal(17),Signal(17),Signal(17),Signal(17),]
        b_17 = [Signal(17),Signal(17),Signal(17),Signal(17),Signal(17),
                Signal(17),Signal(17),Signal(17),Signal(17),Signal(17),
                Signal(17),Signal(17),Signal(17),Signal(17),Signal(17),]
        # split incoming data into 17-bit wide chunks
        for i in range(15):
            self.comb += [
                a_17[i].eq(self.a[i*17:i*17+17]),
                b_17[i].eq(self.b[i*17:i*17+17]),
            ]

        # signals common to all DSP blocks
        dsp_alumode = Signal(4)
        dsp_opmode = Signal(7)
        dsp_reset = Signal()
        dsp_a1_ce = Signal()
        dsp_a2_ce = Signal()
        dsp_b1_ce = Signal()
        dsp_b2_ce = Signal()
        dsp_d_ce = Signal()
        dsp_p_ce = Signal()
        self.comb += [
            dsp_reset.eq(ResetSignal()),
            dsp_b1_ce.eq(0), # not used
        ]
        zeros = Signal(48, reset=0)  # dummy zeros signals to tie off unused bits of the DSP48E
        self.comb += zeros.eq(0)

        step = Signal(max=15+1)  # controls the multiplication step
        prop = Signal() # count the propagations

        for i in range(15):
            # create all the per-block DSP signals before we loop through and connect them
            setattr(self, "dsp_a" + str(i), Signal(48, name="dsp_a" + str(i)))
            setattr(self, "dsp_b" + str(i), Signal(17, name="dsp_b" + str(i)))
            setattr(self, "dsp_c" + str(i), Signal(48, name="dsp_c" + str(i)))
            setattr(self, "dsp_d" + str(i), Signal(17, name="dsp_d" + str(i)))
            setattr(self, "dsp_match" + str(i), Signal(name="dsp_match"+str(i)))
            setattr(self, "dsp_p" + str(i), Signal(48, name="dsp_p"+str(i)))
            setattr(self, "dsp_p_ce" + str(i), Signal(48, name="dsp_p_ce"+str(i)))
            setattr(self, "dsp_inmode" + str(i), Signal(5, name="dsp_inmode"+str(i)))

        self.timing = ModuleDoc(title="Detailed timing operation", body="""

Below is a detailed timing diagram that illustrates the expected sequence of events
by the implementation of this code.

.. wavedrom::
  :caption: Detailed timing of the multiply operation
  
  { "config": {skin : "default"},
  "signal" : [
  { "name": "clk",         "wave": "p......|.........|.......|....." },
  { "name": "go",          "wave": "010..........................10" },
  { "name": "self.a",      "wave": "x2...........................2.", "data": ["A0[255:0]","A1[255:0]"] },
  { "name": "self.b",      "wave": "x2...........................2.", "data": ["B0[255:0]","B2[255:0]"] },
  { "name": "state",       "wave": "2.34......5555...|..86...|..923", "data":["IDLE","SETA","MPY","DLY","PLSB","PMSB","PROP","NORM","PROP","DONE","IDLE","SETA"]},
  { "name": "step",        "wave": "x..2===|==5...55|5556.666|66xxx", "data":["0","1", "2", "3","13","14","0","1","2","11","12","13","0","1","2","11","12","13"]},
  { "name": "prop",        "wave": "x.........5.....|...6....|..xxx", "data":["0","1"]},
  { "name": "dsp.a",       "wave": "x2x2x.....8x.................2x", "data": ["A0xx","A19","0", "A1xx"] },
  { "name": "dsp.b",       "wave": "x2====|==x55xxxxxxx8xx.......2=", "data": ["19","B00","B01","B02","B03","B13","B14","1or19","1or19","19","19","B2_00"] },
  { "name": "dsp.c",        "wave": "x...2===|=x5x5...|..x6...|..xxx", "data":["Q0","Q1","Q2","Q3","Q13","P0,0","C* >> 17    ","C* >> 17    "]},
  { "name": "dsp.d",        "wave": "x.........55x.xxxxxx...xxxxxxx.", "data":["*Q0,1","R0,2"]},
  {},
  { "name": "A1_CE",       "wave": "1.010.....10..................." },
  { "name": "A1",          "wave": "x.2.2......8.........x.........", "data": ["A0xx","A0xx*19","0"] },
  { "name": "A2_CE",       "wave": "0..10......10.................." },
  { "name": "A2",          "wave": "x...2.......8........x.........", "data":["A0xx","0"] },
  { "name": "B2_CE",       "wave": "01.......01.0......10.........." },
  { "name": "B2",          "wave": "x.22===|==x55xxxx.xx8x.........", "data": ["19","B00","B01","B02","B03","B13","B14","1or19","1or19","19"] },
  { "name": "D_CE",        "wave": "0.........1.0.................." },
  { "name": "C",           "wave": "x...2===|==555...|..86...|..x..", "data": ["Q0","Q1","Q2","Q3","Q13","Q14","P0,0","*P","C* >> 17    ","C&","C* >> 17    "] },
  { "name": "D",           "wave": "x..........55xx................", "data": ["Q0,1","R0,2","QS14,1","RS14,2","QS14,1","RS14,2"] },
  { "name": "inmode",      "wave": "x.2.2.....x5.x.xx.xx8x.........", "data":["A1B2","AnB2","DB2","0B2"]},
  { "name": "opmode",      "wave": "x.2.=.....2555...|..86...|..xxx", "data":["M","C+M","C+0","C+M","P+M","C+P","AB/0+C","C+P"]},
  {},
  { "name": "P_CE",        "wave": "0.1.....|....5555|5516666|660.1", "data": ["P1", "P2", "P3","P4","P13","P14","P1", "P2", "P3","P4","P13","P14"] },
  { "name": "P",           "wave": "x..2====|===55555|5552666|666x.", "data": ["A19","P0","P1","P2","P3","P13","P14","P0","PLSB","PMSB","C1","C2","C3","C12", "C13","C14","S+","C1","C2","C3","C12", "C13","C14","final"] },
  { "name": "overflow",    "wave": "x...................2x.........", "data":["Y/N"]},
  { "name": "done",        "wave": "0...........................10." },
  ]}
  
Notes:
   
1. the final product sum on the first DLY cycle is just a shift to get the
  product results into the right unit. Thus, for the load of `dsp.d` `*Q0,1`, it needs
  to pick the result off of the neighboring DSP unit, because it needs to acquire the value
  before the final shift.
2. The `S+` on the P line is the non-normalized sum. This is basically the final result, but
   sometimes with the 19 added to the least significant limb, in the case that the result is greater than
   or equal to $2^{{255}}-19$. This addition must be propagated through the whole result.
  
          """)

        self.diagrams = ModuleDoc(title="Dataflow Diagrams", body="""
        
.. image:: https://raw.githubusercontent.com/betrusted-io/gateware/master/gateware/curve25519/mpy_pipe.png
   :alt: data flow block diagram of the multiplier core
      
Above is the relevant elements of the DSP48E1 block as configured for the systolic dataflow for the "schoolbook"
multiply operation. Items shaded in gray are external to the DSP48E1 block.
  
.. image:: https://raw.githubusercontent.com/betrusted-io/gateware/master/gateware/curve25519/psum.png
   :alt: data flow block diagram of the partial sum step
      
Above is the configuration of the DSP48E1 block for the partial sum steps. Partial sum takes two cycles to
sum together the three 17-bit segments of the partial sums.
  
.. image:: https://raw.githubusercontent.com/betrusted-io/gateware/master/gateware/curve25519/carry_prop.png
   :alt: data flow block diagram of the carry propagate

Above is the configuration of the DSP48E1 block for the carry propagate step. This step must be repeated 
14 times to handle the worst-case carry propagate path. During the carry propagate step, the pattern
detector is active, and on the final step we check it to see if the result overflows $2^{{255}}-19$.
  
.. image:: https://raw.githubusercontent.com/betrusted-io/gateware/master/gateware/curve25519/normalize.png
   :alt: data flow block diagram of the normalization step
  
Above is the configuration of the DSP48E1 block for the normalization step. If the result overflows $2^{{255}}-19$,
we must add 19 to make it a member of the prime field once again. We can do this in a single cycle by
short-circuiting the carry propagate: we already know we will have to propagate a carry to handle the overflow
case (there are only 19 possible numbers that will overflow this, and all of them have 1's set up the entire
chain), so we pre-add the carry simultaneous with adding the number 19 to the least significant limb.

        """)

        start_pipe = Signal()
        self.sync.mul_clk += start_pipe.eq(self.start) # break critical path of instruction decode -> SETUP_A state muxes
        self.submodules.mseq = mseq = ClockDomainsRenamer("mul_clk")(FSM(reset_state="IDLE"))
        mseq.act("IDLE",
            NextValue(step, 0),
            NextValue(prop, 0),
            If(start_pipe,
                NextState("SETUP_A")
            )
        )
        mseq.act("SETUP_A", # SETA, load the a, a19 values values
            NextState("MULTIPLY"),
        )
        mseq.act("MULTIPLY", # MPY
            If(step < 14,
                NextValue(step, step + 1)
            ).Else(
                NextState("P_DELAY"),
                NextValue(step, 0),
            )
        )
        mseq.act("P_DELAY", # DLY - due to pipelining of P register delaying feedback by one cycle
            NextState("PSUM_LSB")
        )
        mseq.act("PSUM_LSB", # PLSB
            NextState("PSUM_MSB")
        )
        mseq.act("PSUM_MSB", # PMSB
            NextState("CARRYPROP")
        )
        mseq.act("CARRYPROP", # PROP
            If( step == 13,
               If( prop == 0,
                   NextState("NORMALIZE"),
                   NextValue(step, 0),
               ).Else(
                   NextState("DONE"),  # if modifying to the "DONE" state, change q-latch statement at the end
               )
            ).Else(
                NextValue(step, step + 1),
            )
        )
        mseq.act("NORMALIZE", # NORM
            NextState("CARRYPROP"),
            NextValue(prop, 1),
            NextValue(step, 0),
        )
        ### note that the post-amble "manually" aligns the mul_clk to eng_clk phases
        ### this can have one of two outcomes if the previous number of states is even or odd
        ### in this case, we end up phase mis-aligned, so we have to burn a dummy cycle to sync clocks
        ### see q_valid logic at end of this module
        mseq.act("DONE", # DONE -- we are actually finished on an odd phase of the eng_clk, can't assert RF here
            NextState("DONE2"),
        )
        mseq.act("DONE2",  # assert valid to the RF here
            NextState("DONE3"),
        )
        mseq.act("DONE3", # second done state, because we are latching into a half-rate clock domain, so valid is good for one full eng_clk
            NextState("IDLE"),
            # Note: we could, in theory, pipeline the next multiply by detecting if go goes high here,
            # and bypassing IDLE and going straight to SETA, but...
        )

        # DSP48E opcode encodings
        OP_PASS_M        = 0b000_01_01  # X:Y <- M; Z <-0;    P <- 0 + M + 0
        OP_M_PLUS_PCIN   = 0b001_01_01  # X:Y <- M; Z <-PCIN; P <- PCIN + M + 0
        OP_M_PLUS_C      = 0b011_01_01  # X:Y <- M; Z <-C;    P <- C + M + 0
        OP_M_PLUS_P      = 0b010_01_01  # X:Y <- M; Z <-P   ; P <- P + M + 0
        OP_P_PLUS_PCIN17 = 0b101_10_00  # X <- P; Y <- 0; Z <- PCIN >> 17; P <- PCIN>>17 + P + 0
        OP_C_PLUS_P      = 0b010_11_00  # X <- 0; Y <- C; Z <- P; P <- 0 + C + P
        OP_AB_PLUS_P     = 0b010_00_11  # X <- A:B; Y <- 0; Z <- P; P <- A:B + 0 + P + 0
        OP_AB_PLUS_C     = 0b011_00_11  # X <- A:B; Y <- 0; Z <- C; P <- A:B + 0 + C + 0
        OP_0_PLUS_P      = 0b010_00_00  # X <- 0; Y <- 0; Z <- P; P <- 0 + 0 + P + 0
        OP_C_PLUS_0      = 0b011_00_00  # X <- 0; Y <- 0; Z <- C; P <- C + 0 + 0 + 0
        INMODE_A1 = 0b0001
        INMODE_A2 = 0b0000
        INMODE_D  = 0b0110
        INMODE_0  = 0b0010
        INMODE_B2 = 0b0
        # INMODE_B1 = 0b1  # should not be used in this configuration, only 1 BREG configured

        overflow_25519 = Signal() # set during normalize if we're overflowing 2^255-19

        # see the self.timing documentation (above, best viewed after post-processing with sphinx) for how this all works.
        self.comb += [
            dsp_alumode.eq(0),
            If(mseq.before_entering("SETUP_A"),
                dsp_b2_ce.eq(1),
                dsp_a1_ce.eq(1),
            ).Elif(mseq.ongoing("SETUP_A"),
                # at this point, these are already loaded: A1 <- Axx, B2 <- 19
                # P <- A1 * B2
                dsp_opmode.eq(OP_PASS_M),
                # pipeline in the b1 value for the first round of the multiply
                dsp_b2_ce.eq(1),
                dsp_p_ce.eq(1),
            ).Elif(mseq.ongoing("MULTIPLY"),
                dsp_p_ce.eq(1),
                If(step == 0,
                    dsp_a1_ce.eq(1),
                    dsp_a2_ce.eq(1),  # latch the pipelined Axx * 19 signal on the first round of multiply
                    dsp_opmode.eq(OP_PASS_M), # don't add PCIN on the first partial product, as it's bogus on step 0
                ).Else(
                    dsp_a1_ce.eq(0),
                    dsp_a2_ce.eq(0),
                    dsp_opmode.eq(OP_M_PLUS_C),
                ),
                If(step != 14,
                    dsp_b2_ce.eq(1),
                ).Else(
                    dsp_b2_ce.eq(0),
                )
            ).Elif(mseq.ongoing("P_DELAY"),
                dsp_opmode.eq(OP_C_PLUS_0),
                dsp_p_ce.eq(1),
                dsp_b2_ce.eq(1),
                dsp_d_ce.eq(1),
                dsp_a1_ce.eq(1),
            ).Elif(mseq.ongoing("PSUM_LSB"),
                dsp_p_ce.eq(1),
                dsp_b2_ce.eq(1),
                dsp_d_ce.eq(1),
                dsp_opmode.eq(OP_M_PLUS_C),
                dsp_a2_ce.eq(1),
            ).Elif(mseq.ongoing("PSUM_MSB"),
                dsp_p_ce.eq(1),
                dsp_opmode.eq(OP_M_PLUS_P),
            ).Elif(mseq.ongoing("CARRYPROP"),
                dsp_p_ce.eq(0), # move to individual unit P_CEs for this stage
                dsp_opmode.eq(OP_C_PLUS_P),
                If(step==13,
                    dsp_b2_ce.eq(1),
                )
            ).Elif(mseq.ongoing("NORMALIZE"),
                dsp_p_ce.eq(1),
                If(overflow_25519 | (self.dsp_p14[17] == 1),
                    dsp_opmode.eq(OP_AB_PLUS_C),
                ).Else(
                    dsp_opmode.eq(OP_C_PLUS_0),
                )
            )
        ]
        b_step = Signal(17)
        self.comb += [
            # the code below doesn't synthesize well, so let's write out the barrel shifter explicitly
            # getattr(self, "dsp_b" + str(i)).eq((self.b >> (17 * (step + 1))) & 0x1_ffff),  # b_17[step+1]
            # written out explicitly because the fancy for-loop format also leads to a weird synthesis result...
            If(step == 0, b_step.eq(b_17[1])
            ).Elif(step == 1, b_step.eq(b_17[2])
            ).Elif(step == 2, b_step.eq(b_17[3])
            ).Elif(step == 3, b_step.eq(b_17[4])
            ).Elif(step == 4, b_step.eq(b_17[5])
            ).Elif(step == 5, b_step.eq(b_17[6])
            ).Elif(step == 6, b_step.eq(b_17[7])
            ).Elif(step == 7, b_step.eq(b_17[8])
            ).Elif(step == 8, b_step.eq(b_17[9])
            ).Elif(step == 9, b_step.eq(b_17[10])
            ).Elif(step == 10, b_step.eq(b_17[11])
            ).Elif(step == 11, b_step.eq(b_17[12])
            ).Elif(step == 12, b_step.eq(b_17[13])
            ).Elif(step == 13, b_step.eq(b_17[14])
            )
        ]

        for i in range(15):
            self.comb += [
                If(mseq.before_entering("SETUP_A"),
                    getattr( self, "dsp_a" + str(i) ).eq(Cat(a_17[i], zeros[:(30-17)])),
                    getattr( self, "dsp_b" + str(i) ).eq(19),
                ).Elif(mseq.ongoing("SETUP_A"),
                    getattr( self, "dsp_inmode" + str(i) ).eq(Cat(INMODE_A1, INMODE_B2)),
                    getattr(self, "dsp_b" + str(i)).eq(b_17[0]), # preload B00
                ).Elif(mseq.ongoing("MULTIPLY"),
                    getattr(self, "dsp_c" + str(i)).eq(getattr(self, "dsp_p" + str( (i+1) % 15 ))),
                    If(step == 0,
                        getattr(self, "dsp_a" + str(i)).eq(getattr(self, "dsp_p" + str(i))),
                    ),
                    If(step < 14,
                        getattr(self, "dsp_b" + str(i)).eq(Cat(b_step, zeros[:1])),  # b_17[step+1]; note that b input is 18 bits wide, so pad with one 0 to prevent a dangling X on the high bit
                    ),
                    If(step == 0,
                        getattr(self, "dsp_inmode" + str(i)).eq(Cat(INMODE_A1, INMODE_B2)),  # A1 has Axx on the first step only
                    ).Elif(i > (14-step), # lay out the diagonal wrap-around of partial sums
                        getattr(self, "dsp_inmode" + str(i)).eq(Cat(INMODE_A1, INMODE_B2)),  # A1 has Axx*19
                    ).Else(
                        getattr(self, "dsp_inmode" + str(i)).eq(Cat(INMODE_A2, INMODE_B2)),  # A2 has Axx for rest of steps
                    )
                )
            ]

            if i > 0: # sum is different from bottom limb, as the top MSB wraps around
                self.comb += [
                    If(mseq.ongoing("P_DELAY"),
                        getattr(self, "dsp_c" + str(i)).eq(getattr(self, "dsp_p" + str((i + 1) % 15))),
                        getattr(self, "dsp_d" + str(i)).eq((getattr(self, "dsp_p" + str(i)) >> 17) & 0x1_ffff), # (i-1)+1, the +1 is because the result has not been shifted yet
                        getattr(self, "dsp_b" + str(i)).eq(1),
                    )]
            else:
                self.comb += [
                    If(mseq.ongoing("P_DELAY"),
                        getattr(self, "dsp_a" + str(i)).eq(zeros),
                        getattr(self, "dsp_c" + str(i)).eq(getattr(self, "dsp_p" + str((i + 1) % 15))),
                        getattr(self, "dsp_d" + str(i)).eq((getattr(self, "dsp_p" + str(0)) >> 17) & 0x1_ffff),
                        getattr(self, "dsp_b" + str(i)).eq(19),
                    )]

            self.comb += [
                    If(mseq.ongoing("PSUM_LSB"),
                        getattr(self, "dsp_inmode" + str(i)).eq(Cat(INMODE_D, INMODE_B2)),
                        getattr(self, "dsp_c" + str(i)).eq(getattr(self, "dsp_p" + str(i)) & 0x1_ffff),
                    )]
            if i > 1:  # sum-ordering is different for the bottom two limbs, as the top wraps around into two limbs
                self.comb += [
                    If(mseq.ongoing("PSUM_LSB"),
                        getattr(self, "dsp_d" + str(i)).eq((getattr(self, "dsp_p" + str(i - 2)) >> 34) & 0x1_ffff),
                        getattr(self, "dsp_b" + str(i)).eq(1),
                    )]
            elif i == 1:
                self.comb += [
                    If(mseq.ongoing("PSUM_LSB"),
                        getattr(self, "dsp_d" + str(i)).eq((getattr(self, "dsp_p" + str(14)) >> 34) & 0x1_ffff),
                        getattr(self, "dsp_b" + str(i)).eq(19),
                    )]
            else:
                self.comb += [
                    If(mseq.ongoing("PSUM_LSB"),
                        getattr(self, "dsp_d" + str(i)).eq((getattr(self, "dsp_p" + str(13)) >> 34) & 0x1_ffff),
                        getattr(self, "dsp_b" + str(i)).eq(19),
                    )]

            self.comb += [
                If(mseq.ongoing("PSUM_MSB"),
                    getattr(self, "dsp_c0").eq(zeros), # dsp_c is actually don't care due to the opmode
                    getattr(self, "dsp_inmode" + str(i)).eq(Cat(INMODE_D, INMODE_B2)),
                ).Elif(mseq.ongoing("NORMALIZE"),
                    getattr(self, "dsp_c" + str(i)).eq(getattr(self, "dsp_p" + str(i)) & 0x1_ffff),
                    getattr(self, "dsp_inmode" + str(i)).eq(Cat(INMODE_0, INMODE_B2)),
                )
            ]

            if i == 0:
                self.comb += [
                    If(mseq.ongoing("CARRYPROP"),
                        getattr(self, "dsp_c" + str(i)).eq( zeros ),
                    ),
                    If(mseq.ongoing("CARRYPROP") & (step == 13),
                        getattr(self, "dsp_b" + str(i)).eq( 19 ), # special-case constant to handle normalization in overflow of prime field; a is loded with 0 on previous cycle
                    ),
                ]
            else:
                self.comb += [
                    If(mseq.ongoing("CARRYPROP"),
                        getattr(self, "dsp_c" + str(i)).eq( Cat(getattr(self, "dsp_p" + str(i - 1)) >> 17, zeros[:17]) ),
                        getattr(self, "dsp_p_ce" + str(i)).eq(step == (i-1)),
                    ),
                    If(mseq.ongoing("CARRYPROP") & (step == 13),
                        getattr(self, "dsp_b" + str(i)).eq(0),
                    )
                ]
            if sim:
                instance = "DSP48E1_sim"
            else:
                instance = "DSP48E1"
            self.specials += [
                Instance(instance, name="DSP_ENG25519_" + str(i),
                    # configure number of input registers
                    p_ACASCREG=1,
                    p_AREG=2,
                    p_ADREG=0,
                    p_ALUMODEREG=0,
                    p_BCASCREG=1,
                    p_BREG=1,

                    # only pipeline at the output
                    p_CARRYINREG=0,
                    p_CARRYINSELREG=0,
                    p_CREG=0,
                    p_DREG=1, # i think we can use this to save some fabric registers
                    p_INMODEREG=0,
                    p_MREG=0,
                    p_OPMODEREG=0,
                    p_PREG=1,

                    p_A_INPUT="DIRECT",
                    p_B_INPUT="DIRECT",
                    p_USE_DPORT="TRUE",
                    p_USE_MULT="DYNAMIC",
                    p_USE_SIMD="ONE48",

                    # setup pattern detector to catch the case of mostly 1's
                    p_AUTORESET_PATDET="NO_RESET",
                    p_MASK   =0xffff_fffe_0000, #'1'*(48-17)+'0'*17,  # 1 bits are ignored, 0 compared
                    p_PATTERN=0x1_ffff, # '0'*(48-17)+'1'*17,  # compare against 0x1_FFFF
                    p_SEL_MASK="MASK",
                    p_SEL_PATTERN="PATTERN",
                    p_USE_PATTERN_DETECT="PATDET",

                    # signals
                    i_A=getattr(self, "dsp_a" + str(i)),
                    i_ALUMODE=dsp_alumode,
                    i_B=Cat(getattr(self, "dsp_b" + str(i)), zeros[:(18-17)]),
                    i_C=getattr(self, "dsp_c" + str(i)),
                    i_CARRYIN=0,
                    i_CARRYINSEL=zeros[:3],
                    i_CEA1=dsp_a1_ce,
                    i_CEA2=dsp_a2_ce,
                    i_CEAD=0, # no pipe
                    i_CEALUMODE=0, # no pipe
                    i_CEB1=dsp_b1_ce,
                    i_CEB2=dsp_b2_ce,
                    i_CEC=0, # no pipe
                    i_CECARRYIN=0,
                    i_CECTRL=0, # no pipe on opmode
                    i_CED=dsp_d_ce,
                    i_CEP=dsp_p_ce | getattr(self, "dsp_p_ce" + str(i)),
                    i_CLK=ClockSignal("mul_clk"),  # run at 2x speed of engine clock
                    i_D=Cat(getattr(self, "dsp_d" + str(i)), zeros[:(25-17)]),
                    i_INMODE=getattr(self, "dsp_inmode" + str(i)),
                    i_OPMODE=dsp_opmode,
                    o_P=getattr(self, "dsp_p" + str(i)),
                    o_PATTERNDETECT=getattr(self, "dsp_match" + str(i)),

                    # tie unused CE to active
                    i_CEM=0,
                    i_CEINMODE=1,

                    # resets
                    i_RSTA=dsp_reset,
                    i_RSTALLCARRYIN=dsp_reset,
                    i_RSTALUMODE=dsp_reset,
                    i_RSTB=dsp_reset,
                    i_RSTC=dsp_reset,
                    i_RSTCTRL=dsp_reset,
                    i_RSTD=dsp_reset,
                    i_RSTINMODE=dsp_reset,
                    i_RSTM=dsp_reset,
                    i_RSTP=dsp_reset,
                )
            ]
            self.sync.mul_clk += [ # this syncs into the eng_clk domain
                If(mseq.ongoing("DONE"), ## mod this to sync with the phase that the state machine ends on
                   self.q[i * 17:i * 17 + 17].eq(getattr(self, "dsp_p" + str(i))[:17]),
                ).Else(
                    self.q[i * 17:i * 17 + 17].eq(self.q[i * 17:i * 17 + 17]),
                ),
            ]
        # whether we are asserting on DONE/DONE2 or DONE2/DONE3 depends on even/odd # of states previously spent to compute the mul
        self.sync.mul_clk += [
            If(mseq.ongoing("DONE2") | mseq.ongoing("DONE3"),
                self.q_valid.eq(1),
               ).Else(
                self.q_valid.eq(0),
            )
        ]
        # compute special-case detection if the partial sum output is >= 2^255-19
        self.comb += [
            overflow_25519.eq(
                self.dsp_match14 &
                self.dsp_match13 &
                self.dsp_match12 &
                self.dsp_match11 &
                self.dsp_match10 &
                self.dsp_match9 &
                self.dsp_match8 &
                self.dsp_match7 &
                self.dsp_match6 &
                self.dsp_match5 &
                self.dsp_match4 &
                self.dsp_match3 &
                self.dsp_match2 &
                self.dsp_match1 &
                (self.dsp_p0 >= 0x1_ffed)
            )
        ]


class Engine(Module, AutoCSR, AutoDoc):
    def __init__(self, platform, prefix, sim=False):
        opdoc = "\n"
        for mnemonic, description in opcodes.items():
            opdoc += f" * **{mnemonic}** ({str(description[0])}) -- {description[1]} \n"

        self.intro = ModuleDoc(title="Curve25519 Engine", body="""
The Curve25519 engine is a microcoded hardware accelerator for Curve25519 operations.
The Engine loosely resembles a Harvard architecture microcoded CPU, with a single 
512-entry, 256-bit wide 2R1W windowed-register file, a handful of execution units, and a "mailbox"
unit (like a load/store, but transactional to wishbone). The Engine's microcode is 
contained in a 1k-entry, 32-bit wide microcode block. Microcode procedures are written to
the block, and execution can only proceed in a linear fashion (no branches supported) from
a given offset, and execution will stop after a certain length run.

The register file is "windowed". A single window consists of 32x256-bit wide registers,
and there are up to 16 windows. The concept behind windows is that core routines, such
as point doubling and point addition, can be coded using no more than 32 intermediate
results. The same microcode can be used, then, to operate on up to 16 different point
sets at the same time, selectable by the window.

Every register read can be overridden from a constant ROM, by asserting `ca` or `cb` for
registers a and b respectively. When either of these bits are asserted, the respective
register address is fed into a constant table, and the result of that table lookup is
replaced for the constant value. This means up to 32 commonly used constants may be stored.

The Engine address space is divided up as follows::

 0x0_0000 - 0x0_0fff: microcode (one 4k byte page)
 0x1_0000 - 0x1_3fff: memory-mapped register file (4 x 4k pages = 16kbytes)
 
Here are the currently implemented opcodes for The Engine:
{}  
        """.format(opdoc))

        ##### TIMING CONSTRAINTS -- you want these. Trust me.
        ### clk200->clk50 multi-cycle paths:
        # we architecturally guarantee extra setup time from the register file to the point of consumption:
        # read data is stable by the 3rd phase of the RF fetch cycle, and so it is in fact ready even before
        # the other signals that trigger the execute mode, hence 4+1 cycles total setup time
        platform.add_platform_command("set_multicycle_path 5 -setup -start -from [get_clocks clk200] -to [get_clocks clk50] -through [get_cells *rf_r*_dat_reg*]")
        platform.add_platform_command("set_multicycle_path 4 -hold -from [get_clocks clk200] -to [get_clocks clk50] -through [get_cells *rf_r*_dat_reg*]")
        ### clk200->clk100 multi-cycle paths:
        # same as above, but for the multiplier path.
        platform.add_platform_command("set_multicycle_path 3 -setup -start -from [get_clocks clk200] -to [get_clocks sys_clk] -through [get_cells *rf_r*_dat_reg*]")
        platform.add_platform_command("set_multicycle_path 2 -hold -from [get_clocks clk200] -to [get_clocks sys_clk] -through [get_cells *rf_r*_dat_reg*]")
        ### sys->clk200 multi-cycle paths:
        # microcode fetch is stable 10ns before use by the register file, by design
        platform.add_platform_command("set_multicycle_path 2 -setup -from [get_clocks sys_clk] -to [get_clocks clk200] -through [get_nets engine_ra_adr*]")
        platform.add_platform_command("set_multicycle_path 1 -hold -end -from [get_clocks sys_clk] -to [get_clocks clk200] -through [get_nets engine_ra_adr*]")
        platform.add_platform_command("set_multicycle_path 2 -setup -from [get_clocks sys_clk] -to [get_clocks clk200] -through [get_nets engine_rb_adr*]")
        platform.add_platform_command("set_multicycle_path 1 -hold -end -from [get_clocks sys_clk] -to [get_clocks clk200] -through [get_nets engine_rb_adr*]")
        # ignore the clk200 reset path for timing purposes -- there is >1 cycle guaranteed after reset for everything to settle before anything moves on these paths
        platform.add_platform_command("set_false_path -through [get_nets clk200_rst]")
        # ignore the clk50 reset path for timing purposes -- there is > 1 cycle guaranteed after reset for everything to settle before anything moves on these paths (applies for other crypto engines, (SHA/AES) as well)
        platform.add_platform_command("set_false_path -through [get_nets clk50_rst]")
        ### sys->clk50 multi-cycle paths:
        # microcode fetch is guaranteed not to transition in the middle of an exec computation
        platform.add_platform_command("set_multicycle_path 2 -setup -start -from [get_clocks sys_clk] -to [get_clocks clk50] -through [get_cells microcode_reg*]")
        platform.add_platform_command("set_multicycle_path 1 -hold -from [get_clocks sys_clk] -to [get_clocks clk50] -through [get_cells microcode_reg*]")
        ### clk50->clk200 multi-cycle paths:
        # engine running will set up a full eng_clk cycle before any RF accesses need to be valid
        platform.add_platform_command("set_multicycle_path 4 -setup -from [get_clocks clk50] -to [get_clocks clk200] -through [get_nets engine_running*]")
        platform.add_platform_command("set_multicycle_path 3 -hold -end -from [get_clocks clk50] -to [get_clocks clk200] -through [get_nets engine_running*]")
        # data writeback happens on phase==2, and thus is stable for at least two clk200 clocks extra
        platform.add_platform_command("set_multicycle_path 2 -setup -from [get_clocks clk50] -to [get_clocks clk200] -through [get_pins RF_RAMB*/*/DI*DI*]")
        platform.add_platform_command("set_multicycle_path 1 -hold -end -from [get_clocks clk50] -to [get_clocks clk200] -through [get_pins RF_RAMB*/*/DI*DI*]")
        platform.add_platform_command("set_multicycle_path 2 -setup -from [get_clocks clk50] -to [get_clocks clk200] -through [get_pins RF_RAMB*/*/ADDR*ADDR*]")
        platform.add_platform_command("set_multicycle_path 1 -hold -end -from [get_clocks clk50] -to [get_clocks clk200] -through [get_pins RF_RAMB*/*/ADDR*ADDR*]")
        ### sys->clk200 multi-cycle paths:
        # data writeback happens on phase==2, and thus is stable for at least two clk200 clocks extra
        platform.add_platform_command("set_multicycle_path 2 -setup -from [get_clocks sys_clk] -to [get_clocks clk200] -through [get_pins RF_RAMB*/*/DI*DI*]")
        platform.add_platform_command("set_multicycle_path 1 -hold -end -from [get_clocks sys_clk] -to [get_clocks clk200] -through [get_pins RF_RAMB*/*/DI*DI*]")
        platform.add_platform_command("set_multicycle_path 2 -setup -from [get_clocks sys_clk] -to [get_clocks clk200] -through [get_pins RF_RAMB*/*/ADDR*ADDR*]")
        platform.add_platform_command("set_multicycle_path 1 -hold -end -from [get_clocks sys_clk] -to [get_clocks clk200] -through [get_pins RF_RAMB*/*/ADDR*ADDR*]")

        microcode_width = 32
        microcode_depth = 1024
        running = Signal() # asserted when microcode is running

        instruction = Record(instruction_layout) # current instruction to execute
        illegal_opcode = Signal()

        ### register file
        rf_depth_raw = 512
        rf_width_raw = 256
        self.submodules.rf = rf = RegisterFile(depth=rf_depth_raw, width=rf_width_raw)
        self.specials += MultiReg(ResetSignal("eng_clk"), rf.clear, "eng_clk") # sync up the register file's fast clock to our slow clock

        self.window = CSRStorage(fields=[
            CSRField("window", size=log2_int(rf_depth_raw) - log2_int(num_registers), description="Selects the current register window to use"),
        ])

        self.mpstart = CSRStorage(fields=[
            CSRField("mpstart", size=log2_int(microcode_depth), description="Where to start execution")
        ])
        self.mplen = CSRStorage(fields=[
            CSRField("mplen", size=log2_int(microcode_depth), description="Length of the current microcode program. Thus valid code must be in the range of [mpstart, mpstart + mplen]"),
        ])
        self.control = CSRStorage(fields=[
            CSRField("go", size=1, pulse=True, description="Writing to this puts the engine in `run` mode, and it will execute mplen microcode instructions starting at mpstart"),
        ])
        self.status = CSRStorage(fields=[
            CSRField("running", size=1, description="When set, the microcode engine is running. All wishbone access to RF and microcode memory areas will stall until this bit is clear"),
            CSRField("mpc", size=log2_int(microcode_depth), description="Current location of the microcode program counter. Mostly for debug."),
        ])
        self.comb += self.status.fields.running.eq(running)

        self.submodules.ev = EventManager()
        self.ev.finished = EventSourcePulse(description="Microcode run finished execution")
        self.ev.illegal_opcode = EventSourcePulse(description="Illegal opcode encountered")
        self.ev.finalize()
        running_r = Signal()
        ill_op_r = Signal()
        self.sync += [
        running_r.eq(running),
            ill_op_r.eq(illegal_opcode),
        ]
        self.comb += [
            self.ev.finished.trigger.eq(~running & running_r), # falling edge pulse on running
            self.ev.illegal_opcode.trigger.eq(~ill_op_r & illegal_opcode),
        ]

        ### microcode memory - 1rd/1wr dedicated to wishbone, 1rd for execution
        microcode = Memory(microcode_width, microcode_depth)
        self.specials += microcode
        micro_wrport = microcode.get_port(write_capable=True, mode=READ_FIRST) # READ_FIRST allows BRAM inference
        self.specials += micro_wrport
        micro_rdport = microcode.get_port(mode=READ_FIRST)
        self.specials += micro_rdport
        micro_runport = microcode.get_port(mode=READ_FIRST) # , clock_domain="eng_clk"
        self.specials += micro_runport

        mpc = Signal(log2_int(microcode_depth))  # the microcode program counter
        self.comb += [
            micro_runport.adr.eq(mpc),
            instruction.raw_bits().eq(micro_runport.dat_r),  # mapping should follow the record definition *exactly*
            instruction.eq(micro_runport.dat_r),
        ]
        instruction_fields = []
        for opcode, bits, description in instruction_layout:
            instruction_fields.append(CSRField(opcode, size=bits, description=description))
        self.instruction = CSRStatus(description="Current instruction being executed by the engine. The format of this register exactly reflects the binary layout of an Engine instruction.", fields=instruction_fields)
        self.comb += [
            self.instruction.status.eq(micro_runport.dat_r)
        ]

        ### wishbone bus interface: decode the two address spaces and dispatch accordingly
        self.bus = bus = wishbone.Interface()
        wdata = Signal(32)
        wadr = Signal(log2_int(rf_depth_raw) + 3) # wishbone bus is 32-bits wide, so 3 extra bits to select the sub-words out of the 256-bit registers
        wmask = Signal(4)
        wdata_we = Signal()
        rdata_re = Signal()
        rdata_ack = Signal()
        rdata_req = Signal()
        radr = Signal(log2_int(rf_depth_raw) + 3)

        micro_rd_waitstates = 2
        micro_rdack = Signal(max=(micro_rd_waitstates+1))
        self.sync += [
            If( ((bus.adr & ((0xFFFF_C000) >> 2)) >= ((prefix | 0x1_0000) >> 2)) & (((bus.adr & ((0xFFFF_C000) >> 2)) < ((prefix | 0x1_4000) >> 2))),
                # fully decode register file address to avoid aliasing
                If(bus.cyc & bus.stb & bus.we & ~bus.ack,
                    If(~running,
                        wdata.eq(bus.dat_w),
                        wadr.eq(bus.adr[:wadr.nbits]),
                        wmask.eq(bus.sel),
                        wdata_we.eq(1),
                        If(rf.phase,
                            bus.ack.eq(1),
                        ).Else(
                            bus.ack.eq(0),
                        ),
                    ).Else(
                        wdata_we.eq(0),
                        bus.ack.eq(0),
                    )
                ).Elif(bus.cyc & bus.stb & ~bus.we & ~bus.ack,
                    If(~running,
                        radr.eq(bus.adr[:radr.nbits]),
                        rdata_re.eq(1),
                        bus.dat_r.eq( rf.ra_dat >> ((radr & 0x7) * 32) ),
                        bus.ack.eq(rdata_ack),
                        rdata_req.eq(1),
                    ).Else(
                        rdata_re.eq(0),
                        bus.ack.eq(0),
                        rdata_req.eq(0),
                    )
                ).Else(
                    wdata_we.eq(0),
                    bus.ack.eq(0),
                    rdata_req.eq(0),
                    rdata_re.eq(0),
                )
            ).Elif( (bus.adr & ((0xFFFF_F000) >> 2)) == ((0x0 | prefix) >> 2),
                # fully decode microcode address to avoid aliasing
                If(bus.cyc & bus.stb & bus.we & ~bus.ack,
                    micro_wrport.adr.eq(bus.adr),
                    micro_wrport.dat_w.eq(bus.dat_w),
                    micro_wrport.we.eq(1),
                    bus.ack.eq(1),
                ).Elif(bus.cyc & bus.stb & ~bus.we & ~bus.ack,
                    micro_wrport.we.eq(0),
                    micro_rdport.adr.eq(bus.adr),
                    bus.dat_r.eq(micro_rdport.dat_r),

                    If(micro_rdack == 0, # 1 cycle delay for read to occur
                        bus.ack.eq(1),
                    ).Else(
                        bus.ack.eq(0),
                        micro_rdack.eq(micro_rdack - 1),
                    )
                ).Else(
                    micro_wrport.we.eq(0),
                    micro_rdack.eq(micro_rd_waitstates),
                    bus.ack.eq(0),
                )
            ).Else(
                # handle all mis-target reads not explicitly decoded
                If(bus.cyc & bus.stb & ~bus.we & ~bus.ack,
                    bus.dat_r.eq(0xC0DE_BADD),
                    bus.ack.eq(1),
                ).Elif(bus.cyc & bus.stb & bus.we & ~bus.ack,
                    bus.ack.eq(1), # ignore writes -- but don't hang the bus
                ).Else(
                    bus.ack.eq(0),
                )

            )
        ]

        ### execution path signals to register file
        ra_dat = Signal(rf_width_raw)
        ra_adr = Signal(log2_int(num_registers))
        ra_const = Signal()
        rb_dat = Signal(rf_width_raw)
        rb_adr = Signal(log2_int(num_registers))
        rb_const = Signal()
        wd_dat = Signal(rf_width_raw)
        wd_adr = Signal(log2_int(num_registers))
        rf_write = Signal()

        self.submodules.ra_const_rom = Curve25519Const(insert_docs=True)
        self.submodules.rb_const_rom = Curve25519Const()

        ### merge execution path signals with host access paths
        self.comb += [
            ra_adr.eq(instruction.ra),
            rb_adr.eq(instruction.rb),
            self.ra_const_rom.adr.eq(ra_adr),
            self.rb_const_rom.adr.eq(rb_adr),
            rf.window.eq(self.window.fields.window),

            If(running,
                rf.ra_adr.eq(Cat(ra_adr, self.window.fields.window)),
                rf.rb_adr.eq(Cat(rb_adr, self.window.fields.window)),
                rf.instruction_pipe_in.eq(instruction.raw_bits()),
                rf.wd_adr.eq(Cat(wd_adr, self.window.fields.window)),
                rf.wd_dat.eq(wd_dat),
                rf.wd_bwe.eq(0xFFFF_FFFF), # enable all bytes
                rf.we.eq(rf_write),
            ).Else(
                rf.ra_adr.eq(radr >> 3),
                rf.wd_adr.eq(wadr >> 3),
                rf.wd_dat.eq(Cat(wdata,wdata,wdata,wdata,wdata,wdata,wdata,wdata)), # replicate; use byte-enable to multiplex
                rf.wd_bwe.eq(0xF << ((wadr & 0x7) * 4)), # select the byte
                rf.we.eq(wdata_we),
            ),
            If(~ra_const,
                ra_dat.eq(rf.ra_dat),
            ).Else(
                ra_dat.eq(self.ra_const_rom.const)
            ),
            If(~rb_const,
                rb_dat.eq(rf.rb_dat),
            ).Else(
                rb_dat.eq(self.rb_const_rom.const)
            )
        ]
        # simple machine to wait 2 RF clock cycles for data to propagate out of the register file and back to the host
        rd_wait_states=4
        bus_rd_wait = Signal(max=(rd_wait_states+1))
        self.sync.rf_clk += [
            If(rdata_req,
                If(~running,
                    If(bus_rd_wait != 0,
                        bus_rd_wait.eq(bus_rd_wait-1),
                    ).Else(
                        rdata_ack.eq(1),
                    )
                )
            ).Else(
                rdata_ack.eq(0),
                bus_rd_wait.eq(rd_wait_states),
            )
        ]

        sext_immediate = Signal((log2_int(microcode_depth), True)) # make this signal signed
        self.comb += sext_immediate.eq(instruction.immediate) # does this automatically do sign extension? who knows. migen claims "user-friendly sign extension rules, (a la MyHDL)", with no further explanation. :-P

        ### Microcode sequencer. Very simple: it can only run linear sections of microcode. Feature not bug;
        ### constant time operation is a defense against timing attacks.

        # pulse-stretch the go from sys->eng_clk. Don't use Migen CDC primitives, as they add latency; a BlindTransfer
        # primitive on its own will take about as much time as a couple instructions on The Engine.
        engine_go = Signal()
        go_stretch = Signal(2)
        self.sync += [
            If(self.control.fields.go,
                go_stretch.eq(2)
            ).Else(
                If(go_stretch != 0,
                   go_stretch.eq(go_stretch - 1),
                )
            )
        ]
        self.comb += engine_go.eq(self.control.fields.go | (go_stretch != 0))

        self.submodules.seq = seq = ClockDomainsRenamer("eng_clk")(FSM(reset_state="IDLE"))
        mpc_stop = Signal(log2_int(microcode_depth))
        window_latch = Signal(self.window.fields.window.size)
        exec = Signal()  # indicates to execution units to start running
        done = Signal()  # indicates when the given execution units are done (as-muxed from subunits)
        self.comb += rf.running.eq(~seq.ongoing("IDLE") | rdata_re),  # let the RF know when we're not executing, so it can idle to save power
        seq.act("IDLE",
            If(engine_go,
                NextValue(mpc, self.mpstart.fields.mpstart),
                NextValue(mpc_stop, self.mpstart.fields.mpstart + self.mplen.fields.mplen - 1),
                NextValue(window_latch, self.window.fields.window),
                NextValue(running, 1),
                NextState("FETCH"),
            ).Else(
                NextValue(running, 0),
            )
        )
        seq.act("FETCH",
            # one cycle latency for instruction fetch
            NextState("EXEC"),
        )
        seq.act("EXEC",
            If(instruction.opcode == opcodes["BRZ"][0],
                NextState("DO_BRZ"),
            ).Elif(instruction.opcode == opcodes["FIN"][0],
                NextState("IDLE"),
                NextValue(running, 0),
            ).Elif(instruction.opcode < opcodes["MAX"][0], # check if the opcode is legal before running it
                exec.eq(1),
                NextState("WAIT_DONE"),
            ).Else(
                NextState("ILLEGAL_OPCODE"),
            )
        )
        seq.act("WAIT_DONE",
            If(done, # TODO: for now, we just wait for each instruction to finish; but the foundations are around for pipelining...
                If(mpc < mpc_stop,
                   NextState("FETCH"),
                   NextValue(mpc, mpc + 1),
                ).Else(
                    NextState("IDLE"),
                    NextValue(running, 0),
                )
            )
        )
        seq.act("ILLEGAL_OPCODE",
            NextState("IDLE"),
            NextValue(running, 0),
            illegal_opcode.eq(1),
        )
        seq.act("DO_BRZ",
            If(ra_dat == 0,
                If( (rb_dat[:mpc.nbits] < mpc_stop) & (rb_dat[:mpc.nbits] >= self.mpstart.fields.mpstart), # validate new PC is in range
                   NextValue(mpc, sext_immediate + mpc + 1),
                ).Else(
                    NextState("IDLE"),
                    NextValue(running, 0),
                )
            ).Else(
                If(mpc < mpc_stop,
                   NextValue(mpc, mpc + 1),
                ).Else(
                    NextState("IDLE"),
                    NextValue(running, 0),
                )
            ),
        )

        exec_units = {
            "exec_mask"      : ExecMask(width=rf_width_raw),
            "exec_logic"     : ExecLogic(width=rf_width_raw),
            "exec_addsub"    : ExecAddSub(width=rf_width_raw),
            "exec_testreduce": ExecTestReduce(width=rf_width_raw),
            "exec_mul"       : ExecMul(width=rf_width_raw, sim=sim),
        }
        index = 0
        for name, unit in exec_units.items():
            setattr(self.submodules, name, unit);
            setattr(self, "done" + str(index), Signal(name="done"+str(index)))
            setattr(self, "unit_q" + str(index), Signal(wd_dat.nbits, name="unit_q"+str(index)))
            setattr(self, "unit_sel" + str(index), Signal(name="unit_sel"+str(index)))
            setattr(self, "unit_wd" + str(index), Signal(log2_int(num_registers), name="unit_wd"+str(index)))
            subdecode = Signal()
            for op in unit.opcode_list:
                self.comb += [
                    If(instruction.opcode == opcodes[op][0],
                        subdecode.eq(1)
                    )
                ]
            instruction_out = Record(instruction_layout)
            self.comb += [
                instruction_out.raw_bits().eq(unit.instruction_out)
            ]
            self.comb += [
                unit.start.eq(exec & subdecode),
                getattr(self, "done" + str(index)).eq(unit.q_valid),
                unit.a.eq(ra_dat),
                unit.b.eq(rb_dat),
                unit.instruction_in.eq(instruction.raw_bits()),
                getattr(self, "unit_q" + str(index)).eq(unit.q),
                getattr(self, "unit_sel" + str(index)).eq(subdecode),
                getattr(self, "unit_wd" + str(index)).eq(instruction_out.wd),
            ]
            index += 1

        for i in range(index):
            self.comb += [
                If(getattr(self, "done" + str(i)),
                   done.eq(1),  # TODO: for proper pipelining, handle case of two units done simultaneously!
                   wd_dat.eq(getattr(self, "unit_q" + str(i))),
                   wd_adr.eq(getattr(self, "unit_wd" + str(i))),
                ).Elif(seq.ongoing("IDLE"),
                    done.eq(0),
                )
            ]

        self.comb += [
            rf_write.eq(done),
        ]