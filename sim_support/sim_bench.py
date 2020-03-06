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

VEX_CPU_PATH = "../../gateware/cpu/VexRiscv_BetrustedSoC_Debug.v"

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
        XilinxPlatform.__init__(self, "", simio + benchio)


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
        "sram"          : 0x01000000,
        "spiflash"      : 0x20000000,
        "sram_ext"      : 0x40000000,
        "memlcd"        : 0xb0000000,
        "audio"         : 0xe0000000,
        "sha"           : 0xe0001000,
        "vexriscv_debug": 0xefff0000,
        "csr"           : 0xf0000000,
    }

    # custom_clocks is a dictionary of clock name to clock speed pairs to add to the CRG
    # spiboot sets the reset vector to either spiflash memory space, or rom memory space
    # NOTE: for spiboot to work, you must add a SPI ROM model mapped to the correct memory space
    def __init__(self, platform, custom_clocks=None, spiboot=False, **kwargs):
        if custom_clocks:
            # copy custom clocks into the config array
            for key in custom_clocks.keys():
                crg_config[key] = custom_clocks[key]

        SoCCore.__init__(self, platform, crg_config["sys"][0],
            integrated_rom_size=0x8000,
            integrated_sram_size=0x20000,
            ident="simulation LiteX Base SoC",
            cpu_type="vexriscv",
            csr_paging=4096,
            csr_address_width=16,
            csr_data_width=32,
            uart_name="crossover",  # use UART-over-wishbone for debugging
            **kwargs)

        self.cpu.use_external_variant(VEX_CPU_PATH)
        # self.cpu.add_debug()
        if spiboot:
            kwargs["cpu_reset_address"] = self.mem_map["spiflash"]
        else:
            kwargs["cpu_reset_address"] = self.mem_map["rom"]

        # instantiate the clock module
        self.submodules.crg = CRG(platform, crg_config)
        self.platform.add_period_constraint(self.crg.cd_sys.clk, 1e9 / crg_config["sys"][0])

        self.platform.add_platform_command(
            "create_clock -name clk12 -period {:0.3f} [get_nets input]".format(1e9 / crg_config["refclk"][0]))

        # add the status reporting module, mandatory in every sim
        self.submodules.simstatus = SimStatus(platform.request("sim"))
        self.add_csr("simstatus")

class BiosHelper():
    def __init__(self, soc):
        sim_name = os.path.basename(os.getcwd())

        # generate the SVD
        os.system("mkdir -p ../../target")  # this doesn't exist on the first run
        lxsocdoc.generate_svd(soc, "../../target", name="simulation", description="simulation core framework", filename="soc.svd", vendor="betrusted.io")
        # this is now legacy, PAC generation is managed by a build.rs script
        # os.system("cd ../../sim_support/rust/pac && svd2rust --target riscv -i ../../../target/soc.svd && rm -rf src && form -i lib.rs -o src/ && rm lib.rs && cargo doc && cargo fmt")

        # run the BIOS build
        ret = 0
        ret += os.system("cd test && cargo build --release")
        ret += os.system("riscv64-unknown-elf-objcopy -O binary ../../target/riscv32imac-unknown-none-elf/release/{} run/software/bios/bios.bin".format(sim_name))
        ret += os.system("riscv64-unknown-elf-objdump -d ../../target/riscv32imac-unknown-none-elf/release/{} > run/bios.S".format(sim_name))
        if ret != 0:
            sys.exit(1)  # fail the build

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
