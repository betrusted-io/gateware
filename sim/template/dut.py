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
from sim_support.sim_bench import Sim, Platform, VEX_CPU_PATH, BiosHelper, CheckSim

# handy to keep around in case a DUT framework needs it
from litex.soc.integration.soc_core import *
from litex.soc.cores.clock import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect.csr import *

# specific to a given DUT
from gateware import sram_32  # for example...

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
    # Template for additional DUT I/O
    ("template", 0,
     Subsignal("pin", Pins("X")),
     Subsignal("bus", Pins("A B C D")),
    ),
]

"""
additional clocks beyond the simulation defaults
"""
local_clocks = {
    "clk50": [50e6, 22.5],
    # add more clocks here, formatted as {"name" : [freq, phase]}
}

"""
A self-contained module for the template. Normally this is deleted and
instead a `from gateware import <dut>` statement is used to pull in
the appropriate DUT from the gateware directory.
"""
class Demo(Module, AutoCSR, AutoDoc):
    def __init__(self, pads):
        self.demo = CSRStorage(description="A demo register for the template", fields=[
            CSRField("pin", size=1, description="Connect this to the `pin` port"),
            CSRField("bus", size=4, description="Connect this to the `bus` port"),
        ])
        self.sync.clk50 += pads.pin.eq(self.demo.fields.pin)  # use the clk50 local clock domain
        self.sync.clk50 += pads.bus.eq(self.demo.fields.bus)

"""
add the submodules we're testing to the SoC, which is encapsulated in the Sim class
"""
class Dut(Sim):
    def __init__(self, platform, spiboot=False, **kwargs):
        Sim.__init__(self, platform, custom_clocks=local_clocks, spiboot=spiboot, **kwargs) # SoC magic is in here

        # Add something to simulate: Demo module for the template
        self.submodules.demo = Demo(platform.request("template"))
        self.add_csr("demo")


"""
generate all the files necessary to run xsim
"""
def generate_top():
    global dutio
    global boot_from_spi

    # Pass the boot type to the Rust build subsystem via an environment variable
    # this is later used by the build.rs in the bios to copy the correct memory.x template for the linker
    if boot_from_spi:
        os.environ["BOOT_TYPE"] = 'SPI'
    else:
        os.environ["BOOT_TYPE"] = 'ROM'


    # we have to do two passes: once to make the SVD, without compiling the BIOS
    # second, to compile the BIOS, which is then built into the gateware.

    # pass #1 -- make the SVD
    platform = Platform(dutio)
    soc = Dut(platform, spiboot=boot_from_spi)

    builder = Builder(soc, output_dir="./run", compile_gateware=False, compile_software=False)
    vns = builder.build(run=False)
    soc.do_exit(vns)

    BiosHelper(soc) # marshals cargo to generate the BIOS from Rust files

    # pass #2 -- generate the SoC, incorporating the now-built BIOS
    platform = Platform(dutio)
    soc = Dut(platform)

    builder = Builder(soc, output_dir="./run")
    builder.software_packages = [  # Point to a dummy Makefile, so Litex pulls in bios.bin but doesn't try building over it
        ("bios", os.path.abspath(os.path.join(os.path.dirname(__file__), "test")))
    ]
    vns = builder.build(run=False)
    soc.do_exit(vns)


"""
script to drive xsim
This is dut.py local because we may want to add local verilog models or tweak the
simulator in unusual ways
"""
def run_sim(ci=False):
    os.system("mkdir -p run")
    os.system("rm -rf run/xsim.dir")

    # copy over the top test bench and common code
    os.system("cp top_tb.v run/top_tb.v")
    os.system("cp ../../sim_support/common.v run/")
    
    # initialize with a default waveform that contains the most basic execution tracing
    if os.path.isfile('run/top_tb_sim.wcfg') != True:
        if os.path.isfile('top_tb_sim.wcfg'):
            os.system('cp top_tb_sim.wcfg run/')
        else:
            os.system('cp ../../sim_support/top_tb_sim.wcfg run/')
            
    # load up simulator dependencies
    os.system("cd run && cp gateware/*.init .")
    os.system("cd run && cp gateware/*.v .")
    os.system("cd run && xvlog ../../../sim_support/glbl.v")
    os.system("cd run && xvlog top.v -sv")
    os.system("cd run && xvlog top_tb.v -sv ")
    os.system("cd run && xvlog {}".format("../"+VEX_CPU_PATH))
    os.system("cd run && xelab -debug typical top_tb glbl -s top_tb_sim -L unisims_ver -L unimacro_ver -L SIMPRIM_VER -L secureip -L $xsimdir/xil_defaultlib -timescale 1ns/1ps")
    if ci:
        os.system("cd run && xsim top_tb_sim -runall -wdb ci.wdb")
    else:
        os.system("cd run && xsim top_tb_sim -gui")


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
