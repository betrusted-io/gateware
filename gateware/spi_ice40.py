from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect.csr_eventmanager import *

from litex.soc.interconnect import wishbone
from migen.genlib.fifo import SyncFIFOBuffered

from migen.genlib.cdc import MultiReg
from migen.genlib.cdc import PulseSynchronizer

class SpiController(Module, AutoCSR, AutoDoc):
    def __init__(self, pads, gpio_cs=False):
        self.intro = ModuleDoc("""Simple soft SPI controller module optimized for Betrusted applications

        Requires a clock domain 'spi', which runs at the speed of the SPI bus. 
        
        Simulation benchmarks 16.5us to transfer 16x16 bit words including setup overhead (sysclk=100MHz, spiclk=25MHz)
        which is about 15Mbps system-level performance, assuming the receiver can keep up.
        
        Note that for the ICE40 controller, timing simulations indicate the clock rate could go higher than 24MHz, although
        there is some question if setup/hold times to the external can be met after all delays are counted.
        
        The gpio_cs parameter when true turns CS into a GPIO to be managed by software; when false,
        it is automatically asserted/de-asserted by the SpiController machine.
        
        gpio_cs is {} in this instance. 
        """.format(gpio_cs))

        self.cipo = pads.cipo
        self.copi = pads.copi
        self.csn = pads.csn

        self.tx = CSRStorage(16, name="tx", description="""Tx data, for COPI""")
        self.rx = CSRStatus(16, name="rx", description="""Rx data, from CIPO""")
        if gpio_cs:
            self.cs = CSRStorage(fields=[
                CSRField("cs", description="Writing `1` to this asserts cs_n, that is, brings it low; writing `0`, brings it high")
            ])
        self.control = CSRStorage(fields=[
            CSRField("go", description="Initiate a SPI cycle by writing a `1`. Does not automatically clear."),
        ])
        self.status = CSRStatus(fields=[
            CSRField("tip", description="Set when transaction is in progress"),
            CSRField("txfull", description="Set when Tx register is full"),
        ])
        self.wifi = CSRStorage(fields=[
            CSRField("reset", description="Write `1` to this register to reset the wifi chip; write `0` to enable normal operation", reset=1),
            CSRField("pa_ena", description="Mapped to PA_ENABLE for wifi (only useful if configured in wifi firmware)"),
            CSRField("wakeup", description="Wakeup the wifi chip"),
        ])
        self.comb += [
            pads.pa_enable.eq(self.wifi.fields.pa_ena),
            pads.wakeup.eq(self.wifi.fields.wakeup),
            pads.res_n.eq(~self.wifi.fields.reset),
        ]

        self.submodules.ev = EventManager()
        # self.ev.spi_int = EventSourceProcess(description="Triggered on conclusion of each transaction")  # falling edge triggered
        self.ev.wirq = EventSourcePulse(description="Interrupt request from wifi chip") # rising edge triggered
        self.ev.finalize()
        # self.comb += self.ev.spi_int.trigger.eq(self.status.fields.tip)
        wirq_in = Signal()
        wirq_r = Signal()
        self.specials += MultiReg(pads.wirq, wirq_in)
        self.sync += wirq_r.eq(wirq_in)
        self.comb += self.ev.wirq.trigger.eq(wirq_in & ~wirq_r)

        tx_swab = Signal(16)
        self.comb += tx_swab.eq(Cat(self.tx.storage[8:], self.tx.storage[:8]))

        # Replica CSR into "spi" clock domain
        self.tx_r = Signal(16)
        self.rx_r = Signal(16)
        self.tip_r = Signal()
        self.txfull_r = Signal()
        self.go_r = Signal()
        self.tx_written = Signal()

        self.specials += MultiReg(self.tip_r, self.status.fields.tip)
        self.specials += MultiReg(self.txfull_r, self.status.fields.txfull)
        self.specials += MultiReg(self.control.fields.go, self.go_r, "spi")
        self.specials += MultiReg(self.tx.re, self.tx_written, "spi")
        # extract rising edge of go -- necessary in case of huge disparity in sysclk-to-spi clock domain
        self.go_d = Signal()
        self.go_edge = Signal()
        self.sync.spi += self.go_d.eq(self.go_r)
        self.comb += self.go_edge.eq(self.go_r & ~self.go_d)

        self.csn_r = Signal(reset=1)
        if gpio_cs:
            self.comb += self.csn.eq(~self.cs.fields.cs)
        else:
            self.comb += self.csn.eq(self.csn_r)
        self.comb += self.rx.status.eq(Cat(self.rx_r[8:],self.rx_r[:8])) ## invalid while transaction is in progress
        fsm = FSM(reset_state="IDLE")
        fsm = ClockDomainsRenamer("spi")(fsm)
        self.submodules += fsm
        spicount = Signal(4)
        spiclk_run = Signal()
        fsm.act("IDLE",
                If(self.go_edge,
                   NextState("RUN"),
                   NextValue(self.tx_r, Cat(0, tx_swab[:15])),
                   # stability guaranteed so no synchronizer necessary
                   NextValue(spicount, 15),
                   NextValue(self.txfull_r, 0),
                   NextValue(self.tip_r, 1),
                   NextValue(self.csn_r, 0),
                   NextValue(self.copi, tx_swab[15]),
                   NextValue(self.rx_r, Cat(self.cipo, self.rx_r[:15])),
                   NextValue(spiclk_run, 1),
                ).Else(
                    NextValue(spiclk_run, 0),
                    NextValue(self.tip_r, 0),
                    NextValue(self.csn_r, 1),
                    If(self.tx_written,
                       NextValue(self.txfull_r, 1),
                    ),
                ),
        )
        fsm.act("RUN",
                If(spicount > 0,
                   NextValue(spiclk_run, 1),
                   NextValue(self.copi, self.tx_r[15]),
                   NextValue(self.tx_r, Cat(0, self.tx_r[:15])),
                   NextValue(spicount, spicount - 1),
                   NextValue(self.rx_r, Cat(self.cipo, self.rx_r[:15])),
                ).Else(
                    NextValue(spiclk_run, 0),
                    NextValue(self.csn_r, 1),
                    NextValue(self.tip_r, 0),
                    NextState("IDLE"),
                ),
        )
        # gate the spi clock so it only runs during a SPI transaction -- requirement of the wf200 block
        self.specials += [
            Instance("SB_IO",
                p_PIN_TYPE=0b100000,   # define a DDR output type
                p_IO_STANDARD="SB_LVCMOS",
                p_PULLUP=0,
                p_NEG_TRIGGER=0,
                io_PACKAGE_PIN=pads.sclk,
                i_LATCH_INPUT_VALUE=0,
                i_CLOCK_ENABLE=1,
                i_INPUT_CLK=0,
                i_OUTPUT_CLK=ClockSignal("spi"),
                i_OUTPUT_ENABLE=1,
                i_D_OUT_0=0,           # rising clock edge
                i_D_OUT_1=spiclk_run,  # falling clock edge
            )
        ]


class StickyBit(Module):
    def __init__(self):
        self.flag = Signal()
        self.bit = Signal()
        self.clear = Signal()

        self.sync += [
            If(self.clear,
                self.bit.eq(0)
            ).Else(
                If(self.flag,
                    self.bit.eq(1)
                ).Else(
                    self.bit.eq(self.bit)
                )
            )
        ]

class SpiFifoPeripheral(Module, AutoCSR, AutoDoc):
    def __init__(self, pads, pipeline_cipo=False):
        self.intro = ModuleDoc("""SPI peripheral module optimized for Betrusted-EC (UP5K arch) use

The `pipeline_cipo` argument configures the interface to put a pipeline register
on the output of CIPO. Setting this to `False` gives you a standards-compliant SPI Mode 1
interface, but it should run at around 12-15MHz. Also I'm unaware of a method to convince
nextpnr to fix asynchronous delays from fabric to output, and therefore the total delay
from the fabric registers to the output seems to vary quite widely.

Setting `pipeline_cipo` to `True` shifts the CIPO output late by a half clock cycle by
resampling the CIPO line using an SB_IO register, but the clock-to-q timing is better 
(about 14ns versus 21ns). Also, because the origin of the data is from an SB_IO register,
the timing should be very consistent regardless of nextpnr's internal machinations. 
The downside is that the controller needs to sample an extra bit after the SCLK stops.
This isn't a problem for an FPGA design (and the matching spi_7series.SPIController IP
block has a `pipeline_cipo` argument to match this block), but it won't work with most
off-the-shelf microcontrollers. However, by using `pipeline_cipo`, you can increase
the clock rate of the SPI bus to 20MHz with margin to spare.

This module was built with `pipeline_cipo` set to {} 
        """.format(pipeline_cipo))

        self.protocol = ModuleDoc("""Enhanced Protocol for COM
The large performance differential between the SoC and the EC in Precursor/Betrusted means that
it's very easy for the EC to be overwhelmed with requests from the SoC. 

We extend the SPI protocol with a "hold" signal to inform the SoC that read data is not yet ready.

This, in essence, is a matter of tying the Tx FIFO's "read empty" signal to the hold pin. 
The EC signals readiness to accept new commands by writing a single word to the Tx FIFO.
Upon receipt of the word, the FIFO will empty, raising the "read empty" signal and producing a
"hold" condition until the next data is made available for reading.
        """)

        self.copi = pads.copi
        self.csn = pads.csn
        self.hold = Signal()
        self.oe = Signal()  # used to disable driving signals to the target device when it is powered down
        self.hold_ts = TSTriple(1)
        self.specials += [
            self.hold_ts.get_tristate(pads.hold)
        ]
        self.comb += [
            self.hold_ts.oe.eq(self.oe),
            self.hold_ts.o.eq(self.hold),
        ]

        ### clock is not wired up in this module, it's moved up to CRG for implementation-dependent buffering

        self.control = CSRStorage(fields=[
            CSRField("clrerr", description="Clear FIFO error flags", pulse=True),
            CSRField("host_int", description="0->1 raises an interrupt to the COM host"), # rising edge triggered on other side
            CSRField("reset", description="Reset the fifos", pulse=True),
        ])
        self.comb += pads.irq.eq(self.control.fields.host_int)

        self.status = CSRStatus(fields=[
            CSRField("tip", description="Set when transaction is in progress"),
            CSRField("rx_avail", description="Set when Rx FIFO has new, valid contents to read"),
            CSRField("rx_over", description="Set if Rx FIFO has overflowed"),
            CSRField("rx_under", description="Set if Rx FIFO underflows"),
            CSRField("rx_level", size=12, description="Level of Rx FIFO"),
            CSRField("tx_avail", description="Set when Tx FIFO has space for new content"),
            CSRField("tx_empty", description="Set when Tx FIFO is empty"),
            CSRField("tx_level", size=12, description="Level of Tx FIFO"),
            CSRField("tx_over", description="Set when Tx FIFO overflows"),
            CSRField("tx_under", description = "Set when Tx FIFO underflows"),
        ])
        self.bus = bus = wishbone.Interface()
        rd_ack = Signal()
        wr_ack = Signal()
        self.comb +=[
            If(bus.we,
               bus.ack.eq(wr_ack),
            ).Else(
                bus.ack.eq(rd_ack),
            )
        ]

        # read/rx subsystem
        self.submodules.rx_fifo = rx_fifo = ResetInserter(["sys"])(SyncFIFOBuffered(16, 1280)) # should infer SB_RAM256x16's. 2560 depth > 2312 bytes = wifi MTU
        self.comb += self.rx_fifo.reset_sys.eq(self.control.fields.reset | ResetSignal())
        self.submodules.rx_under = StickyBit()
        self.comb += [
            self.status.fields.rx_level.eq(rx_fifo.level),
            self.status.fields.rx_avail.eq(rx_fifo.readable),
            self.rx_under.clear.eq(self.control.fields.clrerr),
            self.status.fields.rx_under.eq(self.rx_under.bit),
        ]


        bus_read = Signal()
        bus_read_d = Signal()
        rd_ack_pipe = Signal()
        self.comb += bus_read.eq(bus.cyc & bus.stb & ~bus.we & (bus.cti == 0))
        self.sync += [  # This is the bus responder -- only works for uncached memory regions
            bus_read_d.eq(bus_read),
            If(bus_read & ~bus_read_d,  # One response, one cycle
                rd_ack_pipe.eq(1),
                If(rx_fifo.readable,
                    bus.dat_r.eq(rx_fifo.dout),
                    rx_fifo.re.eq(1),
                    self.rx_under.flag.eq(0),
                ).Else(
                    # Don't stall the bus indefinitely if we try to read from an empty fifo...just
                    # return garbage
                    bus.dat_r.eq(0xdeadbeef),
                    rx_fifo.re.eq(0),
                    self.rx_under.flag.eq(1),
                )
               ).Else(
                rx_fifo.re.eq(0),
                rd_ack_pipe.eq(0),
                self.rx_under.flag.eq(0),
            ),
            rd_ack.eq(rd_ack_pipe),
        ]

        # tx/write spiperipheral
        self.submodules.tx_fifo = tx_fifo = ResetInserter(["sys"])(SyncFIFOBuffered(16, 1280))
        self.comb += self.tx_fifo.reset_sys.eq(self.control.fields.reset | ResetSignal())
        self.submodules.tx_over = StickyBit()
        self.comb += [
            self.tx_over.clear.eq(self.control.fields.clrerr),
            self.status.fields.tx_over.eq(self.tx_over.bit),
            self.status.fields.tx_empty.eq(~tx_fifo.readable),
            self.status.fields.tx_avail.eq(tx_fifo.writable),
            self.status.fields.tx_level.eq(tx_fifo.level),
        ]

        write_gate = Signal()
        self.sync += [
            If(bus.cyc & bus.stb & bus.we & ~bus.ack,
                If(tx_fifo.writable,
                    tx_fifo.din.eq(bus.dat_w),
                    tx_fifo.we.eq(~write_gate), # ensure write is just single cycle
                    wr_ack.eq(1),
                    write_gate.eq(1),
                ).Else(
                    self.tx_over.flag.eq(1),
                    tx_fifo.we.eq(0),
                    wr_ack.eq(0),
                    write_gate.eq(0),
                )
            ).Else(
                write_gate.eq(0),
                tx_fifo.we.eq(0),
                wr_ack.eq(0),
            )
        ]

        # Replica CSR into "spi" clock domain
        self.tx = Signal(16, reset_less=True)
        self.tip_r = Signal()
        self.rxfull_r = Signal()
        self.rxover_r = Signal()
        self.csn_r = Signal()

        self.specials += MultiReg(~self.csn, self.tip_r)
        self.comb += self.status.fields.tip.eq(self.tip_r)
        tip_d = Signal()
        donepulse = Signal()
        self.sync += tip_d.eq(self.tip_r)
        self.comb += donepulse.eq(~self.tip_r & tip_d)  # done pulse goes high when tip drops

        self.submodules.rx_over = StickyBit()
        self.comb += [
            self.status.fields.rx_over.eq(self.rx_over.bit),
            self.rx_over.clear.eq(self.control.fields.clrerr),
            self.rx_over.flag.eq(~self.rx_fifo.writable & donepulse),
        ]
        self.submodules.tx_under = StickyBit()
        self.comb += [
            self.status.fields.tx_under.eq(self.tx_under.bit),
            self.tx_under.clear.eq(self.control.fields.clrerr),
            self.tx_under.flag.eq(~self.tx_fifo.readable & donepulse),
        ]

        rx = Signal(16, reset_less=True)
        self.comb += [
            self.rx_fifo.din.eq(rx), # assume CS is high for quite a while before donepulse triggers the write, this stabilizes the rx din
            self.rx_fifo.we.eq(donepulse),
            self.tx_fifo.re.eq(donepulse),
        ]

        # form the SPI-clock domain shift registers.
        self.comb += [
            self.hold.eq(~self.tx_fifo.readable),
        ]
        # input register on copi. Falling edge sampling.
        self.specials += Instance("SB_IO",
            p_IO_STANDARD = "SB_LVCMOS",
            p_PIN_TYPE = 0b0000_00,
            p_NEG_TRIGGER = 1,
            io_PACKAGE_PIN = self.copi,
            i_CLOCK_ENABLE = 1,
            i_INPUT_CLK = ClockSignal("sclk"),
            i_OUTPUT_ENABLE = 0,
            o_D_IN_0 = rx[0], # D_IN_0 is falling edge when NEG_TRIGGER is 1
        )
        for bit in range(15):
            self.specials += Instance("SB_DFFN",
                i_C=ClockSignal("sclk"),
                i_D=rx[bit],
                o_Q=rx[bit+1],
            )

        if pipeline_cipo:
            # output register on cipo. produces new result on falling-edge
            # this improves Tc-q timing, and more importantly, keeps it consistent between builds
            self.specials += Instance("SB_IO",
                p_IO_STANDARD = "SB_LVCMOS",
                p_PIN_TYPE = 0b1001_00,
                p_NEG_TRIGGER = 1, # this causes the output to update on the falling edge
                io_PACKAGE_PIN = pads.cipo,
                i_CLOCK_ENABLE = 1,
                i_OUTPUT_CLK = ClockSignal("sclk"),
                i_OUTPUT_ENABLE = self.oe,
                i_D_OUT_0 = self.tx[15],
            )
            # tx is updated on the rising edge, but the SB_IO primitive pushes the new data out on the falling edge
            # so the total time we have to move the data from this shift register to the output register is a half
            # clock cycle.
            spi_load = Signal()
            self.sync.sclk += [
                If(spi_load,
                    If(self.tx_fifo.readable,
                        self.tx.eq(self.tx_fifo.dout),
                    ).Else(
                        self.tx.eq(0xDDDD), # in case of underflow send error code
                    ),
                ).Else(
                    self.tx.eq(Cat(1, self.tx[0:15])) # if we overshift, we eventually get all 1's
                )
            ]
            self.specials += Instance("SB_DFFS",
                i_C=ClockSignal("sclk"),
                i_D=0,
                o_Q=spi_load,
                i_S=self.csn,
            )
        else:
            # this path gets you a "standards compliant" SPI interface, but it's slower and the timing is less reliable
            self.cipo_ts = TSTriple(1)
            self.specials += [
                self.cipo_ts.get_tristate(pads.cipo)
            ]
            self.comb += [
                self.cipo_ts.oe.eq(self.oe),
                self.cipo_ts.o.eq(self.tx[15]),
            ]

            tx_staged=Signal(16)
            for bit in range(16):
                if bit != 0:
                    self.specials += Instance("SB_DFFS",
                        i_C=ClockSignal("sclk"),
                        i_D=self.tx[bit - 1],
                        o_Q=self.tx[bit],
                        i_S=tx_staged[bit] & self.csn,
                    )
                else:
                    self.specials += Instance("SB_DFFS",
                        i_C=ClockSignal("sclk"),
                        i_D=0,
                        o_Q=self.tx[bit],
                        i_S=tx_staged[bit] & self.csn,
                    )
            self.comb += [
                If(self.tx_fifo.readable,
                    tx_staged.eq(self.tx_fifo.dout),
                ).Else(
                    tx_staged.eq(0xDDDD),
                )
            ]

