from migen import *
from migen.genlib.fsm import FSM, NextState

from litex.soc.interconnect import wishbone
from litex.soc.interconnect.csr import *


class SRAM32(Module, AutoCSR):
    def __init__(self, pads, rd_timing, wr_timing, page_rd_timing):
        self.bus = wishbone.Interface()

        config_status = self.config_status = CSRStatus(fields=[
            CSRField("mode", size=32, description="The current configuration mode of the SRAM")
        ])
        read_config = self.read_config = CSRStorage(fields=[
            CSRField("trigger", size=1, description="Writing to this bit triggers the SRAM mode status read update", pulse=True)
        ])

        # # #

        # min 150us, at 100MHz this is 15,000 cycles
        sram_zz = Signal(reset=1)
        load_config = Signal()
        self.sram_ready = Signal()
        reset_counter = Signal(14, reset=50) # Cut short because 150us > FPGA config time
        self.sync += [
            If(reset_counter != 0,
                reset_counter.eq(reset_counter - 1),
                self.sram_ready.eq(0)
            ).Else(
                self.sram_ready.eq(1)
            ),

            If(reset_counter == 1,
               load_config.eq(1)
            ).Else(
                load_config.eq(0)
            )
        ]

        data = TSTriple(32)

        self.specials += data.get_tristate(pads.d)

        store           = Signal()
        load            = Signal()
        config          = Signal()
        config_override = Signal()
        config_ce_n     = Signal(reset=1)
        config_we_n     = Signal(reset=1)
        config_oe_n     = Signal(reset=1)

        comb_oe_n   = Signal()
        comb_we_n   = Signal()
        comb_zz_n   = Signal()
        comb_ce_n   = Signal()
        comb_dm_n   = Signal(4)
        comb_adr    = Signal(22)
        comb_data_o = Signal(32)

        comb_oe_n.reset, comb_we_n.reset = 1, 1
        comb_zz_n.reset, comb_ce_n.reset = 1, 1
        self.comb += [
            comb_oe_n.eq(1),
            comb_we_n.eq(1),
            comb_zz_n.eq(sram_zz),
            comb_ce_n.eq(1),

            If(config_override,
               comb_oe_n.eq(config_oe_n),
               comb_we_n.eq(config_we_n),
               comb_ce_n.eq(config_ce_n),
               comb_zz_n.eq(1),
               If(config_ce_n,  # DM should track CE_n
                  comb_dm_n.eq(0xf),
                ).Else(
                   comb_dm_n.eq(0x0)
               ),
               comb_adr.eq(0x3fffff),
               comb_data_o.eq(0),
            ).Else(
                # Register data/address to avoid off-chip glitches
                If(sram_zz == 0,
                   comb_adr.eq(0xf0),  # 1111_0000   page mode enabled, TCR = 85C, PAR enabled, full array PAR
                   comb_dm_n.eq(0xf),
                ).Elif(self.bus.cyc & self.bus.stb,
                    comb_adr.eq(self.bus.adr),
                    comb_dm_n.eq(~self.bus.sel),
                    If(self.bus.we,
                       comb_data_o.eq(self.bus.dat_w)
                    ).Else(
                        comb_oe_n.eq(0)
                    )
                ),
                If(store | config, comb_we_n.eq(0)),
                If(store | config | (self.bus.cyc & self.bus.stb & ~self.bus.we), comb_ce_n.eq(0))
            )
        ]
        sync_oe_n = Signal()
        self.sync += sync_oe_n.eq(comb_oe_n) # Register internally to match ODDR
        self.comb += data.oe.eq(sync_oe_n)

        self.specials += [
            Instance("ODDR",
                p_DDR_CLK_EDGE="SAME_EDGE",
                i_C=ClockSignal(), i_R=ResetSignal(), i_S=0, i_CE=1,
                i_D1=comb_oe_n, i_D2=comb_oe_n, o_Q=pads.oe_n,
            ),
            Instance("ODDR",
                p_DDR_CLK_EDGE="SAME_EDGE",
                i_C=ClockSignal(), i_R=ResetSignal(), i_S=0, i_CE=1,
                i_D1=comb_we_n, i_D2=comb_we_n, o_Q=pads.we_n,
            ),
            Instance("ODDR",
                p_DDR_CLK_EDGE="SAME_EDGE",
                i_C=ClockSignal(), i_R=ResetSignal(), i_S=0, i_CE=1,
                i_D1=comb_zz_n, i_D2=comb_zz_n, o_Q=pads.zz_n,
            ),
            Instance("ODDR",
                p_DDR_CLK_EDGE="SAME_EDGE",
                i_C=ClockSignal(), i_R=ResetSignal(), i_S=0, i_CE=1,
                i_D1=comb_ce_n, i_D2=comb_ce_n, o_Q=pads.ce_n,
            ),
        ]

        for i in range(4):
            self.specials += Instance("ODDR",
                p_DDR_CLK_EDGE="SAME_EDGE",
                i_C=ClockSignal(), i_R=ResetSignal(), i_S=0, i_CE=1,
                i_D1=comb_dm_n[i], i_D2=comb_dm_n[i], o_Q=pads.dm_n[i],
            ),

        for i in range(22):
            self.specials += Instance("ODDR",
                p_DDR_CLK_EDGE="SAME_EDGE",
                i_C=ClockSignal(), i_R=ResetSignal(), i_S=0, i_CE=1,
                i_D1=comb_adr[i], i_D2=comb_adr[i], o_Q=pads.adr[i],
            ),

        for i in range(32):
            self.specials += Instance("ODDR",
                p_DDR_CLK_EDGE="SAME_EDGE",
                i_C=ClockSignal(), i_R=ResetSignal(), i_S=0, i_CE=1,
                i_D1=comb_data_o[i], i_D2=comb_data_o[i], o_Q=data.o[i],
            ),

        for i in range(32):
            self.specials += Instance("IDDR",
                p_DDR_CLK_EDGE="OPPOSITE_EDGE",
                i_C=ClockSignal(), i_R=ResetSignal(), i_S=0, i_CE=load,
                i_D=data.i[i], o_Q1=self.bus.dat_r[i]
            ),

        counter       = Signal(max=max(rd_timing, wr_timing, 15)+1)
        counter_limit = Signal(max=max(rd_timing, wr_timing, 15)+1)
        counter_en    = Signal()
        counter_done  = Signal()
        self.comb += counter_done.eq(counter == counter_limit)
        self.sync += [
            If(counter_en & ~counter_done,
                counter.eq(counter + 1)
            ).Else(
                counter.eq(0)
            )
        ]

        last_page_adr     = Signal(22)
        last_cycle_was_rd = Signal()

        self.submodules.fsm = fsm = FSM()
        fsm.act("IDLE",
            NextValue(config, 0),
            If(read_config.fields.trigger,
                NextValue(config_override, 1),
                NextState("CONFIG_READ")
            ),
            If(load_config,
                NextValue(last_cycle_was_rd, 0),
                NextValue(counter_limit, 10), # 100 ns, assuming sysclk = 10ns. A little margin over min 70ns
                NextValue(sram_zz, 0), # zz has to fall before WE
                NextState("CONFIG_PRE")
            ).Elif(self.bus.cyc & self.bus.stb,
                NextValue(sram_zz, 1),
                If(self.bus.we,
                    NextValue(counter_limit, wr_timing),
                    counter_en.eq(1),
                    store.eq(1),
                    NextValue(last_cycle_was_rd, 0),
                    NextState("WR")
                ).Else(
                    counter_en.eq(1),
                    NextValue(last_page_adr,self.bus.adr),
                    NextValue(last_cycle_was_rd, 1),
                    If((self.bus.adr[2:last_page_adr.nbits] == last_page_adr[2:last_page_adr.nbits]) & last_cycle_was_rd, # doc says 4:nbits, but it doesn't work in practice...
                        NextState("RD"),
                        NextValue(counter_limit, page_rd_timing),
                    ).Else(
                        NextValue(counter_limit, rd_timing),
                        NextState("RD")
                    )
                )
            ).Else(
                NextValue(sram_zz, 1),
            )
        )
        fsm.act("CONFIG_READ",
            NextValue(counter_limit, rd_timing),
            NextValue(config_ce_n, 1),
            NextValue(config_we_n, 1),
            NextValue(config_oe_n, 1),
            NextState("CFGRD1"),
        )
        fsm.act("CFGRD1",
                counter_en.eq(1),
                NextValue(config_ce_n, 0),
                NextValue(config_oe_n, 0),
                If(counter_done,
                    NextValue(counter_limit, rd_timing),
                    NextValue(config_ce_n, 1), # Should be 5ns min high time
                    NextValue(config_oe_n, 1),
                    NextState("CFGRD2"),
                )
        )
        fsm.act("CFGRD2",
                counter_en.eq(1),
                NextValue(config_ce_n, 0),
                NextValue(config_oe_n, 0),
                If(counter_done,
                    NextValue(counter_limit, rd_timing),
                    NextValue(config_ce_n, 1), # Should be 5ns min high time
                    NextValue(config_oe_n, 1),
                    NextState("CFGWR1"),
                )
        )
        fsm.act("CFGWR1",
                counter_en.eq(1),
                NextValue(config_ce_n, 0),
                NextValue(config_we_n, 0),
                If(counter_done,
                    NextValue(counter_limit, rd_timing),
                    NextValue(config_ce_n, 1), # Should be 5ns min high time
                    NextValue(config_we_n, 1),
                    NextState("CFGRD3"),
                )
        )
        fsm.act("CFGRD3",
                counter_en.eq(1),
                NextValue(config_ce_n, 0),
                NextValue(config_oe_n, 0),
                If(counter_done,
                    NextValue(config_status.fields.mode, data.i),
                    NextValue(config_ce_n, 1), # Should be 5ns min high time
                    NextValue(config_oe_n, 1),
                    NextValue(config_override, 0),
                    NextState("IDLE"),
                )
        )

        fsm.act("CONFIG_PRE",
            NextState("CONFIG")
        )
        fsm.act("CONFIG",
            counter_en.eq(1),
            If(counter_done,
               NextValue(config, 0),
               NextState("ZZ_UP"),
            ).Else(
                NextValue(config, 1),
            ),
        )
        fsm.act("ZZ_UP",
            NextValue(config, 0),
            NextValue(sram_zz, 1),
            NextState("IDLE"),
        )
        fsm.act("RD",
            counter_en.eq(1),
            If(counter_done,
                load.eq(1),
                NextState("ACK")
            )
        )
        fsm.act("WR",
            counter_en.eq(1),
            store.eq(1),
            If(counter_done,
                NextState("ACK")
            )
        )
        fsm.act("ACK",
            self.bus.ack.eq(1),
            NextState("IDLE")
        )
