from migen import *
from migen.genlib.cdc import MultiReg, BlindTransfer, BusSynchronizer
from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import *

# WDT --------------------------------------------------------------------------------------------
class WDT(Module, AutoDoc, AutoCSR):
    def __init__(self, platform):
        default_period = 325000000
        self.intro = ModuleDoc("""Watch Dog Timer
A watchdog timer for Betrusted. Once enabled, it cannot be disabled, and
it must have the reset_wdt bit written periodically to avoid a watchdog reset event.

If this does not happen, the WDT will attempt to toggle reset of the full chip via GSR.

The timeout period is specified in 'approximately 65MHz' (15.38ns) periods by the period register.
According to Xilinx, 'approximately' is +/-50%.

The register cannot be updated once the WDT is running.
        """)
        self.gsr = Signal() # wire to the GSR line for the FPGA
        self.cfgmclk = Signal() # wire to FPGA's CFGMCLK ring oscillator, a "typical" 65MHz clock
        self.clock_domains.cd_wdt = ClockDomain()
        self.specials += Instance(
            "BUFG",
            name="BUFG_WDT",
            i_I=self.cfgmclk,
            o_O=self.cd_wdt.clk,
            attr=("KEEP", "DONT_TOUCH")
        )
        # prevent this signal from being optimized away, as it needs to exist for us to apply the constraint
        platform.add_platform_command("create_clock -name wdt -period 10.256 [get_pins BUFG_WDT/O]", net=self.cd_wdt.clk) # 65MHz + 50% tolerance

        ### WATCHDOG RESET, uses the extcomm_div divider to save on gates
        self.watchdog = CSRStorage(fields=[
            CSRField("reset_wdt", size=1,
                description="Write to this register to reset the watchdog timer", pulse=True),
            CSRField("enable",
                description="Enable the watchdog timer. Cannot be disabled once enabled, except with a reset. Notably, a watchdog reset will disable the watchdog.",
                reset=0),
        ])
        reset_wdt = Signal()
        w_stretch = Signal(3)
        reset_wdt_sys = Signal()
        self.sync += [
            If(self.watchdog.fields.reset_wdt,
                w_stretch.eq(7)
            ).Elif(w_stretch > 0,
                w_stretch.eq(w_stretch - 1)
            ),
            reset_wdt_sys.eq(w_stretch != 0),
        ]
        self.submodules.reset_sync = BlindTransfer("sys", "wdt")
        self.comb += [
            self.reset_sync.i.eq(reset_wdt_sys),
            reset_wdt.eq(self.reset_sync.o),
        ]
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
                NextState("DISARMED")
            )
        )
        wdog.act("ARMED_HOT",
            armed2.eq(1),
            If(reset_wdt,
                NextState("DISARMED")
            ).Elif(wdog_cycle,
                do_reset.eq(1),
            ),
        )
        # double-interlock: not having responded to the watchdog code immediately
        # is not cause for a reset: this could just be the wdog_cycle hitting at an
        # inopportune time relative to the watchdog reset routine.
        # instead, escalate to the ARMED_HOT state so that
        # the watchdog next period, if no action was taken, we do a reset
        wdog.act("ARMED",
            armed1.eq(1),
            If(reset_wdt,
                NextState("DISARMED")
            ).Elif(wdog_cycle,
                NextState("ARMED_HOT")
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
