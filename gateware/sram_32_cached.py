from migen import *
from migen.genlib.fsm import FSM, NextState

from litex.soc.interconnect import wishbone
from litex.soc.interconnect.csr import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc

from math import log2

class SRAM32(Module, AutoCSR, AutoDoc):
    def __init__(self, pads, rd_timing, wr_timing, page_rd_timing,
            l2_cache_size=0x10000,
            reverse=False,
            l2_cache_full_memory_we = True,
            use_idelay = False,
            expose_csr = True
            ):

        # adjust input parameters so they are in multiples of 10 ns
        page_rd_timing = page_rd_timing - 1
        rd_timing = rd_timing + 1

        self.intro = ModuleDoc("""Intro
This version of the SRAM32 block introduces an L2 cache. This block is
borrowed from the LiteX L2 cache that is normally found on DRAM. The use
of this block (along with some bug fixes compared to the previous rev) also
allows us to improve the page-read timing mode of the SRAM.

Configuring this with a 128k cache increases power consumption by ~2mA during idle, but
overall improves performance from about 30% to 200%, depending upon the benchmark.
Small routines that mostly ran out of L1 cache are sped up less; large routines that
would blow out L1 entirely are sped up much more.
        """)

        # Insert L2 cache in between Wishbone bus and SRAM
        l2_cache_data_width = 256
        l2_cache_size = max(l2_cache_size, int(2*l2_cache_data_width/8)) # Use minimal size if lower
        l2_cache_size = 2**int(log2(l2_cache_size))                  # Round to nearest power of 2
        l2_cache = wishbone.Cache(
            cachesize = l2_cache_size//4,
            master    = wishbone.Interface(),
            slave     = wishbone.Interface(l2_cache_data_width),
            reverse   = reverse)
        if l2_cache_full_memory_we:
            l2_cache = FullMemoryWE()(l2_cache)
        self.submodules.l2_cache = l2_cache
        self.cbus = self.l2_cache.slave
        self.bus = self.l2_cache.master

        config_status_wire = Signal(32)
        read_config_wire = Signal()
        if expose_csr:
            config_status = self.config_status = CSRStatus(fields=[
                CSRField("mode", size=32, description="The current configuration mode of the SRAM")
            ])
            read_config = self.read_config = CSRStorage(fields=[
                CSRField("trigger", size=1, description="Writing to this bit triggers the SRAM mode status read update", pulse=True)
            ])
            self.comb += [
                config_status.fields.mode.eq(config_status_wire),
                read_config_wire.eq(read_config.fields.trigger),
            ]

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

        store           = Signal()
        load            = Signal()
        config          = Signal()
        config_ce_early = Signal()
        config_override = Signal()
        config_ce_n     = Signal(reset=1)
        config_we_n     = Signal(reset=1)
        config_oe_n     = Signal(reset=1)
        access          = Signal()

        comb_oe_n   = Signal(reset=1)
        comb_we_n   = Signal(reset=1)
        comb_zz_n   = Signal(reset=1)
        comb_ce_n   = Signal(reset=1)
        self.debug_ce = Signal()
        self.comb += self.debug_ce.eq(comb_ce_n)
        comb_dm_n   = Signal(4)
        comb_adr    = Signal(22)
        comb_data_o = Signal(32)
        burst_adr   = Signal(int(log2(l2_cache_data_width/32)))
        burst_adr_max = int(2**(log2(l2_cache_data_width/32)) - 1)
        read_reg = Signal(l2_cache_data_width)
        read_ram = Signal(32)
        read_shift = Signal()

        comb_oe_n.reset, comb_we_n.reset = 1, 1
        comb_zz_n.reset, comb_ce_n.reset = 1, 1
        data_reg = Signal(32)

        cases = {}
        for i in range(burst_adr_max+1):
            cases[i] = [
                data_reg.eq(self.cbus.dat_w[i*32 : (i+1)*32])
            ]
        # this extra cycle is OK because data only needs to be stable 23ns before the rising edge of WE
        # and this helps relax the timing from wishbone to the ODDR devices by adding a retiming register
        self.sync += Case(burst_adr, cases)

        self.sync += [
            If(read_shift,
                read_reg.eq(Cat(read_reg[32:],read_ram))
            ).Else(
                read_reg.eq(read_reg)
            )
        ]
        self.comb += self.cbus.dat_r.eq(read_reg)

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
               comb_dm_n.eq(0x0),
               comb_adr.eq(0x3fffff),
               comb_data_o.eq(0),
            ).Else(
                # Register data/address to avoid off-chip glitches
                If(sram_zz == 0,
                   comb_adr.eq(0xf0),  # 1111_0000   page mode enabled, TCR = 85C, PAR enabled, full array PAR
                   comb_dm_n.eq(0x0),
                ).Elif(self.cbus.cyc & self.cbus.stb,
                    comb_adr.eq(Cat(burst_adr, self.cbus.adr)),
                    comb_dm_n.eq(0), # ~self.cbus.sel -- we are using FullMemoryWE so we never do byte-write commits at the cache level
                ),
                If(store | config, comb_we_n.eq(0)),
                If(config | config_ce_early | access, comb_ce_n.eq(0)),
                comb_data_o.eq(data_reg),
                comb_oe_n.eq(~load),
            )
        ]

        # split the OE signal into a driver per pin, because otherwise we have one FF driving
        # 32 drivers that are very far away and we end up paying ~2.6ns penalty in OE being late.
        data = []
        data_i = Signal(32)
        self.sync_oe_n = sync_oe_n = Signal()
        self.sync += sync_oe_n.eq(~load & access) # Register internally to match ODDR
        for i in range(32):
            data.append(TSTriple())
            self.specials += data[i].get_tristate(pads.d[i])
            self.comb += data[i].oe.eq(sync_oe_n)
            self.comb += data_i[i].eq(data[i].i)

        self.specials += [
            Instance("ODDR",
                p_DDR_CLK_EDGE="SAME_EDGE",
                p_INIT=1,
                i_C=ClockSignal(), i_R=0, i_S=ResetSignal(), i_CE=1,
                i_D1=comb_oe_n, i_D2=comb_oe_n, o_Q=pads.oe_n,
            ),
            Instance("ODDR",
                p_DDR_CLK_EDGE="SAME_EDGE",
                p_INIT=1,
                i_C=ClockSignal(), i_R=0, i_S=ResetSignal(), i_CE=1,
                i_D1=comb_we_n, i_D2=comb_we_n, o_Q=pads.we_n,
            ),
            Instance("ODDR",
                p_DDR_CLK_EDGE="SAME_EDGE",
                p_INIT=1,
                i_C=ClockSignal(), i_R=0, i_S=ResetSignal(), i_CE=1,
                i_D1=comb_zz_n, i_D2=comb_zz_n, o_Q=pads.zz_n,
            ),
            Instance("ODDR",
                p_DDR_CLK_EDGE="SAME_EDGE",
                p_INIT=1,
                i_C=ClockSignal(), i_R=0, i_S=ResetSignal(), i_CE=1,
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
                i_D1=comb_data_o[i], i_D2=comb_data_o[i], o_Q=data[i].o,
            ),

        if use_idelay:
                # uses the "spinor" clock signal, which is 90 degrees late (2.5ns late)
                self.specials += Instance("IDDR",
                    p_DDR_CLK_EDGE="OPPOSITE_EDGE",
                    i_C=ClockSignal("spinor"), i_R=ResetSignal("spinor"), i_S=0, i_CE=1,
                    i_D=data[i].i, o_Q1=read_ram[i]
                ),
        else:
            for i in range(32):
                self.specials += Instance("IDDR",
                    p_DDR_CLK_EDGE="OPPOSITE_EDGE",
                    i_C=ClockSignal(), i_R=ResetSignal(), i_S=0, i_CE=1,
                    i_D=data[i].i, o_Q1=read_ram[i]
                ),

        counter       = Signal(max=max(rd_timing, wr_timing, page_rd_timing, 15)+1)
        counter_limit = Signal(max=max(rd_timing, wr_timing, page_rd_timing, 15)+1)
        counter_en    = Signal()
        counter_done  = Signal()
        counter_almost_done = Signal()
        self.comb += counter_done.eq(counter >= counter_limit)
        self.comb += counter_almost_done.eq(counter == (counter_limit - 1))
        self.sync += [
            If(counter_en & ~counter_done,
                counter.eq(counter + 1)
            ).Else(
                counter.eq(0)
            )
        ]

        self.comb += access.eq(self.cbus.cyc) # power up the SRAM whenever the cbus is active
        self.cache_idle = Signal()
        self.submodules.fsm = fsm = FSM()
        self.comb += self.cache_idle.eq(fsm.ongoing("IDLE"))
        fsm.act("IDLE",
            NextValue(self.cbus.ack, 0),
            NextValue(config, 0),
            If(read_config_wire,
                NextValue(config_override, 1),
                NextState("CONFIG_READ")
            ),
            If(load_config,
                NextValue(counter_limit, 12), # 120 ns, assuming sysclk = 10ns. A little margin over min 70ns
                NextValue(sram_zz, 0), # zz has to fall before WE
                NextState("CONFIG_PRE")
            ).Elif(self.cbus.cyc & self.cbus.stb,
                NextValue(sram_zz, 1),
                NextValue(burst_adr, 0),
                If(self.cbus.we,
                    NextState("WR_CE"),
                ).Else(
                    NextValue(load, 1),
                    counter_en.eq(1),
                    NextValue(counter_limit, rd_timing),
                    NextState("RD")
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
                    NextValue(config_status_wire, data_i),
                    NextValue(config_ce_n, 1), # Should be 5ns min high time
                    NextValue(config_oe_n, 1),
                    NextValue(config_override, 0),
                    NextState("IDLE"),
                )
        )

        fsm.act("CONFIG_PRE",
            # Tzzwe
            NextState("CONFIG_PRE2")
        )
        fsm.act("CONFIG_PRE2",
            # Tzzwe
            NextState("CONFIG_PRE3"),
        ),
        fsm.act("CONFIG_PRE3",
            NextValue(config_ce_early, 1), # drop CE
            NextState("CONFIG"),
        ),
        fsm.act("CONFIG",
            counter_en.eq(1),
            If(counter_done,
               NextValue(config, 0),
               NextState("ZZ_UP"),
            ).Else(
                NextValue(config, 1),  # drops WE
            ),
        )
        fsm.act("ZZ_UP",
            NextValue(config, 0), # raise WE
            NextState("ZZ_UP2"),
        )
        fsm.act("ZZ_UP2",
            NextValue(config_ce_early, 0), # raise CE
            NextState("ZZ_UP3"),
        )
        fsm.act("ZZ_UP3",
            NextValue(sram_zz, 1), # raise ZZ
            NextState("IDLE"),
        )

        fsm.act("RD",
            counter_en.eq(1),
            If(counter_almost_done,
                NextValue(burst_adr, burst_adr + 1),
            ),
            NextValue(read_shift, counter_done),
            If(counter_almost_done & (burst_adr != burst_adr_max),
                NextValue(counter_limit, page_rd_timing),
                NextState("RD")
            ).Elif(counter_almost_done & (burst_adr == burst_adr_max),
                NextState("RACK")
            )
        )
        fsm.act("RACK",
            NextValue(read_shift, counter_done),
            counter_en.eq(1),
            NextState("RACK2")
        )
        fsm.act("RACK2",
            NextValue(read_shift, 0),
            NextValue(self.cbus.ack, 1),
            NextState("RACK3")
        )
        fsm.act("RACK3",
            NextValue(load, 0),
            NextValue(self.cbus.ack, 0),
            NextState("IDLE")
        )


        fsm.act("WR_CE", # one extra cycle penalty for CE to propagate through the standby bus switch.
            # might be able to cut this, but we only gain ~1.5% write performance for a potential reliability hit
            # the one-cycle penalty only applies to the first cycle of the burst, not every data element...
            NextValue(counter_limit, wr_timing),
            store.eq(1),
            NextState("WR")
        )
        fsm.act("WR",
            counter_en.eq(1),
            If(counter_almost_done,
                NextValue(burst_adr, burst_adr + 1),
            ),
            If(counter_almost_done & (burst_adr == burst_adr_max),
                NextState("WACK"),
                NextValue(self.cbus.ack, 1),
            ).Elif(counter_almost_done & (burst_adr != burst_adr_max),
                NextState("WR"),
            ).Else (
                store.eq(1),
            )
        )
        fsm.act("WACK",
            counter_en.eq(1),
            NextValue(self.cbus.ack, 0),
            NextState("IDLE")
        )
