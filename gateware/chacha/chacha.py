from migen import *
from migen.genlib.cdc import MultiReg

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
        self.ready = Signal()    # indicates all seeding operations are done
        self.reseed_interval = Signal(12) # input / indicates how many ChaCha rounds we can generate before demanding a reseed. 0 means never auto-reseed.

        self.advance_a = Signal()   # input / a single-cycle pulse that advances the value of output_a
        self.output_a = Signal(32)  # output / one of two output ports
        self.valid_a = Signal()     # output / when high, the value on output_a is valid

        self.advance_b = Signal()   # input / a single-cycle pulse that advances the value of output_b
        self.output_b = Signal(32)  # output / second of two output ports
        self.valid_b = Signal()     # output / when high, the value on output_a is valid

        self.selfmix_ena = Signal()     # input / enables opportunistic self-mixing in the background
        self.selfmix_interval = Signal(16)  # input / sysclk cycles in between opportunistic self mixings; for power savings

        state = Signal(384) # key + iv + ctr
        state_rot = Signal()
        holding_buf = Signal(512)
        holding_buf_shift_by_1 = Signal()
        holding_buf_shift_by_2 = Signal()
        holding_buf_load = Signal()
        advance_block = Signal()
        selfmix_ctr = Signal(self.selfmix_interval.nbits)

        self.sync += [
            If(state_rot | (self.ready & self.seed_now),
                state.eq(Cat(state[-32:] ^ self.seed ^ self.userdata, state[:-32]))
            ).Else(
                state.eq(state)
            )
        ]

        # verilog I/Os
        init = Signal()
        next = Signal()
        key = Signal(256)
        iv = Signal(64)
        ctr = Signal(64)
        data_in = Signal(512)
        force_round = Signal()
        ready = Signal()
        data_out = Signal(512)
        valid = Signal()

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
        self.sync += [
            If( (holding_buf_load & ~hold_init) | holdfsm_load,
                holding_buf.eq(data_out)
            ).Elif(holding_buf_shift_by_1,
                holding_buf.eq(Cat(sentinel, holding_buf[:-32]))
            ).Elif(holding_buf_shift_by_2,
                holding_buf.eq(Cat(sentinel, sentinel, holding_buf[:-64]))
            ).Else(
                holding_buf.eq(holding_buf)
            ),
            If(clear_saw_load,
                saw_load.eq(0)
            ).Elif(holding_buf_load,
                saw_load.eq(1)
            ).Else(
                saw_load.eq(saw_load)
            )
        ]
        ### implement the output control logic here
        words_remaining = Signal(max=16, reset=0)
        holdfsm = FSM(reset_state="RESET")
        self.submodules += holdfsm
        holdfsm.act("RESET",
            NextValue(hold_init, 0),
            NextValue(words_remaining, 0),
            NextValue(advance_block, 0),
            NextValue(self.valid_a, 0),
            NextValue(self.valid_b, 0),
            If(holding_buf_load,
                NextState("INIT"),
                NextValue(hold_init, 1), # this will prevent further auto-initialization of the holding buffer
                clear_saw_load.eq(1), # this "wins" over holding_buf_load, and saw_load should be 0
                advance_block.eq(1), # immediately queue up the next block
            )
        )
        # structurally, at this point:
        # - ChaCha20 is initialized
        # - holding buffer has 16 words of data
        # - ChaCha20 is already computing the next 16 words, and when it's done, `saw_load` will become 1
        holdfsm.act("INIT",
            NextValue(self.output_a, holding_buf[-32:]),
            NextValue(self.output_b, holding_buf[-64:-32]),
            NextValue(self.valid_a, 1),
            NextValue(self.valid_b, 1),
            NextValue(words_remaining, 14),
            holding_buf_shift_by_2.eq(1),
        )
        holdfsm.act("OUTPUT",
            # handle the case of needing a single word
            If( ( # update conditions are either we've received an adavance, or the valid is low (we saw an advance and wasn't able to refill)
                  # if you advance while not valid, well...that's undefined behavior! you will be reading the sentinel value
                  (self.advance_a | ~self.valid_a) & (~self.advance_b & self.valid_b) | # only a needs an update
                  (~self.advance_a & self.valid_a) & (self.advance_b | ~self.valid_b)   # only b needs an update
                ),
                If((self.advance_a | ~self.valid_a) & (~self.advance_b & self.valid_b), # a needs an update
                    NextValue(self.output_a, holding_buf[-32:]),
                    NextValue(self.valid_a, 1),
                ).Else( # if not a, then must be that b needs an update
                    NextValue(self.output_b, holding_buf[-32:]),
                    NextValue(self.valid_b, 1),
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
            ).Elif( (self.advance_a | ~self.valid_a) & (self.advance_b | ~self.valid_b), # case of needing two words
                If(words_remaining >= 2,
                    NextValue(self.output_a, holding_buf[-32:]),
                    NextValue(self.valid_a, 1),
                    NextValue(self.output_b, holding_buf[-64:-32]),
                    NextValue(self.valid_b, 1),
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
                        NextValue(self.output_a, holding_buf[-32:]),
                        NextValue(self.valid_a, 1),
                        NextValue(self.output_b, sentinel),
                        NextValue(self.valid_b, 0),
                        NextValue(words_remaining, 0),
                    ).Else( # 0 words -- should never hit this case, but handle it anyways
                        NextValue(self.output_a, sentinel),
                        NextValue(self.valid_a, 0),
                        NextValue(self.output_b, sentinel),
                        NextValue(self.valid_b, 0),
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
            If(self.advance_a,
                NextValue(self.output_a, sentinel),
                NextValue(self.valid_a, 0)
            ),
            If(self.advance_b,
                NextValue(self.output_b, sentinel),
                NextValue(self.valid_b, 0)
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
        seed_ctr = Signal(4, reset=15)
        seedfsm = FSM(reset_state="RESET")
        seed_req = Signal()
        self.comb += self.seed_req.eq(seed_req) # using self.seed_req directly somehow causes migen to puke...seems a mild bug?
        self.submodules += seedfsm
        seedfsm.act("RESET",
            NextValue(reseed_ctr, 0),
            NextValue(self.ready, 0),
            NextValue(seed_ctr, 12), # seed in 384 bits for key
            NextState("SEEDING"),
        )
        seedfsm.act("SEEDING",
            If(self.seed_gnt,
                state_rot.eq(1),
                NextValue(seed_ctr, seed_ctr - 1),
            ),
            If(seed_ctr == 0,
                NextValue(seed_req, 0),
                NextValue(seed_ctr, 15), # seed in 512 bits for DIN
                NextState("DIN_SEEDING"),
            ).Else(
                NextValue(seed_req, ~self.seed_gnt),
            )
        )
        seedfsm.act("DIN_SEEDING",
            If(self.seed_gnt,
                din_shift.eq(1),
                NextValue(seed_ctr, seed_ctr - 1),
            ),
            If(seed_ctr == 0,
                NextValue(seed_req, 0),
                NextState("SEEDED"),
            ).Else(
                NextValue(seed_req, ~self.seed_gnt),
            )
        )
        seedfsm.act("SEEDED",
            NextValue(init, 1),
            NextState("WAIT_INIT")
        )
        seedfsm.act("WAIT_INIT",
            NextValue(init, 0),
            If(ready,
                NextState("RUN"),
                NextValue(self.ready, 1),
                NextValue(selfmix_ctr, self.selfmix_interval),
                holding_buf_load.eq(1),
            )
        )
        seedfsm.act("RUN",
            If(self.selfmix_ena,
                If(selfmix_ctr != 0,
                    NextValue(selfmix_ctr, selfmix_ctr - 1),
                ).Else(
                    NextValue(selfmix_ctr, self.selfmix_interval),
                    force_round.eq(1),
                )
            ),
            If(advance_block,
                NextValue(next, 1),
                NextState("WAIT_NEXT"),
                If(reseed_ctr < self.reseed_interval,
                    reseed_ctr.eq(reseed_ctr + 1),
                )
            )
        )
        seedfsm.act("WAIT_NEXT",
            NextValue(next, 0),
            If(valid,
                If((reseed_ctr == self.reseed_interval) & (self.reseed_interval != 0),
                    NextValue(seed_req, 1),
                    NextState("RUN_RESEED"),
                ).Else(
                    holding_buf_load.eq(1),
                    NextState("RUN"),
                )
            )
        )
        seedfsm.act("RUN_RESEED",
            If(self.seed_gnt,
                state_rot.eq(1),
                holding_buf_load.eq(1),
                NextValue(seed_req, 0),
                NextState("RUN"),
            )
        )

        # verilog block instantiation
        self.comb += [
            key.eq(state[:256]),
            iv.eq(state[256:320]),
            ctr.eq(state[320:]),
        ]
        self.specials += Instance("chacha_core",
            i_clk = ClockSignal(),
            i_reset_n = ~ResetSignal(),

            i_init = init,
            i_next = next,

            i_key = key,
            i_keylen = 1, # select a 256-bit keylen
            i_iv = iv,
            i_ctr = ctr,
            i_rounds = 20, # minimum of 20 rounds
            i_data_in = data_in,
            i_force_round = force_round,
            o_ready = ready,
            o_data_out = data_out,
            o_data_out_valid = valid,
        )

        platform.add_source(os.path.join("deps", "gateware", "gateware", "chacha", "chacha_core.v"))
        platform.add_source(os.path.join("deps", "gateware", "gateware", "chacha", "chacha_qr.v"))
