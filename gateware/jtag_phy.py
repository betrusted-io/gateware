from migen import *

from litex.soc.interconnect.csr_eventmanager import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc

# BtJtag -------------------------------------------------------------------------------------------
class BtJtag(Module, AutoDoc, AutoCSR):
    def __init__(self, pads):
        self.intro = ModuleDoc("""JTAG loopback connectivity for self-provisioning of fuses.
        This module implements the "soft PHY" for a JTAG loopback interface driven by a firmware driver.
        The soft PHY enforces timing constraints on the JTAG interface, and sequences the order of
        TDO-vs-TDI. This could also have been done just using a GPIO bitbang but the interface runs
        a bit faster by having the TCK pulse automatically every time TDI/TMS is written, and it
        also means timing is more deterministic and less liable to variability due to e.g. cache-line
        misses. 
        """)
        self.next = CSRStorage(name="next", description="Next state for TDI/TMS; writing automatically clocks TCK", fields=[
            CSRField("tdi", size=1, description="TDI pin value"),
            CSRField("tms", size=1, description="TMS pin value"),
        ])
        self.tdo = CSRStatus(name="tdo", description="TDO resulting from previous cycle", fields=[
            CSRField("tdo", size=1, description="TDO pin value"),
            CSRField("ready", size=1, description="JTAG machine is ready for a new cycle; also indicates TDO is valid"),
        ])
        ready = Signal(reset=1)
        self.comb += [
            self.tdo.fields.ready.eq(ready & ~self.next.re)  # ensure valid goes immediately low
        ]
        self.sync += [  # use a flop to clean up timing
            pads.tdi.eq(self.next.fields.tdi),
            pads.tms.eq(self.next.fields.tms),
        ]

        fsm = FSM(reset_state="IDLE")
        self.submodules += fsm
        fsm.act("IDLE",
            If(self.next.re, # note if we spam-write to self.next, we will miss items, so "ready" must be checked
                NextState("TDO"),
                NextValue(ready, 0),
            )
        )
        fsm.act("TDO", # this state also guarantees setup time for tdi/tms
            NextValue(self.tdo.fields.tdo, pads.tdo),
            NextState("TCK"),
        )
        fsm.act("TCK", # 10ns pulse width -> ~50MHz rate assuming 50/50 duty cycle (datasheet only specifies TCK <66MHz)
            pads.tck.eq(1),
            NextState("IDLE"),
            NextValue(ready, 1),
        ) # there is a 7ns "hold" requirement after TCK falls; guaranteed by 1 clock minimum in "IDLE" state
