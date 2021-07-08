from migen import *
from migen.genlib.fsm import FSM, NextState

from litex.soc.interconnect import wishbone
from litex.soc.interconnect.csr import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.integration.soc import SoCRegion

from math import log2

def colorer(s, color="bright"):
    header  = {
        "bright": "\x1b[1m",
        "green":  "\x1b[32m",
        "cyan":   "\x1b[36m",
        "red":    "\x1b[31m",
        "yellow": "\x1b[33m",
        "underline": "\x1b[4m"}[color]
    trailer = "\x1b[0m"
    return header + str(s) + trailer

class rom_block(Module):
    def __init__(self, name, origin, size, contents=[], mode="r"):
        ram_bus = wishbone.Interface(data_width=self.bus.data_width)
        ram     = BlockRom(size, bus=ram_bus, init=contents)
        self.bus.add_slave(name, ram.bus, SoCRegion(origin=origin, size=size, mode=mode, cached=False))
        self.check_if_exists(name)
        self.logger.info("Block ROM {} {} {}.".format(
            colorer(name),
            colorer("added", color="green"),
            self.bus.regions[name]))
        setattr(self.submodules, name, ram)

class BlockRomSimple(Module):
    def __init__(self, init=None, bus=None):
        self.bus = bus

        self.specials += Instance("xpm_memory_sprom",
            p_ADDR_WIDTH_A = 14,
            p_MEMORY_OPTIMIZATION = "false",
            p_MEMORY_PRIMITIVE = "block",
            p_MEMORY_SIZE = 524288,
            p_READ_DATA_WIDTH_A = 32,
            i_addra = self.bus.adr,
            i_clka = ClockSignal(),
            o_douta = self.bus.dat_r,
            i_ena = self.bus.stb,
            i_rsta = ResetSignal(),
        )
        # generate ack
        self.sync += [
            self.bus.ack.eq(0),
            If(self.bus.cyc & self.bus.stb & ~self.bus.ack, self.bus.ack.eq(1))
        ]

class BlockRom(Module):
    def __init__(self, init=None, bus=None):
        self.bus = bus

        import random
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
            for i in range(0x40):
                params.update({'p_INIT_{:02X}'.format(i) : random.getrandbits(256)})
            print(params)
            self.specials += Instance("BRAM_SINGLE_MACRO", **params)

        # generate ack
        self.sync += [
            self.bus.ack.eq(0),
            If(self.bus.cyc & self.bus.stb & ~self.bus.ack, self.bus.ack.eq(1))
        ]


class BlockRomBak(Module):
    def __init__(self, init=None, bus=None):
        self.bus = bus

        muxd_hi = Signal(256)
        muxd_lo = Signal(256)
        for bank in range(12):
            self.specials += Instance("RAMB18E1", name="ROMBLOCKLO" + str(bank),
                p_DOA_REG = 1,
                p_DOB_REG = 1,
                p_RAM_MODE = "SDP",
                p_READ_WIDTH_A = 18,
                p_READ_WIDTH_B = 0,
                p_WRITE_MODE_A = "READ_FIRST",
                p_WRITE_WIDTH_A = 0,
                p_WRITE_WIDTH_B = 0,
                p_INIT_FILE = "NONE",
                p_SIM_COLLISION_CHECK = "ALL", # "WARNING_ONLY", "GENERATE_X_ONLY", "NONE"
                i_CLKARDCLK = ClockSignal(),
                i_ADDRARDADDR = self.bus.adr,
                o_DOADO=muxd_lo[bank*16 : (bank+1)*16],
                i_ENARDEN=self.bus.stb,
                i_REGCEAREGCE=self.bus.stb,
                i_RSTRAMARSTRAM=ResetSignal(),
                i_RSTREGARSTREG=ResetSignal(),
            )
            self.specials += Instance("RAMB18E1", name="ROMBLOCKHI" + str(bank),
                p_DOA_REG = 1,
                p_DOB_REG = 1,
                p_RAM_MODE = "SDP",
                p_READ_WIDTH_A = 18,
                p_READ_WIDTH_B = 0,
                p_WRITE_MODE_A = "READ_FIRST",
                p_WRITE_WIDTH_A = 0,
                p_WRITE_WIDTH_B = 0,
                p_INIT_FILE = "NONE",
                p_SIM_COLLISION_CHECK = "ALL", # "WARNING_ONLY", "GENERATE_X_ONLY", "NONE"
                i_CLKARDCLK = ClockSignal(),
                i_ADDRARDADDR = self.bus.adr,
                o_DOADO=muxd_hi[bank*16 : (bank+1)*16],
                i_ENARDEN=self.bus.stb,
                i_REGCEAREGCE=self.bus.stb,
                i_RSTRAMARSTRAM=ResetSignal(),
                i_RSTREGARSTREG=ResetSignal(),
            )

        cases = {}
        for i in range(16):
            cases[i] = [
                self.bus.dat_r.eq(Cat(muxd_lo[i*16:(i+1)*16], muxd_hi[i*16:(i+1)*16]))
            ]
        self.comb += Case(self.bus.adr[10:14], cases)

        # generate ack
        self.sync += [
            self.bus.ack.eq(0),
            If(self.bus.cyc & self.bus.stb & ~self.bus.ack, self.bus.ack.eq(1))
        ]