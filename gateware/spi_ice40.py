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
    def __init__(self, pads):
        self.intro = ModuleDoc("""Simple soft SPI peripheral module optimized for Betrusted-EC (UP5K arch) use

        Assumes a free-running sclk and csn performs the function of framing bits
        Thus csn must go high between each frame, you cannot hold csn low for burst transfers.
        
        A free-running clock is necessitated because the FIFO primitive used here is synchronous
        to the sysclk domain, not the SPICLK domain. An async FIFO would take too many gates; a sync
        FIFO can use ICESTORM_RAMs efficiently. However, the price is that in order to synchronize from
        spiclk->sysclk, we need some extra trailing spiclk signals to generate the latching pulse from
        spiclk domain to sysclk domain (we run CS_N through a MultiReg synchronizer and then do a rising
        edge detect on that in sysclk). This need is driven in part by the fact that we anticipate that
        SPICLK may run (much) faster than sysclk -- it's constrained to 24MHz in the design but 
        it looks like we could run it much, much faster. 
        
        Capturing the data with no sync overhead would require either a fancier state machine and/or
        async fifos, both which burn gates. Thus the call here is to incur some packet-to-packet overhead on 
        the SPI bus by imposing a sync penalty after each packet received, but on the upside the bus can
        run much faster, and also the implementation is extremely small.     
        """)

        self.cipo = pads.cipo
        self.copi = pads.copi
        self.csn = pads.csn

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
        self.submodules.ev = EventManager()
        self.ev.spi_avail = EventSourcePulse(description="Triggered when Rx FIFO leaves empty state")  # rising edge triggered
        self.ev.spi_event = EventSourceProcess(description="Triggered every time a packet completes")  # falling edge triggered
        self.ev.spi_err = EventSourcePulse(description="Triggered when any error condition occurs") # rising edge
        self.ev.finalize()
        self.comb += self.ev.spi_avail.trigger.eq(self.status.fields.rx_avail)
        self.comb += self.ev.spi_event.trigger.eq(self.status.fields.tip)
        self.comb += self.ev.spi_err.trigger.eq(self.status.fields.rx_over | self.status.fields.rx_under | self.status.fields.tx_over | self.status.fields.tx_under)

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

        # read/rx subsystemx
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
        self.txrx = Signal(16)
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

        rx = Signal(16)
        self.comb += self.cipo.eq(self.txrx[15])
        self.comb += [
            self.rx_fifo.din.eq(rx),
            self.rx_fifo.we.eq(donepulse),
            self.tx_fifo.re.eq(donepulse),
        ]

        tx_data = Signal(16)
        self.comb += [
            If(self.tx_fifo.readable, tx_data.eq(self.tx_fifo.dout)
            ).Else(tx_data.eq(0xDDDD)) # in case of underflow send an error code
        ]
        self.sync.spi_peripheral += [
            # "Sloppy" clock boundary crossing allowed because rx is, in theory, static when donepulse happens
            If(self.csn == 0,
               self.txrx.eq(Cat(self.copi, self.txrx[0:15])),
               rx.eq(Cat(self.copi, self.txrx[0:15])),
            ).Else(
               rx.eq(rx),
               self.txrx.eq(tx_data)
            )
        ]



class SpiPeripheral(Module, AutoCSR, AutoDoc):
    def __init__(self, pads):
        self.intro = ModuleDoc("""Simple soft SPI peripheral module optimized for Betrusted-EC (UP5K arch) use

        Assumes a free-running sclk and csn performs the function of framing bits
        Thus csn must go high between each frame, you cannot hold csn low for burst transfers
        """)

        self.cipo = pads.cipo
        self.copi = pads.copi
        self.csn = pads.csn

        ### clock is not wired up in this module, it's moved up to CRG for implementation-dependent buffering

        self.tx = CSRStorage(16, name="tx", description="""Tx data, to CIPO""")
        self.rx = CSRStatus(16, name="rx", description="""Rx data, from COPI""")
        self.control = CSRStorage(fields=[
            CSRField("intena", description="Enable interrupt on transaction finished"),
            CSRField("clrerr", description="Clear Rx overrun error", pulse=True),
        ])
        self.status = CSRStatus(fields=[
            CSRField("tip", description="Set when transaction is in progress"),
            CSRField("rxfull", description="Set when Rx register has new, valid contents to read"),
            CSRField("rxover", description="Set if Rx register was not read before another transaction was started")
        ])

        self.submodules.ev = EventManager()
        self.ev.spi_int = EventSourceProcess()  # falling edge triggered
        self.ev.finalize()
        self.comb += self.ev.spi_int.trigger.eq(self.control.fields.intena & self.status.fields.tip)

        # Replica CSR into "spi" clock domain
        self.txrx = Signal(16)
        self.tip_r = Signal()
        self.rxfull_r = Signal()
        self.rxover_r = Signal()
        self.csn_r = Signal()

        self.specials += MultiReg(self.tip_r, self.status.fields.tip)
        self.comb += self.tip_r.eq(~self.csn)
        tip_d = Signal()
        donepulse = Signal()
        self.sync += tip_d.eq(self.tip_r)
        self.comb += donepulse.eq(~self.tip_r & tip_d)  # done pulse goes high when tip drops

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
                ),
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

