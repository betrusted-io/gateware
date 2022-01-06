from random import SystemRandom

from migen import *

from litex.soc.interconnect.csr import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc

# KeyRom ------------------------------------------------------------------------------------------

class KeyRom(Module, AutoDoc, AutoCSR):
    def __init__(self, platform):
        self.intro = ModuleDoc("""Bitstream-patchable key ROM set for keys that are "baked in" to the FPGA image""")
        platform.toolchain.attr_translate["KEEP"] = ("KEEP", "TRUE")
        platform.toolchain.attr_translate["DONT_TOUCH"] = ("DONT_TOUCH", "TRUE")

        import binascii
        self.address = CSRStorage(8, name="address", description="address for ROM")
        self.data = CSRStatus(32, name="data", description="data from ROM")
        self.lockaddr = CSRStorage(8, name="lockaddr", description="address of the word to lock. Address locked on write, and cannot be undone.")
        self.lockstat = CSRStatus(1, name="lockstat", description="If set, the requested address word is locked and will always return 0.")

        lockmem = Memory(1, 256, init=[0]*256)
        self.specials += lockmem
        self.specials.lockrd = lockmem.get_port(write_capable=False, mode=WRITE_FIRST, async_read=True)
        self.specials.lockwr = lockmem.get_port(write_capable=True, mode=WRITE_FIRST)
        self.comb += [
            self.lockwr.adr.eq(self.lockaddr.storage),
            self.lockwr.dat_w.eq(1),
            self.lockwr.we.eq(self.lockaddr.re),
        ]
        rawdata = Signal(32)

        rng = SystemRandom()
        with open("rom.db", "w") as f:
            for bit in range(0,32):
                lutsel = Signal(4)
                for lut in range(4):
                    if lut == 0:
                        lutname = 'A'
                    elif lut == 1:
                        lutname = 'B'
                    elif lut == 2:
                        lutname = 'C'
                    else:
                        lutname = 'D'
                    romval = rng.getrandbits(64)
                    # print("rom bit ", str(bit), lutname, ": ", binascii.hexlify(romval.to_bytes(8, byteorder='big')))
                    rom_name = "KEYROM" + str(bit) + lutname
                    # X36Y99 and counting down
                    if bit % 2 == 0:
                        platform.toolchain.attr_translate[rom_name] = ("LOC", "SLICE_X36Y" + str(50 + bit // 2))
                    else:
                        platform.toolchain.attr_translate[rom_name] = ("LOC", "SLICE_X37Y" + str(50 + bit // 2))
                    platform.toolchain.attr_translate[rom_name + 'BEL'] = ("BEL", lutname + '6LUT')
                    platform.toolchain.attr_translate[rom_name + 'LOCK'] = ( "LOCK_PINS", "I5:A6, I4:A5, I3:A4, I2:A3, I1:A2, I0:A1" )
                    self.specials += [
                        Instance( "LUT6",
                                  name=rom_name,
                                  # p_INIT=0x0000000000000000000000000000000000000000000000000000000000000000,
                                  p_INIT=romval,
                                  i_I0= self.address.storage[0],
                                  i_I1= self.address.storage[1],
                                  i_I2= self.address.storage[2],
                                  i_I3= self.address.storage[3],
                                  i_I4= self.address.storage[4],
                                  i_I5= self.address.storage[5],
                                  o_O= lutsel[lut],
                                  attr=("KEEP", "DONT_TOUCH", rom_name, rom_name + 'BEL', rom_name + 'LOCK')
                                  )
                    ]
                    # record the ROM LUT locations in a DB and annotate the initial random value given
                    f.write("KEYROM " + str(bit) + ' ' + lutname + ' ' + platform.toolchain.attr_translate[rom_name][1] +
                            ' ' + str(binascii.hexlify(romval.to_bytes(8, byteorder='big'))) + '\n')
                self.comb += [
                    If( self.address.storage[6:] == 0,
                        rawdata[bit].eq(lutsel[2]))
                    .Elif(self.address.storage[6:] == 1,
                          rawdata[bit].eq(lutsel[3]))
                    .Elif(self.address.storage[6:] == 2,
                          rawdata[bit].eq(lutsel[0]))
                    .Else(rawdata[bit].eq(lutsel[1]))
                ]

        allow_read = Signal()
        self.comb += [
            allow_read.eq(~self.lockrd.dat_r),
            self.lockrd.adr.eq(self.address.storage),
        ]
        self.sync += [
            If(allow_read,
                self.data.status.eq(rawdata),
            ).Else(
                self.data.status.eq(0),
            ),
            self.lockstat.status.eq(allow_read)
        ]

        platform.add_platform_command("create_pblock keyrom")
        platform.add_platform_command('resize_pblock [get_pblocks keyrom] -add ' + '{{SLICE_X36Y50:SLICE_X37Y65}}')
        #platform.add_platform_command("set_property CONTAIN_ROUTING true [get_pblocks keyrom]")  # should be fine to mingle the routing for this pblock
        platform.add_platform_command("add_cells_to_pblock [get_pblocks keyrom] [get_cells KEYROM*]")
