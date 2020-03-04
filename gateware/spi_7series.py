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


class SPIMaster(Module, AutoCSR, AutoDoc):
    def __init__(self, pads):
        self.intro = ModuleDoc("""Simple soft SPI master module optimized for Betrusted applications

        Requires a clock domain 'spi', which runs at the speed of the SPI bus.

        Simulation benchmarks 16.5us to transfer 16x16 bit words including setup overhead (sysclk=100MHz, spiclk=25MHz)
        which is about 15Mbps system-level performance, assuming the receiver can keep up.
        """)

        self.miso = pads.miso
        self.mosi = pads.mosi
        self.sclk = pads.sclk
        self.csn  = pads.csn

        # self.comb += self.sclk.eq(~ClockSignal("spi"))  # TODO: add clock gating to save power; note receiver reqs for CS pre-clocks
        # generate a clock, this is Artix-specific
        # mirror the clock with zero delay, and 180 degrees out of phase
        self.specials += Instance("ODDR2",
            p_DDR_ALIGNMENT = "NONE",
            p_INIT          = "0",
            p_SRTYPE        = "SYNC",
            o_Q  = self.sclk,
            i_C0 = ClockSignal("spi"),
            i_C1 = ~ClockSignal("spi"),
            i_D0 = 0,
            i_D1 = 1,
            i_R  = ResetSignal("spi"),
            i_S  = 0,
        )

        self.tx = CSRStorage(16, name="tx", description="""Tx data, for MOSI.""")
        # note to self: we can't auto-initiate on TX write because a 16-bit CSR is split into two 8-bit registers :(
        # thus we need a "go" bit
        self.rx = CSRStatus(16, name="rx", description="""Rx data, from MISO""")
        self.control = CSRStorage(fields=[
            CSRField("clrdone", description="Clear the done field", pulse=True),
            CSRField("go", description="Initiates the SPI transaction", pulse=True),
            CSRField("intena", description="Enable interrupt on transaction finished"),
        ])
        self.status = CSRStatus(fields=[
            CSRField("tip", description="Set when transaction is in progress"),
            CSRField("done", description="Set when transaction is finished, manually cleared"),
        ])

        self.submodules.ev = EventManager()
        self.ev.spi_int    = EventSourceProcess()  # Falling edge triggered
        self.ev.finalize()
        self.comb += self.ev.spi_int.trigger.eq(self.control.fields.intena & self.status.fields.tip)

        # Replicate CSR into "spi" clock domain
        self.tx_r       = Signal(16)
        self.rx_r       = Signal(16)
        self.tip_r      = Signal()
        self.go_r       = Signal()
        self.tx_written = Signal()

        self.specials += MultiReg(self.tip_r, self.status.fields.tip)

        self.submodules.txwrite = PulseStretch() # Stretch the go signal to ensure it's picked up in the SPI domain
        self.comb += self.txwrite.i.eq(self.control.fields.go)
        self.comb += self.tx_written.eq(self.txwrite.o)
        tx_written_d = Signal()
        tx_go        = Signal()
        self.sync.spi += tx_written_d.eq(self.tx_written)
        self.comb += tx_go.eq(~self.tx_written & tx_written_d) # Falling edge of tx_written pulse, guarantees tx.storage is stable

        setdone = Signal()
        self.sync += [
            If(self.control.fields.clrdone,
                self.status.fields.done.eq(0)
            ).Elif(setdone,
                self.status.fields.done.eq(1)
            ).Else(
                self.status.fields.done.eq(self.status.fields.done)
            )
        ]

        self.csn_r = Signal(reset=1)
        self.comb += self.csn.eq(self.csn_r)
        self.comb += self.rx.status.eq(self.rx_r) # Invalid while transaction is in progress
        fsm = FSM(reset_state="IDLE")
        fsm = ClockDomainsRenamer("spi")(fsm)
        self.submodules += fsm
        spicount = Signal(4)
        fsm.act("IDLE",
            If(tx_go,
                NextState("RUN"),
                NextValue(self.tx_r, Cat(0, self.tx.storage[:15])),
                # Stability guaranteed so no synchronizer necessary
                NextValue(spicount, 15),
                NextValue(self.tip_r, 1),
                NextValue(self.csn_r, 0),
                NextValue(self.mosi, self.tx.storage[15]),
                NextValue(self.rx_r, Cat(self.miso, self.rx_r[:15])),
            ).Else(
                NextValue(self.tip_r, 0),
                NextValue(self.csn_r, 1),
            )
        )
        fsm.act("RUN",
            If(spicount > 0,
                NextValue(self.mosi, self.tx_r[15]),
                NextValue(self.tx_r, Cat(0, self.tx_r[:15])),
                NextValue(spicount, spicount - 1),
                NextValue(self.rx_r, Cat(self.miso, self.rx_r[:15])),
            ).Else(
                NextValue(self.csn_r, 1),
                NextValue(self.tip_r, 0),
                NextValue(spicount, 5),
                NextState("WAIT"),
            ),
        )
        fsm.act("WAIT",  # guarantee a minimum CS_N high time after the transaction so slave can capture
            NextValue(spicount, spicount - 1),
            If(spicount == 0,
                setdone.eq(1),
                NextState("IDLE"),
            )
        )


class SPISlave(Module, AutoCSR, AutoDoc):
    def __init__(self, pads):
        self.intro = ModuleDoc("""Simple soft SPI slave module optimized for Betrusted-EC (UP5K arch) use

        Assumes a free-running sclk and csn performs the function of framing bits
        Thus csn must go high between each frame, you cannot hold csn low for burst transfers
        """)

        self.miso = pads.miso
        self.mosi = pads.mosi
        self.sclk = pads.sclk
        self.csn  = pads.csn

        ### FIXME: stand-in for SPI clock input
        self.clock_domains.cd_spislave = ClockDomain()
        self.comb += self.cd_spislave.clk.eq(self.sclk)

        self.tx = CSRStorage(16, name="tx", description="""Tx data, to MISO""")
        self.rx = CSRStatus(16,  name="rx", description="""Rx data, from MOSI""")
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

        self.comb += self.miso.eq(self.txrx[15])
        csn_d = Signal()
        self.sync.spislave += [
            csn_d.eq(self.csn),
            # "Sloppy" clock boundary crossing allowed because "rxfull" is synchronized and CPU should grab data based on that
            If(self.csn == 0,
                self.txrx.eq(Cat(self.mosi, self.txrx[0:15])),
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
