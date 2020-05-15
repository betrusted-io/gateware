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

# specific to a given DUT
from gateware import spi_7series
from gateware import spi_ice40

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
    # COM to UP5K (maste0)
    ("com", 0,
     Subsignal("csn", Pins("T15"), IOStandard("LVCMOS18")),
     Subsignal("miso", Pins("P16"), IOStandard("LVCMOS18")),
     Subsignal("mosi", Pins("N18"), IOStandard("LVCMOS18")),
     Subsignal("sclk", Pins("R16"), IOStandard("LVCMOS18")),
     ),

    # slave interface for testing UP5K side
    ("slave", 0,
     Subsignal("csn", Pins("dummy0")),
     Subsignal("miso", Pins("dummy1")),
     Subsignal("mosi", Pins("dummy2")),
     Subsignal("sclk", Pins("dummy3")),
     Subsignal("irq", Pins("dummy4")),
     ),
]

"""
additional clocks beyond the simulation defaults
"""
local_clocks = {
    "spi": [20e6, 0.0],
    "sys": [18e6, 0.0],  # this overrides the default 100e6 -- simulate like we're an ICE40
    # add more clocks here, formatted as {"name" : [freq, phase]}
}

"""
add the submodules we're testing to the SoC, which is encapsulated in the Sim class
"""
ICE40 = True
# change these to toggle between ICE-40-like sim or Spartan-like sim
if ICE40:
    VEX_CPU_PATH = "../../../pythondata-cpu-vexriscv/pythondata_cpu_vexriscv/verilog/VexRiscv_MinDebug.v" # to simulate ICE-40 config
    TARGET = "riscv32i-unknown-none-elf"
else:
    VEX_CPU_PATH = "../../gateware/cpu/VexRiscv_BetrustedSoC_Debug.v"
    TARGET = "riscv32imac-unknown-none-elf"

class Dut(Sim):
    def __init__(self, platform, spiboot=False, **kwargs):
        if ICE40:
            SoCCore.mem_map = {}  # clear the default map provided by the simulation
            SoCCore.mem_map["rom"] = 0x0
            SoCCore.mem_map["sram"] = 0x01000000
            SoCCore.mem_map["com"]  = 0xd0000000   # when simulating ICE40
            SoCCore.mem_map["csr"]  = 0xe0000000
        else:
            SoCCore.mem_map["wifi"] = 0xe0010000  # when simulating 7-series

        Sim.__init__(self, platform, custom_clocks=local_clocks, spiboot=spiboot, vex_verilog_path=VEX_CPU_PATH, **kwargs) # SoC magic is in here

        # FIXME: the SpiFifoSlave core inside spi_ice40 is *not* the code used in the EC
        # FIXME: the EC currently keeps it in an "rtl" directory. This should be fixed to point to "gateware"
        # SPI interface
        self.submodules.spimaster = ClockDomainsRenamer({"sys":"spi"})(spi_7series.SPIMaster(platform.request("com")))
        self.add_csr("spimaster")

        self.submodules.com = ClockDomainsRenamer({"spislave":"spi"})(spi_ice40.SpiFifoSlave(platform.request("slave")))
        self.add_wb_slave(self.mem_map["com"], self.com.bus, 4)
        self.add_memory_region("com", self.mem_map["com"], 4, type='io')
        self.add_csr("com")
        self.add_interrupt("com")


"""
generate all the files necessary to run xsim
"""
def generate_top():
    global dutio
    global boot_from_spi

    # we have to do two passes: once to make the SVD, without compiling the BIOS
    # second, to compile the BIOS, which is then built into the gateware.

    # pass #1 -- make the SVD
    platform = Platform(dutio)
    soc = Dut(platform, spiboot=boot_from_spi)

    os.system("mkdir -p ../../target")  # this doesn't exist on the first run
    builder = Builder(soc, output_dir="./run", csr_svd="../../target/soc.svd", compile_gateware=False, compile_software=False)
    vns = builder.build(run=False)
    soc.do_exit(vns)

    BiosHelper(soc, boot_from_spi, target=TARGET) # marshals cargo to generate the BIOS from Rust files

    # pass #2 -- generate the SoC, incorporating the now-built BIOS
    platform = Platform(dutio)
    soc = Dut(platform, spiboot=boot_from_spi)

    builder = Builder(soc, output_dir="./run")
    builder.software_packages = [  # Point to a dummy Makefile, so Litex pulls in bios.bin but doesn't try building over it
        ("bios", os.path.abspath(os.path.join(os.path.dirname(__file__), "testbench")))
    ]
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
    SimRunner(ci, extra_cmds, vex_verilog_path=VEX_CPU_PATH)


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
