// Generator : SpinalHDL v1.6.5    git head : cad13e84cddd8b45bbb9ca121013c823aca98ea3
// Component : UsbDeviceWithPhyWishbone
// Git hash  : 3913588b2aa98fa70f5f30d3e2b9c02b6bd6847c

`timescale 1ns/1ps 

module UsbDeviceWithPhyWishbone (
  input               io_wishbone_CYC,
  input               io_wishbone_STB,
  output              io_wishbone_ACK,
  input               io_wishbone_WE,
  input      [13:0]   io_wishbone_ADR,
  output     [31:0]   io_wishbone_DAT_MISO,
  input      [31:0]   io_wishbone_DAT_MOSI,
  input      [3:0]    io_wishbone_SEL,
  input               io_usb_dp_read,
  output              io_usb_dp_write,
  output              io_usb_dp_writeEnable,
  input               io_usb_dm_read,
  output              io_usb_dm_write,
  output              io_usb_dm_writeEnable,
  input               io_power,
  output              io_interrupt,
  input               phy_clk,
  input               phy_reset,
  input               ctrl_clk,
  input               ctrl_reset
);

  wire       [31:0]   ctrl_bridge_io_input_DAT_MISO;
  wire                ctrl_bridge_io_input_ACK;
  wire                ctrl_bridge_io_output_cmd_valid;
  wire                ctrl_bridge_io_output_cmd_payload_last;
  wire       [0:0]    ctrl_bridge_io_output_cmd_payload_fragment_opcode;
  wire       [15:0]   ctrl_bridge_io_output_cmd_payload_fragment_address;
  wire       [1:0]    ctrl_bridge_io_output_cmd_payload_fragment_length;
  wire       [31:0]   ctrl_bridge_io_output_cmd_payload_fragment_data;
  wire       [3:0]    ctrl_bridge_io_output_cmd_payload_fragment_mask;
  wire                ctrl_bridge_io_output_rsp_ready;
  wire                ctrl_logic_io_ctrl_cmd_ready;
  wire                ctrl_logic_io_ctrl_rsp_valid;
  wire                ctrl_logic_io_ctrl_rsp_payload_last;
  wire       [0:0]    ctrl_logic_io_ctrl_rsp_payload_fragment_opcode;
  wire       [31:0]   ctrl_logic_io_ctrl_rsp_payload_fragment_data;
  wire                ctrl_logic_io_phy_resumeIt;
  wire                ctrl_logic_io_phy_pullup;
  wire                ctrl_logic_io_phy_tx_stream_valid;
  wire                ctrl_logic_io_phy_tx_stream_payload_last;
  wire       [7:0]    ctrl_logic_io_phy_tx_stream_payload_fragment;
  wire                ctrl_logic_io_interrupt;
  wire                phy_logic_io_ctrl_tick;
  wire                phy_logic_io_ctrl_reset;
  wire                phy_logic_io_ctrl_suspend;
  wire                phy_logic_io_ctrl_resume_valid;
  wire                phy_logic_io_ctrl_power;
  wire                phy_logic_io_ctrl_disconnect;
  wire                phy_logic_io_ctrl_tx_stream_ready;
  wire                phy_logic_io_ctrl_tx_eop;
  wire                phy_logic_io_ctrl_rx_flow_valid;
  wire       [7:0]    phy_logic_io_ctrl_rx_flow_payload;
  wire                phy_logic_io_ctrl_rx_active;
  wire                phy_logic_io_ctrl_rx_stuffingError;
  wire                phy_logic_io_usb_tx_enable;
  wire                phy_logic_io_usb_tx_data;
  wire                phy_logic_io_usb_tx_se0;
  wire                phy_logic_io_pullup;
  wire                ctrl_logic_io_phy_cc_input_tick;
  wire                ctrl_logic_io_phy_cc_input_reset;
  wire                ctrl_logic_io_phy_cc_input_suspend;
  wire                ctrl_logic_io_phy_cc_input_resume_valid;
  wire                ctrl_logic_io_phy_cc_input_power;
  wire                ctrl_logic_io_phy_cc_input_disconnect;
  wire                ctrl_logic_io_phy_cc_input_tx_stream_ready;
  wire                ctrl_logic_io_phy_cc_input_tx_eop;
  wire                ctrl_logic_io_phy_cc_input_rx_flow_valid;
  wire       [7:0]    ctrl_logic_io_phy_cc_input_rx_flow_payload;
  wire                ctrl_logic_io_phy_cc_input_rx_active;
  wire                ctrl_logic_io_phy_cc_input_rx_stuffingError;
  wire                ctrl_logic_io_phy_cc_output_resumeIt;
  wire                ctrl_logic_io_phy_cc_output_pullup;
  wire                ctrl_logic_io_phy_cc_output_tx_stream_valid;
  wire                ctrl_logic_io_phy_cc_output_tx_stream_payload_last;
  wire       [7:0]    ctrl_logic_io_phy_cc_output_tx_stream_payload_fragment;
  wire                phy_native_dp_read;
  reg                 phy_native_dp_write;
  reg                 phy_native_dp_writeEnable;
  wire                phy_native_dm_read;
  reg                 phy_native_dm_write;
  reg                 phy_native_dm_writeEnable;
  wire                when_UsbDeviceWithPhyWishbone_l44;
  wire                phy_buffer_dp_read;
  wire                phy_buffer_dp_write;
  wire                phy_buffer_dp_writeEnable;
  wire                phy_buffer_dm_read;
  wire                phy_buffer_dm_write;
  wire                phy_buffer_dm_writeEnable;
  wire                phy_native_dp_stage_read;
  wire                phy_native_dp_stage_write;
  wire                phy_native_dp_stage_writeEnable;
  reg                 phy_native_dp_writeEnable_regNext;
  reg                 phy_native_dp_write_regNext;
  reg                 phy_native_dp_stage_read_regNext;
  wire                phy_native_dm_stage_read;
  wire                phy_native_dm_stage_write;
  wire                phy_native_dm_stage_writeEnable;
  reg                 phy_native_dm_writeEnable_regNext;
  reg                 phy_native_dm_write_regNext;
  reg                 phy_native_dm_stage_read_regNext;
  wire                phy_buffer_stage_dp_read;
  wire                phy_buffer_stage_dp_write;
  wire                phy_buffer_stage_dp_writeEnable;
  wire                phy_buffer_stage_dm_read;
  wire                phy_buffer_stage_dm_write;
  wire                phy_buffer_stage_dm_writeEnable;
  wire                phy_buffer_dp_stage_read;
  wire                phy_buffer_dp_stage_write;
  wire                phy_buffer_dp_stage_writeEnable;
  reg                 phy_buffer_dp_writeEnable_regNext;
  reg                 phy_buffer_dp_write_regNext;
  reg                 phy_buffer_dp_stage_read_regNext;
  wire                phy_buffer_dm_stage_read;
  wire                phy_buffer_dm_stage_write;
  wire                phy_buffer_dm_stage_writeEnable;
  reg                 phy_buffer_dm_writeEnable_regNext;
  reg                 phy_buffer_dm_write_regNext;
  reg                 phy_buffer_dm_stage_read_regNext;

  WishboneToBmb ctrl_bridge (
    .io_input_CYC                              (io_wishbone_CYC                                           ), //i
    .io_input_STB                              (io_wishbone_STB                                           ), //i
    .io_input_ACK                              (ctrl_bridge_io_input_ACK                                  ), //o
    .io_input_WE                               (io_wishbone_WE                                            ), //i
    .io_input_ADR                              (io_wishbone_ADR[13:0]                                     ), //i
    .io_input_DAT_MISO                         (ctrl_bridge_io_input_DAT_MISO[31:0]                       ), //o
    .io_input_DAT_MOSI                         (io_wishbone_DAT_MOSI[31:0]                                ), //i
    .io_input_SEL                              (io_wishbone_SEL[3:0]                                      ), //i
    .io_output_cmd_valid                       (ctrl_bridge_io_output_cmd_valid                           ), //o
    .io_output_cmd_ready                       (ctrl_logic_io_ctrl_cmd_ready                              ), //i
    .io_output_cmd_payload_last                (ctrl_bridge_io_output_cmd_payload_last                    ), //o
    .io_output_cmd_payload_fragment_opcode     (ctrl_bridge_io_output_cmd_payload_fragment_opcode         ), //o
    .io_output_cmd_payload_fragment_address    (ctrl_bridge_io_output_cmd_payload_fragment_address[15:0]  ), //o
    .io_output_cmd_payload_fragment_length     (ctrl_bridge_io_output_cmd_payload_fragment_length[1:0]    ), //o
    .io_output_cmd_payload_fragment_data       (ctrl_bridge_io_output_cmd_payload_fragment_data[31:0]     ), //o
    .io_output_cmd_payload_fragment_mask       (ctrl_bridge_io_output_cmd_payload_fragment_mask[3:0]      ), //o
    .io_output_rsp_valid                       (ctrl_logic_io_ctrl_rsp_valid                              ), //i
    .io_output_rsp_ready                       (ctrl_bridge_io_output_rsp_ready                           ), //o
    .io_output_rsp_payload_last                (ctrl_logic_io_ctrl_rsp_payload_last                       ), //i
    .io_output_rsp_payload_fragment_opcode     (ctrl_logic_io_ctrl_rsp_payload_fragment_opcode            ), //i
    .io_output_rsp_payload_fragment_data       (ctrl_logic_io_ctrl_rsp_payload_fragment_data[31:0]        ), //i
    .ctrl_clk                                  (ctrl_clk                                                  ), //i
    .ctrl_reset                                (ctrl_reset                                                )  //i
  );
  UsbDeviceCtrl ctrl_logic (
    .io_ctrl_cmd_valid                       (ctrl_bridge_io_output_cmd_valid                           ), //i
    .io_ctrl_cmd_ready                       (ctrl_logic_io_ctrl_cmd_ready                              ), //o
    .io_ctrl_cmd_payload_last                (ctrl_bridge_io_output_cmd_payload_last                    ), //i
    .io_ctrl_cmd_payload_fragment_opcode     (ctrl_bridge_io_output_cmd_payload_fragment_opcode         ), //i
    .io_ctrl_cmd_payload_fragment_address    (ctrl_bridge_io_output_cmd_payload_fragment_address[15:0]  ), //i
    .io_ctrl_cmd_payload_fragment_length     (ctrl_bridge_io_output_cmd_payload_fragment_length[1:0]    ), //i
    .io_ctrl_cmd_payload_fragment_data       (ctrl_bridge_io_output_cmd_payload_fragment_data[31:0]     ), //i
    .io_ctrl_cmd_payload_fragment_mask       (ctrl_bridge_io_output_cmd_payload_fragment_mask[3:0]      ), //i
    .io_ctrl_rsp_valid                       (ctrl_logic_io_ctrl_rsp_valid                              ), //o
    .io_ctrl_rsp_ready                       (ctrl_bridge_io_output_rsp_ready                           ), //i
    .io_ctrl_rsp_payload_last                (ctrl_logic_io_ctrl_rsp_payload_last                       ), //o
    .io_ctrl_rsp_payload_fragment_opcode     (ctrl_logic_io_ctrl_rsp_payload_fragment_opcode            ), //o
    .io_ctrl_rsp_payload_fragment_data       (ctrl_logic_io_ctrl_rsp_payload_fragment_data[31:0]        ), //o
    .io_phy_tx_stream_valid                  (ctrl_logic_io_phy_tx_stream_valid                         ), //o
    .io_phy_tx_stream_ready                  (ctrl_logic_io_phy_cc_input_tx_stream_ready                ), //i
    .io_phy_tx_stream_payload_last           (ctrl_logic_io_phy_tx_stream_payload_last                  ), //o
    .io_phy_tx_stream_payload_fragment       (ctrl_logic_io_phy_tx_stream_payload_fragment[7:0]         ), //o
    .io_phy_tx_eop                           (ctrl_logic_io_phy_cc_input_tx_eop                         ), //i
    .io_phy_rx_flow_valid                    (ctrl_logic_io_phy_cc_input_rx_flow_valid                  ), //i
    .io_phy_rx_flow_payload                  (ctrl_logic_io_phy_cc_input_rx_flow_payload[7:0]           ), //i
    .io_phy_rx_active                        (ctrl_logic_io_phy_cc_input_rx_active                      ), //i
    .io_phy_rx_stuffingError                 (ctrl_logic_io_phy_cc_input_rx_stuffingError               ), //i
    .io_phy_pullup                           (ctrl_logic_io_phy_pullup                                  ), //o
    .io_phy_reset                            (ctrl_logic_io_phy_cc_input_reset                          ), //i
    .io_phy_suspend                          (ctrl_logic_io_phy_cc_input_suspend                        ), //i
    .io_phy_disconnect                       (ctrl_logic_io_phy_cc_input_disconnect                     ), //i
    .io_phy_resume_valid                     (ctrl_logic_io_phy_cc_input_resume_valid                   ), //i
    .io_phy_tick                             (ctrl_logic_io_phy_cc_input_tick                           ), //i
    .io_phy_power                            (ctrl_logic_io_phy_cc_input_power                          ), //i
    .io_phy_resumeIt                         (ctrl_logic_io_phy_resumeIt                                ), //o
    .io_interrupt                            (ctrl_logic_io_interrupt                                   ), //o
    .ctrl_clk                                (ctrl_clk                                                  ), //i
    .ctrl_reset                              (ctrl_reset                                                )  //i
  );
  UsbDevicePhyNative phy_logic (
    .io_ctrl_tx_stream_valid               (ctrl_logic_io_phy_cc_output_tx_stream_valid                  ), //i
    .io_ctrl_tx_stream_ready               (phy_logic_io_ctrl_tx_stream_ready                            ), //o
    .io_ctrl_tx_stream_payload_last        (ctrl_logic_io_phy_cc_output_tx_stream_payload_last           ), //i
    .io_ctrl_tx_stream_payload_fragment    (ctrl_logic_io_phy_cc_output_tx_stream_payload_fragment[7:0]  ), //i
    .io_ctrl_tx_eop                        (phy_logic_io_ctrl_tx_eop                                     ), //o
    .io_ctrl_rx_flow_valid                 (phy_logic_io_ctrl_rx_flow_valid                              ), //o
    .io_ctrl_rx_flow_payload               (phy_logic_io_ctrl_rx_flow_payload[7:0]                       ), //o
    .io_ctrl_rx_active                     (phy_logic_io_ctrl_rx_active                                  ), //o
    .io_ctrl_rx_stuffingError              (phy_logic_io_ctrl_rx_stuffingError                           ), //o
    .io_ctrl_pullup                        (ctrl_logic_io_phy_cc_output_pullup                           ), //i
    .io_ctrl_reset                         (phy_logic_io_ctrl_reset                                      ), //o
    .io_ctrl_suspend                       (phy_logic_io_ctrl_suspend                                    ), //o
    .io_ctrl_disconnect                    (phy_logic_io_ctrl_disconnect                                 ), //o
    .io_ctrl_resume_valid                  (phy_logic_io_ctrl_resume_valid                               ), //o
    .io_ctrl_tick                          (phy_logic_io_ctrl_tick                                       ), //o
    .io_ctrl_power                         (phy_logic_io_ctrl_power                                      ), //o
    .io_ctrl_resumeIt                      (ctrl_logic_io_phy_cc_output_resumeIt                         ), //i
    .io_usb_tx_enable                      (phy_logic_io_usb_tx_enable                                   ), //o
    .io_usb_tx_data                        (phy_logic_io_usb_tx_data                                     ), //o
    .io_usb_tx_se0                         (phy_logic_io_usb_tx_se0                                      ), //o
    .io_usb_rx_dp                          (phy_native_dp_read                                           ), //i
    .io_usb_rx_dm                          (phy_native_dm_read                                           ), //i
    .io_power                              (io_power                                                     ), //i
    .io_pullup                             (phy_logic_io_pullup                                          ), //o
    .phy_clk                               (phy_clk                                                      ), //i
    .phy_reset                             (phy_reset                                                    )  //i
  );
  PhyCc ctrl_logic_io_phy_cc (
    .input_tx_stream_valid                (ctrl_logic_io_phy_tx_stream_valid                            ), //i
    .input_tx_stream_ready                (ctrl_logic_io_phy_cc_input_tx_stream_ready                   ), //o
    .input_tx_stream_payload_last         (ctrl_logic_io_phy_tx_stream_payload_last                     ), //i
    .input_tx_stream_payload_fragment     (ctrl_logic_io_phy_tx_stream_payload_fragment[7:0]            ), //i
    .input_tx_eop                         (ctrl_logic_io_phy_cc_input_tx_eop                            ), //o
    .input_rx_flow_valid                  (ctrl_logic_io_phy_cc_input_rx_flow_valid                     ), //o
    .input_rx_flow_payload                (ctrl_logic_io_phy_cc_input_rx_flow_payload[7:0]              ), //o
    .input_rx_active                      (ctrl_logic_io_phy_cc_input_rx_active                         ), //o
    .input_rx_stuffingError               (ctrl_logic_io_phy_cc_input_rx_stuffingError                  ), //o
    .input_pullup                         (ctrl_logic_io_phy_pullup                                     ), //i
    .input_reset                          (ctrl_logic_io_phy_cc_input_reset                             ), //o
    .input_suspend                        (ctrl_logic_io_phy_cc_input_suspend                           ), //o
    .input_disconnect                     (ctrl_logic_io_phy_cc_input_disconnect                        ), //o
    .input_resume_valid                   (ctrl_logic_io_phy_cc_input_resume_valid                      ), //o
    .input_tick                           (ctrl_logic_io_phy_cc_input_tick                              ), //o
    .input_power                          (ctrl_logic_io_phy_cc_input_power                             ), //o
    .input_resumeIt                       (ctrl_logic_io_phy_resumeIt                                   ), //i
    .output_tx_stream_valid               (ctrl_logic_io_phy_cc_output_tx_stream_valid                  ), //o
    .output_tx_stream_ready               (phy_logic_io_ctrl_tx_stream_ready                            ), //i
    .output_tx_stream_payload_last        (ctrl_logic_io_phy_cc_output_tx_stream_payload_last           ), //o
    .output_tx_stream_payload_fragment    (ctrl_logic_io_phy_cc_output_tx_stream_payload_fragment[7:0]  ), //o
    .output_tx_eop                        (phy_logic_io_ctrl_tx_eop                                     ), //i
    .output_rx_flow_valid                 (phy_logic_io_ctrl_rx_flow_valid                              ), //i
    .output_rx_flow_payload               (phy_logic_io_ctrl_rx_flow_payload[7:0]                       ), //i
    .output_rx_active                     (phy_logic_io_ctrl_rx_active                                  ), //i
    .output_rx_stuffingError              (phy_logic_io_ctrl_rx_stuffingError                           ), //i
    .output_pullup                        (ctrl_logic_io_phy_cc_output_pullup                           ), //o
    .output_reset                         (phy_logic_io_ctrl_reset                                      ), //i
    .output_suspend                       (phy_logic_io_ctrl_suspend                                    ), //i
    .output_disconnect                    (phy_logic_io_ctrl_disconnect                                 ), //i
    .output_resume_valid                  (phy_logic_io_ctrl_resume_valid                               ), //i
    .output_tick                          (phy_logic_io_ctrl_tick                                       ), //i
    .output_power                         (phy_logic_io_ctrl_power                                      ), //i
    .output_resumeIt                      (ctrl_logic_io_phy_cc_output_resumeIt                         ), //o
    .phy_clk                              (phy_clk                                                      ), //i
    .phy_reset                            (phy_reset                                                    ), //i
    .ctrl_clk                             (ctrl_clk                                                     ), //i
    .ctrl_reset                           (ctrl_reset                                                   )  //i
  );
  assign io_wishbone_ACK = ctrl_bridge_io_input_ACK;
  assign io_wishbone_DAT_MISO = ctrl_bridge_io_input_DAT_MISO;
  assign io_interrupt = ctrl_logic_io_interrupt;
  always @(*) begin
    phy_native_dp_writeEnable = phy_logic_io_usb_tx_enable;
    if(when_UsbDeviceWithPhyWishbone_l44) begin
      phy_native_dp_writeEnable = 1'b1;
    end
  end

  always @(*) begin
    phy_native_dm_writeEnable = phy_logic_io_usb_tx_enable;
    if(when_UsbDeviceWithPhyWishbone_l44) begin
      phy_native_dm_writeEnable = 1'b1;
    end
  end

  always @(*) begin
    phy_native_dp_write = ((! phy_logic_io_usb_tx_se0) && phy_logic_io_usb_tx_data);
    if(when_UsbDeviceWithPhyWishbone_l44) begin
      phy_native_dp_write = 1'b0;
    end
  end

  always @(*) begin
    phy_native_dm_write = ((! phy_logic_io_usb_tx_se0) && (! phy_logic_io_usb_tx_data));
    if(when_UsbDeviceWithPhyWishbone_l44) begin
      phy_native_dm_write = 1'b0;
    end
  end

  assign when_UsbDeviceWithPhyWishbone_l44 = (! phy_logic_io_pullup);
  assign phy_native_dp_stage_writeEnable = phy_native_dp_writeEnable_regNext;
  assign phy_native_dp_stage_write = phy_native_dp_write_regNext;
  assign phy_native_dp_read = phy_native_dp_stage_read_regNext;
  assign phy_buffer_dp_writeEnable = phy_native_dp_stage_writeEnable;
  assign phy_buffer_dp_write = phy_native_dp_stage_write;
  assign phy_native_dp_stage_read = phy_buffer_dp_read;
  assign phy_native_dm_stage_writeEnable = phy_native_dm_writeEnable_regNext;
  assign phy_native_dm_stage_write = phy_native_dm_write_regNext;
  assign phy_native_dm_read = phy_native_dm_stage_read_regNext;
  assign phy_buffer_dm_writeEnable = phy_native_dm_stage_writeEnable;
  assign phy_buffer_dm_write = phy_native_dm_stage_write;
  assign phy_native_dm_stage_read = phy_buffer_dm_read;
  assign phy_buffer_dp_stage_writeEnable = phy_buffer_dp_writeEnable_regNext;
  assign phy_buffer_dp_stage_write = phy_buffer_dp_write_regNext;
  assign phy_buffer_dp_read = phy_buffer_dp_stage_read_regNext;
  assign phy_buffer_stage_dp_writeEnable = phy_buffer_dp_stage_writeEnable;
  assign phy_buffer_stage_dp_write = phy_buffer_dp_stage_write;
  assign phy_buffer_dp_stage_read = phy_buffer_stage_dp_read;
  assign phy_buffer_dm_stage_writeEnable = phy_buffer_dm_writeEnable_regNext;
  assign phy_buffer_dm_stage_write = phy_buffer_dm_write_regNext;
  assign phy_buffer_dm_read = phy_buffer_dm_stage_read_regNext;
  assign phy_buffer_stage_dm_writeEnable = phy_buffer_dm_stage_writeEnable;
  assign phy_buffer_stage_dm_write = phy_buffer_dm_stage_write;
  assign phy_buffer_dm_stage_read = phy_buffer_stage_dm_read;
  assign phy_buffer_stage_dp_read = io_usb_dp_read;
  assign io_usb_dp_write = phy_buffer_stage_dp_write;
  assign io_usb_dp_writeEnable = phy_buffer_stage_dp_writeEnable;
  assign phy_buffer_stage_dm_read = io_usb_dm_read;
  assign io_usb_dm_write = phy_buffer_stage_dm_write;
  assign io_usb_dm_writeEnable = phy_buffer_stage_dm_writeEnable;
  always @(posedge phy_clk) begin
    phy_native_dp_writeEnable_regNext <= phy_native_dp_writeEnable;
    phy_native_dp_write_regNext <= phy_native_dp_write;
    phy_native_dp_stage_read_regNext <= phy_native_dp_stage_read;
    phy_native_dm_writeEnable_regNext <= phy_native_dm_writeEnable;
    phy_native_dm_write_regNext <= phy_native_dm_write;
    phy_native_dm_stage_read_regNext <= phy_native_dm_stage_read;
    phy_buffer_dp_writeEnable_regNext <= phy_buffer_dp_writeEnable;
    phy_buffer_dp_write_regNext <= phy_buffer_dp_write;
    phy_buffer_dp_stage_read_regNext <= phy_buffer_dp_stage_read;
    phy_buffer_dm_writeEnable_regNext <= phy_buffer_dm_writeEnable;
    phy_buffer_dm_write_regNext <= phy_buffer_dm_write;
    phy_buffer_dm_stage_read_regNext <= phy_buffer_dm_stage_read;
  end


endmodule

module PhyCc (
  input               input_tx_stream_valid,
  output              input_tx_stream_ready,
  input               input_tx_stream_payload_last,
  input      [7:0]    input_tx_stream_payload_fragment,
  output              input_tx_eop,
  output              input_rx_flow_valid,
  output     [7:0]    input_rx_flow_payload,
  output              input_rx_active,
  output              input_rx_stuffingError,
  input               input_pullup,
  output              input_reset,
  output              input_suspend,
  output              input_disconnect,
  output              input_resume_valid,
  output              input_tick,
  output              input_power,
  input               input_resumeIt,
  output              output_tx_stream_valid,
  input               output_tx_stream_ready,
  output              output_tx_stream_payload_last,
  output     [7:0]    output_tx_stream_payload_fragment,
  input               output_tx_eop,
  input               output_rx_flow_valid,
  input      [7:0]    output_rx_flow_payload,
  input               output_rx_active,
  input               output_rx_stuffingError,
  output              output_pullup,
  input               output_reset,
  input               output_suspend,
  input               output_disconnect,
  input               output_resume_valid,
  input               output_tick,
  input               output_power,
  output              output_resumeIt,
  input               phy_clk,
  input               phy_reset,
  input               ctrl_clk,
  input               ctrl_reset
);

  reg                 input_tx_stream_ccToggle_io_output_ready;
  wire                input_tx_stream_ccToggle_io_input_ready;
  wire                input_tx_stream_ccToggle_io_output_valid;
  wire                input_tx_stream_ccToggle_io_output_payload_last;
  wire       [7:0]    input_tx_stream_ccToggle_io_output_payload_fragment;
  wire                pulseCCByToggle_2_io_pulseOut;
  wire                pulseCCByToggle_2_phy_reset_syncronized_1;
  wire                output_rx_flow_ccToggle_io_output_valid;
  wire       [7:0]    output_rx_flow_ccToggle_io_output_payload;
  wire                output_rx_active_buffercc_io_dataOut;
  wire                output_rx_stuffingError_buffercc_io_dataOut;
  wire                input_pullup_buffercc_io_dataOut;
  wire                input_resumeIt_buffercc_io_dataOut;
  wire                pulseCCByToggle_3_io_pulseOut;
  wire                output_reset_buffercc_io_dataOut;
  wire                output_suspend_buffercc_io_dataOut;
  wire                output_resume_ccToggle_io_output_valid;
  wire                output_power_buffercc_io_dataOut;
  wire                output_disconnect_buffercc_io_dataOut;
  wire                input_tx_stream_ccToggle_io_output_m2sPipe_valid;
  wire                input_tx_stream_ccToggle_io_output_m2sPipe_ready;
  wire                input_tx_stream_ccToggle_io_output_m2sPipe_payload_last;
  wire       [7:0]    input_tx_stream_ccToggle_io_output_m2sPipe_payload_fragment;
  reg                 input_tx_stream_ccToggle_io_output_rValid;
  reg                 input_tx_stream_ccToggle_io_output_rData_last;
  reg        [7:0]    input_tx_stream_ccToggle_io_output_rData_fragment;
  wire                when_Stream_l366;

  StreamCCByToggle input_tx_stream_ccToggle (
    .io_input_valid                (input_tx_stream_valid                                     ), //i
    .io_input_ready                (input_tx_stream_ccToggle_io_input_ready                   ), //o
    .io_input_payload_last         (input_tx_stream_payload_last                              ), //i
    .io_input_payload_fragment     (input_tx_stream_payload_fragment[7:0]                     ), //i
    .io_output_valid               (input_tx_stream_ccToggle_io_output_valid                  ), //o
    .io_output_ready               (input_tx_stream_ccToggle_io_output_ready                  ), //i
    .io_output_payload_last        (input_tx_stream_ccToggle_io_output_payload_last           ), //o
    .io_output_payload_fragment    (input_tx_stream_ccToggle_io_output_payload_fragment[7:0]  ), //o
    .ctrl_clk                      (ctrl_clk                                                  ), //i
    .ctrl_reset                    (ctrl_reset                                                ), //i
    .phy_clk                       (phy_clk                                                   )  //i
  );
  PulseCCByToggle pulseCCByToggle_2 (
    .io_pulseIn                 (output_tx_eop                              ), //i
    .io_pulseOut                (pulseCCByToggle_2_io_pulseOut              ), //o
    .phy_clk                    (phy_clk                                    ), //i
    .phy_reset                  (phy_reset                                  ), //i
    .ctrl_clk                   (ctrl_clk                                   ), //i
    .phy_reset_syncronized_1    (pulseCCByToggle_2_phy_reset_syncronized_1  )  //o
  );
  FlowCCByToggle output_rx_flow_ccToggle (
    .io_input_valid             (output_rx_flow_valid                            ), //i
    .io_input_payload           (output_rx_flow_payload[7:0]                     ), //i
    .io_output_valid            (output_rx_flow_ccToggle_io_output_valid         ), //o
    .io_output_payload          (output_rx_flow_ccToggle_io_output_payload[7:0]  ), //o
    .phy_clk                    (phy_clk                                         ), //i
    .phy_reset                  (phy_reset                                       ), //i
    .ctrl_clk                   (ctrl_clk                                        ), //i
    .phy_reset_syncronized_1    (pulseCCByToggle_2_phy_reset_syncronized_1       )  //i
  );
  BufferCC_8 output_rx_active_buffercc (
    .io_dataIn     (output_rx_active                      ), //i
    .io_dataOut    (output_rx_active_buffercc_io_dataOut  ), //o
    .ctrl_clk      (ctrl_clk                              ), //i
    .ctrl_reset    (ctrl_reset                            )  //i
  );
  BufferCC_8 output_rx_stuffingError_buffercc (
    .io_dataIn     (output_rx_stuffingError                      ), //i
    .io_dataOut    (output_rx_stuffingError_buffercc_io_dataOut  ), //o
    .ctrl_clk      (ctrl_clk                                     ), //i
    .ctrl_reset    (ctrl_reset                                   )  //i
  );
  BufferCC_10 input_pullup_buffercc (
    .io_dataIn     (input_pullup                      ), //i
    .io_dataOut    (input_pullup_buffercc_io_dataOut  ), //o
    .phy_clk       (phy_clk                           ), //i
    .phy_reset     (phy_reset                         )  //i
  );
  BufferCC_10 input_resumeIt_buffercc (
    .io_dataIn     (input_resumeIt                      ), //i
    .io_dataOut    (input_resumeIt_buffercc_io_dataOut  ), //o
    .phy_clk       (phy_clk                             ), //i
    .phy_reset     (phy_reset                           )  //i
  );
  PulseCCByToggle_1 pulseCCByToggle_3 (
    .io_pulseIn                 (output_tick                                ), //i
    .io_pulseOut                (pulseCCByToggle_3_io_pulseOut              ), //o
    .phy_clk                    (phy_clk                                    ), //i
    .phy_reset                  (phy_reset                                  ), //i
    .ctrl_clk                   (ctrl_clk                                   ), //i
    .phy_reset_syncronized_1    (pulseCCByToggle_2_phy_reset_syncronized_1  )  //i
  );
  BufferCC_8 output_reset_buffercc (
    .io_dataIn     (output_reset                      ), //i
    .io_dataOut    (output_reset_buffercc_io_dataOut  ), //o
    .ctrl_clk      (ctrl_clk                          ), //i
    .ctrl_reset    (ctrl_reset                        )  //i
  );
  BufferCC_8 output_suspend_buffercc (
    .io_dataIn     (output_suspend                      ), //i
    .io_dataOut    (output_suspend_buffercc_io_dataOut  ), //o
    .ctrl_clk      (ctrl_clk                            ), //i
    .ctrl_reset    (ctrl_reset                          )  //i
  );
  FlowCCByToggle_1 output_resume_ccToggle (
    .io_input_valid             (output_resume_valid                        ), //i
    .io_output_valid            (output_resume_ccToggle_io_output_valid     ), //o
    .phy_clk                    (phy_clk                                    ), //i
    .phy_reset                  (phy_reset                                  ), //i
    .ctrl_clk                   (ctrl_clk                                   ), //i
    .phy_reset_syncronized_1    (pulseCCByToggle_2_phy_reset_syncronized_1  )  //i
  );
  BufferCC_8 output_power_buffercc (
    .io_dataIn     (output_power                      ), //i
    .io_dataOut    (output_power_buffercc_io_dataOut  ), //o
    .ctrl_clk      (ctrl_clk                          ), //i
    .ctrl_reset    (ctrl_reset                        )  //i
  );
  BufferCC_8 output_disconnect_buffercc (
    .io_dataIn     (output_disconnect                      ), //i
    .io_dataOut    (output_disconnect_buffercc_io_dataOut  ), //o
    .ctrl_clk      (ctrl_clk                               ), //i
    .ctrl_reset    (ctrl_reset                             )  //i
  );
  assign input_tx_stream_ready = input_tx_stream_ccToggle_io_input_ready;
  always @(*) begin
    input_tx_stream_ccToggle_io_output_ready = input_tx_stream_ccToggle_io_output_m2sPipe_ready;
    if(when_Stream_l366) begin
      input_tx_stream_ccToggle_io_output_ready = 1'b1;
    end
  end

  assign when_Stream_l366 = (! input_tx_stream_ccToggle_io_output_m2sPipe_valid);
  assign input_tx_stream_ccToggle_io_output_m2sPipe_valid = input_tx_stream_ccToggle_io_output_rValid;
  assign input_tx_stream_ccToggle_io_output_m2sPipe_payload_last = input_tx_stream_ccToggle_io_output_rData_last;
  assign input_tx_stream_ccToggle_io_output_m2sPipe_payload_fragment = input_tx_stream_ccToggle_io_output_rData_fragment;
  assign output_tx_stream_valid = input_tx_stream_ccToggle_io_output_m2sPipe_valid;
  assign input_tx_stream_ccToggle_io_output_m2sPipe_ready = output_tx_stream_ready;
  assign output_tx_stream_payload_last = input_tx_stream_ccToggle_io_output_m2sPipe_payload_last;
  assign output_tx_stream_payload_fragment = input_tx_stream_ccToggle_io_output_m2sPipe_payload_fragment;
  assign input_tx_eop = pulseCCByToggle_2_io_pulseOut;
  assign input_rx_flow_valid = output_rx_flow_ccToggle_io_output_valid;
  assign input_rx_flow_payload = output_rx_flow_ccToggle_io_output_payload;
  assign input_rx_active = output_rx_active_buffercc_io_dataOut;
  assign input_rx_stuffingError = output_rx_stuffingError_buffercc_io_dataOut;
  assign output_pullup = input_pullup_buffercc_io_dataOut;
  assign output_resumeIt = input_resumeIt_buffercc_io_dataOut;
  assign input_tick = pulseCCByToggle_3_io_pulseOut;
  assign input_reset = output_reset_buffercc_io_dataOut;
  assign input_suspend = output_suspend_buffercc_io_dataOut;
  assign input_resume_valid = output_resume_ccToggle_io_output_valid;
  assign input_power = output_power_buffercc_io_dataOut;
  assign input_disconnect = output_disconnect_buffercc_io_dataOut;
  always @(posedge phy_clk or posedge phy_reset) begin
    if(phy_reset) begin
      input_tx_stream_ccToggle_io_output_rValid <= 1'b0;
    end else begin
      if(input_tx_stream_ccToggle_io_output_ready) begin
        input_tx_stream_ccToggle_io_output_rValid <= input_tx_stream_ccToggle_io_output_valid;
      end
    end
  end

  always @(posedge phy_clk) begin
    if(input_tx_stream_ccToggle_io_output_ready) begin
      input_tx_stream_ccToggle_io_output_rData_last <= input_tx_stream_ccToggle_io_output_payload_last;
      input_tx_stream_ccToggle_io_output_rData_fragment <= input_tx_stream_ccToggle_io_output_payload_fragment;
    end
  end


endmodule

module UsbDevicePhyNative (
  input               io_ctrl_tx_stream_valid,
  output reg          io_ctrl_tx_stream_ready,
  input               io_ctrl_tx_stream_payload_last,
  input      [7:0]    io_ctrl_tx_stream_payload_fragment,
  output reg          io_ctrl_tx_eop,
  output reg          io_ctrl_rx_flow_valid,
  output     [7:0]    io_ctrl_rx_flow_payload,
  output reg          io_ctrl_rx_active,
  output reg          io_ctrl_rx_stuffingError,
  input               io_ctrl_pullup,
  output              io_ctrl_reset,
  output              io_ctrl_suspend,
  output              io_ctrl_disconnect,
  output              io_ctrl_resume_valid,
  output              io_ctrl_tick,
  output              io_ctrl_power,
  input               io_ctrl_resumeIt,
  output              io_usb_tx_enable,
  output              io_usb_tx_data,
  output              io_usb_tx_se0,
  input               io_usb_rx_dp,
  input               io_usb_rx_dm,
  input               io_power,
  output              io_pullup,
  input               phy_clk,
  input               phy_reset
);
  localparam tx_frame_enumDef_BOOT = 3'd0;
  localparam tx_frame_enumDef_IDLE = 3'd1;
  localparam tx_frame_enumDef_TAKE_LINE = 3'd2;
  localparam tx_frame_enumDef_SYNC = 3'd3;
  localparam tx_frame_enumDef_DATA = 3'd4;
  localparam tx_frame_enumDef_EOP_0 = 3'd5;
  localparam tx_frame_enumDef_EOP_1 = 3'd6;
  localparam tx_frame_enumDef_EOP_2 = 3'd7;
  localparam rx_packet_enumDef_BOOT = 2'd0;
  localparam rx_packet_enumDef_IDLE = 2'd1;
  localparam rx_packet_enumDef_PACKET = 2'd2;
  localparam rx_packet_enumDef_ERRORED = 2'd3;

  wire                rx_filter_io_filtred_dp;
  wire                rx_filter_io_filtred_dm;
  wire                rx_filter_io_filtred_d;
  wire                rx_filter_io_filtred_se0;
  wire                rx_filter_io_filtred_sample;
  wire       [6:0]    _zz_timer_oneCycle;
  wire       [4:0]    _zz_timer_oneCycle_1;
  wire       [6:0]    _zz_timer_twoCycle;
  wire       [5:0]    _zz_timer_twoCycle_1;
  wire       [7:0]    _zz_timer_fourCycle;
  wire       [5:0]    _zz_rxToTxDelay_twoCycle;
  wire       [9:0]    _zz_rx_packet_errorTimeout_trigger;
  wire       [1:0]    _zz_tickTimer_counter_valueNext;
  wire       [0:0]    _zz_tickTimer_counter_valueNext_1;
  reg                 timer_lowSpeed;
  reg        [6:0]    timer_counter;
  reg                 timer_clear;
  wire                timer_inc;
  wire                timer_oneCycle;
  wire                timer_twoCycle;
  wire                timer_fourCycle;
  wire                rxToTxDelay_lowSpeed;
  reg        [4:0]    rxToTxDelay_counter;
  reg                 rxToTxDelay_clear;
  wire                rxToTxDelay_inc;
  wire                rxToTxDelay_twoCycle;
  reg                 rxToTxDelay_active;
  reg                 tx_encoder_input_valid;
  reg                 tx_encoder_input_ready;
  reg                 tx_encoder_input_data;
  reg                 tx_encoder_output_valid;
  reg                 tx_encoder_output_se0;
  reg                 tx_encoder_output_data;
  reg        [2:0]    tx_encoder_counter;
  reg                 tx_encoder_state;
  wire                when_UsbDevicePhyNative_l60;
  wire                when_UsbDevicePhyNative_l65;
  wire                when_UsbDevicePhyNative_l79;
  reg                 tx_serialiser_input_valid;
  reg                 tx_serialiser_input_ready;
  reg        [7:0]    tx_serialiser_input_payload;
  reg        [2:0]    tx_serialiser_bitCounter;
  wire                when_UsbDevicePhyNative_l103;
  wire                when_UsbDevicePhyNative_l109;
  wire                tx_frame_wantExit;
  reg                 tx_frame_wantStart;
  wire                tx_frame_wantKill;
  wire                tx_frame_busy;
  wire                rx_j;
  wire                rx_k;
  reg                 rx_stuffingError;
  reg                 rx_waitSync;
  reg                 rx_decoder_state;
  reg                 rx_decoder_output_valid;
  reg                 rx_decoder_output_payload;
  wire                when_UsbDevicePhyNative_l210;
  reg        [2:0]    rx_destuffer_counter;
  wire                rx_destuffer_unstuffNext;
  wire                rx_destuffer_output_valid;
  wire                rx_destuffer_output_payload;
  wire                when_UsbDevicePhyNative_l231;
  wire                rx_history_updated;
  wire                _zz_rx_history_value;
  reg                 _zz_rx_history_value_1;
  reg                 _zz_rx_history_value_2;
  reg                 _zz_rx_history_value_3;
  reg                 _zz_rx_history_value_4;
  reg                 _zz_rx_history_value_5;
  reg                 _zz_rx_history_value_6;
  reg                 _zz_rx_history_value_7;
  wire       [7:0]    rx_history_value;
  wire                rx_history_sync_hit;
  reg        [6:0]    rx_eop_counter;
  wire                rx_eop_maxHit;
  reg                 rx_eop_hit;
  wire                when_UsbDevicePhyNative_l258;
  wire                when_UsbDevicePhyNative_l259;
  wire                when_UsbDevicePhyNative_l266;
  wire                rx_packet_wantExit;
  reg                 rx_packet_wantStart;
  wire                rx_packet_wantKill;
  reg        [2:0]    rx_packet_counter;
  wire                rx_packet_errorTimeout_lowSpeed;
  reg        [8:0]    rx_packet_errorTimeout_counter;
  reg                 rx_packet_errorTimeout_clear;
  wire                rx_packet_errorTimeout_inc;
  wire                rx_packet_errorTimeout_trigger;
  reg                 rx_packet_errorTimeout_p;
  reg                 rx_packet_errorTimeout_n;
  wire                rx_timerLong_lowSpeed;
  reg        [22:0]   rx_timerLong_counter;
  reg                 rx_timerLong_clear;
  reg                 rx_timerLong_inc;
  wire                rx_timerLong_resume;
  wire                rx_timerLong_reset;
  wire                rx_timerLong_suspend;
  wire                rx_timerLong_oneBit;
  wire                rx_timerLong_threeBit;
  reg                 rx_timerLong_hadOne;
  reg                 rx_timerLong_hadTree;
  wire       [1:0]    rx_detect_current;
  reg        [1:0]    rx_detect_previous;
  wire                when_UsbDevicePhyNative_l358;
  wire                when_UsbDevicePhyNative_l361;
  wire                rx_detect_isReset;
  wire                rx_detect_isSuspend;
  reg                 rx_detect_resumeState;
  wire                when_UsbDevicePhyNative_l367;
  wire                when_UsbDevicePhyNative_l367_1;
  wire                rx_detect_isResume;
  reg                 rx_detect_resetState;
  wire                when_UsbDevicePhyNative_l370;
  wire                when_UsbDevicePhyNative_l370_1;
  reg                 rx_detect_suspendState;
  wire                when_UsbDevicePhyNative_l371;
  wire                when_UsbDevicePhyNative_l371_1;
  reg                 rx_detect_isResume_regNext;
  wire                tickTimer_counter_willIncrement;
  wire                tickTimer_counter_willClear;
  reg        [1:0]    tickTimer_counter_valueNext;
  reg        [1:0]    tickTimer_counter_value;
  wire                tickTimer_counter_willOverflowIfInc;
  wire                tickTimer_counter_willOverflow;
  wire                tickTimer_tick;
  reg        [2:0]    tx_frame_stateReg;
  reg        [2:0]    tx_frame_stateNext;
  wire                when_UsbDevicePhyNative_l132;
  reg        [1:0]    rx_packet_stateReg;
  reg        [1:0]    rx_packet_stateNext;
  wire                when_UsbDevicePhyNative_l297;
  wire                when_UsbDevicePhyNative_l320;
  wire                when_StateMachine_l238;
  wire                when_StateMachine_l238_1;
  `ifndef SYNTHESIS
  reg [71:0] tx_frame_stateReg_string;
  reg [71:0] tx_frame_stateNext_string;
  reg [55:0] rx_packet_stateReg_string;
  reg [55:0] rx_packet_stateNext_string;
  `endif


  assign _zz_timer_oneCycle_1 = (timer_lowSpeed ? 5'h1f : 5'h03);
  assign _zz_timer_oneCycle = {2'd0, _zz_timer_oneCycle_1};
  assign _zz_timer_twoCycle_1 = (timer_lowSpeed ? 6'h3f : 6'h07);
  assign _zz_timer_twoCycle = {1'd0, _zz_timer_twoCycle_1};
  assign _zz_timer_fourCycle = {1'd0, timer_counter};
  assign _zz_rxToTxDelay_twoCycle = {1'd0, rxToTxDelay_counter};
  assign _zz_rx_packet_errorTimeout_trigger = {1'd0, rx_packet_errorTimeout_counter};
  assign _zz_tickTimer_counter_valueNext_1 = tickTimer_counter_willIncrement;
  assign _zz_tickTimer_counter_valueNext = {1'd0, _zz_tickTimer_counter_valueNext_1};
  UsbLsFsPhyFilter rx_filter (
    .io_lowSpeed          (1'b0                         ), //i
    .io_usb_dp            (io_usb_rx_dp                 ), //i
    .io_usb_dm            (io_usb_rx_dm                 ), //i
    .io_filtred_dp        (rx_filter_io_filtred_dp      ), //o
    .io_filtred_dm        (rx_filter_io_filtred_dm      ), //o
    .io_filtred_d         (rx_filter_io_filtred_d       ), //o
    .io_filtred_se0       (rx_filter_io_filtred_se0     ), //o
    .io_filtred_sample    (rx_filter_io_filtred_sample  ), //o
    .phy_clk              (phy_clk                      ), //i
    .phy_reset            (phy_reset                    )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(tx_frame_stateReg)
      tx_frame_enumDef_BOOT : tx_frame_stateReg_string = "BOOT     ";
      tx_frame_enumDef_IDLE : tx_frame_stateReg_string = "IDLE     ";
      tx_frame_enumDef_TAKE_LINE : tx_frame_stateReg_string = "TAKE_LINE";
      tx_frame_enumDef_SYNC : tx_frame_stateReg_string = "SYNC     ";
      tx_frame_enumDef_DATA : tx_frame_stateReg_string = "DATA     ";
      tx_frame_enumDef_EOP_0 : tx_frame_stateReg_string = "EOP_0    ";
      tx_frame_enumDef_EOP_1 : tx_frame_stateReg_string = "EOP_1    ";
      tx_frame_enumDef_EOP_2 : tx_frame_stateReg_string = "EOP_2    ";
      default : tx_frame_stateReg_string = "?????????";
    endcase
  end
  always @(*) begin
    case(tx_frame_stateNext)
      tx_frame_enumDef_BOOT : tx_frame_stateNext_string = "BOOT     ";
      tx_frame_enumDef_IDLE : tx_frame_stateNext_string = "IDLE     ";
      tx_frame_enumDef_TAKE_LINE : tx_frame_stateNext_string = "TAKE_LINE";
      tx_frame_enumDef_SYNC : tx_frame_stateNext_string = "SYNC     ";
      tx_frame_enumDef_DATA : tx_frame_stateNext_string = "DATA     ";
      tx_frame_enumDef_EOP_0 : tx_frame_stateNext_string = "EOP_0    ";
      tx_frame_enumDef_EOP_1 : tx_frame_stateNext_string = "EOP_1    ";
      tx_frame_enumDef_EOP_2 : tx_frame_stateNext_string = "EOP_2    ";
      default : tx_frame_stateNext_string = "?????????";
    endcase
  end
  always @(*) begin
    case(rx_packet_stateReg)
      rx_packet_enumDef_BOOT : rx_packet_stateReg_string = "BOOT   ";
      rx_packet_enumDef_IDLE : rx_packet_stateReg_string = "IDLE   ";
      rx_packet_enumDef_PACKET : rx_packet_stateReg_string = "PACKET ";
      rx_packet_enumDef_ERRORED : rx_packet_stateReg_string = "ERRORED";
      default : rx_packet_stateReg_string = "???????";
    endcase
  end
  always @(*) begin
    case(rx_packet_stateNext)
      rx_packet_enumDef_BOOT : rx_packet_stateNext_string = "BOOT   ";
      rx_packet_enumDef_IDLE : rx_packet_stateNext_string = "IDLE   ";
      rx_packet_enumDef_PACKET : rx_packet_stateNext_string = "PACKET ";
      rx_packet_enumDef_ERRORED : rx_packet_stateNext_string = "ERRORED";
      default : rx_packet_stateNext_string = "???????";
    endcase
  end
  `endif

  assign io_pullup = io_ctrl_pullup;
  always @(*) begin
    timer_clear = 1'b0;
    if(tx_encoder_input_valid) begin
      if(tx_encoder_input_data) begin
        if(timer_oneCycle) begin
          if(when_UsbDevicePhyNative_l60) begin
            timer_clear = 1'b1;
          end
        end
      end
    end
    if(tx_encoder_input_ready) begin
      timer_clear = 1'b1;
    end
    case(tx_frame_stateReg)
      tx_frame_enumDef_IDLE : begin
        timer_clear = 1'b1;
      end
      tx_frame_enumDef_TAKE_LINE : begin
        if(timer_oneCycle) begin
          timer_clear = 1'b1;
        end
      end
      tx_frame_enumDef_SYNC : begin
      end
      tx_frame_enumDef_DATA : begin
      end
      tx_frame_enumDef_EOP_0 : begin
        if(timer_twoCycle) begin
          timer_clear = 1'b1;
        end
      end
      tx_frame_enumDef_EOP_1 : begin
        if(timer_oneCycle) begin
          timer_clear = 1'b1;
        end
      end
      tx_frame_enumDef_EOP_2 : begin
        if(timer_twoCycle) begin
          timer_clear = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign timer_inc = 1'b1;
  assign timer_oneCycle = (timer_counter == _zz_timer_oneCycle);
  assign timer_twoCycle = (timer_counter == _zz_timer_twoCycle);
  assign timer_fourCycle = (_zz_timer_fourCycle == (timer_lowSpeed ? 8'h9f : 8'h13));
  always @(*) begin
    timer_lowSpeed = 1'b0;
    case(tx_frame_stateReg)
      tx_frame_enumDef_IDLE : begin
      end
      tx_frame_enumDef_TAKE_LINE : begin
        timer_lowSpeed = 1'b0;
      end
      tx_frame_enumDef_SYNC : begin
      end
      tx_frame_enumDef_DATA : begin
      end
      tx_frame_enumDef_EOP_0 : begin
      end
      tx_frame_enumDef_EOP_1 : begin
      end
      tx_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    rxToTxDelay_clear = 1'b0;
    if(rx_eop_hit) begin
      rxToTxDelay_clear = 1'b1;
    end
  end

  assign rxToTxDelay_inc = 1'b1;
  assign rxToTxDelay_twoCycle = (_zz_rxToTxDelay_twoCycle == (rxToTxDelay_lowSpeed ? 6'h3f : 6'h07));
  assign rxToTxDelay_lowSpeed = 1'b0;
  always @(*) begin
    tx_encoder_input_valid = 1'b0;
    if(tx_serialiser_input_valid) begin
      tx_encoder_input_valid = 1'b1;
    end
  end

  always @(*) begin
    tx_encoder_input_ready = 1'b0;
    if(tx_encoder_input_valid) begin
      if(tx_encoder_input_data) begin
        if(timer_oneCycle) begin
          tx_encoder_input_ready = 1'b1;
          if(when_UsbDevicePhyNative_l60) begin
            tx_encoder_input_ready = 1'b0;
          end
        end
      end else begin
        if(timer_oneCycle) begin
          tx_encoder_input_ready = 1'b1;
        end
      end
    end
  end

  always @(*) begin
    tx_encoder_input_data = 1'bx;
    if(tx_serialiser_input_valid) begin
      tx_encoder_input_data = tx_serialiser_input_payload[tx_serialiser_bitCounter];
    end
  end

  always @(*) begin
    tx_encoder_output_valid = 1'b0;
    if(tx_encoder_input_valid) begin
      tx_encoder_output_valid = tx_encoder_input_valid;
    end
    case(tx_frame_stateReg)
      tx_frame_enumDef_IDLE : begin
      end
      tx_frame_enumDef_TAKE_LINE : begin
        tx_encoder_output_valid = 1'b1;
      end
      tx_frame_enumDef_SYNC : begin
      end
      tx_frame_enumDef_DATA : begin
      end
      tx_frame_enumDef_EOP_0 : begin
        tx_encoder_output_valid = 1'b1;
      end
      tx_frame_enumDef_EOP_1 : begin
        tx_encoder_output_valid = 1'b1;
      end
      tx_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    tx_encoder_output_se0 = 1'b0;
    case(tx_frame_stateReg)
      tx_frame_enumDef_IDLE : begin
      end
      tx_frame_enumDef_TAKE_LINE : begin
      end
      tx_frame_enumDef_SYNC : begin
      end
      tx_frame_enumDef_DATA : begin
      end
      tx_frame_enumDef_EOP_0 : begin
        tx_encoder_output_se0 = 1'b1;
      end
      tx_frame_enumDef_EOP_1 : begin
      end
      tx_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    tx_encoder_output_data = 1'bx;
    if(tx_encoder_input_valid) begin
      if(tx_encoder_input_data) begin
        tx_encoder_output_data = tx_encoder_state;
      end else begin
        tx_encoder_output_data = (! tx_encoder_state);
      end
    end
    case(tx_frame_stateReg)
      tx_frame_enumDef_IDLE : begin
      end
      tx_frame_enumDef_TAKE_LINE : begin
        tx_encoder_output_data = 1'b1;
      end
      tx_frame_enumDef_SYNC : begin
      end
      tx_frame_enumDef_DATA : begin
      end
      tx_frame_enumDef_EOP_0 : begin
      end
      tx_frame_enumDef_EOP_1 : begin
        tx_encoder_output_data = 1'b1;
      end
      tx_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  assign when_UsbDevicePhyNative_l60 = (tx_encoder_counter == 3'b101);
  assign when_UsbDevicePhyNative_l65 = (tx_encoder_counter == 3'b110);
  assign when_UsbDevicePhyNative_l79 = (! tx_encoder_input_valid);
  always @(*) begin
    tx_serialiser_input_valid = 1'b0;
    case(tx_frame_stateReg)
      tx_frame_enumDef_IDLE : begin
      end
      tx_frame_enumDef_TAKE_LINE : begin
      end
      tx_frame_enumDef_SYNC : begin
        tx_serialiser_input_valid = 1'b1;
      end
      tx_frame_enumDef_DATA : begin
        tx_serialiser_input_valid = 1'b1;
      end
      tx_frame_enumDef_EOP_0 : begin
      end
      tx_frame_enumDef_EOP_1 : begin
      end
      tx_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    tx_serialiser_input_payload = 8'bxxxxxxxx;
    case(tx_frame_stateReg)
      tx_frame_enumDef_IDLE : begin
      end
      tx_frame_enumDef_TAKE_LINE : begin
      end
      tx_frame_enumDef_SYNC : begin
        tx_serialiser_input_payload = 8'h80;
      end
      tx_frame_enumDef_DATA : begin
        tx_serialiser_input_payload = io_ctrl_tx_stream_payload_fragment;
      end
      tx_frame_enumDef_EOP_0 : begin
      end
      tx_frame_enumDef_EOP_1 : begin
      end
      tx_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    tx_serialiser_input_ready = 1'b0;
    if(tx_serialiser_input_valid) begin
      if(tx_encoder_input_ready) begin
        if(when_UsbDevicePhyNative_l103) begin
          tx_serialiser_input_ready = 1'b1;
        end
      end
    end
  end

  assign when_UsbDevicePhyNative_l103 = (tx_serialiser_bitCounter == 3'b111);
  assign when_UsbDevicePhyNative_l109 = ((! tx_serialiser_input_valid) || tx_serialiser_input_ready);
  assign tx_frame_wantExit = 1'b0;
  always @(*) begin
    tx_frame_wantStart = 1'b0;
    case(tx_frame_stateReg)
      tx_frame_enumDef_IDLE : begin
      end
      tx_frame_enumDef_TAKE_LINE : begin
      end
      tx_frame_enumDef_SYNC : begin
      end
      tx_frame_enumDef_DATA : begin
      end
      tx_frame_enumDef_EOP_0 : begin
      end
      tx_frame_enumDef_EOP_1 : begin
      end
      tx_frame_enumDef_EOP_2 : begin
      end
      default : begin
        tx_frame_wantStart = 1'b1;
      end
    endcase
  end

  assign tx_frame_wantKill = 1'b0;
  assign tx_frame_busy = (! (tx_frame_stateReg == tx_frame_enumDef_BOOT));
  always @(*) begin
    io_ctrl_tx_stream_ready = 1'b0;
    case(tx_frame_stateReg)
      tx_frame_enumDef_IDLE : begin
      end
      tx_frame_enumDef_TAKE_LINE : begin
      end
      tx_frame_enumDef_SYNC : begin
      end
      tx_frame_enumDef_DATA : begin
        if(tx_serialiser_input_ready) begin
          io_ctrl_tx_stream_ready = 1'b1;
        end
      end
      tx_frame_enumDef_EOP_0 : begin
      end
      tx_frame_enumDef_EOP_1 : begin
      end
      tx_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_ctrl_tx_eop = 1'b0;
    case(tx_frame_stateReg)
      tx_frame_enumDef_IDLE : begin
      end
      tx_frame_enumDef_TAKE_LINE : begin
      end
      tx_frame_enumDef_SYNC : begin
      end
      tx_frame_enumDef_DATA : begin
      end
      tx_frame_enumDef_EOP_0 : begin
        if(timer_twoCycle) begin
          io_ctrl_tx_eop = 1'b1;
        end
      end
      tx_frame_enumDef_EOP_1 : begin
      end
      tx_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  assign rx_j = (rx_filter_io_filtred_dp && (! rx_filter_io_filtred_dm));
  assign rx_k = ((! rx_filter_io_filtred_dp) && rx_filter_io_filtred_dm);
  always @(*) begin
    rx_waitSync = 1'b0;
    case(rx_packet_stateReg)
      rx_packet_enumDef_IDLE : begin
        rx_waitSync = 1'b1;
      end
      rx_packet_enumDef_PACKET : begin
      end
      rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l238) begin
      rx_waitSync = 1'b1;
    end
  end

  always @(*) begin
    rx_decoder_output_valid = 1'b0;
    if(rx_filter_io_filtred_sample) begin
      rx_decoder_output_valid = 1'b1;
    end
  end

  always @(*) begin
    rx_decoder_output_payload = 1'bx;
    if(rx_filter_io_filtred_sample) begin
      if(when_UsbDevicePhyNative_l210) begin
        rx_decoder_output_payload = 1'b0;
      end else begin
        rx_decoder_output_payload = 1'b1;
      end
    end
  end

  assign when_UsbDevicePhyNative_l210 = (rx_decoder_state ^ rx_filter_io_filtred_d);
  assign rx_destuffer_unstuffNext = (rx_destuffer_counter == 3'b110);
  assign rx_destuffer_output_valid = (rx_decoder_output_valid && (! rx_destuffer_unstuffNext));
  assign rx_destuffer_output_payload = rx_decoder_output_payload;
  assign when_UsbDevicePhyNative_l231 = ((! rx_decoder_output_payload) || rx_destuffer_unstuffNext);
  assign rx_history_updated = rx_destuffer_output_valid;
  assign _zz_rx_history_value = rx_destuffer_output_payload;
  assign rx_history_value = {_zz_rx_history_value,{_zz_rx_history_value_1,{_zz_rx_history_value_2,{_zz_rx_history_value_3,{_zz_rx_history_value_4,{_zz_rx_history_value_5,{_zz_rx_history_value_6,_zz_rx_history_value_7}}}}}}};
  assign rx_history_sync_hit = (rx_history_updated && (rx_history_value == 8'hd5));
  assign rx_eop_maxHit = (rx_eop_counter == 7'h0c);
  always @(*) begin
    rx_eop_hit = 1'b0;
    if(rx_j) begin
      if(when_UsbDevicePhyNative_l266) begin
        rx_eop_hit = 1'b1;
      end
    end
  end

  assign when_UsbDevicePhyNative_l258 = ((! rx_filter_io_filtred_dp) && (! rx_filter_io_filtred_dm));
  assign when_UsbDevicePhyNative_l259 = (! rx_eop_maxHit);
  assign when_UsbDevicePhyNative_l266 = ((7'h05 <= rx_eop_counter) && (! rx_eop_maxHit));
  assign rx_packet_wantExit = 1'b0;
  always @(*) begin
    rx_packet_wantStart = 1'b0;
    case(rx_packet_stateReg)
      rx_packet_enumDef_IDLE : begin
      end
      rx_packet_enumDef_PACKET : begin
      end
      rx_packet_enumDef_ERRORED : begin
      end
      default : begin
        rx_packet_wantStart = 1'b1;
      end
    endcase
  end

  assign rx_packet_wantKill = 1'b0;
  always @(*) begin
    io_ctrl_rx_active = 1'b0;
    case(rx_packet_stateReg)
      rx_packet_enumDef_IDLE : begin
      end
      rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_active = 1'b1;
      end
      rx_packet_enumDef_ERRORED : begin
        io_ctrl_rx_active = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_ctrl_rx_stuffingError = 1'b0;
    case(rx_packet_stateReg)
      rx_packet_enumDef_IDLE : begin
      end
      rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_stuffingError = rx_stuffingError;
      end
      rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_ctrl_rx_flow_valid = 1'b0;
    case(rx_packet_stateReg)
      rx_packet_enumDef_IDLE : begin
      end
      rx_packet_enumDef_PACKET : begin
        if(rx_destuffer_output_valid) begin
          if(when_UsbDevicePhyNative_l297) begin
            io_ctrl_rx_flow_valid = 1'b1;
          end
        end
      end
      rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
  end

  assign io_ctrl_rx_flow_payload = rx_history_value;
  always @(*) begin
    rx_packet_errorTimeout_clear = 1'b0;
    case(rx_packet_stateReg)
      rx_packet_enumDef_IDLE : begin
      end
      rx_packet_enumDef_PACKET : begin
      end
      rx_packet_enumDef_ERRORED : begin
        if(when_UsbDevicePhyNative_l320) begin
          rx_packet_errorTimeout_clear = 1'b1;
        end
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l238_1) begin
      rx_packet_errorTimeout_clear = 1'b1;
    end
  end

  assign rx_packet_errorTimeout_inc = 1'b1;
  assign rx_packet_errorTimeout_lowSpeed = 1'b0;
  assign rx_packet_errorTimeout_trigger = (_zz_rx_packet_errorTimeout_trigger == (rx_packet_errorTimeout_lowSpeed ? 10'h27f : 10'h04f));
  always @(*) begin
    rx_timerLong_clear = 1'b0;
    if(when_UsbDevicePhyNative_l361) begin
      rx_timerLong_clear = 1'b1;
    end
  end

  always @(*) begin
    rx_timerLong_inc = 1'b1;
    if(when_UsbDevicePhyNative_l358) begin
      rx_timerLong_inc = 1'b0;
    end
  end

  assign rx_timerLong_resume = (rx_timerLong_counter == 23'h0e933f);
  assign rx_timerLong_reset = (rx_timerLong_counter == 23'h07403f);
  assign rx_timerLong_suspend = (rx_timerLong_counter == 23'h021fbf);
  assign rx_timerLong_oneBit = (rx_timerLong_counter == 23'h000002);
  assign rx_timerLong_threeBit = (rx_timerLong_counter == 23'h00000a);
  assign rx_timerLong_lowSpeed = 1'b0;
  assign rx_detect_current = {rx_filter_io_filtred_dm,rx_filter_io_filtred_dp};
  assign when_UsbDevicePhyNative_l358 = rx_timerLong_counter[22];
  assign when_UsbDevicePhyNative_l361 = (rx_detect_current != rx_detect_previous);
  assign rx_detect_isReset = (rx_detect_current == 2'b00);
  assign rx_detect_isSuspend = (rx_detect_current == 2'b01);
  assign when_UsbDevicePhyNative_l367 = ((rx_detect_current != 2'b00) && (rx_detect_current != rx_detect_previous));
  assign when_UsbDevicePhyNative_l367_1 = (rx_timerLong_resume && (rx_detect_current == 2'b10));
  assign rx_detect_isResume = (((rx_detect_resumeState && rx_timerLong_hadOne) && (! rx_timerLong_hadTree)) && (rx_detect_current == 2'b01));
  assign when_UsbDevicePhyNative_l370 = (rx_timerLong_reset && rx_detect_isReset);
  assign when_UsbDevicePhyNative_l370_1 = (! rx_detect_isReset);
  assign when_UsbDevicePhyNative_l371 = (rx_timerLong_suspend && rx_detect_isSuspend);
  assign when_UsbDevicePhyNative_l371_1 = (! rx_detect_isSuspend);
  assign io_ctrl_reset = rx_detect_resetState;
  assign io_ctrl_suspend = rx_detect_suspendState;
  assign io_ctrl_disconnect = 1'b0;
  assign io_ctrl_resume_valid = rx_detect_isResume_regNext;
  assign tickTimer_counter_willClear = 1'b0;
  assign tickTimer_counter_willOverflowIfInc = (tickTimer_counter_value == 2'b11);
  assign tickTimer_counter_willOverflow = (tickTimer_counter_willOverflowIfInc && tickTimer_counter_willIncrement);
  always @(*) begin
    tickTimer_counter_valueNext = (tickTimer_counter_value + _zz_tickTimer_counter_valueNext);
    if(tickTimer_counter_willClear) begin
      tickTimer_counter_valueNext = 2'b00;
    end
  end

  assign tickTimer_counter_willIncrement = 1'b1;
  assign tickTimer_tick = (tickTimer_counter_willOverflow == 1'b1);
  assign io_ctrl_tick = tickTimer_tick;
  assign io_usb_tx_enable = tx_encoder_output_valid;
  assign io_usb_tx_se0 = tx_encoder_output_se0;
  assign io_usb_tx_data = tx_encoder_output_data;
  assign io_ctrl_power = io_power;
  always @(*) begin
    tx_frame_stateNext = tx_frame_stateReg;
    case(tx_frame_stateReg)
      tx_frame_enumDef_IDLE : begin
        if(when_UsbDevicePhyNative_l132) begin
          tx_frame_stateNext = tx_frame_enumDef_TAKE_LINE;
        end
      end
      tx_frame_enumDef_TAKE_LINE : begin
        if(timer_oneCycle) begin
          tx_frame_stateNext = tx_frame_enumDef_SYNC;
        end
      end
      tx_frame_enumDef_SYNC : begin
        if(tx_serialiser_input_ready) begin
          tx_frame_stateNext = tx_frame_enumDef_DATA;
        end
      end
      tx_frame_enumDef_DATA : begin
        if(tx_serialiser_input_ready) begin
          if(io_ctrl_tx_stream_payload_last) begin
            tx_frame_stateNext = tx_frame_enumDef_EOP_0;
          end
        end
      end
      tx_frame_enumDef_EOP_0 : begin
        if(timer_twoCycle) begin
          tx_frame_stateNext = tx_frame_enumDef_EOP_1;
        end
      end
      tx_frame_enumDef_EOP_1 : begin
        if(timer_oneCycle) begin
          tx_frame_stateNext = tx_frame_enumDef_EOP_2;
        end
      end
      tx_frame_enumDef_EOP_2 : begin
        if(timer_twoCycle) begin
          tx_frame_stateNext = tx_frame_enumDef_IDLE;
        end
      end
      default : begin
      end
    endcase
    if(tx_frame_wantStart) begin
      tx_frame_stateNext = tx_frame_enumDef_IDLE;
    end
    if(tx_frame_wantKill) begin
      tx_frame_stateNext = tx_frame_enumDef_BOOT;
    end
  end

  assign when_UsbDevicePhyNative_l132 = (io_ctrl_tx_stream_valid && (! rxToTxDelay_active));
  always @(*) begin
    rx_packet_stateNext = rx_packet_stateReg;
    case(rx_packet_stateReg)
      rx_packet_enumDef_IDLE : begin
        if(rx_history_sync_hit) begin
          rx_packet_stateNext = rx_packet_enumDef_PACKET;
        end
      end
      rx_packet_enumDef_PACKET : begin
        if(rx_destuffer_output_valid) begin
          if(when_UsbDevicePhyNative_l297) begin
            if(rx_stuffingError) begin
              rx_packet_stateNext = rx_packet_enumDef_ERRORED;
            end
          end
        end
      end
      rx_packet_enumDef_ERRORED : begin
        if(rx_packet_errorTimeout_trigger) begin
          rx_packet_stateNext = rx_packet_enumDef_IDLE;
        end
      end
      default : begin
      end
    endcase
    if(rx_eop_hit) begin
      rx_packet_stateNext = rx_packet_enumDef_IDLE;
    end
    if(tx_encoder_output_valid) begin
      rx_packet_stateNext = rx_packet_enumDef_IDLE;
    end
    if(rx_packet_wantStart) begin
      rx_packet_stateNext = rx_packet_enumDef_IDLE;
    end
    if(rx_packet_wantKill) begin
      rx_packet_stateNext = rx_packet_enumDef_BOOT;
    end
  end

  assign when_UsbDevicePhyNative_l297 = (rx_packet_counter == 3'b111);
  assign when_UsbDevicePhyNative_l320 = ((rx_packet_errorTimeout_p != rx_filter_io_filtred_dp) || (rx_packet_errorTimeout_n != rx_filter_io_filtred_dm));
  assign when_StateMachine_l238 = ((! (rx_packet_stateReg == rx_packet_enumDef_IDLE)) && (rx_packet_stateNext == rx_packet_enumDef_IDLE));
  assign when_StateMachine_l238_1 = ((! (rx_packet_stateReg == rx_packet_enumDef_ERRORED)) && (rx_packet_stateNext == rx_packet_enumDef_ERRORED));
  always @(posedge phy_clk) begin
    if(timer_inc) begin
      timer_counter <= (timer_counter + 7'h01);
    end
    if(timer_clear) begin
      timer_counter <= 7'h0;
    end
    if(rxToTxDelay_inc) begin
      rxToTxDelay_counter <= (rxToTxDelay_counter + 5'h01);
    end
    if(rxToTxDelay_clear) begin
      rxToTxDelay_counter <= 5'h0;
    end
    if(tx_encoder_input_valid) begin
      if(tx_encoder_input_data) begin
        if(timer_oneCycle) begin
          tx_encoder_counter <= (tx_encoder_counter + 3'b001);
          if(when_UsbDevicePhyNative_l60) begin
            tx_encoder_state <= (! tx_encoder_state);
          end
          if(when_UsbDevicePhyNative_l65) begin
            tx_encoder_counter <= 3'b000;
          end
        end
      end else begin
        if(timer_oneCycle) begin
          tx_encoder_counter <= 3'b000;
          tx_encoder_state <= (! tx_encoder_state);
        end
      end
    end
    if(when_UsbDevicePhyNative_l79) begin
      tx_encoder_counter <= 3'b000;
      tx_encoder_state <= 1'b1;
    end
    if(tx_serialiser_input_valid) begin
      if(tx_encoder_input_ready) begin
        tx_serialiser_bitCounter <= (tx_serialiser_bitCounter + 3'b001);
      end
    end
    if(when_UsbDevicePhyNative_l109) begin
      tx_serialiser_bitCounter <= 3'b000;
    end
    if(rx_filter_io_filtred_sample) begin
      if(when_UsbDevicePhyNative_l210) begin
        rx_decoder_state <= (! rx_decoder_state);
      end
    end
    if(rx_waitSync) begin
      rx_decoder_state <= 1'b0;
    end
    if(rx_decoder_output_valid) begin
      rx_destuffer_counter <= (rx_destuffer_counter + 3'b001);
      if(when_UsbDevicePhyNative_l231) begin
        rx_destuffer_counter <= 3'b000;
        if(rx_decoder_output_payload) begin
          rx_stuffingError <= 1'b1;
        end
      end
    end
    if(rx_waitSync) begin
      rx_destuffer_counter <= 3'b000;
    end
    if(rx_history_updated) begin
      _zz_rx_history_value_1 <= _zz_rx_history_value;
    end
    if(rx_history_updated) begin
      _zz_rx_history_value_2 <= _zz_rx_history_value_1;
    end
    if(rx_history_updated) begin
      _zz_rx_history_value_3 <= _zz_rx_history_value_2;
    end
    if(rx_history_updated) begin
      _zz_rx_history_value_4 <= _zz_rx_history_value_3;
    end
    if(rx_history_updated) begin
      _zz_rx_history_value_5 <= _zz_rx_history_value_4;
    end
    if(rx_history_updated) begin
      _zz_rx_history_value_6 <= _zz_rx_history_value_5;
    end
    if(rx_history_updated) begin
      _zz_rx_history_value_7 <= _zz_rx_history_value_6;
    end
    if(rx_packet_errorTimeout_inc) begin
      rx_packet_errorTimeout_counter <= (rx_packet_errorTimeout_counter + 9'h001);
    end
    if(rx_packet_errorTimeout_clear) begin
      rx_packet_errorTimeout_counter <= 9'h0;
    end
    if(rx_timerLong_inc) begin
      rx_timerLong_counter <= (rx_timerLong_counter + 23'h000001);
    end
    if(rx_timerLong_clear) begin
      rx_timerLong_counter <= 23'h0;
    end
    case(rx_packet_stateReg)
      rx_packet_enumDef_IDLE : begin
        rx_packet_counter <= 3'b000;
        rx_stuffingError <= 1'b0;
      end
      rx_packet_enumDef_PACKET : begin
        if(rx_destuffer_output_valid) begin
          rx_packet_counter <= (rx_packet_counter + 3'b001);
        end
      end
      rx_packet_enumDef_ERRORED : begin
        rx_packet_errorTimeout_p <= rx_filter_io_filtred_dp;
        rx_packet_errorTimeout_n <= rx_filter_io_filtred_dm;
      end
      default : begin
      end
    endcase
  end

  always @(posedge phy_clk or posedge phy_reset) begin
    if(phy_reset) begin
      rxToTxDelay_active <= 1'b0;
      rx_eop_counter <= 7'h0;
      rx_timerLong_hadOne <= 1'b0;
      rx_timerLong_hadTree <= 1'b0;
      rx_detect_previous <= 2'b11;
      rx_detect_resumeState <= 1'b0;
      rx_detect_resetState <= 1'b0;
      rx_detect_suspendState <= 1'b0;
      rx_detect_isResume_regNext <= 1'b0;
      tickTimer_counter_value <= 2'b00;
      tx_frame_stateReg <= tx_frame_enumDef_BOOT;
      rx_packet_stateReg <= rx_packet_enumDef_BOOT;
    end else begin
      if(rxToTxDelay_twoCycle) begin
        rxToTxDelay_active <= 1'b0;
      end
      if(when_UsbDevicePhyNative_l258) begin
        if(when_UsbDevicePhyNative_l259) begin
          rx_eop_counter <= (rx_eop_counter + 7'h01);
        end
      end else begin
        rx_eop_counter <= 7'h0;
      end
      if(rx_timerLong_oneBit) begin
        rx_timerLong_hadOne <= 1'b1;
      end
      if(rx_timerLong_clear) begin
        rx_timerLong_hadOne <= 1'b0;
      end
      if(rx_timerLong_threeBit) begin
        rx_timerLong_hadTree <= 1'b1;
      end
      if(rx_timerLong_clear) begin
        rx_timerLong_hadTree <= 1'b0;
      end
      rx_detect_previous <= rx_detect_current;
      if(when_UsbDevicePhyNative_l367) begin
        rx_detect_resumeState <= 1'b0;
      end
      if(when_UsbDevicePhyNative_l367_1) begin
        rx_detect_resumeState <= 1'b1;
      end
      if(when_UsbDevicePhyNative_l370) begin
        rx_detect_resetState <= 1'b1;
      end
      if(when_UsbDevicePhyNative_l370_1) begin
        rx_detect_resetState <= 1'b0;
      end
      if(when_UsbDevicePhyNative_l371) begin
        rx_detect_suspendState <= 1'b1;
      end
      if(when_UsbDevicePhyNative_l371_1) begin
        rx_detect_suspendState <= 1'b0;
      end
      rx_detect_isResume_regNext <= rx_detect_isResume;
      tickTimer_counter_value <= tickTimer_counter_valueNext;
      tx_frame_stateReg <= tx_frame_stateNext;
      rx_packet_stateReg <= rx_packet_stateNext;
      if(rx_eop_hit) begin
        rxToTxDelay_active <= 1'b1;
      end
    end
  end


endmodule

module UsbDeviceCtrl (
  input               io_ctrl_cmd_valid,
  output              io_ctrl_cmd_ready,
  input               io_ctrl_cmd_payload_last,
  input      [0:0]    io_ctrl_cmd_payload_fragment_opcode,
  input      [15:0]   io_ctrl_cmd_payload_fragment_address,
  input      [1:0]    io_ctrl_cmd_payload_fragment_length,
  input      [31:0]   io_ctrl_cmd_payload_fragment_data,
  input      [3:0]    io_ctrl_cmd_payload_fragment_mask,
  output              io_ctrl_rsp_valid,
  input               io_ctrl_rsp_ready,
  output              io_ctrl_rsp_payload_last,
  output     [0:0]    io_ctrl_rsp_payload_fragment_opcode,
  output     [31:0]   io_ctrl_rsp_payload_fragment_data,
  output reg          io_phy_tx_stream_valid,
  input               io_phy_tx_stream_ready,
  output reg          io_phy_tx_stream_payload_last,
  output reg [7:0]    io_phy_tx_stream_payload_fragment,
  input               io_phy_tx_eop,
  input               io_phy_rx_flow_valid,
  input      [7:0]    io_phy_rx_flow_payload,
  input               io_phy_rx_active,
  input               io_phy_rx_stuffingError,
  output              io_phy_pullup,
  input               io_phy_reset,
  input               io_phy_suspend,
  input               io_phy_disconnect,
  input               io_phy_resume_valid,
  input               io_phy_tick,
  input               io_phy_power,
  output              io_phy_resumeIt,
  output              io_interrupt,
  input               ctrl_clk,
  input               ctrl_reset
);
  localparam dataTx_enumDef_BOOT = 3'd0;
  localparam dataTx_enumDef_PID = 3'd1;
  localparam dataTx_enumDef_DATA = 3'd2;
  localparam dataTx_enumDef_CRC_0 = 3'd3;
  localparam dataTx_enumDef_CRC_1 = 3'd4;
  localparam dataTx_enumDef_EOP = 3'd5;
  localparam active_enumDef_BOOT = 5'd0;
  localparam active_enumDef_IDLE = 5'd1;
  localparam active_enumDef_TOKEN = 5'd2;
  localparam active_enumDef_ADDRESS_HIT = 5'd3;
  localparam active_enumDef_EP_READ = 5'd4;
  localparam active_enumDef_EP_ANALYSE = 5'd5;
  localparam active_enumDef_DESC_READ_0 = 5'd6;
  localparam active_enumDef_DESC_READ_1 = 5'd7;
  localparam active_enumDef_DESC_READ_2 = 5'd8;
  localparam active_enumDef_DESC_ANALYSE = 5'd9;
  localparam active_enumDef_DATA_RX = 5'd10;
  localparam active_enumDef_DATA_RX_ANALYSE = 5'd11;
  localparam active_enumDef_HANDSHAKE_TX_0 = 5'd12;
  localparam active_enumDef_HANDSHAKE_TX_1 = 5'd13;
  localparam active_enumDef_DATA_TX_0 = 5'd14;
  localparam active_enumDef_DATA_TX_1 = 5'd15;
  localparam active_enumDef_HANDSHAKE_RX_0 = 5'd16;
  localparam active_enumDef_HANDSHAKE_RX_1 = 5'd17;
  localparam active_enumDef_UPDATE_SETUP = 5'd18;
  localparam active_enumDef_UPDATE_DESC = 5'd19;
  localparam active_enumDef_UPDATE_EP = 5'd20;
  localparam dataRx_enumDef_BOOT = 2'd0;
  localparam dataRx_enumDef_IDLE = 2'd1;
  localparam dataRx_enumDef_PID = 2'd2;
  localparam dataRx_enumDef_DATA = 2'd3;
  localparam token_enumDef_BOOT = 3'd0;
  localparam token_enumDef_PID = 3'd1;
  localparam token_enumDef_DATA_0 = 3'd2;
  localparam token_enumDef_DATA_1 = 3'd3;
  localparam token_enumDef_CHECK = 3'd4;
  localparam token_enumDef_ERROR = 3'd5;
  localparam main_enumDef_BOOT = 3'd0;
  localparam main_enumDef_ATTACHED = 3'd1;
  localparam main_enumDef_POWERED = 3'd2;
  localparam main_enumDef_ACTIVE_INIT = 3'd3;
  localparam main_enumDef_ACTIVE = 3'd4;

  reg                 token_crc5_io_flush;
  reg                 token_crc5_io_input_valid;
  reg                 dataRx_crc16_io_flush;
  reg                 dataRx_crc16_io_input_valid;
  reg                 dataTx_crc16_io_flush;
  reg        [31:0]   _zz_memory_ram_port0;
  wire       [4:0]    token_crc5_io_result;
  wire       [4:0]    token_crc5_io_resultNext;
  wire       [15:0]   dataRx_crc16_io_result;
  wire       [15:0]   dataRx_crc16_io_resultNext;
  wire       [15:0]   dataTx_crc16_io_result;
  wire       [15:0]   dataTx_crc16_io_resultNext;
  wire       [12:0]   _zz_desc_words_0;
  wire       [12:0]   _zz_desc_currentByte;
  wire       [12:0]   _zz_desc_currentByte_1;
  wire       [11:0]   _zz_desc_currentByte_2;
  wire       [0:0]    _zz_regs_interrupts_reset;
  wire       [0:0]    _zz_regs_interrupts_ep0Setup;
  wire       [0:0]    _zz_regs_interrupts_suspend;
  wire       [0:0]    _zz_regs_interrupts_resume;
  wire       [0:0]    _zz_regs_interrupts_disconnect;
  wire       [0:0]    _zz_regs_pullup;
  wire       [0:0]    _zz_regs_pullup_1;
  wire       [0:0]    _zz_regs_interrupts_enable;
  wire       [0:0]    _zz_regs_interrupts_enable_1;
  wire       [13:0]   _zz_memory_external_readCmd_payload;
  wire       [13:0]   _zz_memory_external_writeCmd_payload_address;
  wire       [11:0]   _zz_memory_internal_readCmd_payload;
  wire       [9:0]    _zz_memory_internal_readCmd_payload_1;
  wire       [12:0]   _zz_active_byteSel;
  reg        [7:0]    _zz_dataTx_input_payload_fragment;
  wire       [7:0]    _zz_memory_internal_writeCmd_payload_data;
  reg                 ctrl_readHaltTrigger;
  reg                 ctrl_writeHaltTrigger;
  wire                ctrl_rsp_valid;
  wire                ctrl_rsp_ready;
  wire                ctrl_rsp_payload_last;
  wire       [0:0]    ctrl_rsp_payload_fragment_opcode;
  reg        [31:0]   ctrl_rsp_payload_fragment_data;
  wire                _zz_io_ctrl_rsp_valid;
  reg                 _zz_ctrl_rsp_ready;
  wire                _zz_io_ctrl_rsp_valid_1;
  reg                 _zz_io_ctrl_rsp_valid_2;
  reg                 _zz_io_ctrl_rsp_payload_last;
  reg        [0:0]    _zz_io_ctrl_rsp_payload_fragment_opcode;
  reg        [31:0]   _zz_io_ctrl_rsp_payload_fragment_data;
  wire                when_Stream_l366;
  wire                ctrl_askWrite;
  wire                ctrl_askRead;
  wire                io_ctrl_cmd_fire;
  wire                ctrl_doWrite;
  wire                io_ctrl_cmd_fire_1;
  wire                ctrl_doRead;
  reg        [15:0]   done_pendings;
  reg        [10:0]   regs_frame;
  reg        [6:0]    regs_address_value;
  reg                 regs_address_enable;
  reg                 regs_address_trigger;
  reg        [15:0]   regs_interrupts_endpoints;
  reg                 regs_interrupts_reset;
  reg                 regs_interrupts_suspend;
  reg                 io_phy_suspend_regNext;
  wire                when_UsbDeviceCtrl_l154;
  reg                 regs_interrupts_resume;
  reg                 regs_interrupts_disconnect;
  reg                 io_phy_power_regNext;
  wire                when_UsbDeviceCtrl_l156;
  reg                 regs_interrupts_ep0Setup;
  reg                 regs_interrupts_enable;
  wire                regs_interrupts_pending;
  reg        [3:0]    regs_halt_id;
  reg                 regs_halt_enable;
  reg                 regs_halt_effective;
  wire                regs_halt_hit;
  reg                 regs_pullup;
  wire                memory_readPort_cmd_valid;
  wire       [9:0]    memory_readPort_cmd_payload;
  wire       [31:0]   memory_readPort_rsp;
  wire                memory_writePort_valid;
  wire       [9:0]    memory_writePort_payload_address;
  wire       [31:0]   memory_writePort_payload_data;
  wire       [3:0]    memory_writePort_payload_mask;
  reg                 memory_internal_writeCmd_valid;
  reg        [9:0]    memory_internal_writeCmd_payload_address;
  reg        [31:0]   memory_internal_writeCmd_payload_data;
  reg        [3:0]    memory_internal_writeCmd_payload_mask;
  reg                 memory_internal_readCmd_valid;
  reg        [9:0]    memory_internal_readCmd_payload;
  reg                 memory_internal_readCmd_regNext_valid;
  reg        [9:0]    memory_internal_readCmd_regNext_payload;
  wire                memory_internal_readRsp_valid;
  wire       [31:0]   memory_internal_readRsp_payload;
  reg                 memory_external_halt;
  reg                 memory_external_writeCmd_valid;
  wire                memory_external_writeCmd_ready;
  wire       [9:0]    memory_external_writeCmd_payload_address;
  wire       [31:0]   memory_external_writeCmd_payload_data;
  wire       [3:0]    memory_external_writeCmd_payload_mask;
  reg                 memory_external_readCmd_valid;
  wire                memory_external_readCmd_ready;
  wire       [9:0]    memory_external_readCmd_payload;
  wire                memory_external_readCmd_fire;
  reg                 _zz_memory_external_readRsp_valid;
  wire                memory_external_readRsp_valid;
  wire       [31:0]   memory_external_readRsp_payload;
  wire                _zz_memory_external_writeCmd_ready;
  wire                memory_external_writeCmdHalted_valid;
  wire                memory_external_writeCmdHalted_ready;
  wire       [9:0]    memory_external_writeCmdHalted_payload_address;
  wire       [31:0]   memory_external_writeCmdHalted_payload_data;
  wire       [3:0]    memory_external_writeCmdHalted_payload_mask;
  reg        [4:0]    rxTimer_counter;
  reg                 rxTimer_clear;
  wire                rxTimer_timeout;
  wire                rxTimer_turnover;
  reg                 token_wantExit;
  reg                 token_wantStart;
  wire                token_wantKill;
  reg        [3:0]    token_pid;
  reg        [10:0]   token_data;
  wire       [6:0]    token_address;
  wire       [3:0]    token_endpoint;
  reg                 token_ok;
  wire                token_isSetup;
  wire                token_isIn;
  reg                 dataRx_wantExit;
  reg                 dataRx_wantStart;
  wire                dataRx_wantKill;
  reg        [3:0]    dataRx_pid;
  reg                 dataRx_data_valid;
  wire       [7:0]    dataRx_data_payload;
  wire       [7:0]    dataRx_history_0;
  wire       [7:0]    dataRx_history_1;
  reg        [7:0]    _zz_dataRx_history_0;
  reg        [7:0]    _zz_dataRx_history_1;
  reg        [1:0]    dataRx_valids;
  reg                 dataRx_notResponding;
  reg                 dataRx_stuffingError;
  reg                 dataRx_pidError;
  reg                 dataRx_crcError;
  wire                dataRx_hasError;
  reg                 dataTx_wantExit;
  reg                 dataTx_wantStart;
  wire                dataTx_wantKill;
  reg        [3:0]    dataTx_pid;
  wire                dataTx_data_valid;
  reg                 dataTx_data_ready;
  wire                dataTx_data_payload_last;
  wire       [7:0]    dataTx_data_payload_fragment;
  wire                dataTx_data_fire;
  reg                 dataTx_startNull;
  reg                 dataTx_input_valid;
  wire                dataTx_input_ready;
  reg                 dataTx_input_payload_last;
  reg        [7:0]    dataTx_input_payload_fragment;
  wire                dataTx_input_halfPipe_valid;
  reg                 dataTx_input_halfPipe_ready;
  wire                dataTx_input_halfPipe_payload_last;
  wire       [7:0]    dataTx_input_halfPipe_payload_fragment;
  reg                 dataTx_input_rValid;
  wire                dataTx_input_halfPipe_fire;
  reg                 dataTx_input_rData_last;
  reg        [7:0]    dataTx_input_rData_fragment;
  wire                dataTx_input_halfPipe_m2sPipe_valid;
  wire                dataTx_input_halfPipe_m2sPipe_ready;
  wire                dataTx_input_halfPipe_m2sPipe_payload_last;
  wire       [7:0]    dataTx_input_halfPipe_m2sPipe_payload_fragment;
  reg                 dataTx_input_halfPipe_rValid;
  reg                 dataTx_input_halfPipe_rData_last;
  reg        [7:0]    dataTx_input_halfPipe_rData_fragment;
  wire                when_Stream_l366_1;
  wire                when_UsbDeviceCtrl_l281;
  reg        [31:0]   ep_word;
  wire       [7:0]    ep_head;
  wire                ep_enable;
  wire                ep_stall;
  wire                ep_nack;
  wire                ep_dataPhase;
  wire                ep_isochronous;
  wire       [9:0]    ep_maxPacketSize;
  wire       [11:0]   ep_headByte;
  reg        [31:0]   desc_words_0;
  reg        [31:0]   desc_words_1;
  reg        [31:0]   desc_words_2;
  wire       [12:0]   desc_offset;
  wire       [3:0]    desc_code;
  wire       [7:0]    desc_next;
  wire       [12:0]   desc_length;
  wire                desc_direction;
  wire                desc_interrupt;
  wire                desc_completionOnFull;
  wire                desc_data1OnCompletion;
  wire       [11:0]   desc_frame;
  reg                 desc_offsetIncrement;
  wire       [11:0]   desc_currentByte;
  wire                desc_full;
  wire                desc_dataPhaseMatch;
  reg        [9:0]    byteCounter_value;
  reg                 byteCounter_clear;
  reg                 byteCounter_increment;
  wire                byteCounter_full;
  wire                transferFull;
  wire                active_wantExit;
  reg                 active_wantStart;
  wire                active_wantKill;
  reg        [3:0]    active_handshakePid;
  reg                 active_completion;
  reg                 active_noUpdate;
  wire                when_UsbDeviceCtrl_l363;
  reg        [1:0]    active_byteSel;
  reg                 active_dataRxOverrun;
  wire                main_wantExit;
  reg                 main_wantStart;
  wire                main_wantKill;
  wire       [15:0]   _zz_when_BusSlaveFactory_l341;
  reg                 when_BusSlaveFactory_l335;
  wire                when_BusSlaveFactory_l341;
  wire                when_BusSlaveFactory_l341_1;
  wire                when_BusSlaveFactory_l341_2;
  wire                when_BusSlaveFactory_l341_3;
  wire                when_BusSlaveFactory_l341_4;
  wire                when_BusSlaveFactory_l341_5;
  wire                when_BusSlaveFactory_l341_6;
  wire                when_BusSlaveFactory_l341_7;
  wire                when_BusSlaveFactory_l341_8;
  wire                when_BusSlaveFactory_l341_9;
  wire                when_BusSlaveFactory_l341_10;
  wire                when_BusSlaveFactory_l341_11;
  wire                when_BusSlaveFactory_l341_12;
  wire                when_BusSlaveFactory_l341_13;
  wire                when_BusSlaveFactory_l341_14;
  wire                when_BusSlaveFactory_l341_15;
  reg                 when_BusSlaveFactory_l335_1;
  wire                when_BusSlaveFactory_l341_16;
  reg                 when_BusSlaveFactory_l335_2;
  wire                when_BusSlaveFactory_l341_17;
  reg                 when_BusSlaveFactory_l335_3;
  wire                when_BusSlaveFactory_l341_18;
  reg                 when_BusSlaveFactory_l335_4;
  wire                when_BusSlaveFactory_l341_19;
  reg                 when_BusSlaveFactory_l335_5;
  wire                when_BusSlaveFactory_l341_20;
  reg                 when_BusSlaveFactory_l371;
  wire                when_BusSlaveFactory_l373;
  reg                 when_BusSlaveFactory_l335_6;
  wire                when_BusSlaveFactory_l341_21;
  reg                 when_BusSlaveFactory_l371_1;
  wire                when_BusSlaveFactory_l373_1;
  reg                 when_BusSlaveFactory_l335_7;
  wire                when_BusSlaveFactory_l341_22;
  reg        [31:0]   mapping_readBuffer;
  reg        [1:0]    mapping_readState;
  reg        [0:0]    mapping_writeState;
  reg                 regs_interrupts_pending_regNext;
  wire                when_BusSlaveFactory_l962;
  wire                when_BusSlaveFactory_l962_1;
  wire                when_BusSlaveFactory_l962_2;
  wire                when_BusSlaveFactory_l962_3;
  wire                when_BusSlaveFactory_l962_4;
  wire                when_BusSlaveFactory_l962_5;
  wire                when_BmbSlaveFactory_l71;
  reg        [1:0]    dataRx_stateReg;
  reg        [1:0]    dataRx_stateNext;
  wire                when_Misc_l64;
  wire                when_Misc_l70;
  wire                when_Misc_l71;
  wire                when_Misc_l78;
  wire                when_StateMachine_l238;
  wire                when_Misc_l85;
  reg        [2:0]    dataTx_stateReg;
  reg        [2:0]    dataTx_stateNext;
  reg        [2:0]    token_stateReg;
  reg        [2:0]    token_stateNext;
  wire                when_Misc_l204;
  wire                when_Misc_l229;
  wire                when_Misc_l230;
  wire                when_Misc_l241;
  wire                when_StateMachine_l222;
  wire                when_Misc_l247;
  reg        [4:0]    active_stateReg;
  reg        [4:0]    active_stateNext;
  wire                when_UsbDeviceCtrl_l379;
  wire                when_UsbDeviceCtrl_l388;
  wire                when_UsbDeviceCtrl_l390;
  wire                when_UsbDeviceCtrl_l412;
  wire                when_UsbDeviceCtrl_l415;
  wire                when_UsbDeviceCtrl_l424;
  wire                when_UsbDeviceCtrl_l478;
  wire       [1:0]    _zz_memory_internal_writeCmd_payload_mask;
  reg        [3:0]    _zz_memory_internal_writeCmd_payload_mask_1;
  wire                when_UsbDeviceCtrl_l556;
  wire                when_UsbDeviceCtrl_l569;
  wire                when_UsbDeviceCtrl_l572;
  wire                when_UsbDeviceCtrl_l575;
  wire                when_UsbDeviceCtrl_l578;
  wire                when_UsbDeviceCtrl_l497;
  wire                when_UsbDeviceCtrl_l527;
  wire                when_UsbDeviceCtrl_l529;
  reg                 io_phy_rx_active_regNext;
  wire                when_UsbDeviceCtrl_l535;
  wire                when_UsbDeviceCtrl_l541;
  wire                when_UsbDeviceCtrl_l609;
  wire                when_UsbDeviceCtrl_l610;
  wire                when_UsbDeviceCtrl_l655;
  wire                when_UsbDeviceCtrl_l658;
  wire                when_StateMachine_l238_1;
  wire                when_StateMachine_l238_2;
  wire                when_StateMachine_l238_3;
  reg        [2:0]    main_stateReg;
  reg        [2:0]    main_stateNext;
  wire                when_UsbDeviceCtrl_l687;
  wire                when_StateMachine_l238_4;
  wire                when_StateMachine_l238_5;
  `ifndef SYNTHESIS
  reg [31:0] dataRx_stateReg_string;
  reg [31:0] dataRx_stateNext_string;
  reg [39:0] dataTx_stateReg_string;
  reg [39:0] dataTx_stateNext_string;
  reg [47:0] token_stateReg_string;
  reg [47:0] token_stateNext_string;
  reg [119:0] active_stateReg_string;
  reg [119:0] active_stateNext_string;
  reg [87:0] main_stateReg_string;
  reg [87:0] main_stateNext_string;
  `endif

  reg [7:0] memory_ram_symbol0 [0:1023];
  reg [7:0] memory_ram_symbol1 [0:1023];
  reg [7:0] memory_ram_symbol2 [0:1023];
  reg [7:0] memory_ram_symbol3 [0:1023];
  reg [7:0] _zz_memory_ramsymbol_read;
  reg [7:0] _zz_memory_ramsymbol_read_1;
  reg [7:0] _zz_memory_ramsymbol_read_2;
  reg [7:0] _zz_memory_ramsymbol_read_3;

  assign _zz_desc_words_0 = (desc_offset + 13'h0001);
  assign _zz_desc_currentByte = (_zz_desc_currentByte_1 + desc_offset);
  assign _zz_desc_currentByte_2 = {ep_head,4'b1100};
  assign _zz_desc_currentByte_1 = {1'd0, _zz_desc_currentByte_2};
  assign _zz_regs_interrupts_reset = 1'b0;
  assign _zz_regs_interrupts_ep0Setup = 1'b0;
  assign _zz_regs_interrupts_suspend = 1'b0;
  assign _zz_regs_interrupts_resume = 1'b0;
  assign _zz_regs_interrupts_disconnect = 1'b0;
  assign _zz_regs_pullup = 1'b1;
  assign _zz_regs_pullup_1 = 1'b0;
  assign _zz_regs_interrupts_enable = 1'b1;
  assign _zz_regs_interrupts_enable_1 = 1'b0;
  assign _zz_memory_external_readCmd_payload = (io_ctrl_cmd_payload_fragment_address >>> 2);
  assign _zz_memory_external_writeCmd_payload_address = (io_ctrl_cmd_payload_fragment_address >>> 2);
  assign _zz_memory_internal_readCmd_payload = ({2'd0,_zz_memory_internal_readCmd_payload_1} <<< 2);
  assign _zz_memory_internal_readCmd_payload_1 = {6'd0, token_endpoint};
  assign _zz_active_byteSel = desc_offset;
  assign _zz_memory_internal_writeCmd_payload_data = (active_completion ? desc_next : ep_head);
  always @(*) begin
    _zz_memory_ram_port0 = {_zz_memory_ramsymbol_read_3, _zz_memory_ramsymbol_read_2, _zz_memory_ramsymbol_read_1, _zz_memory_ramsymbol_read};
  end
  always @(posedge ctrl_clk) begin
    if(memory_readPort_cmd_valid) begin
      _zz_memory_ramsymbol_read <= memory_ram_symbol0[memory_readPort_cmd_payload];
      _zz_memory_ramsymbol_read_1 <= memory_ram_symbol1[memory_readPort_cmd_payload];
      _zz_memory_ramsymbol_read_2 <= memory_ram_symbol2[memory_readPort_cmd_payload];
      _zz_memory_ramsymbol_read_3 <= memory_ram_symbol3[memory_readPort_cmd_payload];
    end
  end

  always @(posedge ctrl_clk) begin
    if(memory_writePort_payload_mask[0] && memory_writePort_valid) begin
      memory_ram_symbol0[memory_writePort_payload_address] <= memory_writePort_payload_data[7 : 0];
    end
    if(memory_writePort_payload_mask[1] && memory_writePort_valid) begin
      memory_ram_symbol1[memory_writePort_payload_address] <= memory_writePort_payload_data[15 : 8];
    end
    if(memory_writePort_payload_mask[2] && memory_writePort_valid) begin
      memory_ram_symbol2[memory_writePort_payload_address] <= memory_writePort_payload_data[23 : 16];
    end
    if(memory_writePort_payload_mask[3] && memory_writePort_valid) begin
      memory_ram_symbol3[memory_writePort_payload_address] <= memory_writePort_payload_data[31 : 24];
    end
  end

  Crc token_crc5 (
    .io_flush            (token_crc5_io_flush            ), //i
    .io_input_valid      (token_crc5_io_input_valid      ), //i
    .io_input_payload    (io_phy_rx_flow_payload[7:0]    ), //i
    .io_result           (token_crc5_io_result[4:0]      ), //o
    .io_resultNext       (token_crc5_io_resultNext[4:0]  ), //o
    .ctrl_clk            (ctrl_clk                       ), //i
    .ctrl_reset          (ctrl_reset                     )  //i
  );
  Crc_1 dataRx_crc16 (
    .io_flush            (dataRx_crc16_io_flush             ), //i
    .io_input_valid      (dataRx_crc16_io_input_valid       ), //i
    .io_input_payload    (io_phy_rx_flow_payload[7:0]       ), //i
    .io_result           (dataRx_crc16_io_result[15:0]      ), //o
    .io_resultNext       (dataRx_crc16_io_resultNext[15:0]  ), //o
    .ctrl_clk            (ctrl_clk                          ), //i
    .ctrl_reset          (ctrl_reset                        )  //i
  );
  Crc_2 dataTx_crc16 (
    .io_flush            (dataTx_crc16_io_flush              ), //i
    .io_input_valid      (dataTx_data_fire                   ), //i
    .io_input_payload    (dataTx_data_payload_fragment[7:0]  ), //i
    .io_result           (dataTx_crc16_io_result[15:0]       ), //o
    .io_resultNext       (dataTx_crc16_io_resultNext[15:0]   ), //o
    .ctrl_clk            (ctrl_clk                           ), //i
    .ctrl_reset          (ctrl_reset                         )  //i
  );
  always @(*) begin
    case(active_byteSel)
      2'b00 : _zz_dataTx_input_payload_fragment = memory_internal_readRsp_payload[7 : 0];
      2'b01 : _zz_dataTx_input_payload_fragment = memory_internal_readRsp_payload[15 : 8];
      2'b10 : _zz_dataTx_input_payload_fragment = memory_internal_readRsp_payload[23 : 16];
      default : _zz_dataTx_input_payload_fragment = memory_internal_readRsp_payload[31 : 24];
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(dataRx_stateReg)
      dataRx_enumDef_BOOT : dataRx_stateReg_string = "BOOT";
      dataRx_enumDef_IDLE : dataRx_stateReg_string = "IDLE";
      dataRx_enumDef_PID : dataRx_stateReg_string = "PID ";
      dataRx_enumDef_DATA : dataRx_stateReg_string = "DATA";
      default : dataRx_stateReg_string = "????";
    endcase
  end
  always @(*) begin
    case(dataRx_stateNext)
      dataRx_enumDef_BOOT : dataRx_stateNext_string = "BOOT";
      dataRx_enumDef_IDLE : dataRx_stateNext_string = "IDLE";
      dataRx_enumDef_PID : dataRx_stateNext_string = "PID ";
      dataRx_enumDef_DATA : dataRx_stateNext_string = "DATA";
      default : dataRx_stateNext_string = "????";
    endcase
  end
  always @(*) begin
    case(dataTx_stateReg)
      dataTx_enumDef_BOOT : dataTx_stateReg_string = "BOOT ";
      dataTx_enumDef_PID : dataTx_stateReg_string = "PID  ";
      dataTx_enumDef_DATA : dataTx_stateReg_string = "DATA ";
      dataTx_enumDef_CRC_0 : dataTx_stateReg_string = "CRC_0";
      dataTx_enumDef_CRC_1 : dataTx_stateReg_string = "CRC_1";
      dataTx_enumDef_EOP : dataTx_stateReg_string = "EOP  ";
      default : dataTx_stateReg_string = "?????";
    endcase
  end
  always @(*) begin
    case(dataTx_stateNext)
      dataTx_enumDef_BOOT : dataTx_stateNext_string = "BOOT ";
      dataTx_enumDef_PID : dataTx_stateNext_string = "PID  ";
      dataTx_enumDef_DATA : dataTx_stateNext_string = "DATA ";
      dataTx_enumDef_CRC_0 : dataTx_stateNext_string = "CRC_0";
      dataTx_enumDef_CRC_1 : dataTx_stateNext_string = "CRC_1";
      dataTx_enumDef_EOP : dataTx_stateNext_string = "EOP  ";
      default : dataTx_stateNext_string = "?????";
    endcase
  end
  always @(*) begin
    case(token_stateReg)
      token_enumDef_BOOT : token_stateReg_string = "BOOT  ";
      token_enumDef_PID : token_stateReg_string = "PID   ";
      token_enumDef_DATA_0 : token_stateReg_string = "DATA_0";
      token_enumDef_DATA_1 : token_stateReg_string = "DATA_1";
      token_enumDef_CHECK : token_stateReg_string = "CHECK ";
      token_enumDef_ERROR : token_stateReg_string = "ERROR ";
      default : token_stateReg_string = "??????";
    endcase
  end
  always @(*) begin
    case(token_stateNext)
      token_enumDef_BOOT : token_stateNext_string = "BOOT  ";
      token_enumDef_PID : token_stateNext_string = "PID   ";
      token_enumDef_DATA_0 : token_stateNext_string = "DATA_0";
      token_enumDef_DATA_1 : token_stateNext_string = "DATA_1";
      token_enumDef_CHECK : token_stateNext_string = "CHECK ";
      token_enumDef_ERROR : token_stateNext_string = "ERROR ";
      default : token_stateNext_string = "??????";
    endcase
  end
  always @(*) begin
    case(active_stateReg)
      active_enumDef_BOOT : active_stateReg_string = "BOOT           ";
      active_enumDef_IDLE : active_stateReg_string = "IDLE           ";
      active_enumDef_TOKEN : active_stateReg_string = "TOKEN          ";
      active_enumDef_ADDRESS_HIT : active_stateReg_string = "ADDRESS_HIT    ";
      active_enumDef_EP_READ : active_stateReg_string = "EP_READ        ";
      active_enumDef_EP_ANALYSE : active_stateReg_string = "EP_ANALYSE     ";
      active_enumDef_DESC_READ_0 : active_stateReg_string = "DESC_READ_0    ";
      active_enumDef_DESC_READ_1 : active_stateReg_string = "DESC_READ_1    ";
      active_enumDef_DESC_READ_2 : active_stateReg_string = "DESC_READ_2    ";
      active_enumDef_DESC_ANALYSE : active_stateReg_string = "DESC_ANALYSE   ";
      active_enumDef_DATA_RX : active_stateReg_string = "DATA_RX        ";
      active_enumDef_DATA_RX_ANALYSE : active_stateReg_string = "DATA_RX_ANALYSE";
      active_enumDef_HANDSHAKE_TX_0 : active_stateReg_string = "HANDSHAKE_TX_0 ";
      active_enumDef_HANDSHAKE_TX_1 : active_stateReg_string = "HANDSHAKE_TX_1 ";
      active_enumDef_DATA_TX_0 : active_stateReg_string = "DATA_TX_0      ";
      active_enumDef_DATA_TX_1 : active_stateReg_string = "DATA_TX_1      ";
      active_enumDef_HANDSHAKE_RX_0 : active_stateReg_string = "HANDSHAKE_RX_0 ";
      active_enumDef_HANDSHAKE_RX_1 : active_stateReg_string = "HANDSHAKE_RX_1 ";
      active_enumDef_UPDATE_SETUP : active_stateReg_string = "UPDATE_SETUP   ";
      active_enumDef_UPDATE_DESC : active_stateReg_string = "UPDATE_DESC    ";
      active_enumDef_UPDATE_EP : active_stateReg_string = "UPDATE_EP      ";
      default : active_stateReg_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(active_stateNext)
      active_enumDef_BOOT : active_stateNext_string = "BOOT           ";
      active_enumDef_IDLE : active_stateNext_string = "IDLE           ";
      active_enumDef_TOKEN : active_stateNext_string = "TOKEN          ";
      active_enumDef_ADDRESS_HIT : active_stateNext_string = "ADDRESS_HIT    ";
      active_enumDef_EP_READ : active_stateNext_string = "EP_READ        ";
      active_enumDef_EP_ANALYSE : active_stateNext_string = "EP_ANALYSE     ";
      active_enumDef_DESC_READ_0 : active_stateNext_string = "DESC_READ_0    ";
      active_enumDef_DESC_READ_1 : active_stateNext_string = "DESC_READ_1    ";
      active_enumDef_DESC_READ_2 : active_stateNext_string = "DESC_READ_2    ";
      active_enumDef_DESC_ANALYSE : active_stateNext_string = "DESC_ANALYSE   ";
      active_enumDef_DATA_RX : active_stateNext_string = "DATA_RX        ";
      active_enumDef_DATA_RX_ANALYSE : active_stateNext_string = "DATA_RX_ANALYSE";
      active_enumDef_HANDSHAKE_TX_0 : active_stateNext_string = "HANDSHAKE_TX_0 ";
      active_enumDef_HANDSHAKE_TX_1 : active_stateNext_string = "HANDSHAKE_TX_1 ";
      active_enumDef_DATA_TX_0 : active_stateNext_string = "DATA_TX_0      ";
      active_enumDef_DATA_TX_1 : active_stateNext_string = "DATA_TX_1      ";
      active_enumDef_HANDSHAKE_RX_0 : active_stateNext_string = "HANDSHAKE_RX_0 ";
      active_enumDef_HANDSHAKE_RX_1 : active_stateNext_string = "HANDSHAKE_RX_1 ";
      active_enumDef_UPDATE_SETUP : active_stateNext_string = "UPDATE_SETUP   ";
      active_enumDef_UPDATE_DESC : active_stateNext_string = "UPDATE_DESC    ";
      active_enumDef_UPDATE_EP : active_stateNext_string = "UPDATE_EP      ";
      default : active_stateNext_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(main_stateReg)
      main_enumDef_BOOT : main_stateReg_string = "BOOT       ";
      main_enumDef_ATTACHED : main_stateReg_string = "ATTACHED   ";
      main_enumDef_POWERED : main_stateReg_string = "POWERED    ";
      main_enumDef_ACTIVE_INIT : main_stateReg_string = "ACTIVE_INIT";
      main_enumDef_ACTIVE : main_stateReg_string = "ACTIVE     ";
      default : main_stateReg_string = "???????????";
    endcase
  end
  always @(*) begin
    case(main_stateNext)
      main_enumDef_BOOT : main_stateNext_string = "BOOT       ";
      main_enumDef_ATTACHED : main_stateNext_string = "ATTACHED   ";
      main_enumDef_POWERED : main_stateNext_string = "POWERED    ";
      main_enumDef_ACTIVE_INIT : main_stateNext_string = "ACTIVE_INIT";
      main_enumDef_ACTIVE : main_stateNext_string = "ACTIVE     ";
      default : main_stateNext_string = "???????????";
    endcase
  end
  `endif

  assign io_phy_resumeIt = 1'b0;
  always @(*) begin
    io_phy_tx_stream_valid = 1'b0;
    case(dataTx_stateReg)
      dataTx_enumDef_PID : begin
        io_phy_tx_stream_valid = 1'b1;
      end
      dataTx_enumDef_DATA : begin
        io_phy_tx_stream_valid = 1'b1;
      end
      dataTx_enumDef_CRC_0 : begin
        io_phy_tx_stream_valid = 1'b1;
      end
      dataTx_enumDef_CRC_1 : begin
        io_phy_tx_stream_valid = 1'b1;
      end
      dataTx_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
    case(active_stateReg)
      active_enumDef_IDLE : begin
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
      end
      active_enumDef_EP_READ : begin
      end
      active_enumDef_EP_ANALYSE : begin
      end
      active_enumDef_DESC_READ_0 : begin
      end
      active_enumDef_DESC_READ_1 : begin
      end
      active_enumDef_DESC_READ_2 : begin
      end
      active_enumDef_DESC_ANALYSE : begin
      end
      active_enumDef_DATA_RX : begin
      end
      active_enumDef_DATA_RX_ANALYSE : begin
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
        io_phy_tx_stream_valid = 1'b1;
      end
      active_enumDef_DATA_TX_0 : begin
      end
      active_enumDef_DATA_TX_1 : begin
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
      end
      active_enumDef_UPDATE_DESC : begin
      end
      active_enumDef_UPDATE_EP : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_phy_tx_stream_payload_last = 1'bx;
    case(dataTx_stateReg)
      dataTx_enumDef_PID : begin
        io_phy_tx_stream_payload_last = 1'b0;
      end
      dataTx_enumDef_DATA : begin
        io_phy_tx_stream_payload_last = 1'b0;
      end
      dataTx_enumDef_CRC_0 : begin
        io_phy_tx_stream_payload_last = 1'b0;
      end
      dataTx_enumDef_CRC_1 : begin
        io_phy_tx_stream_payload_last = 1'b1;
      end
      dataTx_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
    case(active_stateReg)
      active_enumDef_IDLE : begin
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
      end
      active_enumDef_EP_READ : begin
      end
      active_enumDef_EP_ANALYSE : begin
      end
      active_enumDef_DESC_READ_0 : begin
      end
      active_enumDef_DESC_READ_1 : begin
      end
      active_enumDef_DESC_READ_2 : begin
      end
      active_enumDef_DESC_ANALYSE : begin
      end
      active_enumDef_DATA_RX : begin
      end
      active_enumDef_DATA_RX_ANALYSE : begin
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
        io_phy_tx_stream_payload_last = 1'b1;
      end
      active_enumDef_DATA_TX_0 : begin
      end
      active_enumDef_DATA_TX_1 : begin
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
      end
      active_enumDef_UPDATE_DESC : begin
      end
      active_enumDef_UPDATE_EP : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_phy_tx_stream_payload_fragment = 8'bxxxxxxxx;
    case(dataTx_stateReg)
      dataTx_enumDef_PID : begin
        io_phy_tx_stream_payload_fragment = {(~ dataTx_pid),dataTx_pid};
      end
      dataTx_enumDef_DATA : begin
        io_phy_tx_stream_payload_fragment = dataTx_data_payload_fragment;
      end
      dataTx_enumDef_CRC_0 : begin
        io_phy_tx_stream_payload_fragment = dataTx_crc16_io_result[7 : 0];
      end
      dataTx_enumDef_CRC_1 : begin
        io_phy_tx_stream_payload_fragment = dataTx_crc16_io_result[15 : 8];
      end
      dataTx_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
    case(active_stateReg)
      active_enumDef_IDLE : begin
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
      end
      active_enumDef_EP_READ : begin
      end
      active_enumDef_EP_ANALYSE : begin
      end
      active_enumDef_DESC_READ_0 : begin
      end
      active_enumDef_DESC_READ_1 : begin
      end
      active_enumDef_DESC_READ_2 : begin
      end
      active_enumDef_DESC_ANALYSE : begin
      end
      active_enumDef_DATA_RX : begin
      end
      active_enumDef_DATA_RX_ANALYSE : begin
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
        io_phy_tx_stream_payload_fragment = {(~ active_handshakePid),active_handshakePid};
      end
      active_enumDef_DATA_TX_0 : begin
      end
      active_enumDef_DATA_TX_1 : begin
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
      end
      active_enumDef_UPDATE_DESC : begin
      end
      active_enumDef_UPDATE_EP : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ctrl_readHaltTrigger = 1'b0;
    if(when_BmbSlaveFactory_l71) begin
      if(ctrl_askRead) begin
        case(mapping_readState)
          2'b00 : begin
            ctrl_readHaltTrigger = 1'b1;
          end
          2'b01 : begin
            ctrl_readHaltTrigger = 1'b1;
          end
          default : begin
          end
        endcase
      end
    end
  end

  always @(*) begin
    ctrl_writeHaltTrigger = 1'b0;
    if(when_BmbSlaveFactory_l71) begin
      if(ctrl_askWrite) begin
        case(mapping_writeState)
          1'b0 : begin
            ctrl_writeHaltTrigger = 1'b1;
          end
          default : begin
          end
        endcase
      end
    end
  end

  assign _zz_io_ctrl_rsp_valid = (! (ctrl_readHaltTrigger || ctrl_writeHaltTrigger));
  assign ctrl_rsp_ready = (_zz_ctrl_rsp_ready && _zz_io_ctrl_rsp_valid);
  always @(*) begin
    _zz_ctrl_rsp_ready = io_ctrl_rsp_ready;
    if(when_Stream_l366) begin
      _zz_ctrl_rsp_ready = 1'b1;
    end
  end

  assign when_Stream_l366 = (! _zz_io_ctrl_rsp_valid_1);
  assign _zz_io_ctrl_rsp_valid_1 = _zz_io_ctrl_rsp_valid_2;
  assign io_ctrl_rsp_valid = _zz_io_ctrl_rsp_valid_1;
  assign io_ctrl_rsp_payload_last = _zz_io_ctrl_rsp_payload_last;
  assign io_ctrl_rsp_payload_fragment_opcode = _zz_io_ctrl_rsp_payload_fragment_opcode;
  assign io_ctrl_rsp_payload_fragment_data = _zz_io_ctrl_rsp_payload_fragment_data;
  assign ctrl_askWrite = (io_ctrl_cmd_valid && (io_ctrl_cmd_payload_fragment_opcode == 1'b1));
  assign ctrl_askRead = (io_ctrl_cmd_valid && (io_ctrl_cmd_payload_fragment_opcode == 1'b0));
  assign io_ctrl_cmd_fire = (io_ctrl_cmd_valid && io_ctrl_cmd_ready);
  assign ctrl_doWrite = (io_ctrl_cmd_fire && (io_ctrl_cmd_payload_fragment_opcode == 1'b1));
  assign io_ctrl_cmd_fire_1 = (io_ctrl_cmd_valid && io_ctrl_cmd_ready);
  assign ctrl_doRead = (io_ctrl_cmd_fire_1 && (io_ctrl_cmd_payload_fragment_opcode == 1'b0));
  assign ctrl_rsp_valid = io_ctrl_cmd_valid;
  assign io_ctrl_cmd_ready = ctrl_rsp_ready;
  assign ctrl_rsp_payload_last = 1'b1;
  assign ctrl_rsp_payload_fragment_opcode = 1'b0;
  always @(*) begin
    ctrl_rsp_payload_fragment_data = 32'h0;
    case(io_ctrl_cmd_payload_fragment_address)
      16'hff00 : begin
        ctrl_rsp_payload_fragment_data[10 : 0] = regs_frame;
      end
      16'hff08 : begin
        ctrl_rsp_payload_fragment_data[15 : 0] = regs_interrupts_endpoints;
        ctrl_rsp_payload_fragment_data[16 : 16] = regs_interrupts_reset;
        ctrl_rsp_payload_fragment_data[17 : 17] = regs_interrupts_ep0Setup;
        ctrl_rsp_payload_fragment_data[18 : 18] = regs_interrupts_suspend;
        ctrl_rsp_payload_fragment_data[19 : 19] = regs_interrupts_resume;
        ctrl_rsp_payload_fragment_data[20 : 20] = regs_interrupts_disconnect;
      end
      16'hff0c : begin
        ctrl_rsp_payload_fragment_data[5 : 5] = regs_halt_effective;
      end
      16'hff20 : begin
        ctrl_rsp_payload_fragment_data[3 : 0] = 4'b1100;
      end
      default : begin
      end
    endcase
    if(when_BmbSlaveFactory_l71) begin
      ctrl_rsp_payload_fragment_data[31 : 0] = mapping_readBuffer;
    end
  end

  assign when_UsbDeviceCtrl_l154 = (io_phy_suspend && (! io_phy_suspend_regNext));
  assign when_UsbDeviceCtrl_l156 = ((! io_phy_power) && io_phy_power_regNext);
  assign regs_interrupts_pending = (((((((|regs_interrupts_endpoints) || regs_interrupts_reset) || regs_interrupts_suspend) || regs_interrupts_resume) || regs_interrupts_disconnect) || regs_interrupts_ep0Setup) && regs_interrupts_enable);
  assign io_phy_pullup = regs_pullup;
  assign memory_readPort_rsp = _zz_memory_ram_port0;
  assign memory_internal_readRsp_valid = memory_internal_readCmd_regNext_valid;
  assign memory_internal_readRsp_payload = memory_readPort_rsp;
  always @(*) begin
    memory_internal_readCmd_valid = 1'b0;
    case(active_stateReg)
      active_enumDef_IDLE : begin
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
        if(!when_UsbDeviceCtrl_l379) begin
          case(token_pid)
            4'b0101 : begin
            end
            4'b1101, 4'b0001, 4'b1001 : begin
              if(when_UsbDeviceCtrl_l388) begin
                memory_internal_readCmd_valid = 1'b1;
              end
            end
            default : begin
            end
          endcase
        end
      end
      active_enumDef_EP_READ : begin
      end
      active_enumDef_EP_ANALYSE : begin
        memory_internal_readCmd_valid = 1'b1;
      end
      active_enumDef_DESC_READ_0 : begin
        memory_internal_readCmd_valid = 1'b1;
      end
      active_enumDef_DESC_READ_1 : begin
        memory_internal_readCmd_valid = 1'b1;
      end
      active_enumDef_DESC_READ_2 : begin
      end
      active_enumDef_DESC_ANALYSE : begin
      end
      active_enumDef_DATA_RX : begin
      end
      active_enumDef_DATA_RX_ANALYSE : begin
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
      end
      active_enumDef_DATA_TX_0 : begin
        if(when_UsbDeviceCtrl_l497) begin
          if(dataTx_input_ready) begin
            memory_internal_readCmd_valid = 1'b1;
          end
        end
      end
      active_enumDef_DATA_TX_1 : begin
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
        memory_internal_readCmd_valid = 1'b1;
      end
      active_enumDef_UPDATE_DESC : begin
      end
      active_enumDef_UPDATE_EP : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    memory_internal_readCmd_payload = 10'bxxxxxxxxxx;
    case(active_stateReg)
      active_enumDef_IDLE : begin
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
        if(!when_UsbDeviceCtrl_l379) begin
          case(token_pid)
            4'b0101 : begin
            end
            4'b1101, 4'b0001, 4'b1001 : begin
              if(when_UsbDeviceCtrl_l388) begin
                memory_internal_readCmd_payload = (_zz_memory_internal_readCmd_payload >>> 2);
              end
            end
            default : begin
            end
          endcase
        end
      end
      active_enumDef_EP_READ : begin
      end
      active_enumDef_EP_ANALYSE : begin
        memory_internal_readCmd_payload = (ep_headByte >>> 2);
      end
      active_enumDef_DESC_READ_0 : begin
        memory_internal_readCmd_payload = ((ep_headByte | 12'h004) >>> 2);
      end
      active_enumDef_DESC_READ_1 : begin
        memory_internal_readCmd_payload = ((ep_headByte | 12'h008) >>> 2);
      end
      active_enumDef_DESC_READ_2 : begin
      end
      active_enumDef_DESC_ANALYSE : begin
      end
      active_enumDef_DATA_RX : begin
      end
      active_enumDef_DATA_RX_ANALYSE : begin
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
      end
      active_enumDef_DATA_TX_0 : begin
        if(when_UsbDeviceCtrl_l497) begin
          if(dataTx_input_ready) begin
            memory_internal_readCmd_payload = (desc_currentByte >>> 2);
          end
        end
      end
      active_enumDef_DATA_TX_1 : begin
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
        memory_internal_readCmd_payload = ((ep_headByte | 12'h004) >>> 2);
      end
      active_enumDef_UPDATE_DESC : begin
      end
      active_enumDef_UPDATE_EP : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    memory_internal_writeCmd_valid = 1'b0;
    case(active_stateReg)
      active_enumDef_IDLE : begin
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
      end
      active_enumDef_EP_READ : begin
      end
      active_enumDef_EP_ANALYSE : begin
      end
      active_enumDef_DESC_READ_0 : begin
      end
      active_enumDef_DESC_READ_1 : begin
      end
      active_enumDef_DESC_READ_2 : begin
      end
      active_enumDef_DESC_ANALYSE : begin
      end
      active_enumDef_DATA_RX : begin
        if(dataRx_data_valid) begin
          memory_internal_writeCmd_valid = ((! transferFull) && (! active_noUpdate));
        end
      end
      active_enumDef_DATA_RX_ANALYSE : begin
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
      end
      active_enumDef_DATA_TX_0 : begin
      end
      active_enumDef_DATA_TX_1 : begin
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
      end
      active_enumDef_UPDATE_DESC : begin
        memory_internal_writeCmd_valid = (! token_isSetup);
      end
      active_enumDef_UPDATE_EP : begin
        memory_internal_writeCmd_valid = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    memory_internal_writeCmd_payload_address = 10'bxxxxxxxxxx;
    case(active_stateReg)
      active_enumDef_IDLE : begin
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
      end
      active_enumDef_EP_READ : begin
      end
      active_enumDef_EP_ANALYSE : begin
      end
      active_enumDef_DESC_READ_0 : begin
      end
      active_enumDef_DESC_READ_1 : begin
      end
      active_enumDef_DESC_READ_2 : begin
      end
      active_enumDef_DESC_ANALYSE : begin
      end
      active_enumDef_DATA_RX : begin
        if(dataRx_data_valid) begin
          memory_internal_writeCmd_payload_address = (desc_currentByte >>> 2);
        end
      end
      active_enumDef_DATA_RX_ANALYSE : begin
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
      end
      active_enumDef_DATA_TX_0 : begin
      end
      active_enumDef_DATA_TX_1 : begin
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
      end
      active_enumDef_UPDATE_DESC : begin
        memory_internal_writeCmd_payload_address = ({2'd0,ep_head} <<< 2);
      end
      active_enumDef_UPDATE_EP : begin
        memory_internal_writeCmd_payload_address = {6'd0, token_endpoint};
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    memory_internal_writeCmd_payload_data = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    case(active_stateReg)
      active_enumDef_IDLE : begin
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
      end
      active_enumDef_EP_READ : begin
      end
      active_enumDef_EP_ANALYSE : begin
      end
      active_enumDef_DESC_READ_0 : begin
      end
      active_enumDef_DESC_READ_1 : begin
      end
      active_enumDef_DESC_READ_2 : begin
      end
      active_enumDef_DESC_ANALYSE : begin
      end
      active_enumDef_DATA_RX : begin
        if(dataRx_data_valid) begin
          memory_internal_writeCmd_payload_data[7 : 0] = dataRx_data_payload;
          memory_internal_writeCmd_payload_data[15 : 8] = dataRx_data_payload;
          memory_internal_writeCmd_payload_data[23 : 16] = dataRx_data_payload;
          memory_internal_writeCmd_payload_data[31 : 24] = dataRx_data_payload;
        end
      end
      active_enumDef_DATA_RX_ANALYSE : begin
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
      end
      active_enumDef_DATA_TX_0 : begin
      end
      active_enumDef_DATA_TX_1 : begin
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
      end
      active_enumDef_UPDATE_DESC : begin
        memory_internal_writeCmd_payload_data = 32'h0;
        memory_internal_writeCmd_payload_data[12 : 0] = desc_offset;
        memory_internal_writeCmd_payload_data[19 : 16] = (active_completion ? 4'b0000 : 4'b1111);
      end
      active_enumDef_UPDATE_EP : begin
        memory_internal_writeCmd_payload_data[3 : 0] = {(! ep_dataPhase),{ep_nack,{ep_stall,ep_enable}}};
        memory_internal_writeCmd_payload_data[15 : 4] = {4'd0, _zz_memory_internal_writeCmd_payload_data};
        if(token_isSetup) begin
          memory_internal_writeCmd_payload_data[1] = 1'b0;
          memory_internal_writeCmd_payload_data[15 : 4] = 12'h0;
        end
        if(active_completion) begin
          if(desc_data1OnCompletion) begin
            memory_internal_writeCmd_payload_data[3] = 1'b1;
          end
          if(when_UsbDeviceCtrl_l658) begin
            memory_internal_writeCmd_payload_data[15 : 4] = 12'h0;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    memory_internal_writeCmd_payload_mask = 4'bxxxx;
    case(active_stateReg)
      active_enumDef_IDLE : begin
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
      end
      active_enumDef_EP_READ : begin
      end
      active_enumDef_EP_ANALYSE : begin
      end
      active_enumDef_DESC_READ_0 : begin
      end
      active_enumDef_DESC_READ_1 : begin
      end
      active_enumDef_DESC_READ_2 : begin
      end
      active_enumDef_DESC_ANALYSE : begin
      end
      active_enumDef_DATA_RX : begin
        if(dataRx_data_valid) begin
          memory_internal_writeCmd_payload_mask = _zz_memory_internal_writeCmd_payload_mask_1;
        end
      end
      active_enumDef_DATA_RX_ANALYSE : begin
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
      end
      active_enumDef_DATA_TX_0 : begin
      end
      active_enumDef_DATA_TX_1 : begin
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
      end
      active_enumDef_UPDATE_DESC : begin
        memory_internal_writeCmd_payload_mask = 4'b1111;
      end
      active_enumDef_UPDATE_EP : begin
        memory_internal_writeCmd_payload_mask = 4'b0011;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    memory_external_halt = 1'b0;
    case(active_stateReg)
      active_enumDef_IDLE : begin
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
      end
      active_enumDef_EP_READ : begin
      end
      active_enumDef_EP_ANALYSE : begin
      end
      active_enumDef_DESC_READ_0 : begin
      end
      active_enumDef_DESC_READ_1 : begin
      end
      active_enumDef_DESC_READ_2 : begin
      end
      active_enumDef_DESC_ANALYSE : begin
      end
      active_enumDef_DATA_RX : begin
      end
      active_enumDef_DATA_RX_ANALYSE : begin
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
      end
      active_enumDef_DATA_TX_0 : begin
      end
      active_enumDef_DATA_TX_1 : begin
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
        memory_external_halt = 1'b1;
      end
      active_enumDef_UPDATE_DESC : begin
        memory_external_halt = 1'b1;
      end
      active_enumDef_UPDATE_EP : begin
        memory_external_halt = 1'b1;
      end
      default : begin
      end
    endcase
  end

  assign memory_external_readCmd_fire = (memory_external_readCmd_valid && memory_external_readCmd_ready);
  assign memory_external_readRsp_valid = _zz_memory_external_readRsp_valid;
  assign memory_external_readRsp_payload = memory_readPort_rsp;
  assign _zz_memory_external_writeCmd_ready = (! memory_external_halt);
  assign memory_external_writeCmdHalted_valid = (memory_external_writeCmd_valid && _zz_memory_external_writeCmd_ready);
  assign memory_external_writeCmd_ready = (memory_external_writeCmdHalted_ready && _zz_memory_external_writeCmd_ready);
  assign memory_external_writeCmdHalted_payload_address = memory_external_writeCmd_payload_address;
  assign memory_external_writeCmdHalted_payload_data = memory_external_writeCmd_payload_data;
  assign memory_external_writeCmdHalted_payload_mask = memory_external_writeCmd_payload_mask;
  assign memory_readPort_cmd_valid = (memory_internal_readCmd_valid || memory_external_readCmd_valid);
  assign memory_readPort_cmd_payload = (memory_internal_readCmd_valid ? memory_internal_readCmd_payload : memory_external_readCmd_payload);
  assign memory_external_readCmd_ready = (! memory_internal_readCmd_valid);
  assign memory_writePort_valid = (memory_internal_writeCmd_valid || memory_external_writeCmdHalted_valid);
  assign memory_writePort_payload_address = (memory_internal_writeCmd_valid ? memory_internal_writeCmd_payload_address : memory_external_writeCmdHalted_payload_address);
  assign memory_writePort_payload_data = (memory_internal_writeCmd_valid ? memory_internal_writeCmd_payload_data : memory_external_writeCmdHalted_payload_data);
  assign memory_writePort_payload_mask = (memory_internal_writeCmd_valid ? memory_internal_writeCmd_payload_mask : memory_external_writeCmdHalted_payload_mask);
  assign memory_external_writeCmdHalted_ready = (! memory_internal_writeCmd_valid);
  always @(*) begin
    rxTimer_clear = 1'b0;
    if(io_phy_rx_active) begin
      rxTimer_clear = 1'b1;
    end
    if(when_StateMachine_l238) begin
      rxTimer_clear = 1'b1;
    end
    if(when_StateMachine_l222) begin
      rxTimer_clear = 1'b1;
    end
    if(when_StateMachine_l238_3) begin
      rxTimer_clear = 1'b1;
    end
  end

  assign rxTimer_timeout = (rxTimer_counter == 5'h17);
  assign rxTimer_turnover = (rxTimer_counter == 5'h01);
  always @(*) begin
    token_wantExit = 1'b0;
    case(token_stateReg)
      token_enumDef_PID : begin
      end
      token_enumDef_DATA_0 : begin
      end
      token_enumDef_DATA_1 : begin
      end
      token_enumDef_CHECK : begin
        if(when_Misc_l229) begin
          token_wantExit = 1'b1;
        end
      end
      token_enumDef_ERROR : begin
        if(when_Misc_l241) begin
          token_wantExit = 1'b1;
        end
      end
      default : begin
      end
    endcase
    if(when_Misc_l247) begin
      if(rxTimer_timeout) begin
        token_wantExit = 1'b1;
      end
    end
  end

  always @(*) begin
    token_wantStart = 1'b0;
    if(when_StateMachine_l238_1) begin
      token_wantStart = 1'b1;
    end
  end

  assign token_wantKill = 1'b0;
  assign token_address = token_data[6 : 0];
  assign token_endpoint = token_data[10 : 7];
  always @(*) begin
    token_crc5_io_flush = 1'b0;
    if(when_StateMachine_l222) begin
      token_crc5_io_flush = 1'b1;
    end
  end

  always @(*) begin
    token_crc5_io_input_valid = 1'b0;
    case(token_stateReg)
      token_enumDef_PID : begin
      end
      token_enumDef_DATA_0 : begin
        if(io_phy_rx_flow_valid) begin
          token_crc5_io_input_valid = 1'b1;
        end
      end
      token_enumDef_DATA_1 : begin
        if(io_phy_rx_flow_valid) begin
          token_crc5_io_input_valid = 1'b1;
        end
      end
      token_enumDef_CHECK : begin
      end
      token_enumDef_ERROR : begin
      end
      default : begin
      end
    endcase
  end

  assign token_isSetup = (token_pid == 4'b1101);
  assign token_isIn = (token_pid == 4'b1001);
  assign regs_halt_hit = (regs_halt_enable && (regs_halt_id == token_endpoint));
  always @(*) begin
    dataRx_wantExit = 1'b0;
    case(dataRx_stateReg)
      dataRx_enumDef_IDLE : begin
        if(!io_phy_rx_active) begin
          if(rxTimer_timeout) begin
            dataRx_wantExit = 1'b1;
          end
        end
      end
      dataRx_enumDef_PID : begin
        if(!io_phy_rx_flow_valid) begin
          if(when_Misc_l64) begin
            dataRx_wantExit = 1'b1;
          end
        end
      end
      dataRx_enumDef_DATA : begin
        if(when_Misc_l70) begin
          dataRx_wantExit = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataRx_wantStart = 1'b0;
    case(active_stateReg)
      active_enumDef_IDLE : begin
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
        if(!when_UsbDeviceCtrl_l379) begin
          case(token_pid)
            4'b0101 : begin
            end
            4'b1101, 4'b0001, 4'b1001 : begin
              if(when_UsbDeviceCtrl_l388) begin
                if(when_UsbDeviceCtrl_l390) begin
                  dataRx_wantStart = 1'b1;
                end
              end
            end
            default : begin
            end
          endcase
        end
      end
      active_enumDef_EP_READ : begin
      end
      active_enumDef_EP_ANALYSE : begin
      end
      active_enumDef_DESC_READ_0 : begin
      end
      active_enumDef_DESC_READ_1 : begin
      end
      active_enumDef_DESC_READ_2 : begin
      end
      active_enumDef_DESC_ANALYSE : begin
      end
      active_enumDef_DATA_RX : begin
      end
      active_enumDef_DATA_RX_ANALYSE : begin
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
      end
      active_enumDef_DATA_TX_0 : begin
      end
      active_enumDef_DATA_TX_1 : begin
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
      end
      active_enumDef_UPDATE_DESC : begin
      end
      active_enumDef_UPDATE_EP : begin
      end
      default : begin
      end
    endcase
  end

  assign dataRx_wantKill = 1'b0;
  assign dataRx_history_0 = _zz_dataRx_history_0;
  assign dataRx_history_1 = _zz_dataRx_history_1;
  assign dataRx_hasError = ({dataRx_crcError,{dataRx_pidError,{dataRx_stuffingError,dataRx_notResponding}}} != 4'b0000);
  always @(*) begin
    dataRx_data_valid = 1'b0;
    case(dataRx_stateReg)
      dataRx_enumDef_IDLE : begin
      end
      dataRx_enumDef_PID : begin
      end
      dataRx_enumDef_DATA : begin
        if(!when_Misc_l70) begin
          if(io_phy_rx_flow_valid) begin
            if(when_Misc_l78) begin
              dataRx_data_valid = 1'b1;
            end
          end
        end
      end
      default : begin
      end
    endcase
  end

  assign dataRx_data_payload = dataRx_history_1;
  always @(*) begin
    dataRx_crc16_io_input_valid = 1'b0;
    case(dataRx_stateReg)
      dataRx_enumDef_IDLE : begin
      end
      dataRx_enumDef_PID : begin
      end
      dataRx_enumDef_DATA : begin
        if(!when_Misc_l70) begin
          if(io_phy_rx_flow_valid) begin
            dataRx_crc16_io_input_valid = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataRx_crc16_io_flush = 1'b0;
    case(dataRx_stateReg)
      dataRx_enumDef_IDLE : begin
      end
      dataRx_enumDef_PID : begin
        dataRx_crc16_io_flush = 1'b1;
      end
      dataRx_enumDef_DATA : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataTx_wantExit = 1'b0;
    case(dataTx_stateReg)
      dataTx_enumDef_PID : begin
      end
      dataTx_enumDef_DATA : begin
      end
      dataTx_enumDef_CRC_0 : begin
      end
      dataTx_enumDef_CRC_1 : begin
      end
      dataTx_enumDef_EOP : begin
        if(io_phy_tx_eop) begin
          dataTx_wantExit = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataTx_wantStart = 1'b0;
    if(when_UsbDeviceCtrl_l281) begin
      dataTx_wantStart = 1'b1;
    end
  end

  assign dataTx_wantKill = 1'b0;
  always @(*) begin
    dataTx_pid = 4'bxxxx;
    dataTx_pid = {ep_dataPhase,3'b011};
  end

  always @(*) begin
    dataTx_data_ready = 1'b0;
    case(dataTx_stateReg)
      dataTx_enumDef_PID : begin
      end
      dataTx_enumDef_DATA : begin
        if(io_phy_tx_stream_ready) begin
          dataTx_data_ready = 1'b1;
        end
      end
      dataTx_enumDef_CRC_0 : begin
      end
      dataTx_enumDef_CRC_1 : begin
      end
      dataTx_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
  end

  assign dataTx_data_fire = (dataTx_data_valid && dataTx_data_ready);
  always @(*) begin
    dataTx_crc16_io_flush = 1'b0;
    case(dataTx_stateReg)
      dataTx_enumDef_PID : begin
        dataTx_crc16_io_flush = 1'b1;
      end
      dataTx_enumDef_DATA : begin
      end
      dataTx_enumDef_CRC_0 : begin
      end
      dataTx_enumDef_CRC_1 : begin
      end
      dataTx_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataTx_startNull = 1'b0;
    case(active_stateReg)
      active_enumDef_IDLE : begin
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
      end
      active_enumDef_EP_READ : begin
      end
      active_enumDef_EP_ANALYSE : begin
      end
      active_enumDef_DESC_READ_0 : begin
      end
      active_enumDef_DESC_READ_1 : begin
      end
      active_enumDef_DESC_READ_2 : begin
      end
      active_enumDef_DESC_ANALYSE : begin
        case(token_pid)
          4'b1101 : begin
          end
          4'b0001 : begin
          end
          4'b1001 : begin
            if(!when_UsbDeviceCtrl_l478) begin
              if(desc_full) begin
                dataTx_startNull = 1'b1;
              end
            end
          end
          default : begin
          end
        endcase
      end
      active_enumDef_DATA_RX : begin
      end
      active_enumDef_DATA_RX_ANALYSE : begin
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
      end
      active_enumDef_DATA_TX_0 : begin
      end
      active_enumDef_DATA_TX_1 : begin
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
      end
      active_enumDef_UPDATE_DESC : begin
      end
      active_enumDef_UPDATE_EP : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataTx_input_valid = 1'b0;
    case(active_stateReg)
      active_enumDef_IDLE : begin
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
      end
      active_enumDef_EP_READ : begin
      end
      active_enumDef_EP_ANALYSE : begin
      end
      active_enumDef_DESC_READ_0 : begin
      end
      active_enumDef_DESC_READ_1 : begin
      end
      active_enumDef_DESC_READ_2 : begin
      end
      active_enumDef_DESC_ANALYSE : begin
      end
      active_enumDef_DATA_RX : begin
      end
      active_enumDef_DATA_RX_ANALYSE : begin
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
      end
      active_enumDef_DATA_TX_0 : begin
      end
      active_enumDef_DATA_TX_1 : begin
        dataTx_input_valid = 1'b1;
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
      end
      active_enumDef_UPDATE_DESC : begin
      end
      active_enumDef_UPDATE_EP : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataTx_input_payload_last = 1'bx;
    case(active_stateReg)
      active_enumDef_IDLE : begin
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
      end
      active_enumDef_EP_READ : begin
      end
      active_enumDef_EP_ANALYSE : begin
      end
      active_enumDef_DESC_READ_0 : begin
      end
      active_enumDef_DESC_READ_1 : begin
      end
      active_enumDef_DESC_READ_2 : begin
      end
      active_enumDef_DESC_ANALYSE : begin
      end
      active_enumDef_DATA_RX : begin
      end
      active_enumDef_DATA_RX_ANALYSE : begin
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
      end
      active_enumDef_DATA_TX_0 : begin
      end
      active_enumDef_DATA_TX_1 : begin
        dataTx_input_payload_last = transferFull;
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
      end
      active_enumDef_UPDATE_DESC : begin
      end
      active_enumDef_UPDATE_EP : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataTx_input_payload_fragment = 8'bxxxxxxxx;
    case(active_stateReg)
      active_enumDef_IDLE : begin
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
      end
      active_enumDef_EP_READ : begin
      end
      active_enumDef_EP_ANALYSE : begin
      end
      active_enumDef_DESC_READ_0 : begin
      end
      active_enumDef_DESC_READ_1 : begin
      end
      active_enumDef_DESC_READ_2 : begin
      end
      active_enumDef_DESC_ANALYSE : begin
      end
      active_enumDef_DATA_RX : begin
      end
      active_enumDef_DATA_RX_ANALYSE : begin
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
      end
      active_enumDef_DATA_TX_0 : begin
      end
      active_enumDef_DATA_TX_1 : begin
        dataTx_input_payload_fragment = _zz_dataTx_input_payload_fragment;
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
      end
      active_enumDef_UPDATE_DESC : begin
      end
      active_enumDef_UPDATE_EP : begin
      end
      default : begin
      end
    endcase
  end

  assign dataTx_input_halfPipe_fire = (dataTx_input_halfPipe_valid && dataTx_input_halfPipe_ready);
  assign dataTx_input_ready = (! dataTx_input_rValid);
  assign dataTx_input_halfPipe_valid = dataTx_input_rValid;
  assign dataTx_input_halfPipe_payload_last = dataTx_input_rData_last;
  assign dataTx_input_halfPipe_payload_fragment = dataTx_input_rData_fragment;
  always @(*) begin
    dataTx_input_halfPipe_ready = dataTx_input_halfPipe_m2sPipe_ready;
    if(when_Stream_l366_1) begin
      dataTx_input_halfPipe_ready = 1'b1;
    end
  end

  assign when_Stream_l366_1 = (! dataTx_input_halfPipe_m2sPipe_valid);
  assign dataTx_input_halfPipe_m2sPipe_valid = dataTx_input_halfPipe_rValid;
  assign dataTx_input_halfPipe_m2sPipe_payload_last = dataTx_input_halfPipe_rData_last;
  assign dataTx_input_halfPipe_m2sPipe_payload_fragment = dataTx_input_halfPipe_rData_fragment;
  assign dataTx_data_valid = dataTx_input_halfPipe_m2sPipe_valid;
  assign dataTx_input_halfPipe_m2sPipe_ready = dataTx_data_ready;
  assign dataTx_data_payload_last = dataTx_input_halfPipe_m2sPipe_payload_last;
  assign dataTx_data_payload_fragment = dataTx_input_halfPipe_m2sPipe_payload_fragment;
  assign when_UsbDeviceCtrl_l281 = ((dataTx_data_valid && (dataTx_stateReg == dataTx_enumDef_BOOT)) || dataTx_startNull);
  assign ep_head = ep_word[11 : 4];
  assign ep_enable = ep_word[0];
  assign ep_stall = ep_word[1];
  assign ep_nack = ep_word[2];
  assign ep_dataPhase = ep_word[3];
  assign ep_isochronous = ep_word[16];
  assign ep_maxPacketSize = ep_word[31 : 22];
  assign ep_headByte = ({4'd0,ep_head} <<< 4);
  assign desc_offset = desc_words_0[12 : 0];
  assign desc_code = desc_words_0[19 : 16];
  assign desc_next = desc_words_1[11 : 4];
  assign desc_length = desc_words_1[28 : 16];
  assign desc_direction = desc_words_2[16];
  assign desc_interrupt = desc_words_2[17];
  assign desc_completionOnFull = desc_words_2[18];
  assign desc_data1OnCompletion = desc_words_2[19];
  assign desc_frame = desc_words_2[11 : 0];
  always @(*) begin
    desc_offsetIncrement = 1'b0;
    case(active_stateReg)
      active_enumDef_IDLE : begin
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
      end
      active_enumDef_EP_READ : begin
      end
      active_enumDef_EP_ANALYSE : begin
      end
      active_enumDef_DESC_READ_0 : begin
      end
      active_enumDef_DESC_READ_1 : begin
      end
      active_enumDef_DESC_READ_2 : begin
      end
      active_enumDef_DESC_ANALYSE : begin
      end
      active_enumDef_DATA_RX : begin
        if(dataRx_data_valid) begin
          if(!when_UsbDeviceCtrl_l556) begin
            desc_offsetIncrement = 1'b1;
          end
        end
      end
      active_enumDef_DATA_RX_ANALYSE : begin
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
      end
      active_enumDef_DATA_TX_0 : begin
        if(when_UsbDeviceCtrl_l497) begin
          if(dataTx_input_ready) begin
            desc_offsetIncrement = 1'b1;
          end
        end
      end
      active_enumDef_DATA_TX_1 : begin
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
      end
      active_enumDef_UPDATE_DESC : begin
      end
      active_enumDef_UPDATE_EP : begin
      end
      default : begin
      end
    endcase
  end

  assign desc_currentByte = _zz_desc_currentByte[11:0];
  assign desc_full = (desc_offset == desc_length);
  assign desc_dataPhaseMatch = (ep_dataPhase ? (dataRx_pid == 4'b1011) : (dataRx_pid == 4'b0011));
  always @(*) begin
    byteCounter_clear = 1'b0;
    case(active_stateReg)
      active_enumDef_IDLE : begin
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
      end
      active_enumDef_EP_READ : begin
      end
      active_enumDef_EP_ANALYSE : begin
      end
      active_enumDef_DESC_READ_0 : begin
      end
      active_enumDef_DESC_READ_1 : begin
      end
      active_enumDef_DESC_READ_2 : begin
      end
      active_enumDef_DESC_ANALYSE : begin
        byteCounter_clear = 1'b1;
      end
      active_enumDef_DATA_RX : begin
      end
      active_enumDef_DATA_RX_ANALYSE : begin
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
      end
      active_enumDef_DATA_TX_0 : begin
      end
      active_enumDef_DATA_TX_1 : begin
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
      end
      active_enumDef_UPDATE_DESC : begin
      end
      active_enumDef_UPDATE_EP : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    byteCounter_increment = 1'b0;
    case(active_stateReg)
      active_enumDef_IDLE : begin
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
      end
      active_enumDef_EP_READ : begin
      end
      active_enumDef_EP_ANALYSE : begin
      end
      active_enumDef_DESC_READ_0 : begin
      end
      active_enumDef_DESC_READ_1 : begin
      end
      active_enumDef_DESC_READ_2 : begin
      end
      active_enumDef_DESC_ANALYSE : begin
      end
      active_enumDef_DATA_RX : begin
        if(dataRx_data_valid) begin
          if(!when_UsbDeviceCtrl_l556) begin
            byteCounter_increment = 1'b1;
          end
        end
      end
      active_enumDef_DATA_RX_ANALYSE : begin
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
      end
      active_enumDef_DATA_TX_0 : begin
        if(when_UsbDeviceCtrl_l497) begin
          if(dataTx_input_ready) begin
            byteCounter_increment = 1'b1;
          end
        end
      end
      active_enumDef_DATA_TX_1 : begin
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
      end
      active_enumDef_UPDATE_DESC : begin
      end
      active_enumDef_UPDATE_EP : begin
      end
      default : begin
      end
    endcase
  end

  assign byteCounter_full = (byteCounter_value == ep_maxPacketSize);
  assign transferFull = (desc_full || byteCounter_full);
  assign active_wantExit = 1'b0;
  always @(*) begin
    active_wantStart = 1'b0;
    if(when_StateMachine_l238_5) begin
      active_wantStart = 1'b1;
    end
  end

  assign active_wantKill = 1'b0;
  assign when_UsbDeviceCtrl_l363 = ((((active_stateReg == active_enumDef_BOOT) || (active_stateReg == active_enumDef_IDLE)) || (active_stateReg == active_enumDef_TOKEN)) || (! regs_halt_hit));
  assign main_wantExit = 1'b0;
  always @(*) begin
    main_wantStart = 1'b0;
    case(main_stateReg)
      main_enumDef_ATTACHED : begin
      end
      main_enumDef_POWERED : begin
      end
      main_enumDef_ACTIVE_INIT : begin
      end
      main_enumDef_ACTIVE : begin
      end
      default : begin
        main_wantStart = 1'b1;
      end
    endcase
  end

  assign main_wantKill = 1'b0;
  always @(*) begin
    when_BusSlaveFactory_l335 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      16'hff08 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l341 = _zz_when_BusSlaveFactory_l341[0];
  assign when_BusSlaveFactory_l341_1 = _zz_when_BusSlaveFactory_l341[1];
  assign when_BusSlaveFactory_l341_2 = _zz_when_BusSlaveFactory_l341[2];
  assign when_BusSlaveFactory_l341_3 = _zz_when_BusSlaveFactory_l341[3];
  assign when_BusSlaveFactory_l341_4 = _zz_when_BusSlaveFactory_l341[4];
  assign when_BusSlaveFactory_l341_5 = _zz_when_BusSlaveFactory_l341[5];
  assign when_BusSlaveFactory_l341_6 = _zz_when_BusSlaveFactory_l341[6];
  assign when_BusSlaveFactory_l341_7 = _zz_when_BusSlaveFactory_l341[7];
  assign when_BusSlaveFactory_l341_8 = _zz_when_BusSlaveFactory_l341[8];
  assign when_BusSlaveFactory_l341_9 = _zz_when_BusSlaveFactory_l341[9];
  assign when_BusSlaveFactory_l341_10 = _zz_when_BusSlaveFactory_l341[10];
  assign when_BusSlaveFactory_l341_11 = _zz_when_BusSlaveFactory_l341[11];
  assign when_BusSlaveFactory_l341_12 = _zz_when_BusSlaveFactory_l341[12];
  assign when_BusSlaveFactory_l341_13 = _zz_when_BusSlaveFactory_l341[13];
  assign when_BusSlaveFactory_l341_14 = _zz_when_BusSlaveFactory_l341[14];
  assign when_BusSlaveFactory_l341_15 = _zz_when_BusSlaveFactory_l341[15];
  always @(*) begin
    when_BusSlaveFactory_l335_1 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      16'hff08 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_1 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l341_16 = io_ctrl_cmd_payload_fragment_data[16];
  always @(*) begin
    when_BusSlaveFactory_l335_2 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      16'hff08 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_2 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l341_17 = io_ctrl_cmd_payload_fragment_data[17];
  always @(*) begin
    when_BusSlaveFactory_l335_3 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      16'hff08 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_3 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l341_18 = io_ctrl_cmd_payload_fragment_data[18];
  always @(*) begin
    when_BusSlaveFactory_l335_4 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      16'hff08 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_4 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l341_19 = io_ctrl_cmd_payload_fragment_data[19];
  always @(*) begin
    when_BusSlaveFactory_l335_5 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      16'hff08 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_5 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l341_20 = io_ctrl_cmd_payload_fragment_data[20];
  always @(*) begin
    when_BusSlaveFactory_l371 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      16'hff10 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l371 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l373 = io_ctrl_cmd_payload_fragment_data[0];
  always @(*) begin
    when_BusSlaveFactory_l335_6 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      16'hff10 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_6 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l341_21 = io_ctrl_cmd_payload_fragment_data[1];
  always @(*) begin
    when_BusSlaveFactory_l371_1 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      16'hff10 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l371_1 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l373_1 = io_ctrl_cmd_payload_fragment_data[2];
  always @(*) begin
    when_BusSlaveFactory_l335_7 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      16'hff10 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_7 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l341_22 = io_ctrl_cmd_payload_fragment_data[3];
  always @(*) begin
    memory_external_readCmd_valid = 1'b0;
    if(when_BmbSlaveFactory_l71) begin
      if(ctrl_askRead) begin
        case(mapping_readState)
          2'b00 : begin
            memory_external_readCmd_valid = 1'b1;
          end
          default : begin
          end
        endcase
      end
    end
  end

  assign memory_external_readCmd_payload = _zz_memory_external_readCmd_payload[9:0];
  always @(*) begin
    memory_external_writeCmd_valid = 1'b0;
    if(when_BmbSlaveFactory_l71) begin
      if(ctrl_askWrite) begin
        case(mapping_writeState)
          1'b0 : begin
            memory_external_writeCmd_valid = 1'b1;
          end
          default : begin
          end
        endcase
      end
    end
  end

  assign memory_external_writeCmd_payload_address = _zz_memory_external_writeCmd_payload_address[9:0];
  assign memory_external_writeCmd_payload_mask = 4'b1111;
  assign io_interrupt = regs_interrupts_pending_regNext;
  assign _zz_when_BusSlaveFactory_l341 = io_ctrl_cmd_payload_fragment_data[15 : 0];
  assign memory_external_writeCmd_payload_data = io_ctrl_cmd_payload_fragment_data[31 : 0];
  assign when_BusSlaveFactory_l962 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l962_1 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l962_2 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l962_3 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l962_4 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l962_5 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BmbSlaveFactory_l71 = ((io_ctrl_cmd_payload_fragment_address & 16'h8000) == 16'h0);
  always @(*) begin
    dataRx_stateNext = dataRx_stateReg;
    case(dataRx_stateReg)
      dataRx_enumDef_IDLE : begin
        if(io_phy_rx_active) begin
          dataRx_stateNext = dataRx_enumDef_PID;
        end else begin
          if(rxTimer_timeout) begin
            dataRx_stateNext = dataRx_enumDef_BOOT;
          end
        end
      end
      dataRx_enumDef_PID : begin
        if(io_phy_rx_flow_valid) begin
          dataRx_stateNext = dataRx_enumDef_DATA;
        end else begin
          if(when_Misc_l64) begin
            dataRx_stateNext = dataRx_enumDef_BOOT;
          end
        end
      end
      dataRx_enumDef_DATA : begin
        if(when_Misc_l70) begin
          dataRx_stateNext = dataRx_enumDef_BOOT;
        end
      end
      default : begin
      end
    endcase
    if(dataRx_wantStart) begin
      dataRx_stateNext = dataRx_enumDef_IDLE;
    end
    if(dataRx_wantKill) begin
      dataRx_stateNext = dataRx_enumDef_BOOT;
    end
  end

  assign when_Misc_l64 = (! io_phy_rx_active);
  assign when_Misc_l70 = (! io_phy_rx_active);
  assign when_Misc_l71 = ((! (&dataRx_valids)) || (dataRx_crc16_io_result != 16'h800d));
  assign when_Misc_l78 = (&dataRx_valids);
  assign when_StateMachine_l238 = ((! (dataRx_stateReg == dataRx_enumDef_IDLE)) && (dataRx_stateNext == dataRx_enumDef_IDLE));
  assign when_Misc_l85 = (! (dataRx_stateReg == dataRx_enumDef_BOOT));
  always @(*) begin
    dataTx_stateNext = dataTx_stateReg;
    case(dataTx_stateReg)
      dataTx_enumDef_PID : begin
        if(io_phy_tx_stream_ready) begin
          if(dataTx_data_valid) begin
            dataTx_stateNext = dataTx_enumDef_DATA;
          end else begin
            dataTx_stateNext = dataTx_enumDef_CRC_0;
          end
        end
      end
      dataTx_enumDef_DATA : begin
        if(io_phy_tx_stream_ready) begin
          if(dataTx_data_payload_last) begin
            dataTx_stateNext = dataTx_enumDef_CRC_0;
          end
        end
      end
      dataTx_enumDef_CRC_0 : begin
        if(io_phy_tx_stream_ready) begin
          dataTx_stateNext = dataTx_enumDef_CRC_1;
        end
      end
      dataTx_enumDef_CRC_1 : begin
        if(io_phy_tx_stream_ready) begin
          dataTx_stateNext = dataTx_enumDef_EOP;
        end
      end
      dataTx_enumDef_EOP : begin
        if(io_phy_tx_eop) begin
          dataTx_stateNext = dataTx_enumDef_BOOT;
        end
      end
      default : begin
      end
    endcase
    if(dataTx_wantStart) begin
      dataTx_stateNext = dataTx_enumDef_PID;
    end
    if(dataTx_wantKill) begin
      dataTx_stateNext = dataTx_enumDef_BOOT;
    end
  end

  always @(*) begin
    token_stateNext = token_stateReg;
    case(token_stateReg)
      token_enumDef_PID : begin
        if(io_phy_rx_flow_valid) begin
          if(when_Misc_l204) begin
            token_stateNext = token_enumDef_DATA_0;
          end else begin
            token_stateNext = token_enumDef_ERROR;
          end
        end
      end
      token_enumDef_DATA_0 : begin
        if(io_phy_rx_flow_valid) begin
          token_stateNext = token_enumDef_DATA_1;
        end
      end
      token_enumDef_DATA_1 : begin
        if(io_phy_rx_flow_valid) begin
          token_stateNext = token_enumDef_CHECK;
        end
      end
      token_enumDef_CHECK : begin
        if(when_Misc_l229) begin
          token_stateNext = token_enumDef_BOOT;
        end
        if(io_phy_rx_flow_valid) begin
          token_stateNext = token_enumDef_ERROR;
        end
      end
      token_enumDef_ERROR : begin
        if(when_Misc_l241) begin
          token_stateNext = token_enumDef_BOOT;
        end
      end
      default : begin
      end
    endcase
    if(when_Misc_l247) begin
      if(rxTimer_timeout) begin
        token_stateNext = token_enumDef_BOOT;
      end
    end
    if(token_wantStart) begin
      token_stateNext = token_enumDef_PID;
    end
    if(token_wantKill) begin
      token_stateNext = token_enumDef_BOOT;
    end
  end

  assign when_Misc_l204 = (io_phy_rx_flow_payload[3 : 0] == (~ io_phy_rx_flow_payload[7 : 4]));
  assign when_Misc_l229 = (! io_phy_rx_active);
  assign when_Misc_l230 = (token_crc5_io_result == 5'h0c);
  assign when_Misc_l241 = (! io_phy_rx_active);
  assign when_StateMachine_l222 = ((token_stateReg == token_enumDef_BOOT) && (! (token_stateNext == token_enumDef_BOOT)));
  assign when_Misc_l247 = (! (token_stateReg == token_enumDef_BOOT));
  always @(*) begin
    active_stateNext = active_stateReg;
    case(active_stateReg)
      active_enumDef_IDLE : begin
        if(io_phy_rx_active) begin
          active_stateNext = active_enumDef_TOKEN;
        end
      end
      active_enumDef_TOKEN : begin
        if(token_wantExit) begin
          active_stateNext = active_enumDef_ADDRESS_HIT;
        end
      end
      active_enumDef_ADDRESS_HIT : begin
        if(when_UsbDeviceCtrl_l379) begin
          active_stateNext = active_enumDef_IDLE;
        end else begin
          case(token_pid)
            4'b0101 : begin
              active_stateNext = active_enumDef_IDLE;
            end
            4'b1101, 4'b0001, 4'b1001 : begin
              if(when_UsbDeviceCtrl_l388) begin
                active_stateNext = active_enumDef_EP_READ;
              end else begin
                active_stateNext = active_enumDef_IDLE;
              end
            end
            default : begin
              active_stateNext = active_enumDef_IDLE;
            end
          endcase
        end
      end
      active_enumDef_EP_READ : begin
        active_stateNext = active_enumDef_EP_ANALYSE;
      end
      active_enumDef_EP_ANALYSE : begin
        if(when_UsbDeviceCtrl_l412) begin
          active_stateNext = active_enumDef_IDLE;
        end else begin
          if(token_isSetup) begin
            if(when_UsbDeviceCtrl_l415) begin
              active_stateNext = active_enumDef_IDLE;
            end else begin
              active_stateNext = active_enumDef_DESC_ANALYSE;
            end
          end else begin
            if(when_UsbDeviceCtrl_l424) begin
              case(token_pid)
                4'b0001 : begin
                  active_stateNext = active_enumDef_DATA_RX;
                end
                4'b1001 : begin
                  if(ep_isochronous) begin
                    active_stateNext = active_enumDef_IDLE;
                  end else begin
                    active_stateNext = active_enumDef_HANDSHAKE_TX_0;
                  end
                end
                default : begin
                  active_stateNext = active_enumDef_IDLE;
                end
              endcase
            end else begin
              active_stateNext = active_enumDef_DESC_READ_0;
            end
          end
        end
      end
      active_enumDef_DESC_READ_0 : begin
        active_stateNext = active_enumDef_DESC_READ_1;
      end
      active_enumDef_DESC_READ_1 : begin
        active_stateNext = active_enumDef_DESC_READ_2;
      end
      active_enumDef_DESC_READ_2 : begin
        active_stateNext = active_enumDef_DESC_ANALYSE;
      end
      active_enumDef_DESC_ANALYSE : begin
        case(token_pid)
          4'b1101 : begin
            active_stateNext = active_enumDef_DATA_RX;
          end
          4'b0001 : begin
            if(desc_direction) begin
              active_stateNext = active_enumDef_IDLE;
            end else begin
              active_stateNext = active_enumDef_DATA_RX;
            end
          end
          4'b1001 : begin
            if(when_UsbDeviceCtrl_l478) begin
              active_stateNext = active_enumDef_IDLE;
            end else begin
              active_stateNext = active_enumDef_DATA_TX_0;
            end
          end
          default : begin
            active_stateNext = active_enumDef_IDLE;
          end
        endcase
      end
      active_enumDef_DATA_RX : begin
        if(dataRx_wantExit) begin
          active_stateNext = active_enumDef_DATA_RX_ANALYSE;
        end
      end
      active_enumDef_DATA_RX_ANALYSE : begin
        if(when_UsbDeviceCtrl_l569) begin
          active_stateNext = active_enumDef_IDLE;
        end else begin
          if(when_UsbDeviceCtrl_l575) begin
            active_stateNext = active_enumDef_IDLE;
          end else begin
            if(ep_isochronous) begin
              active_stateNext = active_enumDef_UPDATE_SETUP;
            end else begin
              active_stateNext = active_enumDef_HANDSHAKE_TX_0;
            end
          end
        end
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
        if(rxTimer_turnover) begin
          active_stateNext = active_enumDef_HANDSHAKE_TX_1;
        end
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
        if(io_phy_tx_stream_ready) begin
          active_stateNext = active_enumDef_UPDATE_SETUP;
        end
      end
      active_enumDef_DATA_TX_0 : begin
        if(when_UsbDeviceCtrl_l497) begin
          if(dataTx_input_ready) begin
            active_stateNext = active_enumDef_DATA_TX_1;
          end
        end else begin
          if(io_phy_tx_eop) begin
            if(ep_isochronous) begin
              active_stateNext = active_enumDef_UPDATE_SETUP;
            end else begin
              active_stateNext = active_enumDef_HANDSHAKE_RX_0;
            end
          end
        end
      end
      active_enumDef_DATA_TX_1 : begin
        active_stateNext = active_enumDef_DATA_TX_0;
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
        if(io_phy_rx_flow_valid) begin
          if(when_UsbDeviceCtrl_l527) begin
            active_stateNext = active_enumDef_IDLE;
          end else begin
            if(when_UsbDeviceCtrl_l529) begin
              active_stateNext = active_enumDef_IDLE;
            end else begin
              active_stateNext = active_enumDef_HANDSHAKE_RX_1;
            end
          end
        end
        if(when_UsbDeviceCtrl_l535) begin
          active_stateNext = active_enumDef_IDLE;
        end
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
        if(when_UsbDeviceCtrl_l541) begin
          active_stateNext = active_enumDef_UPDATE_SETUP;
        end
        if(io_phy_rx_flow_valid) begin
          active_stateNext = active_enumDef_IDLE;
        end
      end
      active_enumDef_UPDATE_SETUP : begin
        if(active_noUpdate) begin
          active_stateNext = active_enumDef_IDLE;
        end else begin
          active_stateNext = active_enumDef_UPDATE_DESC;
        end
      end
      active_enumDef_UPDATE_DESC : begin
        active_stateNext = active_enumDef_UPDATE_EP;
      end
      active_enumDef_UPDATE_EP : begin
        active_stateNext = active_enumDef_IDLE;
      end
      default : begin
      end
    endcase
    if(active_wantStart) begin
      active_stateNext = active_enumDef_IDLE;
    end
    if(active_wantKill) begin
      active_stateNext = active_enumDef_BOOT;
    end
  end

  assign when_UsbDeviceCtrl_l379 = (! token_ok);
  assign when_UsbDeviceCtrl_l388 = (token_address == (regs_address_enable ? regs_address_value : 7'h0));
  assign when_UsbDeviceCtrl_l390 = ((token_pid == 4'b1101) || (token_pid == 4'b0001));
  assign when_UsbDeviceCtrl_l412 = (! ep_enable);
  assign when_UsbDeviceCtrl_l415 = (token_endpoint != 4'b0000);
  assign when_UsbDeviceCtrl_l424 = (((ep_head == 8'h0) || ep_stall) || regs_halt_hit);
  assign when_UsbDeviceCtrl_l478 = (! desc_direction);
  assign _zz_memory_internal_writeCmd_payload_mask = desc_currentByte[1 : 0];
  always @(*) begin
    _zz_memory_internal_writeCmd_payload_mask_1[0] = (_zz_memory_internal_writeCmd_payload_mask == 2'b00);
    _zz_memory_internal_writeCmd_payload_mask_1[1] = (_zz_memory_internal_writeCmd_payload_mask == 2'b01);
    _zz_memory_internal_writeCmd_payload_mask_1[2] = (_zz_memory_internal_writeCmd_payload_mask == 2'b10);
    _zz_memory_internal_writeCmd_payload_mask_1[3] = (_zz_memory_internal_writeCmd_payload_mask == 2'b11);
  end

  assign when_UsbDeviceCtrl_l556 = (transferFull && (! active_noUpdate));
  assign when_UsbDeviceCtrl_l569 = (dataRx_hasError || active_dataRxOverrun);
  assign when_UsbDeviceCtrl_l572 = (! active_noUpdate);
  assign when_UsbDeviceCtrl_l575 = (dataRx_pid[2 : 0] != 3'b011);
  assign when_UsbDeviceCtrl_l578 = ((! ep_stall) && (dataRx_pid[3] != ep_dataPhase));
  assign when_UsbDeviceCtrl_l497 = (! transferFull);
  assign when_UsbDeviceCtrl_l527 = (io_phy_rx_flow_payload[3 : 0] != (~ io_phy_rx_flow_payload[7 : 4]));
  assign when_UsbDeviceCtrl_l529 = (io_phy_rx_flow_payload[3 : 0] != 4'b0010);
  assign when_UsbDeviceCtrl_l535 = (rxTimer_timeout || ((! io_phy_rx_active) && io_phy_rx_active_regNext));
  assign when_UsbDeviceCtrl_l541 = (! io_phy_rx_active);
  assign when_UsbDeviceCtrl_l609 = (! token_isSetup);
  assign when_UsbDeviceCtrl_l610 = ((! byteCounter_full) || (desc_completionOnFull && desc_full));
  assign when_UsbDeviceCtrl_l655 = (regs_address_trigger && token_isIn);
  assign when_UsbDeviceCtrl_l658 = (! desc_full);
  assign when_StateMachine_l238_1 = ((! (active_stateReg == active_enumDef_TOKEN)) && (active_stateNext == active_enumDef_TOKEN));
  assign when_StateMachine_l238_2 = ((! (active_stateReg == active_enumDef_DATA_RX)) && (active_stateNext == active_enumDef_DATA_RX));
  assign when_StateMachine_l238_3 = ((! (active_stateReg == active_enumDef_HANDSHAKE_RX_0)) && (active_stateNext == active_enumDef_HANDSHAKE_RX_0));
  always @(*) begin
    main_stateNext = main_stateReg;
    case(main_stateReg)
      main_enumDef_ATTACHED : begin
        if(io_phy_power) begin
          main_stateNext = main_enumDef_POWERED;
        end
      end
      main_enumDef_POWERED : begin
        if(io_phy_reset) begin
          main_stateNext = main_enumDef_ACTIVE_INIT;
        end
      end
      main_enumDef_ACTIVE_INIT : begin
        if(when_UsbDeviceCtrl_l687) begin
          main_stateNext = main_enumDef_ACTIVE;
        end
      end
      main_enumDef_ACTIVE : begin
        if(io_phy_reset) begin
          main_stateNext = main_enumDef_ACTIVE_INIT;
        end
      end
      default : begin
      end
    endcase
    if(main_wantStart) begin
      main_stateNext = main_enumDef_ATTACHED;
    end
    if(main_wantKill) begin
      main_stateNext = main_enumDef_BOOT;
    end
  end

  assign when_UsbDeviceCtrl_l687 = (! io_phy_reset);
  assign when_StateMachine_l238_4 = ((! (main_stateReg == main_enumDef_ACTIVE_INIT)) && (main_stateNext == main_enumDef_ACTIVE_INIT));
  assign when_StateMachine_l238_5 = ((! (main_stateReg == main_enumDef_ACTIVE)) && (main_stateNext == main_enumDef_ACTIVE));
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      _zz_io_ctrl_rsp_valid_2 <= 1'b0;
      regs_address_enable <= 1'b0;
      regs_address_trigger <= 1'b0;
      regs_interrupts_endpoints <= 16'h0;
      regs_interrupts_reset <= 1'b0;
      regs_interrupts_suspend <= 1'b0;
      io_phy_suspend_regNext <= 1'b0;
      regs_interrupts_resume <= 1'b0;
      regs_interrupts_disconnect <= 1'b0;
      io_phy_power_regNext <= 1'b0;
      regs_interrupts_ep0Setup <= 1'b0;
      regs_interrupts_enable <= 1'b0;
      regs_halt_enable <= 1'b0;
      regs_halt_effective <= 1'b0;
      regs_pullup <= 1'b0;
      memory_internal_readCmd_regNext_valid <= 1'b0;
      _zz_memory_external_readRsp_valid <= 1'b0;
      dataTx_input_rValid <= 1'b0;
      dataTx_input_halfPipe_rValid <= 1'b0;
      mapping_readState <= 2'b00;
      mapping_writeState <= 1'b0;
      regs_interrupts_pending_regNext <= 1'b0;
      dataRx_stateReg <= dataRx_enumDef_BOOT;
      dataTx_stateReg <= dataTx_enumDef_BOOT;
      token_stateReg <= token_enumDef_BOOT;
      active_stateReg <= active_enumDef_BOOT;
      main_stateReg <= main_enumDef_BOOT;
    end else begin
      if(_zz_ctrl_rsp_ready) begin
        _zz_io_ctrl_rsp_valid_2 <= (ctrl_rsp_valid && _zz_io_ctrl_rsp_valid);
      end
      io_phy_suspend_regNext <= io_phy_suspend;
      if(when_UsbDeviceCtrl_l154) begin
        regs_interrupts_suspend <= 1'b1;
      end
      if(io_phy_resume_valid) begin
        regs_interrupts_resume <= 1'b1;
      end
      io_phy_power_regNext <= io_phy_power;
      if(when_UsbDeviceCtrl_l156) begin
        regs_interrupts_disconnect <= 1'b1;
      end
      memory_internal_readCmd_regNext_valid <= memory_internal_readCmd_valid;
      _zz_memory_external_readRsp_valid <= memory_external_readCmd_fire;
      if(dataTx_input_valid) begin
        dataTx_input_rValid <= 1'b1;
      end
      if(dataTx_input_halfPipe_fire) begin
        dataTx_input_rValid <= 1'b0;
      end
      if(dataTx_input_halfPipe_ready) begin
        dataTx_input_halfPipe_rValid <= dataTx_input_halfPipe_valid;
      end
      if(when_UsbDeviceCtrl_l363) begin
        regs_halt_effective <= 1'b1;
      end
      if(when_BusSlaveFactory_l335) begin
        if(when_BusSlaveFactory_l341) begin
          regs_interrupts_endpoints[0 : 0] <= 1'b0;
        end
        if(when_BusSlaveFactory_l341_1) begin
          regs_interrupts_endpoints[1 : 1] <= 1'b0;
        end
        if(when_BusSlaveFactory_l341_2) begin
          regs_interrupts_endpoints[2 : 2] <= 1'b0;
        end
        if(when_BusSlaveFactory_l341_3) begin
          regs_interrupts_endpoints[3 : 3] <= 1'b0;
        end
        if(when_BusSlaveFactory_l341_4) begin
          regs_interrupts_endpoints[4 : 4] <= 1'b0;
        end
        if(when_BusSlaveFactory_l341_5) begin
          regs_interrupts_endpoints[5 : 5] <= 1'b0;
        end
        if(when_BusSlaveFactory_l341_6) begin
          regs_interrupts_endpoints[6 : 6] <= 1'b0;
        end
        if(when_BusSlaveFactory_l341_7) begin
          regs_interrupts_endpoints[7 : 7] <= 1'b0;
        end
        if(when_BusSlaveFactory_l341_8) begin
          regs_interrupts_endpoints[8 : 8] <= 1'b0;
        end
        if(when_BusSlaveFactory_l341_9) begin
          regs_interrupts_endpoints[9 : 9] <= 1'b0;
        end
        if(when_BusSlaveFactory_l341_10) begin
          regs_interrupts_endpoints[10 : 10] <= 1'b0;
        end
        if(when_BusSlaveFactory_l341_11) begin
          regs_interrupts_endpoints[11 : 11] <= 1'b0;
        end
        if(when_BusSlaveFactory_l341_12) begin
          regs_interrupts_endpoints[12 : 12] <= 1'b0;
        end
        if(when_BusSlaveFactory_l341_13) begin
          regs_interrupts_endpoints[13 : 13] <= 1'b0;
        end
        if(when_BusSlaveFactory_l341_14) begin
          regs_interrupts_endpoints[14 : 14] <= 1'b0;
        end
        if(when_BusSlaveFactory_l341_15) begin
          regs_interrupts_endpoints[15 : 15] <= 1'b0;
        end
      end
      if(when_BusSlaveFactory_l335_1) begin
        if(when_BusSlaveFactory_l341_16) begin
          regs_interrupts_reset <= _zz_regs_interrupts_reset[0];
        end
      end
      if(when_BusSlaveFactory_l335_2) begin
        if(when_BusSlaveFactory_l341_17) begin
          regs_interrupts_ep0Setup <= _zz_regs_interrupts_ep0Setup[0];
        end
      end
      if(when_BusSlaveFactory_l335_3) begin
        if(when_BusSlaveFactory_l341_18) begin
          regs_interrupts_suspend <= _zz_regs_interrupts_suspend[0];
        end
      end
      if(when_BusSlaveFactory_l335_4) begin
        if(when_BusSlaveFactory_l341_19) begin
          regs_interrupts_resume <= _zz_regs_interrupts_resume[0];
        end
      end
      if(when_BusSlaveFactory_l335_5) begin
        if(when_BusSlaveFactory_l341_20) begin
          regs_interrupts_disconnect <= _zz_regs_interrupts_disconnect[0];
        end
      end
      if(when_BusSlaveFactory_l371) begin
        if(when_BusSlaveFactory_l373) begin
          regs_pullup <= _zz_regs_pullup[0];
        end
      end
      if(when_BusSlaveFactory_l335_6) begin
        if(when_BusSlaveFactory_l341_21) begin
          regs_pullup <= _zz_regs_pullup_1[0];
        end
      end
      if(when_BusSlaveFactory_l371_1) begin
        if(when_BusSlaveFactory_l373_1) begin
          regs_interrupts_enable <= _zz_regs_interrupts_enable[0];
        end
      end
      if(when_BusSlaveFactory_l335_7) begin
        if(when_BusSlaveFactory_l341_22) begin
          regs_interrupts_enable <= _zz_regs_interrupts_enable_1[0];
        end
      end
      regs_interrupts_pending_regNext <= regs_interrupts_pending;
      case(io_ctrl_cmd_payload_fragment_address)
        16'hff04 : begin
          if(ctrl_doWrite) begin
            if(when_BusSlaveFactory_l962_1) begin
              regs_address_enable <= io_ctrl_cmd_payload_fragment_data[8];
            end
            if(when_BusSlaveFactory_l962_2) begin
              regs_address_trigger <= io_ctrl_cmd_payload_fragment_data[9];
            end
          end
        end
        16'hff0c : begin
          if(ctrl_doWrite) begin
            if(when_BusSlaveFactory_l962_4) begin
              regs_halt_enable <= io_ctrl_cmd_payload_fragment_data[4];
            end
            if(when_BusSlaveFactory_l962_5) begin
              regs_halt_effective <= io_ctrl_cmd_payload_fragment_data[5];
            end
          end
        end
        default : begin
        end
      endcase
      if(when_BmbSlaveFactory_l71) begin
        if(ctrl_askWrite) begin
          case(mapping_writeState)
            1'b0 : begin
              if(memory_external_writeCmd_ready) begin
                mapping_writeState <= 1'b1;
              end
            end
            default : begin
            end
          endcase
        end
        if(ctrl_doWrite) begin
          mapping_writeState <= 1'b0;
        end
        if(ctrl_askRead) begin
          case(mapping_readState)
            2'b00 : begin
              if(memory_external_readCmd_ready) begin
                mapping_readState <= 2'b01;
              end
            end
            2'b01 : begin
              if(memory_external_readRsp_valid) begin
                mapping_readState <= 2'b10;
              end
            end
            default : begin
            end
          endcase
        end
        if(ctrl_doRead) begin
          mapping_readState <= 2'b00;
        end
      end
      dataRx_stateReg <= dataRx_stateNext;
      dataTx_stateReg <= dataTx_stateNext;
      token_stateReg <= token_stateNext;
      active_stateReg <= active_stateNext;
      case(active_stateReg)
        active_enumDef_IDLE : begin
        end
        active_enumDef_TOKEN : begin
        end
        active_enumDef_ADDRESS_HIT : begin
        end
        active_enumDef_EP_READ : begin
        end
        active_enumDef_EP_ANALYSE : begin
        end
        active_enumDef_DESC_READ_0 : begin
        end
        active_enumDef_DESC_READ_1 : begin
        end
        active_enumDef_DESC_READ_2 : begin
        end
        active_enumDef_DESC_ANALYSE : begin
        end
        active_enumDef_DATA_RX : begin
        end
        active_enumDef_DATA_RX_ANALYSE : begin
        end
        active_enumDef_HANDSHAKE_TX_0 : begin
        end
        active_enumDef_HANDSHAKE_TX_1 : begin
        end
        active_enumDef_DATA_TX_0 : begin
        end
        active_enumDef_DATA_TX_1 : begin
        end
        active_enumDef_HANDSHAKE_RX_0 : begin
        end
        active_enumDef_HANDSHAKE_RX_1 : begin
        end
        active_enumDef_UPDATE_SETUP : begin
        end
        active_enumDef_UPDATE_DESC : begin
        end
        active_enumDef_UPDATE_EP : begin
          if(token_isSetup) begin
            regs_interrupts_ep0Setup <= 1'b1;
          end
          if(active_completion) begin
            if(desc_interrupt) begin
              regs_interrupts_endpoints[token_endpoint] <= 1'b1;
            end
            if(when_UsbDeviceCtrl_l655) begin
              regs_address_enable <= 1'b1;
            end
          end
        end
        default : begin
        end
      endcase
      main_stateReg <= main_stateNext;
      case(main_stateReg)
        main_enumDef_ATTACHED : begin
        end
        main_enumDef_POWERED : begin
        end
        main_enumDef_ACTIVE_INIT : begin
          regs_address_enable <= 1'b0;
        end
        main_enumDef_ACTIVE : begin
        end
        default : begin
        end
      endcase
      if(when_StateMachine_l238_4) begin
        regs_interrupts_reset <= 1'b1;
      end
    end
  end

  always @(posedge ctrl_clk) begin
    if(_zz_ctrl_rsp_ready) begin
      _zz_io_ctrl_rsp_payload_last <= ctrl_rsp_payload_last;
      _zz_io_ctrl_rsp_payload_fragment_opcode <= ctrl_rsp_payload_fragment_opcode;
      _zz_io_ctrl_rsp_payload_fragment_data <= ctrl_rsp_payload_fragment_data;
    end
    memory_internal_readCmd_regNext_payload <= memory_internal_readCmd_payload;
    if(io_phy_tick) begin
      rxTimer_counter <= (rxTimer_counter + 5'h01);
    end
    if(rxTimer_clear) begin
      rxTimer_counter <= 5'h0;
    end
    if(io_phy_rx_flow_valid) begin
      _zz_dataRx_history_0 <= io_phy_rx_flow_payload;
    end
    if(io_phy_rx_flow_valid) begin
      _zz_dataRx_history_1 <= _zz_dataRx_history_0;
    end
    if(dataTx_input_ready) begin
      dataTx_input_rData_last <= dataTx_input_payload_last;
      dataTx_input_rData_fragment <= dataTx_input_payload_fragment;
    end
    if(dataTx_input_halfPipe_ready) begin
      dataTx_input_halfPipe_rData_last <= dataTx_input_halfPipe_payload_last;
      dataTx_input_halfPipe_rData_fragment <= dataTx_input_halfPipe_payload_fragment;
    end
    if(desc_offsetIncrement) begin
      desc_words_0[12 : 0] <= _zz_desc_words_0;
    end
    if(byteCounter_increment) begin
      byteCounter_value <= (byteCounter_value + 10'h001);
    end
    if(byteCounter_clear) begin
      byteCounter_value <= 10'h0;
    end
    if(memory_external_readRsp_valid) begin
      mapping_readBuffer <= memory_external_readRsp_payload;
    end
    case(io_ctrl_cmd_payload_fragment_address)
      16'hff04 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l962) begin
            regs_address_value[6 : 0] <= io_ctrl_cmd_payload_fragment_data[6 : 0];
          end
        end
      end
      16'hff0c : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l962_3) begin
            regs_halt_id[3 : 0] <= io_ctrl_cmd_payload_fragment_data[3 : 0];
          end
        end
      end
      default : begin
      end
    endcase
    case(dataRx_stateReg)
      dataRx_enumDef_IDLE : begin
        if(!io_phy_rx_active) begin
          if(rxTimer_timeout) begin
            dataRx_notResponding <= 1'b1;
          end
        end
      end
      dataRx_enumDef_PID : begin
        dataRx_valids <= 2'b00;
        dataRx_pidError <= 1'b1;
        if(io_phy_rx_flow_valid) begin
          dataRx_pid <= io_phy_rx_flow_payload[3 : 0];
          dataRx_pidError <= (io_phy_rx_flow_payload[3 : 0] != (~ io_phy_rx_flow_payload[7 : 4]));
        end
      end
      dataRx_enumDef_DATA : begin
        if(when_Misc_l70) begin
          if(when_Misc_l71) begin
            dataRx_crcError <= 1'b1;
          end
        end else begin
          if(io_phy_rx_flow_valid) begin
            dataRx_valids <= {dataRx_valids[0],1'b1};
          end
        end
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l238) begin
      dataRx_notResponding <= 1'b0;
      dataRx_stuffingError <= 1'b0;
      dataRx_pidError <= 1'b0;
      dataRx_crcError <= 1'b0;
    end
    if(when_Misc_l85) begin
      if(io_phy_rx_flow_valid) begin
        if(io_phy_rx_stuffingError) begin
          dataRx_stuffingError <= 1'b1;
        end
      end
    end
    case(token_stateReg)
      token_enumDef_PID : begin
        if(io_phy_rx_flow_valid) begin
          token_pid <= io_phy_rx_flow_payload[3 : 0];
        end
      end
      token_enumDef_DATA_0 : begin
        if(io_phy_rx_flow_valid) begin
          token_data[7 : 0] <= io_phy_rx_flow_payload;
        end
      end
      token_enumDef_DATA_1 : begin
        if(io_phy_rx_flow_valid) begin
          token_data[10 : 8] <= io_phy_rx_flow_payload[2 : 0];
        end
      end
      token_enumDef_CHECK : begin
        if(when_Misc_l229) begin
          if(when_Misc_l230) begin
            token_ok <= 1'b1;
          end
        end
      end
      token_enumDef_ERROR : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l222) begin
      token_ok <= 1'b0;
    end
    case(active_stateReg)
      active_enumDef_IDLE : begin
        active_completion <= 1'b0;
        active_noUpdate <= 1'b0;
      end
      active_enumDef_TOKEN : begin
      end
      active_enumDef_ADDRESS_HIT : begin
        if(!when_UsbDeviceCtrl_l379) begin
          case(token_pid)
            4'b0101 : begin
              regs_frame <= token_data;
            end
            4'b1101, 4'b0001, 4'b1001 : begin
            end
            default : begin
            end
          endcase
        end
      end
      active_enumDef_EP_READ : begin
        ep_word <= memory_internal_readRsp_payload;
      end
      active_enumDef_EP_ANALYSE : begin
        if(!when_UsbDeviceCtrl_l412) begin
          if(token_isSetup) begin
            if(!when_UsbDeviceCtrl_l415) begin
              desc_words_0[12 : 0] <= 13'h0034;
              desc_words_1[28 : 16] <= 13'h0008;
              desc_words_2[16] <= 1'b0;
              ep_word[3] <= 1'b0;
            end
          end else begin
            if(when_UsbDeviceCtrl_l424) begin
              active_handshakePid <= ((ep_stall && (! regs_halt_hit)) ? 4'b1110 : 4'b1010);
              case(token_pid)
                4'b0001 : begin
                  active_noUpdate <= 1'b1;
                end
                4'b1001 : begin
                  active_noUpdate <= 1'b1;
                end
                default : begin
                end
              endcase
            end
          end
        end
      end
      active_enumDef_DESC_READ_0 : begin
        desc_words_0 <= memory_internal_readRsp_payload;
      end
      active_enumDef_DESC_READ_1 : begin
        desc_words_1 <= memory_internal_readRsp_payload;
      end
      active_enumDef_DESC_READ_2 : begin
        desc_words_2 <= memory_internal_readRsp_payload;
      end
      active_enumDef_DESC_ANALYSE : begin
      end
      active_enumDef_DATA_RX : begin
        if(dataRx_data_valid) begin
          if(when_UsbDeviceCtrl_l556) begin
            active_dataRxOverrun <= 1'b1;
          end
        end
      end
      active_enumDef_DATA_RX_ANALYSE : begin
        if(!when_UsbDeviceCtrl_l569) begin
          if(when_UsbDeviceCtrl_l572) begin
            active_handshakePid <= 4'b0010;
          end
          if(!when_UsbDeviceCtrl_l575) begin
            if(when_UsbDeviceCtrl_l578) begin
              active_noUpdate <= 1'b1;
              active_handshakePid <= 4'b0010;
            end
          end
        end
      end
      active_enumDef_HANDSHAKE_TX_0 : begin
      end
      active_enumDef_HANDSHAKE_TX_1 : begin
      end
      active_enumDef_DATA_TX_0 : begin
        active_byteSel <= _zz_active_byteSel[1:0];
      end
      active_enumDef_DATA_TX_1 : begin
      end
      active_enumDef_HANDSHAKE_RX_0 : begin
      end
      active_enumDef_HANDSHAKE_RX_1 : begin
      end
      active_enumDef_UPDATE_SETUP : begin
        if(when_UsbDeviceCtrl_l609) begin
          if(when_UsbDeviceCtrl_l610) begin
            active_completion <= 1'b1;
          end
        end
      end
      active_enumDef_UPDATE_DESC : begin
        desc_words_1 <= memory_internal_readRsp_payload;
      end
      active_enumDef_UPDATE_EP : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l238_2) begin
      active_dataRxOverrun <= 1'b0;
    end
  end

  always @(posedge ctrl_clk) begin
    io_phy_rx_active_regNext <= io_phy_rx_active;
  end


endmodule

module WishboneToBmb (
  input               io_input_CYC,
  input               io_input_STB,
  output              io_input_ACK,
  input               io_input_WE,
  input      [13:0]   io_input_ADR,
  output     [31:0]   io_input_DAT_MISO,
  input      [31:0]   io_input_DAT_MOSI,
  input      [3:0]    io_input_SEL,
  output              io_output_cmd_valid,
  input               io_output_cmd_ready,
  output              io_output_cmd_payload_last,
  output     [0:0]    io_output_cmd_payload_fragment_opcode,
  output     [15:0]   io_output_cmd_payload_fragment_address,
  output     [1:0]    io_output_cmd_payload_fragment_length,
  output     [31:0]   io_output_cmd_payload_fragment_data,
  output     [3:0]    io_output_cmd_payload_fragment_mask,
  input               io_output_rsp_valid,
  output              io_output_rsp_ready,
  input               io_output_rsp_payload_last,
  input      [0:0]    io_output_rsp_payload_fragment_opcode,
  input      [31:0]   io_output_rsp_payload_fragment_data,
  input               ctrl_clk,
  input               ctrl_reset
);

  reg                 _zz_io_output_cmd_valid;
  wire                io_output_cmd_fire;
  wire                io_output_rsp_fire;
  wire                io_output_rsp_fire_1;

  assign io_output_cmd_payload_fragment_address = ({2'd0,io_input_ADR} <<< 2);
  assign io_output_cmd_payload_fragment_opcode = (io_input_WE ? 1'b1 : 1'b0);
  assign io_output_cmd_payload_fragment_data = io_input_DAT_MOSI;
  assign io_output_cmd_payload_fragment_mask = io_input_SEL;
  assign io_output_cmd_payload_fragment_length = 2'b11;
  assign io_output_cmd_payload_last = 1'b1;
  assign io_output_cmd_fire = (io_output_cmd_valid && io_output_cmd_ready);
  assign io_output_rsp_fire = (io_output_rsp_valid && io_output_rsp_ready);
  assign io_output_cmd_valid = ((io_input_CYC && io_input_STB) && (! _zz_io_output_cmd_valid));
  assign io_output_rsp_fire_1 = (io_output_rsp_valid && io_output_rsp_ready);
  assign io_input_ACK = io_output_rsp_fire_1;
  assign io_input_DAT_MISO = io_output_rsp_payload_fragment_data;
  assign io_output_rsp_ready = 1'b1;
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      _zz_io_output_cmd_valid <= 1'b0;
    end else begin
      if(io_output_cmd_fire) begin
        _zz_io_output_cmd_valid <= 1'b1;
      end
      if(io_output_rsp_fire) begin
        _zz_io_output_cmd_valid <= 1'b0;
      end
    end
  end


endmodule

//BufferCC_8 replaced by BufferCC_8

//BufferCC_8 replaced by BufferCC_8

module FlowCCByToggle_1 (
  input               io_input_valid,
  output              io_output_valid,
  input               phy_clk,
  input               phy_reset,
  input               ctrl_clk,
  input               phy_reset_syncronized_1
);

  wire                inputArea_target_buffercc_io_dataOut;
  reg                 inputArea_target;
  wire                outputArea_target;
  reg                 outputArea_hit;
  wire                outputArea_flow_valid;
  reg                 outputArea_flow_m2sPipe_valid;

  BufferCC_4 inputArea_target_buffercc (
    .io_dataIn                (inputArea_target                      ), //i
    .io_dataOut               (inputArea_target_buffercc_io_dataOut  ), //o
    .ctrl_clk                 (ctrl_clk                              ), //i
    .phy_reset_syncronized    (phy_reset_syncronized_1               )  //i
  );
  assign outputArea_target = inputArea_target_buffercc_io_dataOut;
  assign outputArea_flow_valid = (outputArea_target != outputArea_hit);
  assign io_output_valid = outputArea_flow_m2sPipe_valid;
  always @(posedge phy_clk or posedge phy_reset) begin
    if(phy_reset) begin
      inputArea_target <= 1'b0;
    end else begin
      if(io_input_valid) begin
        inputArea_target <= (! inputArea_target);
      end
    end
  end

  always @(posedge ctrl_clk or posedge phy_reset_syncronized_1) begin
    if(phy_reset_syncronized_1) begin
      outputArea_flow_m2sPipe_valid <= 1'b0;
      outputArea_hit <= 1'b0;
    end else begin
      outputArea_hit <= outputArea_target;
      outputArea_flow_m2sPipe_valid <= outputArea_flow_valid;
    end
  end


endmodule

//BufferCC_8 replaced by BufferCC_8

//BufferCC_8 replaced by BufferCC_8

module PulseCCByToggle_1 (
  input               io_pulseIn,
  output              io_pulseOut,
  input               phy_clk,
  input               phy_reset,
  input               ctrl_clk,
  input               phy_reset_syncronized_1
);

  wire                inArea_target_buffercc_io_dataOut;
  reg                 inArea_target;
  wire                outArea_target;
  reg                 outArea_target_regNext;

  BufferCC_4 inArea_target_buffercc (
    .io_dataIn                (inArea_target                      ), //i
    .io_dataOut               (inArea_target_buffercc_io_dataOut  ), //o
    .ctrl_clk                 (ctrl_clk                           ), //i
    .phy_reset_syncronized    (phy_reset_syncronized_1            )  //i
  );
  assign outArea_target = inArea_target_buffercc_io_dataOut;
  assign io_pulseOut = (outArea_target ^ outArea_target_regNext);
  always @(posedge phy_clk or posedge phy_reset) begin
    if(phy_reset) begin
      inArea_target <= 1'b0;
    end else begin
      if(io_pulseIn) begin
        inArea_target <= (! inArea_target);
      end
    end
  end

  always @(posedge ctrl_clk or posedge phy_reset_syncronized_1) begin
    if(phy_reset_syncronized_1) begin
      outArea_target_regNext <= 1'b0;
    end else begin
      outArea_target_regNext <= outArea_target;
    end
  end


endmodule

//BufferCC_10 replaced by BufferCC_10

module BufferCC_10 (
  input               io_dataIn,
  output              io_dataOut,
  input               phy_clk,
  input               phy_reset
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge phy_clk) begin
    buffers_0 <= io_dataIn;
    buffers_1 <= buffers_0;
  end


endmodule

//BufferCC_8 replaced by BufferCC_8

module BufferCC_8 (
  input               io_dataIn,
  output              io_dataOut,
  input               ctrl_clk,
  input               ctrl_reset
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge ctrl_clk) begin
    buffers_0 <= io_dataIn;
    buffers_1 <= buffers_0;
  end


endmodule

module FlowCCByToggle (
  input               io_input_valid,
  input      [7:0]    io_input_payload,
  output              io_output_valid,
  output     [7:0]    io_output_payload,
  input               phy_clk,
  input               phy_reset,
  input               ctrl_clk,
  input               phy_reset_syncronized_1
);

  wire                inputArea_target_buffercc_io_dataOut;
  reg                 inputArea_target;
  reg        [7:0]    inputArea_data;
  wire                outputArea_target;
  reg                 outputArea_hit;
  wire                outputArea_flow_valid;
  wire       [7:0]    outputArea_flow_payload;
  reg                 outputArea_flow_m2sPipe_valid;
  reg        [7:0]    outputArea_flow_m2sPipe_payload;

  BufferCC_4 inputArea_target_buffercc (
    .io_dataIn                (inputArea_target                      ), //i
    .io_dataOut               (inputArea_target_buffercc_io_dataOut  ), //o
    .ctrl_clk                 (ctrl_clk                              ), //i
    .phy_reset_syncronized    (phy_reset_syncronized_1               )  //i
  );
  assign outputArea_target = inputArea_target_buffercc_io_dataOut;
  assign outputArea_flow_valid = (outputArea_target != outputArea_hit);
  assign outputArea_flow_payload = inputArea_data;
  assign io_output_valid = outputArea_flow_m2sPipe_valid;
  assign io_output_payload = outputArea_flow_m2sPipe_payload;
  always @(posedge phy_clk or posedge phy_reset) begin
    if(phy_reset) begin
      inputArea_target <= 1'b0;
    end else begin
      if(io_input_valid) begin
        inputArea_target <= (! inputArea_target);
      end
    end
  end

  always @(posedge phy_clk) begin
    if(io_input_valid) begin
      inputArea_data <= io_input_payload;
    end
  end

  always @(posedge ctrl_clk or posedge phy_reset_syncronized_1) begin
    if(phy_reset_syncronized_1) begin
      outputArea_flow_m2sPipe_valid <= 1'b0;
      outputArea_hit <= 1'b0;
    end else begin
      outputArea_hit <= outputArea_target;
      outputArea_flow_m2sPipe_valid <= outputArea_flow_valid;
    end
  end

  always @(posedge ctrl_clk) begin
    if(outputArea_flow_valid) begin
      outputArea_flow_m2sPipe_payload <= outputArea_flow_payload;
    end
  end


endmodule

module PulseCCByToggle (
  input               io_pulseIn,
  output              io_pulseOut,
  input               phy_clk,
  input               phy_reset,
  input               ctrl_clk,
  output              phy_reset_syncronized_1
);

  wire                bufferCC_16_io_dataOut;
  wire                inArea_target_buffercc_io_dataOut;
  reg                 inArea_target;
  wire                phy_reset_syncronized;
  wire                outArea_target;
  reg                 outArea_target_regNext;

  BufferCC_3 bufferCC_16 (
    .io_dataIn     (1'b0                    ), //i
    .io_dataOut    (bufferCC_16_io_dataOut  ), //o
    .ctrl_clk      (ctrl_clk                ), //i
    .phy_reset     (phy_reset               )  //i
  );
  BufferCC_4 inArea_target_buffercc (
    .io_dataIn                (inArea_target                      ), //i
    .io_dataOut               (inArea_target_buffercc_io_dataOut  ), //o
    .ctrl_clk                 (ctrl_clk                           ), //i
    .phy_reset_syncronized    (phy_reset_syncronized              )  //i
  );
  assign phy_reset_syncronized = bufferCC_16_io_dataOut;
  assign outArea_target = inArea_target_buffercc_io_dataOut;
  assign io_pulseOut = (outArea_target ^ outArea_target_regNext);
  assign phy_reset_syncronized_1 = phy_reset_syncronized;
  always @(posedge phy_clk or posedge phy_reset) begin
    if(phy_reset) begin
      inArea_target <= 1'b0;
    end else begin
      if(io_pulseIn) begin
        inArea_target <= (! inArea_target);
      end
    end
  end

  always @(posedge ctrl_clk or posedge phy_reset_syncronized) begin
    if(phy_reset_syncronized) begin
      outArea_target_regNext <= 1'b0;
    end else begin
      outArea_target_regNext <= outArea_target;
    end
  end


endmodule

module StreamCCByToggle (
  input               io_input_valid,
  output              io_input_ready,
  input               io_input_payload_last,
  input      [7:0]    io_input_payload_fragment,
  output              io_output_valid,
  input               io_output_ready,
  output              io_output_payload_last,
  output     [7:0]    io_output_payload_fragment,
  input               ctrl_clk,
  input               ctrl_reset,
  input               phy_clk
);

  wire                outHitSignal_buffercc_io_dataOut;
  wire                bufferCC_16_io_dataOut;
  wire                pushArea_target_buffercc_io_dataOut;
  wire                outHitSignal;
  wire                pushArea_hit;
  wire                pushArea_accept;
  reg                 pushArea_target;
  reg                 pushArea_data_last;
  reg        [7:0]    pushArea_data_fragment;
  wire                io_input_fire;
  wire                ctrl_reset_syncronized;
  wire                popArea_stream_valid;
  reg                 popArea_stream_ready;
  wire                popArea_stream_payload_last;
  wire       [7:0]    popArea_stream_payload_fragment;
  wire                popArea_target;
  wire                popArea_stream_fire;
  reg                 popArea_hit;
  wire                popArea_stream_m2sPipe_valid;
  wire                popArea_stream_m2sPipe_ready;
  wire                popArea_stream_m2sPipe_payload_last;
  wire       [7:0]    popArea_stream_m2sPipe_payload_fragment;
  reg                 popArea_stream_rValid;
  wire                popArea_stream_fire_1;
  reg                 popArea_stream_rData_last;
  reg        [7:0]    popArea_stream_rData_fragment;
  wire                when_Stream_l366;

  BufferCC outHitSignal_buffercc (
    .io_dataIn     (outHitSignal                      ), //i
    .io_dataOut    (outHitSignal_buffercc_io_dataOut  ), //o
    .ctrl_clk      (ctrl_clk                          ), //i
    .ctrl_reset    (ctrl_reset                        )  //i
  );
  BufferCC_1 bufferCC_16 (
    .io_dataIn     (1'b0                    ), //i
    .io_dataOut    (bufferCC_16_io_dataOut  ), //o
    .phy_clk       (phy_clk                 ), //i
    .ctrl_reset    (ctrl_reset              )  //i
  );
  BufferCC_2 pushArea_target_buffercc (
    .io_dataIn                 (pushArea_target                      ), //i
    .io_dataOut                (pushArea_target_buffercc_io_dataOut  ), //o
    .phy_clk                   (phy_clk                              ), //i
    .ctrl_reset_syncronized    (ctrl_reset_syncronized               )  //i
  );
  assign pushArea_hit = outHitSignal_buffercc_io_dataOut;
  assign io_input_fire = (io_input_valid && io_input_ready);
  assign pushArea_accept = io_input_fire;
  assign io_input_ready = (pushArea_hit == pushArea_target);
  assign ctrl_reset_syncronized = bufferCC_16_io_dataOut;
  assign popArea_target = pushArea_target_buffercc_io_dataOut;
  assign popArea_stream_fire = (popArea_stream_valid && popArea_stream_ready);
  assign outHitSignal = popArea_hit;
  assign popArea_stream_valid = (popArea_target != popArea_hit);
  assign popArea_stream_payload_last = pushArea_data_last;
  assign popArea_stream_payload_fragment = pushArea_data_fragment;
  assign popArea_stream_fire_1 = (popArea_stream_valid && popArea_stream_ready);
  always @(*) begin
    popArea_stream_ready = popArea_stream_m2sPipe_ready;
    if(when_Stream_l366) begin
      popArea_stream_ready = 1'b1;
    end
  end

  assign when_Stream_l366 = (! popArea_stream_m2sPipe_valid);
  assign popArea_stream_m2sPipe_valid = popArea_stream_rValid;
  assign popArea_stream_m2sPipe_payload_last = popArea_stream_rData_last;
  assign popArea_stream_m2sPipe_payload_fragment = popArea_stream_rData_fragment;
  assign io_output_valid = popArea_stream_m2sPipe_valid;
  assign popArea_stream_m2sPipe_ready = io_output_ready;
  assign io_output_payload_last = popArea_stream_m2sPipe_payload_last;
  assign io_output_payload_fragment = popArea_stream_m2sPipe_payload_fragment;
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      pushArea_target <= 1'b0;
    end else begin
      if(pushArea_accept) begin
        pushArea_target <= (! pushArea_target);
      end
    end
  end

  always @(posedge ctrl_clk) begin
    if(pushArea_accept) begin
      pushArea_data_last <= io_input_payload_last;
      pushArea_data_fragment <= io_input_payload_fragment;
    end
  end

  always @(posedge phy_clk or posedge ctrl_reset_syncronized) begin
    if(ctrl_reset_syncronized) begin
      popArea_hit <= 1'b0;
      popArea_stream_rValid <= 1'b0;
    end else begin
      if(popArea_stream_fire) begin
        popArea_hit <= popArea_target;
      end
      if(popArea_stream_ready) begin
        popArea_stream_rValid <= popArea_stream_valid;
      end
    end
  end

  always @(posedge phy_clk) begin
    if(popArea_stream_fire_1) begin
      popArea_stream_rData_last <= popArea_stream_payload_last;
      popArea_stream_rData_fragment <= popArea_stream_payload_fragment;
    end
  end


endmodule

module UsbLsFsPhyFilter (
  input               io_lowSpeed,
  input               io_usb_dp,
  input               io_usb_dm,
  output              io_filtred_dp,
  output              io_filtred_dm,
  output              io_filtred_d,
  output              io_filtred_se0,
  output              io_filtred_sample,
  input               phy_clk,
  input               phy_reset
);

  wire       [4:0]    _zz_timer_sampleDo;
  reg                 timer_clear;
  reg        [4:0]    timer_counter;
  wire       [4:0]    timer_counterLimit;
  wire                when_UsbHubPhy_l93;
  wire       [3:0]    timer_sampleAt;
  wire                timer_sampleDo;
  reg                 io_usb_dp_regNext;
  reg                 io_usb_dm_regNext;
  wire                when_UsbHubPhy_l100;

  assign _zz_timer_sampleDo = {1'd0, timer_sampleAt};
  always @(*) begin
    timer_clear = 1'b0;
    if(when_UsbHubPhy_l100) begin
      timer_clear = 1'b1;
    end
  end

  assign timer_counterLimit = (io_lowSpeed ? 5'h1f : 5'h03);
  assign when_UsbHubPhy_l93 = ((timer_counter == timer_counterLimit) || timer_clear);
  assign timer_sampleAt = (io_lowSpeed ? 4'b1110 : 4'b0000);
  assign timer_sampleDo = ((timer_counter == _zz_timer_sampleDo) && (! timer_clear));
  assign when_UsbHubPhy_l100 = ((io_usb_dp ^ io_usb_dp_regNext) || (io_usb_dm ^ io_usb_dm_regNext));
  assign io_filtred_dp = io_usb_dp;
  assign io_filtred_dm = io_usb_dm;
  assign io_filtred_d = io_usb_dp;
  assign io_filtred_sample = timer_sampleDo;
  assign io_filtred_se0 = ((! io_usb_dp) && (! io_usb_dm));
  always @(posedge phy_clk) begin
    timer_counter <= (timer_counter + 5'h01);
    if(when_UsbHubPhy_l93) begin
      timer_counter <= 5'h0;
    end
    io_usb_dp_regNext <= io_usb_dp;
    io_usb_dm_regNext <= io_usb_dm;
  end


endmodule

module Crc_2 (
  input               io_flush,
  input               io_input_valid,
  input      [7:0]    io_input_payload,
  output     [15:0]   io_result,
  output     [15:0]   io_resultNext,
  input               ctrl_clk,
  input               ctrl_reset
);

  wire       [15:0]   _zz_state_1;
  wire       [15:0]   _zz_state_2;
  wire       [15:0]   _zz_state_3;
  wire       [15:0]   _zz_state_4;
  wire       [15:0]   _zz_state_5;
  wire       [15:0]   _zz_state_6;
  wire       [15:0]   _zz_state_7;
  wire       [15:0]   _zz_state_8;
  wire                _zz_io_result;
  wire       [0:0]    _zz_io_result_1;
  wire       [4:0]    _zz_io_result_2;
  wire                _zz_io_resultNext;
  wire       [0:0]    _zz_io_resultNext_1;
  wire       [4:0]    _zz_io_resultNext_2;
  reg        [15:0]   state_8;
  reg        [15:0]   state_7;
  reg        [15:0]   state_6;
  reg        [15:0]   state_5;
  reg        [15:0]   state_4;
  reg        [15:0]   state_3;
  reg        [15:0]   state_2;
  reg        [15:0]   state_1;
  reg        [15:0]   state;
  wire       [15:0]   stateXor;
  wire       [15:0]   accXor;

  assign _zz_state_1 = (state <<< 1);
  assign _zz_state_2 = (state_1 <<< 1);
  assign _zz_state_3 = (state_2 <<< 1);
  assign _zz_state_4 = (state_3 <<< 1);
  assign _zz_state_5 = (state_4 <<< 1);
  assign _zz_state_6 = (state_5 <<< 1);
  assign _zz_state_7 = (state_6 <<< 1);
  assign _zz_state_8 = (state_7 <<< 1);
  assign _zz_io_result = stateXor[9];
  assign _zz_io_result_1 = stateXor[10];
  assign _zz_io_result_2 = {stateXor[11],{stateXor[12],{stateXor[13],{stateXor[14],stateXor[15]}}}};
  assign _zz_io_resultNext = accXor[9];
  assign _zz_io_resultNext_1 = accXor[10];
  assign _zz_io_resultNext_2 = {accXor[11],{accXor[12],{accXor[13],{accXor[14],accXor[15]}}}};
  always @(*) begin
    state_8 = state_7;
    state_8 = (_zz_state_8 ^ ((io_input_payload[7] ^ state_7[15]) ? 16'h8005 : 16'h0));
  end

  always @(*) begin
    state_7 = state_6;
    state_7 = (_zz_state_7 ^ ((io_input_payload[6] ^ state_6[15]) ? 16'h8005 : 16'h0));
  end

  always @(*) begin
    state_6 = state_5;
    state_6 = (_zz_state_6 ^ ((io_input_payload[5] ^ state_5[15]) ? 16'h8005 : 16'h0));
  end

  always @(*) begin
    state_5 = state_4;
    state_5 = (_zz_state_5 ^ ((io_input_payload[4] ^ state_4[15]) ? 16'h8005 : 16'h0));
  end

  always @(*) begin
    state_4 = state_3;
    state_4 = (_zz_state_4 ^ ((io_input_payload[3] ^ state_3[15]) ? 16'h8005 : 16'h0));
  end

  always @(*) begin
    state_3 = state_2;
    state_3 = (_zz_state_3 ^ ((io_input_payload[2] ^ state_2[15]) ? 16'h8005 : 16'h0));
  end

  always @(*) begin
    state_2 = state_1;
    state_2 = (_zz_state_2 ^ ((io_input_payload[1] ^ state_1[15]) ? 16'h8005 : 16'h0));
  end

  always @(*) begin
    state_1 = state;
    state_1 = (_zz_state_1 ^ ((io_input_payload[0] ^ state[15]) ? 16'h8005 : 16'h0));
  end

  assign stateXor = (state ^ 16'hffff);
  assign accXor = (state_8 ^ 16'hffff);
  assign io_result = {stateXor[0],{stateXor[1],{stateXor[2],{stateXor[3],{stateXor[4],{stateXor[5],{stateXor[6],{stateXor[7],{stateXor[8],{_zz_io_result,{_zz_io_result_1,_zz_io_result_2}}}}}}}}}}};
  assign io_resultNext = {accXor[0],{accXor[1],{accXor[2],{accXor[3],{accXor[4],{accXor[5],{accXor[6],{accXor[7],{accXor[8],{_zz_io_resultNext,{_zz_io_resultNext_1,_zz_io_resultNext_2}}}}}}}}}}};
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      state <= 16'hffff;
    end else begin
      if(io_input_valid) begin
        state <= state_8;
      end
      if(io_flush) begin
        state <= 16'hffff;
      end
    end
  end


endmodule

module Crc_1 (
  input               io_flush,
  input               io_input_valid,
  input      [7:0]    io_input_payload,
  output     [15:0]   io_result,
  output     [15:0]   io_resultNext,
  input               ctrl_clk,
  input               ctrl_reset
);

  wire       [15:0]   _zz_state_1;
  wire       [15:0]   _zz_state_2;
  wire       [15:0]   _zz_state_3;
  wire       [15:0]   _zz_state_4;
  wire       [15:0]   _zz_state_5;
  wire       [15:0]   _zz_state_6;
  wire       [15:0]   _zz_state_7;
  wire       [15:0]   _zz_state_8;
  reg        [15:0]   state_8;
  reg        [15:0]   state_7;
  reg        [15:0]   state_6;
  reg        [15:0]   state_5;
  reg        [15:0]   state_4;
  reg        [15:0]   state_3;
  reg        [15:0]   state_2;
  reg        [15:0]   state_1;
  reg        [15:0]   state;
  wire       [15:0]   stateXor;
  wire       [15:0]   accXor;

  assign _zz_state_1 = (state <<< 1);
  assign _zz_state_2 = (state_1 <<< 1);
  assign _zz_state_3 = (state_2 <<< 1);
  assign _zz_state_4 = (state_3 <<< 1);
  assign _zz_state_5 = (state_4 <<< 1);
  assign _zz_state_6 = (state_5 <<< 1);
  assign _zz_state_7 = (state_6 <<< 1);
  assign _zz_state_8 = (state_7 <<< 1);
  always @(*) begin
    state_8 = state_7;
    state_8 = (_zz_state_8 ^ ((io_input_payload[7] ^ state_7[15]) ? 16'h8005 : 16'h0));
  end

  always @(*) begin
    state_7 = state_6;
    state_7 = (_zz_state_7 ^ ((io_input_payload[6] ^ state_6[15]) ? 16'h8005 : 16'h0));
  end

  always @(*) begin
    state_6 = state_5;
    state_6 = (_zz_state_6 ^ ((io_input_payload[5] ^ state_5[15]) ? 16'h8005 : 16'h0));
  end

  always @(*) begin
    state_5 = state_4;
    state_5 = (_zz_state_5 ^ ((io_input_payload[4] ^ state_4[15]) ? 16'h8005 : 16'h0));
  end

  always @(*) begin
    state_4 = state_3;
    state_4 = (_zz_state_4 ^ ((io_input_payload[3] ^ state_3[15]) ? 16'h8005 : 16'h0));
  end

  always @(*) begin
    state_3 = state_2;
    state_3 = (_zz_state_3 ^ ((io_input_payload[2] ^ state_2[15]) ? 16'h8005 : 16'h0));
  end

  always @(*) begin
    state_2 = state_1;
    state_2 = (_zz_state_2 ^ ((io_input_payload[1] ^ state_1[15]) ? 16'h8005 : 16'h0));
  end

  always @(*) begin
    state_1 = state;
    state_1 = (_zz_state_1 ^ ((io_input_payload[0] ^ state[15]) ? 16'h8005 : 16'h0));
  end

  assign stateXor = (state ^ 16'h0);
  assign accXor = (state_8 ^ 16'h0);
  assign io_result = stateXor;
  assign io_resultNext = accXor;
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      state <= 16'hffff;
    end else begin
      if(io_input_valid) begin
        state <= state_8;
      end
      if(io_flush) begin
        state <= 16'hffff;
      end
    end
  end


endmodule

module Crc (
  input               io_flush,
  input               io_input_valid,
  input      [7:0]    io_input_payload,
  output     [4:0]    io_result,
  output     [4:0]    io_resultNext,
  input               ctrl_clk,
  input               ctrl_reset
);

  wire       [4:0]    _zz_state_1;
  wire       [4:0]    _zz_state_2;
  wire       [4:0]    _zz_state_3;
  wire       [4:0]    _zz_state_4;
  wire       [4:0]    _zz_state_5;
  wire       [4:0]    _zz_state_6;
  wire       [4:0]    _zz_state_7;
  wire       [4:0]    _zz_state_8;
  reg        [4:0]    state_8;
  reg        [4:0]    state_7;
  reg        [4:0]    state_6;
  reg        [4:0]    state_5;
  reg        [4:0]    state_4;
  reg        [4:0]    state_3;
  reg        [4:0]    state_2;
  reg        [4:0]    state_1;
  reg        [4:0]    state;
  wire       [4:0]    stateXor;
  wire       [4:0]    accXor;

  assign _zz_state_1 = (state <<< 1);
  assign _zz_state_2 = (state_1 <<< 1);
  assign _zz_state_3 = (state_2 <<< 1);
  assign _zz_state_4 = (state_3 <<< 1);
  assign _zz_state_5 = (state_4 <<< 1);
  assign _zz_state_6 = (state_5 <<< 1);
  assign _zz_state_7 = (state_6 <<< 1);
  assign _zz_state_8 = (state_7 <<< 1);
  always @(*) begin
    state_8 = state_7;
    state_8 = (_zz_state_8 ^ ((io_input_payload[7] ^ state_7[4]) ? 5'h05 : 5'h0));
  end

  always @(*) begin
    state_7 = state_6;
    state_7 = (_zz_state_7 ^ ((io_input_payload[6] ^ state_6[4]) ? 5'h05 : 5'h0));
  end

  always @(*) begin
    state_6 = state_5;
    state_6 = (_zz_state_6 ^ ((io_input_payload[5] ^ state_5[4]) ? 5'h05 : 5'h0));
  end

  always @(*) begin
    state_5 = state_4;
    state_5 = (_zz_state_5 ^ ((io_input_payload[4] ^ state_4[4]) ? 5'h05 : 5'h0));
  end

  always @(*) begin
    state_4 = state_3;
    state_4 = (_zz_state_4 ^ ((io_input_payload[3] ^ state_3[4]) ? 5'h05 : 5'h0));
  end

  always @(*) begin
    state_3 = state_2;
    state_3 = (_zz_state_3 ^ ((io_input_payload[2] ^ state_2[4]) ? 5'h05 : 5'h0));
  end

  always @(*) begin
    state_2 = state_1;
    state_2 = (_zz_state_2 ^ ((io_input_payload[1] ^ state_1[4]) ? 5'h05 : 5'h0));
  end

  always @(*) begin
    state_1 = state;
    state_1 = (_zz_state_1 ^ ((io_input_payload[0] ^ state[4]) ? 5'h05 : 5'h0));
  end

  assign stateXor = (state ^ 5'h0);
  assign accXor = (state_8 ^ 5'h0);
  assign io_result = stateXor;
  assign io_resultNext = accXor;
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      state <= 5'h1f;
    end else begin
      if(io_input_valid) begin
        state <= state_8;
      end
      if(io_flush) begin
        state <= 5'h1f;
      end
    end
  end


endmodule

//BufferCC_4 replaced by BufferCC_4

//BufferCC_4 replaced by BufferCC_4

//BufferCC_4 replaced by BufferCC_4

module BufferCC_4 (
  input               io_dataIn,
  output              io_dataOut,
  input               ctrl_clk,
  input               phy_reset_syncronized
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge ctrl_clk or posedge phy_reset_syncronized) begin
    if(phy_reset_syncronized) begin
      buffers_0 <= 1'b0;
      buffers_1 <= 1'b0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module BufferCC_3 (
  input               io_dataIn,
  output              io_dataOut,
  input               ctrl_clk,
  input               phy_reset
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge ctrl_clk or posedge phy_reset) begin
    if(phy_reset) begin
      buffers_0 <= 1'b1;
      buffers_1 <= 1'b1;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module BufferCC_2 (
  input               io_dataIn,
  output              io_dataOut,
  input               phy_clk,
  input               ctrl_reset_syncronized
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge phy_clk or posedge ctrl_reset_syncronized) begin
    if(ctrl_reset_syncronized) begin
      buffers_0 <= 1'b0;
      buffers_1 <= 1'b0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module BufferCC_1 (
  input               io_dataIn,
  output              io_dataOut,
  input               phy_clk,
  input               ctrl_reset
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge phy_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      buffers_0 <= 1'b1;
      buffers_1 <= 1'b1;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module BufferCC (
  input               io_dataIn,
  output              io_dataOut,
  input               ctrl_clk,
  input               ctrl_reset
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      buffers_0 <= 1'b0;
      buffers_1 <= 1'b0;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule
