from migen import *
from migen.genlib.cdc import BlindTransfer

from litex.soc.interconnect.csr import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect import wishbone
from litex.soc.interconnect.csr_eventmanager import *

opcode_bits = 6  # number of bits used to encode the opcode field
opcodes = {  # mnemonic : [bit coding, docstring]
    "UDF" : [-1, "Undefined opcodes"],
    "PSA" : [0, "Wd <- Ra  # pass A"],
    "PSB" : [1, "Wd <- Rb  # pass B"],
    "MSK" : [2, "Replicate(Ra[0], 256) & Rb  # for doing cswap()"],
    "XOR" : [3, "XOR", "Wd <- Ra ^ Rb  # bitwise XOR"],
    "NOT" : [4, "Wd <- ~Ra   # binary invert"],
    "ADD" : [5, "Wd <- Ra + Rb  # 256-bit binary add, must be followed by TRD,SUB"],
    "SUB" : [6, "Wd <- Ra - Rb  # 256-bit binary subtraction, must be followed by TRD,SUB"],
    "MUL" : [7, "Wd <- Ra * Rb  # multiplication in F(2^255-19) - result is normalized"],
    "TRD" : [8, "If Ra >= 2^255-19 then Wd <- 2^255-19, else Wd <- 0  # Test reduce"],
    "BRZ" : [9, "If Ra == 0 then mpc[9:0] <- mpc[9:0] + Rb[9:0], else mpc <- mpc + 1  # Branch if zero"],
    "MAX" : [10, "Maximum opcode number"]
}

class RegisterFile(Module, AutoDoc):
    def __init__(self, depth=512, width=256):
        reset_cycles = 4
        self.intro = ModuleDoc("""
This implements the register file for the Curve25519 engine. It's implemented using
7-series specific block RAMs in order to take advantage of architecture-specific features
to ensure a compact and performant implementation.

The core primitive is the RAMB36E1. This can be configured as a 64/72-bit wide memory
but only if used in "SDP" (simple dual port) mode. In SDP, you have one read, one write port.
However, the register file needs to produce two operands per cycle, while accepting up to
one operand per cycle. 

In order to do this, we stipulate that the RF runs at `rf_clk` (100MHz), but uses two phases 
to produce/consume data according to a half-rate "Engine clock" `eng_clk` (50MHz).

The phasing is defined as follows:

Phase 0:
  - read from port A
Phase 1:
  - read from port B
  - write data
  
The writing of data is done in the second phase so that in the case you are writing
to the same address as being read, we guarantee the value read is the old value.

The register file is unavailable for {} `eng_clk` cycles after reset.

When configured as a 64 bit memory, the depth of the block is 512 bits, corresponding to 
an address width of 9 bits.
        """.format(reset_cycles))

        self.phase = phase = Signal()

        # these are the signals in and out of the register file
        self.ra_dat = Signal(width)
        self.ra_adr = Signal(log2_int(depth))
        self.rb_dat = Signal(width)
        self.rb_adr = Signal(log2_int(depth))
        self.wd_dat = Signal(width)
        self.wd_adr = Signal(log2_int(depth))
        self.wd_bwe = Signal(width//8)  # byte masks for writing
        self.we = Signal()
        self.clear = Signal()

        eng_sync = Signal(reset=1)

        rf_adr = Signal(log2_int(depth))
        self.comb += [
            If(~phase,
                rf_adr.eq(self.ra_adr),
            ).Else(
                rf_adr.eq(self.rb_adr),
            )
        ]
        rf_dat = Signal(width)
        self.sync.rf_clk += [
            If(phase,
                self.ra_dat.eq(rf_dat),
                self.rb_dat.eq(self.rb_dat),
            ).Else(
                self.ra_dat.eq(self.ra_dat),
                self.rb_dat.eq(rf_dat),
            ),
            If(eng_sync,
                phase.eq(0),
            ).Else(
                phase.eq(~phase),
            )
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
                i_RDEN = 1,
                i_WREN = phase & self.we,
                i_RST = eng_sync,
                i_WE = self.wd_bwe[word*8 : word*8 + 8],
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
    def __init__(self):
        constant_defs = {
            0: [0, "zero", "The number zero"],
            1: [121665, "a24", "The value A-2/4"],
            2: [0x7FFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFED, "field", "Binary coding of 2^255-19"],
            3: [0xFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF, "neg1", "Binary -1"],
            4: [1, "one", "The number one"],
        }
        self.intro = ModuleDoc("""
This module encodes the constants that can be substituted for any register
value. Up to 32 constants can be encoded in this ROM.
        """)
        self.adr = Signal(5)
        self.const = Signal(256)
        for code, const in constant_defs.items():
            self.comb += [
                If(self.adr == code,
                    self.const.eq(const[0]),
                )
            ]
            setattr(self, const[1], ModuleDoc(const[2]))

# ------------------------------------------------------------------------ EXECUTION UNITS
class ExecUnit(Module, AutoDoc):
    def __init__(self, width=256, opcode_list=["UDF"]):
        self.intro = ModuleDoc("""
ExecUnit is the superclass template for execution units.

Configuration Arguments:
  - opcode_list is the list of opcodes that an ExecUnit can process
  - width is the bit-width of the execution pathway

Signal API for an exec unit:
  - `a` and `b` are the inputs. `q` is the output.
  - `start` is a single-clock signal which indicates processing should start
  - `q_valid` is a single cycle pulse that indicates that the `q` result is valid
  - `opcode` is the current opcode being executed (for finer-grained decode of multi-functional units)
        """)
        self.a = Signal(width)
        self.b = Signal(width)
        self.q = Signal(width)
        self.start = Signal()
        self.q_valid = Signal()

        self.opcode_list = opcode_list
        self.opcode = Signal(opcode_bits)

class ExecMask(ExecUnit):
    def __init__(self, width=256):
        ExecUnit.__init__(self, width, ["MSK"])

        self.sync.eng_clk += [
            self.q_valid.eq(self.start),
            self.q.eq(self.b & Replicate(self.a[0], width))
        ]

class ExecLogic(ExecUnit):
    def __init__(self, width=256):
        ExecUnit.__init__(self, width, ["XOR", "NOT", "PSA", "PSB"])

        self.sync.eng_clk += [
            self.q_valid.eq(self.start),
            If(self.opcode == opcodes["XOR"][0],
               self.q.eq(self.a ^ self.b)
            ).Elif(self.opcode == opcodes["NOT"][0],
               self.q.eq(~self.a)
            ).Elif(self.opcode == opcodes["PSA"][0],
                self.q.eq(self.a),
            ).Elif(self.opcode == opcodes["PSB"][0],
                self.q.eq(self.b),
            )
        ]

class ExecAddSub(ExecUnit):
    def __init__(self, width=256):
        ExecUnit.__init__(self, width, ["ADD", "SUB"])

        self.sync.eng_clk += [
            self.q_valid.eq(self.start),
            If(self.opcode == opcodes["ADD"][0],
               self.q.eq(self.a + self.b),
            ).Elif(self.opcode == opcodes["SUB"][0],
               self.q.eq(self.a - self.b),
            )
        ]

class ExecTestReduce(ExecUnit, AutoDoc):
    def __init__(self, width=256):
        ExecUnit.__init__(self, width, ["TRD"])

        self.notes = ModuleDoc("""
First, observe that 2^n-19 is 0xFF....FFED.
Next, observe that arithmetic in the field 2^255-19 will never
the 256th bit. 

Modular reduction must happen when an arithmetic operation
overflows the bounds of the modulus. When this happens, one must
subtract the modulus (in this case 2^255-19). 

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
  - If the 256th bit is set (e.g, ra[255]), then return 2^255-19
  - If bits ra[255:5] are all 1, and bits ra[4:0] are greater than or equal to 0x1D, then return 2^255-19
  - Otherwise return 0
2. Subtract
  - Subtract the return value of TestReduce from the tested value
        """)
        self.sync.eng_clk += [
            If( (self.a[255] == 1) | ((self.a[5:256] == Replicate(1, 251) & (self.a[:5] >= 0x1D))),
                self.q.eq(0x7FFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFED)
            ).Else(
                self.q.eq(0x0)
            )
        ]


class Engine(Module, AutoCSR, AutoDoc):
    def __init__(self, platform, prefix):
        self.intro = ModuleDoc("""
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

The Engine address space is divided up as follows:

Offset:
   0x0_0000 - 0x0_0fff: microcode (one 4k byte page)
   0x1_0000 - 0x1_3fff: memory-mapped register file (4 x 4k pages = 16kbytes) 
        """)
        microcode_width = 32
        microcode_depth = 1024
        running = Signal() # asserted when microcode is running
        num_registers = 32

        instruction_layout = [
            ("opcode", opcode_bits), # opcode to be executed
            ("ra", log2_int(num_registers)),  # operand A read register
            ("ca", 1), # substitute constant table value for A
            ("rb", log2_int(num_registers)), # operand B read register
            ("cb", 1), # substitute constant table value for B
            ("wd", log2_int(num_registers)), # write register
            ("reserved", 9) # reserved for future use. Must be set to 0.
        ]
        instruction = Record(instruction_layout) # current instruction to execute
        illegal_opcode = Signal()

        ### register file
        rf_depth_raw = 512
        rf_width_raw = 256
        self.submodules.rf = rf = RegisterFile(depth=rf_depth_raw, width=rf_width_raw)

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
        micro_runport = microcode.get_port(mode=READ_FIRST)
        self.specials += micro_runport

        mpc = Signal(log2_int(microcode_depth))  # the microcode program counter
        self.comb += [
            micro_runport.adr.eq(mpc),
            # map instruction bits to function
            instruction.opcode.eq(micro_runport.dat_r[:6]),
            instruction.wd.eq(micro_runport.dat_r[6:11]),
            instruction.rb.eq(micro_runport.dat_r[11:16]),
            instruction.cb.eq(micro_runport.dat_r[16:17]),
            instruction.ra.eq(micro_runport.dat_r[17:22]),
            instruction.ca.eq(micro_runport.dat_r[22:23]),
            instruction.reserved.eq(micro_runport.dat_r[23:32]),
            instruction.eq(micro_runport.dat_r),
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
                        If(~rf.phase,
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

        self.submodules.ra_const_rom = Curve25519Const()
        self.submodules.rb_const_rom = Curve25519Const()

        ### merge execution path signals with host access paths
        self.comb += [
            self.ra_const_rom.adr.eq(ra_adr),
            self.rb_const_rom.adr.eq(rb_adr),

            If(running,
                rf.ra_adr.eq(Cat(ra_adr, self.window.fields.window)),
                rf.rb_adr.eq(Cat(rb_adr, self.window.fields.window)),
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
        rd_wait_states=2
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

        ### Microcode sequencer. Very simple: it can only run linear sections of microcode. Feature not bug;
        ### constant time operation is a defense against timing attacks.
        engine_go = Signal()
        self.submodules.gosync = BlindTransfer("sys", "eng_clk")
        self.comb += [ self.gosync.i.eq(self.control.fields.go), engine_go.eq(self.gosync.o)]

        self.submodules.seq = seq = ClockDomainsRenamer("eng_clk")(FSM(reset_state="IDLE"))
        mpc_stop = Signal(log2_int(microcode_depth))
        window_latch = Signal(self.window.fields.window.size)
        exec = Signal()  # indicates to execution units to start running
        done = Signal()  # indicates when the given execution units are done (as-muxed from subunits)
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
            ).Elif(instruction.opcode < opcodes["MAX"][0], # check if the opcode is legal before running it
                exec.eq(1),
                NextState("WAIT_DONE"),
            ).Else(
                NextState("ILLEGAL_OPCODE"),
            )
        )
        seq.act("WAIT_DONE",
            If(done,
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
                   NextValue(mpc, rb_dat[:mpc.nbits]),
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

        exec_units = [
            ExecMask(width=rf_width_raw),
            ExecLogic(width=rf_width_raw),
            ExecAddSub(width=rf_width_raw),
            ExecTestReduce(width=rf_width_raw),
        ]
        index = 0
        for unit in exec_units:
            self.submodules += unit
            setattr(self, "done" + str(index), Signal())
            setattr(self, "unit_q" + str(index), Signal(wd_dat.nbits))
            setattr(self, "unit_sel" + str(index), Signal())
            subdecode = Signal()
            for op in unit.opcode_list:
                self.sync.eng_clk += [
                    If(instruction.opcode == opcodes[op][0],
                        subdecode.eq(1)
                    )
                ]
            self.sync.eng_clk += [
                unit.a.eq(ra_dat),
                unit.b.eq(rb_dat),
                unit.start.eq(exec & subdecode),
                unit.opcode.eq(instruction.opcode),
                getattr(self, "done" + str(index)).eq(unit.q_valid),
                getattr(self, "unit_q" + str(index)).eq(unit.q),
                getattr(self, "unit_sel" + str(index)).eq(subdecode),
            ]
            index += 1

        for i in range(index):
            self.comb += [
                If(getattr(self, "done" + str(i)),
                   done.eq(1),
                ),
                If(getattr(self, "unit_sel" + str(i)),
                    wd_dat.eq(getattr(self, "unit_q" + str(i))),
                )
            ]
