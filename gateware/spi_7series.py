from os import pipe
from migen.genlib.cdc import MultiReg
from migen.genlib.cdc import BlindTransfer

from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect.csr_eventmanager import *


class PulseStretch(Module):
    """Simple module to stretch a pulse out by n cycles to cross into the slower SPI domain"""
    def __init__(self, n=10):
        self.i = Signal()
        self.o = Signal()

        # # #

        i_d   = Signal()
        count = Signal(bits_for(n))

        self.sync += [
            i_d.eq(self.i),
            # Reload count on rising edge
            If(self.i & ~i_d,
                count.eq(n)
            ).Elif(count != 0,
                count.eq(count - 1)
            ),
        ]
        # Set output while count != 0
        self.comb += self.o.eq(count != 0)


class SPIController(Module, AutoCSR, AutoDoc):
    def __init__(self, pads, pipeline_cipo=False):
        self.intro = ModuleDoc("""Simple soft SPI Controller module optimized for Betrusted applications

        Requires a clock domain 'spi', which runs at the speed of the SPI bus.

        Simulation benchmarks 16.5us to transfer 16x16 bit words including setup overhead (sysclk=100MHz, spiclk=25MHz)
        which is about 15Mbps system-level performance, assuming the receiver can keep up.

        A receiver running at 18MHz, with a spiclk of 20MHz, shows about 55us for 16x16bit words, or about 4.5Mbps performance.

        The `pipeline_cipo` argument, when set, introduces an extra pipeline stage on the return path from the peripheral.
        This can help improve the timing closure when talking to slow devices, such as a UP5K. However, it makes the
        bus not standards-compliant. Thus, by default this is set to False.

        For this build, `pipeline_cipo` has been set to {}
        """.format(pipeline_cipo))

        self.cipo = pads.cipo
        self.copi = pads.copi
        self.sclk = pads.sclk
        self.csn  = pads.csn
        self.hold = pads.hold
        hold = Signal()
        self.specials += MultiReg(self.hold, hold)

        self.tx = CSRStorage(16, name="tx", description="""Tx data, for COPI. Note: 32-bit CSRs are required for this block to work!""")
        self.rx = CSRStatus(16, name="rx", description="""Rx data, from CIPO""")
        self.control = CSRStorage(fields=[
            CSRField("intena", description="Enable interrupt on transaction finished"),
            CSRField("autohold", description="Disallow transmission start if hold if asserted"),
        ])
        self.status = CSRStatus(fields=[
            CSRField("tip", description="Set when transaction is in progress"),
            CSRField("hold", description="Set when peripheral asserts hold"),
        ])
        self.comb += self.status.fields.hold.eq(hold)

        self.submodules.ev = EventManager()
        self.ev.spi_int    = EventSourceProcess()  # Falling edge triggered
        self.ev.spi_hold   = EventSourceProcess()  # triggers when hold drops
        self.ev.finalize()
        self.comb += self.ev.spi_int.trigger.eq(self.control.fields.intena & self.status.fields.tip)
        self.comb += self.ev.spi_hold.trigger.eq(hold)

        # Replicate CSR into "spi" clock domain
        self.tx_r       = Signal(16)
        self.rx_r       = Signal(16)
        self.go_r       = Signal()
        self.tx_written = Signal()

        setdone = Signal()
        done_r      = Signal()
        self.specials += MultiReg(setdone, done_r)
        self.sync += [
            If(self.tx.re,
                self.status.fields.tip.eq(1)
            ).Elif(done_r,
                self.status.fields.tip.eq(0)
            ).Else(
                self.status.fields.tip.eq(self.status.fields.tip)
            )
        ]

        self.submodules.txwrite = PulseStretch() # Stretch the go signal to ensure it's picked up in the SPI domain
        self.comb += self.txwrite.i.eq(self.tx.re)
        self.comb += self.tx_written.eq(self.txwrite.o)
        tx_written_d = Signal()
        tx_go        = Signal()
        self.sync.spi += tx_written_d.eq(self.tx_written)
        self.comb += tx_go.eq(~self.tx_written & tx_written_d) # Falling edge of tx_written pulse, guarantees tx.storage is stable

        self.csn_r = Signal(reset=1)
        self.comb += self.csn.eq(self.csn_r)
        fsm = FSM(reset_state="IDLE")
        fsm = ClockDomainsRenamer("spi")(fsm)
        self.submodules += fsm
        spicount = Signal(4)
        # I/ODDR signals
        clk_run = Signal()
        cipo_sampled = Signal()
        fsm.act("IDLE",
            NextValue(clk_run, 0),
            If(tx_go & ~(self.control.fields.autohold & hold),
                NextState("PRE_ASSERT"),
                NextValue(self.tx_r, self.tx.storage),
                # Stability guaranteed so no synchronizer necessary
                NextValue(spicount, 15),
                NextValue(self.csn_r, 0),
            ).Else(
                NextValue(self.csn_r, 1),
            )
        )
        fsm.act("PRE_ASSERT", # assert CS_N for a cycle before sending a clock, so that the receiver can bring its counter out of async clear
                NextState("RUN"),
                NextValue(clk_run, 1),
        )
        if pipeline_cipo:
            turnaround_delay = 2
        else:
            turnaround_delay = 3
        fsm.act("RUN",
            NextValue(self.rx_r, Cat(cipo_sampled, self.rx_r[:15])),
            NextValue(self.tx_r, Cat(0, self.tx_r[:15])),
            If(spicount > 0,
                NextValue(clk_run, 1),
                NextValue(spicount, spicount - 1),
            ).Else(
                NextValue(clk_run, 0),
                NextValue(spicount, turnaround_delay),
                NextState("POST_ASSERT"),
            ),
        )
        if pipeline_cipo:
            fsm.act("POST_ASSERT",
                # one cycle extra at the end, to grab the falling-edge asserted receive data
                NextValue(self.rx_r, Cat(cipo_sampled, self.rx_r[:15])),
                NextValue(self.csn_r, 1),
                NextState("SAMPLE"),
            )
            fsm.act("SAMPLE",
                # another extra cycle to grab pipelined data
                NextValue(self.rx_r, Cat(cipo_sampled, self.rx_r[:15])),
                NextState("WAIT"),
            )
        else:
            fsm.act("POST_ASSERT",
                # one cycle extra at the end, to grab the falling-edge asserted receive data
                NextValue(self.rx_r, Cat(cipo_sampled, self.rx_r[:15])),
                NextValue(self.csn_r, 1),
                NextState("WAIT"),
            )
        fsm.act("WAIT",  # guarantee a minimum CS_N high time after the transaction so Peripheral can capture. Has to perculate through multiregs, 2 cycles/ea + sync FIFO latch.
            NextValue(self.rx.status, self.rx_r),
            NextValue(spicount, spicount - 1),
            If(spicount == 0,
                setdone.eq(1),
                NextState("IDLE"),
            )
        )

        # generate a clock, this is Artix-specific
        # mirror the clock with zero delay
        self.specials += Instance("ODDR",
            p_DDR_CLK_EDGE = "SAME_EDGE",
            p_INIT          = 0,
            p_SRTYPE        = "SYNC",
            o_Q  = self.sclk,
            i_C = ClockSignal("spi"),
            i_CE = 1,
            i_D1 = clk_run,
            i_D2 = 0,
            i_R  = ResetSignal("spi"),
            i_S  = 0,
        )
        self.specials += Instance("ODDR",
            p_DDR_CLK_EDGE = "SAME_EDGE",
            o_Q  = self.copi,
            i_C = ClockSignal("spi"),
            i_CE = 1,
            i_D1 = self.tx_r[15],
            i_D2 = self.tx_r[15],
        )
        self.specials += Instance("IDDR",
            p_DDR_CLK_EDGE = "OPPOSITE_EDGE",
            p_SRTYPE        = "SYNC",
            i_C = ClockSignal("spi"),
            i_CE = 1,
            i_D = self.cipo,
            o_Q1 = cipo_sampled,
            i_R  = ResetSignal("spi"),
            i_S  = 0,
        )


class SPIPeripheral(Module, AutoCSR, AutoDoc):
    def __init__(self, pads):
        self.intro = ModuleDoc("""Simple soft SPI Peripheral module optimized for Betrusted-EC (UP5K arch) use

        Assumes a free-running sclk and csn performs the function of framing bits
        Thus csn must go high between each frame, you cannot hold csn low for burst transfers
        """)

        self.cipo = pads.cipo
        self.copi = pads.copi
        self.sclk = pads.sclk
        self.csn  = pads.csn

        ### FIXME: stand-in for SPI clock input
        self.clock_domains.cd_spi_peripheral = ClockDomain()
        self.comb += self.cd_spi_peripheral.clk.eq(self.sclk)

        self.tx = CSRStorage(16, name="tx", description="""Tx data, to CIPO""")
        self.rx = CSRStatus(16,  name="rx", description="""Rx data, from COPI""")
        self.control = CSRStorage(fields=[
            CSRField("intena", description="Enable interrupt on transaction finished"),
            CSRField("clrerr", description="Clear Rx overrun error", pulse=True),
        ])
        self.status = CSRStatus(fields=[
            CSRField("tip",    description="Set when transaction is in progress"),
            CSRField("rxfull", description="Set when Rx register has new, valid contents to read"),
            CSRField("rxover", description="Set if Rx register was not read before another transaction was started")
        ])

        self.submodules.ev = EventManager()
        self.ev.spi_int    = EventSourceProcess()  # Falling edge triggered
        self.ev.finalize()
        self.comb += self.ev.spi_int.trigger.eq(self.control.fields.intena & self.status.fields.tip)

        # Replicate CSR into "spi" clock domain
        self.txrx     = Signal(16)
        self.tip_r    = Signal()
        self.rxfull_r = Signal()
        self.rxover_r = Signal()
        self.csn_r    = Signal()

        self.specials += MultiReg(self.tip_r, self.status.fields.tip)
        self.comb += self.tip_r.eq(~self.csn)
        tip_d     = Signal()
        donepulse = Signal()
        self.sync += tip_d.eq(self.tip_r)
        self.comb += donepulse.eq(~self.tip_r & tip_d)  # Done pulse goes high when tip drops

        self.comb += self.status.fields.rxfull.eq(self.rxfull_r)
        self.comb += self.status.fields.rxover.eq(self.rxover_r)

        self.sync += [
            If(self.rx.we,
                self.rxfull_r.eq(0),
            ).Else(
                If(donepulse,
                    self.rxfull_r.eq(1)
                ).Else(
                    self.rxfull_r.eq(self.rxfull_r),
                ),

                If(self.tip_r & self.rxfull_r,
                    self.rxover_r.eq(1)
                ).Elif(self.control.fields.clrerr,
                    self.rxover_r.eq(0)
                ).Else(
                    self.rxover_r.eq(self.rxover_r)
                )
            )
        ]

        self.comb += self.cipo.eq(self.txrx[15])
        csn_d = Signal()
        self.sync.spi_peripheral += [
            csn_d.eq(self.csn),
            # "Sloppy" clock boundary crossing allowed because "rxfull" is synchronized and CPU should grab data based on that
            If(self.csn == 0,
                self.txrx.eq(Cat(self.copi, self.txrx[0:15])),
                self.rx.status.eq(self.rx.status),
            ).Else(
                If(self.csn & ~csn_d,
                    self.rx.status.eq(self.txrx),
                ).Else(
                    self.rx.status.eq(self.rx.status)
                ),
                self.txrx.eq(self.tx.storage)
            )
        ]
