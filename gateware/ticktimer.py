from migen import *
from migen.genlib.cdc import MultiReg

from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc


class TickTimer(Module, AutoCSR, AutoDoc):
    """Millisecond timer"""
    def __init__(self, clkspertick, clkfreq, bits=64):
        self.clkspertick = int(clkfreq/ clkspertick)

        self.intro = ModuleDoc("""TickTimer: A practical systick timer.

        TIMER0 in the system gives a high-resolution, sysclk-speed timer which overflows
        very quickly and requires OS overhead to convert it into a practically usable time source
        which counts off in systicks, instead of sysclks.

        The hardware parameter to the block is the divisor of sysclk, and sysclk. So if
        the divisor is 1000, then the increment for a tick is 1ms. If the divisor is 2000,
        the increment for a tick is 0.5ms. 
        """)

        resolution_in_ms = 1000 * (self.clkspertick / clkfreq)
        self.note = ModuleDoc(title="Configuration",
            body="This timer was configured with {} bits, which rolls over in {:.2f} years, with each bit giving {}ms resolution".format(
                bits, (2**bits / (60*60*24*365)) * (self.clkspertick / clkfreq), resolution_in_ms))

        prescaler = Signal(max=self.clkspertick, reset=self.clkspertick)
        timer = Signal(bits)

        # cross-process domain signals. Broken out to a different CSR so it can be on a different virtual memory page.
        self.pause = Signal()
        self.load = Signal()
        self.paused = Signal()
        self.timer = Signal(bits)
        self.resume_time = Signal(bits)

        self.control = CSRStorage(2, fields=[
            CSRField("reset", description="Write a `1` to this bit to reset the count to 0. This bit has priority over all other requests.", pulse=True),
        ])
        self.time = CSRStatus(bits, name="time", description="""Elapsed time in systicks""")
        self.comb += [
            self.timer.eq(timer),
        ]
        self.sync += [
            If(self.control.fields.reset,
                timer.eq(0),
                prescaler.eq(self.clkspertick),
            ).Elif(self.load,
                prescaler.eq(self.clkspertick),
                timer.eq(self.resume_time),
            ).Else(
                If(prescaler == 0,
                   prescaler.eq(self.clkspertick),

                   If(self.pause == 0,
                       timer.eq(timer + 1),
                       self.paused.eq(0)
                   ).Else(
                       timer.eq(timer),
                       self.paused.eq(1)
                   )
                ).Else(
                   prescaler.eq(prescaler - 1),
                )
            )
        ]

        self.comb += self.time.status.eq(timer)

        self.msleep = ModuleDoc("""msleep extension
        
        The msleep extension is a Xous-specific add-on to aid the implementation of the msleep server.
        
        msleep fires an interrupt when the requested time is less than or equal to the current elapsed time in
        systicks. The interrupt remains active until a new target is set, or masked. 
        """)
        self.msleep_target = CSRStorage(size=bits, description="Target time in {}ms ticks".format(resolution_in_ms))
        self.submodules.ev = EventManager()
        alarm = Signal()
        self.ev.alarm = EventSourceLevel()
        self.comb += self.ev.alarm.trigger.eq(alarm)

        self.comb += alarm.eq(self.msleep_target.storage <= timer)

