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
from litex.soc.cores.spi_opi import S7SPIOPI

"""
set boot_from_spi to change the reset vector and linking location of BIOS
note that this script does not link `run/software/bios/bios.bin` to
a .init file suitable for the SPI verilog model. This needs to be done
with additional code or tooling based on the specific SPI verilog model 
employed.
"""
boot_from_spi=True

"""
top-level IOs specific to the DUT
"""
dutio = [
    # SPI Flash
    ("spiflash_4x", 0,  # clock needs to be accessed through STARTUPE2
     Subsignal("cs_n", Pins("M13")),
     Subsignal("dq", Pins("K17 K18 L14 M15")),
     IOStandard("LVCMOS18")
     ),
    ("spiflash_1x", 0,  # clock needs to be accessed through STARTUPE2
     Subsignal("cs_n", Pins("M13")),
     Subsignal("copi", Pins("K17")),
     Subsignal("cipo", Pins("K18")),
     Subsignal("wp", Pins("L14")),  # provisional
     Subsignal("hold", Pins("M15")),  # provisional
     IOStandard("LVCMOS18")
     ),
    ("spiflash_8x", 0,  # clock needs to be accessed through STARTUPE2
     Subsignal("cs_n", Pins("M13")),
     Subsignal("dq", Pins("K17 K18 L14 M15 L17 L18 M14 N14")),
     Subsignal("dqs", Pins("R14")),
     Subsignal("ecs_n", Pins("L16")),
     Subsignal("sclk", Pins("L13")),
     IOStandard("LVCMOS18")
     ),
]

"""
additional clocks beyond the simulation defaults
"""
local_clocks = {
    "spinor": [100e6, 82.5],
    "idelay_ref": [200e6, 0.0],
    # add more clocks here, formatted as {"name" : [freq, phase]}
}

boot_offset    = 0x0 #0x500000 # enough space to hold 2x FPGA bitstreams before the firmware start

"""
add the submodules we're testing to the SoC, which is encapsulated in the Sim class
"""
class Dut(Sim):
    def __init__(self, platform, spiboot=False, **kwargs):
        Sim.__init__(self, platform, custom_clocks=local_clocks, spiboot=spiboot, **kwargs) # SoC magic is in here

        # Add an IDELAYCTRL primitive for the SpiOpi block
        reset_counter = Signal(5, reset=31)  # 155ns @ 200MHz, min 59.28ns
        ic_reset = Signal(reset=1)
        self.sync.idelay_ref += \
            If(reset_counter != 0,
                reset_counter.eq(reset_counter - 1)
            ).Else(
                ic_reset.eq(0)
            )
        self.delay_rdy = Signal()
        self.specials += Instance("IDELAYCTRL", i_REFCLK=ClockSignal("idelay_ref"), i_RST=ic_reset, o_RDY=self.delay_rdy)
        self.ready = CSRStatus()
        self.comb += self.ready.status.eq(self.delay_rdy)

        # spi control -- that's the point of this simulation!
        SPI_FLASH_SIZE=128 * 1024 * 1024
        sclk_instance_name = "SCLK_ODDR"
        iddr_instance_name = "SPI_IDDR"
        cipo_instance_name = "cipo_FDRE"
        self.submodules.spinor = S7SPIOPI(platform.request("spiflash_8x"),
                                               sclk_name=sclk_instance_name, iddr_name=iddr_instance_name,
                                               cipo_name=cipo_instance_name, sim=True)
        platform.add_source("../../gateware/spimemio.v") ### NOTE: this actually doesn't help for SIM, but it reminds us to scroll to the bottom of this file and add it to the xvlog imports
        self.register_mem("spiflash", self.mem_map["spiflash"], self.spinor.bus, size=SPI_FLASH_SIZE)
        self.add_csr("spinor")


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
    extra_cmds = ["cd run && xvlog ../MX66UM1G45G/MX66UM1G45G.v", "cd run && xvlog ../../../gateware/spimemio.v"]
    SimRunner(ci, extra_cmds)


def main():
    parser = argparse.ArgumentParser(description="Gateware simulation framework")
    parser.add_argument(
        "-c", "--ci", default=False, action="store_true", help="Run with settings for automated CI"
    )

    args = parser.parse_args()

    generate_top()

    # generate a .init file for the SPINOR memory based on the BIOS we want to boot
    with open("run/software/bios/bios.bin", "rb") as ifile:
        with open("run/simspi.init", "w") as ofile:
            binfile = ifile.read()

            count = 0
            for b in binfile:
                ofile.write("{:02x}\n".format(b))
                count += 1

            while count < 64 *1024:
                ofile.write("00\n")
                count += 1

            ofile.write("C3\n");
            ofile.write("69\n");
            ofile.write("DE\n");
            ofile.write("C0\n");


    run_sim(ci=args.ci)
    if args.ci:
        if CheckSim() != 0:
            sys.exit(1)

    sys.exit(0)

if __name__ == "__main__":
    main()
