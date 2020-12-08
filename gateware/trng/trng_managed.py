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
        self.ev.error = EventSourcePulse(description="Triggered whenever an underrun condition first occurs on the user interface")
        self.ev.finalize()


class TrngManagedPriv(Module, AutoCSR, AutoDoc):
    def __init__(self):
        self.refill_mark = 512  # point at which manager automatically powers on the block and refills the FIFO

        self.intro = ModuleDoc("""
Kernel-private register interface for the TrngManaged core. Must be created as a submodule in
the top-level SoC and passed to TrngManaged as an argument.
        """)
        self.control = CSRStorage(fields=[
            CSRField("enable", size=1, description="Power on the management interface and auto-fill random numbers"),
            CSRField("ro_dis", size=1, description="When set, disables the ring oscillator as an entropy source"),
            CSRField("av_dis", size=1, description="When set, disables the avalanche generator as an entropy source"),
            CSRField("powersave", size=1, description="When set, TRNGs are automatically turned off until low water mark of {} entries is hit; when cleared, TRNGs are always on".format(self.refill_mark), reset=1),
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
        ])

        self.av_config = CSRStorage(fields=[
            CSRField("powerdelay", size=20, description="Delay in microseconds for avalanche generator to stabilize", reset=200000)
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
            CSRField("priv_underrun", size=10, description="If non-zero, a privileged underrun has occurred. Will count number of underruns up to max field size"),
            CSRField("user_underrun", size=10, description="If non-zero, a user underrun has occurred. Will count number of underruns up to max field size"),
            CSRField("ro_health", size=1, description="Ring oscillator has failed an on-line health test"),
            CSRField("av_health", size=1, description="Avalanche generator has failed an on-line health test"),
        ])

        self.submodules.ev = EventManager()
        self.ev.avail = EventSourceLevel(description="Triggered anytime there is data available on the privileged interface")
        self.ev.error = EventSourcePulse(description="Triggered whenever an error condition first occurs on the privileged interface")
        self.ev.finalize()


class TrngManaged(Module, AutoCSR, AutoDoc):
    def __init__(self, platform, analog_pads, priv, user):
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

The refill mark is configured at {} entries.
        """.format(priv.refill_mark))
        refill_needed = Signal()

        # todo: refactor noisebias/noise power pads to end up in this interface
        # external avalanche generators should be powered down when block is disabled
        # we're also going to need a power-up delay timer based on `refill_needed`
        # we're going to need an FSM that:
        #  1. checks if refill_needed
        #  2. powers on generators
        #  3. clears stale values
        #  4. samples from ro & av (depending on enablement status), and XORs them and puts into queue when both become available
        #  5. when FIFO Is full, powers down the blocks
        # we also need a "health checker" primitive -- initially just a simple repeating value checker
        self.submodules.xadc = TrngXADC(analog_pads)
        av_noise0_read = Signal()
        av_noise1_read = Signal()
        av_noise0_fresh = Signal()
        av_noise1_fresh = Signal()
        av_noise0_data = Signal(12)
        av_noise1_data = Signal(12)
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

        self.submodules.ringosc = TrngRingOscV2Managed(platform)
        # pass-through config and mangamement signals to the RO
        ro_rand = Signal(32)
        ro_fresh = Signal()
        ro_rand_read = Signal()
        self.comb += [
            self.ringosc.ena.eq( (~priv.control.fields.ro_dis & priv.control.fields.enable) & (refill_needed | ~priv.control.fields.powersave) ),
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
        priv_fifo_almostempty = Signal()
        self.specials += Instance("FIFO_SYNC_MACRO",
            p_DEVICE="7SERIES",
            p_FIFO_SIZE="36Kb",
            p_DATA_WIDTH=32,
            p_ALMOST_EMPTY_OFFSET=priv.refill_mark,
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
            o_ALMOSTEMPTY=priv_fifo_almostempty,
        )
        self.comb += [
            priv.ev.avail.trigger.eq(~priv_fifo_empty),
            priv.ev.error.trigger.eq(priv_fifo_rderr), # this should only pulse when RE is triggered; it should not be stuck at a level
            If(~priv_fifo_empty,
                priv_fifo_rden.eq(priv.data.re),
                priv.data.fields.data.eq(priv_fifo_dout),
            ).Else(
                priv.data.fields.data.eq(0xDEADBEEF),
            ),
            priv.status.fields.rdcount.eq(priv_fifo_rdcount),
            priv.status.fields.wrcount.eq(priv_fifo_wrcount),
            priv.status.fields.avail.eq(~priv_fifo_empty),
        ]
        self.sync += [
            If(priv.control.fields.clr_err,
                priv.errors.fields.priv_underrun.eq(0)
            ).Else(
                If(priv_fifo_rden & priv_fifo_empty,
                    If(priv.errors.fields.priv_underrun < 0x3FF,
                        priv.errors.fields.priv_underrun.eq(priv.errors.fields.priv_underrun + 1)
                    )
                )
            )
        ]

        ## user fifo
        user_fifo_full = Signal()
        user_fifo_empty = Signal()
        user_fifo_wren = Signal()
        user_fifo_din = Signal(32)
        user_fifo_rden = Signal()
        user_fifo_dout = Signal(32)
        user_fifo_rdcount = Signal(10)
        user_fifo_rderr = Signal()
        user_fifo_wrcount = Signal(10)
        user_fifo_almostempty = Signal()
        self.specials += Instance("FIFO_SYNC_MACRO",
            p_DEVICE="7SERIES",
            p_FIFO_SIZE="36Kb",
            p_DATA_WIDTH=32,
            p_ALMOST_EMPTY_OFFSET=priv.refill_mark,
            p_ALMOST_FULL_OFFSET=1024-8,
            p_DO_REG=0,
            i_CLK=ClockSignal(),
            i_RST=ResetSignal(),
            o_FULL=user_fifo_full,
            o_EMPTY=user_fifo_empty,
            i_WREN=user_fifo_wren,
            i_DI=user_fifo_din,
            i_RDEN=user_fifo_rden,
            o_DO=user_fifo_dout,
            o_RDCOUNT=user_fifo_rdcount,
            o_RDERR=user_fifo_rderr,
            o_WRCOUNT=user_fifo_wrcount,
            o_ALMOSTEMPTY=user_fifo_almostempty,
        )
        self.comb += [
            user.ev.avail.trigger.eq(~user_fifo_empty),
            user.ev.error.trigger.eq(user_fifo_rderr), # this should only pulse when RE is triggered; it should not be stuck at a level
            If(~user_fifo_empty,
                user_fifo_rden.eq(user.data.re),
                user.data.fields.data.eq(user_fifo_dout),
            ).Else(
                user.data.fields.data.eq(0xDEADBEEF),
            ),
            user.status.fields.rdcount.eq(user_fifo_rdcount),
            user.status.fields.wrcount.eq(user_fifo_wrcount),
            user.status.fields.avail.eq(~user_fifo_empty),
        ]
        self.sync += [
            If(priv.control.fields.clr_err,
                priv.errors.fields.user_underrun.eq(0)
            ).Else(
                If(user_fifo_rden & user_fifo_empty,
                    If(priv.errors.fields.user_underrun < 0x3FF,
                        priv.errors.fields.user_underrun.eq(priv.errors.fields.user_underrun + 1)
                    )
                )
            )
        ]

        self.comb += [
            refill_needed.eq(user_fifo_almostempty | priv_fifo_almostempty)
        ]

analog_layout = [("vauxp", 16), ("vauxn", 16), ("vp", 1), ("vn", 1)]

class TrngXADC(Module, AutoCSR):
    def __init__(self, analog_pads=None):
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
        channel = Signal(7)
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
        self.specials += Instance("XADC",
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
        self.comb += [
            If(~drp_en & self.configured,
                den.eq(eoc),  # auto-read the output of the converter
                dadr.eq(channel),
            )
        ]

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
            If(self.noise0.re | self.noise0_read,
                self.noise0_fresh.eq(0)
            ).Else(
                If(channel == 28 & drdy & self.configured & ~drp_en,
                    self.noise0_fresh.eq(1)
                ).Else(
                    self.noise0_fresh.eq(self.noise0_fresh)
                )
            ),
            If(self.noise1.re | self.noise1_read,
                self.noise1_fresh.eq(0)
            ).Else(
                If(channel == 20 & drdy & self.configured & ~drp_en,
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
            local_dadr.eq(romval[16:]),
        ]
        romadr = Signal(3) # up to 8 entries in the sequence
        self.noise_mode = Signal()
        # configure for fast-sampling of noise
        noise_table = {
            0: 0x410EF0, # set sequencer default mode -- allows updating of Sequencer
            1: 0x480000, # Seq 0: none
            2: 0x491010, # Seq 1: Vaux12 (noise0) and Vaux4 (noise1)
            3: 0x4A0000, # Avg 0: no averaging
            4: 0x4B0000, # Avg 1: no averaging
            5: 0x412EF0, # continuous mode, disable most alarms
            6: 0x408000, # don't use averaging
            7: 0x420420, # adc B off, divide DCLK by 4
        }
        # configure for round-robin sampling of all system parameters (this is default)
        sense_table = {
            0: 0x410EF0, # set sequencer default mode -- allows updating of Sequencer
            1: 0x484701, # Seq 0: Aux Int Bram Temp Cal
            2: 0x49D050, # Seq 1: Vaux15 (usbn) Vaux14 (usbp) Vaux12 (noise0) Vaux6 (vbus) Vaux4 (noise1)
            3: 0x4A4701, # Average aux int bram temp cal
            4: 0x4BC040, # Average all but noise
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
            self.configured.eq(1),
            NextValue(romadr, 0),
            If(self.config_noise,
                NextValue(self.noise_mode, 1),  # select noise table
            ).Else(
                NextValue(self.noise_mode, 0),  # select sense table
            ),
            If(self.reconfigure & ~reconfigure_r,
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
                If(~drdy,
                    NextState("LOAD_DRP")
                )
            )
        )



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

