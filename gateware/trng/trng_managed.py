from migen import *
from migen.genlib.cdc import MultiReg

from litex.soc.interconnect.csr import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect.csr_eventmanager import *

class TrngManagedUser(Module, AutoCSR, AutoDoc):
    def __init__(self):
        self.intro = ModuleDoc("""
Userspace-visible register interface for the TrngManaged core. Must be created as a submodule in
the top-level SoC and passed to TrngManaged as an argument.
        """)
        self.status = CSRStatus(fields=[
            CSRField("ready", size=1, description="When set, indicates that the TRNG interface is capable of generating numbers"),
            CSRField("avail", size=1, description="Indicates that the read FIFO is not empty"),
            CSRField("rdcount", size=10, description="Read fifo pointer"),
            CSRField("wrcount", size=10, description="Write fifo pointer"),
        ])

        self.data = CSRStatus(fields=[
            CSRField("data", size=32, description="Latest random data from the FIFO; only valid if ``avail`` bit is set")
        ])

        self.submodules.ev = EventManager()
        self.ev.avail = EventSourceLevel(description="Triggered anytime there is data available on the user interface")
        self.ev.under = EventSourcePulse(description="Triggered whenever an underrun condition first occurs on the user interface")
        self.ev.finalize()


class TrngManagedPriv(Module, AutoCSR, AutoDoc):
    def __init__(self):
        self.intro = ModuleDoc("""
Kernel-private register interface for the TrngManaged core. Must be created as a submodule in
the top-level SoC and passed to TrngManaged as an argument.
        """)
        self.control = CSRStorage(fields=[
            CSRField("enable", size=1, description="Power on the management interface and auto-fill random numbers"),
            CSRField("ro_dis", size=1, description="When set, disables the ring oscillator as an entropy source"),
            CSRField("av_dis", size=1, description="When set, disables the avalanche generator as an entropy source"),
            CSRField("powersave", size=1, description="When set, TRNGs are automatically turned off until low water mark is hit; when cleared, TRNGs are always on"),
            CSRField("lowmark", size=10, description="Low water mark for re-filling both user and privileged FIFOs", reset=512),
            CSRField("no_check", size=1, description="When set, disables on-line health checking (for power saving)"),
            CSRField("clr_err", size=1, description="Write ``1`` to this bit to clear the ``errors`` register", pulse=True)
        ])

        self.fifo_data = CSRStatus(fields=[
            CSRField("data", size=32, description="Latest random data from the FIFO; only valid if available bit is set")
        ])
        self.fifo_stat = CSRStatus(fields=[
            CSRField("avail", size=1, description="FIFO data is available"),
            CSRField("rdcount", size=10, description="Read fifo pointer"),
            CSRField("wrcount", size=10, description="Write fifo pointer"),
        ])

        self.ro_config = CSRStorage(fields=[
            CSRField("gang", size=1, description="Fold in collective gang entropy during dwell time", reset=1),
            CSRField("dwell", size=20, description="""Prescaler to set dwell-time of entropy collection. 
            Controls the period of how long the oscillators are in a metastable state to collect entropy 
            before sampling. Value encodes the number of sysclk edges to pass during the dwell period.""", reset=100),
            CSRField("delay", size=10, description="""Sampler delay time. Sets the delay between when the small rings
            are merged together, and when the final entropy result is sampled. Value encodes number of sysclk edges
            to pass during the delay period. Delay should be long enough for the signal to propagate around the merged ring,
            but longer times also means more coupling of the deterministic sysclk noise into the rings.""", reset=8)
        ])

        self.errors = CSRStatus(fields=[
            CSRField("underrun", size=10, description="If non-zero, an underrun has occurred. Will count number of underruns up to max field size"),
            CSRField("ro_health", size=1, description="Ring oscillator has failed an on-line health test"),
            CSRField("av_health", size=1, description="Avalanche generator has failed an on-line health test"),
        ])

        self.submodules.ev = EventManager()
        self.ev.avail = EventSourceLevel(description="Triggered anytime there is data available on the privileged interface")
        self.ev.error = EventSourcePulse(description="Triggered whenever an error condition first occurs on the privileged interface")
        self.ev.finalize()


class TrngManaged(Module, AutoCSR, AutoDoc):
    def __init__(self, platform, priv, user):
        self.intro = ModuleDoc("""
TrngManaged wraps a management interface around two TRNG sources for the Precursor platform.
The management interface provides:

  - FIFOs that are automatically filled, to supply limited amounts of entropy in fast bursts
  - Detection of underrun conditions in the FIFOs
  - A separate, dedicated kernel page for kernel processes to acquire TRNGs
  - Basic health monitoring of TRNG sources
  - Combination/selection of both external (avalanche, XADC-based) and internal (ring oscillator based) sources

Installing TrngManaged overrides the Litex-default Info XADC interface. Therefore it cannot be
instantiated concurrently with the XADC in the Info block. It also is intended to manage
the ring oscillator, so e.g. stand-alone TrngRingOscV2's are not reccommended to be installed in
the same design.
        """)

        self.submodules.ringosc = TrngRingOscV2Managed(platform)
        # pass-through config and mangamement signals to the RO
        ro_rand = Signal(32)
        ro_fresh = Signal()
        ro_rand_read = Signal()
        self.comb += [
            self.ringosc.ena.eq(~priv.control.fields.ro_dis & priv.control.fields.enable),
            self.ringosc.gang.eq(priv.ro_config.fields.gang),
            self.ringosc.dwell.eq(priv.ro_config.fields.dwell),
            self.ringosc.delay.eq(priv.ro_config.fields.delay),
            ro_rand.eq(self.ringosc.rand_out),
            ro_fresh.eq(self.ringosc.fresh),
            self.ringosc.rand_read.eq(ro_rand_read),
        ]

        #### now build two fifos, one for user, one for priv
        # At a width of 32 bits, an 36kiB fifo is 1024 entries deep

        ## priv fifo
        priv_fifo_full = Signal()
        priv_fifo_empty = Signal()
        priv_fifo_wren = Signal()
        priv_fifo_din = Signal(32)
        priv_fifo_rden = Signal()
        priv_fifo_dout = Signal(32)
        priv_fifo_rdcount = Signal(10)
        priv_fifo_rderr = Signal()
        priv_fifo_wrcount = Signal(10)
        self.specials += Instance("FIFO_SYNC_MACRO",
            p_DEVICE="7SERIES",
            p_FIFO_SIZE="36Kb",
            p_DATA_WIDTH=32,
            p_ALMOST_EMPTY_OFFSET=8,
            p_ALMOST_FULL_OFFSET=1024-8,
            p_DO_REG=0,
            i_CLK=ClockSignal(),
            i_RST=ResetSignal(),
            o_FULL=priv_fifo_full,
            o_EMPTY=priv_fifo_empty,
            i_WREN=priv_fifo_wren,
            i_DI=priv_fifo_din,
            i_RDEN=priv_fifo_rden,
            o_DO=priv_fifo_dout,
            o_RDCOUNT=priv_fifo_rdcount,
            o_RDERR=priv_fifo_rderr,
            o_WRCOUNT=priv_fifo_wrcount,
        )
        self.comb += [
            priv.ev.avail.trigger.eq(~priv_fifo_empty),
            priv.ev.error.trigger.eq(priv_fifo_rderr), # this should only pulse when RE is triggered; it should not be stuck at a level
            If(~priv_fifo_empty,
                priv_fifo_rden.eq(priv.fifo_data.re),
                priv.fifo_data.fields.data.eq(priv_fifo_dout),
            ).Else(
                priv.fifo_data.fields.data.eq(0xDEADBEEF),
            ),
            priv.fifo_stat.fields.rdcount.eq(priv_fifo_rdcount),
            priv.fifo_stat.fields.wrcount.eq(priv_fifo_wrcount),
            priv.fifo_stat.fields.avail.eq(~priv_fifo_empty),
        ]

class TrngRingOscV2Managed(Module, AutoCSR, AutoDoc):
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
        ### to/from management interface
        self.ena = Signal()
        self.gang = Signal()
        self.dwell = Signal(20)
        self.delay = Signal(10)
        self.rand_out = Signal(32)
        self.rand_read = Signal() # pulse one cycle to indicate rand_out has been read
        self.fresh = Signal()

        devstr = platform.device.split('-')
        device_root = devstr[0]
        if devstr[1][0:3] != 'xc7':
            print("TrngRingOscV2 only supported for 7-Series devices")

        self.trng_raw = Signal()  # raw TRNG output bitstream
        self.trng_out_sync = Signal()  # single-bit output, synchronized to sysclk

        ## NOTE: for managed mode, don't change ro_elements or ro_stages. We assume 32 bit settings.
        ro_elements = 33  # needs to be an odd number, and larger than the size of `self.rand`. 33 is probably optimal.
        ro_stages = 1     # needs to be an odd number. 1 is probably optimal, but coded to accept other numbers, too.

        shift_rand = Signal()
        rand = Signal(ro_elements-1)

        dwell_now = Signal()   # level-signal to indicate dwell or measure
        sample_now = Signal()  # single-sysclk wide pulse to indicate sampling time (after leaving dwell)
        rand_cnt = Signal(max=self.rand_out.nbits+1)
        # keep track of how many bits have been shifted in since the last read-out
        self.sync += [
            If(self.rand_read,
               self.fresh.eq(0),
               self.rand_out.eq(0xDEADBEEF),
            ).Else(
                If(shift_rand,
                    If(rand_cnt < self.rand_out.nbits+1, # +1 because the very first bit never got sample entropy, just dwell, so we throw it away
                       rand_cnt.eq(rand_cnt + 1),
                    ).Else(
                       self.rand_out.eq(rand),
                       self.fresh.eq(1),
                       rand_cnt.eq(0),
                    )
                ).Else(
                    self.fresh.eq(self.fresh),
                    self.rand_out.eq(self.rand_out),
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
                    i_CE=self.gang,
                    i_CLR=0,
                    o_Q=getattr(self, "ro_samp" + str(element))
                )
            if (element != 0) & (element != 32): # element 0 is a special case, handled at end of loop
                self.sync += [
                    If(sample_now,
                       rand[element].eq(rand[element-1]),
                    ).Else(
                        rand[element].eq(rand[element] ^ (getattr(self, "ro_samp" + str(element)) & self.gang)),
                    )
                ]
            # close feedback loop with enable gate
            setattr(self, "ro_fbk" + str(element), Signal())
            self.comb += [
                getattr(self, "ro_fbk" + str(element)).eq(getattr(self, "ro_elem" + str(element))[ro_stages]
                                                          & self.ena),
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
                rand[0].eq(rand[0] ^ (getattr(self, "ro_samp0") & self.gang)),
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

        dwell_cnt = Signal(self.dwell.nbits)
        delay_cnt = Signal(self.delay.nbits)
        fsm = FSM(reset_state="IDLE")
        self.submodules += fsm
        fsm.act("IDLE",
            If(self.ena,
                NextState("DWELL"),
                NextValue(dwell_cnt, self.dwell),
                NextValue(delay_cnt, self.delay),
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
                NextValue(dwell_cnt, self.dwell),
                NextValue(delay_cnt, self.delay),
                If(self.ena,
                    NextState("DWELL"),
                ).Else(
                    NextState("IDLE")
                )
            )
        )

