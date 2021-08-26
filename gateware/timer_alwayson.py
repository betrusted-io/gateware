#
# This file is part of LiteX.
#
# Copyright (c) 2013-2015 Sebastien Bourdeauducq <sb@m-labs.hk>
# Copyright (c) 2019 Sean Cross <sean@xobs.io>
# Copyright (c) 2019 Florent Kermarrec <florent@enjoy-digital.fr>
# SPDX-License-Identifier: BSD-2-Clause


from migen import *
from migen.genlib.cdc import MultiReg, BusSynchronizer

from litex.soc.interconnect.csr import *
from litex.soc.interconnect.csr_eventmanager import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc

# Timer --------------------------------------------------------------------------------------------

class TimerAlwaysOn(Module, AutoCSR, AutoDoc):
    with_uptime = False
    def __init__(self, width=32):
        self.intro = ModuleDoc("""Timer

    Provides a generic Timer core.

    The Timer is implemented as a countdown timer that can be used in various modes:

    - Polling : Returns current countdown value to software
    - One-Shot: Loads itself and stops when value reaches ``0``
    - Periodic: (Re-)Loads itself when value reaches ``0``

    ``en`` register allows the user to enable/disable the Timer. When the Timer is enabled, it is
    automatically loaded with the value of `load` register.

    When the Timer reaches ``0``, it is automatically reloaded with value of `reload` register.

    The user can latch the current countdown value by writing to ``update_value`` register, it will
    update ``value`` register with current countdown value.

    To use the Timer in One-Shot mode, the user needs to:

    - Disable the timer
    - Set the ``load`` register to the expected duration
    - (Re-)Enable the Timer

    To use the Timer in Periodic mode, the user needs to:

    - Disable the Timer
    - Set the ``load`` register to 0
    - Set the ``reload`` register to the expected period
    - Enable the Timer

    For both modes, the CPU can be advertised by an IRQ that the duration/period has elapsed. (The
    CPU can also do software polling with ``update_value`` and ``value`` to know the elapsed duration)
    
    This timer is forked from the LiteX timer and supports a timer that runs in an always-on
    clock domain. This implementation assumes that the always-on clock is strictly equal to or slower than the
    sysclk domain.
    """)
        self._load = CSRStorage(width, description="""Load value when Timer is (re-)enabled.
            In One-Shot mode, the value written to this register specifies the Timer's duration in
            clock cycles.""")
        self._reload = CSRStorage(width, description="""Reload value when Timer reaches ``0``.
            In Periodic mode, the value written to this register specify the Timer's period in
            clock cycles.""")
        self._en = CSRStorage(1, description="""Enable flag of the Timer.
            Set this flag to ``1`` to enable/start the Timer.  Set to ``0`` to disable the Timer.""")

        self.submodules.ev = EventManager()
        self.ev.zero       = EventSourceProcess(edge="rising")
        self.ev.finalize()

        # # #

        reload_ao = Signal(width)
        self.submodules.reload_sync = BusSynchronizer(width, "sys", "always_on")
        self.comb += [
            self.reload_sync.i.eq(self._reload.storage),
            reload_ao.eq(self.reload_sync.o)
        ]
        load_ao = Signal(width)
        self.submodules.load_sync = BusSynchronizer(width, "sys", "always_on")
        self.comb += [
            self.load_sync.i.eq(self._load.storage),
            load_ao.eq(self.load_sync.o)
        ]
        en_sync = Signal()
        self.specials += MultiReg(self._en.storage, en_sync, "always_on")

        trigger_sync = Signal()
        value = Signal(width)
        self.trigger_always_on = Signal()
        self.comb += self.trigger_always_on.eq(value == 0)
        self.specials += MultiReg(self.trigger_always_on, trigger_sync)

        self.sync.always_on += [
            If(en_sync,
                If(value == 0,
                    # set reload to 0 to disable reloading
                    value.eq(reload_ao)
                ).Else(
                    value.eq(value - 1)
                )
            ).Else(
                value.eq(load_ao)
            ),
        ]
        self.comb += self.ev.zero.trigger.eq(trigger_sync)
