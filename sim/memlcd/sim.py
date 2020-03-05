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

from migen import *

import litex.soc.doc as lxsocdoc

from litex.build.generic_platform import *
from litex.build.xilinx import XilinxPlatform

from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.cores.clock import *
from litex.soc.integration.doc import AutoDoc, ModuleDoc
from litex.soc.interconnect.csr import *

from gateware import memlcd
from gateware import sram_32

crg_config = {
    # freqs
    "refclk": 12e6, # required, special name
    "sys": 100e6,   # required, special name
    # add more clocks here
}

benchio = [
    ("refclk", 0, Pins("X")),
    ("rst", 0, Pins("X")),

    ("sim", 0,
     Subsignal("success", Pins("X")),
     Subsignal("report", Pins("A B C D E F G H I J K L M N O P"))
     ),

    ("serial", 0,
     Subsignal("tx", Pins("V6")),
     Subsignal("rx", Pins("V7")),
     IOStandard("LVCMOS18"),
     ),
]


class Platform(XilinxPlatform):
    def __init__(self, simio):
        XilinxPlatform.__init__(self, "", simio + benchio)


class CRG(Module):
    def __init__(self, platform, core_config):
        # build a simulated PLL. Add clocks by adding key/value pairs to the crg_config dictionary
        self.submodules.pll = pll = S7MMCM()
        self.comb += pll.reset.eq(platform.request("rst"))

        for clks in crg_config.keys():
            if clks == 'refclk':
                pll.register_clkin(platform.request("refclk"), crg_config[clks])
            else:
                setattr(self.clock_domains, 'cd_' + clks, ClockDomain(name=clks))
                pll.create_clkout( getattr(self, 'cd_' + clks), crg_config[clks])


class SimStatus(Module, AutoCSR, AutoDoc):
    def __init__(self, pads):
        self.simstatus = CSRStorage(description="status output for simulator", fields=[
            CSRField("success", size = 1, description="Write `1` if simulation was a success"),
            CSRField("report", size = 16, description="A 16-bit field to report a result"),
        ])
        self.comb += pads.success.eq(self.simstatus.fields.success)
        self.comb += pads.report.eq(self.simstatus.fields.report)


VEX_CPU_PATH = "../../gateware/cpu/VexRiscv_BetrustedSoC_Debug.v"
class Sim(SoCCore):
    mem_map = {
        "rom"           : 0x00000000,
        "sram"          : 0x01000000,
        "spiflash"      : 0x20000000,
        "sram_ext"      : 0x40000000,
        "memlcd"        : 0xb0000000,
        "audio"         : 0xe0000000,
        "sha"           : 0xe0001000,
        "vexriscv_debug": 0xefff0000,
        "csr"           : 0xf0000000,
    }
    mem_map.update(SoCCore.mem_map)

    def __init__(self, platform, spiboot=False, **kwargs):
        SoCCore.__init__(self, platform, crg_config["sys"],
            integrated_rom_size  = 0x8000,
            integrated_sram_size = 0x20000,
            ident                = "simulation LiteX Base SoC",
            cpu_type             = "vexriscv",
            csr_paging           = 4096,
            csr_address_width    = 16,
            csr_data_width       = 32,
            uart_name            = "crossover",  # use UART-over-wishbone for debugging
            **kwargs)

        self.cpu.use_external_variant(VEX_CPU_PATH)
        self.cpu.add_debug()
        if spiboot:
            kwargs["cpu_reset_address"] = self.mem_map["spiflash"]
        else:
            kwargs["cpu_reset_address"] = self.mem_map["rom"]

        # instantiate the clock module
        self.submodules.crg = CRG(platform, crg_config)
        self.platform.add_period_constraint(self.crg.cd_sys.clk, 1e9/crg_config["sys"])

        self.platform.add_platform_command(
            "create_clock -name clk12 -period 83.3333 [get_nets input]")

        # add the status reporting module
        self.submodules.simstatus = SimStatus(platform.request("sim"))
        self.add_csr("simstatus")



## todo: split CRG, make automated waveform writing for ci mode


simio = [
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


class SimFocus(Sim):
    def __init__(self, platform, spiboot=False, **kwargs):
        Sim.__init__(self, platform, spiboot, **kwargs)

        # LCD interface
        self.submodules.memlcd = memlcd.MemLCD(platform.request("lcd"))
        self.add_csr("memlcd")
        self.register_mem("memlcd", self.mem_map["memlcd"], self.memlcd.bus, size=self.memlcd.fb_depth*4)

        # external SRAM for testing the build system
        self.submodules.sram_ext = sram_32.SRAM32(platform.request("sram"), rd_timing=7, wr_timing=6, page_rd_timing=2)
        self.add_csr("sram_ext")
        self.register_mem("sram_ext", self.mem_map["sram_ext"],
                  self.sram_ext.bus, size=0x1000000)


def generate_top():
    global simio
    # we have to do two passes: once to make the SVD, without compiling the BIOS
    # second, to compile the BIOS, which is then built into the gateware.

    # pass #1 -- make the SVD
    platform = Platform(simio)
    soc = SimFocus(platform)

    builder = Builder(soc, output_dir="./run", compile_gateware=False, compile_software=False)
    vns = builder.build(run=False)
    soc.do_exit(vns)

    # generate the PAC
    lxsocdoc.generate_svd(soc, "run/software", name="simulation", description="simulation core framework", filename="soc.svd", vendor="betrusted.io")
    os.system("mkdir -p run/software/bios/pac")
    os.system("cp ../../sim_support/rust/pac-Cargo.toml run/software/bios/pac/Cargo.toml")
    os.system("cd run/software/bios/pac && svd2rust --target riscv -i ../../soc.svd && rm -rf src && form -i lib.rs -o src/ && rm lib.rs && cargo doc && cargo fmt")

    # prepare the BIOS directory
    os.system("cp -rf ../../sim_support/rust/bios/* run/software/bios/")
    os.system("cp -rf ../../sim_support/rust/bios/.cargo run/software/bios/")
    os.system("cp -rf test run/software/bios/")

    # pass #2 -- generate the SoC, incorporating the now-built BIOS
    platform = Platform(simio)
    soc = SimFocus(platform)

    builder = Builder(soc, output_dir="./run")
    builder.software_packages = [
        ("bios", os.path.abspath(os.path.join(os.path.dirname(__file__), "../../sim_support/rust/bios")))
    ]
    vns = builder.build(run=False)
    soc.do_exit(vns)


# this ties it all together
def run_sim(ci=False):
    os.system("mkdir -p run")
    os.system("rm -rf run/xsim.dir")

    # copy over the top test bench
    os.system("cp top_tb.v run/top_tb.v")
    
    # initialize with a default waveform that contains the most basic execution tracing
    if os.path.isfile('run/top_tb_sim.wcfg') != True:
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


if __name__ == "__main__":
    main()
