// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Top module auto-generated by `reggen`

module aes_reg_top (
  input 	clk_i,
  input 	rst_ni,

  // Below Regster interface can be changed
  output [31:0] key_0_d,
  input [31:0] 	key_0_q,
  input 	key_0_qe,

  output [31:0] key_1_d,
  input [31:0] 	key_1_q,
  input 	key_1_qe,

  output [31:0] key_2_d,
  input [31:0] 	key_2_q,
  input 	key_2_qe,

  output [31:0] key_3_d,
  input [31:0] 	key_3_q,
  input 	key_3_qe,

  output [31:0] key_4_d,
  input [31:0] 	key_4_q,
  input 	key_4_qe,

  output [31:0] key_5_d,
  input [31:0] 	key_5_q,
  input 	key_5_qe,

  output [31:0] key_6_d,
  input [31:0] 	key_6_q,
  input 	key_6_qe,

  output [31:0] key_7_d,
  input [31:0] 	key_7_q,
  input 	key_7_qe,

  output [31:0] data_in_0_from_core,
  output 	data_in_0_de_from_core,
  input [31:0] 	data_in_0_to_core,
  input 	data_in_0_qe_to_core,

  output [31:0] data_in_1_from_core,
  output 	data_in_1_de_from_core,
  input [31:0] 	data_in_1_to_core,
  input 	data_in_1_qe_to_core,

  output [31:0] data_in_2_from_core,
  output 	data_in_2_de_from_core,
  input [31:0] 	data_in_2_to_core,
  input 	data_in_2_qe_to_core,

  output [31:0] data_in_3_from_core,
  output 	data_in_3_de_from_core,
  input [31:0] 	data_in_3_to_core,
  input 	data_in_3_qe_to_core,

  output [31:0] data_out_0,
  input 	data_out_0_re,
  output [31:0] data_out_1,
  input 	data_out_1_re,
  output [31:0] data_out_2,
  input 	data_out_2_re,
  output [31:0] data_out_3,
  input 	data_out_3_re,

  // ctrl register
  input ctrl_mode,
  input [2:0] ctrl_key_len,
  output [2:0] ctrl_key_len_rbk,
  input ctrl_manual_start_trigger,
  input ctrl_force_data_overwrite,
  input ctrl_update,

  // status
  output idle,
  output stall,
  output output_valid,
  output input_ready,

  // trigger
  input start,
  input key_clear,
  input data_in_clear,
  input data_out_clear,

  // Config
  input 	devmode_i // If 1, explicit error return for unmapped register access
);

  import aes_reg_pkg::* ;

  aes_reg2hw_t reg2hw;
  aes_hw2reg_t hw2reg;

  localparam AW = 7;
  localparam DW = 32;
  localparam DBW = DW/8;                    // Byte Width

		
  // register signals
  logic           reg_we;
  logic           reg_re;
  logic [AW-1:0]  reg_addr;
  logic [DW-1:0]  reg_wdata;
  logic [DBW-1:0] reg_be;
  logic [DW-1:0]  reg_rdata;
  logic           reg_error;

  logic          addrmiss, wr_err;

  logic [DW-1:0] reg_rdata_next;

  assign reg_rdata = reg_rdata_next ;
  assign reg_error = (devmode_i & addrmiss) | wr_err ;

  // Define SW related signals
  // Format: <reg>_<field>_{wd|we|qs}
  //        or <reg>_{wd|we|qs} if field == 1 or 0
  logic [31:0] key0_wd;
  logic key0_we;
  logic [31:0] key1_wd;
  logic key1_we;
  logic [31:0] key2_wd;
  logic key2_we;
  logic [31:0] key3_wd;
  logic key3_we;
  logic [31:0] key4_wd;
  logic key4_we;
  logic [31:0] key5_wd;
  logic key5_we;
  logic [31:0] key6_wd;
  logic key6_we;
  logic [31:0] key7_wd;
  logic key7_we;
  logic [31:0] data_in0_wd;
  logic data_in0_we;
  logic [31:0] data_in1_wd;
  logic data_in1_we;
  logic [31:0] data_in2_wd;
  logic data_in2_we;
  logic [31:0] data_in3_wd;
  logic data_in3_we;
  logic [31:0] data_out0_qs;
  logic data_out0_re;
  logic [31:0] data_out1_qs;
  logic data_out1_re;
  logic [31:0] data_out2_qs;
  logic data_out2_re;
  logic [31:0] data_out3_qs;
  logic data_out3_re;
  logic ctrl_mode_qs;
  logic ctrl_mode_wd;
  logic ctrl_mode_we;
  logic ctrl_mode_re;
  logic [2:0] ctrl_key_len_qs;
  logic [2:0] ctrl_key_len_wd;
  logic ctrl_key_len_we;
  logic ctrl_key_len_re;
  logic ctrl_manual_start_trigger_qs;
  logic ctrl_manual_start_trigger_wd;
  logic ctrl_manual_start_trigger_we;
  logic ctrl_manual_start_trigger_re;
  logic ctrl_force_data_overwrite_qs;
  logic ctrl_force_data_overwrite_wd;
  logic ctrl_force_data_overwrite_we;
  logic ctrl_force_data_overwrite_re;
  logic trigger_start_wd;
  logic trigger_start_we;
  logic trigger_key_clear_wd;
  logic trigger_key_clear_we;
  logic trigger_data_in_clear_wd;
  logic trigger_data_in_clear_we;
  logic trigger_data_out_clear_wd;
  logic trigger_data_out_clear_we;
  logic status_idle_qs;
  logic status_stall_qs;
  logic status_output_valid_qs;
  logic status_input_ready_qs;

  // Register instances

  // Subregister 0 of Multireg key
  // R[key0]: V(True)
   assign key_0_d = hw2reg.key[0].d;
   assign reg2hw.key[0].q = key_0_q;
   assign reg2hw.key[0].qe = key_0_qe;

   assign key_1_d = hw2reg.key[1].d;
   assign reg2hw.key[1].q = key_1_q;
   assign reg2hw.key[1].qe = key_1_qe;

   assign key_2_d = hw2reg.key[2].d;
   assign reg2hw.key[2].q = key_2_q;
   assign reg2hw.key[2].qe = key_2_qe;

   assign key_3_d = hw2reg.key[3].d;
   assign reg2hw.key[3].q = key_3_q;
   assign reg2hw.key[3].qe = key_3_qe;

   assign key_4_d = hw2reg.key[4].d;
   assign reg2hw.key[4].q = key_4_q;
   assign reg2hw.key[4].qe = key_4_qe;

   assign key_5_d = hw2reg.key[5].d;
   assign reg2hw.key[5].q = key_5_q;
   assign reg2hw.key[5].qe = key_5_qe;

   assign key_6_d = hw2reg.key[6].d;
   assign reg2hw.key[6].q = key_6_q;
   assign reg2hw.key[6].qe = key_6_qe;

   assign key_7_d = hw2reg.key[7].d;
   assign reg2hw.key[7].q = key_7_q;
   assign reg2hw.key[7].qe = key_7_qe;


  // Subregister 0 of Multireg data_in
  // R[data_in0]: V(False)
   assign data_in_0_from_core = hw2reg.data_in[0].de;
   assign data_in_0_de_from_core = hw2reg.data_in[0].d;
   assign reg2hw.data_in[0].qe = data_in_0_qe_to_core;
   assign reg2hw.data_in[0].q = data_in_0_to_core;

   assign data_in_1_from_core = hw2reg.data_in[1].de;
   assign data_in_1_de_from_core = hw2reg.data_in[1].d;
   assign reg2hw.data_in[1].qe = data_in_1_qe_to_core;
   assign reg2hw.data_in[1].q = data_in_1_to_core;

   assign data_in_2_from_core = hw2reg.data_in[2].de;
   assign data_in_2_de_from_core = hw2reg.data_in[2].d;
   assign reg2hw.data_in[2].qe = data_in_2_qe_to_core;
   assign reg2hw.data_in[2].q = data_in_2_to_core;

   assign data_in_3_from_core = hw2reg.data_in[3].de;
   assign data_in_3_de_from_core = hw2reg.data_in[3].d;
   assign reg2hw.data_in[3].qe = data_in_3_qe_to_core;
   assign reg2hw.data_in[3].q = data_in_3_to_core;

  // Subregister 0 of Multireg data_out
  // R[data_out0]: V(True)
   assign data_out_0 = hw2reg.data_out[0].d;
   assign reg2hw.data_out[0].re = data_out_0_re;
   assign data_out_1 = hw2reg.data_out[1].d;
   assign reg2hw.data_out[1].re = data_out_1_re;
   assign data_out_2 = hw2reg.data_out[2].d;
   assign reg2hw.data_out[2].re = data_out_2_re;
   assign data_out_3 = hw2reg.data_out[3].d;
   assign reg2hw.data_out[3].re = data_out_3_re;
   

`ifdef CTRL_DEF
  // R[ctrl]: V(True)

  //   F[mode]: 0:0
  prim_subreg_ext #(
    .DW    (1)
  ) u_ctrl_mode (
    .re     (ctrl_mode_re),
    .we     (ctrl_mode_we),
    .wd     (ctrl_mode_wd),
    .d      ('0),
    .qre    (),
    .qe     (reg2hw.ctrl.mode.qe),
    .q      (reg2hw.ctrl.mode.q ),
    .qs     (ctrl_mode_qs)
  );


  //   F[key_len]: 3:1
  prim_subreg_ext #(
    .DW    (3)
  ) u_ctrl_key_len (
    .re     (ctrl_key_len_re),
    .we     (ctrl_key_len_we),
    .wd     (ctrl_key_len_wd),
    .d      (hw2reg.ctrl.key_len.d),
    .qre    (),
    .qe     (reg2hw.ctrl.key_len.qe),
    .q      (reg2hw.ctrl.key_len.q ),
    .qs     (ctrl_key_len_qs)
  );


  //   F[manual_start_trigger]: 4:4
  prim_subreg_ext #(
    .DW    (1)
  ) u_ctrl_manual_start_trigger (
    .re     (ctrl_manual_start_trigger_re),
    .we     (ctrl_manual_start_trigger_we),
    .wd     (ctrl_manual_start_trigger_wd),
    .d      ('0),
    .qre    (),
    .qe     (reg2hw.ctrl.manual_start_trigger.qe),
    .q      (reg2hw.ctrl.manual_start_trigger.q ),
    .qs     (ctrl_manual_start_trigger_qs)
  );


  //   F[force_data_overwrite]: 5:5
  prim_subreg_ext #(
    .DW    (1)
  ) u_ctrl_force_data_overwrite (
    .re     (ctrl_force_data_overwrite_re),
    .we     (ctrl_force_data_overwrite_we),
    .wd     (ctrl_force_data_overwrite_wd),
    .d      ('0),
    .qre    (),
    .qe     (reg2hw.ctrl.force_data_overwrite.qe),
    .q      (reg2hw.ctrl.force_data_overwrite.q ),
    .qs     (ctrl_force_data_overwrite_qs)
  );
`endif

  assign reg2hw.ctrl.mode.q = ctrl_mode;
  assign reg2hw.ctrl.mode.qe = ctrl_update;
  assign reg2hw.ctrl.key_len.q = ctrl_key_len;
  assign reg2hw.ctrl.key_len.qe = ctrl_update;
  assign ctrl_key_len_rbk = hw2reg.ctrl.key_len.d;
  assign reg2hw.ctrl.manual_start_trigger.q = ctrl_manual_start_trigger;
  assign reg2hw.ctrl.manual_start_trigger.qe = ctrl_update;
  assign reg2hw.ctrl.force_data_overwrite.q = ctrl_force_data_overwrite;
  assign reg2hw.ctrl.force_data_overwrite.qe = ctrl_update;


`ifdef TRIGGER_DEF
  // R[trigger]: V(False)

  //   F[start]: 0:0
  prim_subreg #(
    .DW      (1),
    .SWACCESS("WO"),
    .RESVAL  (1'h0)
  ) u_trigger_start (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (trigger_start_we),
    .wd     (trigger_start_wd),

    // from internal hardware
    .de     (hw2reg.trigger.start.de),
    .d      (hw2reg.trigger.start.d ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.trigger.start.q ),

    .qs     ()
  );


  //   F[key_clear]: 1:1
  prim_subreg #(
    .DW      (1),
    .SWACCESS("WO"),
    .RESVAL  (1'h0)
  ) u_trigger_key_clear (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (trigger_key_clear_we),
    .wd     (trigger_key_clear_wd),

    // from internal hardware
    .de     (hw2reg.trigger.key_clear.de),
    .d      (hw2reg.trigger.key_clear.d ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.trigger.key_clear.q ),

    .qs     ()
  );


  //   F[data_in_clear]: 2:2
  prim_subreg #(
    .DW      (1),
    .SWACCESS("WO"),
    .RESVAL  (1'h0)
  ) u_trigger_data_in_clear (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (trigger_data_in_clear_we),
    .wd     (trigger_data_in_clear_wd),

    // from internal hardware
    .de     (hw2reg.trigger.data_in_clear.de),
    .d      (hw2reg.trigger.data_in_clear.d ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.trigger.data_in_clear.q ),

    .qs     ()
  );


  //   F[data_out_clear]: 3:3
  prim_subreg #(
    .DW      (1),
    .SWACCESS("WO"),
    .RESVAL  (1'h0)
  ) u_trigger_data_out_clear (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    // from register interface
    .we     (trigger_data_out_clear_we),
    .wd     (trigger_data_out_clear_wd),

    // from internal hardware
    .de     (hw2reg.trigger.data_out_clear.de),
    .d      (hw2reg.trigger.data_out_clear.d ),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.trigger.data_out_clear.q ),

    .qs     ()
  );
`endif

  assign reg2hw.trigger.start.q=start;
  assign reg2hw.trigger.key_clear.q=key_clear;
  assign reg2hw.trigger.data_in_clear.q=data_in_clear;
  assign reg2hw.trigger.data_out_clear.q=data_out_clear;

`ifdef STATUS_DEF
  // R[status]: V(False)

  //   F[idle]: 0:0
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RO"),
    .RESVAL  (1'h0)
  ) u_status_idle (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    .we     (1'b0),
    .wd     ('0  ),

    // from internal hardware
    .de     (hw2reg.status.idle.de),
    .d      (hw2reg.status.idle.d ),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (status_idle_qs)
  );


  //   F[stall]: 1:1
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RO"),
    .RESVAL  (1'h0)
  ) u_status_stall (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    .we     (1'b0),
    .wd     ('0  ),

    // from internal hardware
    .de     (hw2reg.status.stall.de),
    .d      (hw2reg.status.stall.d ),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (status_stall_qs)
  );


  //   F[output_valid]: 2:2
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RO"),
    .RESVAL  (1'h0)
  ) u_status_output_valid (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    .we     (1'b0),
    .wd     ('0  ),

    // from internal hardware
    .de     (hw2reg.status.output_valid.de),
    .d      (hw2reg.status.output_valid.d ),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (status_output_valid_qs)
  );


  //   F[input_ready]: 3:3
  prim_subreg #(
    .DW      (1),
    .SWACCESS("RO"),
    .RESVAL  (1'h1)
  ) u_status_input_ready (
    .clk_i   (clk_i    ),
    .rst_ni  (rst_ni  ),

    .we     (1'b0),
    .wd     ('0  ),

    // from internal hardware
    .de     (hw2reg.status.input_ready.de),
    .d      (hw2reg.status.input_ready.d ),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (status_input_ready_qs)
  );
`endif
  assign idle = hw2reg.status.idle.d;
  assign stall = hw2reg.status.stall.d;
  assign output_valid = hw2reg.status.output_valid.d;
  assign input_ready = hw2reg.status.input_ready.d;


  logic [18:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[ 0] = (reg_addr == AES_KEY0_OFFSET);
    addr_hit[ 1] = (reg_addr == AES_KEY1_OFFSET);
    addr_hit[ 2] = (reg_addr == AES_KEY2_OFFSET);
    addr_hit[ 3] = (reg_addr == AES_KEY3_OFFSET);
    addr_hit[ 4] = (reg_addr == AES_KEY4_OFFSET);
    addr_hit[ 5] = (reg_addr == AES_KEY5_OFFSET);
    addr_hit[ 6] = (reg_addr == AES_KEY6_OFFSET);
    addr_hit[ 7] = (reg_addr == AES_KEY7_OFFSET);
    addr_hit[ 8] = (reg_addr == AES_DATA_IN0_OFFSET);
    addr_hit[ 9] = (reg_addr == AES_DATA_IN1_OFFSET);
    addr_hit[10] = (reg_addr == AES_DATA_IN2_OFFSET);
    addr_hit[11] = (reg_addr == AES_DATA_IN3_OFFSET);
    addr_hit[12] = (reg_addr == AES_DATA_OUT0_OFFSET);
    addr_hit[13] = (reg_addr == AES_DATA_OUT1_OFFSET);
    addr_hit[14] = (reg_addr == AES_DATA_OUT2_OFFSET);
    addr_hit[15] = (reg_addr == AES_DATA_OUT3_OFFSET);
    addr_hit[16] = (reg_addr == AES_CTRL_OFFSET);
    addr_hit[17] = (reg_addr == AES_TRIGGER_OFFSET);
    addr_hit[18] = (reg_addr == AES_STATUS_OFFSET);
  end

  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0 ;

  // Check sub-word write is permitted
  always_comb begin
    wr_err = 1'b0;
    if (addr_hit[ 0] && reg_we && (AES_PERMIT[ 0] != (AES_PERMIT[ 0] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[ 1] && reg_we && (AES_PERMIT[ 1] != (AES_PERMIT[ 1] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[ 2] && reg_we && (AES_PERMIT[ 2] != (AES_PERMIT[ 2] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[ 3] && reg_we && (AES_PERMIT[ 3] != (AES_PERMIT[ 3] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[ 4] && reg_we && (AES_PERMIT[ 4] != (AES_PERMIT[ 4] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[ 5] && reg_we && (AES_PERMIT[ 5] != (AES_PERMIT[ 5] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[ 6] && reg_we && (AES_PERMIT[ 6] != (AES_PERMIT[ 6] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[ 7] && reg_we && (AES_PERMIT[ 7] != (AES_PERMIT[ 7] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[ 8] && reg_we && (AES_PERMIT[ 8] != (AES_PERMIT[ 8] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[ 9] && reg_we && (AES_PERMIT[ 9] != (AES_PERMIT[ 9] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[10] && reg_we && (AES_PERMIT[10] != (AES_PERMIT[10] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[11] && reg_we && (AES_PERMIT[11] != (AES_PERMIT[11] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[12] && reg_we && (AES_PERMIT[12] != (AES_PERMIT[12] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[13] && reg_we && (AES_PERMIT[13] != (AES_PERMIT[13] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[14] && reg_we && (AES_PERMIT[14] != (AES_PERMIT[14] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[15] && reg_we && (AES_PERMIT[15] != (AES_PERMIT[15] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[16] && reg_we && (AES_PERMIT[16] != (AES_PERMIT[16] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[17] && reg_we && (AES_PERMIT[17] != (AES_PERMIT[17] & reg_be))) wr_err = 1'b1 ;
    if (addr_hit[18] && reg_we && (AES_PERMIT[18] != (AES_PERMIT[18] & reg_be))) wr_err = 1'b1 ;
  end

  assign key0_we = addr_hit[0] & reg_we & ~wr_err;
  assign key0_wd = reg_wdata[31:0];

  assign key1_we = addr_hit[1] & reg_we & ~wr_err;
  assign key1_wd = reg_wdata[31:0];

  assign key2_we = addr_hit[2] & reg_we & ~wr_err;
  assign key2_wd = reg_wdata[31:0];

  assign key3_we = addr_hit[3] & reg_we & ~wr_err;
  assign key3_wd = reg_wdata[31:0];

  assign key4_we = addr_hit[4] & reg_we & ~wr_err;
  assign key4_wd = reg_wdata[31:0];

  assign key5_we = addr_hit[5] & reg_we & ~wr_err;
  assign key5_wd = reg_wdata[31:0];

  assign key6_we = addr_hit[6] & reg_we & ~wr_err;
  assign key6_wd = reg_wdata[31:0];

  assign key7_we = addr_hit[7] & reg_we & ~wr_err;
  assign key7_wd = reg_wdata[31:0];

  assign data_in0_we = addr_hit[8] & reg_we & ~wr_err;
  assign data_in0_wd = reg_wdata[31:0];

  assign data_in1_we = addr_hit[9] & reg_we & ~wr_err;
  assign data_in1_wd = reg_wdata[31:0];

  assign data_in2_we = addr_hit[10] & reg_we & ~wr_err;
  assign data_in2_wd = reg_wdata[31:0];

  assign data_in3_we = addr_hit[11] & reg_we & ~wr_err;
  assign data_in3_wd = reg_wdata[31:0];

  assign data_out0_re = addr_hit[12] && reg_re;

  assign data_out1_re = addr_hit[13] && reg_re;

  assign data_out2_re = addr_hit[14] && reg_re;

  assign data_out3_re = addr_hit[15] && reg_re;

  assign ctrl_mode_we = addr_hit[16] & reg_we & ~wr_err;
  assign ctrl_mode_wd = reg_wdata[0];
  assign ctrl_mode_re = addr_hit[16] && reg_re;

  assign ctrl_key_len_we = addr_hit[16] & reg_we & ~wr_err;
  assign ctrl_key_len_wd = reg_wdata[3:1];
  assign ctrl_key_len_re = addr_hit[16] && reg_re;

  assign ctrl_manual_start_trigger_we = addr_hit[16] & reg_we & ~wr_err;
  assign ctrl_manual_start_trigger_wd = reg_wdata[4];
  assign ctrl_manual_start_trigger_re = addr_hit[16] && reg_re;

  assign ctrl_force_data_overwrite_we = addr_hit[16] & reg_we & ~wr_err;
  assign ctrl_force_data_overwrite_wd = reg_wdata[5];
  assign ctrl_force_data_overwrite_re = addr_hit[16] && reg_re;

  assign trigger_start_we = addr_hit[17] & reg_we & ~wr_err;
  assign trigger_start_wd = reg_wdata[0];

  assign trigger_key_clear_we = addr_hit[17] & reg_we & ~wr_err;
  assign trigger_key_clear_wd = reg_wdata[1];

  assign trigger_data_in_clear_we = addr_hit[17] & reg_we & ~wr_err;
  assign trigger_data_in_clear_wd = reg_wdata[2];

  assign trigger_data_out_clear_we = addr_hit[17] & reg_we & ~wr_err;
  assign trigger_data_out_clear_wd = reg_wdata[3];





  // Read data return
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      addr_hit[0]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[1]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[2]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[3]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[4]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[5]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[6]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[7]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[8]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[9]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[10]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[11]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[12]: begin
        reg_rdata_next[31:0] = hw2reg.data_out[0].d;
      end

      addr_hit[13]: begin
        reg_rdata_next[31:0] = hw2reg.data_out[1].d;
      end

      addr_hit[14]: begin
        reg_rdata_next[31:0] = hw2reg.data_out[2].d;
      end

      addr_hit[15]: begin
        reg_rdata_next[31:0] = hw2reg.data_out[3].d;
      end

      addr_hit[16]: begin
        reg_rdata_next[0] = ctrl_mode_qs;
        reg_rdata_next[3:1] = ctrl_key_len_qs;
        reg_rdata_next[4] = ctrl_manual_start_trigger_qs;
        reg_rdata_next[5] = ctrl_force_data_overwrite_qs;
      end

      addr_hit[17]: begin
        reg_rdata_next[0] = '0;
        reg_rdata_next[1] = '0;
        reg_rdata_next[2] = '0;
        reg_rdata_next[3] = '0;
      end

      addr_hit[18]: begin
        reg_rdata_next[0] = status_idle_qs;
        reg_rdata_next[1] = status_stall_qs;
        reg_rdata_next[2] = status_output_valid_qs;
        reg_rdata_next[3] = status_input_ready_qs;
      end

      default: begin
        reg_rdata_next = '1;
      end
    endcase
  end

  //parameter bit AES192Enable = 1,    // Can be 0 (disable), or 1 (enable).
  //parameter     SBoxImpl     = "lut" // Can be "lut" (LUT-based SBox), or "canright".
  aes_core #(
    .AES192Enable ( 0 ),
    .SBoxImpl     ( "lut"  )
  ) aes_core (
    .clk_i,
    .rst_ni,
    .reg2hw,
    .hw2reg
  );
   
endmodule
