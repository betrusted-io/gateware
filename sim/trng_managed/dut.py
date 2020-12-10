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
    ("noise", 0,
     Subsignal("noisebias_on", Pins("E17"), IOStandard("LVCMOS33")),  # DVT
     # Noise generator
     Subsignal("noise_on", Pins("P14 R13"), IOStandard("LVCMOS18")),
     ),
    ("analog", 0,
     Subsignal("usbdet_p", Pins("C3"), IOStandard("LVCMOS33")),  # DVT
     Subsignal("usbdet_n", Pins("A3"), IOStandard("LVCMOS33")),  # DVT
     Subsignal("vbus_div", Pins("C4"), IOStandard("LVCMOS33")),  # DVT
     Subsignal("noise0", Pins("C5"), IOStandard("LVCMOS33")),  # DVT
     Subsignal("noise1", Pins("A8"), IOStandard("LVCMOS33")),  # DVT
     # diff grounds
     Subsignal("usbdet_p_n", Pins("B3"), IOStandard("LVCMOS33")),  # DVT
     Subsignal("usbdet_n_n", Pins("A2"), IOStandard("LVCMOS33")),  # DVT
     Subsignal("vbus_div_n", Pins("B4"), IOStandard("LVCMOS33")),  # DVT
     Subsignal("noise0_n", Pins("B5"), IOStandard("LVCMOS33")),  # DVT
     Subsignal("noise1_n", Pins("A7"), IOStandard("LVCMOS33")),  # DVT
     # dedicated pins (no I/O standard applicable)
     Subsignal("ana_vn", Pins("K9")),
     Subsignal("ana_vp", Pins("J10")),
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

        platform.toolchain.attr_translate["KEEP"] = ("KEEP", "TRUE")
        platform.toolchain.attr_translate["DONT_TOUCH"] = ("DONT_TOUCH", "TRUE")

        from litex.soc.cores.xadc import analog_layout
        analog_pads = Record(analog_layout)
        analog = platform.request("analog")
        # DVT is solidly an xc7s50-only build
        dummy4 = Signal(4, reset=0)
        dummy5 = Signal(5, reset=0)
        dummy1 = Signal(1, reset=0)
        self.comb += analog_pads.vauxp.eq(Cat(dummy4,  # 0,1,2,3
            analog.noise1,  # 4
            dummy1,  # 5
            analog.vbus_div,  # 6
            dummy5,  # 7,8,9,10,11
            analog.noise0,  # 12
            dummy1,  # 13
            analog.usbdet_p,  # 14
            analog.usbdet_n,  # 15
        )),
        self.comb += analog_pads.vauxn.eq(Cat(dummy4,  # 0,1,2,3
            analog.noise1_n,  # 4
            dummy1,  # 5
            analog.vbus_div_n,  # 6
            dummy5,  # 7,8,9,10,11
            analog.noise0_n,  # 12
            dummy1,  # 13
            analog.usbdet_p_n,  # 14
            analog.usbdet_n_n,  # 15
        )),

        from gateware.trng.trng_managed import TrngManaged, TrngManagedKernel, TrngManagedServer
        self.submodules.trng_kernel = TrngManagedKernel()
        self.add_csr("trng_kernel")
        self.add_interrupt("trng_kernel")
        self.submodules.trng_server = TrngManagedServer()
        self.add_csr("trng_server")
        self.add_interrupt("trng_server")
        self.submodules.trng = TrngManaged(platform, analog_pads, platform.request("noise"), server=self.trng_server,
            kernel=self.trng_kernel)
        self.add_csr("trng")


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
