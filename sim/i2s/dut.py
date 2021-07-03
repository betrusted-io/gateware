#!/usr/bin/env python3

import sys
import os
import argparse

# ASSUME: project structure is <project_root>/deps/gateware/sim/<sim_proj>/this_script
# where the "gateware" repository is cloned into <project_root>/deps/
#
# We need to import lxbuildenv, which is in <project_root>. Add this to the path in an
# os-independent fashion.
script_path = os.path.dirname(os.path.realpath(
    __file__)) + os.path.sep + os.path.pardir + os.path.sep + os.path.pardir + os.path.sep + os.path.pardir + os.path.sep + os.path.pardir + os.path.sep
sys.path.insert(0, script_path)

import lxbuildenv

# This variable defines all the external programs that this module
# relies on.  lxbuildenv reads this variable in order to ensure
# the build will finish without exiting due to missing third-party
# programs.
LX_DEPENDENCIES = ["riscv", "vivado"]

# universally required
from migen import *
import litex.soc.doc as lxsocdoc
from litex.build.generic_platform import *
from litex.soc.integration.builder import *

# pull in the common objects from sim_bench
from sim_support.sim_bench import Sim, Platform, BiosHelper, CheckSim, SimRunner

# handy to keep around in case a DUT framework needs it
from litex.soc.integration.soc_core import *
from litex.soc.cores.clock import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect.csr import *
from litex.soc.integration.soc import SoCRegion

# specific to a given DUT
from litex.soc.cores.i2s import S7I2S

"""
set boot_from_spi to change the reset vector and linking location of BIOS
note that this script does not link `run/software/bios/bios.bin` to
a .init file suitable for the SPI verilog model. This needs to be done
with additional code or tooling based on the specific SPI verilog model 
employed.
"""
boot_from_spi=False

"""
top-level IOs specific to the DUT
"""
dutio = [
    # Audio interface
    ("i2s", 0,  # headset & mic
     Subsignal("clk", Pins("D14")),
     Subsignal("tx", Pins("D12")),  # au_sdi1
     Subsignal("rx", Pins("C13")),  # au_sdo1
     Subsignal("sync", Pins("B15")),
     IOStandard("LVCMOS33"),
     Misc("SLEW=SLOW"), Misc("DRIVE=4"),
     ),
    ("i2s", 1,  # speaker
     Subsignal("clk", Pins("F14")),
     Subsignal("tx", Pins("A15")),  # au_sdi2
     Subsignal("sync", Pins("B17")),
     IOStandard("LVCMOS33"),
     Misc("SLEW=SLOW"), Misc("DRIVE=4"),
     ),
    ("au_mclk", 0, Pins("D18"), IOStandard("LVCMOS33"), Misc("SLEW=SLOW"), Misc("DRIVE=8")),
]

"""
additional clocks beyond the simulation defaults
"""
local_clocks = {
}

"""
add the submodules we're testing to the SoC, which is encapsulated in the Sim class
"""
class Dut(Sim):
    def __init__(self, platform, spiboot=False, **kwargs):
        Sim.__init__(self, platform, custom_clocks=local_clocks, spiboot=spiboot, **kwargs) # SoC magic is in here

        # add a key for the i2s_duplex sim block
        SoCCore.mem_map["i2s_duplex"] = 0xe0001000

        # shallow fifodepth allows us to work the end points a bit faster in simulation
        self.submodules.i2s_duplex = S7I2S(platform.request("i2s", 0), fifo_depth=8)
        self.bus.add_slave("i2s_duplex", self.i2s_duplex.bus, SoCRegion(origin=self.mem_map["i2s_duplex"], size=0x4, cached=False))
        self.add_csr("i2s_duplex")
        self.add_interrupt("i2s_duplex")

        self.submodules.audio = S7I2S(platform.request("i2s", 1), fifo_depth=8)
        self.bus.add_slave("audio", self.audio.bus, SoCRegion(origin=self.mem_map["audio"], size=0x4, cached=False))
        self.add_csr("audio")
        self.add_interrupt("audio")


"""
generate all the files necessary to run xsim
"""
def generate_top():
    global dutio
    global boot_from_spi

    # we have to do two passes: once to make the SVD, without compiling the BIOS
    # second, to compile the BIOS, which is then built into the gateware.
    if os.name == 'nt':
        # windows is really, really hard to do this right. Apparently mkdir and copy aren't "commands", they are shell built-ins
        # plus path separators are different plus calling os.mkdir() is different from the mkdir version in the windows shell. ugh.
        # just...i give up. we can't use a single syscall for both. we just have to do it differently for each platform.
        subprocess.run("mkdir run\\software\\bios", shell=True)
        subprocess.run("mkdir ..\\..\\target", shell=True)
        subprocess.run("copy ..\\..\\sim_support\\placeholder_bios.bin run\\software\\bios\\bios.bin", shell=True)
    else:
        os.system("mkdir -p run/sofware/bios")
        os.system("mkdir -p ../../target")  # this doesn't exist on the first run
        os.system("cp ../../sim_support/placeholder_bios.bin run/software/bios/bios.bin")

    # pass #1 -- make the SVD
    platform = Platform(dutio)
    soc = Dut(platform, spiboot=boot_from_spi)

    builder = Builder(soc, output_dir="./run", csr_svd="../../target/soc.svd", compile_gateware=False, compile_software=False)
    vns = builder.build(run=False)
    soc.do_exit(vns)

    BiosHelper(soc, boot_from_spi) # marshals cargo to generate the BIOS from Rust files

    # pass #2 -- generate the SoC, incorporating the now-built BIOS
    platform = Platform(dutio)
    soc = Dut(platform, spiboot=boot_from_spi)

    builder = Builder(soc, output_dir="./run", compile_software=False)
    vns = builder.build(run=False)
    soc.do_exit(vns)


"""
script to drive xsim
Add local verilog models by adding to the extra_cmds array, 
or tweak the simulator in unusual ways (e.g. translate a .bin to a .init file) 
before calling SimRunner
"""
def run_sim(ci=False):
    # add third-party modules via extra_cmds, eg. "cd run && xvlog ../MX66UM1G45G/MX66UM1G45G.v"
    extra_cmds = []
    SimRunner(ci, extra_cmds)


def main():
    parser = argparse.ArgumentParser(description="Gateware simulation framework")
    parser.add_argument(
        "-c", "--ci", default=False, action="store_true", help="Run with settings for automated CI"
    )

    args = parser.parse_args()

    generate_top()
    run_sim(ci=args.ci)
    if args.ci:
        if CheckSim() != 0:
            sys.exit(1)

    sys.exit(0)

if __name__ == "__main__":
    main()
