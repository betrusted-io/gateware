from migen import *

import random

class BlockRom(Module):
    def __init__(self, init=None, bus=None):
        self.bus = bus

        for bank in range(16):
            params = {}
            params.update(
                    name="ROMBLOCK" + str(bank),
                    p_WRITE_WIDTH=2,
                    p_READ_WIDTH=2,
                    p_BRAM_SIZE="18Kb",
                    p_DO_REG=1,
                    o_DO=self.bus.dat_r[bank*2:bank*2+1],
                    i_ADDR=self.bus.adr[:14],
                    i_WE=0,
                    i_EN=self.bus.stb,
                    i_RST=ResetSignal(),
                    i_CLK=ClockSignal(),
                    i_DI=0,
                    i_REGCE=1,
            )
            if init is None:  # don't allow Litex to optimize this out! we need to placehold its space
                for i in range(0x40):
                    params.update({'p_INIT_{:02X}'.format(i) : random.getrandbits(256)})
                # print(params)
            self.specials += Instance("BRAM_SINGLE_MACRO", **params)

        # generate ack
        self.sync += [
            self.bus.ack.eq(0),
            If(self.bus.cyc & self.bus.stb & ~self.bus.ack, self.bus.ack.eq(1))
        ]
