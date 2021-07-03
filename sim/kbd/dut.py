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
from sim_support.sim_bench import Sim, Platform, VEX_CPU_PATH, BiosHelper, CheckSim, SimRunner

# handy to keep around in case a DUT framework needs it
from litex.soc.integration.soc_core import *
from litex.soc.cores.clock import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect.csr import *

# specific to a given DUT
from gateware import keyboard

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
    # Keyboard scan matrix
    ("kbd", 0,
     # "key" 0-8 are rows, 9-18 are columns
     Subsignal("row", Pins("F15", "E17", "G17", "E14", "E15", "H15", "G15", "H14",
         "H16"), IOStandard("LVCMOS33"), Misc("PULLDOWN True")),
     # column scan with 1's, so PD to default 0
     Subsignal("col", Pins("H17", "E18", "F18", "G18", "E13", "H18", "F13",
         "H13", "J13", "K13"), IOStandard("LVCMOS33")),
     ),
    ("lpclk", 0, Pins("N15"), IOStandard("LVCMOS18")),  # wifi_lpclk
]

"""
additional clocks beyond the simulation defaults
"""
local_clocks = {
    # add more clocks here, formatted as {"name" : [freq, phase]}
}

"""
add the submodules we're testing to the SoC, which is encapsulated in the Sim class
"""
class Dut(Sim):
    def __init__(self, platform, spiboot=False, **kwargs):
        Sim.__init__(self, platform, custom_clocks=local_clocks, spiboot=spiboot, **kwargs) # SoC magic is in here

        # Keyboard module
        self.submodules.keyboard = ClockDomainsRenamer(cd_remapping={"kbd":"lpclk"})(keyboard.KeyScan(platform.request("kbd")))
        self.add_csr("keyboard")
        self.add_interrupt("keyboard")

        self.clock_domains.cd_lpclk = ClockDomain()
        self.comb += self.cd_lpclk.clk.eq(platform.request("lpclk"))


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
    soc = Dut(platform)

    builder = Builder(soc, output_dir="./run", compile_software=False)
    vns = builder.build(run=False)
    soc.do_exit(vns)


"""
script to drive xsim
This is dut.py local because we may want to add local verilog models or tweak the
simulator in unusual ways
"""
def run_sim(ci=False):
    os_cmds = []
    SimRunner(ci, os_cmds)


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
