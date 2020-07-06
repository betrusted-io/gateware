from migen import *
from migen.genlib.cdc import MultiReg

from litex.soc.interconnect.csr import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc

class TrngRingOscV2(Module, AutoCSR, AutoDoc):
    def __init__(self, platform):
        self.intro = ModuleDoc("""
TrngRingOscV2 builds a set of fast oscillators that are allowed to run independently to
gather entropy, and then are merged into a single large oscillator to create a bit of
higher-quality entropy. The idea for this is taken from "Fast Digital TRNG Based on
Metastable Ring Oscillator", with modifications. I actually suspect the ring oscillator
is not quite metastable during the small-ring phase, but it is accumulating phase noise
as an independent variable, so I think the paper's core idea still works.

* `self.trng_slow` and `self.trng_fast` are debug hooks for sampled TRNG data and the fast ring oscillator, respectively. 
        """)
        devstr = platform.device.split('-')
        device_root = devstr[0]
        if devstr[1][0:3] != 'xc7':
            print("TrngRingOscV2 only supported for 7-Series devices")

        self.trng_raw = Signal()  # raw TRNG output bitstream

        ro_elements = 33  # needs to be an odd number, and larger than the size of `self.rand`. 33 is probably optimal.
        ro_stages = 1     # needs to be an odd number. 1 is probably optimal, but coded to accept other numbers, too.

        self.trng_out_sync = Signal()  # single-bit output, synchronized to sysclk
        self.ctl = CSRStorage(fields=[
            CSRField("ena", size=1, description="Enable the TRNG; 0 puts the TRNG into full powerdown", reset=0),
            CSRField("gang", size=1, description="Fold in collective gang entropy during dwell time", reset=1),
            CSRField("dwell", size=20, description="""Prescaler to set dwell-time of entropy collection. 
            Controls the period of how long the oscillators are in a metastable state to collect entropy 
            before sampling. Value encodes the number of sysclk edges to pass during the dwell period.""", reset=100),
            CSRField("delay", size=10, description="""Sampler delay time. Sets the delay between when the small rings
            are merged together, and when the final entropy result is sampled. Value encodes number of sysclk edges
            to pass during the delay period. Delay should be long enough for the signal to propagate around the merged ring,
            but longer times also means more coupling of the deterministic sysclk noise into the rings.""", reset=8)
        ])
        self.rand = CSRStatus(fields=[
            CSRField("rand", size=ro_elements-1, description="Random data shifted into a register for easier collection.", reset=0xDEADBEEF)
        ])
        self.status = CSRStatus(fields=[
            CSRField("fresh", size=1, description="When set, the rand register contains a fresh set of bits to be read; cleaned by reading the `rand` register")
        ])
        shift_rand = Signal()
        rand = Signal(ro_elements-1)

        dwell_now = Signal()   # level-signal to indicate dwell or measure
        sample_now = Signal()  # single-sysclk wide pulse to indicate sampling time (after leaving dwell)
        rand_cnt = Signal(max=self.rand.size+1)
        # keep track of how many bits have been shifted in since the last read-out
        self.sync += [
            If(self.rand.we,
               self.status.fields.fresh.eq(0),
               self.rand.fields.rand.eq(0xDEADBEEF),
            ).Else(
                If(shift_rand,
                    If(rand_cnt < self.rand.size+1, # +1 because the very first bit never got sample entropy, just dwell, so we throw it away
                       rand_cnt.eq(rand_cnt + 1),
                    ).Else(
                       self.rand.fields.rand.eq(rand),
                       self.status.fields.fresh.eq(1),
                       rand_cnt.eq(0),
                    )
                ).Else(
                    self.status.fields.fresh.eq(self.status.fields.fresh),
                    self.rand.fields.rand.eq(self.rand.fields.rand),
                ),
            )
        ]

        # build a set of `element` rings, with `stage` stages
        self.trng_slow = Signal()
        for element in range(ro_elements):
            setattr(self, "ro_elem" + str(element), Signal(ro_stages+1))
            setattr(self, "ro_samp" + str(element), Signal())
            for stage in range(ro_stages):
                stagename = 'RINGOSC_E' + str(element) + '_S' + str(stage)
                self.specials += Instance("LUT1", name=stagename, p_INIT=1,
                    i_I0=getattr(self, "ro_elem" + str(element))[stage],
                    o_O=getattr(self, "ro_elem" + str(element))[stage+1],
                    attr=("KEEP", "DONT_TOUCH"),
                )
                # add platform command to disable timing closure on ring oscillator paths
                platform.add_platform_command("set_disable_timing -from I0 -to O [get_cells " + stagename + "]")
                platform.add_platform_command("set_false_path -through [get_pins " + stagename + "/O]")
            # add "gang" sampler to pull out extra entropy during dwell mode
            if element != 32: # element 32 is a special case, handled at end of loop
                self.specials += Instance("FDCE", name='FDCE_E' + str(element),
                    i_D=getattr(self, "ro_elem" + str(element))[0],
                    i_C=ClockSignal(),
                    i_CE=self.ctl.fields.gang,
                    i_CLR=0,
                    o_Q=getattr(self, "ro_samp" + str(element))
                )
            if (element != 0) & (element != 32): # element 0 is a special case, handled at end of loop
                self.sync += [
                    If(sample_now,
                       rand[element].eq(rand[element-1]),
                    ).Else(
                        rand[element].eq(rand[element] ^ (getattr(self, "ro_samp" + str(element)) & self.ctl.fields.gang)),
                    )
                ]
            # close feedback loop with enable gate
            setattr(self, "ro_fbk" + str(element), Signal())
            self.comb += [
                getattr(self, "ro_fbk" + str(element)).eq(getattr(self, "ro_elem" + str(element))[ro_stages]
                                                          & self.ctl.fields.ena),
            ]

        # build the input tap
        self.specials += Instance("FDCE", name='FDCE_E32',
            i_D=getattr(self, "ro_elem32")[0],
            i_C=ClockSignal(),
            i_CE=1, # element 32 is not part of the gang, it's the output element of the "big loop"
            i_CLR=0,
            o_Q=getattr(self, "ro_samp32")
        )
        self.sync += [
            If(sample_now,
                rand[0].eq(getattr(self, "ro_samp32")), # shift in sample entropy from a tap on the one stage that's not already wired to a gang mixer
            ).Else(
                rand[0].eq(rand[0] ^ (getattr(self, "ro_samp0") & self.ctl.fields.gang)),
            )
        ]

        # create the switchable meta-ring by muxing on dwell_now
        for element in range(ro_elements):
            if element < ro_elements-1:
                self.comb += getattr(self, "ro_elem" + str(element))[0]\
                                 .eq(  getattr(self, "ro_fbk" + str(element)) & dwell_now
                                     | getattr(self, "ro_fbk" + str(element + 1)) & ~dwell_now),
            else:
                self.comb += getattr(self, "ro_elem" + str(element))[0]\
                                 .eq(  getattr(self, "ro_fbk" + str(element)) & dwell_now
                                     | getattr(self, "ro_fbk" + str(0)) & ~dwell_now),

        self.trng_slow = Signal()
        self.trng_fast = Signal()
        self.sync += [self.trng_fast.eq(self.ro_fbk0), self.trng_slow.eq(rand[0])]

        dwell_cnt = Signal(self.ctl.fields.dwell.size)
        delay_cnt = Signal(self.ctl.fields.delay.size)
        fsm = FSM(reset_state="IDLE")
        self.submodules += fsm
        fsm.act("IDLE",
            If(self.ctl.fields.ena,
                NextState("DWELL"),
                NextValue(dwell_cnt, self.ctl.fields.dwell),
                NextValue(delay_cnt, self.ctl.fields.delay),
            )
        )
        fsm.act("DWELL",
            dwell_now.eq(1),
            If(dwell_cnt > 0,
                NextValue(dwell_cnt, dwell_cnt - 1),
            ).Else(
                shift_rand.eq(1),  # we want to shift randomness after a dwell, otherwise in gang mode rand[0] doesn't get any dwell entropy
                # however, this means after a reset the 1st bit generated won't have the large-ring sample entropy, so always throw that away
                # (this is handled in the shifting loop)
                NextState("DELAY")
            )
        )
        fsm.act("DELAY",
            If(delay_cnt > 0,
                NextValue(delay_cnt, delay_cnt - 1),
            ).Else(
                sample_now.eq(1),
                NextValue(dwell_cnt, self.ctl.fields.dwell),
                NextValue(delay_cnt, self.ctl.fields.delay),
                If(self.ctl.fields.ena,
                    NextState("DWELL"),
                ).Else(
                    NextState("IDLE")
                )
            )
        )

