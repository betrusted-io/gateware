from re import S
from migen import *
from migen.genlib.cdc import MultiReg

from litex.soc.interconnect.csr import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect.csr_eventmanager import *

from deps.gateware.gateware.chacha.chacha import ChaChaConditioner

class TrngManagedKernel(Module, AutoCSR, AutoDoc):
    def __init__(self):
        self.intro = ModuleDoc("""
kernel-visible register interface for the TrngManaged core. Must be created as a submodule in
the top-level SoC and passed to TrngManaged as an argument.
        """)
        self.status = CSRStatus(fields=[
            CSRField("ready", size=1, description="When set, indicates that the TRNG interface is capable of generating numbers"),
            CSRField("avail", size=1, description="Indicates that the read FIFO is not empty"),
            CSRField("rdcount", size=10, description="Read fifo pointer"),
            CSRField("wrcount", size=10, description="Write fifo pointer"),
        ])

        self.data = CSRStatus(fields=[
            CSRField("data", size=32, description="(DEPRECATED - use `urandom`) Latest random data from the FIFO; \
                only valid if ``avail`` bit is set. This interface is preserved primarily for test programs to access\
                raw TRNG data, but normal kernel code should never use this port, due to a race condition with the\
                automatic reseeding algorithm for urandom.")
        ])

        self.urandom = CSRStatus(name="urandom", size=32, description="Unlimited random numbers, output from the ChaCha conditioner. Generally, you want to use this.")
        self.urandom_valid = CSRStatus(size=1, description="Set when `urandom` is valid. Always check before taking `urandom`")

        self.submodules.ev = EventManager()
        self.ev.avail = EventSourceLevel(description="Triggered anytime there is data available on the kernel interface")
        self.ev.error = EventSourcePulse(description="Triggered whenever an underrun condition first occurs on the kernel interface")
        self.ev.finalize()


class TrngManagedServer(Module, AutoCSR, AutoDoc):
    def __init__(self, ro_cores=4):
        self.intro = ModuleDoc("""
server register interface for the TrngManaged core. Must be created as a submodule in
the top-level SoC and passed to TrngManaged as an argument.

Characterization data for the powerdelay parameter:

.. image:: https://raw.githubusercontent.com/betrusted-io/gateware/master/gateware/trng/v_ava_poweron.png
Above shows power-enable to full regulator stabilization in ~47ms

.. image:: https://raw.githubusercontent.com/betrusted-io/gateware/master/gateware/trng/v_noise_stable.png
Above shows power-enable to noise generation in much less than 20ms

Note that regulator stability isn't a pre-requisite for noise generation -- the avalanche noise
breakdown process proceeds over a wide voltage range.

50ms seems quite safe; we have sufficient voltage to cause noise generation after about 10ms, but
voltage is fully regulated by 50ms. If a faster power-on is desired, one could program the delay
to as little as 15-20ms and still probably be quite safe.
        """)
        self.control = CSRStorage(fields=[
            CSRField("enable", size=1, description="Power on the management interface and auto-fill random numbers", reset=1),
            CSRField("ro_dis", size=1, description="When set, disables the ring oscillator as an entropy source", reset=0),
            CSRField("av_dis", size=1, description="When set, disables the avalanche generator as an entropy source", reset=0),
            CSRField("powersave", size=1, description="When set, TRNGs are automatically turned off until the low water mark is hit; when cleared, TRNGs are always on", reset=1),
            CSRField("clr_err", size=1, description="Write ``1`` to this bit to clear the ``errors`` register", pulse=True)
        ])

        self.data = CSRStatus(fields=[
            CSRField("data", size=32, description="Latest random data from the FIFO; only valid if available bit is set\
                Unlike the kernel's raw data port, this one is safe to use as there is no race condition with the reseeding algorithm.\
                That being said, it is preferred to use `urandom` because the Conditioner protects against unanticipated dropouts in the raw TRNG stream.")
        ])
        self.status = CSRStatus(fields=[
            CSRField("avail", size=1, description="FIFO data is available"),
            CSRField("rdcount", size=10, description="Read fifo pointer"),
            CSRField("wrcount", size=10, description="Write fifo pointer"),
            CSRField("full", size=1, description="Both kernel and server FIFOs have been topped off"),
            CSRField("chacha_ready", size=1, description="Chacha conditioner is seeded and ready"),
        ])

        # raw data:
        # https://github.com/betrusted-io/gateware/blob/master/gateware/trng/v_noise_stable.png
        # https://github.com/betrusted-io/gateware/blob/master/gateware/trng/v_ava_poweron.png
        default_samples = 32
        self.av_config = CSRStorage(fields=[
            CSRField("powerdelay", size=20, description="Delay in microseconds for avalanche generator to stabilize", reset=50000),
            CSRField("samples", size=8, description="Number of samples to fold into a single result. Smaller values increase rate but decrease quality. Default is {}.".format(default_samples), reset=default_samples),
            CSRField("test", size=1, description="When set, puts the generator into test mode -- full-size, raw ADC samples are directly placed into the FIFO at full rate, creating a 'virtual oscilloscope' snapshot of the avalanche generator waveform."),
            CSRField("required", size=1, description="Require avalanche generator to work in order for boot (used by the synthetic test bench as this self-test 'runs long' compared to the other operations)"),
        ])

        self.ro_config = CSRStorage(fields=[
            CSRField("gang", size=1, description="Fold in collective gang entropy during dwell time", reset=1),
            CSRField("dwell", size=12, description="""Prescaler to set dwell-time of entropy collection.
            Controls the period of how long the oscillators are in a metastable state to collect entropy
            before sampling. Value encodes the number of sysclk edges to pass during the dwell period.""", reset=100),
            CSRField("delay", size=10, description="""Sampler delay time. Sets the delay between when the small rings
            are merged together, and when the final entropy result is sampled. Value encodes number of sysclk edges
            to pass during the delay period. Delay should be long enough for the signal to propagate around the merged ring,
            but longer times also means more coupling of the deterministic sysclk noise into the rings.""", reset=4),
            CSRField("fuzz", size=1, description="""Modulate the `delay`/`dwell` parameter slightly from run-to-run,
            based on previous run's random values. May help to break ring oscillator resonances trained by the delay/dwell periodicity.""", reset=1),
            CSRField("oversampling", size=8, description="""Number of stages to oversample entropy. Normally, each bit is just
            sampled and shifted once (so 32 times for 32-bit word). Each increment of oversampling will add another stage.""", reset=3)
        ])

        # Some defaults are needed to boot the system correctly.
        # These minimums need to be revisited -- entropy is not additive across XOR. it's much more complicated:
        # https://crypto.stackexchange.com/questions/84399/formula-for-bits-of-entropy-per-bit-when-combining-bits-with-xor
        # Avalanche:
        #    The minimum amount of entropy per sample should be ~0.5 bits per sample, as 64 samples are mixed together for 32 bits of output.
        #    For an α of 2^-20, eg, a one-in-a-million chance, the cutoff value for the reptest should be 1 + ceil(20/0.5) = 41.
        #    For the adaptive test, should be 410.
        # Ring oscillator:
        #    Let's shoot for an initial minimum entropy of 0.3 bits per core giving a max repcount of 67
        #    Makes for a run count of 67; 7-bits used to hold the max value
        #    For the adaptive test, let's start with 840 -- that's around 0.4 bits of entropy per core
        # These can be tightened up after boot, but we prefer a looser bound initially to avoid the boot locking up unless we have a truly catastrophic TRNG failure.
        av_repcount_bits=7  # based on a conservative upper bound
        av_adaptive_bits=9  # set by NIST requirement of 512 for non-binary
        ro_repcount_bits=7  # based on a conservative upper bound
        ro_adaptive_bits=10 # this is set by NIST requirements of 1024 for binary
        ro_maxruns=4 # maximum number of runs to count on the RO maxruns
        self.av_nist = CSRStorage(fields=[
            CSRField("repcount_cutoff", av_repcount_bits, description="Sets the `C` (cutoff) parameter in the NIST repetition count test for the avalanche generator", reset=41),
            CSRField("adaptive_cutoff", av_adaptive_bits, description="Sets the `C` (cutoff) parameter in the NIST adaptive proportion test for the avalanche generator", reset=410),
        ])
        self.ro_nist = CSRStorage(fields=[
            CSRField("repcount_cutoff", ro_repcount_bits, description="Sets the `C` (cutoff) parameter in the NIST repetition count test for the ringosc generator", reset=67),
            CSRField("adaptive_cutoff", ro_adaptive_bits, description="Sets the `C` (cutoff) parameter in the NIST adaptive proportion test for the ringosg generator", reset=840),
        ])
        self.underruns = CSRStatus(fields=[
            CSRField("server_underrun", size=10, description="If non-zero, a server underrun has occurred. Will count number of underruns up to max field size"),
            CSRField("kernel_underrun", size=10, description="If non-zero, a kernel underrun has occurred. Will count number of underruns up to max field size"),
        ])
        self.nist_errors = CSRStatus(fields=[
            CSRField("av_repcount", size=2, description="Indicates a failure in a repcount test for one of two avalanche generators"),
            CSRField("av_adaptive", size=2, description="Indicates a failure in a adaptive proportion test for one of two avalanche generators"),
            CSRField("ro_repcount", size=4, description="Indicates a failure in the repcount test for the ring oscillators"),
            CSRField("ro_adaptive", size=4, description="Indicates a failure in the adaptive proportion test for the ring oscillators"),
            CSRField("ro_miniruns", size=4, description="Indicates a failure in the miniruns test"),
        ])
        self.nist_ro_stat0 = CSRStatus(fields=[
            CSRField("adap_b", size=ro_adaptive_bits, description="last window's `b` value for core 0 adaptive proportion test"),
            CSRField("fresh", description="when `1`, adaptive proprotion b has been updated since last read"),
            CSRField("rep_b", size=ro_repcount_bits, description="max `b` value for core 0 repetition count test"),
        ])
        self.nist_ro_stat1 = CSRStatus(fields=[
            CSRField("adap_b", size=ro_adaptive_bits, description="last window's `b` value for core 1 adaptive proportion test"),
            CSRField("fresh", description="when `1`, adaptive proprotion b has been updated since last read"),
            CSRField("rep_b", size=ro_repcount_bits, description="max `b` value for core 0 repetition count test"),
        ])
        self.nist_ro_stat2 = CSRStatus(fields=[
            CSRField("adap_b", size=ro_adaptive_bits, description="last window's `b` value for core 2 adaptive proportion test"),
            CSRField("fresh", description="when `1`, adaptive proprotion b has been updated since last read"),
            CSRField("rep_b", size=ro_repcount_bits, description="max `b` value for core 0 repetition count test"),
        ])
        self.nist_ro_stat3 = CSRStatus(fields=[
            CSRField("adap_b", size=ro_adaptive_bits, description="last window's `b` value for core 3 adaptive proportion test"),
            CSRField("fresh", description="when `1`, adaptive proprotion b has been updated since last read"),
            CSRField("rep_b", size=ro_repcount_bits, description="max `b` value for core 0 repetition count test"),
        ])
        self.nist_av_stat0 = CSRStatus(fields=[
            CSRField("adap_b", size=ro_adaptive_bits, description="last window's `b` value for core 0 adaptive proportion test"),
            CSRField("fresh", description="when `1`, adaptive proprotion b has been updated since last read"),
            CSRField("rep_b", size=ro_repcount_bits, description="max `b` value for core 0 repetition count test"),
        ])
        self.nist_av_stat1 = CSRStatus(fields=[
            CSRField("adap_b", size=ro_adaptive_bits, description="last window's `b` value for core 0 adaptive proportion test"),
            CSRField("fresh", description="when `1`, adaptive proprotion b has been updated since last read"),
            CSRField("rep_b", size=ro_repcount_bits, description="max `b` value for core 0 repetition count test"),
        ])

        mr_max=2047 # max value of a minirun
        # Attempts to derive thresholds on this that are sane:
        # https://docs.google.com/spreadsheets/d/1_2r9GkMPnQaNDT1rO6dodm4zKR1j2ADs3-et-QkkGiw/edit?usp=sharing
        # You can also do a chi-square test on the data, but this is too much math for an integrated hardware min/max test
        # Thus we do a per-bin min/max based on an expected distribution of the run lengths
        # Calculate for p = 1/2**20 chance of it going outside the value, z-score=4.79
        # again, these basically just catch if the RO is horribly bad, can be tightened up at run-time.
        #mins = {1:435, 2:189, 3:77,  4:26,  5:5} # these are 2^-20
        #maxs = {1:589, 2:322, 3:179, 4:101, 5:59}
        mins = {1:440, 2:193, 3:80,  4:29,  5:7} # these are 2^-18
        maxs = {1:584, 2:318, 3:175, 4:99,  5:57}
        for run in range(1, ro_maxruns+1):
            setattr(self, 'ro_runslimit'+str(run), CSRStorage(name='ro_runslimit'+str(run), fields=[
                CSRField("min", size=log2_int(mr_max+1), description="Minimum runs limit for runs of length {}".format(run), reset=mins[run]),
                CSRField("max", size=log2_int(mr_max+1), description="Minimum runs limit for runs of length {}".format(run), reset=maxs[run]),
            ]))

        self.submodules.ev = EventManager()
        self.ev.avail = EventSourceLevel(description="Triggered anytime there is data available on the server interface")
        self.ev.error = EventSourcePulse(description="Triggered whenever an error condition first occurs on the server interface")
        self.ev.health = EventSourcePulse(description="Triggered whenever a health event first occurs")
        self.ev.excursion0 = EventSourcePulse(description="Triggered by a failure in the avalanche generator core 0 on-line excursion test")
        self.ev.excursion1 = EventSourcePulse(description="Triggered by a failure in the avalanche generator core 1 on-line excursion test")

        # instantiate the test modules in this block so the CSRs are mapped to this space, but wire up inside the manager
        self.submodules.av_repcount0 = RepCountTest(cutoff_max=(2**av_repcount_bits)-1, nbits=5)
        self.submodules.av_repcount1 = RepCountTest(cutoff_max=(2**av_repcount_bits)-1, nbits=5)
        self.submodules.av_adaprop0 = AdaptivePropTest(cutoff_max=(2**av_adaptive_bits)-1, nbits=5)
        self.submodules.av_adaprop1 = AdaptivePropTest(cutoff_max=(2**av_adaptive_bits)-1, nbits=5)
        for core in range(ro_cores):
            setattr(self.submodules, 'ro_rep' + str(core), RepCountTest(cutoff_max=(2**ro_repcount_bits)-1, nbits=1))
            setattr(self.submodules, 'ro_adp' + str(core), AdaptivePropTest(cutoff_max=(2**ro_adaptive_bits)-1, nbits=1))
            setattr(self.submodules, 'ro_run' + str(core), MiniRuns(maxrun=ro_maxruns, maxwindow=mr_max))
        self.submodules.av_excursion0 = ExcursionTest()
        self.submodules.av_excursion1 = ExcursionTest()
        self.comb += [
            self.ev.excursion0.trigger.eq(self.av_excursion0.failure),
            self.ev.excursion0.trigger.eq(self.av_excursion1.failure)
        ]
        self.ready = CSRStatus(fields=[
            CSRField("av_excursion", size=2, description="ready bits from the excursion test"),
            CSRField("av_adaprop", size=2, description="ready bits from the adaptive proportion test"),
            CSRField("ro_adaprop", size=4, description="ready bits from the adaptive proportion test"),
        ])

        self.ev.finalize()

        # conditioner setup
        self.chacha = CSRStorage(fields=[
            CSRField("reseed_interval", size=12, description="How many ChaCha blocks to generate before automatically rotating the key pool", reset=2),
            CSRField("selfmix_interval", size=16, description="How many sysclk cycles in between automatic round advancement (adjust to reduce standby power)", reset=200),
            CSRField("selfmix_ena", size=1, description="Enable self mixing feature", reset=1),
        ])
        self.more_seed = CSRStorage(name="seed", size=32, description="Extra data to be rotated into the seed pool. This is supplemental to the automatically seeded TRNG data. Data is committed to the pool immediately upon write.")
        self.urandom = CSRStatus(name="urandom", size=32, description="Unlimited random numbers, output from the ChaCha conditioner. Generally, you want to use this.")
        self.urandom_valid = CSRStatus(size=1, description="Set when `urandom` is valid. Always check before taking `urandom`")
        self.test = CSRStorage(fields=[
            CSRField("simultaneous", size=1, description="Force a simultaneous advance of kernel/user urandom. Used to exercise a corner case in testing. Not harmful in production, just wasteful.", pulse=True),
        ])

class RepCountTest(Module, AutoDoc):
    def __init__(self, cutoff_max=32, nbits=1):
        self.intro = ModuleDoc("""Repetition Count Test (per NIST SP 800-90B sec 4.4.1)

Let next() yield the next sample from the noise source.  Given a continuous sequence of noise
source samples, and the cutoff value C, the repetition count test is performed as follows:

 1.A=next()
 2.B=1
 3.X=next()
 4.If (X==A),
      B=B+1
      If (B ≥ C), signal a failure.
   Else:
      A=X
      B=1
 5. Repeat Step 3.

 * `cutoff_max` specifies the maximum C value that can be programmed.
 * `nbits` specifies the width of the TRNG sample

 This implementation does not directly wire all bits to CSRs, as for the single-bit
 generators we will need >100 such tests. A higher-level module will be responsible
 for multiplexing all the values to a CSR interface.
        """)
        # inputs
        self.cutoff = Signal(max=cutoff_max+1)
        self.sample = Signal()  # strobe to sample a random value. One sample per cycle that this strobe is high.
        self.rand = Signal(nbits) # a connection to the source of entropy to sample
        self.reset = Signal()
        # output
        self.failure = Signal() # latches ON until reset. Also used in its inverse form to indicate a "ready" status (only valid after some run time, which is selected by the higher level logic).
        self.b = Signal(max=cutoff_max+1) # monitor the b output

        a = Signal(nbits)
        b = Signal(max=cutoff_max+1)
        self.sync += [ # latch the max observed "b" value for diagnostic purposes
            If(self.reset,
                self.b.eq(0),
            ).Elif(self.b < b,
                self.b.eq(b)
            ).Else(
                self.b.eq(self.b)
            )
        ]

        fsm = FSM(reset_state="START")
        self.submodules += fsm
        fsm.act("START",
            NextValue(self.failure, 0),
            If(self.sample,
                NextValue(a, self.rand),
                NextValue(b, 0),
                NextState("ITERATE"),
            )
        )
        fsm.act("ITERATE",
            If(self.reset,
                NextState("START"),
                NextValue(self.failure, 0),
            ).Else(
                If(b >= self.cutoff,
                    NextValue(self.failure, 1)
                ),
                If(self.sample,
                    If(self.rand == a,
                        If(b+1 <= cutoff_max,
                            NextValue(b, b+1),
                        )
                    ).Else(
                        NextValue(a, self.rand),
                        NextValue(b, 0),
                    )
                )
            )
        )

class AdaptivePropTest(Module, AutoDoc):
    def __init__(self, cutoff_max=32, nbits=1):
        self.intro = ModuleDoc("""Adaptive Proportion Test (per NIST SP 800-90B sec 4.4.2)

Let next() yield the next sample from the noise source. Given a continuous sequence of noise samples,
the cutoff value C and the window size W, the adaptive proportion test is performed as follows:

1. A=next()
2. B=1.
3. For i=1 to W–1
       If (A == next()) then B=B+1
       If (B ≥ C) then signal a failure
4.Go to Step 1.

The cutoff value C is chosen such that the probability of observing C or more identical samples in a window size of W is at most α.

 * `cutoff_max` specifies the maximum C value that can be programmed.
 * `nbits` specifies the width of the TRNG sample

 This implementation also does not infer CSRs, to allow for aggregation of multi-bank values.
            """)
        if nbits == 1: # per NIST spec
            window_max = 1024
        else:
            window_max = 512

        # inputs
        self.cutoff = Signal(max=cutoff_max+1)
        self.sample = Signal()  # strobe to sample a random value. One sample per cycle that this strobe is high.
        self.rand = Signal(nbits) # a connection to the source of entropy to sample
        self.reset = Signal()
        self.enabled = Signal() # used to reset the "ready" signal
        self.b_read = Signal() # indicate that the "b" value was read, single cycle pulse
        # output
        self.failure = Signal() # latches ON until reset
        self.ready = Signal() # indicates oscillator has passed at least one test iteration
        self.b = Signal(max=cutoff_max+1)  # monitor the "b" variable externally
        self.b_fresh = Signal() # indicates a new value since last read of b

        a = Signal(nbits)
        b = Signal(max=cutoff_max+1)
        w = Signal(max=window_max+1)
        b_updated = Signal()

        self.sync += [
            If(b_updated,
                self.b_fresh.eq(1),
            ).Elif(self.b_read,
                self.b_fresh.eq(0),
            ).Else(
                self.b_fresh.eq(self.b_fresh)
            )
        ]

        fsm = FSM(reset_state="START")
        self.submodules += fsm
        fsm.act("START",
            If(self.reset | ~self.enabled,
                NextValue(self.ready, 0),
                NextValue(self.failure, 0),
            ),
            If(self.reset,
                NextValue(self.failure, 0),
            ),
            If(self.sample,
                NextValue(a, self.rand),
                NextValue(b, 0),
                NextState("ITERATE"),
                NextValue(w, 0),
            )
        )
        fsm.act("ITERATE",
            If(self.reset,
                NextState("START"),
                NextValue(self.failure, 0),
                NextValue(self.ready, 0),
            ).Elif(w == window_max-1,
                NextState("START"),
                NextValue(self.b, b),
                b_updated.eq(1),
                If(~self.failure & self.enabled,
                    NextValue(self.ready, 1)
                ),
            ).Else (
                If(~self.enabled,
                    NextValue(self.ready, 0)
                ),
                If(b >= self.cutoff,
                    NextValue(self.failure, 1)
                ),
                If(self.sample,
                    NextValue(w, w+1),
                    If(a == self.rand,
                        If(b+1 <= cutoff_max,
                           NextValue(b, b+1)
                        )
                    ),
                )
            )
        )

class ExcursionTest(Module, AutoDoc, AutoCSR):
    def __init__(self, nbits=12):
        self.intro = ModuleDoc("""Excursion Test (supplemental tailored to avalanche noise source)

For a given window w, ensure that the max-min excursion observed is greater than range r.

This block includes CSRs, as there are only two instance expected.
""")
        # inputs
        self.sample = Signal()
        self.rand = Signal(nbits)
        self.power_on = Signal() # when de-asserted, resets the "self.ready" output
        # outputs
        self.ready = Signal()   # signal to other logic that we've passed test at least once
        self.failure = Signal() # connect to an EventSourcePulse()

        self.ctrl = CSRStorage(fields=[
            CSRField("cutoff", size=nbits, description="Minimum excursion required to pass", reset=320), # 78mV amplitude cutoff; 10x min entropy window of 32; 6.4x margin on expected p-p amplitude of 0.5V
            CSRField("reset", size=1, description="Write `1` to reset the system, including any error flags", pulse=True),
            CSRField("window", size=(32 - (nbits + 1)), description="Number of samples over which to measure", reset=200), # we'd expect about 60 transitions in this period
        ])
        self.stat = CSRStatus(fields=[
            CSRField("min", size=nbits, description="Minimum of last window"),
            CSRField("max", size=nbits, description="Maximum of last window"),
        ])
        self.last_err = CSRStatus(fields=[
            CSRField("min", size=nbits, description="Minimum of last error window"),
            CSRField("max", size=nbits, description="Maximum of last error window"),
        ])

        failing = Signal()
        failing_r = Signal()
        self.sync += [
            failing_r.eq(failing),
            self.failure.eq(~failing_r & failing)
        ]

        w = Signal(self.ctrl.fields.window.size)
        min = Signal(nbits, reset=((2**nbits)-1))
        max = Signal(nbits, reset=0)
        cur_min = Signal(nbits)
        cur_max = Signal(nbits)
        err_min = Signal(nbits)
        err_max = Signal(nbits)
        self.comb += [
            self.stat.fields.min.eq(cur_min),
            self.stat.fields.max.eq(cur_max),
            self.last_err.fields.min.eq(err_min),
            self.last_err.fields.max.eq(err_max),
        ]
        fsm = FSM(reset_state="OFF")
        self.submodules += fsm
        fsm.act("OFF",
            If(~self.power_on,
                NextValue(self.ready, 0)
            ).Else(
                NextValue(w, self.ctrl.fields.window),
                NextValue(min, (2**nbits)-1),
                NextValue(max, 0),
                NextState("RUN"),
            )
        )
        fsm.act("RUN",
            If(~self.power_on | self.ctrl.fields.reset,
                NextValue(self.ready, 0),
                NextState("OFF"),
            ).Else(
                If(w == 0,
                    If(max - min < self.ctrl.fields.cutoff,
                        failing.eq(1),
                        NextValue(err_min, min),
                        NextValue(err_max, max),
                        NextValue(self.ready, 0),
                    ).Else(
                        NextValue(self.ready, 1),
                    ),
                    NextValue(cur_min, min),
                    NextValue(cur_max, max),
                    NextValue(w, self.ctrl.fields.window),
                    NextValue(min, (2**nbits)-1),
                    NextValue(max, 0),
                ).Else(
                    If(self.sample,
                        NextValue(w, w-1),
                        If(self.rand < min,
                            NextValue(min, self.rand)
                        ),
                        If(self.rand > max,
                            NextValue(max, self.rand)
                        )
                    )
                )
            )
        )


class MiniRuns(Module, AutoDoc, AutoCSR):
    def __init__(self, maxrun=5, maxwindow=2047): # maxwindow should be 2**n - 1
        self.maxrun = maxrun
        self.intro = ModuleDoc("""Miniature Runs Test (supplemental tailored to ring oscillator source)

For a given window w, count the number of runs (e.g., 000/111 each count as a run of 3) of varying
lengths that have occurred.

Automated alarms are based on shared min/max thresholds that need to be mapped in via a higher level
CSR block.
""")
        # inputs
        self.sample = Signal()
        self.rand = Signal()
        self.power_on = Signal() # when de-asserted, resets the counts
        self.runs_fail = Signal(maxrun)
        self.reset_failure = Signal()
        for run in range(1, maxrun+1):
            setattr(self, 'runs_min'+str(run), Signal(max=maxwindow+1))
            setattr(self, 'runs_max'+str(run), Signal(max=maxwindow+1))

        # outputs
        self.failure = Signal()

        self.ctrl = CSRStorage(fields=[
            CSRField("window", size=log2_int(maxwindow+1), description="Number of samples over which to measure. Must be less than {}, or else undefined behavior occurs".format(maxwindow), reset=(maxwindow//2)),
        ])
        self.fresh = CSRStatus(size=maxrun, description="The current data corresponding to a runlength of (bitposition +1) has been updated at least once since the last readout of any register")

        # we need to grab one more than the max run count, in order to determine if an all-1's or all-0's register is exactly maxcount, or longer
        shifter = Signal(maxrun+1)
        shifter_ready = Signal()
        shifter_initcount = Signal(max=maxrun+1)
        w = Signal(max=maxwindow+1, reset=0)
        window_end = Signal()
        self.sync += [
            If(self.sample,
                shifter.eq(Cat(shifter[1:], self.rand)) # this shifts in from the MSB, discarding the LSB
            ),
            # don't start counting runs until we've shifted in at least maxcount bits
            If(~self.power_on,
                shifter_ready.eq(0),
                shifter_initcount.eq(maxrun+1)
            ).Else(
                If(shifter_initcount > 0,
                    shifter_initcount.eq(shifter_initcount - 1),
                    shifter_ready.eq(0)
                ).Else(
                    shifter_ready.eq(1),
                    shifter_initcount.eq(shifter_initcount),
                )
            ),
            # build the window counter
            If(~self.power_on,
                w.eq(0),
                window_end.eq(0),
            ).Else(
                If(shifter_ready & self.sample,
                    If(w < self.ctrl.fields.window,
                        w.eq(w+1),
                        window_end.eq(0)
                    ).Else(
                        w.eq(0),
                        window_end.eq(1)
                    )
                )
            ),
            # aggregate & report failures
            If(self.reset_failure,
                self.failure.eq(0)
            ).Else(
                If(self.runs_fail != 0,
                    self.failure.eq(1)
                ).Else(
                    self.failure.eq(self.failure)
                )
            )
        ]
        for run in range(1, maxrun+1):
            setattr(self, 'count'+str(run), CSRStatus(size=log2_int(maxwindow+1), name="count"+str(run), description="Count of sequence length {} runs seen in the past window".format(run)))
            setattr(self, 'runcount'+str(run), Signal(log2_int(maxwindow+1)))
            self.comb += [
                self.runs_fail[run-1].eq(
                    ((getattr(self, 'count'+str(run)).status < getattr(self, 'runs_min'+str(run)) ) |
                     (getattr(self, 'count'+str(run)).status > getattr(self, 'runs_max'+str(run)) )
                    ) & (self.fresh.status != 0) # if any entries are 'fresh', all have actually been updated, but some may have been read out by the OS
                )
            ]
            self.sync += [
                If(~self.power_on,
                    getattr(self, 'runcount'+str(run)).eq(0)
                ).Elif(shifter_ready,
                    If((w >= self.ctrl.fields.window) & self.sample,
                        # snapshot the runcount, and note the freshness
                        getattr(self, 'count'+str(run)).status.eq(getattr(self, 'runcount'+str(run))),
                        self.fresh.status[run-1].eq(1),
                    ).Else(
                        # save the current count, but retire the freshbit if any attempt to read acount has happened
                        getattr(self, 'count'+str(run)).status.eq(getattr(self, 'count'+str(run)).status),
                        If(getattr(self, 'count'+str(run)).we,
                            self.fresh.status[run-1].eq(0),
                        ).Else(
                            self.fresh.status[run-1].eq(self.fresh.status[run-1])
                        )
                    ),
                    # increment the runs count, based on the observed pattern as a sliding window across the bitstream
                    If(self.sample,
                        If(window_end,
                            getattr(self, 'runcount'+str(run)).eq(0)
                        ).Elif( ((shifter[:run] == 0) & (shifter[run:run+1] == 1)) |   # case of 0's run
                            ((shifter[:run] == ((2**run) -1)) & (shifter[run:run+1] == 0)),  # case of 1's run
                            getattr(self, 'runcount'+str(run)).eq(getattr(self, 'runcount'+str(run)) + 1)
                        ).Else(
                            getattr(self, 'runcount'+str(run)).eq(getattr(self, 'runcount'+str(run)))
                        )
                    )
                )
            ]


class TrngManaged(Module, AutoCSR, AutoDoc):
    def __init__(self, platform, analog_pads, noise_pads, kernel, server, sim=False, revision='pvt', ro_cores=4):
        if sim == True:
            fifo_depth = 64
            refill_mark = int(fifo_depth // 2)
            almost_full = int(1024 - fifo_depth)
        else:
            fifo_depth = 1024
            refill_mark = int(fifo_depth // 2)  # point at which manager automatically powers on the block and refills the FIFO
            almost_full = int(1024 - fifo_depth)
            if almost_full == 0:
                almost_full = 1 # meet DRC rule for 7-series
        self.intro = ModuleDoc("""
TrngManaged wraps a management interface around two TRNG sources for the Precursor platform.
The management interface provides:

  - FIFOs that are automatically filled, to supply limited amounts of entropy in fast bursts
  - Detection of underrun conditions in the FIFOs
  - A separate, dedicated kernel page for kernel functions to acquire TRNGs
  - Basic health monitoring of TRNG sources
  - Combination/selection of both external (avalanche, XADC-based) and internal (ring oscillator based) sources

Installing TrngManaged overrides the Litex-default Info XADC interface. Therefore it cannot be
instantiated concurrently with the XADC in the Info block. It also is intended to manage
the ring oscillator, so e.g. stand-alone TrngRingOscV2's are not recommended to be installed in
the same design.

The refill mark is configured at {} entries, with a total depth of {} entries.
        """.format(refill_mark, fifo_depth))
        refill_needed = Signal()
        powerup = Signal()
        self.warm_reset = Signal()

        if (revision == 'pvt') or (revision == 'pvt2'):
            # this state machine manages the avalanche generator's power-on delay. It ensures that
            # the generator always gets at least the minimum specified time to turn on and stabilize
            av_ena = Signal()
            self.comb += [
                av_ena.eq( (~server.control.fields.av_dis & server.control.fields.enable)
                                    & (powerup | ~server.control.fields.powersave)),
                noise_pads.noisebias_on.eq(av_ena),
                noise_pads.noise_on.eq(Cat(av_ena, av_ena)),
            ]
            av_powerstate = Signal()
            av_delay_ctr = Signal(20)
            av_micros_ctr = Signal(7)

            av_delay_setting = Signal(20)
            if sim == True:
                self.comb += av_delay_setting.eq(10)
            else:
                self.comb += av_delay_setting.eq(server.av_config.fields.powerdelay)

            avpwr = FSM(reset_state="DOWN")
            self.submodules += avpwr
            avpwr.act("DOWN",
                NextValue(av_powerstate, 0),
                If(av_ena,
                    NextValue(av_delay_ctr, av_delay_setting),
                    NextValue(av_micros_ctr, 99),
                    NextState("WAIT"),
                )
            )
            avpwr.act("WAIT",
                NextValue(av_powerstate, 0),
                If(av_micros_ctr == 0,
                    NextValue(av_micros_ctr, 99),
                    If(av_delay_ctr == 0,
                        NextState("UP")
                    ).Else(
                        NextValue(av_delay_ctr, av_delay_ctr - 1)
                    )
                ).Else(
                    NextValue(av_micros_ctr, av_micros_ctr - 1),
                )
            )
            avpwr.act("UP",
                NextValue(av_powerstate, 1),
                If(~av_ena,
                    NextState("DOWN")
                )
            )

            # This the XADC module -- it gives us raw noise values that we have to assemble into a 32-bit value
            self.submodules.xadc = TrngXADC(analog_pads, sim, revision)
            av_noise0_read = Signal()
            av_noise1_read = Signal()
            av_noise0_fresh = Signal()
            av_noise1_fresh = Signal()
            av_noise0_data = Signal(12)
            av_noise1_data = Signal(12)
            pad4 = Signal(4)  # pad by 4 bits
            av_reconfigure = Signal()
            av_config_noise = Signal()
            av_configured = Signal()
            self.comb += [
                av_noise0_fresh.eq(self.xadc.noise0_fresh),
                av_noise1_fresh.eq(self.xadc.noise1_fresh),
                av_noise0_data.eq(self.xadc.noise0.status),
                av_noise1_data.eq(self.xadc.noise1.status),
                self.xadc.noise0_read.eq(av_noise0_read),
                self.xadc.noise1_read.eq(av_noise1_read),
                self.xadc.reconfigure.eq(av_reconfigure),
                self.xadc.config_noise.eq(av_config_noise),
                av_configured.eq(self.xadc.configured),
            ]
            # This state machine assembles ADC values into a 32-bit noise word
            # This can be done even when the XADC isn't configured for noise mode -- the "noise mode"
            # reconfiguration is just to optimize sampling speed, it does not affect correctness.
            # Note that correctness is affected by the power-on delay of the external generator, which is
            # not related to the following state machine
            av_noiseout = Signal(32)
            av_noiseout_ready = Signal()
            av_noiseout_read = Signal()
            av_noisecnt = Signal(server.av_config.fields.samples.nbits)
            avn = FSM(reset_state="IDLE")
            self.submodules += avn

            avn.act("IDLE",
                If(av_powerstate,
                    If(~server.av_config.fields.test,
                        NextState("ASSEMBLE"),
                    ).Else(
                        NextState("TEST"),
                    )
                ),
                NextValue(av_noiseout_ready, 0),
                NextValue(av_noisecnt, server.av_config.fields.samples),
                NextValue(av_noiseout, 0),
            )
            avn.act("ASSEMBLE",
                NextValue(av_noiseout_ready, 0),
                If(av_noisecnt == 0,
                    NextState("READY")
                ).Else(
                    If(av_noise0_fresh & av_noise1_fresh,
                        NextValue(av_noisecnt, av_noisecnt - 1),
                        # Reduce effective sampling rate by oversampling noise (av_noisecount > 8) to improve entropy quality
                        # Side note: entropy is concentrated in the LSBs of the ADC, so we rotate the result by 5
                        #            which stripes the LSB over the final resulting 32-bit number:
                        # mod 5
                        # iters   00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32->0
                        # bit pos 00 05 10 15 20 25 30 03 08 13 18 23 28 01 06 11 16 21 26 31 04 09 14 19 24 29 02 07 12 17 22 27   00
                        # iters is set by the initial value in `av_noisecnt`, loaded in the "IDLE" state above
                        # mod 3
                        # iters   00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32->0
                        # bit pos 00 03 06 09 12 15 18 21 24 27 30 01 04 07 10 13 16 19 22 25 28 31 02 05 08 11 14 17 20 23 26 29   00
                        NextValue(av_noiseout, av_noise0_data ^ av_noise1_data ^ Cat(av_noiseout[27:], av_noiseout[:27])), # 27 for 5 shift, 29 for 3 shift
                        av_noise0_read.eq(1),
                        av_noise1_read.eq(1),
                    )
                )
            )
            avn.act("TEST",
                NextValue(av_noiseout_ready, 0),
                If(av_noise0_fresh & av_noise1_fresh,
                    NextValue(av_noiseout, Cat(av_noise0_data, pad4, av_noise1_data, pad4)),
                    NextState("READY"),
                )
            )
            avn.act("READY",
                If(av_noiseout_read,
                    NextValue(av_noiseout_ready, 0),
                    NextState("IDLE")
                ).Else(
                    NextValue(av_noiseout_ready, 1)
                )
            )
        elif revision == 'modnoise':
            self.submodules.xadc = TrngXADC(analog_pads, sim)
            self.submodules.modnoise = ModNoise(noise_pads)

            av_noiseout = Signal(32)
            av_powerstate = Signal()
            av_noiseout_read = Signal()

            av_config_noise = Signal()
            av_reconfigure = Signal()
            av_configured = Signal()
            av_noiseout_ready = Signal()

            self.comb += [
                av_noiseout.eq(self.modnoise.rand.fields.rand),
                self.modnoise.noise_read.eq(av_noiseout_read),
                av_configured.eq(1),
                self.modnoise.ena.eq((~server.control.fields.av_dis & server.control.fields.enable)
                                    & (powerup | ~server.control.fields.powersave)),
                av_powerstate.eq(self.modnoise.ena),
                av_noiseout_ready.eq(self.modnoise.status.fields.fresh),
            ]

        else:
            print("Error! unsuppored revision")

        # instantiate the on-chip ring oscillator TRNG. This one has no power-on delay, but the first
        # reading should be discarded after enabling (this is handled by the high level sequencer)
        if sim == False:
            self.submodules.ringosc = TrngRingOscV2Managed(platform, cores=ro_cores)
        else:
            self.submodules.ringosc = TrngRingOscSim(cores=ro_cores) # fake source for simulation purposes
        # pass-through config and mangamement signals to the RO
        ro_rand = Signal(32)
        ro_fresh = Signal()
        ro_rand_read = Signal()
        self.comb += [
            self.ringosc.ena.eq( (~server.control.fields.ro_dis & server.control.fields.enable)
                                 & (powerup | ~server.control.fields.powersave) ),
            self.ringosc.gang.eq(server.ro_config.fields.gang),
            self.ringosc.dwell.eq(server.ro_config.fields.dwell),
            self.ringosc.delay.eq(server.ro_config.fields.delay),
            self.ringosc.fuzz.eq(server.ro_config.fields.fuzz),
            self.ringosc.oversampling.eq(server.ro_config.fields.oversampling),
            ro_fresh.eq(self.ringosc.fresh),
            ro_rand.eq(self.ringosc.rand_out),
            self.ringosc.rand_read.eq(ro_rand_read),
        ]

        ###### Avalanche generator on-line health checks
        # "Excursion" health test for the Avalanche generator. A simple check to make sure there's enough wiggle on the noise source.
        # note: this block has its own CSR interface, and will appear separately in the CSR list
        av0_fresh_r = Signal()
        av0_sample = Signal()
        av1_fresh_r = Signal()
        av1_sample = Signal()
        self.sync += [
            av0_fresh_r.eq(av_noise0_fresh),
            av1_fresh_r.eq(av_noise1_fresh)
        ]
        self.comb += [
            av0_sample.eq(~av0_fresh_r & av_noise0_fresh),
            av1_sample.eq(~av1_fresh_r & av_noise1_fresh),
            server.av_excursion0.sample.eq(av0_sample),
            server.av_excursion1.sample.eq(av1_sample),
            server.av_excursion0.rand.eq(av_noise0_data),
            server.av_excursion1.rand.eq(av_noise1_data),
            server.av_excursion0.power_on.eq(av_powerstate),
            server.av_excursion1.power_on.eq(av_powerstate),
        ]
        # "Repetition Count" test as required by NIST SP 800-90B
        # To generate 32 bits of entropy, we take 32 rounds of samples from 2 generators, so 64 total samples.
        # select a cutoff_max of 127, to give _lots_ of margin for future-proofing options; in practice, I think
        # we will arrive at a much smaller number than a larger number.
        self.comb += [
            server.av_repcount0.sample.eq(av0_sample),
            server.av_repcount1.sample.eq(av1_sample),
            server.av_repcount0.rand.eq(av_noise0_data[:5]), # we only assume the bottom 5 bits are usable entropy
            server.av_repcount1.rand.eq(av_noise1_data[:5]),
            server.av_repcount0.reset.eq(server.control.fields.clr_err),
            server.av_repcount1.reset.eq(server.control.fields.clr_err),
            server.av_repcount0.cutoff.eq(server.av_nist.fields.repcount_cutoff),
            server.av_repcount1.cutoff.eq(server.av_nist.fields.repcount_cutoff),
            server.nist_errors.fields.av_repcount.eq(Cat(server.av_repcount0.failure, server.av_repcount1.failure)),
        ]
        # "Adaptive Proportion" test as required by NIST SP 800-90B
        self.comb += [
            server.av_adaprop0.sample.eq(av0_sample),
            server.av_adaprop1.sample.eq(av1_sample),
            server.av_adaprop0.rand.eq(av_noise0_data[:5]), # we only assume the bottom 5 bits are usable entropy
            server.av_adaprop1.rand.eq(av_noise1_data[:5]),
            server.av_adaprop0.enabled.eq(av_powerstate),
            server.av_adaprop1.enabled.eq(av_powerstate),
            server.av_adaprop0.reset.eq(server.control.fields.clr_err),
            server.av_adaprop1.reset.eq(server.control.fields.clr_err),
            server.av_adaprop0.cutoff.eq(server.av_nist.fields.adaptive_cutoff),
            server.av_adaprop1.cutoff.eq(server.av_nist.fields.adaptive_cutoff),
            server.nist_errors.fields.av_adaptive.eq(Cat(server.av_adaprop0.failure, server.av_adaprop1.failure)),
        ]
        # wire up the telemetry
        self.comb += [
            server.nist_av_stat0.fields.adap_b.eq(server.av_adaprop0.b),
            server.nist_av_stat1.fields.adap_b.eq(server.av_adaprop1.b),
            server.nist_av_stat0.fields.fresh.eq(server.av_adaprop0.b_fresh),
            server.nist_av_stat1.fields.fresh.eq(server.av_adaprop1.b_fresh),
            server.nist_av_stat0.fields.rep_b.eq(server.av_repcount0.b),
            server.nist_av_stat1.fields.rep_b.eq(server.av_repcount1.b),
            server.av_adaprop0.b_read.eq(server.nist_av_stat0.we),
            server.av_adaprop1.b_read.eq(server.nist_av_stat1.we),
        ]

        ## aggregate ready (e.g., passed power-on self-check) into one signal
        av_pass = Signal()
        self.comb += av_pass.eq(server.av_adaprop0.ready & server.av_adaprop1.ready & server.av_excursion0.ready & server.av_excursion1.ready)
        self.comb += [
            server.ready.fields.av_excursion.eq(Cat(
                server.av_excursion0.ready,
                server.av_excursion1.ready,
            )),
            server.ready.fields.av_adaprop.eq(Cat(
                server.av_adaprop0.ready,
                server.av_adaprop1.ready,
            )),
        ]

        ###### Ring oscillator on-line health checks
        # "Repetition Count" test as required by NIST SP 800-90B
        #    Use 127 as the max threshold. Should be way more than enough.
        # "Adaptive proportion" test as required by NIST SP 800-90B
        # "MiniRuns" as supplemental statistics gathering for the supervising software to make more informed decisions about
        #    failure modes more specific to ring oscillators
        index = 0
        inject_failure = False
        for core in range(ro_cores):
            if (core == 0) and inject_failure:
                # wire up one core directly to a low-quality entropy source so we can see tests fail
                self.comb +=  getattr(server, 'ro_run'+str(core)).rand.eq(getattr(getattr(self.ringosc, 'rocore'+str(core)),'ro_samp32')),
            else:
                self.comb += getattr(server, 'ro_run'+str(core)).rand.eq(getattr(getattr(self.ringosc, 'rocore'+str(core)),'rand')[0]),

            self.comb += [
                getattr(server, 'ro_rep'+str(core)).sample.eq(getattr(self.ringosc, 'rocore'+str(core)).sample_now),
                getattr(server, 'ro_adp'+str(core)).sample.eq(getattr(self.ringosc, 'rocore'+str(core)).sample_now),
                getattr(server, 'ro_run'+str(core)).sample.eq(getattr(self.ringosc, 'rocore'+str(core)).sample_now),

                getattr(server, 'ro_rep'+str(core)).rand.eq(getattr(getattr(self.ringosc, 'rocore'+str(core)),'rand')[0]),
                getattr(server, 'ro_adp'+str(core)).rand.eq(getattr(getattr(self.ringosc, 'rocore'+str(core)),'rand')[0]),

                getattr(server, 'ro_rep'+str(core)).reset.eq(server.control.fields.clr_err),
                getattr(server, 'ro_adp'+str(core)).reset.eq(server.control.fields.clr_err),
                getattr(server, 'ro_run'+str(core)).reset_failure.eq(server.control.fields.clr_err),

                getattr(server, 'ro_rep'+str(core)).cutoff.eq(server.ro_nist.fields.repcount_cutoff),
                getattr(server, 'ro_adp'+str(core)).cutoff.eq(server.ro_nist.fields.adaptive_cutoff),

                getattr(server, 'ro_adp'+str(core)).enabled.eq(self.ringosc.ena),
                getattr(server, 'ro_run'+str(core)).power_on.eq(self.ringosc.ena),

                server.nist_errors.fields.ro_repcount[index].eq(getattr(server, 'ro_rep'+str(core)).failure),
                server.nist_errors.fields.ro_adaptive[index].eq(getattr(server, 'ro_adp'+str(core)).failure),
                server.nist_errors.fields.ro_miniruns[index].eq(getattr(server, 'ro_run'+str(core)).failure),

                getattr(server, 'nist_ro_stat'+str(core)).fields.adap_b.eq(getattr(server, 'ro_adp'+str(core)).b),
                getattr(server, 'nist_ro_stat'+str(core)).fields.fresh.eq(getattr(server, 'ro_adp'+str(core)).b_fresh),
                getattr(server, 'ro_adp'+str(core)).b_read.eq(getattr(server, 'nist_ro_stat'+str(core)).we),
                getattr(server, 'nist_ro_stat'+str(core)).fields.rep_b.eq(getattr(server, 'ro_rep'+str(core)).b),
            ]
            for run in range(1, getattr(server, 'ro_run'+str(core)).maxrun + 1):
                self.comb += [
                    getattr(getattr(server, 'ro_run'+str(core)), 'runs_min'+str(run)).eq(getattr(server, 'ro_runslimit'+str(run)).fields.min),
                    getattr(getattr(server, 'ro_run'+str(core)), 'runs_max'+str(run)).eq(getattr(server, 'ro_runslimit'+str(run)).fields.max),
                ]
            index += 1

        ro_pass=Signal()
        self.comb += ro_pass.eq(server.ro_adp0.ready & server.ro_adp1.ready & server.ro_adp2.ready & server.ro_adp3.ready &
            ~(server.ro_run0.failure | server.ro_run1.failure | server.ro_run2.failure | server.ro_run3.failure)
        )
        self.comb += [
            server.ready.fields.ro_adaprop.eq(Cat(
                server.ro_adp0.ready,
                server.ro_adp1.ready,
                server.ro_adp2.ready,
                server.ro_adp3.ready,
            ))
        ]

        ## aggregate failures and feed back into all-in-one interrupt
        any_failure = Signal()
        any_failure_r = Signal()
        self.sync += any_failure_r.eq(any_failure)
        self.comb += [ # note that excursion test has its own failure trigger and interrupt
            any_failure.eq(server.av_repcount0.failure | server.av_repcount1.failure | server.av_adaprop0.failure | server.av_adaprop1.failure
               | server.ro_rep0.failure | server.ro_rep1.failure | server.ro_rep2.failure | server.ro_rep3.failure
               | server.ro_adp0.failure | server.ro_adp1.failure | server.ro_adp2.failure | server.ro_adp3.failure
               | server.ro_run0.failure | server.ro_run1.failure | server.ro_run2.failure | server.ro_run3.failure
            ),
            server.ev.health.trigger.eq(any_failure & ~any_failure_r),
        ]

        # meet DRC rules for FIFO reset timing
        fifo_rst_cnt = Signal(3, reset=5)
        fifo_reset   = Signal(reset=1)
        self.sync += [
            If(ResetSignal(),
                fifo_rst_cnt.eq(5),  # 5 cycles reset required by design
                fifo_reset.eq(1)
            ).Else(
                If(fifo_rst_cnt == 0,
                    fifo_reset.eq(0)
                ).Else(
                    fifo_rst_cnt.eq(fifo_rst_cnt - 1),
                    fifo_reset.eq(1)
                )
            )
        ]
        #### now build two fifos, one for kernel, one for server
        # At a width of 32 bits, an 36kiB fifo is 1024 entries deep
        ## server fifo
        server_fifo_full = Signal()
        server_fifo_empty = Signal()
        server_fifo_wren = Signal()
        server_fifo_din = Signal(32)
        server_fifo_rden = Signal()
        server_fifo_dout = Signal(32)
        server_fifo_rdcount = Signal(10)
        server_fifo_rderr = Signal()
        server_fifo_wrcount = Signal(10)
        server_fifo_almostempty = Signal()
        self.specials += Instance("FIFO_SYNC_MACRO",
            p_DEVICE="7SERIES",
            p_FIFO_SIZE="36Kb",
            p_DATA_WIDTH=32,
            p_ALMOST_EMPTY_OFFSET=refill_mark,
            p_ALMOST_FULL_OFFSET=almost_full,
            p_DO_REG=0,
            i_CLK=ClockSignal(),
            i_RST=fifo_reset,
            o_ALMOSTFULL=server_fifo_full, # use ALMOSTFULL so simulations don't take forever to run :P
            o_EMPTY=server_fifo_empty,
            i_WREN=server_fifo_wren,
            i_DI=server_fifo_din,
            i_RDEN=server_fifo_rden,
            o_DO=server_fifo_dout,
            o_RDCOUNT=server_fifo_rdcount,
            o_RDERR=server_fifo_rderr,
            o_WRCOUNT=server_fifo_wrcount,
            o_ALMOSTEMPTY=server_fifo_almostempty,
        )
        self.comb += [
            server.ev.avail.trigger.eq(~server_fifo_empty),
            server.ev.error.trigger.eq(server_fifo_rderr), # this should only pulse when RE is triggered; it should not be stuck at a level
            If(~server_fifo_empty,
                server_fifo_rden.eq(server.data.we),
                server.data.fields.data.eq(server_fifo_dout),
            ).Else(
                server.data.fields.data.eq(0xDEADBEEF),
            ),
            server.status.fields.rdcount.eq(server_fifo_rdcount),
            server.status.fields.wrcount.eq(server_fifo_wrcount),
            server.status.fields.avail.eq(~server_fifo_empty),
        ]
        self.sync += [
            If(server.control.fields.clr_err,
                server.underruns.fields.server_underrun.eq(0)
            ).Else(
                If(server_fifo_rden & server_fifo_empty,
                    If(server.underruns.fields.server_underrun < 0x3FF,
                        server.underruns.fields.server_underrun.eq(server.underruns.fields.server_underrun + 1)
                    )
                )
            )
        ]

        ## kernel fifo
        kernel_fifo_full = Signal()
        kernel_fifo_empty = Signal()
        kernel_fifo_wren = Signal()
        kernel_fifo_din = Signal(32)
        kernel_fifo_rden = Signal()
        kernel_fifo_dout = Signal(32)
        kernel_fifo_rdcount = Signal(10)
        kernel_fifo_rderr = Signal()
        kernel_fifo_wrcount = Signal(10)
        kernel_fifo_almostempty = Signal()
        self.specials += Instance("FIFO_SYNC_MACRO",
            p_DEVICE="7SERIES",
            p_FIFO_SIZE="36Kb",
            p_DATA_WIDTH=32,
            p_ALMOST_EMPTY_OFFSET=refill_mark,
            p_ALMOST_FULL_OFFSET=almost_full,
            p_DO_REG=0,
            i_CLK=ClockSignal(),
            i_RST=fifo_reset,
            o_ALMOSTFULL=kernel_fifo_full, # use ALMOSTFULL so simulations don't take forever to run :P
            o_EMPTY=kernel_fifo_empty,
            i_WREN=kernel_fifo_wren,
            i_DI=kernel_fifo_din,
            i_RDEN=kernel_fifo_rden,
            o_DO=kernel_fifo_dout,
            o_RDCOUNT=kernel_fifo_rdcount,
            o_RDERR=kernel_fifo_rderr,
            o_WRCOUNT=kernel_fifo_wrcount,
            o_ALMOSTEMPTY=kernel_fifo_almostempty,
        )
        seed_req = Signal()
        seed_gnt = Signal()
        seed_buf = Signal(32)
        seed_read = Signal()
        seed_read_r = Signal()
        buffered_avail = Signal()
        self.sync += [
            seed_read_r.eq(seed_read),
            buffered_avail.eq(~kernel_fifo_empty & ~seed_req),
            kernel.ev.avail.trigger.eq(buffered_avail),
            kernel.status.fields.avail.eq(buffered_avail), # note potential race condition if the fifo is drained after avail has been read...
            If(~kernel_fifo_empty,
                kernel_fifo_rden.eq( (~seed_req & kernel.data.we) | (seed_read & ~seed_read_r) ),
                kernel.data.fields.data.eq(kernel_fifo_dout),
            ).Else(
                kernel.data.fields.data.eq(0xDEADBEEF),
            ),
            If(seed_req,
                If(~kernel_fifo_empty,
                    seed_gnt.eq(1),
                    seed_read.eq(1),
                    seed_buf.eq(kernel_fifo_dout),
                ).Else(
                    seed_gnt.eq(0),
                    seed_read.eq(0),
                    seed_buf.eq(seed_buf),
                )
            ).Else(
                seed_gnt.eq(0),
                seed_read.eq(0),
                seed_buf.eq(seed_buf),
            )
        ]

        self.comb += [
            # kernel.ev.avail.trigger.eq(~kernel_fifo_empty),
            kernel.ev.error.trigger.eq(kernel_fifo_rderr), # this should only pulse when RE is triggered; it should not be stuck at a level
            # If(~kernel_fifo_empty,
            #     kernel_fifo_rden.eq(kernel.data.we),
            #     kernel.data.fields.data.eq(kernel_fifo_dout),
            # ).Else(
            #     kernel.data.fields.data.eq(0xDEADBEEF),
            # ),
            # kernel.status.fields.rdcount.eq(kernel_fifo_rdcount),
            # kernel.status.fields.wrcount.eq(kernel_fifo_wrcount),
            # kernel.status.fields.avail.eq(~kernel_fifo_empty),
        ]
        self.sync += [
            If(server.control.fields.clr_err,
                server.underruns.fields.kernel_underrun.eq(0)
            ).Else(
                If(kernel_fifo_rden & kernel_fifo_empty,
                    If(server.underruns.fields.kernel_underrun < 0x3FF,
                        server.underruns.fields.kernel_underrun.eq(server.underruns.fields.kernel_underrun + 1)
                    )
                )
            )
        ]

        self.comb += server.status.fields.full.eq(kernel_fifo_full & server_fifo_full)

        # static datapath to merge the TRNG results into the FIFOs. Actual gating of writes is handled by the
        # high level control state machine. The main reason we don't just always XOR the two machines together
        # is to give visibility for debug and individual TRNG quality checking
        merged_trng = Signal(32)
        self.comb += [
            refill_needed.eq(kernel_fifo_almostempty | server_fifo_almostempty), # either fifo going almost empty will trigger a top-up, but note that both will be topped up anytime one FIFO needs a top-up
            If(~server.control.fields.av_dis & ~server.control.fields.ro_dis,
                merged_trng.eq(av_noiseout ^ ro_rand)
            ).Elif(~server.control.fields.av_dis & server.control.fields.ro_dis,
                merged_trng.eq(av_noiseout)
            ).Elif(server.control.fields.av_dis & ~server.control.fields.ro_dis,
                merged_trng.eq(ro_rand)
            ).Else(
                merged_trng.eq(0xDEADBEEF)
            ),
            kernel_fifo_din.eq(merged_trng),
            server_fifo_din.eq(merged_trng),
        ]

        # This is the "high-level control" refill FSM.
        refill = FSM(reset_state="IDLE")
        self.submodules += refill
        refill.act("IDLE",
            If(refill_needed,
                NextValue(powerup, 1),
                If(~server.control.fields.av_dis,
                    NextState("CONFIG"),
                    NextValue(av_config_noise, 1),  # switch to noise-only sampling for the XADC
                ).Else(
                    NextState("SELFTEST")
                )
            ).Else(
                NextValue(powerup, 0),
            ),
            av_reconfigure.eq(0),
        )
        refill.act("CONFIG",
            av_reconfigure.eq(1),  # edge-triggered signal to initiate XADC config
            NextState("WAIT_ON"),
        )
        refill.act("WAIT_ON",
            If(av_powerstate & av_configured,
                NextState("SELFTEST"), # skip PUMP in favor of SELFTEST
                NextValue(av_config_noise, 0),  # prep for next av_reconfigure pulse
            )
        )
        # refill.act("PUMP", # discard the first value out of the TRNG, as it's potentially biased by power-on effects
        #     # do pump here
        #     If((av_noiseout_ready | server.control.fields.av_dis) & (ro_fresh | server.control.fields.ro_dis),
        #         If(~server.control.fields.av_dis,
        #             av_noiseout_read.eq(1),
        #         ),
        #         If(~server.control.fields.ro_dis,
        #             ro_rand_read.eq(1),
        #         ),
        #         NextState("SELFTEST")
        #     )
        # )
        # we don't need to discard the first value anymore because we pump out lots of values for the selftest
        refill.act("SELFTEST",
            # pump each machine as fast as we can for the self-test
            If( av_noiseout_ready,
                av_noiseout_read.eq(~server.control.fields.av_dis),
            ).Else(
                av_noiseout_read.eq(0)
            ),
            If( ro_fresh,
                ro_rand_read.eq(~server.control.fields.ro_dis), # don't read from a disabled source
            ).Else(
                ro_rand_read.eq(0)
            ),
            #### NOTE: we allow the refill to happen if *either* TRNG passes. This allows us to proceed and get minimum
            #### functionality in the case that one generator source is failing. But at least one must pass!
            #### For the "and" you need this: (av_pass | server.control.fields.av_dis) & (ro_pass | server.control.fields.ro_dis)
            #### the *_dis fields must be considered otherwise you would block on a deliberately disabled TRNG source before booting
            If( av_pass | ro_pass & ~server.av_config.fields.required, # added a clause to force av_pass to be required, if desired by the user
                NextState("REFILL_KERNEL")
            )
        )
        refill.act("REFILL_KERNEL",
            If(kernel_fifo_full,
                NextState("REFILL_SERVER")
            ).Else(
                # this logic is set to allow the system to boot to minimum viable kernel, even if one of the TRNGs is failing
                # if there is a spontaneous failure during run-time, it's up to the OS to catch this and make a policy decision.
                If((av_noiseout_ready | server.control.fields.av_dis) & (ro_fresh | server.control.fields.ro_dis) & (av_pass | ro_pass),
                    kernel_fifo_wren.eq(1),
                    av_noiseout_read.eq(1),  # note that trng stream selection considers the _dis field state, so it's safe to always pump both even if one is disabled
                    ro_rand_read.eq(1),
                ),
            )
        )
        refill.act("REFILL_SERVER",
            If(server_fifo_full,
                NextState("GO_IDLE"),
            ).Else(
                If((av_noiseout_ready | server.control.fields.av_dis) & (ro_fresh | server.control.fields.ro_dis) & (av_pass | ro_pass),
                    server_fifo_wren.eq(1),
                    av_noiseout_read.eq(1),
                    ro_rand_read.eq(1),
                )
            )
        )
        refill.act("GO_IDLE",
            NextValue(av_config_noise, 0), # should already be 0, as this was set leaving "WAIT_ON" state
            av_reconfigure.eq(1), # pulse to set XADC back into the "system" sampling mode
            NextState("IDLE")
        )

        self.submodules.chacha = ChaChaConditioner(platform)
        self.comb += [
            # CSR configs
            self.chacha.reseed_interval.eq(server.chacha.fields.reseed_interval),
            self.chacha.selfmix_interval.eq(server.chacha.fields.selfmix_interval),
            self.chacha.selfmix_ena.eq(server.chacha.fields.selfmix_ena),
            self.chacha.userdata.eq(server.more_seed.storage),
            self.chacha.seed_now.eq(server.more_seed.re),
            server.status.fields.chacha_ready.eq(self.chacha.ready),

            # data outputs
            # userland gets "B" port
            server.urandom.status.eq(self.chacha.output_b),
            server.urandom_valid.status.eq(self.chacha.valid_b),
            self.chacha.advance_b.eq(server.urandom.we | server.test.fields.simultaneous),
            # kernel gets "A" port (has priority over B in case of simultaeous read)
            kernel.urandom.status.eq(self.chacha.output_a),
            kernel.urandom_valid.status.eq(self.chacha.valid_a),
            self.chacha.advance_a.eq(kernel.urandom.we | server.test.fields.simultaneous),

            # TRNG tap to local hardware
            self.chacha.seed.eq(seed_buf),
            seed_req.eq(self.chacha.seed_req),
            self.chacha.seed_gnt.eq(seed_gnt),
        ]

analog_layout = [("vauxp", 16), ("vauxn", 16), ("vp", 1), ("vn", 1)]

class TrngXADC(Module, AutoCSR):
    def __init__(self, analog_pads=None, sim=False, revision='pvt'):
        # Temperature
        self.temperature = CSRStatus(12, description="""Raw Temperature value from XADC.\n
            Temperature (C) = ``Value`` x 503.975 / 4096 - 273.15.""")

        # Voltages
        self.vccint  = CSRStatus(12, description="""Raw VCCINT value from XADC.\n
            VCCINT (V) = ``Value`` x 3 / 4096.""")
        self.vccaux  = CSRStatus(12, description="""Raw VCCAUX value from XADC.\n
            VCCAUX (V) = ``Value`` x 3 / 4096.""")
        self.vccbram = CSRStatus(12, description="""Raw VCCBRAM value from XADC.\n
            VCCBRAM (V) = ``Value`` x 3 / 4096.""")

        self.vbus = CSRStatus(12, description="Raw VBUS value from XADC")
        self.usb_p = CSRStatus(12, description="Voltage on USB_P pin")
        self.usb_n = CSRStatus(12, description="Voltage on USB_N pin")
        self.noise0 = CSRStatus(12, description="Raw noise0")
        self.noise0_read = Signal() # used by trng manager to indicate when the noise value has been read
        self.noise1 = CSRStatus(12, description="Raw noise1")
        self.noise1_read = Signal() # used by trng manager to indicate when the noise value has been read


        # End of Convertion/Sequence
        self.eoc = CSRStatus(description="End of Convertion Status, ``1``: Convertion Done.")
        self.eos = CSRStatus(description="End of Sequence Status, ``1``: Sequence Done.")

        # Alarms
        alarm = Signal(8)
        ot    = Signal()

        # # #

        busy    = Signal()
        channel = Signal(5)
        eoc     = Signal()
        eos     = Signal()

        # XADC instance ----------------------------------------------------------------------------
        dwe  = Signal()
        den  = Signal()
        drdy = Signal()
        dadr = Signal(7)
        di   = Signal(16)
        do   = Signal(16)
        drp_en = Signal()
        if sim == True:
            instancename = "XADCsim"
        else:
            instancename = "XADC"
        self.specials += Instance(instancename,
            # From ug480
            p_INIT_40=0x9000, p_INIT_41=0x2ef0, p_INIT_42=0x0420,
            p_INIT_48=0x4701, p_INIT_49=0xd050, # note the initial values don't map the GPIOx pins, but this is adjusted in the "sense_table" later based on HW rev
            p_INIT_4A=0x4701, p_INIT_4B=0xc040,
            p_INIT_4C=0x0000, p_INIT_4D=0x0000,
            p_INIT_4E=0x0000, p_INIT_4F=0x0000,
            p_INIT_50=0xb5ed, p_INIT_51=0x5999,
            p_INIT_52=0xa147, p_INIT_53=0xdddd,
            p_INIT_54=0xa93a, p_INIT_55=0x5111,
            p_INIT_56=0x91eb, p_INIT_57=0xae4e,
            p_INIT_58=0x5999, p_INIT_5C=0x5111,
            o_ALM       = alarm,
            o_OT        = ot,
            o_BUSY      = busy,
            o_CHANNEL   = channel,
            o_EOC       = eoc,
            o_EOS       = eos,
            i_VAUXP     = 0 if analog_pads is None else analog_pads.vauxp,
            i_VAUXN     = 0 if analog_pads is None else analog_pads.vauxn,
            i_VP        = 0 if analog_pads is None else analog_pads.vp,
            i_VN        = 0 if analog_pads is None else analog_pads.vn,
            i_CONVST    = 0,
            i_CONVSTCLK = 0,
            i_RESET     = ResetSignal(),
            i_DCLK      = ClockSignal(),
            i_DWE       = dwe,
            i_DEN       = den,
            o_DRDY      = drdy,
            i_DADDR     = dadr,
            i_DI        = di,
            o_DO        = do
        )
        local_dwe   = Signal()
        local_den   = Signal()
        local_dadr  = Signal(7)
        local_di    = Signal(16)

        self.configured = Signal() # when high, ADC is configured and sampling

        # Channels update --------------------------------------------------------------------------
        if revision == 'pvt':
            channels = {
                0 : self.temperature,
                1 : self.vccint,
                2 : self.vccaux,
                6 : self.vccbram,
                20: self.noise1,
                22: self.vbus,
                28: self.noise0,
                30: self.usb_p,
                31: self.usb_n,
            }
        elif revision == 'pvt2':
            self.gpio5 = CSRStatus(12, description="GPIO5 value")
            self.gpio2 = CSRStatus(12, description="GPIO2 value")
            channels = {
                0: self.temperature,
                1: self.vccint,
                2: self.vccaux,
                6: self.vccbram,
                20: self.noise1,
                21: self.gpio5,
                22: self.vbus,
                27: self.gpio2,
                28: self.noise0,
                30: self.usb_p,
                31: self.usb_n,
            }
        self.sync += [
                If(drdy,
                    Case(channel, dict(
                        (k, v.status.eq(do >> 4))
                    for k, v in channels.items()))
                )
        ]
        self.noise0_fresh = Signal() # indicates a new value in noise 0
        self.noise1_fresh = Signal() # indicates a new value in noise 1
        self.sync += [
            If(self.noise0.we | self.noise0_read,
                self.noise0_fresh.eq(0)
            ).Else(
                If( (channel == 28) & drdy & self.configured & ~drp_en,
                    self.noise0_fresh.eq(1)
                ).Else(
                    self.noise0_fresh.eq(self.noise0_fresh)
                )
            ),
            If(self.noise1.we | self.noise1_read,
                self.noise1_fresh.eq(0)
            ).Else(
                If( (channel == 20) & drdy & self.configured & ~drp_en,
                    self.noise1_fresh.eq(1)
                ).Else(
                    self.noise1_fresh.eq(self.noise1_fresh)
                )
            )
        ]

        # End of Convertion/Sequence update --------------------------------------------------------
        self.sync += [
            self.eoc.status.eq((self.eoc.status & ~self.eoc.we) | eoc),
            self.eos.status.eq((self.eos.status & ~self.eos.we) | eos),
        ]

        self.drp_enable = CSRStorage() # Set to 1 to use DRP and disable auto-sampling; overrides TRNG manager
        self.drp_read   = CSR()
        self.drp_write  = CSR()
        self.drp_drdy   = CSRStatus()
        self.drp_adr    = CSRStorage(7,  reset_less=True)
        self.drp_dat_w  = CSRStorage(16, reset_less=True)
        self.drp_dat_r  = CSRStatus(16)

        # # #

        den_pipe = Signal() # add a register to ease timing closure of den
        dwe_pipe = Signal()

        self.comb += [
            self.drp_dat_r.status.eq(do),
            If(drp_en,
                den.eq(den_pipe),
                dadr.eq(self.drp_adr.storage),
                di.eq(self.drp_dat_w.storage),
                dwe.eq(dwe_pipe),
            ).Else(
                den.eq(local_den),
                dadr.eq(local_dadr),
                di.eq(local_di),
                dwe.eq(local_dwe),
            )
        ]
        self.sync += [
            drp_en.eq(self.drp_enable.storage),
            dwe_pipe.eq(self.drp_write.re),
            den_pipe.eq(self.drp_read.re | self.drp_write.re),
            If(self.drp_read.re | self.drp_write.re,
                self.drp_drdy.status.eq(0)
            ).Elif(drdy,
                self.drp_drdy.status.eq(1)
            )
        ]

        romval = Signal(16 + 7) # rom is formatted as {addr[6:0], data[15:0]}
        self.comb += [
            local_di.eq(romval[:16]),
            If(self.configured,
                local_dadr.eq(channel),
            ).Else(
                local_dadr.eq(romval[16:]),
            )
        ]
        romadr = Signal(3) # up to 8 entries in the sequence
        self.noise_mode = Signal()
        # configure for fast-sampling of noise
        noise_table = {
            0: 0x410EF0, # set sequencer default mode -- allows updating of Sequencer
            1: 0x480000, # Seq 0: none
            2: 0x491010, # Seq 1: Vaux12 (noise0) and Vaux4 (noise1)
            3: 0x4A0000, # Avg 0: no averaging
            4: 0x4B1010, # Avg 1: no averaging
            5: 0x420420, # adc B off, divide DCLK by 4
            6: 0x408000, # don't use averaging
            7: 0x412EF0,  # continuous mode, disable most alarms
        }
        if revision == 'pvt':
            # configure for round-robin sampling of all system parameters (this is default)
            sense_table = {
                0: 0x410EF0,  # set sequencer default mode -- allows updating of Sequencer
                1: 0x484701,  # Seq 0: Aux Int Bram Temp Cal
                2: 0x49D050,  # Seq 1: Vaux15 (usbn) Vaux14 (usbp) Vaux12 (noise0) Vaux6 (vbus) Vaux4 (noise1)
                3: 0x4A4701,  # Average aux int bram temp cal
                4: 0x4BC040,  # Average all but noise (c040)
                5: 0x412EF0,
                6: 0x409000,  # Average by 16 samples
                7: 0x420420,
            }
        elif revision == 'pvt2':
            # configure for round-robin sampling of all system parameters (this is default)
            sense_table = {
                0: 0x410EF0,  # set sequencer default mode -- allows updating of Sequencer
                1: 0x484701,  # Seq 0: Aux Int Bram Temp Cal
                2: 0x49D870,  # Seq 1: Vaux15 (usbn) Vaux14 (usbp) Vaux12 (noise0) Vaux11 (gpio2) Vaux6 (vbus) Vaux5 (gpio5) Vaux4 (noise1)
                3: 0x4A4701,  # Average aux int bram temp cal
                4: 0x4BC860,  # Average all but noise (c040)
                5: 0x412EF0,
                6: 0x409000,  # Average by 16 samples
                7: 0x420420,
            }
        else:
            print("XADC: unsupported revision!")

        # Add table for power down? maybe this is better handled in driver software with DRP?
        self.sync += [
            If(~self.noise_mode,
                Case(romadr, dict(
                    (k, romval.eq(v))
                    for k, v in sense_table.items()))
            ).Else(
                Case(romadr, dict(
                    (k, romval.eq(v))
                    for k, v in noise_table.items()))
            )
        ]

        self.reconfigure = Signal()  # on rising edge, reconfigure the XADC parameter
        reconfigure_r = Signal()
        self.config_noise = Signal() # when high, selects "noise" configuration; when low, selects "sense"
        self.sync += [
            reconfigure_r.eq(self.reconfigure)
        ]

        fsm = FSM(reset_state="IDLE")
        self.submodules += fsm
        fsm.act("IDLE",
            local_den.eq(eoc),  # auto-read the output of the converter in IDLE mode
            self.configured.eq(1),
            NextValue(romadr, 0),
            If(self.config_noise,
                NextValue(self.noise_mode, 1),  # select noise table
            ).Else(
                NextValue(self.noise_mode, 0),  # select sense table
            ),
            If(self.reconfigure & ~reconfigure_r,
                NextState("WAIT_UNBUSY")
            )
        )
        fsm.act("WAIT_UNBUSY",
            If(~busy,
                NextState("LOAD_DRP")
            )
        )
        fsm.act("LOAD_DRP",
            local_dwe.eq(1),
            local_den.eq(1),
            NextState("WAIT_DRDY")
        )
        fsm.act("WAIT_DRDY",
            If(drdy,
                NextState("ADV")
            )
        )
        fsm.act("ADV",
            NextValue(romadr, romadr + 1),
            NextState("WAIT_DRDY_LOW")
        )
        fsm.act("WAIT_DRDY_LOW",
            If(romadr == 0,
                NextState("IDLE")
            ).Else(
                If(~drdy & ~busy,
                    NextState("LOAD_DRP")
                )
            )
        )

class TrngRingOscCoreSim(Module):
    def __init__(self, index=0):
        self.rand_out = Signal(32, reset=(0x5555_00F0 + index + 3))
        self.update = Signal()
        self.ro_samp32 = Signal()
        self.sample_now = Signal()
        self.rand = Signal(32)
        lfsr = Signal(16)
        self.comb += lfsr.eq(self.rand_out[:16])
        self.sync += [
            If(self.sample_now,
                self.rand_out.eq(Cat(Cat(lfsr[1:], lfsr[5] ^ lfsr[3] ^ lfsr[2] ^ lfsr[0]),self.rand_out[16:]))
            ).Else(
                self.rand_out.eq(self.rand_out)
            )
        ]
        self.comb += self.ro_samp32.eq(self.rand_out[0])
        self.comb += self.rand.eq(self.rand_out)


class TrngRingOscSim(Module, AutoDoc):
    def __init__(self, cores=4):
        self.intro = ModuleDoc("""
WARNING: if you see this paragraph in the documentation, something is very wrong with
the SoC build. The TRNG has been replaced with a simulation model that is not at all
random (it's a simple counter).

We do this because xsim cannot simulate ring oscillators.
        """)
        ### to/from management interface
        self.ena = Signal()
        self.gang = Signal()
        self.dwell = Signal(20)
        self.delay = Signal(10)
        self.rand_out = Signal(32, reset=0x5555_0000)
        self.rand_read = Signal() # pulse one cycle to indicate rand_out has been read
        self.fresh = Signal(reset=1)
        self.fuzz = Signal()
        self.oversampling = Signal(8)  # stages to oversample entropy
        sample_now = Signal()

        for core in range(cores):
            setattr(self.submodules, 'rocore' + str(core), TrngRingOscCoreSim(core * 0x2000))
            self.comb += getattr(self, 'rocore' + str(core)).sample_now.eq(sample_now)

        delay = Signal(4, reset=15)
        self.sync += [
            If(self.ena,
                If(self.rand_read,
                    self.fresh.eq(0),
                    delay.eq(15),
                    self.rand_out.eq(self.rand_out),
                    sample_now.eq(0),
                ).Else(
                    If(delay == 1,
                        delay.eq(delay - 1),
                        self.rand_out.eq(self.rand_out + 1),
                        self.fresh.eq(1),
                        sample_now.eq(1),
                    ).Elif(delay != 0,
                        delay.eq(delay - 1),
                        self.fresh.eq(self.fresh),
                        self.rand_out.eq(self.rand_out),
                        sample_now.eq(0),
                    ).Else(
                        delay.eq(delay),
                        self.fresh.eq(self.fresh),
                        self.rand_out.eq(self.rand_out),
                        sample_now.eq(0),
                    )
                )
            )
        ]

class TrngRingOscCore(Module, AutoDoc, AutoCSR):
    def __init__(self, platform, stage_id, ro_elements, ro_stages):
        self.sample_now = Signal()
        self.dwell_now = Signal()
        self.rand = Signal(ro_elements-1)
        self.gang = Signal()
        self.ena = Signal()

        # build a set of `element` rings, with `stage` stages
        self.trng_slow = Signal()
        for element in range(ro_elements):
            setattr(self, "ro_elem" + str(element), Signal(ro_stages+1))
            setattr(self, "ro_samp" + str(element), Signal())
            for stage in range(ro_stages):
                stagename = 'RINGOSC_E' + str(element) + stage_id + '_S' + str(stage)
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
                self.specials += Instance("FDCE", name='FDCE_E' + str(element) + stage_id,
                    i_D=getattr(self, "ro_elem" + str(element))[0],
                    i_C=ClockSignal(),
                    i_CE=self.gang,
                    i_CLR=0,
                    o_Q=getattr(self, "ro_samp" + str(element))
                )
            if (element != 0) & (element != 32): # element 0 is a special case, handled at end of loop
                self.sync += [
                    If(self.sample_now,
                       self.rand[element].eq(self.rand[element-1]),
                    ).Else(
                        self.rand[element].eq(self.rand[element] ^ (getattr(self, "ro_samp" + str(element)) & self.gang)),
                    )
                ]
            # close feedback loop with enable gate
            setattr(self, "ro_fbk" + str(element), Signal())
            self.comb += [
                getattr(self, "ro_fbk" + str(element)).eq(getattr(self, "ro_elem" + str(element))[ro_stages]
                                                          & self.ena),
            ]

        # build the input tap
        self.specials += Instance("FDCE", name='FDCE_E32' + stage_id,
            i_D=getattr(self, "ro_elem32")[0],
            i_C=ClockSignal(),
            i_CE=1, # element 32 is not part of the gang, it's the output element of the "big loop"
            i_CLR=0,
            o_Q=getattr(self, "ro_samp32")
        )
        self.sync += [
            If(self.sample_now,
                # shift in sample entropy from a tap on the one stage that's not already wired to a gang mixer
                # but still rotate back bits from the top, why throw away good entropy?
                self.rand[0].eq(getattr(self, "ro_samp32") ^ self.rand[31]),
            ).Else(
                self.rand[0].eq(self.rand[0] ^ (getattr(self, "ro_samp0") & self.gang)),
            )
        ]

        # create the switchable meta-ring by muxing on dwell_now
        for element in range(ro_elements):
            if element < ro_elements-1:
                self.comb += getattr(self, "ro_elem" + str(element))[0]\
                                 .eq(  getattr(self, "ro_fbk" + str(element)) & self.dwell_now
                                     | getattr(self, "ro_fbk" + str(element + 1)) & ~self.dwell_now),
            else:
                self.comb += getattr(self, "ro_elem" + str(element))[0]\
                                 .eq(  getattr(self, "ro_fbk" + str(element)) & self.dwell_now
                                     | getattr(self, "ro_fbk" + str(0)) & ~self.dwell_now),

        self.trng_slow = Signal()
        self.trng_fast = Signal()
        self.sync += [self.trng_fast.eq(self.ro_fbk0), self.trng_slow.eq(self.rand[0])]


class TrngRingOscV2Managed(Module, AutoCSR, AutoDoc):
    def __init__(self, platform, cores=4):
        self.intro = ModuleDoc("""
TrngRingOscV2 builds a set of fast oscillators that are allowed to run independently to
gather entropy, and then are merged into a single large oscillator to create a bit of
higher-quality entropy. The idea for this is taken from "Fast Digital TRNG Based on
Metastable Ring Oscillator", with modifications. I actually suspect the ring oscillator
is not quite metastable during the small-ring phase, but it is accumulating phase noise
as an independent variable, so I think the paper's core idea still works.

The system as described above is referred to as a "core". This version is built with {}
parallel cores that are XOR'd simultaneously to generate the final output.

* `self.trng_slow` and `self.trng_fast` are debug hooks for sampled TRNG data and the fast ring oscillator, respectively.
        """.format(cores))
        ### to/from management interface
        self.ena = Signal()
        self.gang = Signal()
        self.dwell = Signal(12)
        self.delay = Signal(10)
        self.rand_out = Signal(32)
        self.rand_read = Signal() # pulse one cycle to indicate rand_out has been read
        self.fresh = Signal()
        self.fuzz = Signal()
        self.oversampling = Signal(8)  # stages to oversample entropy

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
        rand_cnt = Signal(9)
        # keep track of how many bits have been shifted in since the last read-out
        self.sync += [
            If(self.rand_read,
               self.fresh.eq(0),
               self.rand_out.eq(0xDEADBEEF),
            ).Else(
                If(shift_rand,
                    If(rand_cnt < self.rand_out.nbits + self.oversampling +1, # +1 because the very first bit never got sample entropy, just dwell, so we throw it away
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
                If(self.fuzz,
                    NextValue(dwell_cnt, self.dwell + self.rand_out[:5]),
                    NextValue(delay_cnt, self.delay + self.rand_out[:2]),
                ).Else(
                    NextValue(dwell_cnt, self.dwell),
                    NextValue(delay_cnt, self.delay),
                ),
                If(self.ena,
                    NextState("DWELL"),
                ).Else(
                    NextState("IDLE")
                )
            )
        )

        r = Signal(rand.nbits, reset=0) # base case is 0
        for core in range(cores):
            setattr(self.submodules, 'rocore' + str(core), TrngRingOscCore(platform, '_c{}_'.format(core), ro_elements, ro_stages))
            setattr(self, 'rocore' + str(core) + '_rand', Signal(rand.nbits))
            self.comb += [
                getattr(self, 'rocore' + str(core)).sample_now.eq(sample_now),
                getattr(self, 'rocore' + str(core)).dwell_now.eq(dwell_now),
                getattr(self, 'rocore' + str(core)).gang.eq(self.gang),
                getattr(self, 'rocore' + str(core)).ena.eq(self.ena),
            ]
            # fold the results across each core by doing a progressive XOR
            next_r = Signal(rand.nbits)
            self.comb += next_r.eq(r ^ getattr(self, 'rocore' + str(core)).rand)
            r = next_r
        self.comb += rand.eq(r)





# ModNoise ------------------------------------------------------------------------------------------

class ModNoise(Module, AutoCSR, AutoDoc):
    def __init__(self, pads):
        self.intro = ModuleDoc("""Modular Noise generator

        Modular noise generator driver. Generates non-overlapping clocks, and aggregates
        incoming noise.

        Op-amp bandwidth is 1MHz, slew rate of 2V/us. Cap settling time is probably around
        3-4us per phase. Target 4.95us/phase, with a dead time of 50ns between phases. This
        should yield around 200kbps raw noise generation rate, which roughly matches the
        maximum rate at which 256-bit DH key exchanges can be done using the Curve25519 engine.
        """)
        self.phase0 = Signal()
        self.phase1 = Signal()
        self.noiseon = Signal()
        self.noisein = Signal()
        self.noise_read = Signal()
        self.ena = Signal()
        self.comb += [
            pads.phase0.eq(self.phase0),
            pads.phase1.eq(self.phase1),
            pads.noise_on.eq(self.noiseon),
            self.noisein.eq(pads.noise_in),
        ]
        noisesync = Signal()
        self.specials += MultiReg(self.noisein, noisesync)

        ##### NOTE: for testing purposes, the CSR config is put in the module, but should be refactored into the Server address space if used for production
        self.ctl = CSRStorage(fields=[
            CSRField("ena", size=1, description="Power on and enable TRNG.", reset=0),
            CSRField("period", size=20, description="Duration of one phase in sysclk periods", reset=495),
            CSRField("deadtime", size=10, description="Duration of deadtime between nonoverlaps in sysclk periods",
                reset=5),
        ])
        self.comb += self.noiseon.eq(self.ctl.fields.ena | self.ena)
        self.rand = CSRStatus(fields=[
            CSRField("rand", size=32, description="Random data shifted into a register for easier collection",
                reset=0xDEADBEEF),
        ])
        self.status = CSRStatus(fields=[
            CSRField("fresh", size=1,
                description="When set, the rand register contains a fresh set of bits to read; cleared by reading the `rand` register")
        ])

        shift_rand = Signal()
        rand_cnt = Signal(max=self.rand.size + 2)
        rand = Signal(32)
        # keep track of how many bits have been shifted in since the last read-out
        self.sync += [
            If(self.rand.we | ~(self.ctl.fields.ena | self.ena) | self.noise_read,
                self.status.fields.fresh.eq(0),
                self.rand.fields.rand.eq(0xDEADBEEF),
            ).Else(
                If(shift_rand,
                    If(rand_cnt < self.rand.size + 1,
                        rand_cnt.eq(rand_cnt + 1),
                        rand.eq(Cat(noisesync, rand[:-1])),
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

        counter = Signal(self.ctl.fields.period.nbits)
        fsm = FSM(reset_state="RESET")
        self.submodules += fsm
        fsm.act("RESET",
            NextValue(self.phase0, 0),
            NextValue(self.phase1, 0),
            If(self.ctl.fields.ena | self.ena,
                NextValue(counter, self.ctl.fields.deadtime),
                NextState("DEADTIME0"),
            ).Else(
                NextState("RESET")
            )
        )
        fsm.act("DEADTIME0",
            NextValue(self.phase0, 0),
            NextValue(self.phase1, 0),
            If(counter > 0,
                NextValue(counter, counter - 1),
                NextState("DEADTIME0"),
            ).Else(
                NextValue(counter, self.ctl.fields.period),
                NextState("PHASE0"),
            )
        )
        fsm.act("PHASE0",
            NextValue(self.phase0, 1),
            NextValue(self.phase1, 0),
            If(counter > 0,
                NextValue(counter, counter - 1),
                NextState("PHASE0"),
            ).Else(
                NextValue(counter, self.ctl.fields.deadtime),
                NextState("DEADTIME1"),
                shift_rand.eq(1),
            )
        )
        fsm.act("DEADTIME1",
            NextValue(self.phase0, 0),
            NextValue(self.phase1, 0),
            If(counter > 0,
                NextValue(counter, counter - 1),
                NextState("DEADTIME1"),
            ).Else(
                NextValue(counter, self.ctl.fields.period),
                NextState("PHASE1"),
            )
        )
        fsm.act("PHASE1",
            NextValue(self.phase0, 0),
            NextValue(self.phase1, 1),
            If(counter > 0,
                NextValue(counter, counter - 1),
                NextState("PHASE1"),
            ).Else(
                If(self.ctl.fields.ena | self.ena,
                    NextValue(counter, self.ctl.fields.deadtime),
                    NextState("DEADTIME0"),
                    shift_rand.eq(1),
                ).Else(
                    NextState("RESET")
                )
            )
        )

