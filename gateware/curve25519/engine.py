from migen import *
from migen.genlib.cdc import BlindTransfer

from litex.soc.interconnect.csr import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect import wishbone
from litex.soc.interconnect.csr_eventmanager import *

from enum import IntEnum

class Opcode(IntEnum):
    UNDEFINED = -1  # used for initializing records
    PASS_A = 0
    PASS_B = 1
    MAX_OP = 2  # all encodings must be less than this


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
                rf_adr.eq(self.ra_a),
            ).Else(
                rf_adr.eq(self.rb_a),
            )
        ]
        rf_dat = Signal(width)
        self.sync.rf_clk += [
            If(~phase,
                self.rda_dat.eq(rf_dat),
                self.rdb_dat.eq(self.rdb_dat),
            ).Else(
                self.rda_dat.eq(self.rda_dat),
                self.rdb_dat.eq(rf_dat),
            ),
            If(eng_sync,
                phase.eq(0),
            ).Else(
                phase.eq(~phase),
            )
        ]

        for word in range(int(256/64)):
            self.specials += Instance("RAMB36E1", name="RF_RAMB" + str(word),
                p_WRITE_MODE_A = "READ_FIRST",
                p_RAM_MODE = "SDP",
                p_WRITE_WIDTH_A = "72",  # 72 bit width only available in SDP mode
                p_WRITE_WIDTH_B = "0", # WB not available in SDP
                p_READ_WIDTH_A = "72",
                p_READ_WIDTH_B = "0", # RB not available in SDP
                p_DOA_REG = "0", p_DOB_REG = "0",
                p_RDADDR_COLLISION_HWCONFIG = "DELAYED_WRITE",  # "PERFORMANCE" can be used at expense of collision problems
                i_CLKARDCLK = ClockSignal("rf_clk"),
                i_CLKBWRCLK = ClockSignal("rf_clk"),
                i_ADDRARDADDR = rf_adr,
                i_ADDRBWRADDR = self.wd_adr,
                i_DIADI = self.wd_dat[word*64 : word*64 + 32],
                i_DIBDI = self.wd_dat[word*64 + 32 : word*64 + 64],
                o_DOADO = rf_dat[word*64 : word*64 + 32],
                o_DOBDO = rf_dat[word*64 + 32 : word*64 + 64],
                i_ENARDEN = 1,
                i_ENBWREN = phase & self.we,
                i_RSTRAMARSTRAM = eng_sync,
                i_WEBWE = self.wd_bwe[word*8 : word*8 + 8],
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
        self.intro = ModuleDoc("""
This module encodes the constants that can be substituted for any register
value. Up to 32 constants can be encoded in this ROM.
        """)
        self.adr = Signal(5)
        self.const = Signal(256)
        self.comb += [
            If(self.adr == 1, # A+2/4 constant
                self.const.eq(121665),
            ).Else(
                self.const.eq(0),
            )
        ]

# superclass template for execution units
class ExecUnit(Module):
    def __init__(self, width=256, opcode=Opcode.UNDEFINED):
        # basic API for an exec unit:
        # `a` and `b` are the inputs. `q` is the output.
        # `start` is a single-clock signal which indicates processing should start
        # `q_valid` is a single cycle pulse that indicates that the `q` result is valid
        self.a = Signal(width)
        self.b = Signal(width)
        self.q = Signal(width)
        self.start = Signal()
        self.q_valid = Signal()

        self.opcode = opcode

# execution units
class ExecPassThroughA(ExecUnit):
    def __init__(self, width=256):
        ExecUnit.__init__(self, width, Opcode.PASS_A)

        self.sync.eng_clk += [
            self.q.eq(self.a),
            self.q_valid.eq(self.start),
        ]

class ExecPassThroughB(ExecUnit):
    def __init__(self, width=256):
        ExecUnit.__init__(self, width, Opcode.PASS_B)

        self.sync.eng_clk += [
            self.q.eq(self.b),
            self.q_valid.eq(self.start),
        ]

class Engine(Module, AutoCSR, AutoDoc):
    def __init__(self, platform):
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
            ("opcode", 6), # opcode to be executed
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
        micro_wrport = microcode.get_port(write_capable=True)
        micro_rdport = microcode.get_port()
        micro_runport = microcode.get_port()
        self.specials += micro_wrport
        self.specials += micro_rdport
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
        wadr = Signal(log2_int(rf_depth_raw))
        wmask = Signal(4)
        wdata_we = Signal()
        rdata_re = Signal()
        rdata_ack = Signal()
        rdata_req = Signal()
        radr = Signal(log2_int(rf_depth_raw))

        micro_rdack = Signal()
        self.sync += [
            If( (bus.adr & ((0xFFFF_C000) >> 2)) == (0x1_0000 >> 2),
                # fully decode register file address to avoid aliasing
                If(bus.cyc & bus.stb & bus.we & ~bus.ack,
                    If(~running,
                        wdata.eq(bus.dat_w),
                        wadr.eq(bus.adr[:wadr.nbits]),
                        wmask.eq(bus.sel),
                        wdata_we.eq(1),
                        bus.ack.eq(1),
                    ).Else(
                        wdata_we.eq(0),
                        bus.ack.eq(0),
                    )
                   ).Else(
                    bus.ack.eq(0),
                    wdata_we.eq(0),
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
                )
            ).Elif( (bus.adr & ((0xFFFF_F000) >> 2)) == 0x0,
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

                    If(micro_rdack, # 1 cycle delay for read to occur
                        bus.ack.eq(1),
                    ).Else(
                        bus.ack.eq(0),
                        micro_rdack.eq(1),
                    )
                ).Else(
                    micro_wrport.we.eq(0),
                    micro_rdack.eq(0),
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
                rf.ra_adr.eq(Cat(ra_adr, self.window.fileds.window)),
                rf.rb_adr.eq(Cat(rb_adr, self.window.fields.window)),
                rf.wd_adr.eq(Cat(wd_adr, self.window.fields.window)),
                rf.wd_dat.eq(wd_dat),
                rf.wd_bwe.eq(0xFFFF_FFFF), # enable all bytes
                rf.we.eq(rf_write),
            ).Else(
                rf.ra_adr.eq(radr),
                rf.wd_adr.eq(wadr),
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
        # simple machine to wait 4 RF clock cycles for data to propagate out of the register file and back to the host
        bus_rd_wait = Signal(max=4)
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
                bus_rd_wait.eq(4),
            )
        ]

        ### Microcode sequencer. Very simple: it can only run linear sections of microcode. Feature not bug;
        ### constant time operation is a defense against timing attacks.
        engine_go = Signal()
        self.submodules.gosync = BlindTransfer("sys", "eng_clk")
        self.comb += [ self.gosync.i.eq(self.control.go), engine_go.eq(self.gosync.o)]

        self.submodules.seq = seq = ClockDomainsRenamer("eng_clk")(FSM(reset_state="IDLE"))
        mpc_stop = Signal(log2_int(microcode_depth))
        window_latch = Signal(self.window.fields.window.n_bits)
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
            If(instruction.opcode < Opcode.MAX_OP, # check if the opcode is legal before running it
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

        exec_units = [ExecPassThroughA(width=rf_width_raw), ExecPassThroughB(width=rf_width_raw)]
        for unit in exec_units:
            self.submodules += unit
            self.comb += [
                unit.a.eq(ra_dat),
                unit.b.eq(rb_dat),
                unit.start.eq(exec & instruction.opcode == unit.opcode),
                done.eq(done | unit.q_valid),
                wd_dat.eq( (unit.q & (instruction.opcode == unit.opcode)) | wd_dat),
            ]

