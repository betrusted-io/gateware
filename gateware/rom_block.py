from migen import *

import random

# this file was created so make a more efficient, customized block ROM for storing
# boot code. The default LiteX block ROM tries for performance over density. This
# implementation is density over performance.

class BlockRom(Module):
    def __init__(self, init=None, bus=None):
        self.bus = bus

        BANK_WIDTH = 2 # use this to adjust total size. width = 1 -> 64kiB, 2-> 32kiB, 4->16kiB, etc. must be power of 2. 64kiB is the biggest we can create.
        BLOCKS = 32 // BANK_WIDTH   # 32 bits divided by the bank width
        BITS_PER_BLOCK = 16384 # fixed at 16384: use RAMB18E blocks for best packing density


        TOTAL_BYTES = BITS_PER_BLOCK * BLOCKS // 8  # ROM size is a result of BITS_PER_BLOCK and BLOCKS.
        TOTAL_WORDS = TOTAL_BYTES // 4
        INIT_BITS = 256

        INIT_ROWS = 0x40 # expected number of rows to write

        if init is None:  # don't allow Litex to optimize this out! we need to placehold its space
            rawdata = bytearray()
            for i in range(TOTAL_WORDS):
                rawdata += int(i).to_bytes(4, 'little')
        else:
            with open(init, "rb") as handle:
                rawdata = handle.read()

            if len(rawdata) >= TOTAL_BYTES:
                print("CRITICAL ERROR: ROM file does not fit: {} bytes given, {} bytes available".format(len(rawdata), TOTAL_BYTES))
                exit(1)
            elif len(rawdata) < TOTAL_BYTES:
                rawdata += bytearray([0] * (TOTAL_BYTES - len(rawdata)))

        assert len(rawdata) == TOTAL_BYTES # this must be true for anything to work downstream of this

        words = []
        for i in range(TOTAL_WORDS):
            words.append( int.from_bytes(rawdata[i*4:(i+1)*4], 'little') )

        for bank in range(BLOCKS):
            params = {}
            params.update(
                    name="ROMBLOCK" + str(bank),
                    p_WRITE_WIDTH=BANK_WIDTH,
                    p_READ_WIDTH=BANK_WIDTH,
                    p_BRAM_SIZE="18Kb",
                    p_DO_REG=1,
                    o_DO=self.bus.dat_r[bank*BANK_WIDTH:(bank+1)*BANK_WIDTH],
                    i_ADDR=self.bus.adr[:(15 - BANK_WIDTH)],
                    i_WE=0,
                    i_EN=self.bus.stb,
                    i_RST=ResetSignal(),
                    i_CLK=ClockSignal(),
                    i_DI=0,
                    i_REGCE=1,
            )

            init = []
            init_index = 0
            vect = 0
            for word in words:
                nibble = (word & (((2**BANK_WIDTH)-1) << bank*BANK_WIDTH)) >> (bank*BANK_WIDTH)
                vect += nibble << init_index
                init_index += BANK_WIDTH
                if init_index == INIT_BITS:
                    init.append(vect)
                    vect = 0
                    init_index = 0

            # print(init)
            assert len(init) == INIT_ROWS # sanity check that we actually generated the correct number of rows
            i = 0
            for data in init:
                params.update({'p_INIT_{:02X}'.format(i) : data})
                i += 1

            self.specials += Instance("BRAM_SINGLE_MACRO", **params)

        # generate ack
        cycle = Signal()
        ack = Signal() # one cycle delay to ease timing on the ROM
        self.sync += [
            cycle.eq(self.bus.cyc & self.bus.stb & ~self.bus.ack),
            ack.eq(self.bus.cyc & self.bus.stb & ~cycle),
            self.bus.ack.eq(ack),
        ]
