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
from sim_support.sim_bench import Sim, Platform, BiosHelper, CheckSim, SimRunner, Preamble, DoPac

# handy to keep around in case a DUT framework needs it
from litex.soc.integration.soc_core import *
from litex.soc.cores.clock import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect.csr import *
from migen.genlib.cdc import MultiReg
from migen.genlib.cdc import BlindTransfer

# specific to a given DUT
from gateware import aes_opentitan

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

        # Add something to simulate: Demo module for the template
        self.submodules.aes = aes_opentitan.Aes(platform)
        self.add_csr("aes")


"""
generate all the files necessary to run xsim
"""
def generate_top():
    global dutio
    global boot_from_spi

    # we have to do two passes: once to make the SVD, without compiling the BIOS
    # second, to compile the BIOS, which is then built into the gateware.
    Preamble()

    # pass #1 -- make the SVD
    platform = Platform(dutio)
    soc = Dut(platform, spiboot=boot_from_spi)

    builder = Builder(soc, output_dir="./run", csr_svd="../../target/soc.svd", compile_gateware=False, compile_software=False)
    builder.software_packages = []
    vns = builder.build(run=False)
    soc.do_exit(vns)

    DoPac('betrusted-pac')
    BiosHelper(soc, boot_from_spi) # marshals cargo to generate the BIOS from Rust files

    # pass #2 -- generate the SoC, incorporating the now-built BIOS
    platform = Platform(dutio)
    soc = Dut(platform, spiboot=boot_from_spi)

    builder = Builder(soc, output_dir="./run", compile_software=False)
    builder.software_packages = []
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
    extra_cmds =  ['cd run && xvlog -sv ../aes/prim_assert.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/aes_pkg.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/aes_reg_pkg.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/aes_cipher_control.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/aes_cipher_core.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/aes_control.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/aes_core.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/aes_ctr.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/aes_key_expand.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/aes_mix_columns.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/aes_mix_single_column.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/aes_pkg.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/aes_prng.sv']
    #extra_cmds += ['cd run && xvlog ../aes/aes_reg_top.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/aes_sbox_canright.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/aes_sbox_lut.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/aes_sbox.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/aes_shift_rows.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/aes_sub_bytes.sv']
    #extra_cmds += ['cd run && xvlog -sv ../aes/aes.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/prim_cipher_pkg.sv']
    extra_cmds += ['cd run && xvlog -sv ../aes/prim_lfsr.sv']
    extra_cmds += ['cd run && xvlog -sv ../../../gateware/aes_reg_litex.sv']
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
