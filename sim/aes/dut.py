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
from migen.genlib.cdc import MultiReg
from migen.genlib.cdc import BlindTransfer

# specific to a given DUT
from gateware import sram_32  # for example...

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

class Aes(Module, AutoDoc, AutoCSR):
    def __init__(self, platform):
        # TODO: add ResetInserter() to key and data in fields
        self.key_0_q = CSRStorage(fields=[
            CSRField("key_0", size=32, description="least significant key word")
        ])
        self.key_1_q = CSRStorage(fields=[
            CSRField("key_1", size=32, description="key word 1")
        ])
        self.key_2_q = CSRStorage(fields=[
            CSRField("key_2", size=32, description="key word 2")
        ])
        self.key_3_q = CSRStorage(fields=[
            CSRField("key_3", size=32, description="key word 3")
        ])
        self.key_4_q = CSRStorage(fields=[
            CSRField("key_4", size=32, description="key word 4")
        ])
        self.key_5_q = CSRStorage(fields=[
            CSRField("key_5", size=32, description="key word 5")
        ])
        self.key_6_q = CSRStorage(fields=[
            CSRField("key_6", size=32, description="key word 6")
        ])
        self.key_7_q = CSRStorage(fields=[
            CSRField("key_7", size=32, description="most significant key word")
        ])

        self.dataout_0 = CSRStatus(fields=[
            CSRField("data_0", size=32, description="data output from cipher")
        ])
        self.dataout_1 = CSRStatus(fields=[
            CSRField("data_1", size=32, description="data output from cipher")
        ])
        self.dataout_2 = CSRStatus(fields=[
            CSRField("data_2", size=32, description="data output from cipher")
        ])
        self.dataout_3 = CSRStatus(fields=[
            CSRField("data_3", size=32, description="data output from cipher")
        ])

        self.datain_0 = CSRStorage(fields=[
            CSRField("data_0", size=32, description="data input")
        ])
        self.datain_1 = CSRStorage(fields=[
            CSRField("data_1", size=32, description="data input")
        ])
        self.datain_2 = CSRStorage(fields=[
            CSRField("data_2", size=32, description="data input")
        ])
        self.datain_3 = CSRStorage(fields=[
            CSRField("data_3", size=32, description="data input")
        ])

        self.iv_0 = CSRStorage(fields=[
            CSRField("iv_0", size=32, description="iv")
        ])
        self.iv_1 = CSRStorage(fields=[
            CSRField("iv_1", size=32, description="iv")
        ])
        self.iv_2 = CSRStorage(fields=[
            CSRField("iv_2", size=32, description="iv")
        ])
        self.iv_3 = CSRStorage(fields=[
            CSRField("iv_3", size=32, description="iv")
        ])

        self.ctrl = CSRStorage(fields=[
            CSRField("mode", size=3, description="set cipher mode. Illegal values mapped to `AES_ECB`", values=[
                ("001", "AES_ECB"),
                ("010", "AES_CBC"),
                ("100", "AES_CTR"),
            ]),
            CSRField("key_len", size=3, description="length of the aes block. Illegal values mapped to `AES128`", values=[
                    ("001", "AES128"),
                    ("010", "AES192"),
                    ("100", "AES256"),
            ]),
            CSRField("manual_operation", size=1, description="If `1`, operation starts when `trigger` bit `start` is written, otherwise automatically on data and IV ready"),
            CSRField("operation", size=1, description="Sets encrypt/decrypt operation. `0` = encrypt, `1` = decrypt"),
        ])
        self.status = CSRStatus(fields=[
            CSRField("idle", size=1, description="Core idle", reset=1),
            CSRField("stall", size=1, description="Core stall"),
            CSRField("output_valid", size=1, description="Data output valid"),
            CSRField("input_ready", size=1, description="Input value has been latched and it is OK to update to a new value", reset=1),
            CSRField("operation_rbk", size=1, description="Operation readback"),
            CSRField("mode_rbk", size=3, description="Actual mode selected by hardware readback"),
            CSRField("key_len_rbk", size=3, description="Actual key length selected by the hardware readback"),
            CSRField("manual_operation_rbk", size=1, description="Manual operation readback")
        ])

        self.trigger = CSRStorage(fields=[
            CSRField("start", size=1, description="Triggers an AES computation if manual_start is selected", pulse=True),
            CSRField("key_clear", size=1, description="Clears the key", reset=1, pulse=True),
            CSRField("iv_clear", size=1, description="Clears the IV", reset=1, pulse=True),
            CSRField("data_in_clear", size=1, description="Clears data input", reset=1, pulse=True),
            CSRField("data_out_clear", size=1, description="Clears the data output", reset=1, pulse=True),
            CSRField("prng_reseed", size=1, description="Reseed PRNG", reset=1, pulse=True),
        ])
        key0re50 = Signal()
        self.submodules.key0re = BlindTransfer("sys", "clk50")
        self.comb += [self.key0re.i.eq(self.key_0_q.re), key0re50.eq(self.key0re.o)]
        key1re50 = Signal()
        self.submodules.key1re = BlindTransfer("sys", "clk50")
        self.comb += [self.key1re.i.eq(self.key_1_q.re), key1re50.eq(self.key1re.o)]
        key2re50 = Signal()
        self.submodules.key2re = BlindTransfer("sys", "clk50")
        self.comb += [self.key2re.i.eq(self.key_2_q.re), key2re50.eq(self.key2re.o)]
        key3re50 = Signal()
        self.submodules.key3re = BlindTransfer("sys", "clk50")
        self.comb += [self.key3re.i.eq(self.key_3_q.re), key3re50.eq(self.key3re.o)]
        key4re50 = Signal()
        self.submodules.key4re = BlindTransfer("sys", "clk50")
        self.comb += [self.key4re.i.eq(self.key_4_q.re), key4re50.eq(self.key4re.o)]
        key5re50 = Signal()
        self.submodules.key5re = BlindTransfer("sys", "clk50")
        self.comb += [self.key5re.i.eq(self.key_5_q.re), key5re50.eq(self.key5re.o)]
        key6re50 = Signal()
        self.submodules.key6re = BlindTransfer("sys", "clk50")
        self.comb += [self.key6re.i.eq(self.key_6_q.re), key6re50.eq(self.key6re.o)]
        key7re50 = Signal()
        self.submodules.key7re = BlindTransfer("sys", "clk50")
        self.comb += [self.key7re.i.eq(self.key_7_q.re), key0re50.eq(self.key7re.o)]

        iv0_50 = Signal()
        self.submodules.iv0_50 = BlindTransfer("sys", "clk50")
        self.comb += [self.iv0_50.i.eq(self.iv_0.re), iv0_50.eq(self.iv0_50.o)]
        iv1_50 = Signal()
        self.submodules.iv1_50 = BlindTransfer("sys", "clk50")
        self.comb += [self.iv1_50.i.eq(self.iv_1.re), iv1_50.eq(self.iv1_50.o)]
        iv2_50 = Signal()
        self.submodules.iv2_50 = BlindTransfer("sys", "clk50")
        self.comb += [self.iv2_50.i.eq(self.iv_2.re), iv2_50.eq(self.iv2_50.o)]
        iv3_50 = Signal()
        self.submodules.iv3_50 = BlindTransfer("sys", "clk50")
        self.comb += [self.iv3_50.i.eq(self.iv_3.re), iv3_50.eq(self.iv3_50.o)]

        ctrlre50 = Signal()
        self.submodules.ctrl50re = BlindTransfer("sys", "clk50")
        self.comb += [self.ctrl50re.i.eq(self.ctrl.re), ctrlre50.eq(self.ctrl50re.o)]

        di0_50 = Signal()
        self.submodules.di0_50 = BlindTransfer("sys", "clk50")
        self.comb += [self.di0_50.i.eq(self.datain_0.re), di0_50.eq(self.di0_50.o)]
        di1_50 = Signal()
        self.submodules.di1_50 = BlindTransfer("sys", "clk50")
        self.comb += [self.di1_50.i.eq(self.datain_1.re), di1_50.eq(self.di1_50.o)]
        di2_50 = Signal()
        self.submodules.di2_50 = BlindTransfer("sys", "clk50")
        self.comb += [self.di2_50.i.eq(self.datain_2.re), di2_50.eq(self.di2_50.o)]
        di3_50 = Signal()
        self.submodules.di3_50 = BlindTransfer("sys", "clk50")
        self.comb += [self.di3_50.i.eq(self.datain_3.re), di3_50.eq(self.di3_50.o)]

        trigger_start = Signal()
        trigger_key_clear = Signal()
        trigger_iv_clear = Signal()
        trigger_data_in_clear = Signal()
        trigger_data_out_clear = Signal()
        trigger_prng_reseed = Signal()
        self.specials += MultiReg(self.trigger.fields.start, trigger_start, odomain="clk50")
        self.specials += MultiReg(self.trigger.fields.key_clear, trigger_key_clear, odomain="clk50")
        self.specials += MultiReg(self.trigger.fields.iv_clear, trigger_iv_clear, odomain="clk50")
        self.specials += MultiReg(self.trigger.fields.data_in_clear, trigger_data_in_clear, odomain="clk50")
        self.specials += MultiReg(self.trigger.fields.data_out_clear, trigger_data_out_clear, odomain="clk50")
        self.specials += MultiReg(self.trigger.fields.prng_reseed, trigger_prng_reseed, odomain="clk50")

        self.specials += Instance("aes_reg_top",
            i_clk_i = ClockSignal("clk50"),
            i_rst_ni = ~ResetSignal("clk50"),

            i_key_0_q=self.key_0_q.fields.key_0,
            i_key_0_qe=key0re50,
            i_key_1_q=self.key_1_q.fields.key_1,
            i_key_1_qe=key1re50,
            i_key_2_q=self.key_2_q.fields.key_2,
            i_key_2_qe=key2re50,
            i_key_3_q=self.key_3_q.fields.key_3,
            i_key_3_qe=key3re50,
            i_key_4_q=self.key_4_q.fields.key_4,
            i_key_4_qe=key4re50,
            i_key_5_q=self.key_5_q.fields.key_5,
            i_key_5_qe=key5re50,
            i_key_6_q=self.key_6_q.fields.key_6,
            i_key_6_qe=key6re50,
            i_key_7_q=self.key_7_q.fields.key_7,
            i_key_7_qe=key7re50,

            o_data_out_0=self.dataout_0.fields.data_0,
            o_data_out_1=self.dataout_1.fields.data_1,
            o_data_out_2=self.dataout_2.fields.data_2,
            o_data_out_3=self.dataout_3.fields.data_3,

            i_iv_0_q=self.iv_0.fields.iv_0,
            i_iv_0_qe=iv0_50,
            i_iv_1_q=self.iv_1.fields.iv_1,
            i_iv_1_qe=iv1_50,
            i_iv_2_q=self.iv_2.fields.iv_2,
            i_iv_2_qe=iv2_50,
            i_iv_3_q=self.iv_3.fields.iv_3,
            i_iv_3_qe=iv3_50,

            i_data_in_0=self.datain_0.fields.data_0,
            i_data_in_1=self.datain_1.fields.data_1,
            i_data_in_2=self.datain_2.fields.data_2,
            i_data_in_3=self.datain_3.fields.data_3,
            i_data_in_0_qe=di0_50,
            i_data_in_1_qe=di1_50,
            i_data_in_2_qe=di2_50,
            i_data_in_3_qe=di3_50,

            i_ctrl_mode=self.ctrl.fields.mode,
            i_ctrl_key_len=self.ctrl.fields.key_len,
            i_ctrl_manual_operation=self.ctrl.fields.manual_operation,
            i_ctrl_operation=self.ctrl.fields.operation,
            i_ctrl_update=ctrlre50,

            o_idle=self.status.fields.idle,
            o_stall=self.status.fields.stall,
            o_output_valid=self.status.fields.output_valid,
            o_input_ready=self.status.fields.input_ready,
            o_ctrl_key_len_rbk=self.status.fields.key_len_rbk,
            o_operation_rbk=self.status.fields.operation_rbk,
            o_mode_rbk=self.status.fields.mode_rbk,
            o_manual_operation_rbk=self.status.fields.manual_operation_rbk,

            i_start=trigger_start,
            i_key_clear=trigger_key_clear,
            i_iv_clear=trigger_iv_clear,
            i_data_in_clear=trigger_data_in_clear,
            i_data_out_clear=trigger_data_out_clear,
            i_prng_reseed=trigger_prng_reseed,
        )
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "prim", "rtl", "prim_assert.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "aes", "rtl", "aes_reg_pkg.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "aes", "rtl", "aes_pkg.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "aes", "rtl", "aes_control.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "aes", "rtl", "aes_key_expand.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "aes", "rtl", "aes_mix_columns.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "aes", "rtl", "aes_mix_single_column.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "aes", "rtl", "aes_sbox_canright.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "aes", "rtl", "aes_sbox_lut.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "aes", "rtl", "aes_sbox.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "aes", "rtl", "aes_shift_rows.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "aes", "rtl", "aes_sub_bytes.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "aes", "rtl", "aes_core.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "aes", "rtl", "aes_ctr.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "aes", "rtl", "aes_cipher_core.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "aes", "rtl", "aes_cipher_control.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "prim", "rtl", "prim_cipher_pkg.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "prim", "rtl", "prim_lfsr.sv"))
        platform.add_source(os.path.join("deps", "opentitan", "hw", "ip", "aes", "rtl", "aes_prng.sv"))
        platform.add_source(os.path.join("deps", "gateware", "gateware", "aes_reg_litex.sv"))

"""
add the submodules we're testing to the SoC, which is encapsulated in the Sim class
"""
class Dut(Sim):
    def __init__(self, platform, spiboot=False, **kwargs):
        Sim.__init__(self, platform, custom_clocks=local_clocks, spiboot=spiboot, **kwargs) # SoC magic is in here

        # Add something to simulate: Demo module for the template
        self.submodules.aes = Aes(platform)
        self.add_csr("aes")


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

    os.system("rm -rf test/betrusted-pac")  # nuke the old PAC if it exists
    os.system("mkdir -p test/betrusted-pac") # rebuild it from scratch every time
    os.system("cp pac-cargo-template test/betrusted-pac/Cargo.toml")
    os.system("cd test/betrusted-pac && svd2rust --target riscv -i ../../../../target/soc.svd && rm -rf src; form -i lib.rs -o src/; rm lib.rs")
    BiosHelper(soc, boot_from_spi) # marshals cargo to generate the BIOS from Rust files

    # pass #2 -- generate the SoC, incorporating the now-built BIOS
    platform = Platform(dutio)
    soc = Dut(platform, spiboot=boot_from_spi)

    builder = Builder(soc, output_dir="./run")
    builder.software_packages = [  # Point to a dummy Makefile, so Litex pulls in bios.bin but doesn't try building over it
        ("bios", os.path.abspath(os.path.join(os.path.dirname(__file__), "test")))
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
