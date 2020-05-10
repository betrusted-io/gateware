import os

from migen import *
from litex.soc.integration.doc import AutoDoc
from litex.soc.interconnect.csr import *
from migen.genlib.cdc import MultiReg
from migen.genlib.cdc import BlindTransfer

class Aes(Module, AutoDoc, AutoCSR):
    def __init__(self, platform):
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
        status_idle = Signal()
        status_idle_de = Signal()
        status_stall = Signal()
        status_stall_de = Signal()
        output_valid = Signal()
        output_valid_de = Signal()
        input_ready = Signal()
        input_ready_de = Signal()
        self.sync += [
            If(status_idle_de, self.status.fields.idle.eq(status_idle)).Else(self.status.fields.idle.eq(self.status.fields.idle)),
            If(status_stall_de, self.status.fields.stall.eq(status_stall)).Else(self.status.fields.stall.eq(self.status.fields.stall)),
            If(output_valid_de, self.status.fields.output_valid.eq(output_valid)).Else(self.status.fields.output_valid.eq(self.status.fields.output_valid)),
            If(input_ready_de, self.status.fields.input_ready.eq(input_ready)).Else(self.status.fields.input_ready.eq(self.status.fields.input_ready)),
        ]

        self.trigger = CSRStorage(fields=[
            CSRField("start", size=1, description="Triggers an AES computation if manual_start is selected", pulse=True),
            CSRField("key_clear", size=1, description="Clears the key", pulse=True),
            CSRField("iv_clear", size=1, description="Clears the IV", pulse=True),
            CSRField("data_in_clear", size=1, description="Clears data input", pulse=True),
            CSRField("data_out_clear", size=1, description="Clears the data output", pulse=True),
            CSRField("prng_reseed", size=1, description="Reseed PRNG", pulse=True),
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
        self.comb += [self.key7re.i.eq(self.key_7_q.re), key7re50.eq(self.key7re.o)]

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
        self.submodules.trigstart = BlindTransfer("sys", "clk50")
        self.comb += [self.trigstart.i.eq(self.trigger.fields.start), trigger_start.eq(self.trigstart.o)]
        trigger_key_clear = Signal()
        self.submodules.trigkeyclear = BlindTransfer("sys", "clk50")
        self.comb += [self.trigkeyclear.i.eq(self.trigger.fields.key_clear), trigger_key_clear.eq(self.trigkeyclear.o)]
        trigger_iv_clear = Signal()
        self.submodules.trigivclear = BlindTransfer("sys", "clk50")
        self.comb += [self.trigivclear.i.eq(self.trigger.fields.iv_clear), trigger_iv_clear.eq(self.trigivclear.o)]
        trigger_data_in_clear = Signal()
        self.submodules.trigdatinclear = BlindTransfer("sys", "clk50")
        self.comb += [ self.trigdatinclear.i.eq(self.trigger.fields.data_in_clear), trigger_data_in_clear.eq(self.trigdatinclear.o)]
        trigger_data_out_clear = Signal()
        self.submodules.trigdatoutclear = BlindTransfer("sys", "clk50")
        self.comb += [ self.trigdatoutclear.i.eq(self.trigger.fields.data_out_clear), trigger_data_out_clear.eq(self.trigdatoutclear.o)]
        trigger_prng_reseed = Signal()
        self.submodules.trigprng = BlindTransfer("sys", "clk50")
        self.comb += [ self.trigprng.i.eq(self.trigger.fields.prng_reseed), trigger_prng_reseed.eq(self.trigprng.o)]

        dataout0_re = Signal()
        self.submodules.dataout0_re = BlindTransfer("sys", "clk50")
        self.comb += [self.dataout0_re.i.eq(self.dataout_0.we), dataout0_re.eq(self.dataout0_re.o)]
        dataout1_re = Signal()
        self.submodules.dataout1_re = BlindTransfer("sys", "clk50")
        self.comb += [self.dataout1_re.i.eq(self.dataout_1.we), dataout1_re.eq(self.dataout1_re.o)]
        dataout2_re = Signal()
        self.submodules.dataout2_re = BlindTransfer("sys", "clk50")
        self.comb += [self.dataout2_re.i.eq(self.dataout_2.we), dataout2_re.eq(self.dataout2_re.o)]
        dataout3_re = Signal()
        self.submodules.dataout3_re = BlindTransfer("sys", "clk50")
        self.comb += [self.dataout3_re.i.eq(self.dataout_3.we), dataout3_re.eq(self.dataout3_re.o)]
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
            i_data_out_0_re=dataout0_re,
            o_data_out_1=self.dataout_1.fields.data_1,
            i_data_out_1_re=dataout1_re,
            o_data_out_2=self.dataout_2.fields.data_2,
            i_data_out_2_re=dataout2_re,
            o_data_out_3=self.dataout_3.fields.data_3,
            i_data_out_3_re=dataout3_re,

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

            o_idle=status_idle,
            o_idle_de=status_idle_de,
            o_stall=status_stall,
            o_stall_de=status_stall_de,
            o_output_valid=output_valid,
            o_output_valid_de=output_valid_de,
            o_input_ready=input_ready,
            o_input_ready_de=input_ready_de,
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