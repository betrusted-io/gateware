from migen import *
from migen.genlib.cdc import BlindTransfer

from litex.soc.interconnect.csr import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect import wishbone
from litex.soc.interconnect.csr_eventmanager import *

import os

class ChaChaConditioner(Module, AutoCSR, AutoDoc):
    def __init__(self, platform):
        self.intro = ModuleDoc(title="ChaCha cipher", body="""
This is the Litex wrapper for the ChaCha block vendored in from
https://github.com/secworks/chacha/commit/2636e87a7e695bd3fa72981b43d0648c49ecb10d

        """)
        self.seed = Signal(32)  # input / a steady drip of new data to add to the entropy pool
        self.seed_req = Signal()  # output / indicates this block is requesting a seed value.
        self.seed_gnt = Signal()  # input / indicates seed request has been granted. this causes _req to drop, starting a new cycle.
        self.userdata = Signal(32) # input / whatever user-provided data for seeding (optional)
        self.seed_now = Signal() # input / a single-cycle pulse that applies the userdata value. ignored until ready is asserted.
        self.ready = Signal()    # output / indicates all seeding operations are done
        self.reseed_interval = Signal(12) # input / indicates how many ChaCha rounds we can generate before demanding a reseed. 0 means never auto-reseed.

        self.advance_a = Signal()   # input / a single-cycle pulse that advances the value of output_a
        self.output_a = Signal(32)  # output / one of two output ports
        self.valid_a = Signal()     # output / when high, the value on output_a is valid

        self.advance_b = Signal()   # input / a single-cycle pulse that advances the value of output_b
        self.output_b = Signal(32)  # output / second of two output ports
        self.valid_b = Signal()     # output / when high, the value on output_a is valid

        self.selfmix_ena = Signal()     # input / enables opportunistic self-mixing in the background
        self.selfmix_interval = Signal(16)  # input / sysclk cycles in between opportunistic self mixings; for power savings

        # rename so we can easily isolate non-critical path input to avoid false timing dependencies
        userdata_local = Signal(self.userdata.nbits)
        seed_now_local = Signal()
        reseed_interval_local = Signal(self.reseed_interval.nbits)
        selfmix_ena_local = Signal()
        selfmix_interval_local = Signal(self.selfmix_interval.nbits)
        self.comb += [
            userdata_local.eq(self.userdata),
            seed_now_local.eq(self.seed_now),
            reseed_interval_local.eq(self.reseed_interval),
            selfmix_ena_local.eq(self.selfmix_ena),
            selfmix_interval_local.eq(self.selfmix_interval),
        ]

        # local signals from the output of the system
        advance_a_local = Signal()
        output_a_local = Signal(32)
        valid_a_local = Signal()
        advance_b_local = Signal()
        output_b_local = Signal(32)
        valid_b_local = Signal()
        # now, create a pipeline (more correctly, a depth-1 fifo) to isolate the CPU's r/w path from the shifter logic
        # the problem is that we're pulsing the advancement of the output shifter based upon a single-cycle combinational path
        # that originates deep inside the CPU load/store pipe. This becomes an unecessary critical path, so introducing
        # this logic here will relax that over-constraint
        outafsm = FSM(reset_state="FILL")
        self.submodules += outafsm
        outafsm.act("FILL",
            If(valid_a_local,
                NextValue(self.output_a, output_a_local),
                NextValue(self.valid_a, valid_a_local),
                NextState("PIPE"),
                NextValue(advance_a_local, 1)
            ).Else(
                NextValue(advance_a_local, 0)
            )
        )
        outafsm.act("PIPE",
            If(self.advance_a,
                NextValue(self.output_a, output_a_local),
                NextValue(self.valid_a, valid_a_local),
                NextValue(advance_a_local, 1)
            ).Else(
                NextValue(advance_a_local, 0)
            ),
            If(~self.valid_a,
                NextState("FILL")
            )
        )
        outbfsm = FSM(reset_state="FILL")
        self.submodules += outbfsm
        outbfsm.act("FILL",
            If(valid_b_local,
                NextValue(self.output_b, output_b_local),
                NextValue(self.valid_b, valid_b_local),
                NextState("PIPE"),
                NextValue(advance_b_local, 1),
            ).Else(
                NextValue(advance_b_local, 0)
            )
        )
        outbfsm.act("PIPE",
            If(self.advance_b,
                NextValue(self.output_b, output_b_local),
                NextValue(self.valid_b, valid_b_local),
                NextValue(advance_b_local, 1),
            ).Else(
                NextValue(advance_b_local, 0),
            ),
            If(~self.valid_b,
                NextState("FILL")
            )
        )

        state = Signal(384) # key + iv + ctr
        state_rot = Signal()
        holding_buf = Signal(512)
        holding_buf_shift_by_1 = Signal()
        holding_buf_shift_by_2 = Signal()
        holding_buf_load = Signal()
        advance_block = Signal()
        selfmix_ctr = Signal(self.selfmix_interval.nbits)

        self.sync += [
            If(state_rot | (self.ready & seed_now_local),
                If(seed_now_local,
                    state.eq(Cat(state[-32:] ^ self.seed ^ userdata_local, state[:-32]))
                ).Else(
                    state.eq(Cat(state[-32:] ^ self.seed, state[:-32]))
                )
            ).Else(
                state.eq(state)
            )
        ]

        # verilog I/Os
        init_50 = Signal()
        next_50 = Signal()
        key = Signal(256)
        iv = Signal(64)
        ctr = Signal(64)
        data_in = Signal(512)
        force_round_50 = Signal()
        data_out_50 = Signal(512)
        ready_50 = Signal()
        valid_50 = Signal()

        # 100MHz-domain signals
        init = Signal()
        next = Signal()
        force_round = Signal()

        # use fixed random data to blind the output of the generator
        din_shift = Signal()
        self.sync += [
            If(din_shift,
                data_in.eq(Cat(data_in[-32:] ^ self.seed, data_in[:-32]))
            ).Else(
                data_in.eq(data_in)
            )
        ]

        # output control
        sentinel = Signal(32, reset=0xDEAD_BEEF) # sentinel value to indicate something is wrong
        hold_init = Signal()
        holdfsm_load = Signal()
        saw_load = Signal()
        clear_saw_load = Signal()
        data_out = Signal(512)
        self.sync += [
            data_out.eq(data_out_50), # bring the output of chacha into the 100mhz domain to meet timing
            If( (holding_buf_load & ~hold_init) | holdfsm_load,
                holding_buf.eq(data_out)
            ).Elif(holding_buf_shift_by_1,
                holding_buf.eq(Cat(sentinel, holding_buf[:-32]))
            ).Elif(holding_buf_shift_by_2,
                holding_buf.eq(Cat(sentinel, sentinel, holding_buf[:-64]))
            ).Else(
                holding_buf.eq(holding_buf)
            ),
            #saw_load.eq(
            #    ((~clear_saw_load & ~holding_buf_load) & saw_load) |
            #    (holding_buf_load & ~clear_saw_load)
            #),
            If(clear_saw_load,
                saw_load.eq(0)
            ).Elif(holding_buf_load,
                saw_load.eq(1)
            ).Else(
                saw_load.eq(saw_load)
            )
        ]
        ### implement the output control logic here
        words_remaining = Signal(max=17, reset=0) # max= is *exclusive*, so you need 1 plus the actual maximum value
        holdfsm = FSM(reset_state="RESET")
        self.submodules += holdfsm
        holdfsm.act("RESET",
            NextValue(hold_init, 0),
            NextValue(words_remaining, 0),
            NextValue(valid_a_local, 0),
            NextValue(valid_b_local, 0),
            If(holding_buf_load,
                NextState("INIT"),
            )
        )
        # structurally, at this point:
        # - ChaCha20 is initialized
        # - holding buffer has 16 words of data
        # - ChaCha20 is already computing the next 16 words, and when it's done, `saw_load` will become 1
        holdfsm.act("INIT",
            clear_saw_load.eq(1), # this "wins" over holding_buf_load, and saw_load should be 0
            advance_block.eq(1), # immediately queue up the next block
            NextValue(hold_init, 1), # this will prevent further auto-initialization of the holding buffer

            NextValue(output_a_local, holding_buf[-32:]),
            NextValue(output_b_local, holding_buf[-64:-32]),
            NextValue(valid_a_local, 1),
            NextValue(valid_b_local, 1),
            NextValue(words_remaining, 14),
            holding_buf_shift_by_2.eq(1),
            NextState("OUTPUT"),
        )
        holdfsm.act("OUTPUT",
            # handle the case of needing a single word
            If( ( # update conditions are either we've received an adavance, or the valid is low (we saw an advance and wasn't able to refill)
                  # if you advance while not valid, well...that's undefined behavior! you will be reading the sentinel value
                  (advance_a_local | ~valid_a_local) & (~advance_b_local & valid_b_local) | # only a needs an update
                  (~advance_a_local & valid_a_local) & (advance_b_local | ~valid_b_local)   # only b needs an update
                ),
                If((advance_a_local | ~valid_a_local) & (~advance_b_local & valid_b_local), # a needs an update
                    NextValue(output_a_local, holding_buf[-32:]),
                    NextValue(valid_a_local, 1),
                ).Else( # if not a, then must be that b needs an update
                    NextValue(output_b_local, holding_buf[-32:]),
                    NextValue(valid_b_local, 1),
                ),
                # either way, we do this stuff to advance the next state
                holding_buf_shift_by_1.eq(1),
                If(words_remaining <= 1,
                    If(saw_load,
                        advance_block.eq(1),
                        holdfsm_load.eq(1),
                        clear_saw_load.eq(1),
                        NextValue(words_remaining, 16),
                    ).Else(
                        NextValue(words_remaining, 0),
                        NextState("WAIT")
                    )
                ).Else(
                    NextValue(words_remaining, words_remaining - 1),
                )
            ).Elif( (advance_a_local | ~valid_a_local) & (advance_b_local | ~valid_b_local), # case of needing two words
                If(words_remaining >= 2,
                    NextValue(output_a_local, holding_buf[-32:]),
                    NextValue(valid_a_local, 1),
                    NextValue(output_b_local, holding_buf[-64:-32]),
                    NextValue(valid_b_local, 1),
                    If(words_remaining == 2, # we're empty, try to pull the ready state; if not available, go wait
                        If(saw_load,
                            advance_block.eq(1),
                            holdfsm_load.eq(1),
                            clear_saw_load.eq(1),
                            NextValue(words_remaining, 16),
                        ).Else(
                            NextValue(words_remaining, 0),
                            NextState("WAIT")
                        )
                    ).Else(
                        holding_buf_shift_by_2.eq(1),
                        NextValue(words_remaining, words_remaining - 2),
                    )
                ).Else( # either 1 or 0 words
                    If(words_remaining == 1,
                        # we have one word remaining, arbitrarily advance a over b
                        NextValue(output_a_local, holding_buf[-32:]),
                        NextValue(valid_a_local, 1),
                        NextValue(output_b_local, sentinel),
                        NextValue(valid_b_local, 0),
                        NextValue(words_remaining, 0),
                    ).Else( # 0 words -- should never hit this case, but handle it anyways
                        NextValue(output_a_local, sentinel),
                        NextValue(valid_a_local, 0),
                        NextValue(output_b_local, sentinel),
                        NextValue(valid_b_local, 0),
                    ),
                    NextState("WAIT")
                )
            ).Else(
                # this should never be reachable: every condition above will reload before we hit zero.
                # but cover this case just in case, so we don't ever get "stuck" here, on a glitch or whatever
                If(words_remaining == 0,
                    If(saw_load,
                        advance_block.eq(1),
                        holdfsm_load.eq(1),
                        clear_saw_load.eq(1),
                        NextValue(words_remaining, 16),
                    ).Else(
                        NextState("WAIT")
                    )
                )
            )
        )
        holdfsm.act("WAIT",
            If(advance_a_local,
                NextValue(output_a_local, sentinel),
                NextValue(valid_a_local, 0)
            ),
            If(advance_b_local,
                NextValue(output_b_local, sentinel),
                NextValue(valid_b_local, 0)
            ),
            If(saw_load,
                advance_block.eq(1),
                holdfsm_load.eq(1),
                clear_saw_load.eq(1),
                NextValue(words_remaining, 16),
                NextState("OUTPUT")
            )
        )


        # seed control
        reseed_ctr = Signal(self.reseed_interval.nbits)
        seed_ctr = Signal(5, reset=16)
        seedfsm = FSM(reset_state="RESET")
        valid = Signal() # valid brought into the sysclk domain as a single pulse
        valid_r = Signal()
        valid_r2 = Signal()
        ready = Signal()
        seed_gnt_rising = Signal()
        seed_gnt_r = Signal()
        self.sync +=  [
            ready.eq(ready_50), # must pipeline this to break a subtle circular dependency that goes from the output to the input of chacha!
            valid_r.eq(valid_50), # cross 50->100
            valid_r2.eq(valid_r),
            seed_gnt_r.eq(self.seed_gnt),
        ]
        self.comb += valid.eq(~valid_r2 & valid_r)
        self.comb += seed_gnt_rising.eq(~seed_gnt_r & self.seed_gnt)
        self.submodules += seedfsm
        seedfsm.act("RESET",
            NextValue(reseed_ctr, 1),
            NextValue(self.ready, 0),
            NextValue(seed_ctr, 13), # seed in 384 bits for key + 1 dummy word to toss the first 0 on the FIFO
            NextState("SEEDING"),
        )
        seedfsm.act("SEEDING",
            If(seed_gnt_rising,
                state_rot.eq(1),
                NextValue(seed_ctr, seed_ctr - 1),
            ),
            If(seed_ctr == 0,
                NextValue(self.seed_req, 0),
                NextValue(seed_ctr, 16), # seed in 512 bits for DIN
                NextState("DIN_SEEDING"),
            ).Else(
                NextValue(self.seed_req, ~self.seed_gnt),
            )
        )
        seedfsm.act("DIN_SEEDING",
            If(seed_gnt_rising,
                din_shift.eq(1),
                NextValue(seed_ctr, seed_ctr - 1),
            ),
            If(seed_ctr == 0,
                NextValue(self.seed_req, 0),
                NextState("SEEDED"),
            ).Else(
                NextValue(self.seed_req, ~self.seed_gnt),
            )
        )
        seedfsm.act("SEEDED",
            If(ready,
                NextValue(init, 1),
                NextState("WAIT_INIT")
            )
        )
        seedfsm.act("WAIT_INIT",
            NextValue(selfmix_ctr, selfmix_interval_local),
            NextValue(init, 0),
            If(valid,
                NextState("RUN"),
                NextValue(self.ready, 1),
            )
        )
        seedfsm.act("RUN",
            If(selfmix_ena_local,
                If(selfmix_ctr != 0,
                    NextValue(selfmix_ctr, selfmix_ctr - 1),
                ).Else(
                    NextValue(selfmix_ctr, selfmix_interval_local),
                    force_round.eq(1),
                )
            ),
            If(advance_block,
                If(reseed_ctr < reseed_interval_local,
                    NextValue(reseed_ctr, reseed_ctr + 1),
                ),
                If((reseed_ctr == reseed_interval_local) & (reseed_interval_local != 0),
                    NextValue(reseed_ctr, 1),
                    NextValue(self.seed_req, 1),
                    NextState("RUN_RESEED"),
                )
            )
        )
        seedfsm.act("RUN_RESEED",
            If(seed_gnt_rising,
                state_rot.eq(1),
                NextValue(self.seed_req, 0),
                NextState("RUN"),
            )
        )
        # a simple FSM just to manage the ready/wait on the chacha block itself
        advfsm = FSM(reset_state="WAITING")
        self.submodules += advfsm
        advfsm.act("WAITING",
            NextValue(next, 0),
            If(advance_block,
                NextState("WAIT_READY")
            )
        )
        advfsm.act("WAIT_READY",
            If(ready,
                NextValue(next, 1),
                NextState("WAITING"),
            )
        )
        self.sync += holding_buf_load.eq(valid) # just load the buf whenever we see a new valid block come out

        # verilog block instantiation
        self.comb += [
            key.eq(state[:256]),
            iv.eq(state[256:320]),
            ctr.eq(state[320:]),
        ]
        # stretch control signal pulses out
        self.submodules.init_xfer = BlindTransfer("sys", "clk50")
        self.submodules.next_xfer = BlindTransfer("sys", "clk50")
        self.submodules.force_xfer = BlindTransfer("sys", "clk50")
        self.comb += [
            self.init_xfer.i.eq(init),
            self.next_xfer.i.eq(next),
            self.force_xfer.i.eq(force_round),
            init_50.eq(self.init_xfer.o),
            next_50.eq(self.next_xfer.o),
            force_round_50.eq(self.force_xfer.o),
        ]
        # make sure we have a solid local reset
        resetter = Signal(4, reset=15)
        local_reset_n = Signal(reset=0)
        self.sync.clk50 += [
            If(resetter != 0,
                resetter.eq(resetter - 1),
                    local_reset_n.eq(0),
            ).Else(
                If(ResetSignal("clk50"),
                    resetter.eq(15),
                    local_reset_n.eq(0),
                ).Else(
                    resetter.eq(0),
                    local_reset_n.eq(1),
                )
            )
        ]
        self.specials += Instance("chacha_core",
            i_clk = ClockSignal("clk50"),
            i_reset_n = local_reset_n,

            i_init = init_50,
            i_next = next_50,

            i_key = key,
            i_keylen = 1, # select a 256-bit keylen
            i_iv = iv,
            i_ctr = ctr,
            i_rounds = 20, # minimum of 20 rounds
            i_data_in = data_in,
            i_force_round = force_round_50,
            o_ready = ready_50,
            o_data_out = data_out_50,
            o_data_out_valid = valid_50,
        )

        platform.add_source(os.path.join("deps", "gateware", "gateware", "chacha", "chacha_core.v"))
        platform.add_source(os.path.join("deps", "gateware", "gateware", "chacha", "chacha_qr.v"))

        ### sys->clk50 multi-cycle paths:
        # relax the path from the data_in and key into the chacha engine. it's basically static.
        platform.add_platform_command("set_multicycle_path 2 -setup -start -from [get_clocks sys_clk] -to [get_clocks clk50] -through [get_pins chacha_core/data_out_reg_*/D]")
        platform.add_platform_command("set_multicycle_path 1 -hold -end -from [get_clocks sys_clk] -to [get_clocks clk50] -through [get_pins chacha_core/data_out_reg_*/D]")
        platform.add_platform_command("set_multicycle_path 2 -setup -start -from [get_clocks sys_clk] -to [get_clocks clk50] -through [get_pins chacha_core/state_reg*/D]")
        platform.add_platform_command("set_multicycle_path 1 -hold -end -from [get_clocks sys_clk] -to [get_clocks clk50] -through [get_pins chacha_core/state_reg*/D]")
        ### clk50->sys multi-cycle paths:
        # relax the return path, the valid pulse is pipelined so there are oodles of setup/hold time
        # setup is defined w.r.t destination clock, so the numbers are 2x larger in th clk50->sys direction
        platform.add_platform_command("set_multicycle_path 4 -setup -start -from [get_clocks clk50] -to [get_clocks sys_clk] -through [get_pins chacha_core/data_out_reg*/Q]")
        platform.add_platform_command("set_multicycle_path 6 -hold -end -from [get_clocks clk50] -to [get_clocks sys_clk] -through [get_pins chacha_core/data_out_reg*/Q]")
        #platform.add_platform_command("set_multicycle_path 4 -setup -start -from [get_clocks clk50] -to [get_clocks sys_clk] -through [get_pins *trngmanaged_data_out_reg*/D]")
        #platform.add_platform_command("set_multicycle_path 2 -hold -end -from [get_clocks clk50] -to [get_clocks sys_clk] -through [get_pins *trngmanaged_data_out_reg*/D]")

