from migen import *
from migen.genlib.cdc import MultiReg

from litex.soc.interconnect.csr import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc

class TrngRingOsc(Module, AutoCSR, AutoDoc):
    def __init__(self, platform, target_freq=1e6, rng_shift_width=32, make_pblock=False):
        self.intro = ModuleDoc("""
TrngRingOsc builds a set of ring oscillators. One is the "slow" oscillator, which circumscribes
the die, and attempts to hit the target_freq supplied as a parameter. The others are a "fast" oscillator,
which is typically targeted to run in the 50-300MHz range. The idea
is to have the "fast" oscillator sample at a period that is faster than the average jitter picked
up by the slow oscillator as it circumscribes the die. Thus, if the quality of entropy is not good
enough, the fix is to slow down the target_freq parameter.

* self.trng_raw is the unsynchronized output TRNG stream
* self.trng_out_sync is the TRNG stream, but jammed through a sysclk synchronizer
* self.trng_slow and self.trng_fast are debug hooks for checking the ring oscillators  
        """)
        devstr = platform.device.split('-')
        device_root = devstr[0]
        if devstr[1] == 'up5k':
            device_root = device_root + devstr[1]

        self.trng_raw = Signal()  # raw TRNG output bitstream
        self.trng_aux1r = Signal() # aux streams for more decorrelated data
        self.trng_aux2r = Signal()
        self.trng_aux3r = Signal()
        self.trng_out_sync = Signal()  # single-bit output, synchronized to sysclk
        self.ctl = CSRStorage(fields=[
            CSRField("ena", size=1, description="Enable the TRNG; 0 puts the TRNG into full powerdown", reset=0)
        ])
        self.rand = CSRStatus(fields=[
            CSRField("rand", size=rng_shift_width, description="Random data shifted into a register for easier collection. Width set by rng_shift_width parameter.")
        ])
        self.status = CSRStatus(fields=[
            CSRField("fresh", size=1, description="When set, the rand register contains a fresh set of bits to be read; cleaned by reading the `rand` register")
        ])

        rand_strobe = Signal()
        rand_strobe_r = Signal()
        rand_cnt = Signal(max=self.rand.size)
        self.sync += [
            rand_strobe_r.eq(rand_strobe),

            If(self.rand.we,
               rand_cnt.eq(0),
               self.status.fields.fresh.eq(0)
            ).Else(
                If(rand_strobe & ~rand_strobe_r,
                    self.rand.fields.rand.eq(Cat(self.trng_out_sync,self.rand.fields.rand[:-1])),
                    If(rand_cnt < self.rand.size - 1,
                       rand_cnt.eq(rand_cnt + 1),
                       self.status.fields.fresh.eq(0)
                    ).Else(
                       self.status.fields.fresh.eq(1)
                    )
                )
            )
        ]

        target_period = (1/target_freq)*1e9  # period is in ns

        # make osc available for debug
        self.trng_fast = Signal()
        self.trng_slow = Signal()

        if device_root == 'xc7s50':
            stage_delay = 1.7  # rough delay of each ring oscillator stage (incl routing) in ns
            fast_stages = 1
            aux1_stages = 3
            aux2_stages = 5
            aux3_stages = 7

            # routing oscillator slightly through core logic adds more noise, but can impact performance
            x_min = 53     # 0
            x_max = 57     # 65 for clock region X*Y0, X*Y1; 56 for clock region X*Y2
            y_min = 0
            y_max = 149    # <99 for lower region (Y0/Y1); 149 includes Y2 if you limit x_max to below 56
        elif device_root == 'ice40up5k':
            stage_delay = 11  # rough delay of each ring oscillator stage (incl routing) in ns
            fast_stages = 1

            x_min = 1
            x_max = 22
            y_min = 1
            y_max = 30
        else:
            print("TrngRingOsc: unsupported device " + device_root)
            return

        x_mid = (x_max + x_min) // 2
        y_mid = (y_max + y_min) // 2
        y_span = y_max - y_min
        x_span = x_max - x_min

        stages = int((target_period / stage_delay) + 1)
        if stages % 2 == 0:
            stages = stages + 1
        ring_cw = Signal(stages+1) # ring oscillator clockwise
        ring_ccw = Signal(fast_stages+1) # ring oscillator counter-clockwise (fast)
        ring_aux1r = Signal(aux1_stages+1)
        ring_aux2r = Signal(aux2_stages+1)
        ring_aux3r = Signal(aux3_stages+1)

        x = x_min
        y = y_min

        for stage in range(stages):
            stagename = 'RINGOSC_CW' + str(stage)

            if device_root == 'xc7s50':
                platform.toolchain.attr_translate[stagename + 'LOCK'] = ("LOC", "SLICE_X" + str(x) + 'Y' + str(y))
                self.specials += Instance("LUT1",
                                 name=stagename,
                                 p_INIT=1,
                                 i_I0=ring_cw[stage+1],
                                 o_O=ring_cw[stage],
                                 attr=("KEEP", "DONT_TOUCH", stagename + 'LOCK')
                             )
                if stage < fast_stages:
                    stagename = 'RO_CCW' + str(stage) # don't bind to pblock
                    # don't lock the fast oscillator; this helps de-correlate it from the big oscillator
                    #platform.toolchain.attr_translate[stagename + 'LOCK'] = ("LOC", "SLICE_X" + str(x) + 'Y' + str(y))
                    self.specials += Instance("LUT1",
                                     name=stagename,
                                     p_INIT=1,
                                     i_I0=ring_ccw[stage],
                                     o_O=ring_ccw[stage+1],
                                     # attr=("KEEP", "DONT_TOUCH")
                                 )
                if stage < aux1_stages:
                    stagename = 'RO_AUX1R' + str(stage)
                    # run this one around the chip a bit
                    platform.toolchain.attr_translate[stagename + 'LOCK'] = ("LOC", "SLICE_X" + str(x) + 'Y' + str(y))
                    self.specials += Instance("LUT1",
                        name=stagename,
                        p_INIT=1,
                        i_I0=ring_aux1r[stage],
                        o_O=ring_aux1r[stage+1],
                        attr=("KEEP", "DONT_TOUCH", stagename + 'LOCK'),
                    )
                if stage < aux2_stages:
                    stagename = 'RO_AUX2R' + str(stage)
                    # this one is local
                    self.specials += Instance("LUT1",
                        name=stagename,
                        p_INIT=1,
                        i_I0=ring_aux2r[stage],
                        o_O=ring_aux2r[stage+1],
                        attr=("KEEP", "DONT_TOUCH"),
                    )
                if stage < aux3_stages:
                    stagename = 'RO_AUX3R' + str(stage)
                    # this one is local
                    self.specials += Instance("LUT1",
                        name=stagename,
                        p_INIT=1,
                        i_I0=ring_aux3r[stage],
                        o_O=ring_aux3r[stage+1],
                        attr=("KEEP", "DONT_TOUCH"),
                    )


            elif device_root == 'ice40up5k':
                platform.toolchain.attr_translate[stagename + 'LOCK'] = ("BEL", "X" + str(x) + '/Y' + str(y) + '/lc0')
                self.specials += Instance("SB_LUT4",
                                          p_LUT_INIT=1,
                                          o_O=ring_cw[stage],
                                          i_I0=ring_cw[stage+1],
                                          i_I1=0,
                                          i_I2=0,
                                          i_I3=0,
                                          attr=("KEEP", "DONT_TOUCH", stagename + 'LOCK')
                                          )
                if stage < fast_stages:
                    stagename = 'RINGOSC_CCW' + str(stage)
                    # initially, share the CLB -- but see if performance is better if the LUTs are spread farther apart
                    platform.toolchain.attr_translate[stagename + 'LOCK'] = ("BEL", "X" + str(x) + '/Y' + str(y) + '/lc1')
                    self.specials += Instance("SB_LUT4",
                                              p_LUT_INIT=1,
                                              o_O=ring_ccw[stage+1],
                                              i_I0=ring_ccw[stage],
                                              i_I1=0,
                                              i_I2=0,
                                              i_I3=0,
                                              attr=("KEEP", "DONT_TOUCH", stagename + 'LOCK')
                                              )

            # spiral the pattern of LUTs counter-clockwise, starting at the lower left:
            #  (0,ymax)   (xmax, ymax)
            #  (0,0)      (xmax, 0)
            # we stride in on the Y-axis, and once we hit the middle, we stride in on the X-axis
            if x <= x_mid and y <= y_mid: # lower left, go right
                x = x + x_span
            elif x > x_mid and y <= y_mid: # lower right, go up
                y = y + y_span
                if y <= y_mid:  # we hit the middle
                    x = x - 1
                    x_span = x_span - 2
                    y = y_min
                    y_span = y_max - y_min
                else:
                    y_span = y_span - 1

            elif x > x_mid and y > y_mid: # upper right, go left
                x = x - x_span
            else: # upper left, go down to origin + lap
                y = y - y_span
                if y > y_mid:  # we hit the middle
                    x = x + 1
                    x_span = x_span - 2
                    y = y_max
                    y_span = y_max - y_min
                else:
                    y_span = y_span - 1


        # close the rings with a power gate
        self.comb += ring_cw[stages].eq(ring_cw[0] & self.ctl.fields.ena)
        self.comb += ring_ccw[0].eq(ring_ccw[fast_stages] & self.ctl.fields.ena)
        if device_root == 'xc7s50':
            self.comb += ring_aux1r[0].eq(ring_aux1r[aux1_stages] & self.ctl.fields.ena)
            self.comb += ring_aux2r[0].eq(ring_aux2r[aux2_stages] & self.ctl.fields.ena)
            self.comb += ring_aux3r[0].eq(ring_aux3r[aux3_stages] & self.ctl.fields.ena)

        # instantiate the noise slicing flip flop explicitly, don't leave it up to synthesizer to pick a part
            if device_root == 'xc7s50':
                self.specials += Instance("FDCE", name="RO_FDCE",
                # name it so it doesn't get pulled into pblock, helps decorrelate noise
                i_C=ring_cw[int(stages // 2)],
                i_D=ring_ccw[0],
                i_CE=self.ctl.fields.ena,
                i_CLR=0,
                o_Q=self.trng_raw,
            )
            self.specials += Instance("FDCE", name="RO_AUX1_FDCE",
                         i_C=ring_cw[int(stages//4)],
                         i_D=ring_aux1r[0],
                         i_CE=self.ctl.fields.ena,
                         i_CLR=0,
                         o_Q=self.trng_aux1r,
                         )
            self.specials += Instance("FDCE", name="RO_AUX2_FDCE",
                # name it so it doesn't get pulled into pblock, helps decorrelate noise
                i_C=ring_cw[int(stages // 3)],
                i_D=ring_aux2r[0],
                i_CE=self.ctl.fields.ena,
                i_CLR=0,
                o_Q=self.trng_aux2r,
            )
            self.specials += Instance("FDCE", name="RO_AUX3_FDCE",
                i_C=ring_cw[int(3 * (stages // 5))],
                i_D=ring_aux3r[0],
                i_CE=self.ctl.fields.ena,
                i_CLR=0,
                o_Q=self.trng_aux3r,
            )
        elif device_root == 'ice40up5k':
            self.specials += Instance("SB_DFFE",
                         i_C=ring_cw[int(stages//2)],
                         i_D=ring_ccw[0], # ccw is fast, ideally, [period of fast osc] < [jitter of slow osc]
                         i_E=self.ctl.fields.ena,
                         o_Q=self.trng_raw,
                         )

        # add multi-regs to synchronize the noise to sysclk
        self.specials += MultiReg(ring_cw[int(stages // 2)], rand_strobe)
        if device_root == 'ice40up5k':
            self.specials += MultiReg(self.trng_raw, self.trng_out_sync)
        elif device_root == 'xc7s50':
            ro0 = Signal()
            ro1 = Signal()
            ro2 = Signal()
            ro3 = Signal()
            self.specials += MultiReg(self.trng_raw, ro0)
            self.specials += MultiReg(self.trng_aux1r, ro1)
            self.specials += MultiReg(self.trng_aux2r, ro2)
            self.specials += MultiReg(self.trng_aux3r, ro3)
            self.comb += self.trng_out_sync.eq(ro0 ^ ro1 ^ ro2 ^ ro3)

        # wire up debug
        self.comb += [
            self.trng_slow.eq(ring_cw[0]),
            self.trng_fast.eq(ring_ccw[0])
        ]

        if make_pblock & (device_root == 'xc7s50'):
            platform.add_platform_command("create_pblock ringosc")
            platform.add_platform_command('resize_pblock [get_pblocks ringosc] -add ' + '{{' + 'SLICE_X{}Y{}'.format(x_min, y_min) + ':' + 'SLICE_X{}Y{}'.format(x_max, y_max) + '}}')
            #platform.add_platform_command("set_property CONTAIN_ROUTING true [get_pblocks ringosc]") # don't contain routing -- we want coupling
            platform.add_platform_command("add_cells_to_pblock [get_pblocks ringosc] [get_cells RINGOSC*]")

        if device_root == 'xc7s50':
            platform.add_platform_command("set_disable_timing -from I0 -to O RINGOSC_CW2")
            platform.add_platform_command("set_disable_timing -from I0 -to O RO_CCW0")
            platform.add_platform_command("set_disable_timing -from I0 -to O RO_AUX1R0")
            platform.add_platform_command("set_disable_timing -from I0 -to O RO_AUX2R0")
            platform.add_platform_command("set_disable_timing -from I0 -to O RO_AUX3R0")
