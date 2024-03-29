#!/usr/bin/env python3

from operator import floordiv
import sys
import os
import shutil
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

VEX_CPU_PATH = "../../../../VexRiscv/VexRiscv_BetrustedSoC.v"
VEX_CPU_BIN = "../../../../VexRiscv/VexRiscv_BetrustedSoC.v_toplevel_memory_AesPlugin_rom_storage.bin"
TARGET = "riscv32imac-unknown-none-elf"

benchio = [
    ("refclk", 0, Pins("X")),
    ("rst", 0, Pins("X")),

    ("sim", 0,
     Subsignal("success", Pins("X")),
     Subsignal("done", Pins("Z")),
     Subsignal("report", Pins("A B C D E F G H I J K L M N O P A B C D E F G H I J K L M N O P"))
     ),

    ("serial", 0,
     Subsignal("tx", Pins("V6")),
     Subsignal("rx", Pins("V7")),
     IOStandard("LVCMOS18"),
     ),
]

crg_config = {
    # freqs
    "refclk": [12e6, 0.0],    # required, special name
    "sys":    [100e6, 0.0],   # required, special name
}

class Platform(XilinxPlatform):
    def __init__(self, simio):
        part = "xc7s" + "50" + "-csga324-1il"
        XilinxPlatform.__init__(self, part, simio + benchio, toolchain="vivado")


class CRG(Module):
    def __init__(self, platform, core_config):
        # build a simulated PLL. Add clocks by adding key/value pairs to the crg_config dictionary
        self.submodules.pll = pll = S7MMCM()
        self.comb += pll.reset.eq(platform.request("rst"))

        for clks in crg_config.keys():
            if clks == 'refclk':
                pll.register_clkin(platform.request("refclk"), crg_config[clks][0])
            else:
                setattr(self.clock_domains, 'cd_' + clks, ClockDomain(name=clks))
                if clks == 'sys':
                    pll.create_clkout(getattr(self, 'cd_' + clks), crg_config[clks][0], margin=0) # make sysclk precisely
                else:
                    pll.create_clkout( getattr(self, 'cd_' + clks), crg_config[clks][0], phase=crg_config[clks][1])


class SimStatus(Module, AutoCSR, AutoDoc):
    def __init__(self, pads):
        self.simstatus = CSRStorage(description="status output for simulator", fields=[
            CSRField("success", size = 1, description="Write `1` if simulation was a success"),
            CSRField("done", size = 1, description="Write `1` to indicate to the simulator that the simulation is done"),
        ])
        self.report = CSRStorage(size=32, description="report code for simulation")
        self.comb += pads.success.eq(self.simstatus.fields.success)
        self.comb += pads.report.eq(self.report.storage)
        self.comb += pads.done.eq(self.simstatus.fields.done)

class Sim(SoCCore):
    SoCCore.mem_map = {
        "rom"           : 0x00000000,
        "spiflash"      : 0x20000000,
        "sram_ext"      : 0x40000000,
        "memlcd"        : 0xb0000000,
        "audio"         : 0xe0000000,
        "sha2"          : 0xe0001000,
        "sha512"        : 0xe0002000,
        "engine"        : 0xe0020000,
        "vexriscv_debug": 0xefff0000,
        "csr"           : 0xf0000000,
    }

    # custom_clocks is a dictionary of clock name to clock speed pairs to add to the CRG
    # spiboot sets the reset vector to either spiflash memory space, or rom memory space
    # NOTE: for spiboot to work, you must add a SPI ROM model mapped to the correct memory space
    def __init__(self, platform, custom_clocks=None, spiboot=False, vex_verilog_path=VEX_CPU_PATH, **kwargs):
        if custom_clocks:
            # copy custom clocks into the config array
            for key in custom_clocks.keys():
                crg_config[key] = custom_clocks[key]

        rom_size = 0x8000
        reset_address = self.mem_map["rom"]
        if spiboot:
            reset_address = self.mem_map["spiflash"]
            rom_size = 0x0
            rom_init = []
        else:
            rom_init = 'run/software/bios/bios.bin'

        SoCCore.__init__(self, platform, crg_config["sys"][0],
            integrated_rom_size=rom_size,
            integrated_rom_init=rom_init,
            integrated_sram_size=0x20000,
            ident="simulation LiteX Base SoC",
            cpu_type="vexriscv",
            csr_paging=4096,
            csr_address_width=16,
            csr_data_width=32,
            uart_name="crossover",  # use UART-over-wishbone for debugging
            cpu_reset_address=reset_address,
            **kwargs)
        # work around for https://github.com/enjoy-digital/litex/commit/ceb8a6502cc1315eb48fa654a073101c783013a3
        # LiteX has started hard-coding the location of SRAM, with no option to change it!
        self.add_ram("sram2", 0x01000000, 0x20000)

        self.cpu.use_external_variant(vex_verilog_path)

        # instantiate the clock module
        self.submodules.crg = CRG(platform, crg_config)
        self.platform.add_period_constraint(self.crg.cd_sys.clk, 1e9 / crg_config["sys"][0])

        self.platform.add_platform_command(
            "create_clock -name clk12 -period {:0.3f} [get_nets input]".format(1e9 / crg_config["refclk"][0]))

        # add the status reporting module, mandatory in every sim
        self.submodules.simstatus = SimStatus(platform.request("sim"))
        self.add_csr("simstatus")

class BiosHelper():
    def __init__(self, soc, spiboot, nightly=False, target=TARGET):
        sim_name = os.path.basename(os.getcwd())

        # setup the correct linker script for the BIOS build based on the SoC's boot vector settings
        if spiboot:
            shutil.copyfile('../../sim_support/memory_spi.x', '../../target/memory.x')
        else:
            shutil.copyfile('../../sim_support/memory_rom.x', '../../target/memory.x')

        # run the BIOS build
        ret = 0
        try:
            os.system("mkdir run" + os.path.sep + "software" + os.path.sep + "bios") # make the directory if it doesn't exist
        except:
            pass
        if nightly:
            ret += os.system("cd testbench && cargo +nightly build --target {} --release".format(target))
        else:
            ret += os.system("cd testbench && cargo build --target {} --release".format(target))
        ret += os.system("riscv64-unknown-elf-objcopy -j .text -j .rodata -j .data -O binary ../../target/{}/release/{} run/software/bios/bios.bin".format(target, sim_name))
        # -d makes a much smaller file; but you need -D to capture the .data section
        ret += os.system("riscv64-unknown-elf-objdump -d ../../target/{}/release/{} > run/bios.S".format(target, sim_name))
        if ret != 0:
            sys.exit(1)  # fail the build

class DoPac():
    def __init__(self, name):
        if os.name == 'nt':
            subprocess.run("rd /S /Q testbench\\{}".format(name), shell=True)
            subprocess.run("mkdir testbench\\{}".format(name), shell=True)
            subprocess.run("copy pac-cargo-template testbench\\{}\\Cargo.toml".format(name), shell=True)
            subprocess.run("cargo install svd2rust --version 0.30.3") # make sure dependencies are installed
            subprocess.run("cargo install form") # make sure dependencies are installed
            subprocess.run("cd testbench\\{} && svd2rust --target riscv -i ..\\..\\..\\..\\target\\soc.svd".format(name), shell=True)
            subprocess.run("cd testbench\\{} && rd /S /Q src".format(name), shell=True)
            subprocess.run("cd testbench\\{} && form -i lib.rs -o src\\".format(name), shell=True)
            subprocess.run("cd testbench\\{} && del lib.rs\\".format(name), shell=True)
        else:
            os.system("rm -rf testbench/{}".format(name))  # nuke the old PAC if it exists
            os.system("mkdir -p testbench/{}".format(name)) # rebuild it from scratch every time
            os.system("cp pac-cargo-template testbench/{}/Cargo.toml".format(name))
            os.system("cargo install svd2rust --version 0.30.3") # sv2drust breaks after this version, due to requiring a method call instead of a reference to a struct element to access peripherals
            os.system("cargo install form") # make sure dependencies are installed
            os.system("cd testbench/{} && svd2rust --target riscv -i ../../../../target/soc.svd && rm -rf src; form -i lib.rs -o src/; rm lib.rs".format(name))

class Preamble():
    def __init__(self):
        if os.name == 'nt':
            # windows is really, really hard to do this right. Apparently mkdir and copy aren't "commands", they are shell built-ins
            # plus path separators are different plus calling os.mkdir() is different from the mkdir version in the windows shell. ugh.
            # just...i give up. we can't use a single syscall for both. we just have to do it differently for each platform.
            subprocess.run("mkdir run\\software\\bios", shell=True)
            subprocess.run("mkdir ..\\..\\target", shell=True)
            subprocess.run("copy ..\\..\\sim_support\\placeholder_bios.bin run\\software\\bios\\bios.bin", shell=True)
        else:
            os.system("mkdir -p run/software/bios")
            os.system("mkdir -p ../../target")  # this doesn't exist on the first run
            os.system("cp ../../sim_support/placeholder_bios.bin run/software/bios/bios.bin")

class SimRunner():
    def __init__(self, ci, os_cmds, vex_verilog_path=VEX_CPU_PATH):
        # we need to use wildcards, so shutil is rather hard to code around. Use this hack instead.
        if os.name == 'nt':
            cpname = 'copy'
        else:
            cpname = 'cp'

        try:
            os.system("mkdir run") # was "mkdir -p run"
        except:
            pass

        if os.name == 'nt':
            os.system('rmdir /S /Q run\\xsim.dir')
        else:
            os.system("rm -rf run/xsim.dir")

        # copy over the top test bench and common code
        os.system("{} top_tb.v run".format(cpname) + os.path.sep + "top_tb.v") # "cp top_tb.v run/top_tb.v"
        os.system("{} ..".format(cpname) + os.path.sep + ".." + os.path.sep + "sim_support" + os.path.sep + "common.v run" + os.path.sep) # "cp ../../sim_support/common.v run/"

        # initialize with a default waveform that contains the most basic execution tracing
        if os.path.isfile('run/top_tb_sim.wcfg') != True:
            if os.path.isfile('top_tb_sim.wcfg'):
                os.system('{} top_tb_sim.wcfg run'.format(cpname) + os.path.sep) # 'cp top_tb_sim.wcfg run/'
            else:
                os.system('{} ..'.format(cpname)+os.path.sep+'..'+os.path.sep+'sim_support'+os.path.sep+'top_tb_sim.wcfg run' + os.path.sep) # 'cp ../../sim_support/top_tb_sim.wcfg run/'

        # load up simulator dependencies
        os.system("cd run && {} gateware".format(cpname)+os.path.sep+"*.init .") # "cd run && cp gateware/*.init ."
        os.system("cd run && {} gateware".format(cpname)+os.path.sep+"*.v .") # "cd run && cp gateware/*.v ."
        os.system("cd run && xvlog .."+os.path.sep+".."+os.path.sep+".."+os.path.sep+"sim_support"+os.path.sep+"glbl.v") # "cd run && xvlog ../../../sim_support/glbl.v"
        os.system("cd run && xvlog sim_bench.v -sv")
        os.system("cd run && xvlog top_tb.v -sv ")
        vex_dir = os.path.dirname(VEX_CPU_PATH)
        # copy any relevant .bin files into the run directory as well
        os.system("{} {} ".format(cpname, vex_dir.replace("/",os.path.sep) + os.path.sep + "*.bin") + " run" + os.path.sep) # "{} {} run/".format(cpname, vex_dir + "/*.bin")
        os.system("cd run && xvlog {}".format(".." + os.path.sep + vex_verilog_path)) # "cd run && xvlog {}".format("../" + vex_verilog_path)

        # run user dependencies
        for cmd in os_cmds:
            os.system(cmd)

        os.system(
            "cd run && xelab -debug typical top_tb glbl -s top_tb_sim -L unisims_ver -L unimacro_ver -L SIMPRIM_VER -L secureip -L $xsimdir/xil_defaultlib -timescale 1ns/1ps")
        if ci:
            os.system("cd run && xsim top_tb_sim -runall -wdb ci.wdb")
        else:
            os.system("cd run && xsim top_tb_sim -gui")


# for automated VCD checking after CI run
import vcd
import logging

ci_pass = False

class CiTracker(vcd.VCDTracker):
    skip = False
    states = {}
    state = None
    journal = None
    def start(self):
        self.states = {
            "IDLE": self.idle_state,
            "STOP": self.stop_state,
        }
        self.state = self.states["IDLE"]
        self.journal = open('run/ci.log', 'w')

    def update(self):
        self.state()

    def idle_state(self):
        if self["top_tb.success"] == "1":
            global ci_pass
            print("Success: report code 0x{:08x}".format(vcd.v2d(self["top_tb.report"])), file=self.journal)
            ci_pass = True
            self.state = self.states["STOP"]
        else:
            print("Failure: report code 0x{:08x}".format(vcd.v2d(self["top_tb.report"])), file=self.journal)
            self.state = self.states["STOP"]

    def stop_state(self):
        return

class CiWatcher(vcd.VCDWatcher):
    def __init__(self, parser, **kwds):
        super().__init__(parser, **kwds)

    def should_notify(self):
        if (self.get_id("top_tb.done") in self.activity
            and self.get_active_2val("top_tb.done")  # errors out if X or Z
            ):
            return True

        return False

def CheckSim():
    logging.basicConfig()

    parser = vcd.VCDParser(log_level=logging.INFO)
    tracker = CiTracker()
    watcher = CiWatcher(
        parser,
        sensitive=["top_tb.done"],
        watch=[
            "top_tb.success",
            "top_tb.done",
            "top_tb.report",
        ],
        trackers=[tracker],
    )

    with open('run/ci.vcd') as vcd_file:
        parser.parse(vcd_file)

    tracker.journal.close()

    global ci_pass
    if ci_pass:
        return 0
    else:
        return 1
