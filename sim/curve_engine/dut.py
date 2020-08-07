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
from gateware.curve25519.engine import Engine
from litex.soc.integration.soc import SoCRegion

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
add the submodules we're testing to the SoC, which is encapsulated in the Sim class
"""
class Dut(Sim):
    def __init__(self, platform, spiboot=False, **kwargs):
        Sim.__init__(self, platform, custom_clocks=local_clocks, spiboot=spiboot, **kwargs) # SoC magic is in here
        SoCCore.mem_map["vectors"] = 0x30000000 # add test vector ROM area, cached OK

        self.submodules.engine = ClockDomainsRenamer({"eng_clk":"clk50", "rf_clk":"sys"})(Engine(platform, self.mem_map["engine"]))
        self.add_csr("engine")
        self.add_interrupt("engine")
        self.bus.add_slave("engine", self.engine.bus, SoCRegion(origin=self.mem_map["engine"], size=0x2_0000, cached=False))

        vector_data = get_mem_data("testbench/curve25519-dalek/test_vectors.bin", "little")
        self.add_rom("vectors", self.mem_map["vectors"], len(vector_data)*4, vector_data)


"""
generate all the files necessary to run xsim
"""
def generate_top():
    global dutio
    global boot_from_spi

    # build the test vectors for the curve engine
    os.system("cd testbench/curve25519-dalek && cargo test field::test::make_vectors")

    # we have to do two passes: once to make the SVD, without compiling the BIOS
    # second, to compile the BIOS, which is then built into the gateware.

    # pass #1 -- make the SVD
    platform = Platform(dutio)
    soc = Dut(platform, spiboot=boot_from_spi)

    os.system("mkdir -p ../../target")  # this doesn't exist on the first run
    builder = Builder(soc, output_dir="./run", csr_svd="../../target/soc.svd", compile_gateware=False, compile_software=False)
    vns = builder.build(run=False)
    soc.do_exit(vns)

    BiosHelper(soc, boot_from_spi) # marshals cargo to generate the BIOS from Rust files

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
    extra_cmds = ['echo "extra commands!"', 'echo "more extra commands!"']
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
