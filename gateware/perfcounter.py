from migen import *
from migen.genlib.fsm import FSM, NextState

from litex.soc.interconnect import wishbone
from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc
from migen.genlib import fifo

# width of the event FIFO
FIFO_WIDTH = 64
# depth of the event FIFO
FIFO_DEPTH = 4096 # this will consume 4x RAM blocks

# maximum number of event sources -- each is mapped into a separate memory space
EVENT_SOURCES = 6
# maximum width of the event code field, as an integer that represents the number of bits minus 1 (so 31 codes for 32 bits, 0 codes for 1 bit)
EVENT_WIDTH = 5

class PerfEvent(Module, AutoCSR, AutoDoc):
    def __init__(self):
        self.intro = ModuleDoc("""Performance event input
        A single register where a code is written to correlate a timestamp. Several of these
        are instantiated on separate CSR pages so that multiple virtual memory spaces can share
        a common sense of time.
        """)
        self.perfevent = CSRStorage(fields=[
            CSRField("code", size=32, description="Code that represents the performance event. Only the lowest 2**event_width_minus_one bits are recorded. The event_width_minus_one is a global setting in the main block.")
        ])


class PerfCounter(Module, AutoCSR, AutoDoc):
    def __init__(self, soc):
        self.intro = ModuleDoc("""Performance counter
        A triggerable counter that feeds into a FIFO to log user-index events.
        """)

        self.config = CSRStorage(fields=[
            CSRField("prescaler", size=16, description="(Number of CPU clocks + 1) per perf counter interval. 0 -> 1 clock per interval, 3-> 4 clocks per interval."),
            CSRField("saturate", size=1, description="When `1`, counter will stop instead of rolling over. Must set the `saturate_limit` before setting this, otherwise it will trigger prematurely."),
            CSRField("event_width_minus_one", size=EVENT_WIDTH, description="Width of the perfevent field in bits, minus 1 (so a 16-bit wide field should specify 15)")
        ])
        self.saturate_limit = CSRStorage(64,
            description="Saturation limit, if selected. Set this before setting `saturate` to `1`",
        )
        self.run = CSRStorage(fields=[
            CSRField("reset_run", description="When set to `1`, counter is reset to 0 and runs", pulse=True),
            CSRField("stop", description="When set to `1`, counter stops running. If set simultaneously with `reset_run`, the counters clear to 0 but then do not run.")
        ])
        self.status = CSRStatus(fields = [
            CSRField("running", description="Counter is running when value is `1`"),
            CSRField("overflow", description="Counter has overflowed since it was started"),
            CSRField("readable", description="If `1` indicates that there are events to read"),
        ])

        event_re = Signal(EVENT_SOURCES)
        event_code_dict = {}
        event_code_mux = Signal(32)
        for i in range(EVENT_SOURCES):
            setattr(self, 'event_code' + str(i), Signal(32))
            setattr(
                soc.submodules, 'event_source' + str(i),
                PerfEvent()
            )
            soc.add_csr('event_source' + str(i))

            self.comb += [
                event_re[i].eq(getattr(soc, 'event_source' + str(i)).perfevent.re)
            ]
            event_code_dict[1 << i] = event_code_mux.eq(getattr(soc, 'event_source' + str(i)).perfevent.fields.code)
        event_code_dict["default"] = event_code_mux.eq(0xFFFF_FFFF) # mark multiple-write conflicts with an 0xFFFF_FFFF value
        self.sync += Case(event_re, event_code_dict)

        # readback mechanism. Index allows us to track which index in the FIFO we're getting.
        # code is the event code, lowest 2**event_width_minus_one bits
        # timestamp =is the event timestamp, lowest fifo_width - 2**event_width_minus_one bits
        self.event_index = CSRStatus(fields=[
            CSRField("index", size=log2_int(FIFO_DEPTH), description="Index of the event in the FIFO. Auto-increments on read, clears on a `reset_run`")
        ])
        self.event_raw = CSRStatus(fields=[
            CSRField("timestamp", size=FIFO_WIDTH, description="Event code + timestamp, concatenated together per `event_width_minus_one` parameter".format(FIFO_WIDTH))
        ])
        event_index_ctr = Signal(log2_int(FIFO_DEPTH))
        self.sync += [
            If(self.run.fields.reset_run,
                event_index_ctr.eq(0)
            ).Elif(self.event_index.we & (event_index_ctr <= (FIFO_DEPTH - 1)),
                event_index_ctr.eq(event_index_ctr + 1)
            ).Else(
                event_index_ctr.eq(event_index_ctr)
            )
        ]
        self.comb += [
            self.event_index.fields.index.eq(event_index_ctr)
        ]

        event_timer = Signal(FIFO_WIDTH)
        event_prescaler = Signal(17)
        self.sync += [
            If(self.run.fields.stop,
                self.status.fields.running.eq(0)
            ).Elif(self.run.fields.reset_run,
                self.status.fields.running.eq(1)
            ).Else(
                self.status.fields.running.eq(self.status.fields.running)
            ),

            If(self.run.fields.reset_run,
                event_timer.eq(0),
                event_prescaler.eq(0),
            ).Else(
                If(~self.status.fields.running | self.config.fields.saturate & (self.saturate_limit.storage <= event_timer),
                    event_timer.eq(event_timer),
                    event_prescaler.eq(event_prescaler),
                    If(self.config.fields.saturate & (self.saturate_limit.storage <= event_timer),
                        self.status.fields.overflow.eq(1)
                    )
                ).Else(
                    If(self.status.fields.running,
                        If( (event_prescaler + 1) > self.config.fields.prescaler,
                            event_timer.eq(event_timer + 1),
                            event_prescaler.eq(0)
                        ).Else(
                            event_prescaler.eq(event_prescaler + 1),
                        )
                    ).Else(
                        event_prescaler.eq(event_prescaler),
                        event_timer.eq(event_timer),
                    )
                )
            )
        ]

        #### now build the event logger FIFO
        self.submodules.logfifo = logfifo = fifo.SyncFIFOBuffered(width=FIFO_WIDTH, depth=FIFO_DEPTH)
        fifo_mux = {}
        for i in range(2**EVENT_WIDTH):
            fifo_mux[i] = logfifo.din.eq(Cat(event_code_mux[:i+1], event_timer[:FIFO_WIDTH - i - 1]))

        self.sync += logfifo.we.eq(event_re != 0)
        self.comb += [
            Case(self.config.fields.event_width_minus_one, fifo_mux),

            self.event_raw.fields.timestamp.eq(logfifo.dout),
            logfifo.re.eq(self.event_index.we),
            self.status.fields.readable.eq(logfifo.readable),
        ]
