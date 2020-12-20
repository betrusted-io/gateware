from migen import *
from migen.genlib.cdc import MultiReg

from litex.soc.interconnect.csr import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect.csr_eventmanager import *

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
            CSRField("data", size=32, description="Latest random data from the FIFO; only valid if ``avail`` bit is set")
        ])

        self.submodules.ev = EventManager()
        self.ev.avail = EventSourceLevel(description="Triggered anytime there is data available on the kernel interface")
        self.ev.error = EventSourcePulse(description="Triggered whenever an underrun condition first occurs on the kernel interface")
        self.ev.finalize()


class TrngManagedServer(Module, AutoCSR, AutoDoc):
    def __init__(self):
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
            CSRField("no_check", size=1, description="When set, disables on-line health checking (for power saving)"),
            CSRField("clr_err", size=1, description="Write ``1`` to this bit to clear the ``errors`` register", pulse=True)
        ])

        self.data = CSRStatus(fields=[
            CSRField("data", size=32, description="Latest random data from the FIFO; only valid if available bit is set")
        ])
        self.status = CSRStatus(fields=[
            CSRField("avail", size=1, description="FIFO data is available"),
            CSRField("rdcount", size=10, description="Read fifo pointer"),
            CSRField("wrcount", size=10, description="Write fifo pointer"),
            CSRField("full", size=1, description="Both kernel and server FIFOs have been topped off"),
        ])

        # raw data:
        # https://github.com/betrusted-io/gateware/blob/master/gateware/trng/v_noise_stable.png
        # https://github.com/betrusted-io/gateware/blob/master/gateware/trng/v_ava_poweron.png
        default_samples = 32
        self.av_config = CSRStorage(fields=[
            CSRField("powerdelay", size=20, description="Delay in microseconds for avalanche generator to stabilize", reset=50000),
            CSRField("samples", size=8, description="Number of samples to fold into a single result. Smaller values increase rate but decrease quality. Default is {}.".format(default_samples), reset=default_samples),
            CSRField("test", size=1, description="When set, puts the generator into test mode -- full-size, raw ADC samples are directly placed into the FIFO at full rate, creating a 'virtual oscilloscope' snapshot of the avalanche generator waveform.")
        ])

        self.ro_config = CSRStorage(fields=[
            CSRField("gang", size=1, description="Fold in collective gang entropy during dwell time", reset=1),
            CSRField("dwell", size=12, description="""Prescaler to set dwell-time of entropy collection. 
            Controls the period of how long the oscillators are in a metastable state to collect entropy 
            before sampling. Value encodes the number of sysclk edges to pass during the dwell period.""", reset=100),
            CSRField("delay", size=10, description="""Sampler delay time. Sets the delay between when the small rings
            are merged together, and when the final entropy result is sampled. Value encodes number of sysclk edges
            to pass during the delay period. Delay should be long enough for the signal to propagate around the merged ring,
            but longer times also means more coupling of the deterministic sysclk noise into the rings.""", reset=8),
            CSRField("fuzz", size=1, description="""Modulate the `delay`/`dwell` parameter slightly from run-to-run, 
            based on previous run's random values. May help to break ring oscillator resonances trained by the delay/dwell periodicity.""", reset=1),
            CSRField("oversampling", size=8, description="""Number of stages to oversample entropy. Normally, each bit is just
            sampled and shifted once (so 32 times for 32-bit word). Each increment of oversampling will add another stage.""", reset=0)
        ])

        self.errors = CSRStatus(fields=[
            CSRField("server_underrun", size=10, description="If non-zero, a server underrun has occurred. Will count number of underruns up to max field size"),
            CSRField("kernel_underrun", size=10, description="If non-zero, a kernel underrun has occurred. Will count number of underruns up to max field size"),
            CSRField("ro_health", size=1, description="When `1`, Ring oscillator has failed an on-line health test"),
            CSRField("av_health", size=1, description="When `1`, Avalanche generator has failed an on-line health test"),
        ])

        self.submodules.ev = EventManager()
        self.ev.avail = EventSourceLevel(description="Triggered anytime there is data available on the server interface")
        self.ev.error = EventSourcePulse(description="Triggered whenever an error condition first occurs on the server interface")
        self.ev.health = EventSourcePulse(description="Triggered whenever a health event first occurs")
        self.ev.finalize()


class TrngOnlineCheck(Module, AutoDoc):
    def __init__(self):
        self.intro = ModuleDoc("""
This is a placeholder for online health checks on the TRNG. Right now we just check for very gross
errors (stuck state). Do not rely on the output of this until it has been made more robust!

The "TrngOnlineCheck" module should be customized into a module for the ring oscillator, and for
the avalanche generator, as they have very different mechanisms for generating numbers, and therefore
very different failure modes.

- For the ring oscillator, it should check for runs of bits both over a single 32-bit word, but also
individual bits over time. "Long runs" in either direction (probably best to define the threshold as a CSR
that can be set) will trigger a health alert. A run is minimally defined as a 1-bit pattern, but probably
should include at least 2-3 bit patterns if feasible. This basically checks if a ring oscillator "slows down" to
a rate that is not commensurate with the expected entropy rate, or if it stabilizes too much to be generating
entropy. 

- For the avalanche generator, it should extract the raw noise values from the avalanche output in test mode, and use those
to update a min/max window over time. If the min/max window is not exceeded over a period of time, we can
conclude that the avalanche process has ceased. The size of the min/max window, again, should be user-configurable.
This will catch the failure case that the avalanche diode 'wears out', and will also catch the failure case that
the bias generator's voltage is not high enough for some reason. It will not catch the case of e.g. periodic
noise deliberately injected into the TRNG in an attempt to override the TRNG's natural behavior.

- The OPSO/OQSO tests seem to be the hardest for both TRNGs to pass, probably due to systemic, fixed biases
in e.g. ADC bits and/or ring oscillator rates causing certain code-pairs to be less frequent. A truncated 
version of OPSO/OQSO could be pretty useful for measuring the health of the TRNG. 4xRAMB36 blocks could 
store a portion of the OPSO sampling matrix, giving a total of 16 x 1024 "lines" of the 1024x1024 total 
OPSO matrix. Summing results over hundreds of runs into even this sub-portion of the matrix should 
eventually lead to a normal distribution of values, and shifts in the mean and spread can give 
hints into the amount of systemic bias a given ring oscillator could be showing. As of the writing 
of this comment, there are 24x RAMB36's available in the FPGA still.
        """)
        self.enable = Signal()
        self.healthy = Signal() # if currently healthy or not
        self.rand = Signal(32)  # the random number to check
        self.update = Signal()  # update the health checker state

        last_rand = Signal(32)
        self.sync += [
            If(self.enable,
                If(self.update,
                    last_rand.eq(self.rand)
                ),
                If(last_rand == self.rand,
                    self.healthy.eq(0)
                ).Else(
                    self.healthy.eq(1)
                )
            )
        ]


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
        rand_cnt = Signal(max=self.rand.size + 1)
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


class TrngManaged(Module, AutoCSR, AutoDoc):
    def __init__(self, platform, analog_pads, noise_pads, kernel, server, sim=False, revision='pvt'):
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

        if revision == 'pvt':
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
            self.submodules.xadc = TrngXADC(analog_pads, sim)
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
            self.submodules.ringosc = TrngRingOscV2Managed(platform)
        else:
            self.submodules.ringosc = TrngRingOscSim() # fake source for simulation purposes
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

        ## Add the health checkers and interrupts
        self.submodules.ro_health = TrngOnlineCheck()
        self.submodules.av_health = TrngOnlineCheck()
        self.comb += [
            self.av_health.enable.eq(~server.control.fields.no_check & av_powerstate),
            self.av_health.rand.eq(av_noiseout),
            self.av_health.update.eq(av_noiseout_read),
            self.ro_health.enable.eq(~server.control.fields.no_check & self.ringosc.ena),
            self.ro_health.rand.eq(ro_rand),
            self.ro_health.update.eq(ro_rand_read),
        ]
        health_issue = Signal()
        self.sync += [
            If(server.errors.we,
                server.errors.fields.ro_health.eq(0),
                server.errors.fields.av_health.eq(0),
            ).Else(
                If(~self.ro_health.healthy,
                    server.errors.fields.ro_health.eq(1),
                ).Else(
                    server.errors.fields.ro_health.eq(server.errors.fields.ro_health)
                ),
                If(~self.av_health.healthy,
                    server.errors.fields.av_health.eq(1),
                ).Else(
                    server.errors.fields.av_health.eq(server.errors.fields.av_health)
                )
            ),
            health_issue.eq(server.errors.fields.av_health | server.errors.fields.ro_health),
            server.ev.health.trigger.eq(~health_issue & (server.errors.fields.av_health | server.errors.fields.ro_health))
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
            i_RST=ResetSignal(),
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
                server.errors.fields.server_underrun.eq(0)
            ).Else(
                If(server_fifo_rden & server_fifo_empty,
                    If(server.errors.fields.server_underrun < 0x3FF,
                        server.errors.fields.server_underrun.eq(server.errors.fields.server_underrun + 1)
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
            i_RST=ResetSignal(),
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
        self.comb += [
            kernel.ev.avail.trigger.eq(~kernel_fifo_empty),
            kernel.ev.error.trigger.eq(kernel_fifo_rderr), # this should only pulse when RE is triggered; it should not be stuck at a level
            If(~kernel_fifo_empty,
                kernel_fifo_rden.eq(kernel.data.we),
                kernel.data.fields.data.eq(kernel_fifo_dout),
            ).Else(
                kernel.data.fields.data.eq(0xDEADBEEF),
            ),
            kernel.status.fields.rdcount.eq(kernel_fifo_rdcount),
            kernel.status.fields.wrcount.eq(kernel_fifo_wrcount),
            kernel.status.fields.avail.eq(~kernel_fifo_empty),
        ]
        self.sync += [
            If(server.control.fields.clr_err,
                server.errors.fields.kernel_underrun.eq(0)
            ).Else(
                If(kernel_fifo_rden & kernel_fifo_empty,
                    If(server.errors.fields.kernel_underrun < 0x3FF,
                        server.errors.fields.kernel_underrun.eq(server.errors.fields.kernel_underrun + 1)
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
                    NextState("PUMP")
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
            If(av_powerstate & av_configured,  # ring oscillator is "instant-on", so we just need to check avalanche generator's power state
                NextState("PUMP"),
                NextValue(av_config_noise, 0),  # prep for next av_reconfigure pulse
            )
        )
        refill.act("PUMP", # discard the first value out of the TRNG, as it's potentially biased by power-on effects
            # do pump here
            If((av_noiseout_ready | server.control.fields.av_dis) & (ro_fresh | server.control.fields.ro_dis),
                av_noiseout_read.eq(1),
                ro_rand_read.eq(1),
                NextState("REFILL_KERNEL")
            )
        )
        refill.act("REFILL_KERNEL",
            If(kernel_fifo_full,
                NextState("REFILL_SERVER")
            ).Else(
                If((av_noiseout_ready | server.control.fields.av_dis) & (ro_fresh | server.control.fields.ro_dis),
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
                If((av_noiseout_ready | server.control.fields.av_dis) & (ro_fresh | server.control.fields.ro_dis),
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

analog_layout = [("vauxp", 16), ("vauxn", 16), ("vp", 1), ("vn", 1)]

class TrngXADC(Module, AutoCSR):
    def __init__(self, analog_pads=None, sim=False):
        # Temperature
        self.temperature = CSRStatus(12, description="""Raw Temperature value from XADC.\n
            Temperature (°C) = ``Value`` x 503.975 / 4096 - 273.15.""")

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
            p_INIT_48=0x4701, p_INIT_49=0xd050,
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
        channels = {
            0: self.temperature,
            1: self.vccint,
            2: self.vccaux,
            6: self.vccbram,
            20: self.noise1,
            22: self.vbus,
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
        # configure for round-robin sampling of all system parameters (this is default)
        sense_table = {
            0: 0x410EF0, # set sequencer default mode -- allows updating of Sequencer
            1: 0x484701, # Seq 0: Aux Int Bram Temp Cal
            2: 0x49D050, # Seq 1: Vaux15 (usbn) Vaux14 (usbp) Vaux12 (noise0) Vaux6 (vbus) Vaux4 (noise1)
            3: 0x4A4701, # Average aux int bram temp cal
            4: 0x4BC040, # Average all but noise (c040)
            5: 0x412EF0,
            6: 0x409000, # Average by 16 samples
            7: 0x420420,
        }
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

class TrngRingOscSim(Module, AutoDoc):
    def __init__(self):
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

        delay = Signal(4, reset=15)
        self.sync += [
            If(self.ena,
                If(self.rand_read,
                    self.fresh.eq(0),
                    delay.eq(15),
                    self.rand_out.eq(self.rand_out),
                ).Else(
                    If(delay == 1,
                        delay.eq(delay - 1),
                        self.rand_out.eq(self.rand_out + 1),
                        self.fresh.eq(1),
                    ).Elif(delay != 0,
                        delay.eq(delay - 1),
                        self.fresh.eq(self.fresh),
                        self.rand_out.eq(self.rand_out),
                    ).Else(
                        delay.eq(delay),
                        self.fresh.eq(self.fresh),
                        self.rand_out.eq(self.rand_out),
                    )
                )
            )
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
        rand_cnt = Signal(max=self.rand_out.nbits+1+8)
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
                # shift in sample entropy from a tap on the one stage that's not already wired to a gang mixer
                # but still rotate back bits from the top, why throw away good entropy?
                rand[0].eq(getattr(self, "ro_samp32") ^ rand[31]),
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

