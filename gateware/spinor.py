from litex.build.xilinx.vivado import XilinxVivadoToolchain
from litex.soc.interconnect.csr_eventmanager import *
from litex.soc.interconnect import wishbone

class SPINOR(Module, AutoCSR):
    def __init__(self, platform, pads, size=2*1024*1024):
        self.size = size
        self.bus  = bus = wishbone.Interface()

        self.reset = Signal()

        self.cfg0 = CSRStorage(size=8)
        self.cfg1 = CSRStorage(size=8)
        self.cfg2 = CSRStorage(size=8)
        self.cfg3 = CSRStorage(size=8)

        self.stat0 = CSRStatus(size=8)
        self.stat1 = CSRStatus(size=8)
        self.stat2 = CSRStatus(size=8)
        self.stat3 = CSRStatus(size=8)

        # # #

        cfg     = Signal(32)
        cfg_we  = Signal(4)
        cfg_out = Signal(32)
        self.comb += [
            cfg.eq(Cat(self.cfg0.storage, self.cfg1.storage, self.cfg2.storage, self.cfg3.storage)),
            cfg_we.eq(Cat(self.cfg0.re, self.cfg1.re, self.cfg2.re, self.cfg3.re)),
            self.stat0.status.eq(cfg_out[0:8]),
            self.stat1.status.eq(cfg_out[8:16]),
            self.stat2.status.eq(cfg_out[16:24]),
            self.stat3.status.eq(cfg_out[24:32]),
        ]

        mosi_pad = TSTriple()
        miso_pad = TSTriple()
        cs_n_pad = TSTriple()
        if isinstance(platform.toolchain, XilinxVivadoToolchain) == False:
            clk_pad  = TSTriple()
        wp_pad   = TSTriple()
        hold_pad = TSTriple()
        self.specials += mosi_pad.get_tristate(pads.mosi)
        self.specials += miso_pad.get_tristate(pads.miso)
        self.specials += cs_n_pad.get_tristate(pads.cs_n)
        if isinstance(platform.toolchain, XilinxVivadoToolchain) == False:
            self.specials += clk_pad.get_tristate(pads.clk)
        self.specials += wp_pad.get_tristate(pads.wp)
        self.specials += hold_pad.get_tristate(pads.hold)

        reset = Signal()
        self.comb += [
            reset.eq(ResetSignal() | self.reset),
            cs_n_pad.oe.eq(~reset),
        ]
        if isinstance(platform.toolchain, XilinxVivadoToolchain) == False:
            self.comb +=  clk_pad.oe.eq(~reset)

        flash_addr = Signal(24)
        # Size/4 because data bus is 32 bits wide, -1 for base 0
        mem_bits = bits_for(int(size/4)-1)
        pad = Signal(2)
        self.comb += flash_addr.eq(Cat(pad, bus.adr[0:mem_bits-1]))

        read_active = Signal()
        spi_ready   = Signal()
        self.sync += [
            bus.ack.eq(0),
            read_active.eq(0),
            If(bus.stb & bus.cyc & ~read_active,
                read_active.eq(1)
            )
            .Elif(read_active & spi_ready,
                bus.ack.eq(1)
            )
        ]

        o_rdata = Signal(32)
        self.comb += bus.dat_r.eq(o_rdata)

        instance_clk = Signal()
        if isinstance(platform.toolchain, XilinxVivadoToolchain):
            self.specials += Instance("STARTUPE2",
                i_CLK       = 0,
                i_GSR       = 0,
                i_GTS       = 0,
                i_KEYCLEARB = 0,
                i_PACK      = 0,
                i_USRCCLKO  = instance_clk,
                i_USRCCLKTS = 0,
                i_USRDONEO  = 1,
                i_USRDONETS = 1
            )
        else:
            self.comb += clk_pad.o.eq(instance_clk)
        self.specials += Instance("spimemio",
            o_flash_io0_oe = mosi_pad.oe,
            o_flash_io1_oe = miso_pad.oe,
            o_flash_io2_oe = wp_pad.oe,
            o_flash_io3_oe = hold_pad.oe,

            o_flash_io0_do = mosi_pad.o,
            o_flash_io1_do = miso_pad.o,
            o_flash_io2_do = wp_pad.o,
            o_flash_io3_do = hold_pad.o,
            o_flash_csb    = cs_n_pad.o,
            o_flash_clk    = instance_clk,

            i_flash_io0_di = mosi_pad.i,
            i_flash_io1_di = miso_pad.i,
            i_flash_io2_di = wp_pad.i,
            i_flash_io3_di = hold_pad.i,

            i_resetn       = ~reset,
            i_clk          = ClockSignal(),

            i_valid        = bus.stb & bus.cyc,
            o_ready        = spi_ready,
            i_addr         = flash_addr,
            o_rdata        = o_rdata,

            i_cfgreg_we    = cfg_we,
            i_cfgreg_di    = cfg,
            o_cfgreg_do    = cfg_out,
        )
        platform.add_source("gateware/spimemio.v")
