from migen import *
from migen.genlib.cdc import MultiReg, BlindTransfer, BusSynchronizer
from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect.csr import *

# WDT --------------------------------------------------------------------------------------------
class WDT(Module, AutoDoc, AutoCSR):
    def __init__(self, platform):
        default_period = 325000000
        self.intro = ModuleDoc("""Watch Dog Timer
A watchdog timer for Betrusted. Once enabled, it cannot be disabled, and
it must have the words `600d` then `c0de` written to the reset_code register
in sequence, once every timeout period. 

If this does not happen, the WDT will attempt to toggle reset of the full chip via GSR.

The timeout period is specified in 'approximately 65MHz' (15.38ns) periods by the period register.
According to Xilinx, 'approximately' is +/-50%.

The register cannot be updated once the WDT is running.
        """)
        self.gsr = Signal() # wire to the GSR line for the FPGA
        self.cfgmclk = Signal() # wire to FPGA's CFGMCLK ring oscillator, a "typical" 65MHz clock
        self.clock_domains.cd_wdt = ClockDomain()
        self.specials += Instance("BUFG", i_I=self.cfgmclk, o_O=self.cd_wdt.clk)
        platform.add_platform_command("create_clock -name wdt -period 10.256 [get_nets {net}]", net=self.cd_wdt.clk) # 65MHz + 50% tolerance

        ### WATCHDOG RESET, uses the extcomm_div divider to save on gates
        self.watchdog = CSRStorage(17, fields=[
            CSRField("reset_code", size=16,
                description="Write `600d` then `c0de` in sequence to this register to reset the watchdog timer"),
            CSRField("enable",
                description="Enable the watchdog timer. Cannot be disabled once enabled, except with a reset. Notably, a watchdog reset will disable the watchdog.",
                reset=0),
        ])
        self.period = CSRStorage(32, fields=[
            CSRField("period", size=32,
                description="Number of 'approximately 65MHz' CFGMCLK cycles before each reset_code must be entered. Defaults to a range of {:0.2f}-{:0.2f} seconds".format((default_period * 10.256e-9)*0.5, (default_period * 10.256e-9)*1.5), reset=default_period
            )
        ])
        self.state = CSRStatus(4, fields=[
            CSRField("enabled", size=1, description="WDT has been enabled"),
            CSRField("armed1", size=1, description="WDT in the armed1 state"),
            CSRField("armed2", size=1, description="WDT in the armed2 state"),
            CSRField("disarmed", size=1, description="WDT in the disarmed state"),
        ])
        armed1 = Signal()
        armed2 = Signal()
        disarmed = Signal()
        self.specials += MultiReg(armed1, self.state.fields.armed1)
        self.specials += MultiReg(armed2, self.state.fields.armed2)
        self.specials += MultiReg(disarmed, self.state.fields.disarmed)

        wdog_enable_wdt = Signal()
        self.specials += MultiReg(self.watchdog.fields.enable, wdog_enable_wdt, odomain="wdt")
        wdog_enabled = Signal(reset=0)
        wdog_enabled_r = Signal(reset=0)
        self.sync.wdt += [
            If(wdog_enable_wdt,
                wdog_enabled.eq(1)
            ).Else(
                wdog_enabled.eq(wdog_enabled)
            ),
            wdog_enabled_r.eq(wdog_enabled)
        ]
        self.specials += MultiReg(wdog_enabled, self.state.fields.enabled)
        self.submodules.code_sync = BusSynchronizer(16, "sys", "wdt")
        reset_code_wdt = Signal(16)
        self.comb += [
            self.code_sync.i.eq(self.watchdog.fields.reset_code),
            reset_code_wdt.eq(self.code_sync.o)
        ]
        self.submodules.period_sync = BusSynchronizer(32, "sys", "wdt")
        wdt_count = Signal(32)
        self.comb += [
            self.period_sync.i.eq(self.period.fields.period),
            wdt_count.eq(self.period_sync.o)
        ]
        wdt_count_lock = Signal(32)
        wdt_start = Signal()
        self.sync.wdt += [
            wdt_start.eq(~wdog_enabled_r & wdog_enabled),
            If(~wdog_enabled_r & wdog_enabled,
                wdt_count_lock.eq(wdt_count)
            ).Else(
                wdt_count_lock.eq(wdt_count_lock),
            )
        ]
        wdog_counter = Signal(32, reset=default_period)
        wdog_cycle = Signal()
        self.sync.wdt += [
            If(wdt_start,
                wdog_counter.eq(wdt_count_lock),
            ).Else(
                If(wdog_enabled,
                    If(wdog_counter == 0,
                        wdog_cycle.eq(1),
                        wdog_counter.eq(wdt_count_lock)
                    ).Else(
                        wdog_counter.eq(wdog_counter - 1),
                        wdog_cycle.eq(0),
                    )
                )
            )
        ]
        do_reset = Signal()
        wdog = ClockDomainsRenamer("wdt")(FSM(reset_state="IDLE"))
        self.submodules += wdog
        wdog.act("IDLE",
            If(wdog_enabled,
                NextState("WAIT_ARM")
            )
        )
        wdog.act("WAIT_ARM",
            # sync up to the watchdog cycle so we give ourselves a full cycle to disarm the watchdog
            If(wdog_cycle,
                NextState("ARMED")
            )
        )
        wdog.act("ARMED",
            armed1.eq(1),
            If(wdog_cycle,
                do_reset.eq(1),
            ),
            If(reset_code_wdt == 0x600d,
                NextState("DISARM1")
            )
        )
        wdog.act("DISARM1",
            armed2.eq(1),
            If(wdog_cycle,
                do_reset.eq(1),
            ),
            If(reset_code_wdt == 0xc0de,
                NextState("DISARMED")
            ).Else(
                NextState("ARMED")
            )
        )
        wdog.act("DISARMED",
            disarmed.eq(1),
            If(wdog_cycle,
                NextState("ARMED")
            )
        )
        do_reset_sys = Signal()
        reset_stretch = Signal(5, reset=0)
        self.submodules.do_res_sync = BlindTransfer("wdt", "sys")
        self.comb += [
            self.do_res_sync.i.eq(do_reset),
            do_reset_sys.eq(self.do_res_sync.o),
        ]
        self.specials += MultiReg(do_reset, do_reset_sys) # sysclk should be strictly shorter than cclk for this to work, otherwise we may need a blind synchronizer
        self.sync += [
            If(do_reset_sys,
                reset_stretch.eq(31),
                self.gsr.eq(0),
            ).Elif(reset_stretch != 0,
                self.gsr.eq(1),
                reset_stretch.eq(reset_stretch - 1),
            ).Else(
                reset_stretch.eq(0),
                self.gsr.eq(0),
            )
        ]
