#!/usr/bin/env python3

import sys
import os
import argparse
import random

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

adc_values = """
// This analog stimulus file is used to inject analog signals (e.g., volts, temperature) for a simulation.
// Units are as follows:
//          Time:                           nanoseconds [ns]
//          Voltage (All rails):     volts [V]
//          Temperature:             degrees C [C]. Please note that the temperature transfer function is in terms of Kelvin
//
// In this example the VCCAUX supply moves outside the 1.89V upper alarm limit at 67 us
// An alarm is generate when the VCCAUX channel is sampled and converted by the ADC

//      noise1            vbus              noise0              usb_p               usb_n
TIME    VAUXP[4] VAUXN[4] VAUXP[6] VAUXN[6] VAUXP[12] VAUXN[12] VAUXP[14] VAUXN[14] VAUXP[15] VAUXN[15] TEMP VCCINT VCCAUX VCCBRAM
00000   0.005    0.0      0.2      0.0      0.5       0.0       0.1       0.0       0.0       0.0       25    0.94    1.8     0.95
67000   0.020    0.0      0.400    0.0      0.49      0.0       0.2       0.0       0.0       0.0       35    0.94    1.79    0.94
100000  0.049    0.0      0.600    0.0      0.51      0.0       0.5       0.0       0.0       0.0       40    0.95    1.78    0.95
134000  0.034    0.0      0.900    0.0      0.53      0.0       0.5       0.0       0.0       0.0       41    0.96    1.81    0.96
150000  0.500    0.0      2.500    0.0      0.40      0.0       0.5       0.0       0.0       0.0       41    0.96    1.81    0.96
160000  0.450    0.0      2.500    0.0      0.56      0.0       0.5       0.0       0.0       0.0       41    0.96    1.81    0.96
"""

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
            kernel=self.trng_kernel, sim=True)
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
    extra_cmds = ['cd run && xvlog ../XADC.v']
    SimRunner(ci, extra_cmds)


def main():
    parser = argparse.ArgumentParser(description="Gateware simulation framework")
    parser.add_argument(
        "-c", "--ci", default=False, action="store_true", help="Run with settings for automated CI"
    )

    args = parser.parse_args()

    generate_top()

    # copy the ADC simulation values to the right place
    design_txt = open("run/design.txt", "w")
    global adc_values
    design_txt.write(adc_values)
    init_time = 161000
    print("generating random data for avalanche generator...")
    for i in range(65536):
        design_txt.write("{} {} 0.0 2.5 0.0 {} 0.0 0.5 0.0 0.0 0.0 41 0.95 1.80 0.95\n".format(str(init_time), (0.5 * random.randrange(4096)/4096) + 0.25, (0.25 * random.randrange(4096)/4096) + 0.5))
        init_time += 1000
    design_txt.close()
    print("done.")

    run_sim(ci=args.ci)
    if args.ci:
        if CheckSim() != 0:
            sys.exit(1)

    sys.exit(0)

if __name__ == "__main__":
    main()
