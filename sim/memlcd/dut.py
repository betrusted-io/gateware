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
from gateware import memlcd
from gateware import sram_32

## todo: make automated waveform writing for ci mode

# top-level IOs specific to the DUT
dutio = [
    # LCD interface
    ("lcd", 0,
     Subsignal("sclk", Pins("A17"), IOStandard("LVCMOS33")),
     Subsignal("scs", Pins("C18"), IOStandard("LVCMOS33")),
     Subsignal("si", Pins("D17"), IOStandard("LVCMOS33")),
     ),

    # SRAM
    ("sram", 0,
     Subsignal("adr", Pins(
         "V12 M5 P5 N4  V14 M3 R17 U15",
         "M4  L6 K3 R18 U16 K1 R5  T2",
         "U1  N1 L5 K2  M18 T6"),
               IOStandard("LVCMOS18")),
     Subsignal("ce_n", Pins("V5"), IOStandard("LVCMOS18")),
     Subsignal("oe_n", Pins("U12"), IOStandard("LVCMOS18")),
     Subsignal("we_n", Pins("K4"), IOStandard("LVCMOS18")),
     Subsignal("zz_n", Pins("V17"), IOStandard("LVCMOS18")),
     Subsignal("d", Pins(
         "M2  R4  P2  L4  L1  M1  R1  P1 "
         "U3  V2  V4  U2  N2  T1  K6  J6 "
         "V16 V15 U17 U18 P17 T18 P18 M17 "
         "N3  T4  V13 P15 T14 R15 T3  R7 "), IOStandard("LVCMOS18")),
     Subsignal("dm_n", Pins("V3 R2 T5 T13"), IOStandard("LVCMOS18")),
     ),
]

local_clocks = {
    "clk200": [200e6, 45.0],
    # add more clocks here, formatted as {"name" : [freq, phase]}
}

boot_from_spi=False

# add the submodules we're testing to the SoC, which is encapsulated in the Sim class
class Dut(Sim):
    def __init__(self, platform, spiboot=False, **kwargs):
        Sim.__init__(self, platform, custom_clocks=local_clocks, spiboot=spiboot, **kwargs) # SoC magic is in here

        # LCD interface
        self.submodules.memlcd = memlcd.MemLCD(platform.request("lcd"))
        self.add_csr("memlcd")
        self.register_mem("memlcd", self.mem_map["memlcd"], self.memlcd.bus, size=self.memlcd.fb_depth*4)

        # external SRAM for testing the build system
        self.submodules.sram_ext = sram_32.SRAM32(platform.request("sram"), rd_timing=7, wr_timing=6, page_rd_timing=2)
        self.add_csr("sram_ext")
        self.register_mem("sram_ext", self.mem_map["sram_ext"],
                  self.sram_ext.bus, size=0x1000000)


# generate all the files necessary to run xsim
def generate_top():
    global dutio
    global boot_from_spi

    # we have to do two passes: once to make the SVD, without compiling the BIOS
    # second, to compile the BIOS, which is then built into the gateware.

    # pass #1 -- make the SVD
    platform = Platform(dutio)
    soc = Dut(platform, spiboot=boot_from_spi)

    builder = Builder(soc, output_dir="./run", compile_gateware=False, compile_software=False)
    vns = builder.build(run=False)
    soc.do_exit(vns)

    BiosHelper(soc, boot_from_spi)

    # pass #2 -- generate the SoC, incorporating the now-built BIOS
    platform = Platform(dutio)
    soc = Dut(platform)

    builder = Builder(soc, output_dir="./run")
    os.environ["DUTNAME"] = 'memlcd'
    builder.software_packages = [
        ("bios", os.path.abspath(os.path.join(os.path.dirname(__file__), "test")))
    ]
    vns = builder.build(run=False)
    soc.do_exit(vns)


# script to drive xsim
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
