// Generator : SpinalHDL v1.6.4    git head : 598c18959149eb18e5eee5b0aa3eef01ecaa41a1
// Component : UsbOhciWishbone
// Git hash  : b0d80358b4b47c5d380af332ceda91c59690daeb

`timescale 1ns/1ps 

module UsbOhciWishbone (
  output              io_dma_CYC,
  output              io_dma_STB,
  input               io_dma_ACK,
  output              io_dma_WE,
  output     [29:0]   io_dma_ADR,
  input      [31:0]   io_dma_DAT_MISO,
  output     [31:0]   io_dma_DAT_MOSI,
  output     [3:0]    io_dma_SEL,
  input               io_dma_ERR,
  output     [2:0]    io_dma_CTI,
  output     [1:0]    io_dma_BTE,
  input               io_ctrl_CYC,
  input               io_ctrl_STB,
  output              io_ctrl_ACK,
  input               io_ctrl_WE,
  input      [9:0]    io_ctrl_ADR,
  output     [31:0]   io_ctrl_DAT_MISO,
  input      [31:0]   io_ctrl_DAT_MOSI,
  input      [3:0]    io_ctrl_SEL,
  output              io_interrupt,
  input               io_usb_0_dp_read,
  output              io_usb_0_dp_write,
  output              io_usb_0_dp_writeEnable,
  input               io_usb_0_dm_read,
  output              io_usb_0_dm_write,
  output              io_usb_0_dm_writeEnable,
  input               io_usb_1_dp_read,
  output              io_usb_1_dp_write,
  output              io_usb_1_dp_writeEnable,
  input               io_usb_1_dm_read,
  output              io_usb_1_dm_write,
  output              io_usb_1_dm_writeEnable,
  input               phy_clk,
  input               phy_reset,
  input               ctrl_clk,
  input               ctrl_reset
);

  wire                front_dmaBridge_io_input_cmd_ready;
  wire                front_dmaBridge_io_input_rsp_valid;
  wire                front_dmaBridge_io_input_rsp_payload_last;
  wire       [0:0]    front_dmaBridge_io_input_rsp_payload_fragment_opcode;
  wire       [31:0]   front_dmaBridge_io_input_rsp_payload_fragment_data;
  wire       [31:0]   front_dmaBridge_io_output_DAT_MOSI;
  wire       [29:0]   front_dmaBridge_io_output_ADR;
  wire                front_dmaBridge_io_output_CYC;
  wire       [3:0]    front_dmaBridge_io_output_SEL;
  wire                front_dmaBridge_io_output_STB;
  wire                front_dmaBridge_io_output_WE;
  wire       [2:0]    front_dmaBridge_io_output_CTI;
  wire       [1:0]    front_dmaBridge_io_output_BTE;
  wire       [31:0]   front_ctrlBridge_io_input_DAT_MISO;
  wire                front_ctrlBridge_io_input_ACK;
  wire                front_ctrlBridge_io_output_cmd_valid;
  wire                front_ctrlBridge_io_output_cmd_payload_last;
  wire       [0:0]    front_ctrlBridge_io_output_cmd_payload_fragment_opcode;
  wire       [11:0]   front_ctrlBridge_io_output_cmd_payload_fragment_address;
  wire       [1:0]    front_ctrlBridge_io_output_cmd_payload_fragment_length;
  wire       [31:0]   front_ctrlBridge_io_output_cmd_payload_fragment_data;
  wire       [3:0]    front_ctrlBridge_io_output_cmd_payload_fragment_mask;
  wire                front_ctrlBridge_io_output_rsp_ready;
  wire                front_ohci_io_ctrl_cmd_ready;
  wire                front_ohci_io_ctrl_rsp_valid;
  wire                front_ohci_io_ctrl_rsp_payload_last;
  wire       [0:0]    front_ohci_io_ctrl_rsp_payload_fragment_opcode;
  wire       [31:0]   front_ohci_io_ctrl_rsp_payload_fragment_data;
  wire                front_ohci_io_phy_lowSpeed;
  wire                front_ohci_io_phy_usbReset;
  wire                front_ohci_io_phy_usbResume;
  wire                front_ohci_io_phy_tx_valid;
  wire                front_ohci_io_phy_tx_payload_last;
  wire       [7:0]    front_ohci_io_phy_tx_payload_fragment;
  wire                front_ohci_io_phy_ports_0_removable;
  wire                front_ohci_io_phy_ports_0_power;
  wire                front_ohci_io_phy_ports_0_reset_valid;
  wire                front_ohci_io_phy_ports_0_suspend_valid;
  wire                front_ohci_io_phy_ports_0_resume_valid;
  wire                front_ohci_io_phy_ports_0_disable_valid;
  wire                front_ohci_io_phy_ports_1_removable;
  wire                front_ohci_io_phy_ports_1_power;
  wire                front_ohci_io_phy_ports_1_reset_valid;
  wire                front_ohci_io_phy_ports_1_suspend_valid;
  wire                front_ohci_io_phy_ports_1_resume_valid;
  wire                front_ohci_io_phy_ports_1_disable_valid;
  wire                front_ohci_io_dma_cmd_valid;
  wire                front_ohci_io_dma_cmd_payload_last;
  wire       [0:0]    front_ohci_io_dma_cmd_payload_fragment_opcode;
  wire       [31:0]   front_ohci_io_dma_cmd_payload_fragment_address;
  wire       [5:0]    front_ohci_io_dma_cmd_payload_fragment_length;
  wire       [31:0]   front_ohci_io_dma_cmd_payload_fragment_data;
  wire       [3:0]    front_ohci_io_dma_cmd_payload_fragment_mask;
  wire                front_ohci_io_dma_rsp_ready;
  wire                front_ohci_io_interrupt;
  wire                front_ohci_io_interruptBios;
  wire                back_phy_io_ctrl_overcurrent;
  wire                back_phy_io_ctrl_tick;
  wire                back_phy_io_ctrl_tx_ready;
  wire                back_phy_io_ctrl_txEop;
  wire                back_phy_io_ctrl_rx_flow_valid;
  wire                back_phy_io_ctrl_rx_flow_payload_stuffingError;
  wire       [7:0]    back_phy_io_ctrl_rx_flow_payload_data;
  wire                back_phy_io_ctrl_rx_active;
  wire                back_phy_io_ctrl_ports_0_reset_ready;
  wire                back_phy_io_ctrl_ports_0_suspend_ready;
  wire                back_phy_io_ctrl_ports_0_resume_ready;
  wire                back_phy_io_ctrl_ports_0_disable_ready;
  wire                back_phy_io_ctrl_ports_0_connect;
  wire                back_phy_io_ctrl_ports_0_disconnect;
  wire                back_phy_io_ctrl_ports_0_overcurrent;
  wire                back_phy_io_ctrl_ports_0_lowSpeed;
  wire                back_phy_io_ctrl_ports_0_remoteResume;
  wire                back_phy_io_ctrl_ports_1_reset_ready;
  wire                back_phy_io_ctrl_ports_1_suspend_ready;
  wire                back_phy_io_ctrl_ports_1_resume_ready;
  wire                back_phy_io_ctrl_ports_1_disable_ready;
  wire                back_phy_io_ctrl_ports_1_connect;
  wire                back_phy_io_ctrl_ports_1_disconnect;
  wire                back_phy_io_ctrl_ports_1_overcurrent;
  wire                back_phy_io_ctrl_ports_1_lowSpeed;
  wire                back_phy_io_ctrl_ports_1_remoteResume;
  wire                back_phy_io_usb_0_tx_enable;
  wire                back_phy_io_usb_0_tx_data;
  wire                back_phy_io_usb_0_tx_se0;
  wire                back_phy_io_usb_1_tx_enable;
  wire                back_phy_io_usb_1_tx_data;
  wire                back_phy_io_usb_1_tx_se0;
  wire                back_phy_io_management_0_power;
  wire                back_phy_io_management_1_power;
  wire                cc_input_overcurrent;
  wire                cc_input_tick;
  wire                cc_input_tx_ready;
  wire                cc_input_txEop;
  wire                cc_input_rx_flow_valid;
  wire                cc_input_rx_flow_payload_stuffingError;
  wire       [7:0]    cc_input_rx_flow_payload_data;
  wire                cc_input_rx_active;
  wire                cc_input_ports_0_reset_ready;
  wire                cc_input_ports_0_suspend_ready;
  wire                cc_input_ports_0_resume_ready;
  wire                cc_input_ports_0_disable_ready;
  wire                cc_input_ports_0_connect;
  wire                cc_input_ports_0_disconnect;
  wire                cc_input_ports_0_overcurrent;
  wire                cc_input_ports_0_lowSpeed;
  wire                cc_input_ports_0_remoteResume;
  wire                cc_input_ports_1_reset_ready;
  wire                cc_input_ports_1_suspend_ready;
  wire                cc_input_ports_1_resume_ready;
  wire                cc_input_ports_1_disable_ready;
  wire                cc_input_ports_1_connect;
  wire                cc_input_ports_1_disconnect;
  wire                cc_input_ports_1_overcurrent;
  wire                cc_input_ports_1_lowSpeed;
  wire                cc_input_ports_1_remoteResume;
  wire                cc_output_lowSpeed;
  wire                cc_output_usbReset;
  wire                cc_output_usbResume;
  wire                cc_output_tx_valid;
  wire                cc_output_tx_payload_last;
  wire       [7:0]    cc_output_tx_payload_fragment;
  wire                cc_output_ports_0_removable;
  wire                cc_output_ports_0_power;
  wire                cc_output_ports_0_reset_valid;
  wire                cc_output_ports_0_suspend_valid;
  wire                cc_output_ports_0_resume_valid;
  wire                cc_output_ports_0_disable_valid;
  wire                cc_output_ports_1_removable;
  wire                cc_output_ports_1_power;
  wire                cc_output_ports_1_reset_valid;
  wire                cc_output_ports_1_suspend_valid;
  wire                cc_output_ports_1_resume_valid;
  wire                cc_output_ports_1_disable_valid;
  wire                back_native_0_dp_read;
  wire                back_native_0_dp_write;
  wire                back_native_0_dp_writeEnable;
  wire                back_native_0_dm_read;
  wire                back_native_0_dm_write;
  wire                back_native_0_dm_writeEnable;
  wire                back_native_1_dp_read;
  wire                back_native_1_dp_write;
  wire                back_native_1_dp_writeEnable;
  wire                back_native_1_dm_read;
  wire                back_native_1_dm_write;
  wire                back_native_1_dm_writeEnable;
  wire                back_buffer_0_dp_read;
  wire                back_buffer_0_dp_write;
  wire                back_buffer_0_dp_writeEnable;
  wire                back_buffer_0_dm_read;
  wire                back_buffer_0_dm_write;
  wire                back_buffer_0_dm_writeEnable;
  wire                back_native_0_dp_stage_read;
  wire                back_native_0_dp_stage_write;
  wire                back_native_0_dp_stage_writeEnable;
  reg                 back_native_0_dp_writeEnable_regNext;
  reg                 back_native_0_dp_write_regNext;
  reg                 back_native_0_dp_stage_read_regNext;
  wire                back_native_0_dm_stage_read;
  wire                back_native_0_dm_stage_write;
  wire                back_native_0_dm_stage_writeEnable;
  reg                 back_native_0_dm_writeEnable_regNext;
  reg                 back_native_0_dm_write_regNext;
  reg                 back_native_0_dm_stage_read_regNext;
  wire                back_buffer_1_dp_read;
  wire                back_buffer_1_dp_write;
  wire                back_buffer_1_dp_writeEnable;
  wire                back_buffer_1_dm_read;
  wire                back_buffer_1_dm_write;
  wire                back_buffer_1_dm_writeEnable;
  wire                back_native_1_dp_stage_read;
  wire                back_native_1_dp_stage_write;
  wire                back_native_1_dp_stage_writeEnable;
  reg                 back_native_1_dp_writeEnable_regNext;
  reg                 back_native_1_dp_write_regNext;
  reg                 back_native_1_dp_stage_read_regNext;
  wire                back_native_1_dm_stage_read;
  wire                back_native_1_dm_stage_write;
  wire                back_native_1_dm_stage_writeEnable;
  reg                 back_native_1_dm_writeEnable_regNext;
  reg                 back_native_1_dm_write_regNext;
  reg                 back_native_1_dm_stage_read_regNext;
  wire                back_buffer_0_dp_stage_read;
  wire                back_buffer_0_dp_stage_write;
  wire                back_buffer_0_dp_stage_writeEnable;
  reg                 back_buffer_0_dp_writeEnable_regNext;
  reg                 back_buffer_0_dp_write_regNext;
  reg                 back_buffer_0_dp_stage_read_regNext;
  wire                back_buffer_0_dm_stage_read;
  wire                back_buffer_0_dm_stage_write;
  wire                back_buffer_0_dm_stage_writeEnable;
  reg                 back_buffer_0_dm_writeEnable_regNext;
  reg                 back_buffer_0_dm_write_regNext;
  reg                 back_buffer_0_dm_stage_read_regNext;
  wire                back_buffer_1_dp_stage_read;
  wire                back_buffer_1_dp_stage_write;
  wire                back_buffer_1_dp_stage_writeEnable;
  reg                 back_buffer_1_dp_writeEnable_regNext;
  reg                 back_buffer_1_dp_write_regNext;
  reg                 back_buffer_1_dp_stage_read_regNext;
  wire                back_buffer_1_dm_stage_read;
  wire                back_buffer_1_dm_stage_write;
  wire                back_buffer_1_dm_stage_writeEnable;
  reg                 back_buffer_1_dm_writeEnable_regNext;
  reg                 back_buffer_1_dm_write_regNext;
  reg                 back_buffer_1_dm_stage_read_regNext;

  UsbOhciWishbone_BmbToWishbone front_dmaBridge (
    .io_input_cmd_valid                       (front_ohci_io_dma_cmd_valid                               ), //i
    .io_input_cmd_ready                       (front_dmaBridge_io_input_cmd_ready                        ), //o
    .io_input_cmd_payload_last                (front_ohci_io_dma_cmd_payload_last                        ), //i
    .io_input_cmd_payload_fragment_opcode     (front_ohci_io_dma_cmd_payload_fragment_opcode             ), //i
    .io_input_cmd_payload_fragment_address    (front_ohci_io_dma_cmd_payload_fragment_address[31:0]      ), //i
    .io_input_cmd_payload_fragment_length     (front_ohci_io_dma_cmd_payload_fragment_length[5:0]        ), //i
    .io_input_cmd_payload_fragment_data       (front_ohci_io_dma_cmd_payload_fragment_data[31:0]         ), //i
    .io_input_cmd_payload_fragment_mask       (front_ohci_io_dma_cmd_payload_fragment_mask[3:0]          ), //i
    .io_input_rsp_valid                       (front_dmaBridge_io_input_rsp_valid                        ), //o
    .io_input_rsp_ready                       (front_ohci_io_dma_rsp_ready                               ), //i
    .io_input_rsp_payload_last                (front_dmaBridge_io_input_rsp_payload_last                 ), //o
    .io_input_rsp_payload_fragment_opcode     (front_dmaBridge_io_input_rsp_payload_fragment_opcode      ), //o
    .io_input_rsp_payload_fragment_data       (front_dmaBridge_io_input_rsp_payload_fragment_data[31:0]  ), //o
    .io_output_CYC                            (front_dmaBridge_io_output_CYC                             ), //o
    .io_output_STB                            (front_dmaBridge_io_output_STB                             ), //o
    .io_output_ACK                            (io_dma_ACK                                                ), //i
    .io_output_WE                             (front_dmaBridge_io_output_WE                              ), //o
    .io_output_ADR                            (front_dmaBridge_io_output_ADR[29:0]                       ), //o
    .io_output_DAT_MISO                       (io_dma_DAT_MISO[31:0]                                     ), //i
    .io_output_DAT_MOSI                       (front_dmaBridge_io_output_DAT_MOSI[31:0]                  ), //o
    .io_output_SEL                            (front_dmaBridge_io_output_SEL[3:0]                        ), //o
    .io_output_ERR                            (io_dma_ERR                                                ), //i
    .io_output_CTI                            (front_dmaBridge_io_output_CTI[2:0]                        ), //o
    .io_output_BTE                            (front_dmaBridge_io_output_BTE[1:0]                        ), //o
    .ctrl_clk                                 (ctrl_clk                                                  ), //i
    .ctrl_reset                               (ctrl_reset                                                )  //i
  );
  UsbOhciWishbone_WishboneToBmb front_ctrlBridge (
    .io_input_CYC                              (io_ctrl_CYC                                                    ), //i
    .io_input_STB                              (io_ctrl_STB                                                    ), //i
    .io_input_ACK                              (front_ctrlBridge_io_input_ACK                                  ), //o
    .io_input_WE                               (io_ctrl_WE                                                     ), //i
    .io_input_ADR                              (io_ctrl_ADR[9:0]                                               ), //i
    .io_input_DAT_MISO                         (front_ctrlBridge_io_input_DAT_MISO[31:0]                       ), //o
    .io_input_DAT_MOSI                         (io_ctrl_DAT_MOSI[31:0]                                         ), //i
    .io_input_SEL                              (io_ctrl_SEL[3:0]                                               ), //i
    .io_output_cmd_valid                       (front_ctrlBridge_io_output_cmd_valid                           ), //o
    .io_output_cmd_ready                       (front_ohci_io_ctrl_cmd_ready                                   ), //i
    .io_output_cmd_payload_last                (front_ctrlBridge_io_output_cmd_payload_last                    ), //o
    .io_output_cmd_payload_fragment_opcode     (front_ctrlBridge_io_output_cmd_payload_fragment_opcode         ), //o
    .io_output_cmd_payload_fragment_address    (front_ctrlBridge_io_output_cmd_payload_fragment_address[11:0]  ), //o
    .io_output_cmd_payload_fragment_length     (front_ctrlBridge_io_output_cmd_payload_fragment_length[1:0]    ), //o
    .io_output_cmd_payload_fragment_data       (front_ctrlBridge_io_output_cmd_payload_fragment_data[31:0]     ), //o
    .io_output_cmd_payload_fragment_mask       (front_ctrlBridge_io_output_cmd_payload_fragment_mask[3:0]      ), //o
    .io_output_rsp_valid                       (front_ohci_io_ctrl_rsp_valid                                   ), //i
    .io_output_rsp_ready                       (front_ctrlBridge_io_output_rsp_ready                           ), //o
    .io_output_rsp_payload_last                (front_ohci_io_ctrl_rsp_payload_last                            ), //i
    .io_output_rsp_payload_fragment_opcode     (front_ohci_io_ctrl_rsp_payload_fragment_opcode                 ), //i
    .io_output_rsp_payload_fragment_data       (front_ohci_io_ctrl_rsp_payload_fragment_data[31:0]             ), //i
    .ctrl_clk                                  (ctrl_clk                                                       ), //i
    .ctrl_reset                                (ctrl_reset                                                     )  //i
  );
  UsbOhciWishbone_UsbOhci front_ohci (
    .io_ctrl_cmd_valid                       (front_ctrlBridge_io_output_cmd_valid                           ), //i
    .io_ctrl_cmd_ready                       (front_ohci_io_ctrl_cmd_ready                                   ), //o
    .io_ctrl_cmd_payload_last                (front_ctrlBridge_io_output_cmd_payload_last                    ), //i
    .io_ctrl_cmd_payload_fragment_opcode     (front_ctrlBridge_io_output_cmd_payload_fragment_opcode         ), //i
    .io_ctrl_cmd_payload_fragment_address    (front_ctrlBridge_io_output_cmd_payload_fragment_address[11:0]  ), //i
    .io_ctrl_cmd_payload_fragment_length     (front_ctrlBridge_io_output_cmd_payload_fragment_length[1:0]    ), //i
    .io_ctrl_cmd_payload_fragment_data       (front_ctrlBridge_io_output_cmd_payload_fragment_data[31:0]     ), //i
    .io_ctrl_cmd_payload_fragment_mask       (front_ctrlBridge_io_output_cmd_payload_fragment_mask[3:0]      ), //i
    .io_ctrl_rsp_valid                       (front_ohci_io_ctrl_rsp_valid                                   ), //o
    .io_ctrl_rsp_ready                       (front_ctrlBridge_io_output_rsp_ready                           ), //i
    .io_ctrl_rsp_payload_last                (front_ohci_io_ctrl_rsp_payload_last                            ), //o
    .io_ctrl_rsp_payload_fragment_opcode     (front_ohci_io_ctrl_rsp_payload_fragment_opcode                 ), //o
    .io_ctrl_rsp_payload_fragment_data       (front_ohci_io_ctrl_rsp_payload_fragment_data[31:0]             ), //o
    .io_phy_lowSpeed                         (front_ohci_io_phy_lowSpeed                                     ), //o
    .io_phy_tx_valid                         (front_ohci_io_phy_tx_valid                                     ), //o
    .io_phy_tx_ready                         (cc_input_tx_ready                                              ), //i
    .io_phy_tx_payload_last                  (front_ohci_io_phy_tx_payload_last                              ), //o
    .io_phy_tx_payload_fragment              (front_ohci_io_phy_tx_payload_fragment[7:0]                     ), //o
    .io_phy_txEop                            (cc_input_txEop                                                 ), //i
    .io_phy_rx_flow_valid                    (cc_input_rx_flow_valid                                         ), //i
    .io_phy_rx_flow_payload_stuffingError    (cc_input_rx_flow_payload_stuffingError                         ), //i
    .io_phy_rx_flow_payload_data             (cc_input_rx_flow_payload_data[7:0]                             ), //i
    .io_phy_rx_active                        (cc_input_rx_active                                             ), //i
    .io_phy_usbReset                         (front_ohci_io_phy_usbReset                                     ), //o
    .io_phy_usbResume                        (front_ohci_io_phy_usbResume                                    ), //o
    .io_phy_overcurrent                      (cc_input_overcurrent                                           ), //i
    .io_phy_tick                             (cc_input_tick                                                  ), //i
    .io_phy_ports_0_disable_valid            (front_ohci_io_phy_ports_0_disable_valid                        ), //o
    .io_phy_ports_0_disable_ready            (cc_input_ports_0_disable_ready                                 ), //i
    .io_phy_ports_0_removable                (front_ohci_io_phy_ports_0_removable                            ), //o
    .io_phy_ports_0_power                    (front_ohci_io_phy_ports_0_power                                ), //o
    .io_phy_ports_0_reset_valid              (front_ohci_io_phy_ports_0_reset_valid                          ), //o
    .io_phy_ports_0_reset_ready              (cc_input_ports_0_reset_ready                                   ), //i
    .io_phy_ports_0_suspend_valid            (front_ohci_io_phy_ports_0_suspend_valid                        ), //o
    .io_phy_ports_0_suspend_ready            (cc_input_ports_0_suspend_ready                                 ), //i
    .io_phy_ports_0_resume_valid             (front_ohci_io_phy_ports_0_resume_valid                         ), //o
    .io_phy_ports_0_resume_ready             (cc_input_ports_0_resume_ready                                  ), //i
    .io_phy_ports_0_connect                  (cc_input_ports_0_connect                                       ), //i
    .io_phy_ports_0_disconnect               (cc_input_ports_0_disconnect                                    ), //i
    .io_phy_ports_0_overcurrent              (cc_input_ports_0_overcurrent                                   ), //i
    .io_phy_ports_0_remoteResume             (cc_input_ports_0_remoteResume                                  ), //i
    .io_phy_ports_0_lowSpeed                 (cc_input_ports_0_lowSpeed                                      ), //i
    .io_phy_ports_1_disable_valid            (front_ohci_io_phy_ports_1_disable_valid                        ), //o
    .io_phy_ports_1_disable_ready            (cc_input_ports_1_disable_ready                                 ), //i
    .io_phy_ports_1_removable                (front_ohci_io_phy_ports_1_removable                            ), //o
    .io_phy_ports_1_power                    (front_ohci_io_phy_ports_1_power                                ), //o
    .io_phy_ports_1_reset_valid              (front_ohci_io_phy_ports_1_reset_valid                          ), //o
    .io_phy_ports_1_reset_ready              (cc_input_ports_1_reset_ready                                   ), //i
    .io_phy_ports_1_suspend_valid            (front_ohci_io_phy_ports_1_suspend_valid                        ), //o
    .io_phy_ports_1_suspend_ready            (cc_input_ports_1_suspend_ready                                 ), //i
    .io_phy_ports_1_resume_valid             (front_ohci_io_phy_ports_1_resume_valid                         ), //o
    .io_phy_ports_1_resume_ready             (cc_input_ports_1_resume_ready                                  ), //i
    .io_phy_ports_1_connect                  (cc_input_ports_1_connect                                       ), //i
    .io_phy_ports_1_disconnect               (cc_input_ports_1_disconnect                                    ), //i
    .io_phy_ports_1_overcurrent              (cc_input_ports_1_overcurrent                                   ), //i
    .io_phy_ports_1_remoteResume             (cc_input_ports_1_remoteResume                                  ), //i
    .io_phy_ports_1_lowSpeed                 (cc_input_ports_1_lowSpeed                                      ), //i
    .io_dma_cmd_valid                        (front_ohci_io_dma_cmd_valid                                    ), //o
    .io_dma_cmd_ready                        (front_dmaBridge_io_input_cmd_ready                             ), //i
    .io_dma_cmd_payload_last                 (front_ohci_io_dma_cmd_payload_last                             ), //o
    .io_dma_cmd_payload_fragment_opcode      (front_ohci_io_dma_cmd_payload_fragment_opcode                  ), //o
    .io_dma_cmd_payload_fragment_address     (front_ohci_io_dma_cmd_payload_fragment_address[31:0]           ), //o
    .io_dma_cmd_payload_fragment_length      (front_ohci_io_dma_cmd_payload_fragment_length[5:0]             ), //o
    .io_dma_cmd_payload_fragment_data        (front_ohci_io_dma_cmd_payload_fragment_data[31:0]              ), //o
    .io_dma_cmd_payload_fragment_mask        (front_ohci_io_dma_cmd_payload_fragment_mask[3:0]               ), //o
    .io_dma_rsp_valid                        (front_dmaBridge_io_input_rsp_valid                             ), //i
    .io_dma_rsp_ready                        (front_ohci_io_dma_rsp_ready                                    ), //o
    .io_dma_rsp_payload_last                 (front_dmaBridge_io_input_rsp_payload_last                      ), //i
    .io_dma_rsp_payload_fragment_opcode      (front_dmaBridge_io_input_rsp_payload_fragment_opcode           ), //i
    .io_dma_rsp_payload_fragment_data        (front_dmaBridge_io_input_rsp_payload_fragment_data[31:0]       ), //i
    .io_interrupt                            (front_ohci_io_interrupt                                        ), //o
    .io_interruptBios                        (front_ohci_io_interruptBios                                    ), //o
    .ctrl_clk                                (ctrl_clk                                                       ), //i
    .ctrl_reset                              (ctrl_reset                                                     )  //i
  );
  UsbOhciWishbone_UsbLsFsPhy back_phy (
    .io_ctrl_lowSpeed                         (cc_output_lowSpeed                              ), //i
    .io_ctrl_tx_valid                         (cc_output_tx_valid                              ), //i
    .io_ctrl_tx_ready                         (back_phy_io_ctrl_tx_ready                       ), //o
    .io_ctrl_tx_payload_last                  (cc_output_tx_payload_last                       ), //i
    .io_ctrl_tx_payload_fragment              (cc_output_tx_payload_fragment[7:0]              ), //i
    .io_ctrl_txEop                            (back_phy_io_ctrl_txEop                          ), //o
    .io_ctrl_rx_flow_valid                    (back_phy_io_ctrl_rx_flow_valid                  ), //o
    .io_ctrl_rx_flow_payload_stuffingError    (back_phy_io_ctrl_rx_flow_payload_stuffingError  ), //o
    .io_ctrl_rx_flow_payload_data             (back_phy_io_ctrl_rx_flow_payload_data[7:0]      ), //o
    .io_ctrl_rx_active                        (back_phy_io_ctrl_rx_active                      ), //o
    .io_ctrl_usbReset                         (cc_output_usbReset                              ), //i
    .io_ctrl_usbResume                        (cc_output_usbResume                             ), //i
    .io_ctrl_overcurrent                      (back_phy_io_ctrl_overcurrent                    ), //o
    .io_ctrl_tick                             (back_phy_io_ctrl_tick                           ), //o
    .io_ctrl_ports_0_disable_valid            (cc_output_ports_0_disable_valid                 ), //i
    .io_ctrl_ports_0_disable_ready            (back_phy_io_ctrl_ports_0_disable_ready          ), //o
    .io_ctrl_ports_0_removable                (cc_output_ports_0_removable                     ), //i
    .io_ctrl_ports_0_power                    (cc_output_ports_0_power                         ), //i
    .io_ctrl_ports_0_reset_valid              (cc_output_ports_0_reset_valid                   ), //i
    .io_ctrl_ports_0_reset_ready              (back_phy_io_ctrl_ports_0_reset_ready            ), //o
    .io_ctrl_ports_0_suspend_valid            (cc_output_ports_0_suspend_valid                 ), //i
    .io_ctrl_ports_0_suspend_ready            (back_phy_io_ctrl_ports_0_suspend_ready          ), //o
    .io_ctrl_ports_0_resume_valid             (cc_output_ports_0_resume_valid                  ), //i
    .io_ctrl_ports_0_resume_ready             (back_phy_io_ctrl_ports_0_resume_ready           ), //o
    .io_ctrl_ports_0_connect                  (back_phy_io_ctrl_ports_0_connect                ), //o
    .io_ctrl_ports_0_disconnect               (back_phy_io_ctrl_ports_0_disconnect             ), //o
    .io_ctrl_ports_0_overcurrent              (back_phy_io_ctrl_ports_0_overcurrent            ), //o
    .io_ctrl_ports_0_remoteResume             (back_phy_io_ctrl_ports_0_remoteResume           ), //o
    .io_ctrl_ports_0_lowSpeed                 (back_phy_io_ctrl_ports_0_lowSpeed               ), //o
    .io_ctrl_ports_1_disable_valid            (cc_output_ports_1_disable_valid                 ), //i
    .io_ctrl_ports_1_disable_ready            (back_phy_io_ctrl_ports_1_disable_ready          ), //o
    .io_ctrl_ports_1_removable                (cc_output_ports_1_removable                     ), //i
    .io_ctrl_ports_1_power                    (cc_output_ports_1_power                         ), //i
    .io_ctrl_ports_1_reset_valid              (cc_output_ports_1_reset_valid                   ), //i
    .io_ctrl_ports_1_reset_ready              (back_phy_io_ctrl_ports_1_reset_ready            ), //o
    .io_ctrl_ports_1_suspend_valid            (cc_output_ports_1_suspend_valid                 ), //i
    .io_ctrl_ports_1_suspend_ready            (back_phy_io_ctrl_ports_1_suspend_ready          ), //o
    .io_ctrl_ports_1_resume_valid             (cc_output_ports_1_resume_valid                  ), //i
    .io_ctrl_ports_1_resume_ready             (back_phy_io_ctrl_ports_1_resume_ready           ), //o
    .io_ctrl_ports_1_connect                  (back_phy_io_ctrl_ports_1_connect                ), //o
    .io_ctrl_ports_1_disconnect               (back_phy_io_ctrl_ports_1_disconnect             ), //o
    .io_ctrl_ports_1_overcurrent              (back_phy_io_ctrl_ports_1_overcurrent            ), //o
    .io_ctrl_ports_1_remoteResume             (back_phy_io_ctrl_ports_1_remoteResume           ), //o
    .io_ctrl_ports_1_lowSpeed                 (back_phy_io_ctrl_ports_1_lowSpeed               ), //o
    .io_usb_0_tx_enable                       (back_phy_io_usb_0_tx_enable                     ), //o
    .io_usb_0_tx_data                         (back_phy_io_usb_0_tx_data                       ), //o
    .io_usb_0_tx_se0                          (back_phy_io_usb_0_tx_se0                        ), //o
    .io_usb_0_rx_dp                           (back_native_0_dp_read                           ), //i
    .io_usb_0_rx_dm                           (back_native_0_dm_read                           ), //i
    .io_usb_1_tx_enable                       (back_phy_io_usb_1_tx_enable                     ), //o
    .io_usb_1_tx_data                         (back_phy_io_usb_1_tx_data                       ), //o
    .io_usb_1_tx_se0                          (back_phy_io_usb_1_tx_se0                        ), //o
    .io_usb_1_rx_dp                           (back_native_1_dp_read                           ), //i
    .io_usb_1_rx_dm                           (back_native_1_dm_read                           ), //i
    .io_management_0_overcurrent              (1'b0                                            ), //i
    .io_management_0_power                    (back_phy_io_management_0_power                  ), //o
    .io_management_1_overcurrent              (1'b0                                            ), //i
    .io_management_1_power                    (back_phy_io_management_1_power                  ), //o
    .phy_clk                                  (phy_clk                                         ), //i
    .phy_reset                                (phy_reset                                       )  //i
  );
  UsbOhciWishbone_CtrlCc cc (
    .input_lowSpeed                          (front_ohci_io_phy_lowSpeed                      ), //i
    .input_tx_valid                          (front_ohci_io_phy_tx_valid                      ), //i
    .input_tx_ready                          (cc_input_tx_ready                               ), //o
    .input_tx_payload_last                   (front_ohci_io_phy_tx_payload_last               ), //i
    .input_tx_payload_fragment               (front_ohci_io_phy_tx_payload_fragment[7:0]      ), //i
    .input_txEop                             (cc_input_txEop                                  ), //o
    .input_rx_flow_valid                     (cc_input_rx_flow_valid                          ), //o
    .input_rx_flow_payload_stuffingError     (cc_input_rx_flow_payload_stuffingError          ), //o
    .input_rx_flow_payload_data              (cc_input_rx_flow_payload_data[7:0]              ), //o
    .input_rx_active                         (cc_input_rx_active                              ), //o
    .input_usbReset                          (front_ohci_io_phy_usbReset                      ), //i
    .input_usbResume                         (front_ohci_io_phy_usbResume                     ), //i
    .input_overcurrent                       (cc_input_overcurrent                            ), //o
    .input_tick                              (cc_input_tick                                   ), //o
    .input_ports_0_disable_valid             (front_ohci_io_phy_ports_0_disable_valid         ), //i
    .input_ports_0_disable_ready             (cc_input_ports_0_disable_ready                  ), //o
    .input_ports_0_removable                 (front_ohci_io_phy_ports_0_removable             ), //i
    .input_ports_0_power                     (front_ohci_io_phy_ports_0_power                 ), //i
    .input_ports_0_reset_valid               (front_ohci_io_phy_ports_0_reset_valid           ), //i
    .input_ports_0_reset_ready               (cc_input_ports_0_reset_ready                    ), //o
    .input_ports_0_suspend_valid             (front_ohci_io_phy_ports_0_suspend_valid         ), //i
    .input_ports_0_suspend_ready             (cc_input_ports_0_suspend_ready                  ), //o
    .input_ports_0_resume_valid              (front_ohci_io_phy_ports_0_resume_valid          ), //i
    .input_ports_0_resume_ready              (cc_input_ports_0_resume_ready                   ), //o
    .input_ports_0_connect                   (cc_input_ports_0_connect                        ), //o
    .input_ports_0_disconnect                (cc_input_ports_0_disconnect                     ), //o
    .input_ports_0_overcurrent               (cc_input_ports_0_overcurrent                    ), //o
    .input_ports_0_remoteResume              (cc_input_ports_0_remoteResume                   ), //o
    .input_ports_0_lowSpeed                  (cc_input_ports_0_lowSpeed                       ), //o
    .input_ports_1_disable_valid             (front_ohci_io_phy_ports_1_disable_valid         ), //i
    .input_ports_1_disable_ready             (cc_input_ports_1_disable_ready                  ), //o
    .input_ports_1_removable                 (front_ohci_io_phy_ports_1_removable             ), //i
    .input_ports_1_power                     (front_ohci_io_phy_ports_1_power                 ), //i
    .input_ports_1_reset_valid               (front_ohci_io_phy_ports_1_reset_valid           ), //i
    .input_ports_1_reset_ready               (cc_input_ports_1_reset_ready                    ), //o
    .input_ports_1_suspend_valid             (front_ohci_io_phy_ports_1_suspend_valid         ), //i
    .input_ports_1_suspend_ready             (cc_input_ports_1_suspend_ready                  ), //o
    .input_ports_1_resume_valid              (front_ohci_io_phy_ports_1_resume_valid          ), //i
    .input_ports_1_resume_ready              (cc_input_ports_1_resume_ready                   ), //o
    .input_ports_1_connect                   (cc_input_ports_1_connect                        ), //o
    .input_ports_1_disconnect                (cc_input_ports_1_disconnect                     ), //o
    .input_ports_1_overcurrent               (cc_input_ports_1_overcurrent                    ), //o
    .input_ports_1_remoteResume              (cc_input_ports_1_remoteResume                   ), //o
    .input_ports_1_lowSpeed                  (cc_input_ports_1_lowSpeed                       ), //o
    .output_lowSpeed                         (cc_output_lowSpeed                              ), //o
    .output_tx_valid                         (cc_output_tx_valid                              ), //o
    .output_tx_ready                         (back_phy_io_ctrl_tx_ready                       ), //i
    .output_tx_payload_last                  (cc_output_tx_payload_last                       ), //o
    .output_tx_payload_fragment              (cc_output_tx_payload_fragment[7:0]              ), //o
    .output_txEop                            (back_phy_io_ctrl_txEop                          ), //i
    .output_rx_flow_valid                    (back_phy_io_ctrl_rx_flow_valid                  ), //i
    .output_rx_flow_payload_stuffingError    (back_phy_io_ctrl_rx_flow_payload_stuffingError  ), //i
    .output_rx_flow_payload_data             (back_phy_io_ctrl_rx_flow_payload_data[7:0]      ), //i
    .output_rx_active                        (back_phy_io_ctrl_rx_active                      ), //i
    .output_usbReset                         (cc_output_usbReset                              ), //o
    .output_usbResume                        (cc_output_usbResume                             ), //o
    .output_overcurrent                      (back_phy_io_ctrl_overcurrent                    ), //i
    .output_tick                             (back_phy_io_ctrl_tick                           ), //i
    .output_ports_0_disable_valid            (cc_output_ports_0_disable_valid                 ), //o
    .output_ports_0_disable_ready            (back_phy_io_ctrl_ports_0_disable_ready          ), //i
    .output_ports_0_removable                (cc_output_ports_0_removable                     ), //o
    .output_ports_0_power                    (cc_output_ports_0_power                         ), //o
    .output_ports_0_reset_valid              (cc_output_ports_0_reset_valid                   ), //o
    .output_ports_0_reset_ready              (back_phy_io_ctrl_ports_0_reset_ready            ), //i
    .output_ports_0_suspend_valid            (cc_output_ports_0_suspend_valid                 ), //o
    .output_ports_0_suspend_ready            (back_phy_io_ctrl_ports_0_suspend_ready          ), //i
    .output_ports_0_resume_valid             (cc_output_ports_0_resume_valid                  ), //o
    .output_ports_0_resume_ready             (back_phy_io_ctrl_ports_0_resume_ready           ), //i
    .output_ports_0_connect                  (back_phy_io_ctrl_ports_0_connect                ), //i
    .output_ports_0_disconnect               (back_phy_io_ctrl_ports_0_disconnect             ), //i
    .output_ports_0_overcurrent              (back_phy_io_ctrl_ports_0_overcurrent            ), //i
    .output_ports_0_remoteResume             (back_phy_io_ctrl_ports_0_remoteResume           ), //i
    .output_ports_0_lowSpeed                 (back_phy_io_ctrl_ports_0_lowSpeed               ), //i
    .output_ports_1_disable_valid            (cc_output_ports_1_disable_valid                 ), //o
    .output_ports_1_disable_ready            (back_phy_io_ctrl_ports_1_disable_ready          ), //i
    .output_ports_1_removable                (cc_output_ports_1_removable                     ), //o
    .output_ports_1_power                    (cc_output_ports_1_power                         ), //o
    .output_ports_1_reset_valid              (cc_output_ports_1_reset_valid                   ), //o
    .output_ports_1_reset_ready              (back_phy_io_ctrl_ports_1_reset_ready            ), //i
    .output_ports_1_suspend_valid            (cc_output_ports_1_suspend_valid                 ), //o
    .output_ports_1_suspend_ready            (back_phy_io_ctrl_ports_1_suspend_ready          ), //i
    .output_ports_1_resume_valid             (cc_output_ports_1_resume_valid                  ), //o
    .output_ports_1_resume_ready             (back_phy_io_ctrl_ports_1_resume_ready           ), //i
    .output_ports_1_connect                  (back_phy_io_ctrl_ports_1_connect                ), //i
    .output_ports_1_disconnect               (back_phy_io_ctrl_ports_1_disconnect             ), //i
    .output_ports_1_overcurrent              (back_phy_io_ctrl_ports_1_overcurrent            ), //i
    .output_ports_1_remoteResume             (back_phy_io_ctrl_ports_1_remoteResume           ), //i
    .output_ports_1_lowSpeed                 (back_phy_io_ctrl_ports_1_lowSpeed               ), //i
    .phy_clk                                 (phy_clk                                         ), //i
    .phy_reset                               (phy_reset                                       ), //i
    .ctrl_clk                                (ctrl_clk                                        ), //i
    .ctrl_reset                              (ctrl_reset                                      )  //i
  );
  assign io_dma_CYC = front_dmaBridge_io_output_CYC;
  assign io_dma_STB = front_dmaBridge_io_output_STB;
  assign io_dma_WE = front_dmaBridge_io_output_WE;
  assign io_dma_ADR = front_dmaBridge_io_output_ADR;
  assign io_dma_DAT_MOSI = front_dmaBridge_io_output_DAT_MOSI;
  assign io_dma_SEL = front_dmaBridge_io_output_SEL;
  assign io_dma_CTI = front_dmaBridge_io_output_CTI;
  assign io_dma_BTE = front_dmaBridge_io_output_BTE;
  assign io_ctrl_ACK = front_ctrlBridge_io_input_ACK;
  assign io_ctrl_DAT_MISO = front_ctrlBridge_io_input_DAT_MISO;
  assign io_interrupt = front_ohci_io_interrupt;
  assign back_native_0_dp_writeEnable = back_phy_io_usb_0_tx_enable;
  assign back_native_0_dm_writeEnable = back_phy_io_usb_0_tx_enable;
  assign back_native_0_dp_write = ((! back_phy_io_usb_0_tx_se0) && back_phy_io_usb_0_tx_data);
  assign back_native_0_dm_write = ((! back_phy_io_usb_0_tx_se0) && (! back_phy_io_usb_0_tx_data));
  assign back_native_1_dp_writeEnable = back_phy_io_usb_1_tx_enable;
  assign back_native_1_dm_writeEnable = back_phy_io_usb_1_tx_enable;
  assign back_native_1_dp_write = ((! back_phy_io_usb_1_tx_se0) && back_phy_io_usb_1_tx_data);
  assign back_native_1_dm_write = ((! back_phy_io_usb_1_tx_se0) && (! back_phy_io_usb_1_tx_data));
  assign back_native_0_dp_stage_writeEnable = back_native_0_dp_writeEnable_regNext;
  assign back_native_0_dp_stage_write = back_native_0_dp_write_regNext;
  assign back_native_0_dp_read = back_native_0_dp_stage_read_regNext;
  assign back_buffer_0_dp_writeEnable = back_native_0_dp_stage_writeEnable;
  assign back_buffer_0_dp_write = back_native_0_dp_stage_write;
  assign back_native_0_dp_stage_read = back_buffer_0_dp_read;
  assign back_native_0_dm_stage_writeEnable = back_native_0_dm_writeEnable_regNext;
  assign back_native_0_dm_stage_write = back_native_0_dm_write_regNext;
  assign back_native_0_dm_read = back_native_0_dm_stage_read_regNext;
  assign back_buffer_0_dm_writeEnable = back_native_0_dm_stage_writeEnable;
  assign back_buffer_0_dm_write = back_native_0_dm_stage_write;
  assign back_native_0_dm_stage_read = back_buffer_0_dm_read;
  assign back_native_1_dp_stage_writeEnable = back_native_1_dp_writeEnable_regNext;
  assign back_native_1_dp_stage_write = back_native_1_dp_write_regNext;
  assign back_native_1_dp_read = back_native_1_dp_stage_read_regNext;
  assign back_buffer_1_dp_writeEnable = back_native_1_dp_stage_writeEnable;
  assign back_buffer_1_dp_write = back_native_1_dp_stage_write;
  assign back_native_1_dp_stage_read = back_buffer_1_dp_read;
  assign back_native_1_dm_stage_writeEnable = back_native_1_dm_writeEnable_regNext;
  assign back_native_1_dm_stage_write = back_native_1_dm_write_regNext;
  assign back_native_1_dm_read = back_native_1_dm_stage_read_regNext;
  assign back_buffer_1_dm_writeEnable = back_native_1_dm_stage_writeEnable;
  assign back_buffer_1_dm_write = back_native_1_dm_stage_write;
  assign back_native_1_dm_stage_read = back_buffer_1_dm_read;
  assign back_buffer_0_dp_stage_writeEnable = back_buffer_0_dp_writeEnable_regNext;
  assign back_buffer_0_dp_stage_write = back_buffer_0_dp_write_regNext;
  assign back_buffer_0_dp_read = back_buffer_0_dp_stage_read_regNext;
  assign back_buffer_0_dp_stage_read = io_usb_0_dp_read;
  assign back_buffer_0_dm_stage_writeEnable = back_buffer_0_dm_writeEnable_regNext;
  assign back_buffer_0_dm_stage_write = back_buffer_0_dm_write_regNext;
  assign back_buffer_0_dm_read = back_buffer_0_dm_stage_read_regNext;
  assign back_buffer_0_dm_stage_read = io_usb_0_dm_read;
  assign back_buffer_1_dp_stage_writeEnable = back_buffer_1_dp_writeEnable_regNext;
  assign back_buffer_1_dp_stage_write = back_buffer_1_dp_write_regNext;
  assign back_buffer_1_dp_read = back_buffer_1_dp_stage_read_regNext;
  assign back_buffer_1_dp_stage_read = io_usb_1_dp_read;
  assign back_buffer_1_dm_stage_writeEnable = back_buffer_1_dm_writeEnable_regNext;
  assign back_buffer_1_dm_stage_write = back_buffer_1_dm_write_regNext;
  assign back_buffer_1_dm_read = back_buffer_1_dm_stage_read_regNext;
  assign back_buffer_1_dm_stage_read = io_usb_1_dm_read;
  assign io_usb_0_dp_write = back_buffer_0_dp_stage_write;
  assign io_usb_0_dp_writeEnable = back_buffer_0_dp_stage_writeEnable;
  assign io_usb_0_dm_write = back_buffer_0_dm_stage_write;
  assign io_usb_0_dm_writeEnable = back_buffer_0_dm_stage_writeEnable;
  assign io_usb_1_dp_write = back_buffer_1_dp_stage_write;
  assign io_usb_1_dp_writeEnable = back_buffer_1_dp_stage_writeEnable;
  assign io_usb_1_dm_write = back_buffer_1_dm_stage_write;
  assign io_usb_1_dm_writeEnable = back_buffer_1_dm_stage_writeEnable;
  always @(posedge phy_clk) begin
    back_native_0_dp_writeEnable_regNext <= back_native_0_dp_writeEnable;
    back_native_0_dp_write_regNext <= back_native_0_dp_write;
    back_native_0_dp_stage_read_regNext <= back_native_0_dp_stage_read;
    back_native_0_dm_writeEnable_regNext <= back_native_0_dm_writeEnable;
    back_native_0_dm_write_regNext <= back_native_0_dm_write;
    back_native_0_dm_stage_read_regNext <= back_native_0_dm_stage_read;
    back_native_1_dp_writeEnable_regNext <= back_native_1_dp_writeEnable;
    back_native_1_dp_write_regNext <= back_native_1_dp_write;
    back_native_1_dp_stage_read_regNext <= back_native_1_dp_stage_read;
    back_native_1_dm_writeEnable_regNext <= back_native_1_dm_writeEnable;
    back_native_1_dm_write_regNext <= back_native_1_dm_write;
    back_native_1_dm_stage_read_regNext <= back_native_1_dm_stage_read;
    back_buffer_0_dp_writeEnable_regNext <= back_buffer_0_dp_writeEnable;
    back_buffer_0_dp_write_regNext <= back_buffer_0_dp_write;
    back_buffer_0_dp_stage_read_regNext <= back_buffer_0_dp_stage_read;
    back_buffer_0_dm_writeEnable_regNext <= back_buffer_0_dm_writeEnable;
    back_buffer_0_dm_write_regNext <= back_buffer_0_dm_write;
    back_buffer_0_dm_stage_read_regNext <= back_buffer_0_dm_stage_read;
    back_buffer_1_dp_writeEnable_regNext <= back_buffer_1_dp_writeEnable;
    back_buffer_1_dp_write_regNext <= back_buffer_1_dp_write;
    back_buffer_1_dp_stage_read_regNext <= back_buffer_1_dp_stage_read;
    back_buffer_1_dm_writeEnable_regNext <= back_buffer_1_dm_writeEnable;
    back_buffer_1_dm_write_regNext <= back_buffer_1_dm_write;
    back_buffer_1_dm_stage_read_regNext <= back_buffer_1_dm_stage_read;
  end


endmodule

module UsbOhciWishbone_CtrlCc (
  input               input_lowSpeed,
  input               input_tx_valid,
  output              input_tx_ready,
  input               input_tx_payload_last,
  input      [7:0]    input_tx_payload_fragment,
  output              input_txEop,
  output              input_rx_flow_valid,
  output              input_rx_flow_payload_stuffingError,
  output     [7:0]    input_rx_flow_payload_data,
  output              input_rx_active,
  input               input_usbReset,
  input               input_usbResume,
  output              input_overcurrent,
  output              input_tick,
  input               input_ports_0_disable_valid,
  output              input_ports_0_disable_ready,
  input               input_ports_0_removable,
  input               input_ports_0_power,
  input               input_ports_0_reset_valid,
  output              input_ports_0_reset_ready,
  input               input_ports_0_suspend_valid,
  output              input_ports_0_suspend_ready,
  input               input_ports_0_resume_valid,
  output              input_ports_0_resume_ready,
  output              input_ports_0_connect,
  output              input_ports_0_disconnect,
  output              input_ports_0_overcurrent,
  output              input_ports_0_remoteResume,
  output              input_ports_0_lowSpeed,
  input               input_ports_1_disable_valid,
  output              input_ports_1_disable_ready,
  input               input_ports_1_removable,
  input               input_ports_1_power,
  input               input_ports_1_reset_valid,
  output              input_ports_1_reset_ready,
  input               input_ports_1_suspend_valid,
  output              input_ports_1_suspend_ready,
  input               input_ports_1_resume_valid,
  output              input_ports_1_resume_ready,
  output              input_ports_1_connect,
  output              input_ports_1_disconnect,
  output              input_ports_1_overcurrent,
  output              input_ports_1_remoteResume,
  output              input_ports_1_lowSpeed,
  output              output_lowSpeed,
  output              output_tx_valid,
  input               output_tx_ready,
  output              output_tx_payload_last,
  output     [7:0]    output_tx_payload_fragment,
  input               output_txEop,
  input               output_rx_flow_valid,
  input               output_rx_flow_payload_stuffingError,
  input      [7:0]    output_rx_flow_payload_data,
  input               output_rx_active,
  output              output_usbReset,
  output              output_usbResume,
  input               output_overcurrent,
  input               output_tick,
  output              output_ports_0_disable_valid,
  input               output_ports_0_disable_ready,
  output              output_ports_0_removable,
  output              output_ports_0_power,
  output              output_ports_0_reset_valid,
  input               output_ports_0_reset_ready,
  output              output_ports_0_suspend_valid,
  input               output_ports_0_suspend_ready,
  output              output_ports_0_resume_valid,
  input               output_ports_0_resume_ready,
  input               output_ports_0_connect,
  input               output_ports_0_disconnect,
  input               output_ports_0_overcurrent,
  input               output_ports_0_remoteResume,
  input               output_ports_0_lowSpeed,
  output              output_ports_1_disable_valid,
  input               output_ports_1_disable_ready,
  output              output_ports_1_removable,
  output              output_ports_1_power,
  output              output_ports_1_reset_valid,
  input               output_ports_1_reset_ready,
  output              output_ports_1_suspend_valid,
  input               output_ports_1_suspend_ready,
  output              output_ports_1_resume_valid,
  input               output_ports_1_resume_ready,
  input               output_ports_1_connect,
  input               output_ports_1_disconnect,
  input               output_ports_1_overcurrent,
  input               output_ports_1_remoteResume,
  input               output_ports_1_lowSpeed,
  input               phy_clk,
  input               phy_reset,
  input               ctrl_clk,
  input               ctrl_reset
);

  reg                 input_tx_ccToggle_io_output_ready;
  wire                input_lowSpeed_buffercc_io_dataOut;
  wire                input_usbReset_buffercc_io_dataOut;
  wire                input_usbResume_buffercc_io_dataOut;
  wire                output_overcurrent_buffercc_io_dataOut;
  wire                input_tx_ccToggle_io_input_ready;
  wire                input_tx_ccToggle_io_output_valid;
  wire                input_tx_ccToggle_io_output_payload_last;
  wire       [7:0]    input_tx_ccToggle_io_output_payload_fragment;
  wire                input_tx_ccToggle_ctrl_reset_syncronized_1;
  wire                pulseCCByToggle_io_pulseOut;
  wire                pulseCCByToggle_phy_reset_syncronized_1;
  wire                output_rx_flow_ccToggle_io_output_valid;
  wire                output_rx_flow_ccToggle_io_output_payload_stuffingError;
  wire       [7:0]    output_rx_flow_ccToggle_io_output_payload_data;
  wire                output_rx_active_buffercc_io_dataOut;
  wire                pulseCCByToggle_1_io_pulseOut;
  wire                input_ports_0_removable_buffercc_io_dataOut;
  wire                input_ports_0_power_buffercc_io_dataOut;
  wire                output_ports_0_lowSpeed_buffercc_io_dataOut;
  wire                output_ports_0_overcurrent_buffercc_io_dataOut;
  wire                pulseCCByToggle_2_io_pulseOut;
  wire                pulseCCByToggle_3_io_pulseOut;
  wire                pulseCCByToggle_4_io_pulseOut;
  wire                input_ports_0_reset_ccToggle_io_input_ready;
  wire                input_ports_0_reset_ccToggle_io_output_valid;
  wire                input_ports_0_suspend_ccToggle_io_input_ready;
  wire                input_ports_0_suspend_ccToggle_io_output_valid;
  wire                input_ports_0_resume_ccToggle_io_input_ready;
  wire                input_ports_0_resume_ccToggle_io_output_valid;
  wire                input_ports_0_disable_ccToggle_io_input_ready;
  wire                input_ports_0_disable_ccToggle_io_output_valid;
  wire                input_ports_1_removable_buffercc_io_dataOut;
  wire                input_ports_1_power_buffercc_io_dataOut;
  wire                output_ports_1_lowSpeed_buffercc_io_dataOut;
  wire                output_ports_1_overcurrent_buffercc_io_dataOut;
  wire                pulseCCByToggle_5_io_pulseOut;
  wire                pulseCCByToggle_6_io_pulseOut;
  wire                pulseCCByToggle_7_io_pulseOut;
  wire                input_ports_1_reset_ccToggle_io_input_ready;
  wire                input_ports_1_reset_ccToggle_io_output_valid;
  wire                input_ports_1_suspend_ccToggle_io_input_ready;
  wire                input_ports_1_suspend_ccToggle_io_output_valid;
  wire                input_ports_1_resume_ccToggle_io_input_ready;
  wire                input_ports_1_resume_ccToggle_io_output_valid;
  wire                input_ports_1_disable_ccToggle_io_input_ready;
  wire                input_ports_1_disable_ccToggle_io_output_valid;
  wire                input_tx_ccToggle_io_output_m2sPipe_valid;
  wire                input_tx_ccToggle_io_output_m2sPipe_ready;
  wire                input_tx_ccToggle_io_output_m2sPipe_payload_last;
  wire       [7:0]    input_tx_ccToggle_io_output_m2sPipe_payload_fragment;
  reg                 input_tx_ccToggle_io_output_rValid;
  reg                 input_tx_ccToggle_io_output_rData_last;
  reg        [7:0]    input_tx_ccToggle_io_output_rData_fragment;
  wire                when_Stream_l342;

  UsbOhciWishbone_BufferCC_29 input_lowSpeed_buffercc (
    .io_dataIn     (input_lowSpeed                      ), //i
    .io_dataOut    (input_lowSpeed_buffercc_io_dataOut  ), //o
    .phy_clk       (phy_clk                             ), //i
    .phy_reset     (phy_reset                           )  //i
  );
  UsbOhciWishbone_BufferCC_29 input_usbReset_buffercc (
    .io_dataIn     (input_usbReset                      ), //i
    .io_dataOut    (input_usbReset_buffercc_io_dataOut  ), //o
    .phy_clk       (phy_clk                             ), //i
    .phy_reset     (phy_reset                           )  //i
  );
  UsbOhciWishbone_BufferCC_29 input_usbResume_buffercc (
    .io_dataIn     (input_usbResume                      ), //i
    .io_dataOut    (input_usbResume_buffercc_io_dataOut  ), //o
    .phy_clk       (phy_clk                              ), //i
    .phy_reset     (phy_reset                            )  //i
  );
  UsbOhciWishbone_BufferCC_32 output_overcurrent_buffercc (
    .io_dataIn     (output_overcurrent                      ), //i
    .io_dataOut    (output_overcurrent_buffercc_io_dataOut  ), //o
    .ctrl_clk      (ctrl_clk                                ), //i
    .ctrl_reset    (ctrl_reset                              )  //i
  );
  UsbOhciWishbone_StreamCCByToggle input_tx_ccToggle (
    .io_input_valid                (input_tx_valid                                     ), //i
    .io_input_ready                (input_tx_ccToggle_io_input_ready                   ), //o
    .io_input_payload_last         (input_tx_payload_last                              ), //i
    .io_input_payload_fragment     (input_tx_payload_fragment[7:0]                     ), //i
    .io_output_valid               (input_tx_ccToggle_io_output_valid                  ), //o
    .io_output_ready               (input_tx_ccToggle_io_output_ready                  ), //i
    .io_output_payload_last        (input_tx_ccToggle_io_output_payload_last           ), //o
    .io_output_payload_fragment    (input_tx_ccToggle_io_output_payload_fragment[7:0]  ), //o
    .ctrl_clk                      (ctrl_clk                                           ), //i
    .ctrl_reset                    (ctrl_reset                                         ), //i
    .phy_clk                       (phy_clk                                            ), //i
    .ctrl_reset_syncronized_1      (input_tx_ccToggle_ctrl_reset_syncronized_1         )  //o
  );
  UsbOhciWishbone_PulseCCByToggle pulseCCByToggle (
    .io_pulseIn                 (output_txEop                             ), //i
    .io_pulseOut                (pulseCCByToggle_io_pulseOut              ), //o
    .phy_clk                    (phy_clk                                  ), //i
    .phy_reset                  (phy_reset                                ), //i
    .ctrl_clk                   (ctrl_clk                                 ), //i
    .phy_reset_syncronized_1    (pulseCCByToggle_phy_reset_syncronized_1  )  //o
  );
  UsbOhciWishbone_FlowCCByToggle output_rx_flow_ccToggle (
    .io_input_valid                     (output_rx_flow_valid                                     ), //i
    .io_input_payload_stuffingError     (output_rx_flow_payload_stuffingError                     ), //i
    .io_input_payload_data              (output_rx_flow_payload_data[7:0]                         ), //i
    .io_output_valid                    (output_rx_flow_ccToggle_io_output_valid                  ), //o
    .io_output_payload_stuffingError    (output_rx_flow_ccToggle_io_output_payload_stuffingError  ), //o
    .io_output_payload_data             (output_rx_flow_ccToggle_io_output_payload_data[7:0]      ), //o
    .phy_clk                            (phy_clk                                                  ), //i
    .phy_reset                          (phy_reset                                                ), //i
    .ctrl_clk                           (ctrl_clk                                                 ), //i
    .phy_reset_syncronized              (pulseCCByToggle_phy_reset_syncronized_1                  )  //i
  );
  UsbOhciWishbone_BufferCC_32 output_rx_active_buffercc (
    .io_dataIn     (output_rx_active                      ), //i
    .io_dataOut    (output_rx_active_buffercc_io_dataOut  ), //o
    .ctrl_clk      (ctrl_clk                              ), //i
    .ctrl_reset    (ctrl_reset                            )  //i
  );
  UsbOhciWishbone_PulseCCByToggle_1 pulseCCByToggle_1 (
    .io_pulseIn               (output_tick                              ), //i
    .io_pulseOut              (pulseCCByToggle_1_io_pulseOut            ), //o
    .phy_clk                  (phy_clk                                  ), //i
    .phy_reset                (phy_reset                                ), //i
    .ctrl_clk                 (ctrl_clk                                 ), //i
    .phy_reset_syncronized    (pulseCCByToggle_phy_reset_syncronized_1  )  //i
  );
  UsbOhciWishbone_BufferCC_29 input_ports_0_removable_buffercc (
    .io_dataIn     (input_ports_0_removable                      ), //i
    .io_dataOut    (input_ports_0_removable_buffercc_io_dataOut  ), //o
    .phy_clk       (phy_clk                                      ), //i
    .phy_reset     (phy_reset                                    )  //i
  );
  UsbOhciWishbone_BufferCC_29 input_ports_0_power_buffercc (
    .io_dataIn     (input_ports_0_power                      ), //i
    .io_dataOut    (input_ports_0_power_buffercc_io_dataOut  ), //o
    .phy_clk       (phy_clk                                  ), //i
    .phy_reset     (phy_reset                                )  //i
  );
  UsbOhciWishbone_BufferCC_32 output_ports_0_lowSpeed_buffercc (
    .io_dataIn     (output_ports_0_lowSpeed                      ), //i
    .io_dataOut    (output_ports_0_lowSpeed_buffercc_io_dataOut  ), //o
    .ctrl_clk      (ctrl_clk                                     ), //i
    .ctrl_reset    (ctrl_reset                                   )  //i
  );
  UsbOhciWishbone_BufferCC_32 output_ports_0_overcurrent_buffercc (
    .io_dataIn     (output_ports_0_overcurrent                      ), //i
    .io_dataOut    (output_ports_0_overcurrent_buffercc_io_dataOut  ), //o
    .ctrl_clk      (ctrl_clk                                        ), //i
    .ctrl_reset    (ctrl_reset                                      )  //i
  );
  UsbOhciWishbone_PulseCCByToggle_1 pulseCCByToggle_2 (
    .io_pulseIn               (output_ports_0_connect                   ), //i
    .io_pulseOut              (pulseCCByToggle_2_io_pulseOut            ), //o
    .phy_clk                  (phy_clk                                  ), //i
    .phy_reset                (phy_reset                                ), //i
    .ctrl_clk                 (ctrl_clk                                 ), //i
    .phy_reset_syncronized    (pulseCCByToggle_phy_reset_syncronized_1  )  //i
  );
  UsbOhciWishbone_PulseCCByToggle_1 pulseCCByToggle_3 (
    .io_pulseIn               (output_ports_0_disconnect                ), //i
    .io_pulseOut              (pulseCCByToggle_3_io_pulseOut            ), //o
    .phy_clk                  (phy_clk                                  ), //i
    .phy_reset                (phy_reset                                ), //i
    .ctrl_clk                 (ctrl_clk                                 ), //i
    .phy_reset_syncronized    (pulseCCByToggle_phy_reset_syncronized_1  )  //i
  );
  UsbOhciWishbone_PulseCCByToggle_1 pulseCCByToggle_4 (
    .io_pulseIn               (output_ports_0_remoteResume              ), //i
    .io_pulseOut              (pulseCCByToggle_4_io_pulseOut            ), //o
    .phy_clk                  (phy_clk                                  ), //i
    .phy_reset                (phy_reset                                ), //i
    .ctrl_clk                 (ctrl_clk                                 ), //i
    .phy_reset_syncronized    (pulseCCByToggle_phy_reset_syncronized_1  )  //i
  );
  UsbOhciWishbone_StreamCCByToggle_1 input_ports_0_reset_ccToggle (
    .io_input_valid            (input_ports_0_reset_valid                     ), //i
    .io_input_ready            (input_ports_0_reset_ccToggle_io_input_ready   ), //o
    .io_output_valid           (input_ports_0_reset_ccToggle_io_output_valid  ), //o
    .io_output_ready           (output_ports_0_reset_ready                    ), //i
    .ctrl_clk                  (ctrl_clk                                      ), //i
    .ctrl_reset                (ctrl_reset                                    ), //i
    .phy_clk                   (phy_clk                                       ), //i
    .ctrl_reset_syncronized    (input_tx_ccToggle_ctrl_reset_syncronized_1    )  //i
  );
  UsbOhciWishbone_StreamCCByToggle_1 input_ports_0_suspend_ccToggle (
    .io_input_valid            (input_ports_0_suspend_valid                     ), //i
    .io_input_ready            (input_ports_0_suspend_ccToggle_io_input_ready   ), //o
    .io_output_valid           (input_ports_0_suspend_ccToggle_io_output_valid  ), //o
    .io_output_ready           (output_ports_0_suspend_ready                    ), //i
    .ctrl_clk                  (ctrl_clk                                        ), //i
    .ctrl_reset                (ctrl_reset                                      ), //i
    .phy_clk                   (phy_clk                                         ), //i
    .ctrl_reset_syncronized    (input_tx_ccToggle_ctrl_reset_syncronized_1      )  //i
  );
  UsbOhciWishbone_StreamCCByToggle_1 input_ports_0_resume_ccToggle (
    .io_input_valid            (input_ports_0_resume_valid                     ), //i
    .io_input_ready            (input_ports_0_resume_ccToggle_io_input_ready   ), //o
    .io_output_valid           (input_ports_0_resume_ccToggle_io_output_valid  ), //o
    .io_output_ready           (output_ports_0_resume_ready                    ), //i
    .ctrl_clk                  (ctrl_clk                                       ), //i
    .ctrl_reset                (ctrl_reset                                     ), //i
    .phy_clk                   (phy_clk                                        ), //i
    .ctrl_reset_syncronized    (input_tx_ccToggle_ctrl_reset_syncronized_1     )  //i
  );
  UsbOhciWishbone_StreamCCByToggle_1 input_ports_0_disable_ccToggle (
    .io_input_valid            (input_ports_0_disable_valid                     ), //i
    .io_input_ready            (input_ports_0_disable_ccToggle_io_input_ready   ), //o
    .io_output_valid           (input_ports_0_disable_ccToggle_io_output_valid  ), //o
    .io_output_ready           (output_ports_0_disable_ready                    ), //i
    .ctrl_clk                  (ctrl_clk                                        ), //i
    .ctrl_reset                (ctrl_reset                                      ), //i
    .phy_clk                   (phy_clk                                         ), //i
    .ctrl_reset_syncronized    (input_tx_ccToggle_ctrl_reset_syncronized_1      )  //i
  );
  UsbOhciWishbone_BufferCC_29 input_ports_1_removable_buffercc (
    .io_dataIn     (input_ports_1_removable                      ), //i
    .io_dataOut    (input_ports_1_removable_buffercc_io_dataOut  ), //o
    .phy_clk       (phy_clk                                      ), //i
    .phy_reset     (phy_reset                                    )  //i
  );
  UsbOhciWishbone_BufferCC_29 input_ports_1_power_buffercc (
    .io_dataIn     (input_ports_1_power                      ), //i
    .io_dataOut    (input_ports_1_power_buffercc_io_dataOut  ), //o
    .phy_clk       (phy_clk                                  ), //i
    .phy_reset     (phy_reset                                )  //i
  );
  UsbOhciWishbone_BufferCC_32 output_ports_1_lowSpeed_buffercc (
    .io_dataIn     (output_ports_1_lowSpeed                      ), //i
    .io_dataOut    (output_ports_1_lowSpeed_buffercc_io_dataOut  ), //o
    .ctrl_clk      (ctrl_clk                                     ), //i
    .ctrl_reset    (ctrl_reset                                   )  //i
  );
  UsbOhciWishbone_BufferCC_32 output_ports_1_overcurrent_buffercc (
    .io_dataIn     (output_ports_1_overcurrent                      ), //i
    .io_dataOut    (output_ports_1_overcurrent_buffercc_io_dataOut  ), //o
    .ctrl_clk      (ctrl_clk                                        ), //i
    .ctrl_reset    (ctrl_reset                                      )  //i
  );
  UsbOhciWishbone_PulseCCByToggle_1 pulseCCByToggle_5 (
    .io_pulseIn               (output_ports_1_connect                   ), //i
    .io_pulseOut              (pulseCCByToggle_5_io_pulseOut            ), //o
    .phy_clk                  (phy_clk                                  ), //i
    .phy_reset                (phy_reset                                ), //i
    .ctrl_clk                 (ctrl_clk                                 ), //i
    .phy_reset_syncronized    (pulseCCByToggle_phy_reset_syncronized_1  )  //i
  );
  UsbOhciWishbone_PulseCCByToggle_1 pulseCCByToggle_6 (
    .io_pulseIn               (output_ports_1_disconnect                ), //i
    .io_pulseOut              (pulseCCByToggle_6_io_pulseOut            ), //o
    .phy_clk                  (phy_clk                                  ), //i
    .phy_reset                (phy_reset                                ), //i
    .ctrl_clk                 (ctrl_clk                                 ), //i
    .phy_reset_syncronized    (pulseCCByToggle_phy_reset_syncronized_1  )  //i
  );
  UsbOhciWishbone_PulseCCByToggle_1 pulseCCByToggle_7 (
    .io_pulseIn               (output_ports_1_remoteResume              ), //i
    .io_pulseOut              (pulseCCByToggle_7_io_pulseOut            ), //o
    .phy_clk                  (phy_clk                                  ), //i
    .phy_reset                (phy_reset                                ), //i
    .ctrl_clk                 (ctrl_clk                                 ), //i
    .phy_reset_syncronized    (pulseCCByToggle_phy_reset_syncronized_1  )  //i
  );
  UsbOhciWishbone_StreamCCByToggle_1 input_ports_1_reset_ccToggle (
    .io_input_valid            (input_ports_1_reset_valid                     ), //i
    .io_input_ready            (input_ports_1_reset_ccToggle_io_input_ready   ), //o
    .io_output_valid           (input_ports_1_reset_ccToggle_io_output_valid  ), //o
    .io_output_ready           (output_ports_1_reset_ready                    ), //i
    .ctrl_clk                  (ctrl_clk                                      ), //i
    .ctrl_reset                (ctrl_reset                                    ), //i
    .phy_clk                   (phy_clk                                       ), //i
    .ctrl_reset_syncronized    (input_tx_ccToggle_ctrl_reset_syncronized_1    )  //i
  );
  UsbOhciWishbone_StreamCCByToggle_1 input_ports_1_suspend_ccToggle (
    .io_input_valid            (input_ports_1_suspend_valid                     ), //i
    .io_input_ready            (input_ports_1_suspend_ccToggle_io_input_ready   ), //o
    .io_output_valid           (input_ports_1_suspend_ccToggle_io_output_valid  ), //o
    .io_output_ready           (output_ports_1_suspend_ready                    ), //i
    .ctrl_clk                  (ctrl_clk                                        ), //i
    .ctrl_reset                (ctrl_reset                                      ), //i
    .phy_clk                   (phy_clk                                         ), //i
    .ctrl_reset_syncronized    (input_tx_ccToggle_ctrl_reset_syncronized_1      )  //i
  );
  UsbOhciWishbone_StreamCCByToggle_1 input_ports_1_resume_ccToggle (
    .io_input_valid            (input_ports_1_resume_valid                     ), //i
    .io_input_ready            (input_ports_1_resume_ccToggle_io_input_ready   ), //o
    .io_output_valid           (input_ports_1_resume_ccToggle_io_output_valid  ), //o
    .io_output_ready           (output_ports_1_resume_ready                    ), //i
    .ctrl_clk                  (ctrl_clk                                       ), //i
    .ctrl_reset                (ctrl_reset                                     ), //i
    .phy_clk                   (phy_clk                                        ), //i
    .ctrl_reset_syncronized    (input_tx_ccToggle_ctrl_reset_syncronized_1     )  //i
  );
  UsbOhciWishbone_StreamCCByToggle_1 input_ports_1_disable_ccToggle (
    .io_input_valid            (input_ports_1_disable_valid                     ), //i
    .io_input_ready            (input_ports_1_disable_ccToggle_io_input_ready   ), //o
    .io_output_valid           (input_ports_1_disable_ccToggle_io_output_valid  ), //o
    .io_output_ready           (output_ports_1_disable_ready                    ), //i
    .ctrl_clk                  (ctrl_clk                                        ), //i
    .ctrl_reset                (ctrl_reset                                      ), //i
    .phy_clk                   (phy_clk                                         ), //i
    .ctrl_reset_syncronized    (input_tx_ccToggle_ctrl_reset_syncronized_1      )  //i
  );
  assign output_lowSpeed = input_lowSpeed_buffercc_io_dataOut;
  assign output_usbReset = input_usbReset_buffercc_io_dataOut;
  assign output_usbResume = input_usbResume_buffercc_io_dataOut;
  assign input_overcurrent = output_overcurrent_buffercc_io_dataOut;
  assign input_tx_ready = input_tx_ccToggle_io_input_ready;
  always @(*) begin
    input_tx_ccToggle_io_output_ready = input_tx_ccToggle_io_output_m2sPipe_ready;
    if(when_Stream_l342) begin
      input_tx_ccToggle_io_output_ready = 1'b1;
    end
  end

  assign when_Stream_l342 = (! input_tx_ccToggle_io_output_m2sPipe_valid);
  assign input_tx_ccToggle_io_output_m2sPipe_valid = input_tx_ccToggle_io_output_rValid;
  assign input_tx_ccToggle_io_output_m2sPipe_payload_last = input_tx_ccToggle_io_output_rData_last;
  assign input_tx_ccToggle_io_output_m2sPipe_payload_fragment = input_tx_ccToggle_io_output_rData_fragment;
  assign output_tx_valid = input_tx_ccToggle_io_output_m2sPipe_valid;
  assign input_tx_ccToggle_io_output_m2sPipe_ready = output_tx_ready;
  assign output_tx_payload_last = input_tx_ccToggle_io_output_m2sPipe_payload_last;
  assign output_tx_payload_fragment = input_tx_ccToggle_io_output_m2sPipe_payload_fragment;
  assign input_txEop = pulseCCByToggle_io_pulseOut;
  assign input_rx_flow_valid = output_rx_flow_ccToggle_io_output_valid;
  assign input_rx_flow_payload_stuffingError = output_rx_flow_ccToggle_io_output_payload_stuffingError;
  assign input_rx_flow_payload_data = output_rx_flow_ccToggle_io_output_payload_data;
  assign input_rx_active = output_rx_active_buffercc_io_dataOut;
  assign input_tick = pulseCCByToggle_1_io_pulseOut;
  assign output_ports_0_removable = input_ports_0_removable_buffercc_io_dataOut;
  assign output_ports_0_power = input_ports_0_power_buffercc_io_dataOut;
  assign input_ports_0_lowSpeed = output_ports_0_lowSpeed_buffercc_io_dataOut;
  assign input_ports_0_overcurrent = output_ports_0_overcurrent_buffercc_io_dataOut;
  assign input_ports_0_connect = pulseCCByToggle_2_io_pulseOut;
  assign input_ports_0_disconnect = pulseCCByToggle_3_io_pulseOut;
  assign input_ports_0_remoteResume = pulseCCByToggle_4_io_pulseOut;
  assign input_ports_0_reset_ready = input_ports_0_reset_ccToggle_io_input_ready;
  assign output_ports_0_reset_valid = input_ports_0_reset_ccToggle_io_output_valid;
  assign input_ports_0_suspend_ready = input_ports_0_suspend_ccToggle_io_input_ready;
  assign output_ports_0_suspend_valid = input_ports_0_suspend_ccToggle_io_output_valid;
  assign input_ports_0_resume_ready = input_ports_0_resume_ccToggle_io_input_ready;
  assign output_ports_0_resume_valid = input_ports_0_resume_ccToggle_io_output_valid;
  assign input_ports_0_disable_ready = input_ports_0_disable_ccToggle_io_input_ready;
  assign output_ports_0_disable_valid = input_ports_0_disable_ccToggle_io_output_valid;
  assign output_ports_1_removable = input_ports_1_removable_buffercc_io_dataOut;
  assign output_ports_1_power = input_ports_1_power_buffercc_io_dataOut;
  assign input_ports_1_lowSpeed = output_ports_1_lowSpeed_buffercc_io_dataOut;
  assign input_ports_1_overcurrent = output_ports_1_overcurrent_buffercc_io_dataOut;
  assign input_ports_1_connect = pulseCCByToggle_5_io_pulseOut;
  assign input_ports_1_disconnect = pulseCCByToggle_6_io_pulseOut;
  assign input_ports_1_remoteResume = pulseCCByToggle_7_io_pulseOut;
  assign input_ports_1_reset_ready = input_ports_1_reset_ccToggle_io_input_ready;
  assign output_ports_1_reset_valid = input_ports_1_reset_ccToggle_io_output_valid;
  assign input_ports_1_suspend_ready = input_ports_1_suspend_ccToggle_io_input_ready;
  assign output_ports_1_suspend_valid = input_ports_1_suspend_ccToggle_io_output_valid;
  assign input_ports_1_resume_ready = input_ports_1_resume_ccToggle_io_input_ready;
  assign output_ports_1_resume_valid = input_ports_1_resume_ccToggle_io_output_valid;
  assign input_ports_1_disable_ready = input_ports_1_disable_ccToggle_io_input_ready;
  assign output_ports_1_disable_valid = input_ports_1_disable_ccToggle_io_output_valid;
  always @(posedge phy_clk or posedge phy_reset) begin
    if(phy_reset) begin
      input_tx_ccToggle_io_output_rValid <= 1'b0;
    end else begin
      if(input_tx_ccToggle_io_output_ready) begin
        input_tx_ccToggle_io_output_rValid <= input_tx_ccToggle_io_output_valid;
      end
    end
  end

  always @(posedge phy_clk) begin
    if(input_tx_ccToggle_io_output_ready) begin
      input_tx_ccToggle_io_output_rData_last <= input_tx_ccToggle_io_output_payload_last;
      input_tx_ccToggle_io_output_rData_fragment <= input_tx_ccToggle_io_output_payload_fragment;
    end
  end


endmodule

module UsbOhciWishbone_UsbLsFsPhy (
  input               io_ctrl_lowSpeed,
  input               io_ctrl_tx_valid,
  output reg          io_ctrl_tx_ready,
  input               io_ctrl_tx_payload_last,
  input      [7:0]    io_ctrl_tx_payload_fragment,
  output reg          io_ctrl_txEop,
  output reg          io_ctrl_rx_flow_valid,
  output reg          io_ctrl_rx_flow_payload_stuffingError,
  output reg [7:0]    io_ctrl_rx_flow_payload_data,
  output reg          io_ctrl_rx_active,
  input               io_ctrl_usbReset,
  input               io_ctrl_usbResume,
  output              io_ctrl_overcurrent,
  output              io_ctrl_tick,
  input               io_ctrl_ports_0_disable_valid,
  output              io_ctrl_ports_0_disable_ready,
  input               io_ctrl_ports_0_removable,
  input               io_ctrl_ports_0_power,
  input               io_ctrl_ports_0_reset_valid,
  output reg          io_ctrl_ports_0_reset_ready,
  input               io_ctrl_ports_0_suspend_valid,
  output              io_ctrl_ports_0_suspend_ready,
  input               io_ctrl_ports_0_resume_valid,
  output              io_ctrl_ports_0_resume_ready,
  output reg          io_ctrl_ports_0_connect,
  output              io_ctrl_ports_0_disconnect,
  output              io_ctrl_ports_0_overcurrent,
  output              io_ctrl_ports_0_remoteResume,
  output              io_ctrl_ports_0_lowSpeed,
  input               io_ctrl_ports_1_disable_valid,
  output              io_ctrl_ports_1_disable_ready,
  input               io_ctrl_ports_1_removable,
  input               io_ctrl_ports_1_power,
  input               io_ctrl_ports_1_reset_valid,
  output reg          io_ctrl_ports_1_reset_ready,
  input               io_ctrl_ports_1_suspend_valid,
  output              io_ctrl_ports_1_suspend_ready,
  input               io_ctrl_ports_1_resume_valid,
  output              io_ctrl_ports_1_resume_ready,
  output reg          io_ctrl_ports_1_connect,
  output              io_ctrl_ports_1_disconnect,
  output              io_ctrl_ports_1_overcurrent,
  output              io_ctrl_ports_1_remoteResume,
  output              io_ctrl_ports_1_lowSpeed,
  output reg          io_usb_0_tx_enable,
  output reg          io_usb_0_tx_data,
  output reg          io_usb_0_tx_se0,
  input               io_usb_0_rx_dp,
  input               io_usb_0_rx_dm,
  output reg          io_usb_1_tx_enable,
  output reg          io_usb_1_tx_data,
  output reg          io_usb_1_tx_se0,
  input               io_usb_1_rx_dp,
  input               io_usb_1_rx_dm,
  input               io_management_0_overcurrent,
  output              io_management_0_power,
  input               io_management_1_overcurrent,
  output              io_management_1_power,
  input               phy_clk,
  input               phy_reset
);
  localparam UsbOhciWishbone_txShared_frame_enumDef_BOOT = 4'd0;
  localparam UsbOhciWishbone_txShared_frame_enumDef_IDLE = 4'd1;
  localparam UsbOhciWishbone_txShared_frame_enumDef_TAKE_LINE = 4'd2;
  localparam UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_SYNC = 4'd3;
  localparam UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_PID = 4'd4;
  localparam UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_DELAY = 4'd5;
  localparam UsbOhciWishbone_txShared_frame_enumDef_SYNC = 4'd6;
  localparam UsbOhciWishbone_txShared_frame_enumDef_DATA = 4'd7;
  localparam UsbOhciWishbone_txShared_frame_enumDef_EOP_0 = 4'd8;
  localparam UsbOhciWishbone_txShared_frame_enumDef_EOP_1 = 4'd9;
  localparam UsbOhciWishbone_txShared_frame_enumDef_EOP_2 = 4'd10;
  localparam UsbOhciWishbone_ports_0_fsm_enumDef_BOOT = 4'd0;
  localparam UsbOhciWishbone_ports_0_fsm_enumDef_POWER_OFF = 4'd1;
  localparam UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED = 4'd2;
  localparam UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED = 4'd3;
  localparam UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING = 4'd4;
  localparam UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY = 4'd5;
  localparam UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_SYNC = 4'd6;
  localparam UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED = 4'd7;
  localparam UsbOhciWishbone_ports_0_fsm_enumDef_SUSPENDED = 4'd8;
  localparam UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING = 4'd9;
  localparam UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0 = 4'd10;
  localparam UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1 = 4'd11;
  localparam UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S = 4'd12;
  localparam UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E = 4'd13;
  localparam UsbOhciWishbone_ports_1_fsm_enumDef_BOOT = 4'd0;
  localparam UsbOhciWishbone_ports_1_fsm_enumDef_POWER_OFF = 4'd1;
  localparam UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED = 4'd2;
  localparam UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED = 4'd3;
  localparam UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING = 4'd4;
  localparam UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY = 4'd5;
  localparam UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_SYNC = 4'd6;
  localparam UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED = 4'd7;
  localparam UsbOhciWishbone_ports_1_fsm_enumDef_SUSPENDED = 4'd8;
  localparam UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING = 4'd9;
  localparam UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0 = 4'd10;
  localparam UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1 = 4'd11;
  localparam UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S = 4'd12;
  localparam UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E = 4'd13;
  localparam UsbOhciWishbone_upstreamRx_enumDef_BOOT = 2'd0;
  localparam UsbOhciWishbone_upstreamRx_enumDef_IDLE = 2'd1;
  localparam UsbOhciWishbone_upstreamRx_enumDef_SUSPEND = 2'd2;
  localparam UsbOhciWishbone_ports_0_rx_packet_enumDef_BOOT = 2'd0;
  localparam UsbOhciWishbone_ports_0_rx_packet_enumDef_IDLE = 2'd1;
  localparam UsbOhciWishbone_ports_0_rx_packet_enumDef_PACKET = 2'd2;
  localparam UsbOhciWishbone_ports_0_rx_packet_enumDef_ERRORED = 2'd3;
  localparam UsbOhciWishbone_ports_1_rx_packet_enumDef_BOOT = 2'd0;
  localparam UsbOhciWishbone_ports_1_rx_packet_enumDef_IDLE = 2'd1;
  localparam UsbOhciWishbone_ports_1_rx_packet_enumDef_PACKET = 2'd2;
  localparam UsbOhciWishbone_ports_1_rx_packet_enumDef_ERRORED = 2'd3;

  wire                ports_0_filter_io_filtred_dp;
  wire                ports_0_filter_io_filtred_dm;
  wire                ports_0_filter_io_filtred_d;
  wire                ports_0_filter_io_filtred_se0;
  wire                ports_0_filter_io_filtred_sample;
  wire                ports_1_filter_io_filtred_dp;
  wire                ports_1_filter_io_filtred_dm;
  wire                ports_1_filter_io_filtred_d;
  wire                ports_1_filter_io_filtred_se0;
  wire                ports_1_filter_io_filtred_sample;
  wire       [1:0]    _zz_tickTimer_counter_valueNext;
  wire       [0:0]    _zz_tickTimer_counter_valueNext_1;
  wire       [9:0]    _zz_txShared_timer_oneCycle;
  wire       [4:0]    _zz_txShared_timer_oneCycle_1;
  wire       [9:0]    _zz_txShared_timer_twoCycle;
  wire       [5:0]    _zz_txShared_timer_twoCycle_1;
  wire       [9:0]    _zz_txShared_timer_fourCycle;
  wire       [7:0]    _zz_txShared_timer_fourCycle_1;
  wire       [8:0]    _zz_txShared_rxToTxDelay_twoCycle;
  wire       [6:0]    _zz_txShared_rxToTxDelay_twoCycle_1;
  wire       [1:0]    _zz_txShared_lowSpeedSof_state;
  wire       [0:0]    _zz_txShared_lowSpeedSof_state_1;
  wire       [6:0]    _zz_when_UsbHubPhy_l501;
  wire       [11:0]   _zz_ports_0_rx_packet_errorTimeout_trigger;
  wire       [9:0]    _zz_ports_0_rx_packet_errorTimeout_trigger_1;
  wire       [6:0]    _zz_ports_0_rx_disconnect_counter;
  wire       [0:0]    _zz_ports_0_rx_disconnect_counter_1;
  wire       [23:0]   _zz_ports_0_fsm_timer_ONE_BIT;
  wire       [4:0]    _zz_ports_0_fsm_timer_ONE_BIT_1;
  wire       [23:0]   _zz_ports_0_fsm_timer_TWO_BIT;
  wire       [5:0]    _zz_ports_0_fsm_timer_TWO_BIT_1;
  wire       [6:0]    _zz_when_UsbHubPhy_l501_1;
  wire       [11:0]   _zz_ports_1_rx_packet_errorTimeout_trigger;
  wire       [9:0]    _zz_ports_1_rx_packet_errorTimeout_trigger_1;
  wire       [6:0]    _zz_ports_1_rx_disconnect_counter;
  wire       [0:0]    _zz_ports_1_rx_disconnect_counter_1;
  wire       [23:0]   _zz_ports_1_fsm_timer_ONE_BIT;
  wire       [4:0]    _zz_ports_1_fsm_timer_ONE_BIT_1;
  wire       [23:0]   _zz_ports_1_fsm_timer_TWO_BIT;
  wire       [5:0]    _zz_ports_1_fsm_timer_TWO_BIT_1;
  wire                tickTimer_counter_willIncrement;
  wire                tickTimer_counter_willClear;
  reg        [1:0]    tickTimer_counter_valueNext;
  reg        [1:0]    tickTimer_counter_value;
  wire                tickTimer_counter_willOverflowIfInc;
  wire                tickTimer_counter_willOverflow;
  wire                tickTimer_tick;
  reg                 txShared_timer_lowSpeed;
  reg        [9:0]    txShared_timer_counter;
  reg                 txShared_timer_clear;
  wire                txShared_timer_inc;
  wire                txShared_timer_oneCycle;
  wire                txShared_timer_twoCycle;
  wire                txShared_timer_fourCycle;
  reg                 txShared_rxToTxDelay_lowSpeed;
  reg        [8:0]    txShared_rxToTxDelay_counter;
  reg                 txShared_rxToTxDelay_clear;
  wire                txShared_rxToTxDelay_inc;
  wire                txShared_rxToTxDelay_twoCycle;
  reg                 txShared_rxToTxDelay_active;
  reg                 txShared_encoder_input_valid;
  reg                 txShared_encoder_input_ready;
  reg                 txShared_encoder_input_data;
  reg                 txShared_encoder_input_lowSpeed;
  reg                 txShared_encoder_output_valid;
  reg                 txShared_encoder_output_se0;
  reg                 txShared_encoder_output_lowSpeed;
  reg                 txShared_encoder_output_data;
  reg        [2:0]    txShared_encoder_counter;
  reg                 txShared_encoder_state;
  wire                when_UsbHubPhy_l189;
  wire                when_UsbHubPhy_l194;
  wire                when_UsbHubPhy_l208;
  reg                 txShared_serialiser_input_valid;
  reg                 txShared_serialiser_input_ready;
  reg        [7:0]    txShared_serialiser_input_data;
  reg                 txShared_serialiser_input_lowSpeed;
  reg        [2:0]    txShared_serialiser_bitCounter;
  wire                when_UsbHubPhy_l234;
  wire                when_UsbHubPhy_l240;
  reg        [4:0]    txShared_lowSpeedSof_timer;
  reg        [1:0]    txShared_lowSpeedSof_state;
  reg                 txShared_lowSpeedSof_increment;
  reg                 txShared_lowSpeedSof_overrideEncoder;
  reg                 txShared_encoder_output_valid_regNext;
  wire                when_UsbHubPhy_l249;
  wire                when_UsbHubPhy_l251;
  wire                io_ctrl_tx_fire;
  reg                 io_ctrl_tx_payload_first;
  wire                when_UsbHubPhy_l252;
  wire                when_UsbHubPhy_l259;
  wire                txShared_lowSpeedSof_valid;
  wire                txShared_lowSpeedSof_data;
  wire                txShared_lowSpeedSof_se0;
  wire                txShared_frame_wantExit;
  reg                 txShared_frame_wantStart;
  wire                txShared_frame_wantKill;
  wire                txShared_frame_busy;
  reg                 txShared_frame_wasLowSpeed;
  wire                upstreamRx_wantExit;
  reg                 upstreamRx_wantStart;
  wire                upstreamRx_wantKill;
  wire                upstreamRx_timer_lowSpeed;
  reg        [19:0]   upstreamRx_timer_counter;
  reg                 upstreamRx_timer_clear;
  wire                upstreamRx_timer_inc;
  wire                upstreamRx_timer_IDLE_EOI;
  wire                Rx_Suspend;
  reg                 resumeFromPort;
  reg                 ports_0_portLowSpeed;
  reg                 ports_0_rx_enablePackets;
  wire                ports_0_rx_j;
  wire                ports_0_rx_k;
  reg                 ports_0_rx_stuffingError;
  reg                 ports_0_rx_waitSync;
  reg                 ports_0_rx_decoder_state;
  reg                 ports_0_rx_decoder_output_valid;
  reg                 ports_0_rx_decoder_output_payload;
  wire                when_UsbHubPhy_l445;
  reg        [2:0]    ports_0_rx_destuffer_counter;
  wire                ports_0_rx_destuffer_unstuffNext;
  wire                ports_0_rx_destuffer_output_valid;
  wire                ports_0_rx_destuffer_output_payload;
  wire                when_UsbHubPhy_l466;
  wire                ports_0_rx_history_updated;
  wire                _zz_ports_0_rx_history_value;
  reg                 _zz_ports_0_rx_history_value_1;
  reg                 _zz_ports_0_rx_history_value_2;
  reg                 _zz_ports_0_rx_history_value_3;
  reg                 _zz_ports_0_rx_history_value_4;
  reg                 _zz_ports_0_rx_history_value_5;
  reg                 _zz_ports_0_rx_history_value_6;
  reg                 _zz_ports_0_rx_history_value_7;
  wire       [7:0]    ports_0_rx_history_value;
  wire                ports_0_rx_history_sync_hit;
  wire       [6:0]    ports_0_rx_eop_maxThreshold;
  wire       [5:0]    ports_0_rx_eop_minThreshold;
  reg        [6:0]    ports_0_rx_eop_counter;
  wire                ports_0_rx_eop_maxHit;
  reg                 ports_0_rx_eop_hit;
  wire                when_UsbHubPhy_l493;
  wire                when_UsbHubPhy_l494;
  wire                when_UsbHubPhy_l501;
  wire                ports_0_rx_packet_wantExit;
  reg                 ports_0_rx_packet_wantStart;
  wire                ports_0_rx_packet_wantKill;
  reg        [2:0]    ports_0_rx_packet_counter;
  wire                ports_0_rx_packet_errorTimeout_lowSpeed;
  reg        [11:0]   ports_0_rx_packet_errorTimeout_counter;
  reg                 ports_0_rx_packet_errorTimeout_clear;
  wire                ports_0_rx_packet_errorTimeout_inc;
  wire                ports_0_rx_packet_errorTimeout_trigger;
  reg                 ports_0_rx_packet_errorTimeout_p;
  reg                 ports_0_rx_packet_errorTimeout_n;
  reg        [6:0]    ports_0_rx_disconnect_counter;
  reg                 ports_0_rx_disconnect_clear;
  wire                ports_0_rx_disconnect_hit;
  reg                 ports_0_rx_disconnect_hitLast;
  wire                ports_0_rx_disconnect_event;
  wire                when_UsbHubPhy_l573;
  wire                ports_0_fsm_wantExit;
  reg                 ports_0_fsm_wantStart;
  wire                ports_0_fsm_wantKill;
  reg                 ports_0_fsm_timer_lowSpeed;
  reg        [23:0]   ports_0_fsm_timer_counter;
  reg                 ports_0_fsm_timer_clear;
  wire                ports_0_fsm_timer_inc;
  wire                ports_0_fsm_timer_DISCONNECTED_EOI;
  wire                ports_0_fsm_timer_RESET_DELAY;
  wire                ports_0_fsm_timer_RESET_EOI;
  wire                ports_0_fsm_timer_RESUME_EOI;
  wire                ports_0_fsm_timer_RESTART_EOI;
  wire                ports_0_fsm_timer_ONE_BIT;
  wire                ports_0_fsm_timer_TWO_BIT;
  reg                 ports_0_fsm_resetInProgress;
  reg                 ports_0_fsm_lowSpeedEop;
  wire                ports_0_fsm_forceJ;
  wire                when_UsbHubPhy_l767;
  reg                 ports_1_portLowSpeed;
  reg                 ports_1_rx_enablePackets;
  wire                ports_1_rx_j;
  wire                ports_1_rx_k;
  reg                 ports_1_rx_stuffingError;
  reg                 ports_1_rx_waitSync;
  reg                 ports_1_rx_decoder_state;
  reg                 ports_1_rx_decoder_output_valid;
  reg                 ports_1_rx_decoder_output_payload;
  wire                when_UsbHubPhy_l445_1;
  reg        [2:0]    ports_1_rx_destuffer_counter;
  wire                ports_1_rx_destuffer_unstuffNext;
  wire                ports_1_rx_destuffer_output_valid;
  wire                ports_1_rx_destuffer_output_payload;
  wire                when_UsbHubPhy_l466_1;
  wire                ports_1_rx_history_updated;
  wire                _zz_ports_1_rx_history_value;
  reg                 _zz_ports_1_rx_history_value_1;
  reg                 _zz_ports_1_rx_history_value_2;
  reg                 _zz_ports_1_rx_history_value_3;
  reg                 _zz_ports_1_rx_history_value_4;
  reg                 _zz_ports_1_rx_history_value_5;
  reg                 _zz_ports_1_rx_history_value_6;
  reg                 _zz_ports_1_rx_history_value_7;
  wire       [7:0]    ports_1_rx_history_value;
  wire                ports_1_rx_history_sync_hit;
  wire       [6:0]    ports_1_rx_eop_maxThreshold;
  wire       [5:0]    ports_1_rx_eop_minThreshold;
  reg        [6:0]    ports_1_rx_eop_counter;
  wire                ports_1_rx_eop_maxHit;
  reg                 ports_1_rx_eop_hit;
  wire                when_UsbHubPhy_l493_1;
  wire                when_UsbHubPhy_l494_1;
  wire                when_UsbHubPhy_l501_1;
  wire                ports_1_rx_packet_wantExit;
  reg                 ports_1_rx_packet_wantStart;
  wire                ports_1_rx_packet_wantKill;
  reg        [2:0]    ports_1_rx_packet_counter;
  wire                ports_1_rx_packet_errorTimeout_lowSpeed;
  reg        [11:0]   ports_1_rx_packet_errorTimeout_counter;
  reg                 ports_1_rx_packet_errorTimeout_clear;
  wire                ports_1_rx_packet_errorTimeout_inc;
  wire                ports_1_rx_packet_errorTimeout_trigger;
  reg                 ports_1_rx_packet_errorTimeout_p;
  reg                 ports_1_rx_packet_errorTimeout_n;
  reg        [6:0]    ports_1_rx_disconnect_counter;
  reg                 ports_1_rx_disconnect_clear;
  wire                ports_1_rx_disconnect_hit;
  reg                 ports_1_rx_disconnect_hitLast;
  wire                ports_1_rx_disconnect_event;
  wire                when_UsbHubPhy_l573_1;
  wire                ports_1_fsm_wantExit;
  reg                 ports_1_fsm_wantStart;
  wire                ports_1_fsm_wantKill;
  reg                 ports_1_fsm_timer_lowSpeed;
  reg        [23:0]   ports_1_fsm_timer_counter;
  reg                 ports_1_fsm_timer_clear;
  wire                ports_1_fsm_timer_inc;
  wire                ports_1_fsm_timer_DISCONNECTED_EOI;
  wire                ports_1_fsm_timer_RESET_DELAY;
  wire                ports_1_fsm_timer_RESET_EOI;
  wire                ports_1_fsm_timer_RESUME_EOI;
  wire                ports_1_fsm_timer_RESTART_EOI;
  wire                ports_1_fsm_timer_ONE_BIT;
  wire                ports_1_fsm_timer_TWO_BIT;
  reg                 ports_1_fsm_resetInProgress;
  reg                 ports_1_fsm_lowSpeedEop;
  wire                ports_1_fsm_forceJ;
  wire                when_UsbHubPhy_l767_1;
  reg        [3:0]    txShared_frame_stateReg;
  reg        [3:0]    txShared_frame_stateNext;
  wire                when_UsbHubPhy_l289;
  reg        [1:0]    upstreamRx_stateReg;
  reg        [1:0]    upstreamRx_stateNext;
  reg        [1:0]    ports_0_rx_packet_stateReg;
  reg        [1:0]    ports_0_rx_packet_stateNext;
  wire                when_UsbHubPhy_l527;
  wire                when_UsbHubPhy_l549;
  wire                when_StateMachine_l238;
  wire                when_StateMachine_l238_1;
  reg        [3:0]    ports_0_fsm_stateReg;
  reg        [3:0]    ports_0_fsm_stateNext;
  wire                when_UsbHubPhy_l638;
  wire                when_UsbHubPhy_l675;
  wire                when_UsbHubPhy_l688;
  wire                when_UsbHubPhy_l697;
  wire                when_UsbHubPhy_l705;
  wire                when_UsbHubPhy_l707;
  wire                when_UsbHubPhy_l748;
  wire                when_UsbHubPhy_l758;
  wire                when_StateMachine_l238_2;
  wire                when_StateMachine_l238_3;
  wire                when_StateMachine_l238_4;
  wire                when_StateMachine_l238_5;
  wire                when_StateMachine_l238_6;
  wire                when_StateMachine_l238_7;
  wire                when_StateMachine_l238_8;
  wire                when_StateMachine_l238_9;
  wire                when_UsbHubPhy_l610;
  wire                when_UsbHubPhy_l617;
  wire                when_UsbHubPhy_l618;
  reg        [1:0]    ports_1_rx_packet_stateReg;
  reg        [1:0]    ports_1_rx_packet_stateNext;
  wire                when_UsbHubPhy_l527_1;
  wire                when_UsbHubPhy_l549_1;
  wire                when_StateMachine_l238_10;
  wire                when_StateMachine_l238_11;
  reg        [3:0]    ports_1_fsm_stateReg;
  reg        [3:0]    ports_1_fsm_stateNext;
  wire                when_UsbHubPhy_l638_1;
  wire                when_UsbHubPhy_l675_1;
  wire                when_UsbHubPhy_l688_1;
  wire                when_UsbHubPhy_l697_1;
  wire                when_UsbHubPhy_l705_1;
  wire                when_UsbHubPhy_l707_1;
  wire                when_UsbHubPhy_l748_1;
  wire                when_UsbHubPhy_l758_1;
  wire                when_StateMachine_l238_12;
  wire                when_StateMachine_l238_13;
  wire                when_StateMachine_l238_14;
  wire                when_StateMachine_l238_15;
  wire                when_StateMachine_l238_16;
  wire                when_StateMachine_l238_17;
  wire                when_StateMachine_l238_18;
  wire                when_StateMachine_l238_19;
  wire                when_UsbHubPhy_l610_1;
  wire                when_UsbHubPhy_l617_1;
  wire                when_UsbHubPhy_l618_1;
  `ifndef SYNTHESIS
  reg [111:0] txShared_frame_stateReg_string;
  reg [111:0] txShared_frame_stateNext_string;
  reg [55:0] upstreamRx_stateReg_string;
  reg [55:0] upstreamRx_stateNext_string;
  reg [55:0] ports_0_rx_packet_stateReg_string;
  reg [55:0] ports_0_rx_packet_stateNext_string;
  reg [119:0] ports_0_fsm_stateReg_string;
  reg [119:0] ports_0_fsm_stateNext_string;
  reg [55:0] ports_1_rx_packet_stateReg_string;
  reg [55:0] ports_1_rx_packet_stateNext_string;
  reg [119:0] ports_1_fsm_stateReg_string;
  reg [119:0] ports_1_fsm_stateNext_string;
  `endif


  assign _zz_tickTimer_counter_valueNext_1 = tickTimer_counter_willIncrement;
  assign _zz_tickTimer_counter_valueNext = {1'd0, _zz_tickTimer_counter_valueNext_1};
  assign _zz_txShared_timer_oneCycle_1 = (txShared_timer_lowSpeed ? 5'h1f : 5'h03);
  assign _zz_txShared_timer_oneCycle = {5'd0, _zz_txShared_timer_oneCycle_1};
  assign _zz_txShared_timer_twoCycle_1 = (txShared_timer_lowSpeed ? 6'h3f : 6'h07);
  assign _zz_txShared_timer_twoCycle = {4'd0, _zz_txShared_timer_twoCycle_1};
  assign _zz_txShared_timer_fourCycle_1 = (txShared_timer_lowSpeed ? 8'h9f : 8'h13);
  assign _zz_txShared_timer_fourCycle = {2'd0, _zz_txShared_timer_fourCycle_1};
  assign _zz_txShared_rxToTxDelay_twoCycle_1 = (txShared_rxToTxDelay_lowSpeed ? 7'h7f : 7'h0f);
  assign _zz_txShared_rxToTxDelay_twoCycle = {2'd0, _zz_txShared_rxToTxDelay_twoCycle_1};
  assign _zz_txShared_lowSpeedSof_state_1 = txShared_lowSpeedSof_increment;
  assign _zz_txShared_lowSpeedSof_state = {1'd0, _zz_txShared_lowSpeedSof_state_1};
  assign _zz_when_UsbHubPhy_l501 = {1'd0, ports_0_rx_eop_minThreshold};
  assign _zz_ports_0_rx_packet_errorTimeout_trigger_1 = (ports_0_rx_packet_errorTimeout_lowSpeed ? 10'h27f : 10'h04f);
  assign _zz_ports_0_rx_packet_errorTimeout_trigger = {2'd0, _zz_ports_0_rx_packet_errorTimeout_trigger_1};
  assign _zz_ports_0_rx_disconnect_counter_1 = (! ports_0_rx_disconnect_hit);
  assign _zz_ports_0_rx_disconnect_counter = {6'd0, _zz_ports_0_rx_disconnect_counter_1};
  assign _zz_ports_0_fsm_timer_ONE_BIT_1 = (ports_0_fsm_timer_lowSpeed ? 5'h1f : 5'h03);
  assign _zz_ports_0_fsm_timer_ONE_BIT = {19'd0, _zz_ports_0_fsm_timer_ONE_BIT_1};
  assign _zz_ports_0_fsm_timer_TWO_BIT_1 = (ports_0_fsm_timer_lowSpeed ? 6'h3f : 6'h07);
  assign _zz_ports_0_fsm_timer_TWO_BIT = {18'd0, _zz_ports_0_fsm_timer_TWO_BIT_1};
  assign _zz_when_UsbHubPhy_l501_1 = {1'd0, ports_1_rx_eop_minThreshold};
  assign _zz_ports_1_rx_packet_errorTimeout_trigger_1 = (ports_1_rx_packet_errorTimeout_lowSpeed ? 10'h27f : 10'h04f);
  assign _zz_ports_1_rx_packet_errorTimeout_trigger = {2'd0, _zz_ports_1_rx_packet_errorTimeout_trigger_1};
  assign _zz_ports_1_rx_disconnect_counter_1 = (! ports_1_rx_disconnect_hit);
  assign _zz_ports_1_rx_disconnect_counter = {6'd0, _zz_ports_1_rx_disconnect_counter_1};
  assign _zz_ports_1_fsm_timer_ONE_BIT_1 = (ports_1_fsm_timer_lowSpeed ? 5'h1f : 5'h03);
  assign _zz_ports_1_fsm_timer_ONE_BIT = {19'd0, _zz_ports_1_fsm_timer_ONE_BIT_1};
  assign _zz_ports_1_fsm_timer_TWO_BIT_1 = (ports_1_fsm_timer_lowSpeed ? 6'h3f : 6'h07);
  assign _zz_ports_1_fsm_timer_TWO_BIT = {18'd0, _zz_ports_1_fsm_timer_TWO_BIT_1};
  UsbOhciWishbone_UsbLsFsPhyFilter ports_0_filter (
    .io_lowSpeed          (io_ctrl_lowSpeed                  ), //i
    .io_usb_dp            (io_usb_0_rx_dp                    ), //i
    .io_usb_dm            (io_usb_0_rx_dm                    ), //i
    .io_filtred_dp        (ports_0_filter_io_filtred_dp      ), //o
    .io_filtred_dm        (ports_0_filter_io_filtred_dm      ), //o
    .io_filtred_d         (ports_0_filter_io_filtred_d       ), //o
    .io_filtred_se0       (ports_0_filter_io_filtred_se0     ), //o
    .io_filtred_sample    (ports_0_filter_io_filtred_sample  ), //o
    .phy_clk              (phy_clk                           ), //i
    .phy_reset            (phy_reset                         )  //i
  );
  UsbOhciWishbone_UsbLsFsPhyFilter ports_1_filter (
    .io_lowSpeed          (io_ctrl_lowSpeed                  ), //i
    .io_usb_dp            (io_usb_1_rx_dp                    ), //i
    .io_usb_dm            (io_usb_1_rx_dm                    ), //i
    .io_filtred_dp        (ports_1_filter_io_filtred_dp      ), //o
    .io_filtred_dm        (ports_1_filter_io_filtred_dm      ), //o
    .io_filtred_d         (ports_1_filter_io_filtred_d       ), //o
    .io_filtred_se0       (ports_1_filter_io_filtred_se0     ), //o
    .io_filtred_sample    (ports_1_filter_io_filtred_sample  ), //o
    .phy_clk              (phy_clk                           ), //i
    .phy_reset            (phy_reset                         )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(txShared_frame_stateReg)
      UsbOhciWishbone_txShared_frame_enumDef_BOOT : txShared_frame_stateReg_string = "BOOT          ";
      UsbOhciWishbone_txShared_frame_enumDef_IDLE : txShared_frame_stateReg_string = "IDLE          ";
      UsbOhciWishbone_txShared_frame_enumDef_TAKE_LINE : txShared_frame_stateReg_string = "TAKE_LINE     ";
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_SYNC : txShared_frame_stateReg_string = "PREAMBLE_SYNC ";
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_PID : txShared_frame_stateReg_string = "PREAMBLE_PID  ";
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_DELAY : txShared_frame_stateReg_string = "PREAMBLE_DELAY";
      UsbOhciWishbone_txShared_frame_enumDef_SYNC : txShared_frame_stateReg_string = "SYNC          ";
      UsbOhciWishbone_txShared_frame_enumDef_DATA : txShared_frame_stateReg_string = "DATA          ";
      UsbOhciWishbone_txShared_frame_enumDef_EOP_0 : txShared_frame_stateReg_string = "EOP_0         ";
      UsbOhciWishbone_txShared_frame_enumDef_EOP_1 : txShared_frame_stateReg_string = "EOP_1         ";
      UsbOhciWishbone_txShared_frame_enumDef_EOP_2 : txShared_frame_stateReg_string = "EOP_2         ";
      default : txShared_frame_stateReg_string = "??????????????";
    endcase
  end
  always @(*) begin
    case(txShared_frame_stateNext)
      UsbOhciWishbone_txShared_frame_enumDef_BOOT : txShared_frame_stateNext_string = "BOOT          ";
      UsbOhciWishbone_txShared_frame_enumDef_IDLE : txShared_frame_stateNext_string = "IDLE          ";
      UsbOhciWishbone_txShared_frame_enumDef_TAKE_LINE : txShared_frame_stateNext_string = "TAKE_LINE     ";
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_SYNC : txShared_frame_stateNext_string = "PREAMBLE_SYNC ";
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_PID : txShared_frame_stateNext_string = "PREAMBLE_PID  ";
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_DELAY : txShared_frame_stateNext_string = "PREAMBLE_DELAY";
      UsbOhciWishbone_txShared_frame_enumDef_SYNC : txShared_frame_stateNext_string = "SYNC          ";
      UsbOhciWishbone_txShared_frame_enumDef_DATA : txShared_frame_stateNext_string = "DATA          ";
      UsbOhciWishbone_txShared_frame_enumDef_EOP_0 : txShared_frame_stateNext_string = "EOP_0         ";
      UsbOhciWishbone_txShared_frame_enumDef_EOP_1 : txShared_frame_stateNext_string = "EOP_1         ";
      UsbOhciWishbone_txShared_frame_enumDef_EOP_2 : txShared_frame_stateNext_string = "EOP_2         ";
      default : txShared_frame_stateNext_string = "??????????????";
    endcase
  end
  always @(*) begin
    case(upstreamRx_stateReg)
      UsbOhciWishbone_upstreamRx_enumDef_BOOT : upstreamRx_stateReg_string = "BOOT   ";
      UsbOhciWishbone_upstreamRx_enumDef_IDLE : upstreamRx_stateReg_string = "IDLE   ";
      UsbOhciWishbone_upstreamRx_enumDef_SUSPEND : upstreamRx_stateReg_string = "SUSPEND";
      default : upstreamRx_stateReg_string = "???????";
    endcase
  end
  always @(*) begin
    case(upstreamRx_stateNext)
      UsbOhciWishbone_upstreamRx_enumDef_BOOT : upstreamRx_stateNext_string = "BOOT   ";
      UsbOhciWishbone_upstreamRx_enumDef_IDLE : upstreamRx_stateNext_string = "IDLE   ";
      UsbOhciWishbone_upstreamRx_enumDef_SUSPEND : upstreamRx_stateNext_string = "SUSPEND";
      default : upstreamRx_stateNext_string = "???????";
    endcase
  end
  always @(*) begin
    case(ports_0_rx_packet_stateReg)
      UsbOhciWishbone_ports_0_rx_packet_enumDef_BOOT : ports_0_rx_packet_stateReg_string = "BOOT   ";
      UsbOhciWishbone_ports_0_rx_packet_enumDef_IDLE : ports_0_rx_packet_stateReg_string = "IDLE   ";
      UsbOhciWishbone_ports_0_rx_packet_enumDef_PACKET : ports_0_rx_packet_stateReg_string = "PACKET ";
      UsbOhciWishbone_ports_0_rx_packet_enumDef_ERRORED : ports_0_rx_packet_stateReg_string = "ERRORED";
      default : ports_0_rx_packet_stateReg_string = "???????";
    endcase
  end
  always @(*) begin
    case(ports_0_rx_packet_stateNext)
      UsbOhciWishbone_ports_0_rx_packet_enumDef_BOOT : ports_0_rx_packet_stateNext_string = "BOOT   ";
      UsbOhciWishbone_ports_0_rx_packet_enumDef_IDLE : ports_0_rx_packet_stateNext_string = "IDLE   ";
      UsbOhciWishbone_ports_0_rx_packet_enumDef_PACKET : ports_0_rx_packet_stateNext_string = "PACKET ";
      UsbOhciWishbone_ports_0_rx_packet_enumDef_ERRORED : ports_0_rx_packet_stateNext_string = "ERRORED";
      default : ports_0_rx_packet_stateNext_string = "???????";
    endcase
  end
  always @(*) begin
    case(ports_0_fsm_stateReg)
      UsbOhciWishbone_ports_0_fsm_enumDef_BOOT : ports_0_fsm_stateReg_string = "BOOT           ";
      UsbOhciWishbone_ports_0_fsm_enumDef_POWER_OFF : ports_0_fsm_stateReg_string = "POWER_OFF      ";
      UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED : ports_0_fsm_stateReg_string = "DISCONNECTED   ";
      UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED : ports_0_fsm_stateReg_string = "DISABLED       ";
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING : ports_0_fsm_stateReg_string = "RESETTING      ";
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY : ports_0_fsm_stateReg_string = "RESETTING_DELAY";
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_SYNC : ports_0_fsm_stateReg_string = "RESETTING_SYNC ";
      UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED : ports_0_fsm_stateReg_string = "ENABLED        ";
      UsbOhciWishbone_ports_0_fsm_enumDef_SUSPENDED : ports_0_fsm_stateReg_string = "SUSPENDED      ";
      UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING : ports_0_fsm_stateReg_string = "RESUMING       ";
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0 : ports_0_fsm_stateReg_string = "SEND_EOP_0     ";
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1 : ports_0_fsm_stateReg_string = "SEND_EOP_1     ";
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S : ports_0_fsm_stateReg_string = "RESTART_S      ";
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E : ports_0_fsm_stateReg_string = "RESTART_E      ";
      default : ports_0_fsm_stateReg_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(ports_0_fsm_stateNext)
      UsbOhciWishbone_ports_0_fsm_enumDef_BOOT : ports_0_fsm_stateNext_string = "BOOT           ";
      UsbOhciWishbone_ports_0_fsm_enumDef_POWER_OFF : ports_0_fsm_stateNext_string = "POWER_OFF      ";
      UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED : ports_0_fsm_stateNext_string = "DISCONNECTED   ";
      UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED : ports_0_fsm_stateNext_string = "DISABLED       ";
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING : ports_0_fsm_stateNext_string = "RESETTING      ";
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY : ports_0_fsm_stateNext_string = "RESETTING_DELAY";
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_SYNC : ports_0_fsm_stateNext_string = "RESETTING_SYNC ";
      UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED : ports_0_fsm_stateNext_string = "ENABLED        ";
      UsbOhciWishbone_ports_0_fsm_enumDef_SUSPENDED : ports_0_fsm_stateNext_string = "SUSPENDED      ";
      UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING : ports_0_fsm_stateNext_string = "RESUMING       ";
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0 : ports_0_fsm_stateNext_string = "SEND_EOP_0     ";
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1 : ports_0_fsm_stateNext_string = "SEND_EOP_1     ";
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S : ports_0_fsm_stateNext_string = "RESTART_S      ";
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E : ports_0_fsm_stateNext_string = "RESTART_E      ";
      default : ports_0_fsm_stateNext_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(ports_1_rx_packet_stateReg)
      UsbOhciWishbone_ports_1_rx_packet_enumDef_BOOT : ports_1_rx_packet_stateReg_string = "BOOT   ";
      UsbOhciWishbone_ports_1_rx_packet_enumDef_IDLE : ports_1_rx_packet_stateReg_string = "IDLE   ";
      UsbOhciWishbone_ports_1_rx_packet_enumDef_PACKET : ports_1_rx_packet_stateReg_string = "PACKET ";
      UsbOhciWishbone_ports_1_rx_packet_enumDef_ERRORED : ports_1_rx_packet_stateReg_string = "ERRORED";
      default : ports_1_rx_packet_stateReg_string = "???????";
    endcase
  end
  always @(*) begin
    case(ports_1_rx_packet_stateNext)
      UsbOhciWishbone_ports_1_rx_packet_enumDef_BOOT : ports_1_rx_packet_stateNext_string = "BOOT   ";
      UsbOhciWishbone_ports_1_rx_packet_enumDef_IDLE : ports_1_rx_packet_stateNext_string = "IDLE   ";
      UsbOhciWishbone_ports_1_rx_packet_enumDef_PACKET : ports_1_rx_packet_stateNext_string = "PACKET ";
      UsbOhciWishbone_ports_1_rx_packet_enumDef_ERRORED : ports_1_rx_packet_stateNext_string = "ERRORED";
      default : ports_1_rx_packet_stateNext_string = "???????";
    endcase
  end
  always @(*) begin
    case(ports_1_fsm_stateReg)
      UsbOhciWishbone_ports_1_fsm_enumDef_BOOT : ports_1_fsm_stateReg_string = "BOOT           ";
      UsbOhciWishbone_ports_1_fsm_enumDef_POWER_OFF : ports_1_fsm_stateReg_string = "POWER_OFF      ";
      UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED : ports_1_fsm_stateReg_string = "DISCONNECTED   ";
      UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED : ports_1_fsm_stateReg_string = "DISABLED       ";
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING : ports_1_fsm_stateReg_string = "RESETTING      ";
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY : ports_1_fsm_stateReg_string = "RESETTING_DELAY";
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_SYNC : ports_1_fsm_stateReg_string = "RESETTING_SYNC ";
      UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED : ports_1_fsm_stateReg_string = "ENABLED        ";
      UsbOhciWishbone_ports_1_fsm_enumDef_SUSPENDED : ports_1_fsm_stateReg_string = "SUSPENDED      ";
      UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING : ports_1_fsm_stateReg_string = "RESUMING       ";
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0 : ports_1_fsm_stateReg_string = "SEND_EOP_0     ";
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1 : ports_1_fsm_stateReg_string = "SEND_EOP_1     ";
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S : ports_1_fsm_stateReg_string = "RESTART_S      ";
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E : ports_1_fsm_stateReg_string = "RESTART_E      ";
      default : ports_1_fsm_stateReg_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(ports_1_fsm_stateNext)
      UsbOhciWishbone_ports_1_fsm_enumDef_BOOT : ports_1_fsm_stateNext_string = "BOOT           ";
      UsbOhciWishbone_ports_1_fsm_enumDef_POWER_OFF : ports_1_fsm_stateNext_string = "POWER_OFF      ";
      UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED : ports_1_fsm_stateNext_string = "DISCONNECTED   ";
      UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED : ports_1_fsm_stateNext_string = "DISABLED       ";
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING : ports_1_fsm_stateNext_string = "RESETTING      ";
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY : ports_1_fsm_stateNext_string = "RESETTING_DELAY";
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_SYNC : ports_1_fsm_stateNext_string = "RESETTING_SYNC ";
      UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED : ports_1_fsm_stateNext_string = "ENABLED        ";
      UsbOhciWishbone_ports_1_fsm_enumDef_SUSPENDED : ports_1_fsm_stateNext_string = "SUSPENDED      ";
      UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING : ports_1_fsm_stateNext_string = "RESUMING       ";
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0 : ports_1_fsm_stateNext_string = "SEND_EOP_0     ";
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1 : ports_1_fsm_stateNext_string = "SEND_EOP_1     ";
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S : ports_1_fsm_stateNext_string = "RESTART_S      ";
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E : ports_1_fsm_stateNext_string = "RESTART_E      ";
      default : ports_1_fsm_stateNext_string = "???????????????";
    endcase
  end
  `endif

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
  always @(*) begin
    txShared_timer_clear = 1'b0;
    if(txShared_encoder_input_valid) begin
      if(txShared_encoder_input_data) begin
        if(txShared_timer_oneCycle) begin
          if(when_UsbHubPhy_l189) begin
            txShared_timer_clear = 1'b1;
          end
        end
      end
    end
    if(txShared_encoder_input_ready) begin
      txShared_timer_clear = 1'b1;
    end
    case(txShared_frame_stateReg)
      UsbOhciWishbone_txShared_frame_enumDef_IDLE : begin
        txShared_timer_clear = 1'b1;
      end
      UsbOhciWishbone_txShared_frame_enumDef_TAKE_LINE : begin
        if(txShared_timer_oneCycle) begin
          txShared_timer_clear = 1'b1;
        end
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_DELAY : begin
        if(txShared_timer_fourCycle) begin
          txShared_timer_clear = 1'b1;
        end
      end
      UsbOhciWishbone_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_DATA : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_0 : begin
        if(txShared_timer_twoCycle) begin
          txShared_timer_clear = 1'b1;
        end
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_1 : begin
        if(txShared_timer_oneCycle) begin
          txShared_timer_clear = 1'b1;
        end
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_2 : begin
        if(txShared_timer_twoCycle) begin
          txShared_timer_clear = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign txShared_timer_inc = 1'b1;
  assign txShared_timer_oneCycle = (txShared_timer_counter == _zz_txShared_timer_oneCycle);
  assign txShared_timer_twoCycle = (txShared_timer_counter == _zz_txShared_timer_twoCycle);
  assign txShared_timer_fourCycle = (txShared_timer_counter == _zz_txShared_timer_fourCycle);
  always @(*) begin
    txShared_timer_lowSpeed = 1'b0;
    if(txShared_encoder_input_valid) begin
      txShared_timer_lowSpeed = txShared_encoder_input_lowSpeed;
    end
    case(txShared_frame_stateReg)
      UsbOhciWishbone_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_TAKE_LINE : begin
        txShared_timer_lowSpeed = 1'b0;
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_DELAY : begin
        txShared_timer_lowSpeed = 1'b0;
      end
      UsbOhciWishbone_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_DATA : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_0 : begin
        txShared_timer_lowSpeed = txShared_frame_wasLowSpeed;
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_1 : begin
        txShared_timer_lowSpeed = txShared_frame_wasLowSpeed;
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_2 : begin
        txShared_timer_lowSpeed = txShared_frame_wasLowSpeed;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    txShared_rxToTxDelay_clear = 1'b0;
    if(ports_0_rx_eop_hit) begin
      txShared_rxToTxDelay_clear = 1'b1;
    end
    if(ports_1_rx_eop_hit) begin
      txShared_rxToTxDelay_clear = 1'b1;
    end
  end

  assign txShared_rxToTxDelay_inc = 1'b1;
  assign txShared_rxToTxDelay_twoCycle = (txShared_rxToTxDelay_counter == _zz_txShared_rxToTxDelay_twoCycle);
  always @(*) begin
    txShared_encoder_input_valid = 1'b0;
    if(txShared_serialiser_input_valid) begin
      txShared_encoder_input_valid = 1'b1;
    end
  end

  always @(*) begin
    txShared_encoder_input_ready = 1'b0;
    if(txShared_encoder_input_valid) begin
      if(txShared_encoder_input_data) begin
        if(txShared_timer_oneCycle) begin
          txShared_encoder_input_ready = 1'b1;
          if(when_UsbHubPhy_l189) begin
            txShared_encoder_input_ready = 1'b0;
          end
        end
      end else begin
        if(txShared_timer_oneCycle) begin
          txShared_encoder_input_ready = 1'b1;
        end
      end
    end
  end

  always @(*) begin
    txShared_encoder_input_data = 1'bx;
    if(txShared_serialiser_input_valid) begin
      txShared_encoder_input_data = txShared_serialiser_input_data[txShared_serialiser_bitCounter];
    end
  end

  always @(*) begin
    txShared_encoder_input_lowSpeed = 1'bx;
    if(txShared_serialiser_input_valid) begin
      txShared_encoder_input_lowSpeed = txShared_serialiser_input_lowSpeed;
    end
  end

  always @(*) begin
    txShared_encoder_output_valid = 1'b0;
    if(txShared_encoder_input_valid) begin
      txShared_encoder_output_valid = txShared_encoder_input_valid;
    end
    case(txShared_frame_stateReg)
      UsbOhciWishbone_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_TAKE_LINE : begin
        txShared_encoder_output_valid = 1'b1;
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_DELAY : begin
        txShared_encoder_output_valid = 1'b1;
      end
      UsbOhciWishbone_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_DATA : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_0 : begin
        txShared_encoder_output_valid = 1'b1;
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_1 : begin
        txShared_encoder_output_valid = 1'b1;
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    txShared_encoder_output_se0 = 1'b0;
    case(txShared_frame_stateReg)
      UsbOhciWishbone_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_TAKE_LINE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_DELAY : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_DATA : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_0 : begin
        txShared_encoder_output_se0 = 1'b1;
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_1 : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    txShared_encoder_output_lowSpeed = 1'bx;
    if(txShared_encoder_input_valid) begin
      txShared_encoder_output_lowSpeed = txShared_encoder_input_lowSpeed;
    end
    case(txShared_frame_stateReg)
      UsbOhciWishbone_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_TAKE_LINE : begin
        txShared_encoder_output_lowSpeed = 1'b0;
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_DELAY : begin
        txShared_encoder_output_lowSpeed = 1'b0;
      end
      UsbOhciWishbone_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_DATA : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_0 : begin
        txShared_encoder_output_lowSpeed = txShared_frame_wasLowSpeed;
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_1 : begin
        txShared_encoder_output_lowSpeed = txShared_frame_wasLowSpeed;
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    txShared_encoder_output_data = 1'bx;
    if(txShared_encoder_input_valid) begin
      if(txShared_encoder_input_data) begin
        txShared_encoder_output_data = txShared_encoder_state;
      end else begin
        txShared_encoder_output_data = (! txShared_encoder_state);
      end
    end
    case(txShared_frame_stateReg)
      UsbOhciWishbone_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_TAKE_LINE : begin
        txShared_encoder_output_data = 1'b1;
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_DELAY : begin
        txShared_encoder_output_data = 1'b1;
      end
      UsbOhciWishbone_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_DATA : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_0 : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_1 : begin
        txShared_encoder_output_data = 1'b1;
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  assign when_UsbHubPhy_l189 = (txShared_encoder_counter == 3'b101);
  assign when_UsbHubPhy_l194 = (txShared_encoder_counter == 3'b110);
  assign when_UsbHubPhy_l208 = (! txShared_encoder_input_valid);
  always @(*) begin
    txShared_serialiser_input_valid = 1'b0;
    case(txShared_frame_stateReg)
      UsbOhciWishbone_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_TAKE_LINE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_SYNC : begin
        txShared_serialiser_input_valid = 1'b1;
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_PID : begin
        txShared_serialiser_input_valid = 1'b1;
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_DELAY : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_SYNC : begin
        txShared_serialiser_input_valid = 1'b1;
      end
      UsbOhciWishbone_txShared_frame_enumDef_DATA : begin
        txShared_serialiser_input_valid = 1'b1;
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_0 : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_1 : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    txShared_serialiser_input_ready = 1'b0;
    if(txShared_serialiser_input_valid) begin
      if(txShared_encoder_input_ready) begin
        if(when_UsbHubPhy_l234) begin
          txShared_serialiser_input_ready = 1'b1;
        end
      end
    end
  end

  always @(*) begin
    txShared_serialiser_input_data = 8'bxxxxxxxx;
    case(txShared_frame_stateReg)
      UsbOhciWishbone_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_TAKE_LINE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_SYNC : begin
        txShared_serialiser_input_data = 8'h80;
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_PID : begin
        txShared_serialiser_input_data = 8'h3c;
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_DELAY : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_SYNC : begin
        txShared_serialiser_input_data = 8'h80;
      end
      UsbOhciWishbone_txShared_frame_enumDef_DATA : begin
        txShared_serialiser_input_data = io_ctrl_tx_payload_fragment;
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_0 : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_1 : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    txShared_serialiser_input_lowSpeed = 1'bx;
    case(txShared_frame_stateReg)
      UsbOhciWishbone_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_TAKE_LINE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_SYNC : begin
        txShared_serialiser_input_lowSpeed = 1'b0;
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_PID : begin
        txShared_serialiser_input_lowSpeed = 1'b0;
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_DELAY : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_SYNC : begin
        txShared_serialiser_input_lowSpeed = txShared_frame_wasLowSpeed;
      end
      UsbOhciWishbone_txShared_frame_enumDef_DATA : begin
        txShared_serialiser_input_lowSpeed = txShared_frame_wasLowSpeed;
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_0 : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_1 : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  assign when_UsbHubPhy_l234 = (txShared_serialiser_bitCounter == 3'b111);
  assign when_UsbHubPhy_l240 = ((! txShared_serialiser_input_valid) || txShared_serialiser_input_ready);
  always @(*) begin
    txShared_lowSpeedSof_increment = 1'b0;
    if(when_UsbHubPhy_l251) begin
      if(when_UsbHubPhy_l252) begin
        txShared_lowSpeedSof_increment = 1'b1;
      end
    end
  end

  assign when_UsbHubPhy_l249 = ((! txShared_encoder_output_valid) && txShared_encoder_output_valid_regNext);
  assign when_UsbHubPhy_l251 = (txShared_lowSpeedSof_state == 2'b00);
  assign io_ctrl_tx_fire = (io_ctrl_tx_valid && io_ctrl_tx_ready);
  assign when_UsbHubPhy_l252 = ((io_ctrl_tx_valid && io_ctrl_tx_payload_first) && (io_ctrl_tx_payload_fragment == 8'ha5));
  assign when_UsbHubPhy_l259 = (txShared_lowSpeedSof_timer == 5'h1f);
  assign txShared_lowSpeedSof_valid = (txShared_lowSpeedSof_state != 2'b00);
  assign txShared_lowSpeedSof_data = 1'b0;
  assign txShared_lowSpeedSof_se0 = (txShared_lowSpeedSof_state != 2'b11);
  assign txShared_frame_wantExit = 1'b0;
  always @(*) begin
    txShared_frame_wantStart = 1'b0;
    case(txShared_frame_stateReg)
      UsbOhciWishbone_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_TAKE_LINE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_DELAY : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_DATA : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_0 : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_1 : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
        txShared_frame_wantStart = 1'b1;
      end
    endcase
  end

  assign txShared_frame_wantKill = 1'b0;
  assign txShared_frame_busy = (! (txShared_frame_stateReg == UsbOhciWishbone_txShared_frame_enumDef_BOOT));
  always @(*) begin
    io_ctrl_tx_ready = 1'b0;
    case(txShared_frame_stateReg)
      UsbOhciWishbone_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_TAKE_LINE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_DELAY : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_DATA : begin
        if(txShared_serialiser_input_ready) begin
          io_ctrl_tx_ready = 1'b1;
        end
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_0 : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_1 : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_ctrl_txEop = 1'b0;
    case(txShared_frame_stateReg)
      UsbOhciWishbone_txShared_frame_enumDef_IDLE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_TAKE_LINE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_DELAY : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_DATA : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_0 : begin
        if(txShared_timer_twoCycle) begin
          io_ctrl_txEop = 1'b1;
        end
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_1 : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
  end

  assign upstreamRx_wantExit = 1'b0;
  always @(*) begin
    upstreamRx_wantStart = 1'b0;
    case(upstreamRx_stateReg)
      UsbOhciWishbone_upstreamRx_enumDef_IDLE : begin
      end
      UsbOhciWishbone_upstreamRx_enumDef_SUSPEND : begin
      end
      default : begin
        upstreamRx_wantStart = 1'b1;
      end
    endcase
  end

  assign upstreamRx_wantKill = 1'b0;
  always @(*) begin
    upstreamRx_timer_clear = 1'b0;
    if(txShared_encoder_output_valid) begin
      upstreamRx_timer_clear = 1'b1;
    end
  end

  assign upstreamRx_timer_inc = 1'b1;
  assign upstreamRx_timer_IDLE_EOI = (upstreamRx_timer_counter == 20'h2327f);
  assign io_ctrl_overcurrent = 1'b0;
  always @(*) begin
    io_ctrl_rx_flow_valid = 1'b0;
    case(ports_0_rx_packet_stateReg)
      UsbOhciWishbone_ports_0_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciWishbone_ports_0_rx_packet_enumDef_PACKET : begin
        if(ports_0_rx_destuffer_output_valid) begin
          if(when_UsbHubPhy_l527) begin
            io_ctrl_rx_flow_valid = ports_0_rx_enablePackets;
          end
        end
      end
      UsbOhciWishbone_ports_0_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    case(ports_1_rx_packet_stateReg)
      UsbOhciWishbone_ports_1_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciWishbone_ports_1_rx_packet_enumDef_PACKET : begin
        if(ports_1_rx_destuffer_output_valid) begin
          if(when_UsbHubPhy_l527_1) begin
            io_ctrl_rx_flow_valid = ports_1_rx_enablePackets;
          end
        end
      end
      UsbOhciWishbone_ports_1_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_ctrl_rx_active = 1'b0;
    case(ports_0_rx_packet_stateReg)
      UsbOhciWishbone_ports_0_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciWishbone_ports_0_rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_active = 1'b1;
      end
      UsbOhciWishbone_ports_0_rx_packet_enumDef_ERRORED : begin
        io_ctrl_rx_active = 1'b1;
      end
      default : begin
      end
    endcase
    case(ports_1_rx_packet_stateReg)
      UsbOhciWishbone_ports_1_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciWishbone_ports_1_rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_active = 1'b1;
      end
      UsbOhciWishbone_ports_1_rx_packet_enumDef_ERRORED : begin
        io_ctrl_rx_active = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_ctrl_rx_flow_payload_stuffingError = 1'b0;
    case(ports_0_rx_packet_stateReg)
      UsbOhciWishbone_ports_0_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciWishbone_ports_0_rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_flow_payload_stuffingError = ports_0_rx_stuffingError;
      end
      UsbOhciWishbone_ports_0_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    case(ports_1_rx_packet_stateReg)
      UsbOhciWishbone_ports_1_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciWishbone_ports_1_rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_flow_payload_stuffingError = ports_1_rx_stuffingError;
      end
      UsbOhciWishbone_ports_1_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_ctrl_rx_flow_payload_data = 8'bxxxxxxxx;
    case(ports_0_rx_packet_stateReg)
      UsbOhciWishbone_ports_0_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciWishbone_ports_0_rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_flow_payload_data = ports_0_rx_history_value;
      end
      UsbOhciWishbone_ports_0_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    case(ports_1_rx_packet_stateReg)
      UsbOhciWishbone_ports_1_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciWishbone_ports_1_rx_packet_enumDef_PACKET : begin
        io_ctrl_rx_flow_payload_data = ports_1_rx_history_value;
      end
      UsbOhciWishbone_ports_1_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    resumeFromPort = 1'b0;
    case(ports_0_fsm_stateReg)
      UsbOhciWishbone_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S : begin
        if(when_UsbHubPhy_l748) begin
          resumeFromPort = 1'b1;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E : begin
        if(when_UsbHubPhy_l758) begin
          resumeFromPort = 1'b1;
        end
      end
      default : begin
      end
    endcase
    case(ports_1_fsm_stateReg)
      UsbOhciWishbone_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S : begin
        if(when_UsbHubPhy_l748_1) begin
          resumeFromPort = 1'b1;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E : begin
        if(when_UsbHubPhy_l758_1) begin
          resumeFromPort = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign io_ctrl_ports_0_lowSpeed = ports_0_portLowSpeed;
  assign io_ctrl_ports_0_remoteResume = 1'b0;
  always @(*) begin
    ports_0_rx_enablePackets = 1'b0;
    case(ports_0_fsm_stateReg)
      UsbOhciWishbone_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED : begin
        ports_0_rx_enablePackets = 1'b1;
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign ports_0_rx_j = ((ports_0_filter_io_filtred_dp == (! ports_0_portLowSpeed)) && (ports_0_filter_io_filtred_dm == ports_0_portLowSpeed));
  assign ports_0_rx_k = ((ports_0_filter_io_filtred_dp == ports_0_portLowSpeed) && (ports_0_filter_io_filtred_dm == (! ports_0_portLowSpeed)));
  assign io_management_0_power = io_ctrl_ports_0_power;
  assign io_ctrl_ports_0_overcurrent = io_management_0_overcurrent;
  always @(*) begin
    ports_0_rx_waitSync = 1'b0;
    case(ports_0_rx_packet_stateReg)
      UsbOhciWishbone_ports_0_rx_packet_enumDef_IDLE : begin
        ports_0_rx_waitSync = 1'b1;
      end
      UsbOhciWishbone_ports_0_rx_packet_enumDef_PACKET : begin
      end
      UsbOhciWishbone_ports_0_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l238) begin
      ports_0_rx_waitSync = 1'b1;
    end
  end

  always @(*) begin
    ports_0_rx_decoder_output_valid = 1'b0;
    if(ports_0_filter_io_filtred_sample) begin
      ports_0_rx_decoder_output_valid = 1'b1;
    end
  end

  always @(*) begin
    ports_0_rx_decoder_output_payload = 1'bx;
    if(ports_0_filter_io_filtred_sample) begin
      if(when_UsbHubPhy_l445) begin
        ports_0_rx_decoder_output_payload = 1'b0;
      end else begin
        ports_0_rx_decoder_output_payload = 1'b1;
      end
    end
  end

  assign when_UsbHubPhy_l445 = ((ports_0_rx_decoder_state ^ ports_0_filter_io_filtred_d) ^ ports_0_portLowSpeed);
  assign ports_0_rx_destuffer_unstuffNext = (ports_0_rx_destuffer_counter == 3'b110);
  assign ports_0_rx_destuffer_output_valid = (ports_0_rx_decoder_output_valid && (! ports_0_rx_destuffer_unstuffNext));
  assign ports_0_rx_destuffer_output_payload = ports_0_rx_decoder_output_payload;
  assign when_UsbHubPhy_l466 = ((! ports_0_rx_decoder_output_payload) || ports_0_rx_destuffer_unstuffNext);
  assign ports_0_rx_history_updated = ports_0_rx_destuffer_output_valid;
  assign _zz_ports_0_rx_history_value = ports_0_rx_destuffer_output_payload;
  assign ports_0_rx_history_value = {_zz_ports_0_rx_history_value,{_zz_ports_0_rx_history_value_1,{_zz_ports_0_rx_history_value_2,{_zz_ports_0_rx_history_value_3,{_zz_ports_0_rx_history_value_4,{_zz_ports_0_rx_history_value_5,{_zz_ports_0_rx_history_value_6,_zz_ports_0_rx_history_value_7}}}}}}};
  assign ports_0_rx_history_sync_hit = (ports_0_rx_history_updated && (ports_0_rx_history_value == 8'hd5));
  assign ports_0_rx_eop_maxThreshold = (io_ctrl_lowSpeed ? 7'h60 : 7'h0c);
  assign ports_0_rx_eop_minThreshold = (io_ctrl_lowSpeed ? 6'h2a : 6'h05);
  assign ports_0_rx_eop_maxHit = (ports_0_rx_eop_counter == ports_0_rx_eop_maxThreshold);
  always @(*) begin
    ports_0_rx_eop_hit = 1'b0;
    if(ports_0_rx_j) begin
      if(when_UsbHubPhy_l501) begin
        ports_0_rx_eop_hit = 1'b1;
      end
    end
  end

  assign when_UsbHubPhy_l493 = ((! ports_0_filter_io_filtred_dp) && (! ports_0_filter_io_filtred_dm));
  assign when_UsbHubPhy_l494 = (! ports_0_rx_eop_maxHit);
  assign when_UsbHubPhy_l501 = ((_zz_when_UsbHubPhy_l501 <= ports_0_rx_eop_counter) && (! ports_0_rx_eop_maxHit));
  assign ports_0_rx_packet_wantExit = 1'b0;
  always @(*) begin
    ports_0_rx_packet_wantStart = 1'b0;
    case(ports_0_rx_packet_stateReg)
      UsbOhciWishbone_ports_0_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciWishbone_ports_0_rx_packet_enumDef_PACKET : begin
      end
      UsbOhciWishbone_ports_0_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
        ports_0_rx_packet_wantStart = 1'b1;
      end
    endcase
  end

  assign ports_0_rx_packet_wantKill = 1'b0;
  always @(*) begin
    ports_0_rx_packet_errorTimeout_clear = 1'b0;
    case(ports_0_rx_packet_stateReg)
      UsbOhciWishbone_ports_0_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciWishbone_ports_0_rx_packet_enumDef_PACKET : begin
      end
      UsbOhciWishbone_ports_0_rx_packet_enumDef_ERRORED : begin
        if(when_UsbHubPhy_l549) begin
          ports_0_rx_packet_errorTimeout_clear = 1'b1;
        end
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l238_1) begin
      ports_0_rx_packet_errorTimeout_clear = 1'b1;
    end
  end

  assign ports_0_rx_packet_errorTimeout_inc = 1'b1;
  assign ports_0_rx_packet_errorTimeout_lowSpeed = io_ctrl_lowSpeed;
  assign ports_0_rx_packet_errorTimeout_trigger = (ports_0_rx_packet_errorTimeout_counter == _zz_ports_0_rx_packet_errorTimeout_trigger);
  always @(*) begin
    ports_0_rx_disconnect_clear = 1'b0;
    if(when_UsbHubPhy_l573) begin
      ports_0_rx_disconnect_clear = 1'b1;
    end
    if(when_UsbHubPhy_l767) begin
      ports_0_rx_disconnect_clear = 1'b1;
    end
  end

  assign ports_0_rx_disconnect_hit = (ports_0_rx_disconnect_counter == 7'h68);
  assign ports_0_rx_disconnect_event = (ports_0_rx_disconnect_hit && (! ports_0_rx_disconnect_hitLast));
  assign when_UsbHubPhy_l573 = ((! ports_0_filter_io_filtred_se0) || io_usb_0_tx_enable);
  assign io_ctrl_ports_0_disconnect = ports_0_rx_disconnect_event;
  assign ports_0_fsm_wantExit = 1'b0;
  always @(*) begin
    ports_0_fsm_wantStart = 1'b0;
    case(ports_0_fsm_stateReg)
      UsbOhciWishbone_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
        ports_0_fsm_wantStart = 1'b1;
      end
    endcase
  end

  assign ports_0_fsm_wantKill = 1'b0;
  always @(*) begin
    ports_0_fsm_timer_clear = 1'b0;
    case(ports_0_fsm_stateReg)
      UsbOhciWishbone_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED : begin
        if(when_UsbHubPhy_l638) begin
          ports_0_fsm_timer_clear = 1'b1;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l238_2) begin
      ports_0_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l238_3) begin
      ports_0_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l238_4) begin
      ports_0_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l238_5) begin
      ports_0_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l238_6) begin
      ports_0_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l238_7) begin
      ports_0_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l238_8) begin
      ports_0_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l238_9) begin
      ports_0_fsm_timer_clear = 1'b1;
    end
  end

  assign ports_0_fsm_timer_inc = 1'b1;
  assign ports_0_fsm_timer_DISCONNECTED_EOI = (ports_0_fsm_timer_counter == 24'h005dbf);
  assign ports_0_fsm_timer_RESET_DELAY = (ports_0_fsm_timer_counter == 24'h00095f);
  assign ports_0_fsm_timer_RESET_EOI = (ports_0_fsm_timer_counter == 24'h249eff);
  assign ports_0_fsm_timer_RESUME_EOI = (ports_0_fsm_timer_counter == 24'h0f617f);
  assign ports_0_fsm_timer_RESTART_EOI = (ports_0_fsm_timer_counter == 24'h0012bf);
  assign ports_0_fsm_timer_ONE_BIT = (ports_0_fsm_timer_counter == _zz_ports_0_fsm_timer_ONE_BIT);
  assign ports_0_fsm_timer_TWO_BIT = (ports_0_fsm_timer_counter == _zz_ports_0_fsm_timer_TWO_BIT);
  always @(*) begin
    ports_0_fsm_timer_lowSpeed = ports_0_portLowSpeed;
    case(ports_0_fsm_stateReg)
      UsbOhciWishbone_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0 : begin
        if(ports_0_fsm_lowSpeedEop) begin
          ports_0_fsm_timer_lowSpeed = 1'b1;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1 : begin
        if(ports_0_fsm_lowSpeedEop) begin
          ports_0_fsm_timer_lowSpeed = 1'b1;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign io_ctrl_ports_0_disable_ready = 1'b1;
  always @(*) begin
    io_ctrl_ports_0_reset_ready = 1'b0;
    case(ports_0_fsm_stateReg)
      UsbOhciWishbone_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_SYNC : begin
        if(when_UsbHubPhy_l675) begin
          io_ctrl_ports_0_reset_ready = 1'b1;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign io_ctrl_ports_0_resume_ready = 1'b1;
  assign io_ctrl_ports_0_suspend_ready = 1'b1;
  always @(*) begin
    io_ctrl_ports_0_connect = 1'b0;
    case(ports_0_fsm_stateReg)
      UsbOhciWishbone_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED : begin
        if(ports_0_fsm_timer_DISCONNECTED_EOI) begin
          io_ctrl_ports_0_connect = 1'b1;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_usb_0_tx_enable = 1'b0;
    case(ports_0_fsm_stateReg)
      UsbOhciWishbone_ports_0_fsm_enumDef_POWER_OFF : begin
        io_usb_0_tx_enable = 1'b1;
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING : begin
        io_usb_0_tx_enable = 1'b1;
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED : begin
        io_usb_0_tx_enable = txShared_encoder_output_valid;
        if(when_UsbHubPhy_l688) begin
          io_usb_0_tx_enable = txShared_lowSpeedSof_valid;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING : begin
        io_usb_0_tx_enable = 1'b1;
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0 : begin
        io_usb_0_tx_enable = 1'b1;
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1 : begin
        io_usb_0_tx_enable = 1'b1;
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_usb_0_tx_data = 1'bx;
    case(ports_0_fsm_stateReg)
      UsbOhciWishbone_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED : begin
        io_usb_0_tx_data = ((txShared_encoder_output_data || ports_0_fsm_forceJ) ^ ports_0_portLowSpeed);
        if(when_UsbHubPhy_l688) begin
          io_usb_0_tx_data = txShared_lowSpeedSof_data;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING : begin
        io_usb_0_tx_data = ports_0_portLowSpeed;
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1 : begin
        io_usb_0_tx_data = (! ports_0_portLowSpeed);
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_usb_0_tx_se0 = 1'bx;
    case(ports_0_fsm_stateReg)
      UsbOhciWishbone_ports_0_fsm_enumDef_POWER_OFF : begin
        io_usb_0_tx_se0 = 1'b1;
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING : begin
        io_usb_0_tx_se0 = 1'b1;
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED : begin
        io_usb_0_tx_se0 = (txShared_encoder_output_se0 && (! ports_0_fsm_forceJ));
        if(when_UsbHubPhy_l688) begin
          io_usb_0_tx_se0 = txShared_lowSpeedSof_se0;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING : begin
        io_usb_0_tx_se0 = 1'b0;
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0 : begin
        io_usb_0_tx_se0 = 1'b1;
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1 : begin
        io_usb_0_tx_se0 = 1'b0;
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ports_0_fsm_resetInProgress = 1'b0;
    case(ports_0_fsm_stateReg)
      UsbOhciWishbone_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING : begin
        ports_0_fsm_resetInProgress = 1'b1;
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY : begin
        ports_0_fsm_resetInProgress = 1'b1;
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_SYNC : begin
        ports_0_fsm_resetInProgress = 1'b1;
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign ports_0_fsm_forceJ = (ports_0_portLowSpeed && (! txShared_encoder_output_lowSpeed));
  assign when_UsbHubPhy_l767 = (((! (ports_0_fsm_stateReg == UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED)) && (! (ports_0_fsm_stateReg == UsbOhciWishbone_ports_0_fsm_enumDef_SUSPENDED))) && (! (ports_0_fsm_stateReg == UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED)));
  assign io_ctrl_ports_1_lowSpeed = ports_1_portLowSpeed;
  assign io_ctrl_ports_1_remoteResume = 1'b0;
  always @(*) begin
    ports_1_rx_enablePackets = 1'b0;
    case(ports_1_fsm_stateReg)
      UsbOhciWishbone_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED : begin
        ports_1_rx_enablePackets = 1'b1;
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign ports_1_rx_j = ((ports_1_filter_io_filtred_dp == (! ports_1_portLowSpeed)) && (ports_1_filter_io_filtred_dm == ports_1_portLowSpeed));
  assign ports_1_rx_k = ((ports_1_filter_io_filtred_dp == ports_1_portLowSpeed) && (ports_1_filter_io_filtred_dm == (! ports_1_portLowSpeed)));
  assign io_management_1_power = io_ctrl_ports_1_power;
  assign io_ctrl_ports_1_overcurrent = io_management_1_overcurrent;
  always @(*) begin
    ports_1_rx_waitSync = 1'b0;
    case(ports_1_rx_packet_stateReg)
      UsbOhciWishbone_ports_1_rx_packet_enumDef_IDLE : begin
        ports_1_rx_waitSync = 1'b1;
      end
      UsbOhciWishbone_ports_1_rx_packet_enumDef_PACKET : begin
      end
      UsbOhciWishbone_ports_1_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l238_10) begin
      ports_1_rx_waitSync = 1'b1;
    end
  end

  always @(*) begin
    ports_1_rx_decoder_output_valid = 1'b0;
    if(ports_1_filter_io_filtred_sample) begin
      ports_1_rx_decoder_output_valid = 1'b1;
    end
  end

  always @(*) begin
    ports_1_rx_decoder_output_payload = 1'bx;
    if(ports_1_filter_io_filtred_sample) begin
      if(when_UsbHubPhy_l445_1) begin
        ports_1_rx_decoder_output_payload = 1'b0;
      end else begin
        ports_1_rx_decoder_output_payload = 1'b1;
      end
    end
  end

  assign when_UsbHubPhy_l445_1 = ((ports_1_rx_decoder_state ^ ports_1_filter_io_filtred_d) ^ ports_1_portLowSpeed);
  assign ports_1_rx_destuffer_unstuffNext = (ports_1_rx_destuffer_counter == 3'b110);
  assign ports_1_rx_destuffer_output_valid = (ports_1_rx_decoder_output_valid && (! ports_1_rx_destuffer_unstuffNext));
  assign ports_1_rx_destuffer_output_payload = ports_1_rx_decoder_output_payload;
  assign when_UsbHubPhy_l466_1 = ((! ports_1_rx_decoder_output_payload) || ports_1_rx_destuffer_unstuffNext);
  assign ports_1_rx_history_updated = ports_1_rx_destuffer_output_valid;
  assign _zz_ports_1_rx_history_value = ports_1_rx_destuffer_output_payload;
  assign ports_1_rx_history_value = {_zz_ports_1_rx_history_value,{_zz_ports_1_rx_history_value_1,{_zz_ports_1_rx_history_value_2,{_zz_ports_1_rx_history_value_3,{_zz_ports_1_rx_history_value_4,{_zz_ports_1_rx_history_value_5,{_zz_ports_1_rx_history_value_6,_zz_ports_1_rx_history_value_7}}}}}}};
  assign ports_1_rx_history_sync_hit = (ports_1_rx_history_updated && (ports_1_rx_history_value == 8'hd5));
  assign ports_1_rx_eop_maxThreshold = (io_ctrl_lowSpeed ? 7'h60 : 7'h0c);
  assign ports_1_rx_eop_minThreshold = (io_ctrl_lowSpeed ? 6'h2a : 6'h05);
  assign ports_1_rx_eop_maxHit = (ports_1_rx_eop_counter == ports_1_rx_eop_maxThreshold);
  always @(*) begin
    ports_1_rx_eop_hit = 1'b0;
    if(ports_1_rx_j) begin
      if(when_UsbHubPhy_l501_1) begin
        ports_1_rx_eop_hit = 1'b1;
      end
    end
  end

  assign when_UsbHubPhy_l493_1 = ((! ports_1_filter_io_filtred_dp) && (! ports_1_filter_io_filtred_dm));
  assign when_UsbHubPhy_l494_1 = (! ports_1_rx_eop_maxHit);
  assign when_UsbHubPhy_l501_1 = ((_zz_when_UsbHubPhy_l501_1 <= ports_1_rx_eop_counter) && (! ports_1_rx_eop_maxHit));
  assign ports_1_rx_packet_wantExit = 1'b0;
  always @(*) begin
    ports_1_rx_packet_wantStart = 1'b0;
    case(ports_1_rx_packet_stateReg)
      UsbOhciWishbone_ports_1_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciWishbone_ports_1_rx_packet_enumDef_PACKET : begin
      end
      UsbOhciWishbone_ports_1_rx_packet_enumDef_ERRORED : begin
      end
      default : begin
        ports_1_rx_packet_wantStart = 1'b1;
      end
    endcase
  end

  assign ports_1_rx_packet_wantKill = 1'b0;
  always @(*) begin
    ports_1_rx_packet_errorTimeout_clear = 1'b0;
    case(ports_1_rx_packet_stateReg)
      UsbOhciWishbone_ports_1_rx_packet_enumDef_IDLE : begin
      end
      UsbOhciWishbone_ports_1_rx_packet_enumDef_PACKET : begin
      end
      UsbOhciWishbone_ports_1_rx_packet_enumDef_ERRORED : begin
        if(when_UsbHubPhy_l549_1) begin
          ports_1_rx_packet_errorTimeout_clear = 1'b1;
        end
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l238_11) begin
      ports_1_rx_packet_errorTimeout_clear = 1'b1;
    end
  end

  assign ports_1_rx_packet_errorTimeout_inc = 1'b1;
  assign ports_1_rx_packet_errorTimeout_lowSpeed = io_ctrl_lowSpeed;
  assign ports_1_rx_packet_errorTimeout_trigger = (ports_1_rx_packet_errorTimeout_counter == _zz_ports_1_rx_packet_errorTimeout_trigger);
  always @(*) begin
    ports_1_rx_disconnect_clear = 1'b0;
    if(when_UsbHubPhy_l573_1) begin
      ports_1_rx_disconnect_clear = 1'b1;
    end
    if(when_UsbHubPhy_l767_1) begin
      ports_1_rx_disconnect_clear = 1'b1;
    end
  end

  assign ports_1_rx_disconnect_hit = (ports_1_rx_disconnect_counter == 7'h68);
  assign ports_1_rx_disconnect_event = (ports_1_rx_disconnect_hit && (! ports_1_rx_disconnect_hitLast));
  assign when_UsbHubPhy_l573_1 = ((! ports_1_filter_io_filtred_se0) || io_usb_1_tx_enable);
  assign io_ctrl_ports_1_disconnect = ports_1_rx_disconnect_event;
  assign ports_1_fsm_wantExit = 1'b0;
  always @(*) begin
    ports_1_fsm_wantStart = 1'b0;
    case(ports_1_fsm_stateReg)
      UsbOhciWishbone_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
        ports_1_fsm_wantStart = 1'b1;
      end
    endcase
  end

  assign ports_1_fsm_wantKill = 1'b0;
  always @(*) begin
    ports_1_fsm_timer_clear = 1'b0;
    case(ports_1_fsm_stateReg)
      UsbOhciWishbone_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED : begin
        if(when_UsbHubPhy_l638_1) begin
          ports_1_fsm_timer_clear = 1'b1;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l238_12) begin
      ports_1_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l238_13) begin
      ports_1_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l238_14) begin
      ports_1_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l238_15) begin
      ports_1_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l238_16) begin
      ports_1_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l238_17) begin
      ports_1_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l238_18) begin
      ports_1_fsm_timer_clear = 1'b1;
    end
    if(when_StateMachine_l238_19) begin
      ports_1_fsm_timer_clear = 1'b1;
    end
  end

  assign ports_1_fsm_timer_inc = 1'b1;
  assign ports_1_fsm_timer_DISCONNECTED_EOI = (ports_1_fsm_timer_counter == 24'h005dbf);
  assign ports_1_fsm_timer_RESET_DELAY = (ports_1_fsm_timer_counter == 24'h00095f);
  assign ports_1_fsm_timer_RESET_EOI = (ports_1_fsm_timer_counter == 24'h249eff);
  assign ports_1_fsm_timer_RESUME_EOI = (ports_1_fsm_timer_counter == 24'h0f617f);
  assign ports_1_fsm_timer_RESTART_EOI = (ports_1_fsm_timer_counter == 24'h0012bf);
  assign ports_1_fsm_timer_ONE_BIT = (ports_1_fsm_timer_counter == _zz_ports_1_fsm_timer_ONE_BIT);
  assign ports_1_fsm_timer_TWO_BIT = (ports_1_fsm_timer_counter == _zz_ports_1_fsm_timer_TWO_BIT);
  always @(*) begin
    ports_1_fsm_timer_lowSpeed = ports_1_portLowSpeed;
    case(ports_1_fsm_stateReg)
      UsbOhciWishbone_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0 : begin
        if(ports_1_fsm_lowSpeedEop) begin
          ports_1_fsm_timer_lowSpeed = 1'b1;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1 : begin
        if(ports_1_fsm_lowSpeedEop) begin
          ports_1_fsm_timer_lowSpeed = 1'b1;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign io_ctrl_ports_1_disable_ready = 1'b1;
  always @(*) begin
    io_ctrl_ports_1_reset_ready = 1'b0;
    case(ports_1_fsm_stateReg)
      UsbOhciWishbone_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_SYNC : begin
        if(when_UsbHubPhy_l675_1) begin
          io_ctrl_ports_1_reset_ready = 1'b1;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign io_ctrl_ports_1_resume_ready = 1'b1;
  assign io_ctrl_ports_1_suspend_ready = 1'b1;
  always @(*) begin
    io_ctrl_ports_1_connect = 1'b0;
    case(ports_1_fsm_stateReg)
      UsbOhciWishbone_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED : begin
        if(ports_1_fsm_timer_DISCONNECTED_EOI) begin
          io_ctrl_ports_1_connect = 1'b1;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_usb_1_tx_enable = 1'b0;
    case(ports_1_fsm_stateReg)
      UsbOhciWishbone_ports_1_fsm_enumDef_POWER_OFF : begin
        io_usb_1_tx_enable = 1'b1;
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING : begin
        io_usb_1_tx_enable = 1'b1;
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED : begin
        io_usb_1_tx_enable = txShared_encoder_output_valid;
        if(when_UsbHubPhy_l688_1) begin
          io_usb_1_tx_enable = txShared_lowSpeedSof_valid;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING : begin
        io_usb_1_tx_enable = 1'b1;
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0 : begin
        io_usb_1_tx_enable = 1'b1;
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1 : begin
        io_usb_1_tx_enable = 1'b1;
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_usb_1_tx_data = 1'bx;
    case(ports_1_fsm_stateReg)
      UsbOhciWishbone_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED : begin
        io_usb_1_tx_data = ((txShared_encoder_output_data || ports_1_fsm_forceJ) ^ ports_1_portLowSpeed);
        if(when_UsbHubPhy_l688_1) begin
          io_usb_1_tx_data = txShared_lowSpeedSof_data;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING : begin
        io_usb_1_tx_data = ports_1_portLowSpeed;
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1 : begin
        io_usb_1_tx_data = (! ports_1_portLowSpeed);
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_usb_1_tx_se0 = 1'bx;
    case(ports_1_fsm_stateReg)
      UsbOhciWishbone_ports_1_fsm_enumDef_POWER_OFF : begin
        io_usb_1_tx_se0 = 1'b1;
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING : begin
        io_usb_1_tx_se0 = 1'b1;
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED : begin
        io_usb_1_tx_se0 = (txShared_encoder_output_se0 && (! ports_1_fsm_forceJ));
        if(when_UsbHubPhy_l688_1) begin
          io_usb_1_tx_se0 = txShared_lowSpeedSof_se0;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING : begin
        io_usb_1_tx_se0 = 1'b0;
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0 : begin
        io_usb_1_tx_se0 = 1'b1;
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1 : begin
        io_usb_1_tx_se0 = 1'b0;
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ports_1_fsm_resetInProgress = 1'b0;
    case(ports_1_fsm_stateReg)
      UsbOhciWishbone_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING : begin
        ports_1_fsm_resetInProgress = 1'b1;
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY : begin
        ports_1_fsm_resetInProgress = 1'b1;
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_SYNC : begin
        ports_1_fsm_resetInProgress = 1'b1;
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
  end

  assign ports_1_fsm_forceJ = (ports_1_portLowSpeed && (! txShared_encoder_output_lowSpeed));
  assign when_UsbHubPhy_l767_1 = (((! (ports_1_fsm_stateReg == UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED)) && (! (ports_1_fsm_stateReg == UsbOhciWishbone_ports_1_fsm_enumDef_SUSPENDED))) && (! (ports_1_fsm_stateReg == UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED)));
  always @(*) begin
    txShared_frame_stateNext = txShared_frame_stateReg;
    case(txShared_frame_stateReg)
      UsbOhciWishbone_txShared_frame_enumDef_IDLE : begin
        if(when_UsbHubPhy_l289) begin
          txShared_frame_stateNext = UsbOhciWishbone_txShared_frame_enumDef_TAKE_LINE;
        end
      end
      UsbOhciWishbone_txShared_frame_enumDef_TAKE_LINE : begin
        if(txShared_timer_oneCycle) begin
          if(io_ctrl_lowSpeed) begin
            txShared_frame_stateNext = UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_SYNC;
          end else begin
            txShared_frame_stateNext = UsbOhciWishbone_txShared_frame_enumDef_SYNC;
          end
        end
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_SYNC : begin
        if(txShared_serialiser_input_ready) begin
          txShared_frame_stateNext = UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_PID;
        end
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_PID : begin
        if(txShared_serialiser_input_ready) begin
          txShared_frame_stateNext = UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_DELAY;
        end
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_DELAY : begin
        if(txShared_timer_fourCycle) begin
          txShared_frame_stateNext = UsbOhciWishbone_txShared_frame_enumDef_SYNC;
        end
      end
      UsbOhciWishbone_txShared_frame_enumDef_SYNC : begin
        if(txShared_serialiser_input_ready) begin
          txShared_frame_stateNext = UsbOhciWishbone_txShared_frame_enumDef_DATA;
        end
      end
      UsbOhciWishbone_txShared_frame_enumDef_DATA : begin
        if(txShared_serialiser_input_ready) begin
          if(io_ctrl_tx_payload_last) begin
            txShared_frame_stateNext = UsbOhciWishbone_txShared_frame_enumDef_EOP_0;
          end
        end
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_0 : begin
        if(txShared_timer_twoCycle) begin
          txShared_frame_stateNext = UsbOhciWishbone_txShared_frame_enumDef_EOP_1;
        end
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_1 : begin
        if(txShared_timer_oneCycle) begin
          txShared_frame_stateNext = UsbOhciWishbone_txShared_frame_enumDef_EOP_2;
        end
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_2 : begin
        if(txShared_timer_twoCycle) begin
          txShared_frame_stateNext = UsbOhciWishbone_txShared_frame_enumDef_IDLE;
        end
      end
      default : begin
      end
    endcase
    if(txShared_frame_wantStart) begin
      txShared_frame_stateNext = UsbOhciWishbone_txShared_frame_enumDef_IDLE;
    end
    if(txShared_frame_wantKill) begin
      txShared_frame_stateNext = UsbOhciWishbone_txShared_frame_enumDef_BOOT;
    end
  end

  assign when_UsbHubPhy_l289 = (io_ctrl_tx_valid && (! txShared_rxToTxDelay_active));
  always @(*) begin
    upstreamRx_stateNext = upstreamRx_stateReg;
    case(upstreamRx_stateReg)
      UsbOhciWishbone_upstreamRx_enumDef_IDLE : begin
        if(upstreamRx_timer_IDLE_EOI) begin
          upstreamRx_stateNext = UsbOhciWishbone_upstreamRx_enumDef_SUSPEND;
        end
      end
      UsbOhciWishbone_upstreamRx_enumDef_SUSPEND : begin
        if(txShared_encoder_output_valid) begin
          upstreamRx_stateNext = UsbOhciWishbone_upstreamRx_enumDef_IDLE;
        end
      end
      default : begin
      end
    endcase
    if(upstreamRx_wantStart) begin
      upstreamRx_stateNext = UsbOhciWishbone_upstreamRx_enumDef_IDLE;
    end
    if(upstreamRx_wantKill) begin
      upstreamRx_stateNext = UsbOhciWishbone_upstreamRx_enumDef_BOOT;
    end
  end

  assign Rx_Suspend = (upstreamRx_stateReg == UsbOhciWishbone_upstreamRx_enumDef_SUSPEND);
  always @(*) begin
    ports_0_rx_packet_stateNext = ports_0_rx_packet_stateReg;
    case(ports_0_rx_packet_stateReg)
      UsbOhciWishbone_ports_0_rx_packet_enumDef_IDLE : begin
        if(ports_0_rx_history_sync_hit) begin
          ports_0_rx_packet_stateNext = UsbOhciWishbone_ports_0_rx_packet_enumDef_PACKET;
        end
      end
      UsbOhciWishbone_ports_0_rx_packet_enumDef_PACKET : begin
        if(ports_0_rx_destuffer_output_valid) begin
          if(when_UsbHubPhy_l527) begin
            if(ports_0_rx_stuffingError) begin
              ports_0_rx_packet_stateNext = UsbOhciWishbone_ports_0_rx_packet_enumDef_ERRORED;
            end
          end
        end
      end
      UsbOhciWishbone_ports_0_rx_packet_enumDef_ERRORED : begin
        if(ports_0_rx_packet_errorTimeout_trigger) begin
          ports_0_rx_packet_stateNext = UsbOhciWishbone_ports_0_rx_packet_enumDef_IDLE;
        end
      end
      default : begin
      end
    endcase
    if(ports_0_rx_eop_hit) begin
      ports_0_rx_packet_stateNext = UsbOhciWishbone_ports_0_rx_packet_enumDef_IDLE;
    end
    if(txShared_encoder_output_valid) begin
      ports_0_rx_packet_stateNext = UsbOhciWishbone_ports_0_rx_packet_enumDef_IDLE;
    end
    if(ports_0_rx_packet_wantStart) begin
      ports_0_rx_packet_stateNext = UsbOhciWishbone_ports_0_rx_packet_enumDef_IDLE;
    end
    if(ports_0_rx_packet_wantKill) begin
      ports_0_rx_packet_stateNext = UsbOhciWishbone_ports_0_rx_packet_enumDef_BOOT;
    end
  end

  assign when_UsbHubPhy_l527 = (ports_0_rx_packet_counter == 3'b111);
  assign when_UsbHubPhy_l549 = ((ports_0_rx_packet_errorTimeout_p != ports_0_filter_io_filtred_dp) || (ports_0_rx_packet_errorTimeout_n != ports_0_filter_io_filtred_dm));
  assign when_StateMachine_l238 = ((! (ports_0_rx_packet_stateReg == UsbOhciWishbone_ports_0_rx_packet_enumDef_IDLE)) && (ports_0_rx_packet_stateNext == UsbOhciWishbone_ports_0_rx_packet_enumDef_IDLE));
  assign when_StateMachine_l238_1 = ((! (ports_0_rx_packet_stateReg == UsbOhciWishbone_ports_0_rx_packet_enumDef_ERRORED)) && (ports_0_rx_packet_stateNext == UsbOhciWishbone_ports_0_rx_packet_enumDef_ERRORED));
  always @(*) begin
    ports_0_fsm_stateNext = ports_0_fsm_stateReg;
    case(ports_0_fsm_stateReg)
      UsbOhciWishbone_ports_0_fsm_enumDef_POWER_OFF : begin
        if(io_ctrl_ports_0_power) begin
          ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED : begin
        if(ports_0_fsm_timer_DISCONNECTED_EOI) begin
          ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING : begin
        if(ports_0_fsm_timer_RESET_EOI) begin
          ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY : begin
        if(ports_0_fsm_timer_RESET_DELAY) begin
          ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_SYNC;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_SYNC : begin
        if(when_UsbHubPhy_l675) begin
          ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED : begin
        if(io_ctrl_ports_0_suspend_valid) begin
          ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_SUSPENDED;
        end else begin
          if(when_UsbHubPhy_l697) begin
            ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E;
          end else begin
            if(io_ctrl_usbResume) begin
              ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING;
            end
          end
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SUSPENDED : begin
        if(when_UsbHubPhy_l705) begin
          ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING;
        end else begin
          if(when_UsbHubPhy_l707) begin
            ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S;
          end
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING : begin
        if(ports_0_fsm_timer_RESUME_EOI) begin
          ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0 : begin
        if(ports_0_fsm_timer_TWO_BIT) begin
          ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1 : begin
        if(ports_0_fsm_timer_ONE_BIT) begin
          ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S : begin
        if(when_UsbHubPhy_l748) begin
          ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING;
        end
        if(ports_0_fsm_timer_RESTART_EOI) begin
          ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E : begin
        if(when_UsbHubPhy_l758) begin
          ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING;
        end
        if(ports_0_fsm_timer_RESTART_EOI) begin
          ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED;
        end
      end
      default : begin
      end
    endcase
    if(when_UsbHubPhy_l610) begin
      ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_POWER_OFF;
    end else begin
      if(ports_0_rx_disconnect_event) begin
        ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED;
      end else begin
        if(io_ctrl_ports_0_disable_valid) begin
          ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED;
        end else begin
          if(io_ctrl_ports_0_reset_valid) begin
            if(when_UsbHubPhy_l617) begin
              if(when_UsbHubPhy_l618) begin
                ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING;
              end
            end
          end
        end
      end
    end
    if(ports_0_fsm_wantStart) begin
      ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_POWER_OFF;
    end
    if(ports_0_fsm_wantKill) begin
      ports_0_fsm_stateNext = UsbOhciWishbone_ports_0_fsm_enumDef_BOOT;
    end
  end

  assign when_UsbHubPhy_l638 = ((! ports_0_filter_io_filtred_dp) && (! ports_0_filter_io_filtred_dm));
  assign when_UsbHubPhy_l675 = (! txShared_encoder_output_valid);
  assign when_UsbHubPhy_l688 = (ports_0_portLowSpeed && txShared_lowSpeedSof_overrideEncoder);
  assign when_UsbHubPhy_l697 = (Rx_Suspend && (ports_0_filter_io_filtred_se0 || ((! ports_0_filter_io_filtred_se0) && ((! ports_0_filter_io_filtred_d) ^ ports_0_portLowSpeed))));
  assign when_UsbHubPhy_l705 = (io_ctrl_ports_0_resume_valid || ((! Rx_Suspend) && ((! ports_0_filter_io_filtred_se0) && ((! ports_0_filter_io_filtred_d) ^ ports_0_portLowSpeed))));
  assign when_UsbHubPhy_l707 = (Rx_Suspend && (ports_0_filter_io_filtred_se0 || ((! ports_0_filter_io_filtred_se0) && ((! ports_0_filter_io_filtred_d) ^ ports_0_portLowSpeed))));
  assign when_UsbHubPhy_l748 = ((! ports_0_filter_io_filtred_se0) && ((! ports_0_filter_io_filtred_d) ^ ports_0_portLowSpeed));
  assign when_UsbHubPhy_l758 = ((! ports_0_filter_io_filtred_se0) && ((! ports_0_filter_io_filtred_d) ^ ports_0_portLowSpeed));
  assign when_StateMachine_l238_2 = ((! (ports_0_fsm_stateReg == UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED)) && (ports_0_fsm_stateNext == UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED));
  assign when_StateMachine_l238_3 = ((! (ports_0_fsm_stateReg == UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING)) && (ports_0_fsm_stateNext == UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING));
  assign when_StateMachine_l238_4 = ((! (ports_0_fsm_stateReg == UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY)) && (ports_0_fsm_stateNext == UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY));
  assign when_StateMachine_l238_5 = ((! (ports_0_fsm_stateReg == UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING)) && (ports_0_fsm_stateNext == UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING));
  assign when_StateMachine_l238_6 = ((! (ports_0_fsm_stateReg == UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0)) && (ports_0_fsm_stateNext == UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0));
  assign when_StateMachine_l238_7 = ((! (ports_0_fsm_stateReg == UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1)) && (ports_0_fsm_stateNext == UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1));
  assign when_StateMachine_l238_8 = ((! (ports_0_fsm_stateReg == UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S)) && (ports_0_fsm_stateNext == UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S));
  assign when_StateMachine_l238_9 = ((! (ports_0_fsm_stateReg == UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E)) && (ports_0_fsm_stateNext == UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E));
  assign when_UsbHubPhy_l610 = ((! io_ctrl_ports_0_power) || io_ctrl_usbReset);
  assign when_UsbHubPhy_l617 = (! ports_0_fsm_resetInProgress);
  assign when_UsbHubPhy_l618 = (ports_0_filter_io_filtred_dm != ports_0_filter_io_filtred_dp);
  always @(*) begin
    ports_1_rx_packet_stateNext = ports_1_rx_packet_stateReg;
    case(ports_1_rx_packet_stateReg)
      UsbOhciWishbone_ports_1_rx_packet_enumDef_IDLE : begin
        if(ports_1_rx_history_sync_hit) begin
          ports_1_rx_packet_stateNext = UsbOhciWishbone_ports_1_rx_packet_enumDef_PACKET;
        end
      end
      UsbOhciWishbone_ports_1_rx_packet_enumDef_PACKET : begin
        if(ports_1_rx_destuffer_output_valid) begin
          if(when_UsbHubPhy_l527_1) begin
            if(ports_1_rx_stuffingError) begin
              ports_1_rx_packet_stateNext = UsbOhciWishbone_ports_1_rx_packet_enumDef_ERRORED;
            end
          end
        end
      end
      UsbOhciWishbone_ports_1_rx_packet_enumDef_ERRORED : begin
        if(ports_1_rx_packet_errorTimeout_trigger) begin
          ports_1_rx_packet_stateNext = UsbOhciWishbone_ports_1_rx_packet_enumDef_IDLE;
        end
      end
      default : begin
      end
    endcase
    if(ports_1_rx_eop_hit) begin
      ports_1_rx_packet_stateNext = UsbOhciWishbone_ports_1_rx_packet_enumDef_IDLE;
    end
    if(txShared_encoder_output_valid) begin
      ports_1_rx_packet_stateNext = UsbOhciWishbone_ports_1_rx_packet_enumDef_IDLE;
    end
    if(ports_1_rx_packet_wantStart) begin
      ports_1_rx_packet_stateNext = UsbOhciWishbone_ports_1_rx_packet_enumDef_IDLE;
    end
    if(ports_1_rx_packet_wantKill) begin
      ports_1_rx_packet_stateNext = UsbOhciWishbone_ports_1_rx_packet_enumDef_BOOT;
    end
  end

  assign when_UsbHubPhy_l527_1 = (ports_1_rx_packet_counter == 3'b111);
  assign when_UsbHubPhy_l549_1 = ((ports_1_rx_packet_errorTimeout_p != ports_1_filter_io_filtred_dp) || (ports_1_rx_packet_errorTimeout_n != ports_1_filter_io_filtred_dm));
  assign when_StateMachine_l238_10 = ((! (ports_1_rx_packet_stateReg == UsbOhciWishbone_ports_1_rx_packet_enumDef_IDLE)) && (ports_1_rx_packet_stateNext == UsbOhciWishbone_ports_1_rx_packet_enumDef_IDLE));
  assign when_StateMachine_l238_11 = ((! (ports_1_rx_packet_stateReg == UsbOhciWishbone_ports_1_rx_packet_enumDef_ERRORED)) && (ports_1_rx_packet_stateNext == UsbOhciWishbone_ports_1_rx_packet_enumDef_ERRORED));
  always @(*) begin
    ports_1_fsm_stateNext = ports_1_fsm_stateReg;
    case(ports_1_fsm_stateReg)
      UsbOhciWishbone_ports_1_fsm_enumDef_POWER_OFF : begin
        if(io_ctrl_ports_1_power) begin
          ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED : begin
        if(ports_1_fsm_timer_DISCONNECTED_EOI) begin
          ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING : begin
        if(ports_1_fsm_timer_RESET_EOI) begin
          ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY : begin
        if(ports_1_fsm_timer_RESET_DELAY) begin
          ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_SYNC;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_SYNC : begin
        if(when_UsbHubPhy_l675_1) begin
          ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED : begin
        if(io_ctrl_ports_1_suspend_valid) begin
          ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_SUSPENDED;
        end else begin
          if(when_UsbHubPhy_l697_1) begin
            ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E;
          end else begin
            if(io_ctrl_usbResume) begin
              ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING;
            end
          end
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SUSPENDED : begin
        if(when_UsbHubPhy_l705_1) begin
          ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING;
        end else begin
          if(when_UsbHubPhy_l707_1) begin
            ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S;
          end
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING : begin
        if(ports_1_fsm_timer_RESUME_EOI) begin
          ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0 : begin
        if(ports_1_fsm_timer_TWO_BIT) begin
          ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1 : begin
        if(ports_1_fsm_timer_ONE_BIT) begin
          ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S : begin
        if(when_UsbHubPhy_l748_1) begin
          ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING;
        end
        if(ports_1_fsm_timer_RESTART_EOI) begin
          ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E : begin
        if(when_UsbHubPhy_l758_1) begin
          ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING;
        end
        if(ports_1_fsm_timer_RESTART_EOI) begin
          ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED;
        end
      end
      default : begin
      end
    endcase
    if(when_UsbHubPhy_l610_1) begin
      ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_POWER_OFF;
    end else begin
      if(ports_1_rx_disconnect_event) begin
        ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED;
      end else begin
        if(io_ctrl_ports_1_disable_valid) begin
          ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED;
        end else begin
          if(io_ctrl_ports_1_reset_valid) begin
            if(when_UsbHubPhy_l617_1) begin
              if(when_UsbHubPhy_l618_1) begin
                ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING;
              end
            end
          end
        end
      end
    end
    if(ports_1_fsm_wantStart) begin
      ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_POWER_OFF;
    end
    if(ports_1_fsm_wantKill) begin
      ports_1_fsm_stateNext = UsbOhciWishbone_ports_1_fsm_enumDef_BOOT;
    end
  end

  assign when_UsbHubPhy_l638_1 = ((! ports_1_filter_io_filtred_dp) && (! ports_1_filter_io_filtred_dm));
  assign when_UsbHubPhy_l675_1 = (! txShared_encoder_output_valid);
  assign when_UsbHubPhy_l688_1 = (ports_1_portLowSpeed && txShared_lowSpeedSof_overrideEncoder);
  assign when_UsbHubPhy_l697_1 = (Rx_Suspend && (ports_1_filter_io_filtred_se0 || ((! ports_1_filter_io_filtred_se0) && ((! ports_1_filter_io_filtred_d) ^ ports_1_portLowSpeed))));
  assign when_UsbHubPhy_l705_1 = (io_ctrl_ports_1_resume_valid || ((! Rx_Suspend) && ((! ports_1_filter_io_filtred_se0) && ((! ports_1_filter_io_filtred_d) ^ ports_1_portLowSpeed))));
  assign when_UsbHubPhy_l707_1 = (Rx_Suspend && (ports_1_filter_io_filtred_se0 || ((! ports_1_filter_io_filtred_se0) && ((! ports_1_filter_io_filtred_d) ^ ports_1_portLowSpeed))));
  assign when_UsbHubPhy_l748_1 = ((! ports_1_filter_io_filtred_se0) && ((! ports_1_filter_io_filtred_d) ^ ports_1_portLowSpeed));
  assign when_UsbHubPhy_l758_1 = ((! ports_1_filter_io_filtred_se0) && ((! ports_1_filter_io_filtred_d) ^ ports_1_portLowSpeed));
  assign when_StateMachine_l238_12 = ((! (ports_1_fsm_stateReg == UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED)) && (ports_1_fsm_stateNext == UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED));
  assign when_StateMachine_l238_13 = ((! (ports_1_fsm_stateReg == UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING)) && (ports_1_fsm_stateNext == UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING));
  assign when_StateMachine_l238_14 = ((! (ports_1_fsm_stateReg == UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY)) && (ports_1_fsm_stateNext == UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY));
  assign when_StateMachine_l238_15 = ((! (ports_1_fsm_stateReg == UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING)) && (ports_1_fsm_stateNext == UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING));
  assign when_StateMachine_l238_16 = ((! (ports_1_fsm_stateReg == UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0)) && (ports_1_fsm_stateNext == UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0));
  assign when_StateMachine_l238_17 = ((! (ports_1_fsm_stateReg == UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1)) && (ports_1_fsm_stateNext == UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1));
  assign when_StateMachine_l238_18 = ((! (ports_1_fsm_stateReg == UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S)) && (ports_1_fsm_stateNext == UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S));
  assign when_StateMachine_l238_19 = ((! (ports_1_fsm_stateReg == UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E)) && (ports_1_fsm_stateNext == UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E));
  assign when_UsbHubPhy_l610_1 = ((! io_ctrl_ports_1_power) || io_ctrl_usbReset);
  assign when_UsbHubPhy_l617_1 = (! ports_1_fsm_resetInProgress);
  assign when_UsbHubPhy_l618_1 = (ports_1_filter_io_filtred_dm != ports_1_filter_io_filtred_dp);
  always @(posedge phy_clk or posedge phy_reset) begin
    if(phy_reset) begin
      tickTimer_counter_value <= 2'b00;
      txShared_rxToTxDelay_active <= 1'b0;
      txShared_lowSpeedSof_state <= 2'b00;
      txShared_lowSpeedSof_overrideEncoder <= 1'b0;
      ports_0_rx_eop_counter <= 7'h0;
      ports_0_rx_disconnect_counter <= 7'h0;
      ports_1_rx_eop_counter <= 7'h0;
      ports_1_rx_disconnect_counter <= 7'h0;
      txShared_frame_stateReg <= UsbOhciWishbone_txShared_frame_enumDef_BOOT;
      upstreamRx_stateReg <= UsbOhciWishbone_upstreamRx_enumDef_BOOT;
      ports_0_rx_packet_stateReg <= UsbOhciWishbone_ports_0_rx_packet_enumDef_BOOT;
      ports_0_fsm_stateReg <= UsbOhciWishbone_ports_0_fsm_enumDef_BOOT;
      ports_1_rx_packet_stateReg <= UsbOhciWishbone_ports_1_rx_packet_enumDef_BOOT;
      ports_1_fsm_stateReg <= UsbOhciWishbone_ports_1_fsm_enumDef_BOOT;
    end else begin
      tickTimer_counter_value <= tickTimer_counter_valueNext;
      if(txShared_rxToTxDelay_twoCycle) begin
        txShared_rxToTxDelay_active <= 1'b0;
      end
      if(when_UsbHubPhy_l249) begin
        txShared_lowSpeedSof_overrideEncoder <= 1'b0;
      end
      txShared_lowSpeedSof_state <= (txShared_lowSpeedSof_state + _zz_txShared_lowSpeedSof_state);
      if(when_UsbHubPhy_l251) begin
        if(when_UsbHubPhy_l252) begin
          txShared_lowSpeedSof_overrideEncoder <= 1'b1;
        end
      end else begin
        if(when_UsbHubPhy_l259) begin
          txShared_lowSpeedSof_state <= (txShared_lowSpeedSof_state + 2'b01);
        end
      end
      if(when_UsbHubPhy_l493) begin
        if(when_UsbHubPhy_l494) begin
          ports_0_rx_eop_counter <= (ports_0_rx_eop_counter + 7'h01);
        end
      end else begin
        ports_0_rx_eop_counter <= 7'h0;
      end
      ports_0_rx_disconnect_counter <= (ports_0_rx_disconnect_counter + _zz_ports_0_rx_disconnect_counter);
      if(ports_0_rx_disconnect_clear) begin
        ports_0_rx_disconnect_counter <= 7'h0;
      end
      if(when_UsbHubPhy_l493_1) begin
        if(when_UsbHubPhy_l494_1) begin
          ports_1_rx_eop_counter <= (ports_1_rx_eop_counter + 7'h01);
        end
      end else begin
        ports_1_rx_eop_counter <= 7'h0;
      end
      ports_1_rx_disconnect_counter <= (ports_1_rx_disconnect_counter + _zz_ports_1_rx_disconnect_counter);
      if(ports_1_rx_disconnect_clear) begin
        ports_1_rx_disconnect_counter <= 7'h0;
      end
      txShared_frame_stateReg <= txShared_frame_stateNext;
      upstreamRx_stateReg <= upstreamRx_stateNext;
      ports_0_rx_packet_stateReg <= ports_0_rx_packet_stateNext;
      if(ports_0_rx_eop_hit) begin
        txShared_rxToTxDelay_active <= 1'b1;
      end
      ports_0_fsm_stateReg <= ports_0_fsm_stateNext;
      ports_1_rx_packet_stateReg <= ports_1_rx_packet_stateNext;
      if(ports_1_rx_eop_hit) begin
        txShared_rxToTxDelay_active <= 1'b1;
      end
      ports_1_fsm_stateReg <= ports_1_fsm_stateNext;
    end
  end

  always @(posedge phy_clk) begin
    if(txShared_timer_inc) begin
      txShared_timer_counter <= (txShared_timer_counter + 10'h001);
    end
    if(txShared_timer_clear) begin
      txShared_timer_counter <= 10'h0;
    end
    if(txShared_rxToTxDelay_inc) begin
      txShared_rxToTxDelay_counter <= (txShared_rxToTxDelay_counter + 9'h001);
    end
    if(txShared_rxToTxDelay_clear) begin
      txShared_rxToTxDelay_counter <= 9'h0;
    end
    if(txShared_encoder_input_valid) begin
      if(txShared_encoder_input_data) begin
        if(txShared_timer_oneCycle) begin
          txShared_encoder_counter <= (txShared_encoder_counter + 3'b001);
          if(when_UsbHubPhy_l189) begin
            txShared_encoder_state <= (! txShared_encoder_state);
          end
          if(when_UsbHubPhy_l194) begin
            txShared_encoder_counter <= 3'b000;
          end
        end
      end else begin
        if(txShared_timer_oneCycle) begin
          txShared_encoder_counter <= 3'b000;
          txShared_encoder_state <= (! txShared_encoder_state);
        end
      end
    end
    if(when_UsbHubPhy_l208) begin
      txShared_encoder_counter <= 3'b000;
      txShared_encoder_state <= 1'b1;
    end
    if(txShared_serialiser_input_valid) begin
      if(txShared_encoder_input_ready) begin
        txShared_serialiser_bitCounter <= (txShared_serialiser_bitCounter + 3'b001);
      end
    end
    if(when_UsbHubPhy_l240) begin
      txShared_serialiser_bitCounter <= 3'b000;
    end
    txShared_encoder_output_valid_regNext <= txShared_encoder_output_valid;
    if(when_UsbHubPhy_l251) begin
      if(when_UsbHubPhy_l252) begin
        txShared_lowSpeedSof_timer <= 5'h0;
      end
    end else begin
      txShared_lowSpeedSof_timer <= (txShared_lowSpeedSof_timer + 5'h01);
    end
    if(upstreamRx_timer_inc) begin
      upstreamRx_timer_counter <= (upstreamRx_timer_counter + 20'h00001);
    end
    if(upstreamRx_timer_clear) begin
      upstreamRx_timer_counter <= 20'h0;
    end
    if(ports_0_filter_io_filtred_sample) begin
      if(when_UsbHubPhy_l445) begin
        ports_0_rx_decoder_state <= (! ports_0_rx_decoder_state);
      end
    end
    if(ports_0_rx_waitSync) begin
      ports_0_rx_decoder_state <= 1'b0;
    end
    if(ports_0_rx_decoder_output_valid) begin
      ports_0_rx_destuffer_counter <= (ports_0_rx_destuffer_counter + 3'b001);
      if(when_UsbHubPhy_l466) begin
        ports_0_rx_destuffer_counter <= 3'b000;
        if(ports_0_rx_decoder_output_payload) begin
          ports_0_rx_stuffingError <= 1'b1;
        end
      end
    end
    if(ports_0_rx_waitSync) begin
      ports_0_rx_destuffer_counter <= 3'b000;
    end
    if(ports_0_rx_history_updated) begin
      _zz_ports_0_rx_history_value_1 <= _zz_ports_0_rx_history_value;
    end
    if(ports_0_rx_history_updated) begin
      _zz_ports_0_rx_history_value_2 <= _zz_ports_0_rx_history_value_1;
    end
    if(ports_0_rx_history_updated) begin
      _zz_ports_0_rx_history_value_3 <= _zz_ports_0_rx_history_value_2;
    end
    if(ports_0_rx_history_updated) begin
      _zz_ports_0_rx_history_value_4 <= _zz_ports_0_rx_history_value_3;
    end
    if(ports_0_rx_history_updated) begin
      _zz_ports_0_rx_history_value_5 <= _zz_ports_0_rx_history_value_4;
    end
    if(ports_0_rx_history_updated) begin
      _zz_ports_0_rx_history_value_6 <= _zz_ports_0_rx_history_value_5;
    end
    if(ports_0_rx_history_updated) begin
      _zz_ports_0_rx_history_value_7 <= _zz_ports_0_rx_history_value_6;
    end
    if(ports_0_rx_packet_errorTimeout_inc) begin
      ports_0_rx_packet_errorTimeout_counter <= (ports_0_rx_packet_errorTimeout_counter + 12'h001);
    end
    if(ports_0_rx_packet_errorTimeout_clear) begin
      ports_0_rx_packet_errorTimeout_counter <= 12'h0;
    end
    ports_0_rx_disconnect_hitLast <= ports_0_rx_disconnect_hit;
    if(ports_0_fsm_timer_inc) begin
      ports_0_fsm_timer_counter <= (ports_0_fsm_timer_counter + 24'h000001);
    end
    if(ports_0_fsm_timer_clear) begin
      ports_0_fsm_timer_counter <= 24'h0;
    end
    if(ports_1_filter_io_filtred_sample) begin
      if(when_UsbHubPhy_l445_1) begin
        ports_1_rx_decoder_state <= (! ports_1_rx_decoder_state);
      end
    end
    if(ports_1_rx_waitSync) begin
      ports_1_rx_decoder_state <= 1'b0;
    end
    if(ports_1_rx_decoder_output_valid) begin
      ports_1_rx_destuffer_counter <= (ports_1_rx_destuffer_counter + 3'b001);
      if(when_UsbHubPhy_l466_1) begin
        ports_1_rx_destuffer_counter <= 3'b000;
        if(ports_1_rx_decoder_output_payload) begin
          ports_1_rx_stuffingError <= 1'b1;
        end
      end
    end
    if(ports_1_rx_waitSync) begin
      ports_1_rx_destuffer_counter <= 3'b000;
    end
    if(ports_1_rx_history_updated) begin
      _zz_ports_1_rx_history_value_1 <= _zz_ports_1_rx_history_value;
    end
    if(ports_1_rx_history_updated) begin
      _zz_ports_1_rx_history_value_2 <= _zz_ports_1_rx_history_value_1;
    end
    if(ports_1_rx_history_updated) begin
      _zz_ports_1_rx_history_value_3 <= _zz_ports_1_rx_history_value_2;
    end
    if(ports_1_rx_history_updated) begin
      _zz_ports_1_rx_history_value_4 <= _zz_ports_1_rx_history_value_3;
    end
    if(ports_1_rx_history_updated) begin
      _zz_ports_1_rx_history_value_5 <= _zz_ports_1_rx_history_value_4;
    end
    if(ports_1_rx_history_updated) begin
      _zz_ports_1_rx_history_value_6 <= _zz_ports_1_rx_history_value_5;
    end
    if(ports_1_rx_history_updated) begin
      _zz_ports_1_rx_history_value_7 <= _zz_ports_1_rx_history_value_6;
    end
    if(ports_1_rx_packet_errorTimeout_inc) begin
      ports_1_rx_packet_errorTimeout_counter <= (ports_1_rx_packet_errorTimeout_counter + 12'h001);
    end
    if(ports_1_rx_packet_errorTimeout_clear) begin
      ports_1_rx_packet_errorTimeout_counter <= 12'h0;
    end
    ports_1_rx_disconnect_hitLast <= ports_1_rx_disconnect_hit;
    if(ports_1_fsm_timer_inc) begin
      ports_1_fsm_timer_counter <= (ports_1_fsm_timer_counter + 24'h000001);
    end
    if(ports_1_fsm_timer_clear) begin
      ports_1_fsm_timer_counter <= 24'h0;
    end
    case(txShared_frame_stateReg)
      UsbOhciWishbone_txShared_frame_enumDef_IDLE : begin
        txShared_frame_wasLowSpeed <= io_ctrl_lowSpeed;
      end
      UsbOhciWishbone_txShared_frame_enumDef_TAKE_LINE : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_PID : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_PREAMBLE_DELAY : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_SYNC : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_DATA : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_0 : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_1 : begin
      end
      UsbOhciWishbone_txShared_frame_enumDef_EOP_2 : begin
      end
      default : begin
      end
    endcase
    case(ports_0_rx_packet_stateReg)
      UsbOhciWishbone_ports_0_rx_packet_enumDef_IDLE : begin
        ports_0_rx_packet_counter <= 3'b000;
        ports_0_rx_stuffingError <= 1'b0;
      end
      UsbOhciWishbone_ports_0_rx_packet_enumDef_PACKET : begin
        if(ports_0_rx_destuffer_output_valid) begin
          ports_0_rx_packet_counter <= (ports_0_rx_packet_counter + 3'b001);
        end
      end
      UsbOhciWishbone_ports_0_rx_packet_enumDef_ERRORED : begin
        ports_0_rx_packet_errorTimeout_p <= ports_0_filter_io_filtred_dp;
        ports_0_rx_packet_errorTimeout_n <= ports_0_filter_io_filtred_dm;
      end
      default : begin
      end
    endcase
    if(ports_0_rx_eop_hit) begin
      txShared_rxToTxDelay_lowSpeed <= io_ctrl_lowSpeed;
    end
    case(ports_0_fsm_stateReg)
      UsbOhciWishbone_ports_0_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_ENABLED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESUMING : begin
        if(ports_0_fsm_timer_RESUME_EOI) begin
          ports_0_fsm_lowSpeedEop <= 1'b1;
        end
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_0_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
    if(!when_UsbHubPhy_l610) begin
      if(!ports_0_rx_disconnect_event) begin
        if(!io_ctrl_ports_0_disable_valid) begin
          if(io_ctrl_ports_0_reset_valid) begin
            if(when_UsbHubPhy_l617) begin
              if(when_UsbHubPhy_l618) begin
                ports_0_portLowSpeed <= (! ports_0_filter_io_filtred_d);
              end
            end
          end
        end
      end
    end
    case(ports_1_rx_packet_stateReg)
      UsbOhciWishbone_ports_1_rx_packet_enumDef_IDLE : begin
        ports_1_rx_packet_counter <= 3'b000;
        ports_1_rx_stuffingError <= 1'b0;
      end
      UsbOhciWishbone_ports_1_rx_packet_enumDef_PACKET : begin
        if(ports_1_rx_destuffer_output_valid) begin
          ports_1_rx_packet_counter <= (ports_1_rx_packet_counter + 3'b001);
        end
      end
      UsbOhciWishbone_ports_1_rx_packet_enumDef_ERRORED : begin
        ports_1_rx_packet_errorTimeout_p <= ports_1_filter_io_filtred_dp;
        ports_1_rx_packet_errorTimeout_n <= ports_1_filter_io_filtred_dm;
      end
      default : begin
      end
    endcase
    if(ports_1_rx_eop_hit) begin
      txShared_rxToTxDelay_lowSpeed <= io_ctrl_lowSpeed;
    end
    case(ports_1_fsm_stateReg)
      UsbOhciWishbone_ports_1_fsm_enumDef_POWER_OFF : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISCONNECTED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_DISABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_DELAY : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESETTING_SYNC : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_ENABLED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SUSPENDED : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESUMING : begin
        if(ports_1_fsm_timer_RESUME_EOI) begin
          ports_1_fsm_lowSpeedEop <= 1'b1;
        end
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_0 : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_SEND_EOP_1 : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_S : begin
      end
      UsbOhciWishbone_ports_1_fsm_enumDef_RESTART_E : begin
      end
      default : begin
      end
    endcase
    if(!when_UsbHubPhy_l610_1) begin
      if(!ports_1_rx_disconnect_event) begin
        if(!io_ctrl_ports_1_disable_valid) begin
          if(io_ctrl_ports_1_reset_valid) begin
            if(when_UsbHubPhy_l617_1) begin
              if(when_UsbHubPhy_l618_1) begin
                ports_1_portLowSpeed <= (! ports_1_filter_io_filtred_d);
              end
            end
          end
        end
      end
    end
  end

  always @(posedge phy_clk or posedge phy_reset) begin
    if(phy_reset) begin
      io_ctrl_tx_payload_first <= 1'b1;
    end else begin
      if(io_ctrl_tx_fire) begin
        io_ctrl_tx_payload_first <= io_ctrl_tx_payload_last;
      end
    end
  end


endmodule

module UsbOhciWishbone_UsbOhci (
  input               io_ctrl_cmd_valid,
  output              io_ctrl_cmd_ready,
  input               io_ctrl_cmd_payload_last,
  input      [0:0]    io_ctrl_cmd_payload_fragment_opcode,
  input      [11:0]   io_ctrl_cmd_payload_fragment_address,
  input      [1:0]    io_ctrl_cmd_payload_fragment_length,
  input      [31:0]   io_ctrl_cmd_payload_fragment_data,
  input      [3:0]    io_ctrl_cmd_payload_fragment_mask,
  output              io_ctrl_rsp_valid,
  input               io_ctrl_rsp_ready,
  output              io_ctrl_rsp_payload_last,
  output     [0:0]    io_ctrl_rsp_payload_fragment_opcode,
  output     [31:0]   io_ctrl_rsp_payload_fragment_data,
  output reg          io_phy_lowSpeed,
  output reg          io_phy_tx_valid,
  input               io_phy_tx_ready,
  output reg          io_phy_tx_payload_last,
  output reg [7:0]    io_phy_tx_payload_fragment,
  input               io_phy_txEop,
  input               io_phy_rx_flow_valid,
  input               io_phy_rx_flow_payload_stuffingError,
  input      [7:0]    io_phy_rx_flow_payload_data,
  input               io_phy_rx_active,
  output              io_phy_usbReset,
  output              io_phy_usbResume,
  input               io_phy_overcurrent,
  input               io_phy_tick,
  output              io_phy_ports_0_disable_valid,
  input               io_phy_ports_0_disable_ready,
  output              io_phy_ports_0_removable,
  output              io_phy_ports_0_power,
  output              io_phy_ports_0_reset_valid,
  input               io_phy_ports_0_reset_ready,
  output              io_phy_ports_0_suspend_valid,
  input               io_phy_ports_0_suspend_ready,
  output              io_phy_ports_0_resume_valid,
  input               io_phy_ports_0_resume_ready,
  input               io_phy_ports_0_connect,
  input               io_phy_ports_0_disconnect,
  input               io_phy_ports_0_overcurrent,
  input               io_phy_ports_0_remoteResume,
  input               io_phy_ports_0_lowSpeed,
  output              io_phy_ports_1_disable_valid,
  input               io_phy_ports_1_disable_ready,
  output              io_phy_ports_1_removable,
  output              io_phy_ports_1_power,
  output              io_phy_ports_1_reset_valid,
  input               io_phy_ports_1_reset_ready,
  output              io_phy_ports_1_suspend_valid,
  input               io_phy_ports_1_suspend_ready,
  output              io_phy_ports_1_resume_valid,
  input               io_phy_ports_1_resume_ready,
  input               io_phy_ports_1_connect,
  input               io_phy_ports_1_disconnect,
  input               io_phy_ports_1_overcurrent,
  input               io_phy_ports_1_remoteResume,
  input               io_phy_ports_1_lowSpeed,
  output              io_dma_cmd_valid,
  input               io_dma_cmd_ready,
  output              io_dma_cmd_payload_last,
  output     [0:0]    io_dma_cmd_payload_fragment_opcode,
  output     [31:0]   io_dma_cmd_payload_fragment_address,
  output     [5:0]    io_dma_cmd_payload_fragment_length,
  output     [31:0]   io_dma_cmd_payload_fragment_data,
  output     [3:0]    io_dma_cmd_payload_fragment_mask,
  input               io_dma_rsp_valid,
  output              io_dma_rsp_ready,
  input               io_dma_rsp_payload_last,
  input      [0:0]    io_dma_rsp_payload_fragment_opcode,
  input      [31:0]   io_dma_rsp_payload_fragment_data,
  output              io_interrupt,
  output              io_interruptBios,
  input               ctrl_clk,
  input               ctrl_reset
);
  localparam UsbOhciWishbone_MainState_RESET = 2'd0;
  localparam UsbOhciWishbone_MainState_RESUME = 2'd1;
  localparam UsbOhciWishbone_MainState_OPERATIONAL = 2'd2;
  localparam UsbOhciWishbone_MainState_SUSPEND = 2'd3;
  localparam UsbOhciWishbone_FlowType_BULK = 2'd0;
  localparam UsbOhciWishbone_FlowType_CONTROL = 2'd1;
  localparam UsbOhciWishbone_FlowType_PERIODIC = 2'd2;
  localparam UsbOhciWishbone_endpoint_Status_OK = 1'd0;
  localparam UsbOhciWishbone_endpoint_Status_FRAME_TIME = 1'd1;
  localparam UsbOhciWishbone_endpoint_enumDef_BOOT = 5'd0;
  localparam UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD = 5'd1;
  localparam UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP = 5'd2;
  localparam UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE = 5'd3;
  localparam UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD = 5'd4;
  localparam UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP = 5'd5;
  localparam UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY = 5'd6;
  localparam UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE = 5'd7;
  localparam UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME = 5'd8;
  localparam UsbOhciWishbone_endpoint_enumDef_BUFFER_READ = 5'd9;
  localparam UsbOhciWishbone_endpoint_enumDef_TOKEN = 5'd10;
  localparam UsbOhciWishbone_endpoint_enumDef_DATA_TX = 5'd11;
  localparam UsbOhciWishbone_endpoint_enumDef_DATA_RX = 5'd12;
  localparam UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE = 5'd13;
  localparam UsbOhciWishbone_endpoint_enumDef_ACK_RX = 5'd14;
  localparam UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 = 5'd15;
  localparam UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 = 5'd16;
  localparam UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP = 5'd17;
  localparam UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA = 5'd18;
  localparam UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS = 5'd19;
  localparam UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD = 5'd20;
  localparam UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD = 5'd21;
  localparam UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC = 5'd22;
  localparam UsbOhciWishbone_endpoint_enumDef_ABORD = 5'd23;
  localparam UsbOhciWishbone_endpoint_dmaLogic_enumDef_BOOT = 3'd0;
  localparam UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT = 3'd1;
  localparam UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB = 3'd2;
  localparam UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB = 3'd3;
  localparam UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION = 3'd4;
  localparam UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD = 3'd5;
  localparam UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD = 3'd6;
  localparam UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD = 3'd7;
  localparam UsbOhciWishbone_token_enumDef_BOOT = 3'd0;
  localparam UsbOhciWishbone_token_enumDef_INIT = 3'd1;
  localparam UsbOhciWishbone_token_enumDef_PID = 3'd2;
  localparam UsbOhciWishbone_token_enumDef_B1 = 3'd3;
  localparam UsbOhciWishbone_token_enumDef_B2 = 3'd4;
  localparam UsbOhciWishbone_token_enumDef_EOP = 3'd5;
  localparam UsbOhciWishbone_dataTx_enumDef_BOOT = 3'd0;
  localparam UsbOhciWishbone_dataTx_enumDef_PID = 3'd1;
  localparam UsbOhciWishbone_dataTx_enumDef_DATA = 3'd2;
  localparam UsbOhciWishbone_dataTx_enumDef_CRC_0 = 3'd3;
  localparam UsbOhciWishbone_dataTx_enumDef_CRC_1 = 3'd4;
  localparam UsbOhciWishbone_dataTx_enumDef_EOP = 3'd5;
  localparam UsbOhciWishbone_dataRx_enumDef_BOOT = 2'd0;
  localparam UsbOhciWishbone_dataRx_enumDef_IDLE = 2'd1;
  localparam UsbOhciWishbone_dataRx_enumDef_PID = 2'd2;
  localparam UsbOhciWishbone_dataRx_enumDef_DATA = 2'd3;
  localparam UsbOhciWishbone_sof_enumDef_BOOT = 2'd0;
  localparam UsbOhciWishbone_sof_enumDef_FRAME_TX = 2'd1;
  localparam UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD = 2'd2;
  localparam UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP = 2'd3;
  localparam UsbOhciWishbone_operational_enumDef_BOOT = 3'd0;
  localparam UsbOhciWishbone_operational_enumDef_SOF = 3'd1;
  localparam UsbOhciWishbone_operational_enumDef_ARBITER = 3'd2;
  localparam UsbOhciWishbone_operational_enumDef_END_POINT = 3'd3;
  localparam UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_CMD = 3'd4;
  localparam UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_RSP = 3'd5;
  localparam UsbOhciWishbone_operational_enumDef_WAIT_SOF = 3'd6;
  localparam UsbOhciWishbone_hc_enumDef_BOOT = 3'd0;
  localparam UsbOhciWishbone_hc_enumDef_RESET = 3'd1;
  localparam UsbOhciWishbone_hc_enumDef_RESUME = 3'd2;
  localparam UsbOhciWishbone_hc_enumDef_OPERATIONAL = 3'd3;
  localparam UsbOhciWishbone_hc_enumDef_SUSPEND = 3'd4;
  localparam UsbOhciWishbone_hc_enumDef_ANY_TO_RESET = 3'd5;
  localparam UsbOhciWishbone_hc_enumDef_ANY_TO_SUSPEND = 3'd6;

  reg                 fifo_io_push_valid;
  reg        [31:0]   fifo_io_push_payload;
  reg                 fifo_io_pop_ready;
  reg                 fifo_io_flush;
  reg                 token_crc5_io_flush;
  reg                 token_crc5_io_input_valid;
  reg                 dataTx_crc16_io_flush;
  reg                 dataRx_crc16_io_flush;
  reg                 dataRx_crc16_io_input_valid;
  wire                fifo_io_push_ready;
  wire                fifo_io_pop_valid;
  wire       [31:0]   fifo_io_pop_payload;
  wire       [9:0]    fifo_io_occupancy;
  wire       [9:0]    fifo_io_availability;
  wire       [4:0]    token_crc5_io_result;
  wire       [4:0]    token_crc5_io_resultNext;
  wire       [15:0]   dataTx_crc16_io_result;
  wire       [15:0]   dataTx_crc16_io_resultNext;
  wire       [15:0]   dataRx_crc16_io_result;
  wire       [15:0]   dataRx_crc16_io_resultNext;
  wire       [3:0]    _zz_dmaCtx_pendingCounter;
  wire       [3:0]    _zz_dmaCtx_pendingCounter_1;
  wire       [0:0]    _zz_dmaCtx_pendingCounter_2;
  wire       [3:0]    _zz_dmaCtx_pendingCounter_3;
  wire       [0:0]    _zz_dmaCtx_pendingCounter_4;
  wire       [0:0]    _zz_reg_hcCommandStatus_startSoftReset;
  wire       [0:0]    _zz_reg_hcCommandStatus_CLF;
  wire       [0:0]    _zz_reg_hcCommandStatus_BLF;
  wire       [0:0]    _zz_reg_hcCommandStatus_OCR;
  wire       [0:0]    _zz_reg_hcInterrupt_MIE;
  wire       [0:0]    _zz_reg_hcInterrupt_MIE_1;
  wire       [0:0]    _zz_reg_hcInterrupt_SO_status;
  wire       [0:0]    _zz_reg_hcInterrupt_SO_enable;
  wire       [0:0]    _zz_reg_hcInterrupt_SO_enable_1;
  wire       [0:0]    _zz_reg_hcInterrupt_WDH_status;
  wire       [0:0]    _zz_reg_hcInterrupt_WDH_enable;
  wire       [0:0]    _zz_reg_hcInterrupt_WDH_enable_1;
  wire       [0:0]    _zz_reg_hcInterrupt_SF_status;
  wire       [0:0]    _zz_reg_hcInterrupt_SF_enable;
  wire       [0:0]    _zz_reg_hcInterrupt_SF_enable_1;
  wire       [0:0]    _zz_reg_hcInterrupt_RD_status;
  wire       [0:0]    _zz_reg_hcInterrupt_RD_enable;
  wire       [0:0]    _zz_reg_hcInterrupt_RD_enable_1;
  wire       [0:0]    _zz_reg_hcInterrupt_UE_status;
  wire       [0:0]    _zz_reg_hcInterrupt_UE_enable;
  wire       [0:0]    _zz_reg_hcInterrupt_UE_enable_1;
  wire       [0:0]    _zz_reg_hcInterrupt_FNO_status;
  wire       [0:0]    _zz_reg_hcInterrupt_FNO_enable;
  wire       [0:0]    _zz_reg_hcInterrupt_FNO_enable_1;
  wire       [0:0]    _zz_reg_hcInterrupt_RHSC_status;
  wire       [0:0]    _zz_reg_hcInterrupt_RHSC_enable;
  wire       [0:0]    _zz_reg_hcInterrupt_RHSC_enable_1;
  wire       [0:0]    _zz_reg_hcInterrupt_OC_status;
  wire       [0:0]    _zz_reg_hcInterrupt_OC_enable;
  wire       [0:0]    _zz_reg_hcInterrupt_OC_enable_1;
  wire       [13:0]   _zz_reg_hcLSThreshold_hit;
  wire       [0:0]    _zz_reg_hcRhStatus_CCIC;
  wire       [0:0]    _zz_reg_hcRhStatus_clearGlobalPower;
  wire       [0:0]    _zz_reg_hcRhStatus_setRemoteWakeupEnable;
  wire       [0:0]    _zz_reg_hcRhStatus_setGlobalPower;
  wire       [0:0]    _zz_reg_hcRhStatus_clearRemoteWakeupEnable;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_clearPortEnable;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_setPortEnable;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_setPortSuspend;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_clearSuspendStatus;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_setPortReset;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_setPortPower;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_clearPortPower;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_CSC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_PESC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_PSSC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_OCIC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_0_PRSC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_clearPortEnable;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_setPortEnable;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_setPortSuspend;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_clearSuspendStatus;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_setPortReset;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_setPortPower;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_clearPortPower;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_CSC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_PESC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_PSSC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_OCIC_clear;
  wire       [0:0]    _zz_reg_hcRhPortStatus_1_PRSC_clear;
  wire       [7:0]    _zz_rxTimer_ackTx;
  wire       [3:0]    _zz_rxTimer_ackTx_1;
  wire       [15:0]   _zz_endpoint_TD_isoOverrun;
  wire       [12:0]   _zz_endpoint_TD_firstOffset;
  wire       [11:0]   _zz_endpoint_TD_firstOffset_1;
  wire       [12:0]   _zz_endpoint_TD_lastOffset;
  wire       [12:0]   _zz_endpoint_TD_lastOffset_1;
  wire       [0:0]    _zz_endpoint_TD_lastOffset_2;
  wire       [13:0]   _zz_endpoint_transactionSizeMinusOne;
  wire       [13:0]   _zz_endpoint_dataDone;
  wire       [5:0]    _zz_endpoint_dmaLogic_lengthMax;
  wire       [13:0]   _zz_endpoint_dmaLogic_lengthCalc;
  wire       [13:0]   _zz_endpoint_dmaLogic_lengthCalc_1;
  wire       [13:0]   _zz_endpoint_dmaLogic_lengthCalc_2;
  wire       [6:0]    _zz_endpoint_dmaLogic_beatCount;
  wire       [6:0]    _zz_endpoint_dmaLogic_beatCount_1;
  wire       [1:0]    _zz_endpoint_dmaLogic_beatCount_2;
  wire       [6:0]    _zz_endpoint_dmaLogic_lengthBmb;
  wire       [13:0]   _zz_endpoint_dmaLogic_lastMask;
  wire       [13:0]   _zz_endpoint_dmaLogic_lastMask_1;
  wire       [13:0]   _zz_endpoint_dmaLogic_lastMask_2;
  wire       [13:0]   _zz_endpoint_dmaLogic_lastMask_3;
  wire       [13:0]   _zz_endpoint_dmaLogic_lastMask_4;
  wire       [13:0]   _zz_endpoint_dmaLogic_lastMask_5;
  wire       [13:0]   _zz_endpoint_dmaLogic_lastMask_6;
  wire       [13:0]   _zz_endpoint_dmaLogic_lastMask_7;
  wire       [5:0]    _zz_endpoint_dmaLogic_beatLast;
  wire       [13:0]   _zz_endpoint_byteCountCalc;
  wire       [13:0]   _zz_endpoint_byteCountCalc_1;
  wire       [16:0]   _zz_endpoint_fsTimeCheck;
  wire       [16:0]   _zz_endpoint_fsTimeCheck_1;
  wire       [15:0]   _zz_token_data;
  wire       [4:0]    _zz_ioDma_cmd_payload_fragment_length;
  wire       [13:0]   _zz__zz_endpoint_lastAddress;
  wire       [13:0]   _zz__zz_endpoint_lastAddress_1;
  wire       [11:0]   _zz__zz_endpoint_lastAddress_2;
  wire       [13:0]   _zz_endpoint_lastAddress_1;
  wire       [13:0]   _zz_endpoint_lastAddress_2;
  wire       [13:0]   _zz_endpoint_lastAddress_3;
  wire       [13:0]   _zz_endpoint_lastAddress_4;
  wire       [13:0]   _zz_when_UsbOhci_l1331;
  wire       [1:0]    _zz_endpoint_TD_words_0;
  wire       [4:0]    _zz_ioDma_cmd_payload_fragment_length_1;
  wire       [3:0]    _zz_ioDma_cmd_payload_last;
  wire       [2:0]    _zz_ioDma_cmd_payload_last_1;
  wire       [11:0]   _zz__zz_ioDma_cmd_payload_fragment_data;
  wire       [13:0]   _zz__zz_ioDma_cmd_payload_fragment_data_1;
  wire       [13:0]   _zz__zz_ioDma_cmd_payload_fragment_data_2;
  wire       [13:0]   _zz__zz_ioDma_cmd_payload_fragment_data_3;
  reg        [7:0]    _zz_dataTx_data_payload_fragment;
  wire       [13:0]   _zz_when_UsbOhci_l1054;
  wire       [13:0]   _zz_endpoint_dmaLogic_overflow;
  wire       [13:0]   _zz_endpoint_lastAddress_5;
  wire       [13:0]   _zz_endpoint_lastAddress_6;
  wire       [13:0]   _zz_endpoint_lastAddress_7;
  wire       [10:0]   _zz_endpoint_dmaLogic_fromUsbCounter;
  wire       [0:0]    _zz_endpoint_dmaLogic_fromUsbCounter_1;
  wire       [13:0]   _zz_endpoint_currentAddress;
  wire       [13:0]   _zz_endpoint_currentAddress_1;
  wire       [13:0]   _zz_endpoint_currentAddress_2;
  wire       [13:0]   _zz_endpoint_currentAddress_3;
  wire       [31:0]   _zz_ioDma_cmd_payload_fragment_address;
  wire       [6:0]    _zz_ioDma_cmd_payload_fragment_address_1;
  reg                 unscheduleAll_valid;
  reg                 unscheduleAll_ready;
  reg                 ioDma_cmd_valid;
  wire                ioDma_cmd_ready;
  reg                 ioDma_cmd_payload_last;
  reg        [0:0]    ioDma_cmd_payload_fragment_opcode;
  reg        [31:0]   ioDma_cmd_payload_fragment_address;
  reg        [5:0]    ioDma_cmd_payload_fragment_length;
  reg        [31:0]   ioDma_cmd_payload_fragment_data;
  reg        [3:0]    ioDma_cmd_payload_fragment_mask;
  wire                ioDma_rsp_valid;
  wire                ioDma_rsp_ready;
  wire                ioDma_rsp_payload_last;
  wire       [0:0]    ioDma_rsp_payload_fragment_opcode;
  wire       [31:0]   ioDma_rsp_payload_fragment_data;
  reg        [3:0]    dmaCtx_pendingCounter;
  wire                ioDma_cmd_fire;
  wire                ioDma_rsp_fire;
  wire                dmaCtx_pendingFull;
  wire                dmaCtx_pendingEmpty;
  reg        [5:0]    dmaCtx_beatCounter;
  wire                ioDma_cmd_fire_1;
  wire                when_UsbOhci_l157;
  wire                io_dma_cmd_fire;
  reg                 io_dma_cmd_payload_first;
  wire                _zz_io_dma_cmd_valid;
  wire       [31:0]   dmaRspMux_vec_0;
  wire       [31:0]   dmaRspMux_data;
  reg        [3:0]    dmaReadCtx_counter;
  wire                ioDma_rsp_fire_1;
  reg        [3:0]    dmaWriteCtx_counter;
  wire                ioDma_cmd_fire_2;
  reg                 ctrlHalt;
  wire                ctrl_readHaltTrigger;
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
  wire                when_Stream_l342;
  wire                ctrl_askWrite;
  wire                ctrl_askRead;
  wire                io_ctrl_cmd_fire;
  wire                ctrl_doWrite;
  wire                io_ctrl_cmd_fire_1;
  wire                ctrl_doRead;
  reg                 doUnschedule;
  reg                 doSoftReset;
  wire                when_UsbOhci_l236;
  wire       [4:0]    reg_hcRevision_REV;
  reg        [1:0]    reg_hcControl_CBSR;
  reg                 reg_hcControl_PLE;
  reg                 reg_hcControl_IE;
  reg                 reg_hcControl_CLE;
  reg                 reg_hcControl_BLE;
  reg        [1:0]    reg_hcControl_HCFS;
  reg                 reg_hcControl_IR;
  reg                 reg_hcControl_RWC;
  reg                 reg_hcControl_RWE;
  reg                 reg_hcControl_HCFSWrite_valid;
  wire       [1:0]    reg_hcControl_HCFSWrite_payload;
  reg                 reg_hcCommandStatus_startSoftReset;
  reg                 when_BusSlaveFactory_l366;
  wire                when_BusSlaveFactory_l368;
  reg                 reg_hcCommandStatus_CLF;
  reg                 when_BusSlaveFactory_l366_1;
  wire                when_BusSlaveFactory_l368_1;
  reg                 reg_hcCommandStatus_BLF;
  reg                 when_BusSlaveFactory_l366_2;
  wire                when_BusSlaveFactory_l368_2;
  reg                 reg_hcCommandStatus_OCR;
  reg                 when_BusSlaveFactory_l366_3;
  wire                when_BusSlaveFactory_l368_3;
  reg        [1:0]    reg_hcCommandStatus_SOC;
  reg                 reg_hcInterrupt_unmaskedPending;
  reg                 reg_hcInterrupt_MIE;
  reg                 when_BusSlaveFactory_l366_4;
  wire                when_BusSlaveFactory_l368_4;
  reg                 when_BusSlaveFactory_l335;
  wire                when_BusSlaveFactory_l337;
  reg                 reg_hcInterrupt_SO_status;
  reg                 when_BusSlaveFactory_l335_1;
  wire                when_BusSlaveFactory_l337_1;
  reg                 reg_hcInterrupt_SO_enable;
  reg                 when_BusSlaveFactory_l366_5;
  wire                when_BusSlaveFactory_l368_5;
  reg                 when_BusSlaveFactory_l335_2;
  wire                when_BusSlaveFactory_l337_2;
  wire                when_UsbOhci_l302;
  reg                 reg_hcInterrupt_WDH_status;
  reg                 when_BusSlaveFactory_l335_3;
  wire                when_BusSlaveFactory_l337_3;
  reg                 reg_hcInterrupt_WDH_enable;
  reg                 when_BusSlaveFactory_l366_6;
  wire                when_BusSlaveFactory_l368_6;
  reg                 when_BusSlaveFactory_l335_4;
  wire                when_BusSlaveFactory_l337_4;
  wire                when_UsbOhci_l302_1;
  reg                 reg_hcInterrupt_SF_status;
  reg                 when_BusSlaveFactory_l335_5;
  wire                when_BusSlaveFactory_l337_5;
  reg                 reg_hcInterrupt_SF_enable;
  reg                 when_BusSlaveFactory_l366_7;
  wire                when_BusSlaveFactory_l368_7;
  reg                 when_BusSlaveFactory_l335_6;
  wire                when_BusSlaveFactory_l337_6;
  wire                when_UsbOhci_l302_2;
  reg                 reg_hcInterrupt_RD_status;
  reg                 when_BusSlaveFactory_l335_7;
  wire                when_BusSlaveFactory_l337_7;
  reg                 reg_hcInterrupt_RD_enable;
  reg                 when_BusSlaveFactory_l366_8;
  wire                when_BusSlaveFactory_l368_8;
  reg                 when_BusSlaveFactory_l335_8;
  wire                when_BusSlaveFactory_l337_8;
  wire                when_UsbOhci_l302_3;
  reg                 reg_hcInterrupt_UE_status;
  reg                 when_BusSlaveFactory_l335_9;
  wire                when_BusSlaveFactory_l337_9;
  reg                 reg_hcInterrupt_UE_enable;
  reg                 when_BusSlaveFactory_l366_9;
  wire                when_BusSlaveFactory_l368_9;
  reg                 when_BusSlaveFactory_l335_10;
  wire                when_BusSlaveFactory_l337_10;
  wire                when_UsbOhci_l302_4;
  reg                 reg_hcInterrupt_FNO_status;
  reg                 when_BusSlaveFactory_l335_11;
  wire                when_BusSlaveFactory_l337_11;
  reg                 reg_hcInterrupt_FNO_enable;
  reg                 when_BusSlaveFactory_l366_10;
  wire                when_BusSlaveFactory_l368_10;
  reg                 when_BusSlaveFactory_l335_12;
  wire                when_BusSlaveFactory_l337_12;
  wire                when_UsbOhci_l302_5;
  reg                 reg_hcInterrupt_RHSC_status;
  reg                 when_BusSlaveFactory_l335_13;
  wire                when_BusSlaveFactory_l337_13;
  reg                 reg_hcInterrupt_RHSC_enable;
  reg                 when_BusSlaveFactory_l366_11;
  wire                when_BusSlaveFactory_l368_11;
  reg                 when_BusSlaveFactory_l335_14;
  wire                when_BusSlaveFactory_l337_14;
  wire                when_UsbOhci_l302_6;
  reg                 reg_hcInterrupt_OC_status;
  reg                 when_BusSlaveFactory_l335_15;
  wire                when_BusSlaveFactory_l337_15;
  reg                 reg_hcInterrupt_OC_enable;
  reg                 when_BusSlaveFactory_l366_12;
  wire                when_BusSlaveFactory_l368_12;
  reg                 when_BusSlaveFactory_l335_16;
  wire                when_BusSlaveFactory_l337_16;
  wire                reg_hcInterrupt_doIrq;
  wire       [31:0]   reg_hcHCCA_HCCA_address;
  reg        [23:0]   reg_hcHCCA_HCCA_reg;
  wire       [31:0]   reg_hcPeriodCurrentED_PCED_address;
  reg        [27:0]   reg_hcPeriodCurrentED_PCED_reg;
  wire                reg_hcPeriodCurrentED_isZero;
  wire       [31:0]   reg_hcControlHeadED_CHED_address;
  reg        [27:0]   reg_hcControlHeadED_CHED_reg;
  wire       [31:0]   reg_hcControlCurrentED_CCED_address;
  reg        [27:0]   reg_hcControlCurrentED_CCED_reg;
  wire                reg_hcControlCurrentED_isZero;
  wire       [31:0]   reg_hcBulkHeadED_BHED_address;
  reg        [27:0]   reg_hcBulkHeadED_BHED_reg;
  wire       [31:0]   reg_hcBulkCurrentED_BCED_address;
  reg        [27:0]   reg_hcBulkCurrentED_BCED_reg;
  wire                reg_hcBulkCurrentED_isZero;
  wire       [31:0]   reg_hcDoneHead_DH_address;
  reg        [27:0]   reg_hcDoneHead_DH_reg;
  reg        [13:0]   reg_hcFmInterval_FI;
  reg        [14:0]   reg_hcFmInterval_FSMPS;
  reg                 reg_hcFmInterval_FIT;
  reg        [13:0]   reg_hcFmRemaining_FR;
  reg                 reg_hcFmRemaining_FRT;
  reg        [15:0]   reg_hcFmNumber_FN;
  reg                 reg_hcFmNumber_overflow;
  wire       [15:0]   reg_hcFmNumber_FNp1;
  reg        [13:0]   reg_hcPeriodicStart_PS;
  reg        [11:0]   reg_hcLSThreshold_LST;
  wire                reg_hcLSThreshold_hit;
  wire       [7:0]    reg_hcRhDescriptorA_NDP;
  reg                 reg_hcRhDescriptorA_PSM;
  reg                 reg_hcRhDescriptorA_NPS;
  reg                 reg_hcRhDescriptorA_OCPM;
  reg                 reg_hcRhDescriptorA_NOCP;
  reg        [7:0]    reg_hcRhDescriptorA_POTPGT;
  reg        [1:0]    reg_hcRhDescriptorB_DR;
  reg        [1:0]    reg_hcRhDescriptorB_PPCM;
  reg                 reg_hcRhStatus_DRWE;
  reg                 reg_hcRhStatus_CCIC;
  reg                 when_BusSlaveFactory_l335_17;
  wire                when_BusSlaveFactory_l337_17;
  reg                 io_phy_overcurrent_regNext;
  wire                when_UsbOhci_l409;
  reg                 reg_hcRhStatus_clearGlobalPower;
  reg                 when_BusSlaveFactory_l366_13;
  wire                when_BusSlaveFactory_l368_13;
  reg                 reg_hcRhStatus_setRemoteWakeupEnable;
  reg                 when_BusSlaveFactory_l366_14;
  wire                when_BusSlaveFactory_l368_14;
  reg                 reg_hcRhStatus_setGlobalPower;
  reg                 when_BusSlaveFactory_l366_15;
  wire                when_BusSlaveFactory_l368_15;
  reg                 reg_hcRhStatus_clearRemoteWakeupEnable;
  reg                 when_BusSlaveFactory_l366_16;
  wire                when_BusSlaveFactory_l368_16;
  reg                 reg_hcRhPortStatus_0_clearPortEnable;
  reg                 when_BusSlaveFactory_l366_17;
  wire                when_BusSlaveFactory_l368_17;
  reg                 reg_hcRhPortStatus_0_setPortEnable;
  reg                 when_BusSlaveFactory_l366_18;
  wire                when_BusSlaveFactory_l368_18;
  reg                 reg_hcRhPortStatus_0_setPortSuspend;
  reg                 when_BusSlaveFactory_l366_19;
  wire                when_BusSlaveFactory_l368_19;
  reg                 reg_hcRhPortStatus_0_clearSuspendStatus;
  reg                 when_BusSlaveFactory_l366_20;
  wire                when_BusSlaveFactory_l368_20;
  reg                 reg_hcRhPortStatus_0_setPortReset;
  reg                 when_BusSlaveFactory_l366_21;
  wire                when_BusSlaveFactory_l368_21;
  reg                 reg_hcRhPortStatus_0_setPortPower;
  reg                 when_BusSlaveFactory_l366_22;
  wire                when_BusSlaveFactory_l368_22;
  reg                 reg_hcRhPortStatus_0_clearPortPower;
  reg                 when_BusSlaveFactory_l366_23;
  wire                when_BusSlaveFactory_l368_23;
  reg                 reg_hcRhPortStatus_0_resume;
  reg                 reg_hcRhPortStatus_0_reset;
  reg                 reg_hcRhPortStatus_0_suspend;
  reg                 reg_hcRhPortStatus_0_connected;
  reg                 reg_hcRhPortStatus_0_PSS;
  reg                 reg_hcRhPortStatus_0_PPS;
  wire                reg_hcRhPortStatus_0_CCS;
  reg                 reg_hcRhPortStatus_0_PES;
  wire                reg_hcRhPortStatus_0_CSC_set;
  reg                 reg_hcRhPortStatus_0_CSC_clear;
  reg                 reg_hcRhPortStatus_0_CSC_reg;
  reg                 when_BusSlaveFactory_l366_24;
  wire                when_BusSlaveFactory_l368_24;
  wire                reg_hcRhPortStatus_0_PESC_set;
  reg                 reg_hcRhPortStatus_0_PESC_clear;
  reg                 reg_hcRhPortStatus_0_PESC_reg;
  reg                 when_BusSlaveFactory_l366_25;
  wire                when_BusSlaveFactory_l368_25;
  wire                reg_hcRhPortStatus_0_PSSC_set;
  reg                 reg_hcRhPortStatus_0_PSSC_clear;
  reg                 reg_hcRhPortStatus_0_PSSC_reg;
  reg                 when_BusSlaveFactory_l366_26;
  wire                when_BusSlaveFactory_l368_26;
  wire                reg_hcRhPortStatus_0_OCIC_set;
  reg                 reg_hcRhPortStatus_0_OCIC_clear;
  reg                 reg_hcRhPortStatus_0_OCIC_reg;
  reg                 when_BusSlaveFactory_l366_27;
  wire                when_BusSlaveFactory_l368_27;
  wire                reg_hcRhPortStatus_0_PRSC_set;
  reg                 reg_hcRhPortStatus_0_PRSC_clear;
  reg                 reg_hcRhPortStatus_0_PRSC_reg;
  reg                 when_BusSlaveFactory_l366_28;
  wire                when_BusSlaveFactory_l368_28;
  wire                when_UsbOhci_l460;
  wire                when_UsbOhci_l460_1;
  wire                when_UsbOhci_l460_2;
  wire                when_UsbOhci_l461;
  wire                when_UsbOhci_l461_1;
  wire                when_UsbOhci_l462;
  wire                when_UsbOhci_l463;
  wire                when_UsbOhci_l464;
  wire                when_UsbOhci_l470;
  reg                 reg_hcRhPortStatus_0_CCS_regNext;
  wire                io_phy_ports_0_suspend_fire;
  wire                io_phy_ports_0_reset_fire;
  wire                io_phy_ports_0_resume_fire;
  wire                io_phy_ports_0_reset_fire_1;
  wire                io_phy_ports_0_suspend_fire_1;
  reg                 reg_hcRhPortStatus_1_clearPortEnable;
  reg                 when_BusSlaveFactory_l366_29;
  wire                when_BusSlaveFactory_l368_29;
  reg                 reg_hcRhPortStatus_1_setPortEnable;
  reg                 when_BusSlaveFactory_l366_30;
  wire                when_BusSlaveFactory_l368_30;
  reg                 reg_hcRhPortStatus_1_setPortSuspend;
  reg                 when_BusSlaveFactory_l366_31;
  wire                when_BusSlaveFactory_l368_31;
  reg                 reg_hcRhPortStatus_1_clearSuspendStatus;
  reg                 when_BusSlaveFactory_l366_32;
  wire                when_BusSlaveFactory_l368_32;
  reg                 reg_hcRhPortStatus_1_setPortReset;
  reg                 when_BusSlaveFactory_l366_33;
  wire                when_BusSlaveFactory_l368_33;
  reg                 reg_hcRhPortStatus_1_setPortPower;
  reg                 when_BusSlaveFactory_l366_34;
  wire                when_BusSlaveFactory_l368_34;
  reg                 reg_hcRhPortStatus_1_clearPortPower;
  reg                 when_BusSlaveFactory_l366_35;
  wire                when_BusSlaveFactory_l368_35;
  reg                 reg_hcRhPortStatus_1_resume;
  reg                 reg_hcRhPortStatus_1_reset;
  reg                 reg_hcRhPortStatus_1_suspend;
  reg                 reg_hcRhPortStatus_1_connected;
  reg                 reg_hcRhPortStatus_1_PSS;
  reg                 reg_hcRhPortStatus_1_PPS;
  wire                reg_hcRhPortStatus_1_CCS;
  reg                 reg_hcRhPortStatus_1_PES;
  wire                reg_hcRhPortStatus_1_CSC_set;
  reg                 reg_hcRhPortStatus_1_CSC_clear;
  reg                 reg_hcRhPortStatus_1_CSC_reg;
  reg                 when_BusSlaveFactory_l366_36;
  wire                when_BusSlaveFactory_l368_36;
  wire                reg_hcRhPortStatus_1_PESC_set;
  reg                 reg_hcRhPortStatus_1_PESC_clear;
  reg                 reg_hcRhPortStatus_1_PESC_reg;
  reg                 when_BusSlaveFactory_l366_37;
  wire                when_BusSlaveFactory_l368_37;
  wire                reg_hcRhPortStatus_1_PSSC_set;
  reg                 reg_hcRhPortStatus_1_PSSC_clear;
  reg                 reg_hcRhPortStatus_1_PSSC_reg;
  reg                 when_BusSlaveFactory_l366_38;
  wire                when_BusSlaveFactory_l368_38;
  wire                reg_hcRhPortStatus_1_OCIC_set;
  reg                 reg_hcRhPortStatus_1_OCIC_clear;
  reg                 reg_hcRhPortStatus_1_OCIC_reg;
  reg                 when_BusSlaveFactory_l366_39;
  wire                when_BusSlaveFactory_l368_39;
  wire                reg_hcRhPortStatus_1_PRSC_set;
  reg                 reg_hcRhPortStatus_1_PRSC_clear;
  reg                 reg_hcRhPortStatus_1_PRSC_reg;
  reg                 when_BusSlaveFactory_l366_40;
  wire                when_BusSlaveFactory_l368_40;
  wire                when_UsbOhci_l460_3;
  wire                when_UsbOhci_l460_4;
  wire                when_UsbOhci_l460_5;
  wire                when_UsbOhci_l461_2;
  wire                when_UsbOhci_l461_3;
  wire                when_UsbOhci_l462_1;
  wire                when_UsbOhci_l463_1;
  wire                when_UsbOhci_l464_1;
  wire                when_UsbOhci_l470_1;
  reg                 reg_hcRhPortStatus_1_CCS_regNext;
  wire                io_phy_ports_1_suspend_fire;
  wire                io_phy_ports_1_reset_fire;
  wire                io_phy_ports_1_resume_fire;
  wire                io_phy_ports_1_reset_fire_1;
  wire                io_phy_ports_1_suspend_fire_1;
  reg                 frame_run;
  reg                 frame_reload;
  wire                frame_overflow;
  reg                 frame_tick;
  wire                frame_section1;
  reg        [14:0]   frame_limitCounter;
  wire                frame_limitHit;
  reg        [2:0]    frame_decrementTimer;
  wire                frame_decrementTimerOverflow;
  wire                when_UsbOhci_l526;
  wire                when_UsbOhci_l528;
  wire                when_UsbOhci_l540;
  reg                 token_wantExit;
  reg                 token_wantStart;
  reg                 token_wantKill;
  reg        [3:0]    token_pid;
  reg        [10:0]   token_data;
  reg                 dataTx_wantExit;
  reg                 dataTx_wantStart;
  reg                 dataTx_wantKill;
  reg        [3:0]    dataTx_pid;
  reg                 dataTx_data_valid;
  reg                 dataTx_data_ready;
  reg                 dataTx_data_payload_last;
  reg        [7:0]    dataTx_data_payload_fragment;
  wire                dataTx_data_fire;
  wire                rxTimer_lowSpeed;
  reg        [7:0]    rxTimer_counter;
  reg                 rxTimer_clear;
  wire                rxTimer_rxTimeout;
  wire                rxTimer_ackTx;
  wire                rxPidOk;
  wire                _zz_1;
  wire       [7:0]    _zz_dataRx_pid;
  wire                when_Misc_l87;
  reg                 dataRx_wantExit;
  reg                 dataRx_wantStart;
  reg                 dataRx_wantKill;
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
  reg                 sof_wantExit;
  reg                 sof_wantStart;
  reg                 sof_wantKill;
  reg                 sof_doInterruptDelay;
  reg                 priority_bulk;
  reg        [1:0]    priority_counter;
  reg                 priority_tick;
  reg                 priority_skip;
  wire                when_UsbOhci_l663;
  reg        [2:0]    interruptDelay_counter;
  reg                 interruptDelay_tick;
  wire                interruptDelay_done;
  wire                interruptDelay_disabled;
  reg                 interruptDelay_disable;
  reg                 interruptDelay_load_valid;
  reg        [2:0]    interruptDelay_load_payload;
  wire                when_UsbOhci_l685;
  wire                when_UsbOhci_l689;
  reg                 endpoint_wantExit;
  reg                 endpoint_wantStart;
  reg                 endpoint_wantKill;
  reg        [1:0]    endpoint_flowType;
  reg        [0:0]    endpoint_status_1;
  reg                 endpoint_dataPhase;
  reg        [31:0]   endpoint_ED_address;
  reg        [31:0]   endpoint_ED_words_0;
  reg        [31:0]   endpoint_ED_words_1;
  reg        [31:0]   endpoint_ED_words_2;
  reg        [31:0]   endpoint_ED_words_3;
  wire       [6:0]    endpoint_ED_FA;
  wire       [3:0]    endpoint_ED_EN;
  wire       [1:0]    endpoint_ED_D;
  wire                endpoint_ED_S;
  wire                endpoint_ED_K;
  wire                endpoint_ED_F;
  wire       [10:0]   endpoint_ED_MPS;
  wire       [27:0]   endpoint_ED_tailP;
  wire                endpoint_ED_H;
  wire                endpoint_ED_C;
  wire       [27:0]   endpoint_ED_headP;
  wire       [27:0]   endpoint_ED_nextED;
  wire                endpoint_ED_tdEmpty;
  wire                endpoint_ED_isFs;
  wire                endpoint_ED_isoOut;
  wire                when_UsbOhci_l750;
  wire       [31:0]   endpoint_TD_address;
  reg        [31:0]   endpoint_TD_words_0;
  reg        [31:0]   endpoint_TD_words_1;
  reg        [31:0]   endpoint_TD_words_2;
  reg        [31:0]   endpoint_TD_words_3;
  wire       [3:0]    endpoint_TD_CC;
  wire       [1:0]    endpoint_TD_EC;
  wire       [1:0]    endpoint_TD_T;
  wire       [2:0]    endpoint_TD_DI;
  wire       [1:0]    endpoint_TD_DP;
  wire                endpoint_TD_R;
  wire       [31:0]   endpoint_TD_CBP;
  wire       [27:0]   endpoint_TD_nextTD;
  wire       [31:0]   endpoint_TD_BE;
  wire       [2:0]    endpoint_TD_FC;
  wire       [15:0]   endpoint_TD_SF;
  wire       [15:0]   endpoint_TD_isoRelativeFrameNumber;
  wire                endpoint_TD_tooEarly;
  wire       [2:0]    endpoint_TD_isoFrameNumber;
  wire                endpoint_TD_isoOverrun;
  reg                 endpoint_TD_isoOverrunReg;
  wire                endpoint_TD_isoLast;
  reg        [12:0]   endpoint_TD_isoBase;
  reg        [12:0]   endpoint_TD_isoBaseNext;
  reg                 endpoint_TD_isoZero;
  reg                 endpoint_TD_isoLastReg;
  reg                 endpoint_TD_tooEarlyReg;
  wire                endpoint_TD_isSinglePage;
  wire       [12:0]   endpoint_TD_firstOffset;
  reg        [12:0]   endpoint_TD_lastOffset;
  wire                endpoint_TD_allowRounding;
  reg                 endpoint_TD_retire;
  reg                 endpoint_TD_upateCBP;
  reg                 endpoint_TD_noUpdate;
  reg                 endpoint_TD_dataPhaseUpdate;
  wire       [1:0]    endpoint_TD_TNext;
  wire                endpoint_TD_dataPhaseNext;
  wire       [3:0]    endpoint_TD_dataPid;
  wire       [3:0]    endpoint_TD_dataPidWrong;
  reg                 endpoint_TD_clear;
  wire       [1:0]    endpoint_tockenType;
  wire                endpoint_isIn;
  reg                 endpoint_applyNextED;
  reg        [13:0]   endpoint_currentAddress;
  wire       [31:0]   endpoint_currentAddressFull;
  reg        [31:0]   _zz_endpoint_currentAddressBmb;
  wire       [31:0]   endpoint_currentAddressBmb;
  reg        [12:0]   endpoint_lastAddress;
  wire       [13:0]   endpoint_transactionSizeMinusOne;
  wire       [13:0]   endpoint_transactionSize;
  reg                 endpoint_zeroLength;
  wire                endpoint_dataDone;
  reg                 endpoint_dmaLogic_wantExit;
  reg                 endpoint_dmaLogic_wantStart;
  reg                 endpoint_dmaLogic_wantKill;
  reg                 endpoint_dmaLogic_validated;
  reg        [5:0]    endpoint_dmaLogic_length;
  wire       [5:0]    endpoint_dmaLogic_lengthMax;
  wire       [5:0]    endpoint_dmaLogic_lengthCalc;
  wire       [4:0]    endpoint_dmaLogic_beatCount;
  wire       [5:0]    endpoint_dmaLogic_lengthBmb;
  reg        [10:0]   endpoint_dmaLogic_fromUsbCounter;
  reg                 endpoint_dmaLogic_overflow;
  reg                 endpoint_dmaLogic_underflow;
  wire                endpoint_dmaLogic_underflowError;
  wire                when_UsbOhci_l938;
  reg        [12:0]   endpoint_dmaLogic_byteCtx_counter;
  wire                endpoint_dmaLogic_byteCtx_last;
  wire       [1:0]    endpoint_dmaLogic_byteCtx_sel;
  reg                 endpoint_dmaLogic_byteCtx_increment;
  wire       [3:0]    endpoint_dmaLogic_headMask;
  wire       [3:0]    endpoint_dmaLogic_lastMask;
  wire       [3:0]    endpoint_dmaLogic_fullMask;
  wire                endpoint_dmaLogic_beatLast;
  reg        [31:0]   endpoint_dmaLogic_buffer;
  reg                 endpoint_dmaLogic_push;
  wire                endpoint_dmaLogic_fsmStopped;
  wire       [13:0]   endpoint_byteCountCalc;
  wire                endpoint_fsTimeCheck;
  wire                endpoint_timeCheck;
  reg                 endpoint_ackRxFired;
  reg                 endpoint_ackRxActivated;
  reg                 endpoint_ackRxPidFailure;
  reg                 endpoint_ackRxStuffing;
  reg        [3:0]    endpoint_ackRxPid;
  wire       [31:0]   endpoint_tdUpdateAddress;
  reg                 operational_wantExit;
  reg                 operational_wantStart;
  reg                 operational_wantKill;
  reg                 operational_periodicHeadFetched;
  reg                 operational_periodicDone;
  reg                 operational_allowBulk;
  reg                 operational_allowControl;
  reg                 operational_allowPeriodic;
  reg                 operational_allowIsochronous;
  reg                 operational_askExit;
  wire                hc_wantExit;
  reg                 hc_wantStart;
  wire                hc_wantKill;
  reg                 hc_error;
  wire                hc_operationalIsDone;
  wire       [1:0]    _zz_reg_hcControl_HCFSWrite_payload;
  wire                when_BusSlaveFactory_l942;
  wire                when_BusSlaveFactory_l942_1;
  wire                when_BusSlaveFactory_l942_2;
  wire                when_BusSlaveFactory_l942_3;
  wire                when_BusSlaveFactory_l942_4;
  wire                when_BusSlaveFactory_l942_5;
  wire                when_BusSlaveFactory_l942_6;
  wire                when_BusSlaveFactory_l942_7;
  wire                when_BusSlaveFactory_l942_8;
  wire                when_BusSlaveFactory_l942_9;
  wire                when_BusSlaveFactory_l942_10;
  wire                when_BusSlaveFactory_l942_11;
  wire                when_BusSlaveFactory_l942_12;
  wire                when_BusSlaveFactory_l942_13;
  wire                when_BusSlaveFactory_l942_14;
  wire                when_BusSlaveFactory_l942_15;
  wire                when_BusSlaveFactory_l942_16;
  wire                when_BusSlaveFactory_l942_17;
  wire                when_BusSlaveFactory_l942_18;
  wire                when_BusSlaveFactory_l942_19;
  wire                when_BusSlaveFactory_l942_20;
  wire                when_BusSlaveFactory_l942_21;
  wire                when_BusSlaveFactory_l942_22;
  wire                when_BusSlaveFactory_l942_23;
  wire                when_BusSlaveFactory_l942_24;
  wire                when_BusSlaveFactory_l942_25;
  wire                when_BusSlaveFactory_l942_26;
  wire                when_BusSlaveFactory_l942_27;
  wire                when_BusSlaveFactory_l942_28;
  wire                when_BusSlaveFactory_l942_29;
  wire                when_BusSlaveFactory_l942_30;
  wire                when_BusSlaveFactory_l942_31;
  wire                when_BusSlaveFactory_l942_32;
  wire                when_BusSlaveFactory_l942_33;
  wire                when_BusSlaveFactory_l942_34;
  wire                when_BusSlaveFactory_l942_35;
  wire                when_BusSlaveFactory_l942_36;
  wire                when_BusSlaveFactory_l942_37;
  wire                when_BusSlaveFactory_l942_38;
  wire                when_BusSlaveFactory_l942_39;
  wire                when_BusSlaveFactory_l942_40;
  wire                when_BusSlaveFactory_l942_41;
  wire                when_BusSlaveFactory_l942_42;
  wire                when_BusSlaveFactory_l942_43;
  wire                when_BusSlaveFactory_l942_44;
  wire                when_BusSlaveFactory_l942_45;
  wire                when_BusSlaveFactory_l942_46;
  reg                 _zz_when_UsbOhci_l253;
  wire                when_UsbOhci_l253;
  reg        [2:0]    token_stateReg;
  reg        [2:0]    token_stateNext;
  wire                when_StateMachine_l222;
  wire                unscheduleAll_fire;
  reg        [2:0]    dataTx_stateReg;
  reg        [2:0]    dataTx_stateNext;
  wire                unscheduleAll_fire_1;
  reg        [1:0]    dataRx_stateReg;
  reg        [1:0]    dataRx_stateNext;
  wire                when_Misc_l64;
  wire                when_Misc_l70;
  wire                when_Misc_l71;
  wire                when_Misc_l78;
  wire                when_StateMachine_l238;
  wire                when_Misc_l85;
  wire                unscheduleAll_fire_2;
  reg        [1:0]    sof_stateReg;
  reg        [1:0]    sof_stateNext;
  wire                when_UsbOhci_l206;
  wire                when_UsbOhci_l206_1;
  wire                when_UsbOhci_l626;
  wire                when_StateMachine_l222_1;
  wire                unscheduleAll_fire_3;
  reg        [4:0]    endpoint_stateReg;
  reg        [4:0]    endpoint_stateNext;
  wire                when_UsbOhci_l1128;
  wire                when_UsbOhci_l1311;
  wire                when_UsbOhci_l188;
  wire                when_UsbOhci_l188_1;
  wire                when_UsbOhci_l188_2;
  wire                when_UsbOhci_l188_3;
  wire                when_UsbOhci_l855;
  wire                when_UsbOhci_l861;
  wire                when_UsbOhci_l188_4;
  wire                when_UsbOhci_l188_5;
  wire                when_UsbOhci_l188_6;
  wire                when_UsbOhci_l188_7;
  wire                when_UsbOhci_l891;
  wire                when_UsbOhci_l188_8;
  wire                when_UsbOhci_l188_9;
  wire                when_UsbOhci_l891_1;
  wire                when_UsbOhci_l188_10;
  wire                when_UsbOhci_l188_11;
  wire                when_UsbOhci_l891_2;
  wire                when_UsbOhci_l188_12;
  wire                when_UsbOhci_l188_13;
  wire                when_UsbOhci_l891_3;
  wire                when_UsbOhci_l188_14;
  wire                when_UsbOhci_l188_15;
  wire                when_UsbOhci_l891_4;
  wire                when_UsbOhci_l188_16;
  wire                when_UsbOhci_l188_17;
  wire                when_UsbOhci_l891_5;
  wire                when_UsbOhci_l188_18;
  wire                when_UsbOhci_l188_19;
  wire                when_UsbOhci_l891_6;
  wire                when_UsbOhci_l188_20;
  wire                when_UsbOhci_l188_21;
  wire                when_UsbOhci_l891_7;
  wire                when_UsbOhci_l188_22;
  wire                ioDma_rsp_fire_2;
  wire                when_UsbOhci_l898;
  wire       [13:0]   _zz_endpoint_lastAddress;
  wire                when_UsbOhci_l1118;
  reg                 when_UsbOhci_l1274;
  wire                when_UsbOhci_l1263;
  wire                when_UsbOhci_l1283;
  wire                when_UsbOhci_l1200;
  wire                when_UsbOhci_l1205;
  wire                when_UsbOhci_l1207;
  wire                when_UsbOhci_l1331;
  wire                when_UsbOhci_l1346;
  wire                when_UsbOhci_l206_2;
  wire                when_UsbOhci_l206_3;
  wire       [15:0]   _zz_ioDma_cmd_payload_fragment_data;
  wire                when_UsbOhci_l1378;
  wire                when_UsbOhci_l206_4;
  wire                when_UsbOhci_l1378_1;
  wire                when_UsbOhci_l206_5;
  wire                when_UsbOhci_l1378_2;
  wire                when_UsbOhci_l206_6;
  wire                when_UsbOhci_l1378_3;
  wire                when_UsbOhci_l206_7;
  wire                when_UsbOhci_l1378_4;
  wire                when_UsbOhci_l206_8;
  wire                when_UsbOhci_l1378_5;
  wire                when_UsbOhci_l206_9;
  wire                when_UsbOhci_l1378_6;
  wire                when_UsbOhci_l206_10;
  wire                when_UsbOhci_l1378_7;
  wire                when_UsbOhci_l206_11;
  wire                when_UsbOhci_l206_12;
  wire                when_UsbOhci_l206_13;
  wire                when_UsbOhci_l206_14;
  wire                when_UsbOhci_l1393;
  wire                when_UsbOhci_l206_15;
  wire                when_UsbOhci_l1408;
  wire                when_UsbOhci_l1415;
  wire                when_UsbOhci_l1418;
  wire                when_StateMachine_l222_2;
  wire                when_StateMachine_l238_1;
  wire                when_StateMachine_l238_2;
  wire                when_StateMachine_l238_3;
  wire                when_StateMachine_l238_4;
  wire                unscheduleAll_fire_4;
  reg        [2:0]    endpoint_dmaLogic_stateReg;
  reg        [2:0]    endpoint_dmaLogic_stateNext;
  wire                when_UsbOhci_l1025;
  wire                when_UsbOhci_l1054;
  wire       [3:0]    _zz_2;
  wire                when_UsbOhci_l1063;
  wire                when_UsbOhci_l1068;
  wire                ioDma_cmd_fire_3;
  reg                 ioDma_cmd_payload_first;
  wire                when_StateMachine_l238_5;
  wire                unscheduleAll_fire_5;
  reg        [2:0]    operational_stateReg;
  reg        [2:0]    operational_stateNext;
  wire                when_UsbOhci_l1461;
  wire                when_UsbOhci_l1488;
  wire                when_UsbOhci_l1487;
  wire                when_StateMachine_l222_3;
  wire                when_StateMachine_l238_6;
  wire                unscheduleAll_fire_6;
  reg        [2:0]    hc_stateReg;
  reg        [2:0]    hc_stateNext;
  wire                when_UsbOhci_l1616;
  wire                when_UsbOhci_l1625;
  wire                when_UsbOhci_l1628;
  wire                when_UsbOhci_l1639;
  wire                when_UsbOhci_l1652;
  wire                when_StateMachine_l238_7;
  wire                when_StateMachine_l238_8;
  wire                when_StateMachine_l238_9;
  wire                when_UsbOhci_l1659;
  `ifndef SYNTHESIS
  reg [87:0] reg_hcControl_HCFS_string;
  reg [87:0] reg_hcControl_HCFSWrite_payload_string;
  reg [63:0] endpoint_flowType_string;
  reg [79:0] endpoint_status_1_string;
  reg [87:0] _zz_reg_hcControl_HCFSWrite_payload_string;
  reg [31:0] token_stateReg_string;
  reg [31:0] token_stateNext_string;
  reg [39:0] dataTx_stateReg_string;
  reg [39:0] dataTx_stateNext_string;
  reg [31:0] dataRx_stateReg_string;
  reg [31:0] dataRx_stateNext_string;
  reg [127:0] sof_stateReg_string;
  reg [127:0] sof_stateNext_string;
  reg [135:0] endpoint_stateReg_string;
  reg [135:0] endpoint_stateNext_string;
  reg [79:0] endpoint_dmaLogic_stateReg_string;
  reg [79:0] endpoint_dmaLogic_stateNext_string;
  reg [135:0] operational_stateReg_string;
  reg [135:0] operational_stateNext_string;
  reg [111:0] hc_stateReg_string;
  reg [111:0] hc_stateNext_string;
  `endif

  function [31:0] zz__zz_endpoint_currentAddressBmb(input dummy);
    begin
      zz__zz_endpoint_currentAddressBmb = 32'hffffffff;
      zz__zz_endpoint_currentAddressBmb[1 : 0] = 2'b00;
    end
  endfunction
  wire [31:0] _zz_3;

  assign _zz_dmaCtx_pendingCounter = (dmaCtx_pendingCounter + _zz_dmaCtx_pendingCounter_1);
  assign _zz_dmaCtx_pendingCounter_2 = (ioDma_cmd_fire && ioDma_cmd_payload_last);
  assign _zz_dmaCtx_pendingCounter_1 = {3'd0, _zz_dmaCtx_pendingCounter_2};
  assign _zz_dmaCtx_pendingCounter_4 = (ioDma_rsp_fire && ioDma_rsp_payload_last);
  assign _zz_dmaCtx_pendingCounter_3 = {3'd0, _zz_dmaCtx_pendingCounter_4};
  assign _zz_reg_hcCommandStatus_startSoftReset = 1'b1;
  assign _zz_reg_hcCommandStatus_CLF = 1'b1;
  assign _zz_reg_hcCommandStatus_BLF = 1'b1;
  assign _zz_reg_hcCommandStatus_OCR = 1'b1;
  assign _zz_reg_hcInterrupt_MIE = 1'b1;
  assign _zz_reg_hcInterrupt_MIE_1 = 1'b0;
  assign _zz_reg_hcInterrupt_SO_status = 1'b0;
  assign _zz_reg_hcInterrupt_SO_enable = 1'b1;
  assign _zz_reg_hcInterrupt_SO_enable_1 = 1'b0;
  assign _zz_reg_hcInterrupt_WDH_status = 1'b0;
  assign _zz_reg_hcInterrupt_WDH_enable = 1'b1;
  assign _zz_reg_hcInterrupt_WDH_enable_1 = 1'b0;
  assign _zz_reg_hcInterrupt_SF_status = 1'b0;
  assign _zz_reg_hcInterrupt_SF_enable = 1'b1;
  assign _zz_reg_hcInterrupt_SF_enable_1 = 1'b0;
  assign _zz_reg_hcInterrupt_RD_status = 1'b0;
  assign _zz_reg_hcInterrupt_RD_enable = 1'b1;
  assign _zz_reg_hcInterrupt_RD_enable_1 = 1'b0;
  assign _zz_reg_hcInterrupt_UE_status = 1'b0;
  assign _zz_reg_hcInterrupt_UE_enable = 1'b1;
  assign _zz_reg_hcInterrupt_UE_enable_1 = 1'b0;
  assign _zz_reg_hcInterrupt_FNO_status = 1'b0;
  assign _zz_reg_hcInterrupt_FNO_enable = 1'b1;
  assign _zz_reg_hcInterrupt_FNO_enable_1 = 1'b0;
  assign _zz_reg_hcInterrupt_RHSC_status = 1'b0;
  assign _zz_reg_hcInterrupt_RHSC_enable = 1'b1;
  assign _zz_reg_hcInterrupt_RHSC_enable_1 = 1'b0;
  assign _zz_reg_hcInterrupt_OC_status = 1'b0;
  assign _zz_reg_hcInterrupt_OC_enable = 1'b1;
  assign _zz_reg_hcInterrupt_OC_enable_1 = 1'b0;
  assign _zz_reg_hcLSThreshold_hit = {2'd0, reg_hcLSThreshold_LST};
  assign _zz_reg_hcRhStatus_CCIC = 1'b0;
  assign _zz_reg_hcRhStatus_clearGlobalPower = 1'b1;
  assign _zz_reg_hcRhStatus_setRemoteWakeupEnable = 1'b1;
  assign _zz_reg_hcRhStatus_setGlobalPower = 1'b1;
  assign _zz_reg_hcRhStatus_clearRemoteWakeupEnable = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_clearPortEnable = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_setPortEnable = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_setPortSuspend = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_clearSuspendStatus = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_setPortReset = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_setPortPower = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_clearPortPower = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_CSC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_PESC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_PSSC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_OCIC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_0_PRSC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_clearPortEnable = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_setPortEnable = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_setPortSuspend = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_clearSuspendStatus = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_setPortReset = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_setPortPower = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_clearPortPower = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_CSC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_PESC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_PSSC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_OCIC_clear = 1'b1;
  assign _zz_reg_hcRhPortStatus_1_PRSC_clear = 1'b1;
  assign _zz_rxTimer_ackTx_1 = (rxTimer_lowSpeed ? 4'b1111 : 4'b0001);
  assign _zz_rxTimer_ackTx = {4'd0, _zz_rxTimer_ackTx_1};
  assign _zz_endpoint_TD_isoOverrun = {13'd0, endpoint_TD_FC};
  assign _zz_endpoint_TD_firstOffset_1 = endpoint_TD_CBP[11 : 0];
  assign _zz_endpoint_TD_firstOffset = {1'd0, _zz_endpoint_TD_firstOffset_1};
  assign _zz_endpoint_TD_lastOffset = (endpoint_TD_isoBaseNext - _zz_endpoint_TD_lastOffset_1);
  assign _zz_endpoint_TD_lastOffset_2 = (! endpoint_TD_isoLast);
  assign _zz_endpoint_TD_lastOffset_1 = {12'd0, _zz_endpoint_TD_lastOffset_2};
  assign _zz_endpoint_transactionSizeMinusOne = {1'd0, endpoint_lastAddress};
  assign _zz_endpoint_dataDone = {1'd0, endpoint_lastAddress};
  assign _zz_endpoint_dmaLogic_lengthMax = endpoint_currentAddress[5:0];
  assign _zz_endpoint_dmaLogic_lengthCalc = ((endpoint_transactionSizeMinusOne < _zz_endpoint_dmaLogic_lengthCalc_1) ? endpoint_transactionSizeMinusOne : _zz_endpoint_dmaLogic_lengthCalc_2);
  assign _zz_endpoint_dmaLogic_lengthCalc_1 = {8'd0, endpoint_dmaLogic_lengthMax};
  assign _zz_endpoint_dmaLogic_lengthCalc_2 = {8'd0, endpoint_dmaLogic_lengthMax};
  assign _zz_endpoint_dmaLogic_beatCount = ({1'b0,endpoint_dmaLogic_length} + _zz_endpoint_dmaLogic_beatCount_1);
  assign _zz_endpoint_dmaLogic_beatCount_2 = endpoint_currentAddressFull[1 : 0];
  assign _zz_endpoint_dmaLogic_beatCount_1 = {5'd0, _zz_endpoint_dmaLogic_beatCount_2};
  assign _zz_endpoint_dmaLogic_lengthBmb = {endpoint_dmaLogic_beatCount,2'b11};
  assign _zz_endpoint_dmaLogic_lastMask = (endpoint_currentAddress + _zz_endpoint_dmaLogic_lastMask_1);
  assign _zz_endpoint_dmaLogic_lastMask_1 = {8'd0, endpoint_dmaLogic_length};
  assign _zz_endpoint_dmaLogic_lastMask_2 = (endpoint_currentAddress + _zz_endpoint_dmaLogic_lastMask_3);
  assign _zz_endpoint_dmaLogic_lastMask_3 = {8'd0, endpoint_dmaLogic_length};
  assign _zz_endpoint_dmaLogic_lastMask_4 = (endpoint_currentAddress + _zz_endpoint_dmaLogic_lastMask_5);
  assign _zz_endpoint_dmaLogic_lastMask_5 = {8'd0, endpoint_dmaLogic_length};
  assign _zz_endpoint_dmaLogic_lastMask_6 = (endpoint_currentAddress + _zz_endpoint_dmaLogic_lastMask_7);
  assign _zz_endpoint_dmaLogic_lastMask_7 = {8'd0, endpoint_dmaLogic_length};
  assign _zz_endpoint_dmaLogic_beatLast = {1'd0, endpoint_dmaLogic_beatCount};
  assign _zz_endpoint_byteCountCalc = (_zz_endpoint_byteCountCalc_1 - endpoint_currentAddress);
  assign _zz_endpoint_byteCountCalc_1 = {1'd0, endpoint_lastAddress};
  assign _zz_endpoint_fsTimeCheck = {2'd0, frame_limitCounter};
  assign _zz_endpoint_fsTimeCheck_1 = ({3'd0,endpoint_byteCountCalc} <<< 3);
  assign _zz_token_data = reg_hcFmNumber_FN;
  assign _zz_ioDma_cmd_payload_fragment_length = (endpoint_ED_F ? 5'h1f : 5'h0f);
  assign _zz__zz_endpoint_lastAddress = ({1'b0,endpoint_TD_firstOffset} + _zz__zz_endpoint_lastAddress_1);
  assign _zz__zz_endpoint_lastAddress_2 = {1'b0,endpoint_ED_MPS};
  assign _zz__zz_endpoint_lastAddress_1 = {2'd0, _zz__zz_endpoint_lastAddress_2};
  assign _zz_endpoint_lastAddress_1 = (endpoint_ED_F ? _zz_endpoint_lastAddress_2 : ((_zz_endpoint_lastAddress_3 < _zz_endpoint_lastAddress) ? _zz_endpoint_lastAddress_4 : _zz_endpoint_lastAddress));
  assign _zz_endpoint_lastAddress_2 = {1'd0, endpoint_TD_lastOffset};
  assign _zz_endpoint_lastAddress_3 = {1'd0, endpoint_TD_lastOffset};
  assign _zz_endpoint_lastAddress_4 = {1'd0, endpoint_TD_lastOffset};
  assign _zz_when_UsbOhci_l1331 = {1'd0, endpoint_TD_lastOffset};
  assign _zz_endpoint_TD_words_0 = (endpoint_TD_EC + 2'b01);
  assign _zz_ioDma_cmd_payload_fragment_length_1 = (endpoint_ED_F ? 5'h1f : 5'h0f);
  assign _zz_ioDma_cmd_payload_last_1 = (endpoint_ED_F ? 3'b111 : 3'b011);
  assign _zz_ioDma_cmd_payload_last = {1'd0, _zz_ioDma_cmd_payload_last_1};
  assign _zz__zz_ioDma_cmd_payload_fragment_data_1 = (endpoint_ED_isoOut ? 14'h0 : _zz__zz_ioDma_cmd_payload_fragment_data_2);
  assign _zz__zz_ioDma_cmd_payload_fragment_data = _zz__zz_ioDma_cmd_payload_fragment_data_1[11:0];
  assign _zz__zz_ioDma_cmd_payload_fragment_data_2 = (endpoint_currentAddress - _zz__zz_ioDma_cmd_payload_fragment_data_3);
  assign _zz__zz_ioDma_cmd_payload_fragment_data_3 = {1'd0, endpoint_TD_isoBase};
  assign _zz_when_UsbOhci_l1054 = {3'd0, endpoint_dmaLogic_fromUsbCounter};
  assign _zz_endpoint_dmaLogic_overflow = {3'd0, endpoint_dmaLogic_fromUsbCounter};
  assign _zz_endpoint_lastAddress_5 = (_zz_endpoint_lastAddress_6 - 14'h0001);
  assign _zz_endpoint_lastAddress_6 = (endpoint_currentAddress + _zz_endpoint_lastAddress_7);
  assign _zz_endpoint_lastAddress_7 = {3'd0, endpoint_dmaLogic_fromUsbCounter};
  assign _zz_endpoint_dmaLogic_fromUsbCounter_1 = (! endpoint_dmaLogic_fromUsbCounter[10]);
  assign _zz_endpoint_dmaLogic_fromUsbCounter = {10'd0, _zz_endpoint_dmaLogic_fromUsbCounter_1};
  assign _zz_endpoint_currentAddress = (endpoint_currentAddress + _zz_endpoint_currentAddress_1);
  assign _zz_endpoint_currentAddress_1 = {8'd0, endpoint_dmaLogic_length};
  assign _zz_endpoint_currentAddress_2 = (endpoint_currentAddress + _zz_endpoint_currentAddress_3);
  assign _zz_endpoint_currentAddress_3 = {8'd0, endpoint_dmaLogic_length};
  assign _zz_ioDma_cmd_payload_fragment_address_1 = ({2'd0,reg_hcFmNumber_FN[4 : 0]} <<< 2);
  assign _zz_ioDma_cmd_payload_fragment_address = {25'd0, _zz_ioDma_cmd_payload_fragment_address_1};
  UsbOhciWishbone_StreamFifo fifo (
    .io_push_valid      (fifo_io_push_valid          ), //i
    .io_push_ready      (fifo_io_push_ready          ), //o
    .io_push_payload    (fifo_io_push_payload[31:0]  ), //i
    .io_pop_valid       (fifo_io_pop_valid           ), //o
    .io_pop_ready       (fifo_io_pop_ready           ), //i
    .io_pop_payload     (fifo_io_pop_payload[31:0]   ), //o
    .io_flush           (fifo_io_flush               ), //i
    .io_occupancy       (fifo_io_occupancy[9:0]      ), //o
    .io_availability    (fifo_io_availability[9:0]   ), //o
    .ctrl_clk           (ctrl_clk                    ), //i
    .ctrl_reset         (ctrl_reset                  )  //i
  );
  UsbOhciWishbone_Crc token_crc5 (
    .io_flush            (token_crc5_io_flush            ), //i
    .io_input_valid      (token_crc5_io_input_valid      ), //i
    .io_input_payload    (token_data[10:0]               ), //i
    .io_result           (token_crc5_io_result[4:0]      ), //o
    .io_resultNext       (token_crc5_io_resultNext[4:0]  ), //o
    .ctrl_clk            (ctrl_clk                       ), //i
    .ctrl_reset          (ctrl_reset                     )  //i
  );
  UsbOhciWishbone_Crc_1 dataTx_crc16 (
    .io_flush            (dataTx_crc16_io_flush              ), //i
    .io_input_valid      (dataTx_data_fire                   ), //i
    .io_input_payload    (dataTx_data_payload_fragment[7:0]  ), //i
    .io_result           (dataTx_crc16_io_result[15:0]       ), //o
    .io_resultNext       (dataTx_crc16_io_resultNext[15:0]   ), //o
    .ctrl_clk            (ctrl_clk                           ), //i
    .ctrl_reset          (ctrl_reset                         )  //i
  );
  UsbOhciWishbone_Crc_2 dataRx_crc16 (
    .io_flush            (dataRx_crc16_io_flush             ), //i
    .io_input_valid      (dataRx_crc16_io_input_valid       ), //i
    .io_input_payload    (_zz_dataRx_pid[7:0]               ), //i
    .io_result           (dataRx_crc16_io_result[15:0]      ), //o
    .io_resultNext       (dataRx_crc16_io_resultNext[15:0]  ), //o
    .ctrl_clk            (ctrl_clk                          ), //i
    .ctrl_reset          (ctrl_reset                        )  //i
  );
  always @(*) begin
    case(endpoint_dmaLogic_byteCtx_sel)
      2'b00 : _zz_dataTx_data_payload_fragment = fifo_io_pop_payload[7 : 0];
      2'b01 : _zz_dataTx_data_payload_fragment = fifo_io_pop_payload[15 : 8];
      2'b10 : _zz_dataTx_data_payload_fragment = fifo_io_pop_payload[23 : 16];
      default : _zz_dataTx_data_payload_fragment = fifo_io_pop_payload[31 : 24];
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(reg_hcControl_HCFS)
      UsbOhciWishbone_MainState_RESET : reg_hcControl_HCFS_string = "RESET      ";
      UsbOhciWishbone_MainState_RESUME : reg_hcControl_HCFS_string = "RESUME     ";
      UsbOhciWishbone_MainState_OPERATIONAL : reg_hcControl_HCFS_string = "OPERATIONAL";
      UsbOhciWishbone_MainState_SUSPEND : reg_hcControl_HCFS_string = "SUSPEND    ";
      default : reg_hcControl_HCFS_string = "???????????";
    endcase
  end
  always @(*) begin
    case(reg_hcControl_HCFSWrite_payload)
      UsbOhciWishbone_MainState_RESET : reg_hcControl_HCFSWrite_payload_string = "RESET      ";
      UsbOhciWishbone_MainState_RESUME : reg_hcControl_HCFSWrite_payload_string = "RESUME     ";
      UsbOhciWishbone_MainState_OPERATIONAL : reg_hcControl_HCFSWrite_payload_string = "OPERATIONAL";
      UsbOhciWishbone_MainState_SUSPEND : reg_hcControl_HCFSWrite_payload_string = "SUSPEND    ";
      default : reg_hcControl_HCFSWrite_payload_string = "???????????";
    endcase
  end
  always @(*) begin
    case(endpoint_flowType)
      UsbOhciWishbone_FlowType_BULK : endpoint_flowType_string = "BULK    ";
      UsbOhciWishbone_FlowType_CONTROL : endpoint_flowType_string = "CONTROL ";
      UsbOhciWishbone_FlowType_PERIODIC : endpoint_flowType_string = "PERIODIC";
      default : endpoint_flowType_string = "????????";
    endcase
  end
  always @(*) begin
    case(endpoint_status_1)
      UsbOhciWishbone_endpoint_Status_OK : endpoint_status_1_string = "OK        ";
      UsbOhciWishbone_endpoint_Status_FRAME_TIME : endpoint_status_1_string = "FRAME_TIME";
      default : endpoint_status_1_string = "??????????";
    endcase
  end
  always @(*) begin
    case(_zz_reg_hcControl_HCFSWrite_payload)
      UsbOhciWishbone_MainState_RESET : _zz_reg_hcControl_HCFSWrite_payload_string = "RESET      ";
      UsbOhciWishbone_MainState_RESUME : _zz_reg_hcControl_HCFSWrite_payload_string = "RESUME     ";
      UsbOhciWishbone_MainState_OPERATIONAL : _zz_reg_hcControl_HCFSWrite_payload_string = "OPERATIONAL";
      UsbOhciWishbone_MainState_SUSPEND : _zz_reg_hcControl_HCFSWrite_payload_string = "SUSPEND    ";
      default : _zz_reg_hcControl_HCFSWrite_payload_string = "???????????";
    endcase
  end
  always @(*) begin
    case(token_stateReg)
      UsbOhciWishbone_token_enumDef_BOOT : token_stateReg_string = "BOOT";
      UsbOhciWishbone_token_enumDef_INIT : token_stateReg_string = "INIT";
      UsbOhciWishbone_token_enumDef_PID : token_stateReg_string = "PID ";
      UsbOhciWishbone_token_enumDef_B1 : token_stateReg_string = "B1  ";
      UsbOhciWishbone_token_enumDef_B2 : token_stateReg_string = "B2  ";
      UsbOhciWishbone_token_enumDef_EOP : token_stateReg_string = "EOP ";
      default : token_stateReg_string = "????";
    endcase
  end
  always @(*) begin
    case(token_stateNext)
      UsbOhciWishbone_token_enumDef_BOOT : token_stateNext_string = "BOOT";
      UsbOhciWishbone_token_enumDef_INIT : token_stateNext_string = "INIT";
      UsbOhciWishbone_token_enumDef_PID : token_stateNext_string = "PID ";
      UsbOhciWishbone_token_enumDef_B1 : token_stateNext_string = "B1  ";
      UsbOhciWishbone_token_enumDef_B2 : token_stateNext_string = "B2  ";
      UsbOhciWishbone_token_enumDef_EOP : token_stateNext_string = "EOP ";
      default : token_stateNext_string = "????";
    endcase
  end
  always @(*) begin
    case(dataTx_stateReg)
      UsbOhciWishbone_dataTx_enumDef_BOOT : dataTx_stateReg_string = "BOOT ";
      UsbOhciWishbone_dataTx_enumDef_PID : dataTx_stateReg_string = "PID  ";
      UsbOhciWishbone_dataTx_enumDef_DATA : dataTx_stateReg_string = "DATA ";
      UsbOhciWishbone_dataTx_enumDef_CRC_0 : dataTx_stateReg_string = "CRC_0";
      UsbOhciWishbone_dataTx_enumDef_CRC_1 : dataTx_stateReg_string = "CRC_1";
      UsbOhciWishbone_dataTx_enumDef_EOP : dataTx_stateReg_string = "EOP  ";
      default : dataTx_stateReg_string = "?????";
    endcase
  end
  always @(*) begin
    case(dataTx_stateNext)
      UsbOhciWishbone_dataTx_enumDef_BOOT : dataTx_stateNext_string = "BOOT ";
      UsbOhciWishbone_dataTx_enumDef_PID : dataTx_stateNext_string = "PID  ";
      UsbOhciWishbone_dataTx_enumDef_DATA : dataTx_stateNext_string = "DATA ";
      UsbOhciWishbone_dataTx_enumDef_CRC_0 : dataTx_stateNext_string = "CRC_0";
      UsbOhciWishbone_dataTx_enumDef_CRC_1 : dataTx_stateNext_string = "CRC_1";
      UsbOhciWishbone_dataTx_enumDef_EOP : dataTx_stateNext_string = "EOP  ";
      default : dataTx_stateNext_string = "?????";
    endcase
  end
  always @(*) begin
    case(dataRx_stateReg)
      UsbOhciWishbone_dataRx_enumDef_BOOT : dataRx_stateReg_string = "BOOT";
      UsbOhciWishbone_dataRx_enumDef_IDLE : dataRx_stateReg_string = "IDLE";
      UsbOhciWishbone_dataRx_enumDef_PID : dataRx_stateReg_string = "PID ";
      UsbOhciWishbone_dataRx_enumDef_DATA : dataRx_stateReg_string = "DATA";
      default : dataRx_stateReg_string = "????";
    endcase
  end
  always @(*) begin
    case(dataRx_stateNext)
      UsbOhciWishbone_dataRx_enumDef_BOOT : dataRx_stateNext_string = "BOOT";
      UsbOhciWishbone_dataRx_enumDef_IDLE : dataRx_stateNext_string = "IDLE";
      UsbOhciWishbone_dataRx_enumDef_PID : dataRx_stateNext_string = "PID ";
      UsbOhciWishbone_dataRx_enumDef_DATA : dataRx_stateNext_string = "DATA";
      default : dataRx_stateNext_string = "????";
    endcase
  end
  always @(*) begin
    case(sof_stateReg)
      UsbOhciWishbone_sof_enumDef_BOOT : sof_stateReg_string = "BOOT            ";
      UsbOhciWishbone_sof_enumDef_FRAME_TX : sof_stateReg_string = "FRAME_TX        ";
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD : sof_stateReg_string = "FRAME_NUMBER_CMD";
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP : sof_stateReg_string = "FRAME_NUMBER_RSP";
      default : sof_stateReg_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(sof_stateNext)
      UsbOhciWishbone_sof_enumDef_BOOT : sof_stateNext_string = "BOOT            ";
      UsbOhciWishbone_sof_enumDef_FRAME_TX : sof_stateNext_string = "FRAME_TX        ";
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD : sof_stateNext_string = "FRAME_NUMBER_CMD";
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP : sof_stateNext_string = "FRAME_NUMBER_RSP";
      default : sof_stateNext_string = "????????????????";
    endcase
  end
  always @(*) begin
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_BOOT : endpoint_stateReg_string = "BOOT             ";
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : endpoint_stateReg_string = "ED_READ_CMD      ";
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : endpoint_stateReg_string = "ED_READ_RSP      ";
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : endpoint_stateReg_string = "ED_ANALYSE       ";
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : endpoint_stateReg_string = "TD_READ_CMD      ";
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : endpoint_stateReg_string = "TD_READ_RSP      ";
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : endpoint_stateReg_string = "TD_READ_DELAY    ";
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : endpoint_stateReg_string = "TD_ANALYSE       ";
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : endpoint_stateReg_string = "TD_CHECK_TIME    ";
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : endpoint_stateReg_string = "BUFFER_READ      ";
      UsbOhciWishbone_endpoint_enumDef_TOKEN : endpoint_stateReg_string = "TOKEN            ";
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : endpoint_stateReg_string = "DATA_TX          ";
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : endpoint_stateReg_string = "DATA_RX          ";
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : endpoint_stateReg_string = "DATA_RX_VALIDATE ";
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : endpoint_stateReg_string = "ACK_RX           ";
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : endpoint_stateReg_string = "ACK_TX_0         ";
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : endpoint_stateReg_string = "ACK_TX_1         ";
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : endpoint_stateReg_string = "ACK_TX_EOP       ";
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : endpoint_stateReg_string = "DATA_RX_WAIT_DMA ";
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : endpoint_stateReg_string = "UPDATE_TD_PROCESS";
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : endpoint_stateReg_string = "UPDATE_TD_CMD    ";
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : endpoint_stateReg_string = "UPDATE_ED_CMD    ";
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : endpoint_stateReg_string = "UPDATE_SYNC      ";
      UsbOhciWishbone_endpoint_enumDef_ABORD : endpoint_stateReg_string = "ABORD            ";
      default : endpoint_stateReg_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(endpoint_stateNext)
      UsbOhciWishbone_endpoint_enumDef_BOOT : endpoint_stateNext_string = "BOOT             ";
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : endpoint_stateNext_string = "ED_READ_CMD      ";
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : endpoint_stateNext_string = "ED_READ_RSP      ";
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : endpoint_stateNext_string = "ED_ANALYSE       ";
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : endpoint_stateNext_string = "TD_READ_CMD      ";
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : endpoint_stateNext_string = "TD_READ_RSP      ";
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : endpoint_stateNext_string = "TD_READ_DELAY    ";
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : endpoint_stateNext_string = "TD_ANALYSE       ";
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : endpoint_stateNext_string = "TD_CHECK_TIME    ";
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : endpoint_stateNext_string = "BUFFER_READ      ";
      UsbOhciWishbone_endpoint_enumDef_TOKEN : endpoint_stateNext_string = "TOKEN            ";
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : endpoint_stateNext_string = "DATA_TX          ";
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : endpoint_stateNext_string = "DATA_RX          ";
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : endpoint_stateNext_string = "DATA_RX_VALIDATE ";
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : endpoint_stateNext_string = "ACK_RX           ";
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : endpoint_stateNext_string = "ACK_TX_0         ";
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : endpoint_stateNext_string = "ACK_TX_1         ";
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : endpoint_stateNext_string = "ACK_TX_EOP       ";
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : endpoint_stateNext_string = "DATA_RX_WAIT_DMA ";
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : endpoint_stateNext_string = "UPDATE_TD_PROCESS";
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : endpoint_stateNext_string = "UPDATE_TD_CMD    ";
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : endpoint_stateNext_string = "UPDATE_ED_CMD    ";
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : endpoint_stateNext_string = "UPDATE_SYNC      ";
      UsbOhciWishbone_endpoint_enumDef_ABORD : endpoint_stateNext_string = "ABORD            ";
      default : endpoint_stateNext_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(endpoint_dmaLogic_stateReg)
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_BOOT : endpoint_dmaLogic_stateReg_string = "BOOT      ";
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : endpoint_dmaLogic_stateReg_string = "INIT      ";
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : endpoint_dmaLogic_stateReg_string = "TO_USB    ";
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : endpoint_dmaLogic_stateReg_string = "FROM_USB  ";
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : endpoint_dmaLogic_stateReg_string = "VALIDATION";
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : endpoint_dmaLogic_stateReg_string = "CALC_CMD  ";
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : endpoint_dmaLogic_stateReg_string = "READ_CMD  ";
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : endpoint_dmaLogic_stateReg_string = "WRITE_CMD ";
      default : endpoint_dmaLogic_stateReg_string = "??????????";
    endcase
  end
  always @(*) begin
    case(endpoint_dmaLogic_stateNext)
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_BOOT : endpoint_dmaLogic_stateNext_string = "BOOT      ";
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : endpoint_dmaLogic_stateNext_string = "INIT      ";
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : endpoint_dmaLogic_stateNext_string = "TO_USB    ";
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : endpoint_dmaLogic_stateNext_string = "FROM_USB  ";
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : endpoint_dmaLogic_stateNext_string = "VALIDATION";
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : endpoint_dmaLogic_stateNext_string = "CALC_CMD  ";
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : endpoint_dmaLogic_stateNext_string = "READ_CMD  ";
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : endpoint_dmaLogic_stateNext_string = "WRITE_CMD ";
      default : endpoint_dmaLogic_stateNext_string = "??????????";
    endcase
  end
  always @(*) begin
    case(operational_stateReg)
      UsbOhciWishbone_operational_enumDef_BOOT : operational_stateReg_string = "BOOT             ";
      UsbOhciWishbone_operational_enumDef_SOF : operational_stateReg_string = "SOF              ";
      UsbOhciWishbone_operational_enumDef_ARBITER : operational_stateReg_string = "ARBITER          ";
      UsbOhciWishbone_operational_enumDef_END_POINT : operational_stateReg_string = "END_POINT        ";
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_CMD : operational_stateReg_string = "PERIODIC_HEAD_CMD";
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_RSP : operational_stateReg_string = "PERIODIC_HEAD_RSP";
      UsbOhciWishbone_operational_enumDef_WAIT_SOF : operational_stateReg_string = "WAIT_SOF         ";
      default : operational_stateReg_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(operational_stateNext)
      UsbOhciWishbone_operational_enumDef_BOOT : operational_stateNext_string = "BOOT             ";
      UsbOhciWishbone_operational_enumDef_SOF : operational_stateNext_string = "SOF              ";
      UsbOhciWishbone_operational_enumDef_ARBITER : operational_stateNext_string = "ARBITER          ";
      UsbOhciWishbone_operational_enumDef_END_POINT : operational_stateNext_string = "END_POINT        ";
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_CMD : operational_stateNext_string = "PERIODIC_HEAD_CMD";
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_RSP : operational_stateNext_string = "PERIODIC_HEAD_RSP";
      UsbOhciWishbone_operational_enumDef_WAIT_SOF : operational_stateNext_string = "WAIT_SOF         ";
      default : operational_stateNext_string = "?????????????????";
    endcase
  end
  always @(*) begin
    case(hc_stateReg)
      UsbOhciWishbone_hc_enumDef_BOOT : hc_stateReg_string = "BOOT          ";
      UsbOhciWishbone_hc_enumDef_RESET : hc_stateReg_string = "RESET         ";
      UsbOhciWishbone_hc_enumDef_RESUME : hc_stateReg_string = "RESUME        ";
      UsbOhciWishbone_hc_enumDef_OPERATIONAL : hc_stateReg_string = "OPERATIONAL   ";
      UsbOhciWishbone_hc_enumDef_SUSPEND : hc_stateReg_string = "SUSPEND       ";
      UsbOhciWishbone_hc_enumDef_ANY_TO_RESET : hc_stateReg_string = "ANY_TO_RESET  ";
      UsbOhciWishbone_hc_enumDef_ANY_TO_SUSPEND : hc_stateReg_string = "ANY_TO_SUSPEND";
      default : hc_stateReg_string = "??????????????";
    endcase
  end
  always @(*) begin
    case(hc_stateNext)
      UsbOhciWishbone_hc_enumDef_BOOT : hc_stateNext_string = "BOOT          ";
      UsbOhciWishbone_hc_enumDef_RESET : hc_stateNext_string = "RESET         ";
      UsbOhciWishbone_hc_enumDef_RESUME : hc_stateNext_string = "RESUME        ";
      UsbOhciWishbone_hc_enumDef_OPERATIONAL : hc_stateNext_string = "OPERATIONAL   ";
      UsbOhciWishbone_hc_enumDef_SUSPEND : hc_stateNext_string = "SUSPEND       ";
      UsbOhciWishbone_hc_enumDef_ANY_TO_RESET : hc_stateNext_string = "ANY_TO_RESET  ";
      UsbOhciWishbone_hc_enumDef_ANY_TO_SUSPEND : hc_stateNext_string = "ANY_TO_SUSPEND";
      default : hc_stateNext_string = "??????????????";
    endcase
  end
  `endif

  always @(*) begin
    io_phy_lowSpeed = 1'b0;
    if(when_UsbOhci_l750) begin
      io_phy_lowSpeed = endpoint_ED_S;
    end
  end

  always @(*) begin
    unscheduleAll_valid = 1'b0;
    if(doUnschedule) begin
      unscheduleAll_valid = 1'b1;
    end
  end

  always @(*) begin
    unscheduleAll_ready = 1'b1;
    if(when_UsbOhci_l157) begin
      unscheduleAll_ready = 1'b0;
    end
  end

  assign ioDma_cmd_fire = (ioDma_cmd_valid && ioDma_cmd_ready);
  assign ioDma_rsp_fire = (ioDma_rsp_valid && ioDma_rsp_ready);
  assign dmaCtx_pendingFull = dmaCtx_pendingCounter[3];
  assign dmaCtx_pendingEmpty = (dmaCtx_pendingCounter == 4'b0000);
  assign ioDma_cmd_fire_1 = (ioDma_cmd_valid && ioDma_cmd_ready);
  assign when_UsbOhci_l157 = (! dmaCtx_pendingEmpty);
  assign io_dma_cmd_fire = (io_dma_cmd_valid && io_dma_cmd_ready);
  assign _zz_io_dma_cmd_valid = (! (dmaCtx_pendingFull || (unscheduleAll_valid && io_dma_cmd_payload_first)));
  assign ioDma_cmd_ready = (io_dma_cmd_ready && _zz_io_dma_cmd_valid);
  assign io_dma_cmd_valid = (ioDma_cmd_valid && _zz_io_dma_cmd_valid);
  assign io_dma_cmd_payload_last = ioDma_cmd_payload_last;
  assign io_dma_cmd_payload_fragment_opcode = ioDma_cmd_payload_fragment_opcode;
  assign io_dma_cmd_payload_fragment_address = ioDma_cmd_payload_fragment_address;
  assign io_dma_cmd_payload_fragment_length = ioDma_cmd_payload_fragment_length;
  assign io_dma_cmd_payload_fragment_data = ioDma_cmd_payload_fragment_data;
  assign io_dma_cmd_payload_fragment_mask = ioDma_cmd_payload_fragment_mask;
  assign ioDma_rsp_valid = io_dma_rsp_valid;
  assign io_dma_rsp_ready = ioDma_rsp_ready;
  assign ioDma_rsp_payload_last = io_dma_rsp_payload_last;
  assign ioDma_rsp_payload_fragment_opcode = io_dma_rsp_payload_fragment_opcode;
  assign ioDma_rsp_payload_fragment_data = io_dma_rsp_payload_fragment_data;
  always @(*) begin
    ioDma_cmd_valid = 1'b0;
    case(sof_stateReg)
      UsbOhciWishbone_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD : begin
        ioDma_cmd_valid = 1'b1;
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
        ioDma_cmd_valid = 1'b1;
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
        ioDma_cmd_valid = 1'b1;
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
        ioDma_cmd_valid = 1'b1;
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
        ioDma_cmd_valid = 1'b1;
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    case(endpoint_dmaLogic_stateReg)
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : begin
        ioDma_cmd_valid = 1'b1;
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        ioDma_cmd_valid = 1'b1;
      end
      default : begin
      end
    endcase
    case(operational_stateReg)
      UsbOhciWishbone_operational_enumDef_SOF : begin
      end
      UsbOhciWishbone_operational_enumDef_ARBITER : begin
      end
      UsbOhciWishbone_operational_enumDef_END_POINT : begin
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_CMD : begin
        ioDma_cmd_valid = 1'b1;
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_RSP : begin
      end
      UsbOhciWishbone_operational_enumDef_WAIT_SOF : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ioDma_cmd_payload_last = 1'bx;
    case(sof_stateReg)
      UsbOhciWishbone_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD : begin
        ioDma_cmd_payload_last = (dmaWriteCtx_counter == 4'b0001);
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
        ioDma_cmd_payload_last = 1'b1;
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
        ioDma_cmd_payload_last = 1'b1;
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
        ioDma_cmd_payload_last = (dmaWriteCtx_counter == _zz_ioDma_cmd_payload_last);
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
        ioDma_cmd_payload_last = (dmaWriteCtx_counter == 4'b0011);
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    case(endpoint_dmaLogic_stateReg)
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : begin
        ioDma_cmd_payload_last = 1'b1;
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        ioDma_cmd_payload_last = endpoint_dmaLogic_beatLast;
      end
      default : begin
      end
    endcase
    case(operational_stateReg)
      UsbOhciWishbone_operational_enumDef_SOF : begin
      end
      UsbOhciWishbone_operational_enumDef_ARBITER : begin
      end
      UsbOhciWishbone_operational_enumDef_END_POINT : begin
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_CMD : begin
        ioDma_cmd_payload_last = 1'b1;
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_RSP : begin
      end
      UsbOhciWishbone_operational_enumDef_WAIT_SOF : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ioDma_cmd_payload_fragment_opcode = 1'bx;
    case(sof_stateReg)
      UsbOhciWishbone_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD : begin
        ioDma_cmd_payload_fragment_opcode = 1'b1;
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
        ioDma_cmd_payload_fragment_opcode = 1'b0;
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
        ioDma_cmd_payload_fragment_opcode = 1'b0;
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
        ioDma_cmd_payload_fragment_opcode = 1'b1;
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
        ioDma_cmd_payload_fragment_opcode = 1'b1;
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    case(endpoint_dmaLogic_stateReg)
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : begin
        ioDma_cmd_payload_fragment_opcode = 1'b0;
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        ioDma_cmd_payload_fragment_opcode = 1'b1;
      end
      default : begin
      end
    endcase
    case(operational_stateReg)
      UsbOhciWishbone_operational_enumDef_SOF : begin
      end
      UsbOhciWishbone_operational_enumDef_ARBITER : begin
      end
      UsbOhciWishbone_operational_enumDef_END_POINT : begin
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_CMD : begin
        ioDma_cmd_payload_fragment_opcode = 1'b0;
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_RSP : begin
      end
      UsbOhciWishbone_operational_enumDef_WAIT_SOF : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ioDma_cmd_payload_fragment_address = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    case(sof_stateReg)
      UsbOhciWishbone_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD : begin
        ioDma_cmd_payload_fragment_address = (reg_hcHCCA_HCCA_address | 32'h00000080);
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
        ioDma_cmd_payload_fragment_address = endpoint_ED_address;
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
        ioDma_cmd_payload_fragment_address = endpoint_TD_address;
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
        ioDma_cmd_payload_fragment_address = endpoint_TD_address;
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
        ioDma_cmd_payload_fragment_address = endpoint_ED_address;
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    case(endpoint_dmaLogic_stateReg)
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : begin
        ioDma_cmd_payload_fragment_address = endpoint_currentAddressBmb;
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        ioDma_cmd_payload_fragment_address = endpoint_currentAddressBmb;
      end
      default : begin
      end
    endcase
    case(operational_stateReg)
      UsbOhciWishbone_operational_enumDef_SOF : begin
      end
      UsbOhciWishbone_operational_enumDef_ARBITER : begin
      end
      UsbOhciWishbone_operational_enumDef_END_POINT : begin
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_CMD : begin
        ioDma_cmd_payload_fragment_address = (reg_hcHCCA_HCCA_address | _zz_ioDma_cmd_payload_fragment_address);
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_RSP : begin
      end
      UsbOhciWishbone_operational_enumDef_WAIT_SOF : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ioDma_cmd_payload_fragment_length = 6'bxxxxxx;
    case(sof_stateReg)
      UsbOhciWishbone_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD : begin
        ioDma_cmd_payload_fragment_length = 6'h07;
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
        ioDma_cmd_payload_fragment_length = 6'h0f;
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
        ioDma_cmd_payload_fragment_length = {1'd0, _zz_ioDma_cmd_payload_fragment_length};
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
        ioDma_cmd_payload_fragment_length = {1'd0, _zz_ioDma_cmd_payload_fragment_length_1};
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
        ioDma_cmd_payload_fragment_length = 6'h0f;
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    case(endpoint_dmaLogic_stateReg)
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : begin
        ioDma_cmd_payload_fragment_length = endpoint_dmaLogic_lengthBmb;
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        ioDma_cmd_payload_fragment_length = endpoint_dmaLogic_lengthBmb;
      end
      default : begin
      end
    endcase
    case(operational_stateReg)
      UsbOhciWishbone_operational_enumDef_SOF : begin
      end
      UsbOhciWishbone_operational_enumDef_ARBITER : begin
      end
      UsbOhciWishbone_operational_enumDef_END_POINT : begin
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_CMD : begin
        ioDma_cmd_payload_fragment_length = 6'h03;
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_RSP : begin
      end
      UsbOhciWishbone_operational_enumDef_WAIT_SOF : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ioDma_cmd_payload_fragment_data = 32'h0;
    case(sof_stateReg)
      UsbOhciWishbone_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD : begin
        if(when_UsbOhci_l206) begin
          ioDma_cmd_payload_fragment_data[31 : 0] = {16'h0,reg_hcFmNumber_FN};
        end
        if(sof_doInterruptDelay) begin
          if(when_UsbOhci_l206_1) begin
            ioDma_cmd_payload_fragment_data[31 : 0] = {reg_hcDoneHead_DH_address[31 : 1],reg_hcInterrupt_unmaskedPending};
          end
        end
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
        if(endpoint_ED_F) begin
          if(endpoint_TD_isoOverrunReg) begin
            if(when_UsbOhci_l206_2) begin
              ioDma_cmd_payload_fragment_data[31 : 24] = {{4'b1000,endpoint_TD_words_0[27]},endpoint_TD_FC};
            end
          end else begin
            if(endpoint_TD_isoLastReg) begin
              if(when_UsbOhci_l206_3) begin
                ioDma_cmd_payload_fragment_data[31 : 24] = {{4'b0000,endpoint_TD_words_0[27]},endpoint_TD_FC};
              end
            end
            if(when_UsbOhci_l1378) begin
              if(when_UsbOhci_l206_4) begin
                ioDma_cmd_payload_fragment_data[15 : 0] = _zz_ioDma_cmd_payload_fragment_data;
              end
            end
            if(when_UsbOhci_l1378_1) begin
              if(when_UsbOhci_l206_5) begin
                ioDma_cmd_payload_fragment_data[31 : 16] = _zz_ioDma_cmd_payload_fragment_data;
              end
            end
            if(when_UsbOhci_l1378_2) begin
              if(when_UsbOhci_l206_6) begin
                ioDma_cmd_payload_fragment_data[15 : 0] = _zz_ioDma_cmd_payload_fragment_data;
              end
            end
            if(when_UsbOhci_l1378_3) begin
              if(when_UsbOhci_l206_7) begin
                ioDma_cmd_payload_fragment_data[31 : 16] = _zz_ioDma_cmd_payload_fragment_data;
              end
            end
            if(when_UsbOhci_l1378_4) begin
              if(when_UsbOhci_l206_8) begin
                ioDma_cmd_payload_fragment_data[15 : 0] = _zz_ioDma_cmd_payload_fragment_data;
              end
            end
            if(when_UsbOhci_l1378_5) begin
              if(when_UsbOhci_l206_9) begin
                ioDma_cmd_payload_fragment_data[31 : 16] = _zz_ioDma_cmd_payload_fragment_data;
              end
            end
            if(when_UsbOhci_l1378_6) begin
              if(when_UsbOhci_l206_10) begin
                ioDma_cmd_payload_fragment_data[15 : 0] = _zz_ioDma_cmd_payload_fragment_data;
              end
            end
            if(when_UsbOhci_l1378_7) begin
              if(when_UsbOhci_l206_11) begin
                ioDma_cmd_payload_fragment_data[31 : 16] = _zz_ioDma_cmd_payload_fragment_data;
              end
            end
          end
        end else begin
          if(when_UsbOhci_l206_12) begin
            ioDma_cmd_payload_fragment_data[31 : 24] = {{endpoint_TD_CC,endpoint_TD_EC},endpoint_TD_TNext};
          end
          if(endpoint_TD_upateCBP) begin
            if(when_UsbOhci_l206_13) begin
              ioDma_cmd_payload_fragment_data[31 : 0] = endpoint_tdUpdateAddress;
            end
          end
        end
        if(endpoint_TD_retire) begin
          if(when_UsbOhci_l206_14) begin
            ioDma_cmd_payload_fragment_data[31 : 0] = reg_hcDoneHead_DH_address;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
        if(endpoint_TD_retire) begin
          if(when_UsbOhci_l206_15) begin
            ioDma_cmd_payload_fragment_data[31 : 0] = {{{endpoint_TD_nextTD,2'b00},endpoint_TD_dataPhaseNext},endpoint_ED_H};
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    case(endpoint_dmaLogic_stateReg)
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        ioDma_cmd_payload_fragment_data = fifo_io_pop_payload;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ioDma_cmd_payload_fragment_mask = 4'b0000;
    case(sof_stateReg)
      UsbOhciWishbone_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD : begin
        if(when_UsbOhci_l206) begin
          ioDma_cmd_payload_fragment_mask[3 : 0] = 4'b1111;
        end
        if(sof_doInterruptDelay) begin
          if(when_UsbOhci_l206_1) begin
            ioDma_cmd_payload_fragment_mask[3 : 0] = 4'b1111;
          end
        end
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
        if(endpoint_ED_F) begin
          if(endpoint_TD_isoOverrunReg) begin
            if(when_UsbOhci_l206_2) begin
              ioDma_cmd_payload_fragment_mask[3 : 3] = 1'b1;
            end
          end else begin
            if(endpoint_TD_isoLastReg) begin
              if(when_UsbOhci_l206_3) begin
                ioDma_cmd_payload_fragment_mask[3 : 3] = 1'b1;
              end
            end
            if(when_UsbOhci_l1378) begin
              if(when_UsbOhci_l206_4) begin
                ioDma_cmd_payload_fragment_mask[1 : 0] = 2'b11;
              end
            end
            if(when_UsbOhci_l1378_1) begin
              if(when_UsbOhci_l206_5) begin
                ioDma_cmd_payload_fragment_mask[3 : 2] = 2'b11;
              end
            end
            if(when_UsbOhci_l1378_2) begin
              if(when_UsbOhci_l206_6) begin
                ioDma_cmd_payload_fragment_mask[1 : 0] = 2'b11;
              end
            end
            if(when_UsbOhci_l1378_3) begin
              if(when_UsbOhci_l206_7) begin
                ioDma_cmd_payload_fragment_mask[3 : 2] = 2'b11;
              end
            end
            if(when_UsbOhci_l1378_4) begin
              if(when_UsbOhci_l206_8) begin
                ioDma_cmd_payload_fragment_mask[1 : 0] = 2'b11;
              end
            end
            if(when_UsbOhci_l1378_5) begin
              if(when_UsbOhci_l206_9) begin
                ioDma_cmd_payload_fragment_mask[3 : 2] = 2'b11;
              end
            end
            if(when_UsbOhci_l1378_6) begin
              if(when_UsbOhci_l206_10) begin
                ioDma_cmd_payload_fragment_mask[1 : 0] = 2'b11;
              end
            end
            if(when_UsbOhci_l1378_7) begin
              if(when_UsbOhci_l206_11) begin
                ioDma_cmd_payload_fragment_mask[3 : 2] = 2'b11;
              end
            end
          end
        end else begin
          if(when_UsbOhci_l206_12) begin
            ioDma_cmd_payload_fragment_mask[3 : 3] = 1'b1;
          end
          if(endpoint_TD_upateCBP) begin
            if(when_UsbOhci_l206_13) begin
              ioDma_cmd_payload_fragment_mask[3 : 0] = 4'b1111;
            end
          end
        end
        if(endpoint_TD_retire) begin
          if(when_UsbOhci_l206_14) begin
            ioDma_cmd_payload_fragment_mask[3 : 0] = 4'b1111;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
        if(endpoint_TD_retire) begin
          if(when_UsbOhci_l206_15) begin
            ioDma_cmd_payload_fragment_mask[3 : 0] = 4'b1111;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    case(endpoint_dmaLogic_stateReg)
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        ioDma_cmd_payload_fragment_mask = ((endpoint_dmaLogic_fullMask & (ioDma_cmd_payload_first ? endpoint_dmaLogic_headMask : endpoint_dmaLogic_fullMask)) & (ioDma_cmd_payload_last ? endpoint_dmaLogic_lastMask : endpoint_dmaLogic_fullMask));
      end
      default : begin
      end
    endcase
  end

  assign ioDma_rsp_ready = 1'b1;
  assign dmaRspMux_vec_0 = ioDma_rsp_payload_fragment_data[31 : 0];
  assign dmaRspMux_data = dmaRspMux_vec_0;
  assign ioDma_rsp_fire_1 = (ioDma_rsp_valid && ioDma_rsp_ready);
  assign ioDma_cmd_fire_2 = (ioDma_cmd_valid && ioDma_cmd_ready);
  always @(*) begin
    fifo_io_push_valid = 1'b0;
    if(when_UsbOhci_l938) begin
      fifo_io_push_valid = 1'b1;
    end
    if(endpoint_dmaLogic_push) begin
      fifo_io_push_valid = 1'b1;
    end
  end

  always @(*) begin
    fifo_io_push_payload = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    if(when_UsbOhci_l938) begin
      fifo_io_push_payload = ioDma_rsp_payload_fragment_data;
    end
    if(endpoint_dmaLogic_push) begin
      fifo_io_push_payload = endpoint_dmaLogic_buffer;
    end
  end

  always @(*) begin
    fifo_io_pop_ready = 1'b0;
    case(endpoint_dmaLogic_stateReg)
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : begin
        if(dataTx_data_ready) begin
          if(when_UsbOhci_l1025) begin
            fifo_io_pop_ready = 1'b1;
          end
        end
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        if(ioDma_cmd_ready) begin
          fifo_io_pop_ready = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    fifo_io_flush = 1'b0;
    case(endpoint_dmaLogic_stateReg)
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : begin
        fifo_io_flush = 1'b1;
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_phy_tx_valid = 1'b0;
    case(token_stateReg)
      UsbOhciWishbone_token_enumDef_INIT : begin
      end
      UsbOhciWishbone_token_enumDef_PID : begin
        io_phy_tx_valid = 1'b1;
      end
      UsbOhciWishbone_token_enumDef_B1 : begin
        io_phy_tx_valid = 1'b1;
      end
      UsbOhciWishbone_token_enumDef_B2 : begin
        io_phy_tx_valid = 1'b1;
      end
      UsbOhciWishbone_token_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
    case(dataTx_stateReg)
      UsbOhciWishbone_dataTx_enumDef_PID : begin
        io_phy_tx_valid = 1'b1;
      end
      UsbOhciWishbone_dataTx_enumDef_DATA : begin
        io_phy_tx_valid = 1'b1;
      end
      UsbOhciWishbone_dataTx_enumDef_CRC_0 : begin
        io_phy_tx_valid = 1'b1;
      end
      UsbOhciWishbone_dataTx_enumDef_CRC_1 : begin
        io_phy_tx_valid = 1'b1;
      end
      UsbOhciWishbone_dataTx_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
        io_phy_tx_valid = 1'b1;
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_phy_tx_payload_fragment = 8'bxxxxxxxx;
    case(token_stateReg)
      UsbOhciWishbone_token_enumDef_INIT : begin
      end
      UsbOhciWishbone_token_enumDef_PID : begin
        io_phy_tx_payload_fragment = {(~ token_pid),token_pid};
      end
      UsbOhciWishbone_token_enumDef_B1 : begin
        io_phy_tx_payload_fragment = token_data[7 : 0];
      end
      UsbOhciWishbone_token_enumDef_B2 : begin
        io_phy_tx_payload_fragment = {token_crc5_io_result,token_data[10 : 8]};
      end
      UsbOhciWishbone_token_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
    case(dataTx_stateReg)
      UsbOhciWishbone_dataTx_enumDef_PID : begin
        io_phy_tx_payload_fragment = {(~ dataTx_pid),dataTx_pid};
      end
      UsbOhciWishbone_dataTx_enumDef_DATA : begin
        io_phy_tx_payload_fragment = dataTx_data_payload_fragment;
      end
      UsbOhciWishbone_dataTx_enumDef_CRC_0 : begin
        io_phy_tx_payload_fragment = dataTx_crc16_io_result[7 : 0];
      end
      UsbOhciWishbone_dataTx_enumDef_CRC_1 : begin
        io_phy_tx_payload_fragment = dataTx_crc16_io_result[15 : 8];
      end
      UsbOhciWishbone_dataTx_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
        io_phy_tx_payload_fragment = 8'hd2;
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_phy_tx_payload_last = 1'bx;
    case(token_stateReg)
      UsbOhciWishbone_token_enumDef_INIT : begin
      end
      UsbOhciWishbone_token_enumDef_PID : begin
        io_phy_tx_payload_last = 1'b0;
      end
      UsbOhciWishbone_token_enumDef_B1 : begin
        io_phy_tx_payload_last = 1'b0;
      end
      UsbOhciWishbone_token_enumDef_B2 : begin
        io_phy_tx_payload_last = 1'b1;
      end
      UsbOhciWishbone_token_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
    case(dataTx_stateReg)
      UsbOhciWishbone_dataTx_enumDef_PID : begin
        io_phy_tx_payload_last = 1'b0;
      end
      UsbOhciWishbone_dataTx_enumDef_DATA : begin
        io_phy_tx_payload_last = 1'b0;
      end
      UsbOhciWishbone_dataTx_enumDef_CRC_0 : begin
        io_phy_tx_payload_last = 1'b0;
      end
      UsbOhciWishbone_dataTx_enumDef_CRC_1 : begin
        io_phy_tx_payload_last = 1'b1;
      end
      UsbOhciWishbone_dataTx_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
        io_phy_tx_payload_last = 1'b1;
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    ctrlHalt = 1'b0;
    case(hc_stateReg)
      UsbOhciWishbone_hc_enumDef_RESET : begin
      end
      UsbOhciWishbone_hc_enumDef_RESUME : begin
      end
      UsbOhciWishbone_hc_enumDef_OPERATIONAL : begin
      end
      UsbOhciWishbone_hc_enumDef_SUSPEND : begin
      end
      UsbOhciWishbone_hc_enumDef_ANY_TO_RESET : begin
        ctrlHalt = 1'b1;
      end
      UsbOhciWishbone_hc_enumDef_ANY_TO_SUSPEND : begin
        ctrlHalt = 1'b1;
      end
      default : begin
      end
    endcase
  end

  assign ctrl_readHaltTrigger = 1'b0;
  always @(*) begin
    ctrl_writeHaltTrigger = 1'b0;
    if(ctrlHalt) begin
      ctrl_writeHaltTrigger = 1'b1;
    end
  end

  assign _zz_io_ctrl_rsp_valid = (! (ctrl_readHaltTrigger || ctrl_writeHaltTrigger));
  assign ctrl_rsp_ready = (_zz_ctrl_rsp_ready && _zz_io_ctrl_rsp_valid);
  always @(*) begin
    _zz_ctrl_rsp_ready = io_ctrl_rsp_ready;
    if(when_Stream_l342) begin
      _zz_ctrl_rsp_ready = 1'b1;
    end
  end

  assign when_Stream_l342 = (! _zz_io_ctrl_rsp_valid_1);
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
      12'h0 : begin
        ctrl_rsp_payload_fragment_data[4 : 0] = reg_hcRevision_REV;
      end
      12'h004 : begin
        ctrl_rsp_payload_fragment_data[1 : 0] = reg_hcControl_CBSR;
        ctrl_rsp_payload_fragment_data[2 : 2] = reg_hcControl_PLE;
        ctrl_rsp_payload_fragment_data[3 : 3] = reg_hcControl_IE;
        ctrl_rsp_payload_fragment_data[4 : 4] = reg_hcControl_CLE;
        ctrl_rsp_payload_fragment_data[5 : 5] = reg_hcControl_BLE;
        ctrl_rsp_payload_fragment_data[7 : 6] = reg_hcControl_HCFS;
        ctrl_rsp_payload_fragment_data[8 : 8] = reg_hcControl_IR;
        ctrl_rsp_payload_fragment_data[9 : 9] = reg_hcControl_RWC;
        ctrl_rsp_payload_fragment_data[10 : 10] = reg_hcControl_RWE;
      end
      12'h008 : begin
        ctrl_rsp_payload_fragment_data[0 : 0] = doSoftReset;
        ctrl_rsp_payload_fragment_data[1 : 1] = reg_hcCommandStatus_CLF;
        ctrl_rsp_payload_fragment_data[2 : 2] = reg_hcCommandStatus_BLF;
        ctrl_rsp_payload_fragment_data[3 : 3] = reg_hcCommandStatus_OCR;
        ctrl_rsp_payload_fragment_data[17 : 16] = reg_hcCommandStatus_SOC;
      end
      12'h010 : begin
        ctrl_rsp_payload_fragment_data[31 : 31] = reg_hcInterrupt_MIE;
        ctrl_rsp_payload_fragment_data[0 : 0] = reg_hcInterrupt_SO_enable;
        ctrl_rsp_payload_fragment_data[1 : 1] = reg_hcInterrupt_WDH_enable;
        ctrl_rsp_payload_fragment_data[2 : 2] = reg_hcInterrupt_SF_enable;
        ctrl_rsp_payload_fragment_data[3 : 3] = reg_hcInterrupt_RD_enable;
        ctrl_rsp_payload_fragment_data[4 : 4] = reg_hcInterrupt_UE_enable;
        ctrl_rsp_payload_fragment_data[5 : 5] = reg_hcInterrupt_FNO_enable;
        ctrl_rsp_payload_fragment_data[6 : 6] = reg_hcInterrupt_RHSC_enable;
        ctrl_rsp_payload_fragment_data[30 : 30] = reg_hcInterrupt_OC_enable;
      end
      12'h014 : begin
        ctrl_rsp_payload_fragment_data[31 : 31] = reg_hcInterrupt_MIE;
        ctrl_rsp_payload_fragment_data[0 : 0] = reg_hcInterrupt_SO_enable;
        ctrl_rsp_payload_fragment_data[1 : 1] = reg_hcInterrupt_WDH_enable;
        ctrl_rsp_payload_fragment_data[2 : 2] = reg_hcInterrupt_SF_enable;
        ctrl_rsp_payload_fragment_data[3 : 3] = reg_hcInterrupt_RD_enable;
        ctrl_rsp_payload_fragment_data[4 : 4] = reg_hcInterrupt_UE_enable;
        ctrl_rsp_payload_fragment_data[5 : 5] = reg_hcInterrupt_FNO_enable;
        ctrl_rsp_payload_fragment_data[6 : 6] = reg_hcInterrupt_RHSC_enable;
        ctrl_rsp_payload_fragment_data[30 : 30] = reg_hcInterrupt_OC_enable;
      end
      12'h00c : begin
        ctrl_rsp_payload_fragment_data[0 : 0] = reg_hcInterrupt_SO_status;
        ctrl_rsp_payload_fragment_data[1 : 1] = reg_hcInterrupt_WDH_status;
        ctrl_rsp_payload_fragment_data[2 : 2] = reg_hcInterrupt_SF_status;
        ctrl_rsp_payload_fragment_data[3 : 3] = reg_hcInterrupt_RD_status;
        ctrl_rsp_payload_fragment_data[4 : 4] = reg_hcInterrupt_UE_status;
        ctrl_rsp_payload_fragment_data[5 : 5] = reg_hcInterrupt_FNO_status;
        ctrl_rsp_payload_fragment_data[6 : 6] = reg_hcInterrupt_RHSC_status;
        ctrl_rsp_payload_fragment_data[30 : 30] = reg_hcInterrupt_OC_status;
      end
      12'h018 : begin
        ctrl_rsp_payload_fragment_data[31 : 8] = reg_hcHCCA_HCCA_reg;
      end
      12'h01c : begin
        ctrl_rsp_payload_fragment_data[31 : 4] = reg_hcPeriodCurrentED_PCED_reg;
      end
      12'h020 : begin
        ctrl_rsp_payload_fragment_data[31 : 4] = reg_hcControlHeadED_CHED_reg;
      end
      12'h024 : begin
        ctrl_rsp_payload_fragment_data[31 : 4] = reg_hcControlCurrentED_CCED_reg;
      end
      12'h028 : begin
        ctrl_rsp_payload_fragment_data[31 : 4] = reg_hcBulkHeadED_BHED_reg;
      end
      12'h02c : begin
        ctrl_rsp_payload_fragment_data[31 : 4] = reg_hcBulkCurrentED_BCED_reg;
      end
      12'h030 : begin
        ctrl_rsp_payload_fragment_data[31 : 4] = reg_hcDoneHead_DH_reg;
      end
      12'h034 : begin
        ctrl_rsp_payload_fragment_data[13 : 0] = reg_hcFmInterval_FI;
        ctrl_rsp_payload_fragment_data[30 : 16] = reg_hcFmInterval_FSMPS;
        ctrl_rsp_payload_fragment_data[31 : 31] = reg_hcFmInterval_FIT;
      end
      12'h038 : begin
        ctrl_rsp_payload_fragment_data[13 : 0] = reg_hcFmRemaining_FR;
        ctrl_rsp_payload_fragment_data[31 : 31] = reg_hcFmRemaining_FRT;
      end
      12'h03c : begin
        ctrl_rsp_payload_fragment_data[15 : 0] = reg_hcFmNumber_FN;
      end
      12'h040 : begin
        ctrl_rsp_payload_fragment_data[13 : 0] = reg_hcPeriodicStart_PS;
      end
      12'h044 : begin
        ctrl_rsp_payload_fragment_data[11 : 0] = reg_hcLSThreshold_LST;
      end
      12'h048 : begin
        ctrl_rsp_payload_fragment_data[7 : 0] = reg_hcRhDescriptorA_NDP;
        ctrl_rsp_payload_fragment_data[8 : 8] = reg_hcRhDescriptorA_PSM;
        ctrl_rsp_payload_fragment_data[9 : 9] = reg_hcRhDescriptorA_NPS;
        ctrl_rsp_payload_fragment_data[11 : 11] = reg_hcRhDescriptorA_OCPM;
        ctrl_rsp_payload_fragment_data[12 : 12] = reg_hcRhDescriptorA_NOCP;
        ctrl_rsp_payload_fragment_data[31 : 24] = reg_hcRhDescriptorA_POTPGT;
      end
      12'h04c : begin
        ctrl_rsp_payload_fragment_data[2 : 1] = reg_hcRhDescriptorB_DR;
        ctrl_rsp_payload_fragment_data[18 : 17] = reg_hcRhDescriptorB_PPCM;
      end
      12'h050 : begin
        ctrl_rsp_payload_fragment_data[1 : 1] = io_phy_overcurrent;
        ctrl_rsp_payload_fragment_data[15 : 15] = reg_hcRhStatus_DRWE;
        ctrl_rsp_payload_fragment_data[17 : 17] = reg_hcRhStatus_CCIC;
      end
      12'h054 : begin
        ctrl_rsp_payload_fragment_data[2 : 2] = reg_hcRhPortStatus_0_PSS;
        ctrl_rsp_payload_fragment_data[8 : 8] = reg_hcRhPortStatus_0_PPS;
        ctrl_rsp_payload_fragment_data[0 : 0] = reg_hcRhPortStatus_0_CCS;
        ctrl_rsp_payload_fragment_data[1 : 1] = reg_hcRhPortStatus_0_PES;
        ctrl_rsp_payload_fragment_data[3 : 3] = io_phy_ports_0_overcurrent;
        ctrl_rsp_payload_fragment_data[4 : 4] = reg_hcRhPortStatus_0_reset;
        ctrl_rsp_payload_fragment_data[9 : 9] = io_phy_ports_0_lowSpeed;
        ctrl_rsp_payload_fragment_data[16 : 16] = reg_hcRhPortStatus_0_CSC_reg;
        ctrl_rsp_payload_fragment_data[17 : 17] = reg_hcRhPortStatus_0_PESC_reg;
        ctrl_rsp_payload_fragment_data[18 : 18] = reg_hcRhPortStatus_0_PSSC_reg;
        ctrl_rsp_payload_fragment_data[19 : 19] = reg_hcRhPortStatus_0_OCIC_reg;
        ctrl_rsp_payload_fragment_data[20 : 20] = reg_hcRhPortStatus_0_PRSC_reg;
      end
      12'h058 : begin
        ctrl_rsp_payload_fragment_data[2 : 2] = reg_hcRhPortStatus_1_PSS;
        ctrl_rsp_payload_fragment_data[8 : 8] = reg_hcRhPortStatus_1_PPS;
        ctrl_rsp_payload_fragment_data[0 : 0] = reg_hcRhPortStatus_1_CCS;
        ctrl_rsp_payload_fragment_data[1 : 1] = reg_hcRhPortStatus_1_PES;
        ctrl_rsp_payload_fragment_data[3 : 3] = io_phy_ports_1_overcurrent;
        ctrl_rsp_payload_fragment_data[4 : 4] = reg_hcRhPortStatus_1_reset;
        ctrl_rsp_payload_fragment_data[9 : 9] = io_phy_ports_1_lowSpeed;
        ctrl_rsp_payload_fragment_data[16 : 16] = reg_hcRhPortStatus_1_CSC_reg;
        ctrl_rsp_payload_fragment_data[17 : 17] = reg_hcRhPortStatus_1_PESC_reg;
        ctrl_rsp_payload_fragment_data[18 : 18] = reg_hcRhPortStatus_1_PSSC_reg;
        ctrl_rsp_payload_fragment_data[19 : 19] = reg_hcRhPortStatus_1_OCIC_reg;
        ctrl_rsp_payload_fragment_data[20 : 20] = reg_hcRhPortStatus_1_PRSC_reg;
      end
      default : begin
      end
    endcase
  end

  assign when_UsbOhci_l236 = (! doUnschedule);
  assign reg_hcRevision_REV = 5'h10;
  always @(*) begin
    reg_hcControl_HCFSWrite_valid = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h004 : begin
        if(ctrl_doWrite) begin
          reg_hcControl_HCFSWrite_valid = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    reg_hcCommandStatus_startSoftReset = 1'b0;
    if(when_BusSlaveFactory_l366) begin
      if(when_BusSlaveFactory_l368) begin
        reg_hcCommandStatus_startSoftReset = _zz_reg_hcCommandStatus_startSoftReset[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h008 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368 = io_ctrl_cmd_payload_fragment_data[0];
  always @(*) begin
    when_BusSlaveFactory_l366_1 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h008 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_1 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_1 = io_ctrl_cmd_payload_fragment_data[1];
  always @(*) begin
    when_BusSlaveFactory_l366_2 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h008 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_2 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_2 = io_ctrl_cmd_payload_fragment_data[2];
  always @(*) begin
    when_BusSlaveFactory_l366_3 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h008 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_3 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_3 = io_ctrl_cmd_payload_fragment_data[3];
  always @(*) begin
    reg_hcInterrupt_unmaskedPending = 1'b0;
    if(when_UsbOhci_l302) begin
      reg_hcInterrupt_unmaskedPending = 1'b1;
    end
    if(when_UsbOhci_l302_1) begin
      reg_hcInterrupt_unmaskedPending = 1'b1;
    end
    if(when_UsbOhci_l302_2) begin
      reg_hcInterrupt_unmaskedPending = 1'b1;
    end
    if(when_UsbOhci_l302_3) begin
      reg_hcInterrupt_unmaskedPending = 1'b1;
    end
    if(when_UsbOhci_l302_4) begin
      reg_hcInterrupt_unmaskedPending = 1'b1;
    end
    if(when_UsbOhci_l302_5) begin
      reg_hcInterrupt_unmaskedPending = 1'b1;
    end
    if(when_UsbOhci_l302_6) begin
      reg_hcInterrupt_unmaskedPending = 1'b1;
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_4 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h010 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_4 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_4 = io_ctrl_cmd_payload_fragment_data[31];
  always @(*) begin
    when_BusSlaveFactory_l335 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h014 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l337 = io_ctrl_cmd_payload_fragment_data[31];
  always @(*) begin
    when_BusSlaveFactory_l335_1 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h00c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_1 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l337_1 = io_ctrl_cmd_payload_fragment_data[0];
  always @(*) begin
    when_BusSlaveFactory_l366_5 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h010 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_5 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_5 = io_ctrl_cmd_payload_fragment_data[0];
  always @(*) begin
    when_BusSlaveFactory_l335_2 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h014 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_2 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l337_2 = io_ctrl_cmd_payload_fragment_data[0];
  assign when_UsbOhci_l302 = (reg_hcInterrupt_SO_status && reg_hcInterrupt_SO_enable);
  always @(*) begin
    when_BusSlaveFactory_l335_3 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h00c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_3 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l337_3 = io_ctrl_cmd_payload_fragment_data[1];
  always @(*) begin
    when_BusSlaveFactory_l366_6 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h010 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_6 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_6 = io_ctrl_cmd_payload_fragment_data[1];
  always @(*) begin
    when_BusSlaveFactory_l335_4 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h014 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_4 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l337_4 = io_ctrl_cmd_payload_fragment_data[1];
  assign when_UsbOhci_l302_1 = (reg_hcInterrupt_WDH_status && reg_hcInterrupt_WDH_enable);
  always @(*) begin
    when_BusSlaveFactory_l335_5 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h00c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_5 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l337_5 = io_ctrl_cmd_payload_fragment_data[2];
  always @(*) begin
    when_BusSlaveFactory_l366_7 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h010 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_7 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_7 = io_ctrl_cmd_payload_fragment_data[2];
  always @(*) begin
    when_BusSlaveFactory_l335_6 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h014 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_6 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l337_6 = io_ctrl_cmd_payload_fragment_data[2];
  assign when_UsbOhci_l302_2 = (reg_hcInterrupt_SF_status && reg_hcInterrupt_SF_enable);
  always @(*) begin
    when_BusSlaveFactory_l335_7 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h00c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_7 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l337_7 = io_ctrl_cmd_payload_fragment_data[3];
  always @(*) begin
    when_BusSlaveFactory_l366_8 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h010 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_8 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_8 = io_ctrl_cmd_payload_fragment_data[3];
  always @(*) begin
    when_BusSlaveFactory_l335_8 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h014 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_8 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l337_8 = io_ctrl_cmd_payload_fragment_data[3];
  assign when_UsbOhci_l302_3 = (reg_hcInterrupt_RD_status && reg_hcInterrupt_RD_enable);
  always @(*) begin
    when_BusSlaveFactory_l335_9 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h00c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_9 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l337_9 = io_ctrl_cmd_payload_fragment_data[4];
  always @(*) begin
    when_BusSlaveFactory_l366_9 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h010 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_9 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_9 = io_ctrl_cmd_payload_fragment_data[4];
  always @(*) begin
    when_BusSlaveFactory_l335_10 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h014 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_10 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l337_10 = io_ctrl_cmd_payload_fragment_data[4];
  assign when_UsbOhci_l302_4 = (reg_hcInterrupt_UE_status && reg_hcInterrupt_UE_enable);
  always @(*) begin
    when_BusSlaveFactory_l335_11 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h00c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_11 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l337_11 = io_ctrl_cmd_payload_fragment_data[5];
  always @(*) begin
    when_BusSlaveFactory_l366_10 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h010 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_10 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_10 = io_ctrl_cmd_payload_fragment_data[5];
  always @(*) begin
    when_BusSlaveFactory_l335_12 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h014 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_12 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l337_12 = io_ctrl_cmd_payload_fragment_data[5];
  assign when_UsbOhci_l302_5 = (reg_hcInterrupt_FNO_status && reg_hcInterrupt_FNO_enable);
  always @(*) begin
    when_BusSlaveFactory_l335_13 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h00c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_13 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l337_13 = io_ctrl_cmd_payload_fragment_data[6];
  always @(*) begin
    when_BusSlaveFactory_l366_11 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h010 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_11 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_11 = io_ctrl_cmd_payload_fragment_data[6];
  always @(*) begin
    when_BusSlaveFactory_l335_14 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h014 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_14 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l337_14 = io_ctrl_cmd_payload_fragment_data[6];
  assign when_UsbOhci_l302_6 = (reg_hcInterrupt_RHSC_status && reg_hcInterrupt_RHSC_enable);
  always @(*) begin
    when_BusSlaveFactory_l335_15 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h00c : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_15 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l337_15 = io_ctrl_cmd_payload_fragment_data[30];
  always @(*) begin
    when_BusSlaveFactory_l366_12 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h010 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_12 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_12 = io_ctrl_cmd_payload_fragment_data[30];
  always @(*) begin
    when_BusSlaveFactory_l335_16 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h014 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_16 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l337_16 = io_ctrl_cmd_payload_fragment_data[30];
  assign reg_hcInterrupt_doIrq = (reg_hcInterrupt_unmaskedPending && reg_hcInterrupt_MIE);
  assign io_interrupt = (reg_hcInterrupt_doIrq && (! reg_hcControl_IR));
  assign io_interruptBios = ((reg_hcInterrupt_doIrq && reg_hcControl_IR) || (reg_hcInterrupt_OC_status && reg_hcInterrupt_OC_enable));
  assign reg_hcHCCA_HCCA_address = {reg_hcHCCA_HCCA_reg,8'h0};
  assign reg_hcPeriodCurrentED_PCED_address = {reg_hcPeriodCurrentED_PCED_reg,4'b0000};
  assign reg_hcPeriodCurrentED_isZero = (reg_hcPeriodCurrentED_PCED_reg == 28'h0);
  assign reg_hcControlHeadED_CHED_address = {reg_hcControlHeadED_CHED_reg,4'b0000};
  assign reg_hcControlCurrentED_CCED_address = {reg_hcControlCurrentED_CCED_reg,4'b0000};
  assign reg_hcControlCurrentED_isZero = (reg_hcControlCurrentED_CCED_reg == 28'h0);
  assign reg_hcBulkHeadED_BHED_address = {reg_hcBulkHeadED_BHED_reg,4'b0000};
  assign reg_hcBulkCurrentED_BCED_address = {reg_hcBulkCurrentED_BCED_reg,4'b0000};
  assign reg_hcBulkCurrentED_isZero = (reg_hcBulkCurrentED_BCED_reg == 28'h0);
  assign reg_hcDoneHead_DH_address = {reg_hcDoneHead_DH_reg,4'b0000};
  assign reg_hcFmNumber_FNp1 = (reg_hcFmNumber_FN + 16'h0001);
  assign reg_hcLSThreshold_hit = (reg_hcFmRemaining_FR < _zz_reg_hcLSThreshold_hit);
  assign reg_hcRhDescriptorA_NDP = 8'h02;
  always @(*) begin
    when_BusSlaveFactory_l335_17 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h050 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l335_17 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l337_17 = io_ctrl_cmd_payload_fragment_data[17];
  assign when_UsbOhci_l409 = (io_phy_overcurrent ^ io_phy_overcurrent_regNext);
  always @(*) begin
    reg_hcRhStatus_clearGlobalPower = 1'b0;
    if(when_BusSlaveFactory_l366_13) begin
      if(when_BusSlaveFactory_l368_13) begin
        reg_hcRhStatus_clearGlobalPower = _zz_reg_hcRhStatus_clearGlobalPower[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_13 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h050 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_13 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_13 = io_ctrl_cmd_payload_fragment_data[0];
  always @(*) begin
    reg_hcRhStatus_setRemoteWakeupEnable = 1'b0;
    if(when_BusSlaveFactory_l366_14) begin
      if(when_BusSlaveFactory_l368_14) begin
        reg_hcRhStatus_setRemoteWakeupEnable = _zz_reg_hcRhStatus_setRemoteWakeupEnable[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_14 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h050 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_14 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_14 = io_ctrl_cmd_payload_fragment_data[15];
  always @(*) begin
    reg_hcRhStatus_setGlobalPower = 1'b0;
    if(when_BusSlaveFactory_l366_15) begin
      if(when_BusSlaveFactory_l368_15) begin
        reg_hcRhStatus_setGlobalPower = _zz_reg_hcRhStatus_setGlobalPower[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_15 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h050 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_15 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_15 = io_ctrl_cmd_payload_fragment_data[16];
  always @(*) begin
    reg_hcRhStatus_clearRemoteWakeupEnable = 1'b0;
    if(when_BusSlaveFactory_l366_16) begin
      if(when_BusSlaveFactory_l368_16) begin
        reg_hcRhStatus_clearRemoteWakeupEnable = _zz_reg_hcRhStatus_clearRemoteWakeupEnable[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_16 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h050 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_16 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_16 = io_ctrl_cmd_payload_fragment_data[31];
  always @(*) begin
    reg_hcRhPortStatus_0_clearPortEnable = 1'b0;
    if(when_BusSlaveFactory_l366_17) begin
      if(when_BusSlaveFactory_l368_17) begin
        reg_hcRhPortStatus_0_clearPortEnable = _zz_reg_hcRhPortStatus_0_clearPortEnable[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_17 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_17 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_17 = io_ctrl_cmd_payload_fragment_data[0];
  always @(*) begin
    reg_hcRhPortStatus_0_setPortEnable = 1'b0;
    if(when_BusSlaveFactory_l366_18) begin
      if(when_BusSlaveFactory_l368_18) begin
        reg_hcRhPortStatus_0_setPortEnable = _zz_reg_hcRhPortStatus_0_setPortEnable[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_18 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_18 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_18 = io_ctrl_cmd_payload_fragment_data[1];
  always @(*) begin
    reg_hcRhPortStatus_0_setPortSuspend = 1'b0;
    if(when_BusSlaveFactory_l366_19) begin
      if(when_BusSlaveFactory_l368_19) begin
        reg_hcRhPortStatus_0_setPortSuspend = _zz_reg_hcRhPortStatus_0_setPortSuspend[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_19 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_19 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_19 = io_ctrl_cmd_payload_fragment_data[2];
  always @(*) begin
    reg_hcRhPortStatus_0_clearSuspendStatus = 1'b0;
    if(when_BusSlaveFactory_l366_20) begin
      if(when_BusSlaveFactory_l368_20) begin
        reg_hcRhPortStatus_0_clearSuspendStatus = _zz_reg_hcRhPortStatus_0_clearSuspendStatus[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_20 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_20 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_20 = io_ctrl_cmd_payload_fragment_data[3];
  always @(*) begin
    reg_hcRhPortStatus_0_setPortReset = 1'b0;
    if(when_BusSlaveFactory_l366_21) begin
      if(when_BusSlaveFactory_l368_21) begin
        reg_hcRhPortStatus_0_setPortReset = _zz_reg_hcRhPortStatus_0_setPortReset[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_21 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_21 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_21 = io_ctrl_cmd_payload_fragment_data[4];
  always @(*) begin
    reg_hcRhPortStatus_0_setPortPower = 1'b0;
    if(when_BusSlaveFactory_l366_22) begin
      if(when_BusSlaveFactory_l368_22) begin
        reg_hcRhPortStatus_0_setPortPower = _zz_reg_hcRhPortStatus_0_setPortPower[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_22 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_22 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_22 = io_ctrl_cmd_payload_fragment_data[8];
  always @(*) begin
    reg_hcRhPortStatus_0_clearPortPower = 1'b0;
    if(when_BusSlaveFactory_l366_23) begin
      if(when_BusSlaveFactory_l368_23) begin
        reg_hcRhPortStatus_0_clearPortPower = _zz_reg_hcRhPortStatus_0_clearPortPower[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_23 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_23 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_23 = io_ctrl_cmd_payload_fragment_data[9];
  assign reg_hcRhPortStatus_0_CCS = ((reg_hcRhPortStatus_0_connected || reg_hcRhDescriptorB_DR[0]) && reg_hcRhPortStatus_0_PPS);
  always @(*) begin
    reg_hcRhPortStatus_0_CSC_clear = 1'b0;
    if(when_BusSlaveFactory_l366_24) begin
      if(when_BusSlaveFactory_l368_24) begin
        reg_hcRhPortStatus_0_CSC_clear = _zz_reg_hcRhPortStatus_0_CSC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_24 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_24 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_24 = io_ctrl_cmd_payload_fragment_data[16];
  always @(*) begin
    reg_hcRhPortStatus_0_PESC_clear = 1'b0;
    if(when_BusSlaveFactory_l366_25) begin
      if(when_BusSlaveFactory_l368_25) begin
        reg_hcRhPortStatus_0_PESC_clear = _zz_reg_hcRhPortStatus_0_PESC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_25 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_25 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_25 = io_ctrl_cmd_payload_fragment_data[17];
  always @(*) begin
    reg_hcRhPortStatus_0_PSSC_clear = 1'b0;
    if(when_BusSlaveFactory_l366_26) begin
      if(when_BusSlaveFactory_l368_26) begin
        reg_hcRhPortStatus_0_PSSC_clear = _zz_reg_hcRhPortStatus_0_PSSC_clear[0];
      end
    end
    if(reg_hcRhPortStatus_0_PRSC_set) begin
      reg_hcRhPortStatus_0_PSSC_clear = 1'b1;
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_26 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_26 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_26 = io_ctrl_cmd_payload_fragment_data[18];
  always @(*) begin
    reg_hcRhPortStatus_0_OCIC_clear = 1'b0;
    if(when_BusSlaveFactory_l366_27) begin
      if(when_BusSlaveFactory_l368_27) begin
        reg_hcRhPortStatus_0_OCIC_clear = _zz_reg_hcRhPortStatus_0_OCIC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_27 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_27 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_27 = io_ctrl_cmd_payload_fragment_data[19];
  always @(*) begin
    reg_hcRhPortStatus_0_PRSC_clear = 1'b0;
    if(when_BusSlaveFactory_l366_28) begin
      if(when_BusSlaveFactory_l368_28) begin
        reg_hcRhPortStatus_0_PRSC_clear = _zz_reg_hcRhPortStatus_0_PRSC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_28 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h054 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_28 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_28 = io_ctrl_cmd_payload_fragment_data[20];
  assign when_UsbOhci_l460 = ((reg_hcRhPortStatus_0_clearPortEnable || reg_hcRhPortStatus_0_PESC_set) || (! reg_hcRhPortStatus_0_PPS));
  assign when_UsbOhci_l460_1 = (reg_hcRhPortStatus_0_PRSC_set || reg_hcRhPortStatus_0_PSSC_set);
  assign when_UsbOhci_l460_2 = (reg_hcRhPortStatus_0_setPortEnable && reg_hcRhPortStatus_0_CCS);
  assign when_UsbOhci_l461 = (((reg_hcRhPortStatus_0_PSSC_set || reg_hcRhPortStatus_0_PRSC_set) || (! reg_hcRhPortStatus_0_PPS)) || (reg_hcControl_HCFS == UsbOhciWishbone_MainState_RESUME));
  assign when_UsbOhci_l461_1 = (reg_hcRhPortStatus_0_setPortSuspend && reg_hcRhPortStatus_0_CCS);
  assign when_UsbOhci_l462 = (reg_hcRhPortStatus_0_setPortSuspend && reg_hcRhPortStatus_0_CCS);
  assign when_UsbOhci_l463 = (reg_hcRhPortStatus_0_clearSuspendStatus && reg_hcRhPortStatus_0_PSS);
  assign when_UsbOhci_l464 = (reg_hcRhPortStatus_0_setPortReset && reg_hcRhPortStatus_0_CCS);
  assign when_UsbOhci_l470 = reg_hcRhDescriptorB_PPCM[0];
  assign reg_hcRhPortStatus_0_CSC_set = ((((reg_hcRhPortStatus_0_CCS ^ reg_hcRhPortStatus_0_CCS_regNext) || (reg_hcRhPortStatus_0_setPortEnable && (! reg_hcRhPortStatus_0_CCS))) || (reg_hcRhPortStatus_0_setPortSuspend && (! reg_hcRhPortStatus_0_CCS))) || (reg_hcRhPortStatus_0_setPortReset && (! reg_hcRhPortStatus_0_CCS)));
  assign reg_hcRhPortStatus_0_PESC_set = io_phy_ports_0_overcurrent;
  assign io_phy_ports_0_suspend_fire = (io_phy_ports_0_suspend_valid && io_phy_ports_0_suspend_ready);
  assign reg_hcRhPortStatus_0_PSSC_set = (io_phy_ports_0_suspend_fire || io_phy_ports_0_remoteResume);
  assign reg_hcRhPortStatus_0_OCIC_set = io_phy_ports_0_overcurrent;
  assign io_phy_ports_0_reset_fire = (io_phy_ports_0_reset_valid && io_phy_ports_0_reset_ready);
  assign reg_hcRhPortStatus_0_PRSC_set = io_phy_ports_0_reset_fire;
  assign io_phy_ports_0_disable_valid = reg_hcRhPortStatus_0_clearPortEnable;
  assign io_phy_ports_0_removable = reg_hcRhDescriptorB_DR[0];
  assign io_phy_ports_0_power = reg_hcRhPortStatus_0_PPS;
  assign io_phy_ports_0_resume_valid = reg_hcRhPortStatus_0_resume;
  assign io_phy_ports_0_resume_fire = (io_phy_ports_0_resume_valid && io_phy_ports_0_resume_ready);
  assign io_phy_ports_0_reset_valid = reg_hcRhPortStatus_0_reset;
  assign io_phy_ports_0_reset_fire_1 = (io_phy_ports_0_reset_valid && io_phy_ports_0_reset_ready);
  assign io_phy_ports_0_suspend_valid = reg_hcRhPortStatus_0_suspend;
  assign io_phy_ports_0_suspend_fire_1 = (io_phy_ports_0_suspend_valid && io_phy_ports_0_suspend_ready);
  always @(*) begin
    reg_hcRhPortStatus_1_clearPortEnable = 1'b0;
    if(when_BusSlaveFactory_l366_29) begin
      if(when_BusSlaveFactory_l368_29) begin
        reg_hcRhPortStatus_1_clearPortEnable = _zz_reg_hcRhPortStatus_1_clearPortEnable[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_29 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_29 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_29 = io_ctrl_cmd_payload_fragment_data[0];
  always @(*) begin
    reg_hcRhPortStatus_1_setPortEnable = 1'b0;
    if(when_BusSlaveFactory_l366_30) begin
      if(when_BusSlaveFactory_l368_30) begin
        reg_hcRhPortStatus_1_setPortEnable = _zz_reg_hcRhPortStatus_1_setPortEnable[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_30 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_30 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_30 = io_ctrl_cmd_payload_fragment_data[1];
  always @(*) begin
    reg_hcRhPortStatus_1_setPortSuspend = 1'b0;
    if(when_BusSlaveFactory_l366_31) begin
      if(when_BusSlaveFactory_l368_31) begin
        reg_hcRhPortStatus_1_setPortSuspend = _zz_reg_hcRhPortStatus_1_setPortSuspend[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_31 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_31 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_31 = io_ctrl_cmd_payload_fragment_data[2];
  always @(*) begin
    reg_hcRhPortStatus_1_clearSuspendStatus = 1'b0;
    if(when_BusSlaveFactory_l366_32) begin
      if(when_BusSlaveFactory_l368_32) begin
        reg_hcRhPortStatus_1_clearSuspendStatus = _zz_reg_hcRhPortStatus_1_clearSuspendStatus[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_32 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_32 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_32 = io_ctrl_cmd_payload_fragment_data[3];
  always @(*) begin
    reg_hcRhPortStatus_1_setPortReset = 1'b0;
    if(when_BusSlaveFactory_l366_33) begin
      if(when_BusSlaveFactory_l368_33) begin
        reg_hcRhPortStatus_1_setPortReset = _zz_reg_hcRhPortStatus_1_setPortReset[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_33 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_33 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_33 = io_ctrl_cmd_payload_fragment_data[4];
  always @(*) begin
    reg_hcRhPortStatus_1_setPortPower = 1'b0;
    if(when_BusSlaveFactory_l366_34) begin
      if(when_BusSlaveFactory_l368_34) begin
        reg_hcRhPortStatus_1_setPortPower = _zz_reg_hcRhPortStatus_1_setPortPower[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_34 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_34 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_34 = io_ctrl_cmd_payload_fragment_data[8];
  always @(*) begin
    reg_hcRhPortStatus_1_clearPortPower = 1'b0;
    if(when_BusSlaveFactory_l366_35) begin
      if(when_BusSlaveFactory_l368_35) begin
        reg_hcRhPortStatus_1_clearPortPower = _zz_reg_hcRhPortStatus_1_clearPortPower[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_35 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_35 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_35 = io_ctrl_cmd_payload_fragment_data[9];
  assign reg_hcRhPortStatus_1_CCS = ((reg_hcRhPortStatus_1_connected || reg_hcRhDescriptorB_DR[1]) && reg_hcRhPortStatus_1_PPS);
  always @(*) begin
    reg_hcRhPortStatus_1_CSC_clear = 1'b0;
    if(when_BusSlaveFactory_l366_36) begin
      if(when_BusSlaveFactory_l368_36) begin
        reg_hcRhPortStatus_1_CSC_clear = _zz_reg_hcRhPortStatus_1_CSC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_36 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_36 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_36 = io_ctrl_cmd_payload_fragment_data[16];
  always @(*) begin
    reg_hcRhPortStatus_1_PESC_clear = 1'b0;
    if(when_BusSlaveFactory_l366_37) begin
      if(when_BusSlaveFactory_l368_37) begin
        reg_hcRhPortStatus_1_PESC_clear = _zz_reg_hcRhPortStatus_1_PESC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_37 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_37 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_37 = io_ctrl_cmd_payload_fragment_data[17];
  always @(*) begin
    reg_hcRhPortStatus_1_PSSC_clear = 1'b0;
    if(when_BusSlaveFactory_l366_38) begin
      if(when_BusSlaveFactory_l368_38) begin
        reg_hcRhPortStatus_1_PSSC_clear = _zz_reg_hcRhPortStatus_1_PSSC_clear[0];
      end
    end
    if(reg_hcRhPortStatus_1_PRSC_set) begin
      reg_hcRhPortStatus_1_PSSC_clear = 1'b1;
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_38 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_38 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_38 = io_ctrl_cmd_payload_fragment_data[18];
  always @(*) begin
    reg_hcRhPortStatus_1_OCIC_clear = 1'b0;
    if(when_BusSlaveFactory_l366_39) begin
      if(when_BusSlaveFactory_l368_39) begin
        reg_hcRhPortStatus_1_OCIC_clear = _zz_reg_hcRhPortStatus_1_OCIC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_39 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_39 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_39 = io_ctrl_cmd_payload_fragment_data[19];
  always @(*) begin
    reg_hcRhPortStatus_1_PRSC_clear = 1'b0;
    if(when_BusSlaveFactory_l366_40) begin
      if(when_BusSlaveFactory_l368_40) begin
        reg_hcRhPortStatus_1_PRSC_clear = _zz_reg_hcRhPortStatus_1_PRSC_clear[0];
      end
    end
  end

  always @(*) begin
    when_BusSlaveFactory_l366_40 = 1'b0;
    case(io_ctrl_cmd_payload_fragment_address)
      12'h058 : begin
        if(ctrl_doWrite) begin
          when_BusSlaveFactory_l366_40 = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign when_BusSlaveFactory_l368_40 = io_ctrl_cmd_payload_fragment_data[20];
  assign when_UsbOhci_l460_3 = ((reg_hcRhPortStatus_1_clearPortEnable || reg_hcRhPortStatus_1_PESC_set) || (! reg_hcRhPortStatus_1_PPS));
  assign when_UsbOhci_l460_4 = (reg_hcRhPortStatus_1_PRSC_set || reg_hcRhPortStatus_1_PSSC_set);
  assign when_UsbOhci_l460_5 = (reg_hcRhPortStatus_1_setPortEnable && reg_hcRhPortStatus_1_CCS);
  assign when_UsbOhci_l461_2 = (((reg_hcRhPortStatus_1_PSSC_set || reg_hcRhPortStatus_1_PRSC_set) || (! reg_hcRhPortStatus_1_PPS)) || (reg_hcControl_HCFS == UsbOhciWishbone_MainState_RESUME));
  assign when_UsbOhci_l461_3 = (reg_hcRhPortStatus_1_setPortSuspend && reg_hcRhPortStatus_1_CCS);
  assign when_UsbOhci_l462_1 = (reg_hcRhPortStatus_1_setPortSuspend && reg_hcRhPortStatus_1_CCS);
  assign when_UsbOhci_l463_1 = (reg_hcRhPortStatus_1_clearSuspendStatus && reg_hcRhPortStatus_1_PSS);
  assign when_UsbOhci_l464_1 = (reg_hcRhPortStatus_1_setPortReset && reg_hcRhPortStatus_1_CCS);
  assign when_UsbOhci_l470_1 = reg_hcRhDescriptorB_PPCM[1];
  assign reg_hcRhPortStatus_1_CSC_set = ((((reg_hcRhPortStatus_1_CCS ^ reg_hcRhPortStatus_1_CCS_regNext) || (reg_hcRhPortStatus_1_setPortEnable && (! reg_hcRhPortStatus_1_CCS))) || (reg_hcRhPortStatus_1_setPortSuspend && (! reg_hcRhPortStatus_1_CCS))) || (reg_hcRhPortStatus_1_setPortReset && (! reg_hcRhPortStatus_1_CCS)));
  assign reg_hcRhPortStatus_1_PESC_set = io_phy_ports_1_overcurrent;
  assign io_phy_ports_1_suspend_fire = (io_phy_ports_1_suspend_valid && io_phy_ports_1_suspend_ready);
  assign reg_hcRhPortStatus_1_PSSC_set = (io_phy_ports_1_suspend_fire || io_phy_ports_1_remoteResume);
  assign reg_hcRhPortStatus_1_OCIC_set = io_phy_ports_1_overcurrent;
  assign io_phy_ports_1_reset_fire = (io_phy_ports_1_reset_valid && io_phy_ports_1_reset_ready);
  assign reg_hcRhPortStatus_1_PRSC_set = io_phy_ports_1_reset_fire;
  assign io_phy_ports_1_disable_valid = reg_hcRhPortStatus_1_clearPortEnable;
  assign io_phy_ports_1_removable = reg_hcRhDescriptorB_DR[1];
  assign io_phy_ports_1_power = reg_hcRhPortStatus_1_PPS;
  assign io_phy_ports_1_resume_valid = reg_hcRhPortStatus_1_resume;
  assign io_phy_ports_1_resume_fire = (io_phy_ports_1_resume_valid && io_phy_ports_1_resume_ready);
  assign io_phy_ports_1_reset_valid = reg_hcRhPortStatus_1_reset;
  assign io_phy_ports_1_reset_fire_1 = (io_phy_ports_1_reset_valid && io_phy_ports_1_reset_ready);
  assign io_phy_ports_1_suspend_valid = reg_hcRhPortStatus_1_suspend;
  assign io_phy_ports_1_suspend_fire_1 = (io_phy_ports_1_suspend_valid && io_phy_ports_1_suspend_ready);
  always @(*) begin
    frame_run = 1'b0;
    case(hc_stateReg)
      UsbOhciWishbone_hc_enumDef_RESET : begin
      end
      UsbOhciWishbone_hc_enumDef_RESUME : begin
      end
      UsbOhciWishbone_hc_enumDef_OPERATIONAL : begin
        frame_run = 1'b1;
      end
      UsbOhciWishbone_hc_enumDef_SUSPEND : begin
      end
      UsbOhciWishbone_hc_enumDef_ANY_TO_RESET : begin
      end
      UsbOhciWishbone_hc_enumDef_ANY_TO_SUSPEND : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    frame_reload = 1'b0;
    if(when_UsbOhci_l526) begin
      if(frame_overflow) begin
        frame_reload = 1'b1;
      end
    end
    if(when_StateMachine_l238_7) begin
      frame_reload = 1'b1;
    end
  end

  assign frame_overflow = (reg_hcFmRemaining_FR == 14'h0);
  always @(*) begin
    frame_tick = 1'b0;
    if(when_UsbOhci_l526) begin
      if(frame_overflow) begin
        frame_tick = 1'b1;
      end
    end
  end

  assign frame_section1 = (reg_hcPeriodicStart_PS < reg_hcFmRemaining_FR);
  assign frame_limitHit = (frame_limitCounter == 15'h0);
  assign frame_decrementTimerOverflow = (frame_decrementTimer == 3'b110);
  assign when_UsbOhci_l526 = (frame_run && io_phy_tick);
  assign when_UsbOhci_l528 = ((! frame_limitHit) && (! frame_decrementTimerOverflow));
  assign when_UsbOhci_l540 = (reg_hcFmNumber_FNp1[15] ^ reg_hcFmNumber_FN[15]);
  always @(*) begin
    token_wantExit = 1'b0;
    case(token_stateReg)
      UsbOhciWishbone_token_enumDef_INIT : begin
      end
      UsbOhciWishbone_token_enumDef_PID : begin
      end
      UsbOhciWishbone_token_enumDef_B1 : begin
      end
      UsbOhciWishbone_token_enumDef_B2 : begin
      end
      UsbOhciWishbone_token_enumDef_EOP : begin
        if(io_phy_txEop) begin
          token_wantExit = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    token_wantStart = 1'b0;
    if(when_StateMachine_l222_1) begin
      token_wantStart = 1'b1;
    end
    if(when_StateMachine_l238_1) begin
      token_wantStart = 1'b1;
    end
  end

  always @(*) begin
    token_wantKill = 1'b0;
    if(unscheduleAll_fire) begin
      token_wantKill = 1'b1;
    end
  end

  always @(*) begin
    token_pid = 4'bxxxx;
    case(sof_stateReg)
      UsbOhciWishbone_sof_enumDef_FRAME_TX : begin
        token_pid = 4'b0101;
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD : begin
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
        case(endpoint_tockenType)
          2'b00 : begin
            token_pid = 4'b1101;
          end
          2'b01 : begin
            token_pid = 4'b0001;
          end
          2'b10 : begin
            token_pid = 4'b1001;
          end
          default : begin
          end
        endcase
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    token_data = 11'bxxxxxxxxxxx;
    case(sof_stateReg)
      UsbOhciWishbone_sof_enumDef_FRAME_TX : begin
        token_data = _zz_token_data[10:0];
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD : begin
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP : begin
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
        token_data = {endpoint_ED_EN,endpoint_ED_FA};
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    token_crc5_io_flush = 1'b0;
    if(when_StateMachine_l222) begin
      token_crc5_io_flush = 1'b1;
    end
  end

  always @(*) begin
    token_crc5_io_input_valid = 1'b0;
    case(token_stateReg)
      UsbOhciWishbone_token_enumDef_INIT : begin
        token_crc5_io_input_valid = 1'b1;
      end
      UsbOhciWishbone_token_enumDef_PID : begin
      end
      UsbOhciWishbone_token_enumDef_B1 : begin
      end
      UsbOhciWishbone_token_enumDef_B2 : begin
      end
      UsbOhciWishbone_token_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataTx_wantExit = 1'b0;
    case(dataTx_stateReg)
      UsbOhciWishbone_dataTx_enumDef_PID : begin
      end
      UsbOhciWishbone_dataTx_enumDef_DATA : begin
      end
      UsbOhciWishbone_dataTx_enumDef_CRC_0 : begin
      end
      UsbOhciWishbone_dataTx_enumDef_CRC_1 : begin
      end
      UsbOhciWishbone_dataTx_enumDef_EOP : begin
        if(io_phy_txEop) begin
          dataTx_wantExit = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataTx_wantStart = 1'b0;
    if(when_StateMachine_l238_2) begin
      dataTx_wantStart = 1'b1;
    end
  end

  always @(*) begin
    dataTx_wantKill = 1'b0;
    if(unscheduleAll_fire_1) begin
      dataTx_wantKill = 1'b1;
    end
  end

  always @(*) begin
    dataTx_pid = 4'bxxxx;
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
        dataTx_pid = {endpoint_dataPhase,3'b011};
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataTx_data_valid = 1'b0;
    case(endpoint_dmaLogic_stateReg)
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : begin
        dataTx_data_valid = 1'b1;
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataTx_data_payload_last = 1'bx;
    case(endpoint_dmaLogic_stateReg)
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : begin
        dataTx_data_payload_last = endpoint_dmaLogic_byteCtx_last;
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataTx_data_payload_fragment = 8'bxxxxxxxx;
    case(endpoint_dmaLogic_stateReg)
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : begin
        dataTx_data_payload_fragment = _zz_dataTx_data_payload_fragment;
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dataTx_data_ready = 1'b0;
    case(dataTx_stateReg)
      UsbOhciWishbone_dataTx_enumDef_PID : begin
      end
      UsbOhciWishbone_dataTx_enumDef_DATA : begin
        if(io_phy_tx_ready) begin
          dataTx_data_ready = 1'b1;
        end
      end
      UsbOhciWishbone_dataTx_enumDef_CRC_0 : begin
      end
      UsbOhciWishbone_dataTx_enumDef_CRC_1 : begin
      end
      UsbOhciWishbone_dataTx_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
  end

  assign dataTx_data_fire = (dataTx_data_valid && dataTx_data_ready);
  always @(*) begin
    dataTx_crc16_io_flush = 1'b0;
    case(dataTx_stateReg)
      UsbOhciWishbone_dataTx_enumDef_PID : begin
        dataTx_crc16_io_flush = 1'b1;
      end
      UsbOhciWishbone_dataTx_enumDef_DATA : begin
      end
      UsbOhciWishbone_dataTx_enumDef_CRC_0 : begin
      end
      UsbOhciWishbone_dataTx_enumDef_CRC_1 : begin
      end
      UsbOhciWishbone_dataTx_enumDef_EOP : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    rxTimer_clear = 1'b0;
    if(io_phy_rx_active) begin
      rxTimer_clear = 1'b1;
    end
    if(when_StateMachine_l238) begin
      rxTimer_clear = 1'b1;
    end
    if(when_StateMachine_l238_4) begin
      rxTimer_clear = 1'b1;
    end
  end

  assign rxTimer_rxTimeout = (rxTimer_counter == (rxTimer_lowSpeed ? 8'hbf : 8'h17));
  assign rxTimer_ackTx = (rxTimer_counter == _zz_rxTimer_ackTx);
  assign rxPidOk = (io_phy_rx_flow_payload_data[3 : 0] == (~ io_phy_rx_flow_payload_data[7 : 4]));
  assign _zz_1 = io_phy_rx_flow_valid;
  assign _zz_dataRx_pid = io_phy_rx_flow_payload_data;
  assign when_Misc_l87 = (io_phy_rx_flow_valid && io_phy_rx_flow_payload_stuffingError);
  always @(*) begin
    dataRx_wantExit = 1'b0;
    case(dataRx_stateReg)
      UsbOhciWishbone_dataRx_enumDef_IDLE : begin
        if(!io_phy_rx_active) begin
          if(rxTimer_rxTimeout) begin
            dataRx_wantExit = 1'b1;
          end
        end
      end
      UsbOhciWishbone_dataRx_enumDef_PID : begin
        if(!_zz_1) begin
          if(when_Misc_l64) begin
            dataRx_wantExit = 1'b1;
          end
        end
      end
      UsbOhciWishbone_dataRx_enumDef_DATA : begin
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
    if(when_StateMachine_l238_3) begin
      dataRx_wantStart = 1'b1;
    end
  end

  always @(*) begin
    dataRx_wantKill = 1'b0;
    if(unscheduleAll_fire_2) begin
      dataRx_wantKill = 1'b1;
    end
  end

  assign dataRx_history_0 = _zz_dataRx_history_0;
  assign dataRx_history_1 = _zz_dataRx_history_1;
  assign dataRx_hasError = ({dataRx_crcError,{dataRx_pidError,{dataRx_stuffingError,dataRx_notResponding}}} != 4'b0000);
  always @(*) begin
    dataRx_data_valid = 1'b0;
    case(dataRx_stateReg)
      UsbOhciWishbone_dataRx_enumDef_IDLE : begin
      end
      UsbOhciWishbone_dataRx_enumDef_PID : begin
      end
      UsbOhciWishbone_dataRx_enumDef_DATA : begin
        if(!when_Misc_l70) begin
          if(_zz_1) begin
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
      UsbOhciWishbone_dataRx_enumDef_IDLE : begin
      end
      UsbOhciWishbone_dataRx_enumDef_PID : begin
      end
      UsbOhciWishbone_dataRx_enumDef_DATA : begin
        if(!when_Misc_l70) begin
          if(_zz_1) begin
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
      UsbOhciWishbone_dataRx_enumDef_IDLE : begin
      end
      UsbOhciWishbone_dataRx_enumDef_PID : begin
        dataRx_crc16_io_flush = 1'b1;
      end
      UsbOhciWishbone_dataRx_enumDef_DATA : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    sof_wantExit = 1'b0;
    case(sof_stateReg)
      UsbOhciWishbone_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD : begin
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP : begin
        if(ioDma_rsp_valid) begin
          sof_wantExit = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    sof_wantStart = 1'b0;
    if(when_StateMachine_l238_6) begin
      sof_wantStart = 1'b1;
    end
  end

  always @(*) begin
    sof_wantKill = 1'b0;
    if(unscheduleAll_fire_3) begin
      sof_wantKill = 1'b1;
    end
  end

  always @(*) begin
    priority_tick = 1'b0;
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
        if(dmaCtx_pendingEmpty) begin
          if(when_UsbOhci_l1418) begin
            priority_tick = 1'b1;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    priority_skip = 1'b0;
    if(priority_tick) begin
      if(when_UsbOhci_l663) begin
        priority_skip = 1'b1;
      end
    end
    case(operational_stateReg)
      UsbOhciWishbone_operational_enumDef_SOF : begin
      end
      UsbOhciWishbone_operational_enumDef_ARBITER : begin
        if(!operational_askExit) begin
          if(!frame_limitHit) begin
            if(!when_UsbOhci_l1487) begin
              priority_skip = 1'b1;
              if(priority_bulk) begin
                if(operational_allowBulk) begin
                  if(reg_hcBulkCurrentED_isZero) begin
                    if(reg_hcCommandStatus_BLF) begin
                      priority_skip = 1'b0;
                    end
                  end else begin
                    priority_skip = 1'b0;
                  end
                end
              end else begin
                if(operational_allowControl) begin
                  if(reg_hcControlCurrentED_isZero) begin
                    if(reg_hcCommandStatus_CLF) begin
                      priority_skip = 1'b0;
                    end
                  end else begin
                    priority_skip = 1'b0;
                  end
                end
              end
            end
          end
        end
      end
      UsbOhciWishbone_operational_enumDef_END_POINT : begin
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_CMD : begin
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_RSP : begin
      end
      UsbOhciWishbone_operational_enumDef_WAIT_SOF : begin
      end
      default : begin
      end
    endcase
  end

  assign when_UsbOhci_l663 = (priority_bulk || (priority_counter == reg_hcControl_CBSR));
  always @(*) begin
    interruptDelay_tick = 1'b0;
    case(sof_stateReg)
      UsbOhciWishbone_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD : begin
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP : begin
        if(ioDma_rsp_valid) begin
          interruptDelay_tick = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign interruptDelay_done = (interruptDelay_counter == 3'b000);
  assign interruptDelay_disabled = (interruptDelay_counter == 3'b111);
  always @(*) begin
    interruptDelay_disable = 1'b0;
    case(sof_stateReg)
      UsbOhciWishbone_sof_enumDef_FRAME_TX : begin
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD : begin
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP : begin
        if(ioDma_rsp_valid) begin
          if(sof_doInterruptDelay) begin
            interruptDelay_disable = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l222_3) begin
      interruptDelay_disable = 1'b1;
    end
  end

  always @(*) begin
    interruptDelay_load_valid = 1'b0;
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
        if(dmaCtx_pendingEmpty) begin
          if(endpoint_TD_retire) begin
            interruptDelay_load_valid = 1'b1;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    interruptDelay_load_payload = 3'bxxx;
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
        if(dmaCtx_pendingEmpty) begin
          if(endpoint_TD_retire) begin
            interruptDelay_load_payload = endpoint_TD_DI;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  assign when_UsbOhci_l685 = ((interruptDelay_tick && (! interruptDelay_done)) && (! interruptDelay_disabled));
  assign when_UsbOhci_l689 = (interruptDelay_load_valid && (interruptDelay_load_payload < interruptDelay_counter));
  always @(*) begin
    endpoint_wantExit = 1'b0;
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
        if(when_UsbOhci_l861) begin
          endpoint_wantExit = 1'b1;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
        if(dmaCtx_pendingEmpty) begin
          endpoint_wantExit = 1'b1;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
        endpoint_wantExit = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    endpoint_wantStart = 1'b0;
    case(operational_stateReg)
      UsbOhciWishbone_operational_enumDef_SOF : begin
      end
      UsbOhciWishbone_operational_enumDef_ARBITER : begin
        if(!operational_askExit) begin
          if(!frame_limitHit) begin
            if(when_UsbOhci_l1487) begin
              if(!when_UsbOhci_l1488) begin
                if(!reg_hcPeriodCurrentED_isZero) begin
                  endpoint_wantStart = 1'b1;
                end
              end
            end else begin
              if(priority_bulk) begin
                if(operational_allowBulk) begin
                  if(!reg_hcBulkCurrentED_isZero) begin
                    endpoint_wantStart = 1'b1;
                  end
                end
              end else begin
                if(operational_allowControl) begin
                  if(!reg_hcControlCurrentED_isZero) begin
                    endpoint_wantStart = 1'b1;
                  end
                end
              end
            end
          end
        end
      end
      UsbOhciWishbone_operational_enumDef_END_POINT : begin
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_CMD : begin
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_RSP : begin
      end
      UsbOhciWishbone_operational_enumDef_WAIT_SOF : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    endpoint_wantKill = 1'b0;
    if(unscheduleAll_fire_4) begin
      endpoint_wantKill = 1'b1;
    end
  end

  assign endpoint_ED_FA = endpoint_ED_words_0[6 : 0];
  assign endpoint_ED_EN = endpoint_ED_words_0[10 : 7];
  assign endpoint_ED_D = endpoint_ED_words_0[12 : 11];
  assign endpoint_ED_S = endpoint_ED_words_0[13];
  assign endpoint_ED_K = endpoint_ED_words_0[14];
  assign endpoint_ED_F = endpoint_ED_words_0[15];
  assign endpoint_ED_MPS = endpoint_ED_words_0[26 : 16];
  assign endpoint_ED_tailP = endpoint_ED_words_1[31 : 4];
  assign endpoint_ED_H = endpoint_ED_words_2[0];
  assign endpoint_ED_C = endpoint_ED_words_2[1];
  assign endpoint_ED_headP = endpoint_ED_words_2[31 : 4];
  assign endpoint_ED_nextED = endpoint_ED_words_3[31 : 4];
  assign endpoint_ED_tdEmpty = (endpoint_ED_tailP == endpoint_ED_headP);
  assign endpoint_ED_isFs = (! endpoint_ED_S);
  assign endpoint_ED_isoOut = endpoint_ED_D[0];
  assign when_UsbOhci_l750 = (! (endpoint_stateReg == UsbOhciWishbone_endpoint_enumDef_BOOT));
  assign rxTimer_lowSpeed = endpoint_ED_S;
  assign endpoint_TD_address = ({4'd0,endpoint_ED_headP} <<< 4);
  assign endpoint_TD_CC = endpoint_TD_words_0[31 : 28];
  assign endpoint_TD_EC = endpoint_TD_words_0[27 : 26];
  assign endpoint_TD_T = endpoint_TD_words_0[25 : 24];
  assign endpoint_TD_DI = endpoint_TD_words_0[23 : 21];
  assign endpoint_TD_DP = endpoint_TD_words_0[20 : 19];
  assign endpoint_TD_R = endpoint_TD_words_0[18];
  assign endpoint_TD_CBP = endpoint_TD_words_1[31 : 0];
  assign endpoint_TD_nextTD = endpoint_TD_words_2[31 : 4];
  assign endpoint_TD_BE = endpoint_TD_words_3[31 : 0];
  assign endpoint_TD_FC = endpoint_TD_words_0[26 : 24];
  assign endpoint_TD_SF = endpoint_TD_words_0[15 : 0];
  assign endpoint_TD_isoRelativeFrameNumber = (reg_hcFmNumber_FN - endpoint_TD_SF);
  assign endpoint_TD_tooEarly = endpoint_TD_isoRelativeFrameNumber[15];
  assign endpoint_TD_isoFrameNumber = endpoint_TD_isoRelativeFrameNumber[2 : 0];
  assign endpoint_TD_isoOverrun = ((! endpoint_TD_tooEarly) && (_zz_endpoint_TD_isoOverrun < endpoint_TD_isoRelativeFrameNumber));
  assign endpoint_TD_isoLast = (((! endpoint_TD_isoOverrun) && (! endpoint_TD_tooEarly)) && (endpoint_TD_isoFrameNumber == endpoint_TD_FC));
  assign endpoint_TD_isSinglePage = (endpoint_TD_CBP[31 : 12] == endpoint_TD_BE[31 : 12]);
  assign endpoint_TD_firstOffset = (endpoint_ED_F ? endpoint_TD_isoBase : _zz_endpoint_TD_firstOffset);
  assign endpoint_TD_allowRounding = ((! endpoint_ED_F) && endpoint_TD_R);
  assign endpoint_TD_TNext = (endpoint_TD_dataPhaseUpdate ? {1'b1,(! endpoint_dataPhase)} : endpoint_TD_T);
  assign endpoint_TD_dataPhaseNext = (endpoint_dataPhase ^ endpoint_TD_dataPhaseUpdate);
  assign endpoint_TD_dataPid = (endpoint_dataPhase ? 4'b1011 : 4'b0011);
  assign endpoint_TD_dataPidWrong = (endpoint_dataPhase ? 4'b0011 : 4'b1011);
  always @(*) begin
    endpoint_TD_clear = 1'b0;
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
        endpoint_TD_clear = 1'b1;
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  assign endpoint_tockenType = ((endpoint_ED_D[0] != endpoint_ED_D[1]) ? endpoint_ED_D : endpoint_TD_DP);
  assign endpoint_isIn = (endpoint_tockenType == 2'b10);
  always @(*) begin
    endpoint_applyNextED = 1'b0;
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
        if(when_UsbOhci_l861) begin
          endpoint_applyNextED = 1'b1;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
        if(dmaCtx_pendingEmpty) begin
          if(when_UsbOhci_l1415) begin
            endpoint_applyNextED = 1'b1;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  assign endpoint_currentAddressFull = {(endpoint_currentAddress[12] ? endpoint_TD_BE[31 : 12] : endpoint_TD_CBP[31 : 12]),endpoint_currentAddress[11 : 0]};
  assign _zz_3 = zz__zz_endpoint_currentAddressBmb(1'b0);
  always @(*) _zz_endpoint_currentAddressBmb = _zz_3;
  assign endpoint_currentAddressBmb = (endpoint_currentAddressFull & _zz_endpoint_currentAddressBmb);
  assign endpoint_transactionSizeMinusOne = (_zz_endpoint_transactionSizeMinusOne - endpoint_currentAddress);
  assign endpoint_transactionSize = (endpoint_transactionSizeMinusOne + 14'h0001);
  assign endpoint_dataDone = (endpoint_zeroLength || (_zz_endpoint_dataDone < endpoint_currentAddress));
  always @(*) begin
    endpoint_dmaLogic_wantExit = 1'b0;
    case(endpoint_dmaLogic_stateReg)
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : begin
        if(dataTx_data_ready) begin
          if(endpoint_dmaLogic_byteCtx_last) begin
            endpoint_dmaLogic_wantExit = 1'b1;
          end
        end
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : begin
        if(when_UsbOhci_l1068) begin
          endpoint_dmaLogic_wantExit = 1'b1;
        end
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : begin
        if(endpoint_dataDone) begin
          if(endpoint_isIn) begin
            endpoint_dmaLogic_wantExit = 1'b1;
          end
        end
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    endpoint_dmaLogic_wantStart = 1'b0;
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
        if(!endpoint_timeCheck) begin
          if(!when_UsbOhci_l1118) begin
            endpoint_dmaLogic_wantStart = 1'b1;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l238_3) begin
      endpoint_dmaLogic_wantStart = 1'b1;
    end
  end

  always @(*) begin
    endpoint_dmaLogic_wantKill = 1'b0;
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
        if(when_UsbOhci_l1128) begin
          if(endpoint_timeCheck) begin
            endpoint_dmaLogic_wantKill = 1'b1;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    if(unscheduleAll_fire_5) begin
      endpoint_dmaLogic_wantKill = 1'b1;
    end
  end

  always @(*) begin
    endpoint_dmaLogic_validated = 1'b0;
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
        endpoint_dmaLogic_validated = 1'b1;
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
  end

  assign endpoint_dmaLogic_lengthMax = (~ _zz_endpoint_dmaLogic_lengthMax);
  assign endpoint_dmaLogic_lengthCalc = _zz_endpoint_dmaLogic_lengthCalc[5:0];
  assign endpoint_dmaLogic_beatCount = _zz_endpoint_dmaLogic_beatCount[6 : 2];
  assign endpoint_dmaLogic_lengthBmb = _zz_endpoint_dmaLogic_lengthBmb[5:0];
  assign endpoint_dmaLogic_underflowError = (endpoint_dmaLogic_underflow && (! endpoint_TD_allowRounding));
  assign when_UsbOhci_l938 = (((! (endpoint_dmaLogic_stateReg == UsbOhciWishbone_endpoint_dmaLogic_enumDef_BOOT)) && (! endpoint_isIn)) && ioDma_rsp_valid);
  assign endpoint_dmaLogic_byteCtx_last = (endpoint_dmaLogic_byteCtx_counter == endpoint_lastAddress);
  assign endpoint_dmaLogic_byteCtx_sel = endpoint_dmaLogic_byteCtx_counter[1:0];
  always @(*) begin
    endpoint_dmaLogic_byteCtx_increment = 1'b0;
    case(endpoint_dmaLogic_stateReg)
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : begin
        if(dataTx_data_ready) begin
          endpoint_dmaLogic_byteCtx_increment = 1'b1;
        end
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : begin
        if(dataRx_data_valid) begin
          endpoint_dmaLogic_byteCtx_increment = 1'b1;
        end
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
      end
      default : begin
      end
    endcase
  end

  assign endpoint_dmaLogic_headMask = {(endpoint_currentAddress[1 : 0] <= 2'b11),{(endpoint_currentAddress[1 : 0] <= 2'b10),{(endpoint_currentAddress[1 : 0] <= 2'b01),(endpoint_currentAddress[1 : 0] <= 2'b00)}}};
  assign endpoint_dmaLogic_lastMask = {(2'b11 <= _zz_endpoint_dmaLogic_lastMask[1 : 0]),{(2'b10 <= _zz_endpoint_dmaLogic_lastMask_2[1 : 0]),{(2'b01 <= _zz_endpoint_dmaLogic_lastMask_4[1 : 0]),(2'b00 <= _zz_endpoint_dmaLogic_lastMask_6[1 : 0])}}};
  assign endpoint_dmaLogic_fullMask = 4'b1111;
  assign endpoint_dmaLogic_beatLast = (dmaCtx_beatCounter == _zz_endpoint_dmaLogic_beatLast);
  assign endpoint_byteCountCalc = (_zz_endpoint_byteCountCalc + 14'h0001);
  assign endpoint_fsTimeCheck = (endpoint_zeroLength ? (frame_limitCounter == 15'h0) : (_zz_endpoint_fsTimeCheck <= _zz_endpoint_fsTimeCheck_1));
  assign endpoint_timeCheck = ((endpoint_ED_isFs && endpoint_fsTimeCheck) || (endpoint_ED_S && reg_hcLSThreshold_hit));
  assign endpoint_tdUpdateAddress = ((endpoint_TD_retire && (! ((endpoint_isIn && ((endpoint_TD_CC == 4'b0000) || (endpoint_TD_CC == 4'b1001))) && endpoint_dmaLogic_underflow))) ? 32'h0 : endpoint_currentAddressFull);
  always @(*) begin
    operational_wantExit = 1'b0;
    case(operational_stateReg)
      UsbOhciWishbone_operational_enumDef_SOF : begin
      end
      UsbOhciWishbone_operational_enumDef_ARBITER : begin
        if(operational_askExit) begin
          operational_wantExit = 1'b1;
        end
      end
      UsbOhciWishbone_operational_enumDef_END_POINT : begin
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_CMD : begin
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_RSP : begin
      end
      UsbOhciWishbone_operational_enumDef_WAIT_SOF : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    operational_wantStart = 1'b0;
    if(when_StateMachine_l238_7) begin
      operational_wantStart = 1'b1;
    end
  end

  always @(*) begin
    operational_wantKill = 1'b0;
    if(unscheduleAll_fire_6) begin
      operational_wantKill = 1'b1;
    end
  end

  always @(*) begin
    operational_askExit = 1'b0;
    case(hc_stateReg)
      UsbOhciWishbone_hc_enumDef_RESET : begin
      end
      UsbOhciWishbone_hc_enumDef_RESUME : begin
      end
      UsbOhciWishbone_hc_enumDef_OPERATIONAL : begin
      end
      UsbOhciWishbone_hc_enumDef_SUSPEND : begin
      end
      UsbOhciWishbone_hc_enumDef_ANY_TO_RESET : begin
      end
      UsbOhciWishbone_hc_enumDef_ANY_TO_SUSPEND : begin
        operational_askExit = 1'b1;
      end
      default : begin
      end
    endcase
  end

  assign hc_wantExit = 1'b0;
  always @(*) begin
    hc_wantStart = 1'b0;
    case(hc_stateReg)
      UsbOhciWishbone_hc_enumDef_RESET : begin
      end
      UsbOhciWishbone_hc_enumDef_RESUME : begin
      end
      UsbOhciWishbone_hc_enumDef_OPERATIONAL : begin
      end
      UsbOhciWishbone_hc_enumDef_SUSPEND : begin
      end
      UsbOhciWishbone_hc_enumDef_ANY_TO_RESET : begin
      end
      UsbOhciWishbone_hc_enumDef_ANY_TO_SUSPEND : begin
      end
      default : begin
        hc_wantStart = 1'b1;
      end
    endcase
  end

  assign hc_wantKill = 1'b0;
  always @(*) begin
    reg_hcControl_HCFS = UsbOhciWishbone_MainState_RESET;
    case(hc_stateReg)
      UsbOhciWishbone_hc_enumDef_RESET : begin
      end
      UsbOhciWishbone_hc_enumDef_RESUME : begin
        reg_hcControl_HCFS = UsbOhciWishbone_MainState_RESUME;
      end
      UsbOhciWishbone_hc_enumDef_OPERATIONAL : begin
        reg_hcControl_HCFS = UsbOhciWishbone_MainState_OPERATIONAL;
      end
      UsbOhciWishbone_hc_enumDef_SUSPEND : begin
        reg_hcControl_HCFS = UsbOhciWishbone_MainState_SUSPEND;
      end
      UsbOhciWishbone_hc_enumDef_ANY_TO_RESET : begin
        reg_hcControl_HCFS = UsbOhciWishbone_MainState_RESET;
      end
      UsbOhciWishbone_hc_enumDef_ANY_TO_SUSPEND : begin
        reg_hcControl_HCFS = UsbOhciWishbone_MainState_SUSPEND;
      end
      default : begin
      end
    endcase
  end

  assign io_phy_usbReset = (reg_hcControl_HCFS == UsbOhciWishbone_MainState_RESET);
  assign io_phy_usbResume = (reg_hcControl_HCFS == UsbOhciWishbone_MainState_RESUME);
  always @(*) begin
    hc_error = 1'b0;
    case(hc_stateReg)
      UsbOhciWishbone_hc_enumDef_RESET : begin
        if(reg_hcControl_HCFSWrite_valid) begin
          case(reg_hcControl_HCFSWrite_payload)
            UsbOhciWishbone_MainState_OPERATIONAL : begin
            end
            default : begin
              hc_error = 1'b1;
            end
          endcase
        end
      end
      UsbOhciWishbone_hc_enumDef_RESUME : begin
      end
      UsbOhciWishbone_hc_enumDef_OPERATIONAL : begin
      end
      UsbOhciWishbone_hc_enumDef_SUSPEND : begin
      end
      UsbOhciWishbone_hc_enumDef_ANY_TO_RESET : begin
      end
      UsbOhciWishbone_hc_enumDef_ANY_TO_SUSPEND : begin
      end
      default : begin
      end
    endcase
  end

  assign _zz_reg_hcControl_HCFSWrite_payload = io_ctrl_cmd_payload_fragment_data[7 : 6];
  assign reg_hcControl_HCFSWrite_payload = _zz_reg_hcControl_HCFSWrite_payload;
  assign when_BusSlaveFactory_l942 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l942_1 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l942_2 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l942_3 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l942_4 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l942_5 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l942_6 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l942_7 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l942_8 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l942_9 = io_ctrl_cmd_payload_fragment_mask[2];
  assign when_BusSlaveFactory_l942_10 = io_ctrl_cmd_payload_fragment_mask[3];
  assign when_BusSlaveFactory_l942_11 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l942_12 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l942_13 = io_ctrl_cmd_payload_fragment_mask[2];
  assign when_BusSlaveFactory_l942_14 = io_ctrl_cmd_payload_fragment_mask[3];
  assign when_BusSlaveFactory_l942_15 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l942_16 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l942_17 = io_ctrl_cmd_payload_fragment_mask[2];
  assign when_BusSlaveFactory_l942_18 = io_ctrl_cmd_payload_fragment_mask[3];
  assign when_BusSlaveFactory_l942_19 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l942_20 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l942_21 = io_ctrl_cmd_payload_fragment_mask[2];
  assign when_BusSlaveFactory_l942_22 = io_ctrl_cmd_payload_fragment_mask[3];
  assign when_BusSlaveFactory_l942_23 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l942_24 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l942_25 = io_ctrl_cmd_payload_fragment_mask[2];
  assign when_BusSlaveFactory_l942_26 = io_ctrl_cmd_payload_fragment_mask[3];
  assign when_BusSlaveFactory_l942_27 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l942_28 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l942_29 = io_ctrl_cmd_payload_fragment_mask[2];
  assign when_BusSlaveFactory_l942_30 = io_ctrl_cmd_payload_fragment_mask[3];
  assign when_BusSlaveFactory_l942_31 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l942_32 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l942_33 = io_ctrl_cmd_payload_fragment_mask[2];
  assign when_BusSlaveFactory_l942_34 = io_ctrl_cmd_payload_fragment_mask[3];
  assign when_BusSlaveFactory_l942_35 = io_ctrl_cmd_payload_fragment_mask[3];
  assign when_BusSlaveFactory_l942_36 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l942_37 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l942_38 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l942_39 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l942_40 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l942_41 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l942_42 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l942_43 = io_ctrl_cmd_payload_fragment_mask[1];
  assign when_BusSlaveFactory_l942_44 = io_ctrl_cmd_payload_fragment_mask[3];
  assign when_BusSlaveFactory_l942_45 = io_ctrl_cmd_payload_fragment_mask[0];
  assign when_BusSlaveFactory_l942_46 = io_ctrl_cmd_payload_fragment_mask[2];
  assign when_UsbOhci_l253 = (doSoftReset || _zz_when_UsbOhci_l253);
  always @(*) begin
    token_stateNext = token_stateReg;
    case(token_stateReg)
      UsbOhciWishbone_token_enumDef_INIT : begin
        token_stateNext = UsbOhciWishbone_token_enumDef_PID;
      end
      UsbOhciWishbone_token_enumDef_PID : begin
        if(io_phy_tx_ready) begin
          token_stateNext = UsbOhciWishbone_token_enumDef_B1;
        end
      end
      UsbOhciWishbone_token_enumDef_B1 : begin
        if(io_phy_tx_ready) begin
          token_stateNext = UsbOhciWishbone_token_enumDef_B2;
        end
      end
      UsbOhciWishbone_token_enumDef_B2 : begin
        if(io_phy_tx_ready) begin
          token_stateNext = UsbOhciWishbone_token_enumDef_EOP;
        end
      end
      UsbOhciWishbone_token_enumDef_EOP : begin
        if(io_phy_txEop) begin
          token_stateNext = UsbOhciWishbone_token_enumDef_BOOT;
        end
      end
      default : begin
      end
    endcase
    if(token_wantStart) begin
      token_stateNext = UsbOhciWishbone_token_enumDef_INIT;
    end
    if(token_wantKill) begin
      token_stateNext = UsbOhciWishbone_token_enumDef_BOOT;
    end
  end

  assign when_StateMachine_l222 = ((token_stateReg == UsbOhciWishbone_token_enumDef_BOOT) && (! (token_stateNext == UsbOhciWishbone_token_enumDef_BOOT)));
  assign unscheduleAll_fire = (unscheduleAll_valid && unscheduleAll_ready);
  always @(*) begin
    dataTx_stateNext = dataTx_stateReg;
    case(dataTx_stateReg)
      UsbOhciWishbone_dataTx_enumDef_PID : begin
        if(io_phy_tx_ready) begin
          if(dataTx_data_valid) begin
            dataTx_stateNext = UsbOhciWishbone_dataTx_enumDef_DATA;
          end else begin
            dataTx_stateNext = UsbOhciWishbone_dataTx_enumDef_CRC_0;
          end
        end
      end
      UsbOhciWishbone_dataTx_enumDef_DATA : begin
        if(io_phy_tx_ready) begin
          if(dataTx_data_payload_last) begin
            dataTx_stateNext = UsbOhciWishbone_dataTx_enumDef_CRC_0;
          end
        end
      end
      UsbOhciWishbone_dataTx_enumDef_CRC_0 : begin
        if(io_phy_tx_ready) begin
          dataTx_stateNext = UsbOhciWishbone_dataTx_enumDef_CRC_1;
        end
      end
      UsbOhciWishbone_dataTx_enumDef_CRC_1 : begin
        if(io_phy_tx_ready) begin
          dataTx_stateNext = UsbOhciWishbone_dataTx_enumDef_EOP;
        end
      end
      UsbOhciWishbone_dataTx_enumDef_EOP : begin
        if(io_phy_txEop) begin
          dataTx_stateNext = UsbOhciWishbone_dataTx_enumDef_BOOT;
        end
      end
      default : begin
      end
    endcase
    if(dataTx_wantStart) begin
      dataTx_stateNext = UsbOhciWishbone_dataTx_enumDef_PID;
    end
    if(dataTx_wantKill) begin
      dataTx_stateNext = UsbOhciWishbone_dataTx_enumDef_BOOT;
    end
  end

  assign unscheduleAll_fire_1 = (unscheduleAll_valid && unscheduleAll_ready);
  always @(*) begin
    dataRx_stateNext = dataRx_stateReg;
    case(dataRx_stateReg)
      UsbOhciWishbone_dataRx_enumDef_IDLE : begin
        if(io_phy_rx_active) begin
          dataRx_stateNext = UsbOhciWishbone_dataRx_enumDef_PID;
        end else begin
          if(rxTimer_rxTimeout) begin
            dataRx_stateNext = UsbOhciWishbone_dataRx_enumDef_BOOT;
          end
        end
      end
      UsbOhciWishbone_dataRx_enumDef_PID : begin
        if(_zz_1) begin
          dataRx_stateNext = UsbOhciWishbone_dataRx_enumDef_DATA;
        end else begin
          if(when_Misc_l64) begin
            dataRx_stateNext = UsbOhciWishbone_dataRx_enumDef_BOOT;
          end
        end
      end
      UsbOhciWishbone_dataRx_enumDef_DATA : begin
        if(when_Misc_l70) begin
          dataRx_stateNext = UsbOhciWishbone_dataRx_enumDef_BOOT;
        end
      end
      default : begin
      end
    endcase
    if(dataRx_wantStart) begin
      dataRx_stateNext = UsbOhciWishbone_dataRx_enumDef_IDLE;
    end
    if(dataRx_wantKill) begin
      dataRx_stateNext = UsbOhciWishbone_dataRx_enumDef_BOOT;
    end
  end

  assign when_Misc_l64 = (! io_phy_rx_active);
  assign when_Misc_l70 = (! io_phy_rx_active);
  assign when_Misc_l71 = ((! (&dataRx_valids)) || (dataRx_crc16_io_result != 16'h800d));
  assign when_Misc_l78 = (&dataRx_valids);
  assign when_StateMachine_l238 = ((! (dataRx_stateReg == UsbOhciWishbone_dataRx_enumDef_IDLE)) && (dataRx_stateNext == UsbOhciWishbone_dataRx_enumDef_IDLE));
  assign when_Misc_l85 = (! (dataRx_stateReg == UsbOhciWishbone_dataRx_enumDef_BOOT));
  assign unscheduleAll_fire_2 = (unscheduleAll_valid && unscheduleAll_ready);
  always @(*) begin
    sof_stateNext = sof_stateReg;
    case(sof_stateReg)
      UsbOhciWishbone_sof_enumDef_FRAME_TX : begin
        if(token_wantExit) begin
          sof_stateNext = UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD;
        end
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD : begin
        if(when_UsbOhci_l626) begin
          sof_stateNext = UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP;
        end
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP : begin
        if(ioDma_rsp_valid) begin
          sof_stateNext = UsbOhciWishbone_sof_enumDef_BOOT;
        end
      end
      default : begin
      end
    endcase
    if(sof_wantStart) begin
      sof_stateNext = UsbOhciWishbone_sof_enumDef_FRAME_TX;
    end
    if(sof_wantKill) begin
      sof_stateNext = UsbOhciWishbone_sof_enumDef_BOOT;
    end
  end

  assign when_UsbOhci_l206 = (dmaWriteCtx_counter == 4'b0000);
  assign when_UsbOhci_l206_1 = (dmaWriteCtx_counter == 4'b0001);
  assign when_UsbOhci_l626 = (ioDma_cmd_ready && ioDma_cmd_payload_last);
  assign when_StateMachine_l222_1 = ((sof_stateReg == UsbOhciWishbone_sof_enumDef_BOOT) && (! (sof_stateNext == UsbOhciWishbone_sof_enumDef_BOOT)));
  assign unscheduleAll_fire_3 = (unscheduleAll_valid && unscheduleAll_ready);
  always @(*) begin
    endpoint_stateNext = endpoint_stateReg;
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
        if(ioDma_cmd_ready) begin
          endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
        if(when_UsbOhci_l855) begin
          endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
        if(when_UsbOhci_l861) begin
          endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_BOOT;
        end else begin
          endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
        if(ioDma_cmd_ready) begin
          endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
        if(when_UsbOhci_l898) begin
          endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
        endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE;
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
        endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME;
        if(endpoint_ED_F) begin
          if(endpoint_TD_tooEarlyReg) begin
            endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC;
          end
          if(endpoint_TD_isoOverrunReg) begin
            endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
        if(endpoint_timeCheck) begin
          endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_ABORD;
        end else begin
          if(when_UsbOhci_l1118) begin
            endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_TOKEN;
          end else begin
            endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_BUFFER_READ;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
        if(when_UsbOhci_l1128) begin
          endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_TOKEN;
          if(endpoint_timeCheck) begin
            endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_ABORD;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
        if(token_wantExit) begin
          if(endpoint_isIn) begin
            endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_DATA_RX;
          end else begin
            endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_DATA_TX;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
        if(dataTx_wantExit) begin
          if(endpoint_ED_F) begin
            endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS;
          end else begin
            endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_ACK_RX;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
        if(dataRx_wantExit) begin
          endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
        endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA;
        if(!dataRx_notResponding) begin
          if(!dataRx_stuffingError) begin
            if(!dataRx_pidError) begin
              if(!endpoint_ED_F) begin
                case(dataRx_pid)
                  4'b1010 : begin
                  end
                  4'b1110 : begin
                  end
                  4'b0011, 4'b1011 : begin
                    if(when_UsbOhci_l1263) begin
                      endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_ACK_TX_0;
                    end
                  end
                  default : begin
                  end
                endcase
              end
              if(when_UsbOhci_l1274) begin
                if(!dataRx_crcError) begin
                  if(when_UsbOhci_l1283) begin
                    endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_ACK_TX_0;
                  end
                end
              end
            end
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
        if(when_UsbOhci_l1205) begin
          endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS;
          if(!when_UsbOhci_l1207) begin
            if(!endpoint_ackRxStuffing) begin
              if(!endpoint_ackRxPidFailure) begin
                case(endpoint_ackRxPid)
                  4'b0010 : begin
                  end
                  4'b1010 : begin
                    endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC;
                  end
                  4'b1110 : begin
                  end
                  default : begin
                  end
                endcase
              end
            end
          end
        end
        if(rxTimer_rxTimeout) begin
          endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
        if(rxTimer_ackTx) begin
          endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_ACK_TX_1;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
        if(io_phy_tx_ready) begin
          endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
        if(io_phy_txEop) begin
          endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
        if(when_UsbOhci_l1311) begin
          endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
        endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD;
        if(!endpoint_ED_F) begin
          if(endpoint_TD_noUpdate) begin
            endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
        if(when_UsbOhci_l1393) begin
          endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
        if(when_UsbOhci_l1408) begin
          endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
        if(dmaCtx_pendingEmpty) begin
          endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_BOOT;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
        endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_BOOT;
      end
      default : begin
      end
    endcase
    if(endpoint_wantStart) begin
      endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD;
    end
    if(endpoint_wantKill) begin
      endpoint_stateNext = UsbOhciWishbone_endpoint_enumDef_BOOT;
    end
  end

  assign when_UsbOhci_l188 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0000));
  assign when_UsbOhci_l188_1 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0001));
  assign when_UsbOhci_l188_2 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0010));
  assign when_UsbOhci_l188_3 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0011));
  assign when_UsbOhci_l855 = (ioDma_rsp_valid && ioDma_rsp_payload_last);
  assign when_UsbOhci_l861 = ((endpoint_ED_H || endpoint_ED_K) || endpoint_ED_tdEmpty);
  assign when_UsbOhci_l188_4 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0000));
  assign when_UsbOhci_l188_5 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0001));
  assign when_UsbOhci_l188_6 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0010));
  assign when_UsbOhci_l188_7 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0011));
  assign when_UsbOhci_l891 = (endpoint_TD_isoFrameNumber == 3'b000);
  assign when_UsbOhci_l188_8 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0100));
  assign when_UsbOhci_l188_9 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0100));
  assign when_UsbOhci_l891_1 = (endpoint_TD_isoFrameNumber == 3'b001);
  assign when_UsbOhci_l188_10 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0100));
  assign when_UsbOhci_l188_11 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0101));
  assign when_UsbOhci_l891_2 = (endpoint_TD_isoFrameNumber == 3'b010);
  assign when_UsbOhci_l188_12 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0101));
  assign when_UsbOhci_l188_13 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0101));
  assign when_UsbOhci_l891_3 = (endpoint_TD_isoFrameNumber == 3'b011);
  assign when_UsbOhci_l188_14 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0101));
  assign when_UsbOhci_l188_15 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0110));
  assign when_UsbOhci_l891_4 = (endpoint_TD_isoFrameNumber == 3'b100);
  assign when_UsbOhci_l188_16 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0110));
  assign when_UsbOhci_l188_17 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0110));
  assign when_UsbOhci_l891_5 = (endpoint_TD_isoFrameNumber == 3'b101);
  assign when_UsbOhci_l188_18 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0110));
  assign when_UsbOhci_l188_19 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0111));
  assign when_UsbOhci_l891_6 = (endpoint_TD_isoFrameNumber == 3'b110);
  assign when_UsbOhci_l188_20 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0111));
  assign when_UsbOhci_l188_21 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0111));
  assign when_UsbOhci_l891_7 = (endpoint_TD_isoFrameNumber == 3'b111);
  assign when_UsbOhci_l188_22 = (ioDma_rsp_valid && (dmaReadCtx_counter == 4'b0111));
  assign ioDma_rsp_fire_2 = (ioDma_rsp_valid && ioDma_rsp_ready);
  assign when_UsbOhci_l898 = (ioDma_rsp_fire_2 && ioDma_rsp_payload_last);
  assign _zz_endpoint_lastAddress = (_zz__zz_endpoint_lastAddress - 14'h0001);
  assign when_UsbOhci_l1118 = (endpoint_isIn || endpoint_zeroLength);
  always @(*) begin
    when_UsbOhci_l1274 = 1'b0;
    if(endpoint_ED_F) begin
      case(dataRx_pid)
        4'b1110, 4'b1010 : begin
        end
        4'b0011, 4'b1011 : begin
          when_UsbOhci_l1274 = 1'b1;
        end
        default : begin
        end
      endcase
    end else begin
      case(dataRx_pid)
        4'b1010 : begin
        end
        4'b1110 : begin
        end
        4'b0011, 4'b1011 : begin
          if(!when_UsbOhci_l1263) begin
            when_UsbOhci_l1274 = 1'b1;
          end
        end
        default : begin
        end
      endcase
    end
  end

  assign when_UsbOhci_l1263 = (dataRx_pid == endpoint_TD_dataPidWrong);
  assign when_UsbOhci_l1283 = (! endpoint_ED_F);
  assign when_UsbOhci_l1200 = ((! rxPidOk) || endpoint_ackRxFired);
  assign when_UsbOhci_l1205 = ((! io_phy_rx_active) && endpoint_ackRxActivated);
  assign when_UsbOhci_l1207 = (! endpoint_ackRxFired);
  assign when_UsbOhci_l1331 = ((endpoint_dmaLogic_underflow || (_zz_when_UsbOhci_l1331 < endpoint_currentAddress)) || endpoint_zeroLength);
  assign when_UsbOhci_l1346 = (endpoint_TD_EC != 2'b10);
  assign when_UsbOhci_l206_2 = (dmaWriteCtx_counter == 4'b0000);
  assign when_UsbOhci_l206_3 = (dmaWriteCtx_counter == 4'b0000);
  assign _zz_ioDma_cmd_payload_fragment_data = {endpoint_TD_CC,_zz__zz_ioDma_cmd_payload_fragment_data};
  assign when_UsbOhci_l1378 = (endpoint_TD_isoFrameNumber == 3'b000);
  assign when_UsbOhci_l206_4 = (dmaWriteCtx_counter == 4'b0100);
  assign when_UsbOhci_l1378_1 = (endpoint_TD_isoFrameNumber == 3'b001);
  assign when_UsbOhci_l206_5 = (dmaWriteCtx_counter == 4'b0100);
  assign when_UsbOhci_l1378_2 = (endpoint_TD_isoFrameNumber == 3'b010);
  assign when_UsbOhci_l206_6 = (dmaWriteCtx_counter == 4'b0101);
  assign when_UsbOhci_l1378_3 = (endpoint_TD_isoFrameNumber == 3'b011);
  assign when_UsbOhci_l206_7 = (dmaWriteCtx_counter == 4'b0101);
  assign when_UsbOhci_l1378_4 = (endpoint_TD_isoFrameNumber == 3'b100);
  assign when_UsbOhci_l206_8 = (dmaWriteCtx_counter == 4'b0110);
  assign when_UsbOhci_l1378_5 = (endpoint_TD_isoFrameNumber == 3'b101);
  assign when_UsbOhci_l206_9 = (dmaWriteCtx_counter == 4'b0110);
  assign when_UsbOhci_l1378_6 = (endpoint_TD_isoFrameNumber == 3'b110);
  assign when_UsbOhci_l206_10 = (dmaWriteCtx_counter == 4'b0111);
  assign when_UsbOhci_l1378_7 = (endpoint_TD_isoFrameNumber == 3'b111);
  assign when_UsbOhci_l206_11 = (dmaWriteCtx_counter == 4'b0111);
  assign when_UsbOhci_l206_12 = (dmaWriteCtx_counter == 4'b0000);
  assign when_UsbOhci_l206_13 = (dmaWriteCtx_counter == 4'b0001);
  assign when_UsbOhci_l206_14 = (dmaWriteCtx_counter == 4'b0010);
  assign when_UsbOhci_l1393 = (ioDma_cmd_ready && ioDma_cmd_payload_last);
  assign when_UsbOhci_l206_15 = (dmaWriteCtx_counter == 4'b0010);
  assign when_UsbOhci_l1408 = (ioDma_cmd_ready && ioDma_cmd_payload_last);
  assign when_UsbOhci_l1415 = (! (endpoint_ED_F && endpoint_TD_isoOverrunReg));
  assign when_UsbOhci_l1418 = (endpoint_flowType != UsbOhciWishbone_FlowType_PERIODIC);
  assign when_StateMachine_l222_2 = ((endpoint_stateReg == UsbOhciWishbone_endpoint_enumDef_BOOT) && (! (endpoint_stateNext == UsbOhciWishbone_endpoint_enumDef_BOOT)));
  assign when_StateMachine_l238_1 = ((! (endpoint_stateReg == UsbOhciWishbone_endpoint_enumDef_TOKEN)) && (endpoint_stateNext == UsbOhciWishbone_endpoint_enumDef_TOKEN));
  assign when_StateMachine_l238_2 = ((! (endpoint_stateReg == UsbOhciWishbone_endpoint_enumDef_DATA_TX)) && (endpoint_stateNext == UsbOhciWishbone_endpoint_enumDef_DATA_TX));
  assign when_StateMachine_l238_3 = ((! (endpoint_stateReg == UsbOhciWishbone_endpoint_enumDef_DATA_RX)) && (endpoint_stateNext == UsbOhciWishbone_endpoint_enumDef_DATA_RX));
  assign when_StateMachine_l238_4 = ((! (endpoint_stateReg == UsbOhciWishbone_endpoint_enumDef_ACK_RX)) && (endpoint_stateNext == UsbOhciWishbone_endpoint_enumDef_ACK_RX));
  assign unscheduleAll_fire_4 = (unscheduleAll_valid && unscheduleAll_ready);
  always @(*) begin
    endpoint_dmaLogic_stateNext = endpoint_dmaLogic_stateReg;
    case(endpoint_dmaLogic_stateReg)
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : begin
        if(endpoint_isIn) begin
          endpoint_dmaLogic_stateNext = UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB;
        end else begin
          endpoint_dmaLogic_stateNext = UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD;
        end
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : begin
        if(dataTx_data_ready) begin
          if(endpoint_dmaLogic_byteCtx_last) begin
            endpoint_dmaLogic_stateNext = UsbOhciWishbone_endpoint_dmaLogic_enumDef_BOOT;
          end
        end
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : begin
        if(dataRx_wantExit) begin
          endpoint_dmaLogic_stateNext = UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION;
        end
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : begin
        if(when_UsbOhci_l1068) begin
          endpoint_dmaLogic_stateNext = UsbOhciWishbone_endpoint_dmaLogic_enumDef_BOOT;
        end else begin
          if(endpoint_dmaLogic_validated) begin
            endpoint_dmaLogic_stateNext = UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD;
          end
        end
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : begin
        if(endpoint_dataDone) begin
          if(endpoint_isIn) begin
            endpoint_dmaLogic_stateNext = UsbOhciWishbone_endpoint_dmaLogic_enumDef_BOOT;
          end else begin
            if(dmaCtx_pendingEmpty) begin
              endpoint_dmaLogic_stateNext = UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB;
            end
          end
        end else begin
          if(endpoint_isIn) begin
            endpoint_dmaLogic_stateNext = UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD;
          end else begin
            endpoint_dmaLogic_stateNext = UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD;
          end
        end
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : begin
        if(ioDma_cmd_ready) begin
          endpoint_dmaLogic_stateNext = UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD;
        end
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        if(ioDma_cmd_ready) begin
          if(endpoint_dmaLogic_beatLast) begin
            endpoint_dmaLogic_stateNext = UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD;
          end
        end
      end
      default : begin
      end
    endcase
    if(endpoint_dmaLogic_wantStart) begin
      endpoint_dmaLogic_stateNext = UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT;
    end
    if(endpoint_dmaLogic_wantKill) begin
      endpoint_dmaLogic_stateNext = UsbOhciWishbone_endpoint_dmaLogic_enumDef_BOOT;
    end
  end

  assign when_UsbOhci_l1025 = (&endpoint_dmaLogic_byteCtx_sel);
  assign when_UsbOhci_l1054 = (_zz_when_UsbOhci_l1054 < endpoint_transactionSize);
  assign _zz_2 = ({3'd0,1'b1} <<< endpoint_dmaLogic_byteCtx_sel);
  assign when_UsbOhci_l1063 = (&endpoint_dmaLogic_byteCtx_sel);
  assign when_UsbOhci_l1068 = (endpoint_dmaLogic_fromUsbCounter == 11'h0);
  assign ioDma_cmd_fire_3 = (ioDma_cmd_valid && ioDma_cmd_ready);
  assign when_StateMachine_l238_5 = ((! (endpoint_dmaLogic_stateReg == UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB)) && (endpoint_dmaLogic_stateNext == UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB));
  assign unscheduleAll_fire_5 = (unscheduleAll_valid && unscheduleAll_ready);
  assign endpoint_dmaLogic_fsmStopped = (endpoint_dmaLogic_stateReg == UsbOhciWishbone_endpoint_dmaLogic_enumDef_BOOT);
  assign when_UsbOhci_l1128 = (endpoint_dmaLogic_stateReg == UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB);
  assign when_UsbOhci_l1311 = (endpoint_dmaLogic_stateReg == UsbOhciWishbone_endpoint_dmaLogic_enumDef_BOOT);
  always @(*) begin
    operational_stateNext = operational_stateReg;
    case(operational_stateReg)
      UsbOhciWishbone_operational_enumDef_SOF : begin
        if(sof_wantExit) begin
          operational_stateNext = UsbOhciWishbone_operational_enumDef_ARBITER;
        end
      end
      UsbOhciWishbone_operational_enumDef_ARBITER : begin
        if(operational_askExit) begin
          operational_stateNext = UsbOhciWishbone_operational_enumDef_BOOT;
        end else begin
          if(frame_limitHit) begin
            operational_stateNext = UsbOhciWishbone_operational_enumDef_WAIT_SOF;
          end else begin
            if(when_UsbOhci_l1487) begin
              if(when_UsbOhci_l1488) begin
                operational_stateNext = UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_CMD;
              end else begin
                if(!reg_hcPeriodCurrentED_isZero) begin
                  operational_stateNext = UsbOhciWishbone_operational_enumDef_END_POINT;
                end
              end
            end else begin
              if(priority_bulk) begin
                if(operational_allowBulk) begin
                  if(!reg_hcBulkCurrentED_isZero) begin
                    operational_stateNext = UsbOhciWishbone_operational_enumDef_END_POINT;
                  end
                end
              end else begin
                if(operational_allowControl) begin
                  if(!reg_hcControlCurrentED_isZero) begin
                    operational_stateNext = UsbOhciWishbone_operational_enumDef_END_POINT;
                  end
                end
              end
            end
          end
        end
      end
      UsbOhciWishbone_operational_enumDef_END_POINT : begin
        if(endpoint_wantExit) begin
          case(endpoint_status_1)
            UsbOhciWishbone_endpoint_Status_OK : begin
              operational_stateNext = UsbOhciWishbone_operational_enumDef_ARBITER;
            end
            default : begin
              operational_stateNext = UsbOhciWishbone_operational_enumDef_WAIT_SOF;
            end
          endcase
        end
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_CMD : begin
        if(ioDma_cmd_ready) begin
          operational_stateNext = UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_RSP;
        end
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_RSP : begin
        if(ioDma_rsp_valid) begin
          operational_stateNext = UsbOhciWishbone_operational_enumDef_ARBITER;
        end
      end
      UsbOhciWishbone_operational_enumDef_WAIT_SOF : begin
        if(frame_tick) begin
          operational_stateNext = UsbOhciWishbone_operational_enumDef_SOF;
        end
      end
      default : begin
      end
    endcase
    if(operational_wantStart) begin
      operational_stateNext = UsbOhciWishbone_operational_enumDef_WAIT_SOF;
    end
    if(operational_wantKill) begin
      operational_stateNext = UsbOhciWishbone_operational_enumDef_BOOT;
    end
  end

  assign when_UsbOhci_l1461 = (operational_allowPeriodic && (! operational_periodicDone));
  assign when_UsbOhci_l1488 = (! operational_periodicHeadFetched);
  assign when_UsbOhci_l1487 = ((operational_allowPeriodic && (! operational_periodicDone)) && (! frame_section1));
  assign when_StateMachine_l222_3 = ((operational_stateReg == UsbOhciWishbone_operational_enumDef_BOOT) && (! (operational_stateNext == UsbOhciWishbone_operational_enumDef_BOOT)));
  assign when_StateMachine_l238_6 = ((! (operational_stateReg == UsbOhciWishbone_operational_enumDef_SOF)) && (operational_stateNext == UsbOhciWishbone_operational_enumDef_SOF));
  assign unscheduleAll_fire_6 = (unscheduleAll_valid && unscheduleAll_ready);
  assign hc_operationalIsDone = (operational_stateReg == UsbOhciWishbone_operational_enumDef_BOOT);
  always @(*) begin
    hc_stateNext = hc_stateReg;
    case(hc_stateReg)
      UsbOhciWishbone_hc_enumDef_RESET : begin
        if(reg_hcControl_HCFSWrite_valid) begin
          case(reg_hcControl_HCFSWrite_payload)
            UsbOhciWishbone_MainState_OPERATIONAL : begin
              hc_stateNext = UsbOhciWishbone_hc_enumDef_OPERATIONAL;
            end
            default : begin
            end
          endcase
        end
      end
      UsbOhciWishbone_hc_enumDef_RESUME : begin
        if(when_UsbOhci_l1616) begin
          hc_stateNext = UsbOhciWishbone_hc_enumDef_OPERATIONAL;
        end
      end
      UsbOhciWishbone_hc_enumDef_OPERATIONAL : begin
      end
      UsbOhciWishbone_hc_enumDef_SUSPEND : begin
        if(when_UsbOhci_l1625) begin
          hc_stateNext = UsbOhciWishbone_hc_enumDef_RESUME;
        end else begin
          if(when_UsbOhci_l1628) begin
            hc_stateNext = UsbOhciWishbone_hc_enumDef_OPERATIONAL;
          end
        end
      end
      UsbOhciWishbone_hc_enumDef_ANY_TO_RESET : begin
        if(when_UsbOhci_l1639) begin
          hc_stateNext = UsbOhciWishbone_hc_enumDef_RESET;
        end
      end
      UsbOhciWishbone_hc_enumDef_ANY_TO_SUSPEND : begin
        if(when_UsbOhci_l1652) begin
          hc_stateNext = UsbOhciWishbone_hc_enumDef_SUSPEND;
        end
      end
      default : begin
      end
    endcase
    if(when_UsbOhci_l1659) begin
      hc_stateNext = UsbOhciWishbone_hc_enumDef_ANY_TO_RESET;
    end
    if(reg_hcCommandStatus_startSoftReset) begin
      hc_stateNext = UsbOhciWishbone_hc_enumDef_ANY_TO_SUSPEND;
    end
    if(hc_wantStart) begin
      hc_stateNext = UsbOhciWishbone_hc_enumDef_RESET;
    end
    if(hc_wantKill) begin
      hc_stateNext = UsbOhciWishbone_hc_enumDef_BOOT;
    end
  end

  assign when_UsbOhci_l1616 = (reg_hcControl_HCFSWrite_valid && (reg_hcControl_HCFSWrite_payload == UsbOhciWishbone_MainState_OPERATIONAL));
  assign when_UsbOhci_l1625 = (reg_hcRhStatus_DRWE && ({reg_hcRhPortStatus_1_CSC_reg,reg_hcRhPortStatus_0_CSC_reg} != 2'b00));
  assign when_UsbOhci_l1628 = (reg_hcControl_HCFSWrite_valid && (reg_hcControl_HCFSWrite_payload == UsbOhciWishbone_MainState_OPERATIONAL));
  assign when_UsbOhci_l1639 = (! doUnschedule);
  assign when_UsbOhci_l1652 = (((! doUnschedule) && (! doSoftReset)) && hc_operationalIsDone);
  assign when_StateMachine_l238_7 = ((! (hc_stateReg == UsbOhciWishbone_hc_enumDef_OPERATIONAL)) && (hc_stateNext == UsbOhciWishbone_hc_enumDef_OPERATIONAL));
  assign when_StateMachine_l238_8 = ((! (hc_stateReg == UsbOhciWishbone_hc_enumDef_ANY_TO_RESET)) && (hc_stateNext == UsbOhciWishbone_hc_enumDef_ANY_TO_RESET));
  assign when_StateMachine_l238_9 = ((! (hc_stateReg == UsbOhciWishbone_hc_enumDef_ANY_TO_SUSPEND)) && (hc_stateNext == UsbOhciWishbone_hc_enumDef_ANY_TO_SUSPEND));
  assign when_UsbOhci_l1659 = (reg_hcControl_HCFSWrite_valid && (reg_hcControl_HCFSWrite_payload == UsbOhciWishbone_MainState_RESET));
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      dmaCtx_pendingCounter <= 4'b0000;
      dmaCtx_beatCounter <= 6'h0;
      io_dma_cmd_payload_first <= 1'b1;
      dmaReadCtx_counter <= 4'b0000;
      dmaWriteCtx_counter <= 4'b0000;
      _zz_io_ctrl_rsp_valid_2 <= 1'b0;
      doUnschedule <= 1'b0;
      doSoftReset <= 1'b0;
      reg_hcControl_IR <= 1'b0;
      reg_hcControl_RWC <= 1'b0;
      reg_hcFmNumber_overflow <= 1'b0;
      reg_hcPeriodicStart_PS <= 14'h0;
      io_phy_overcurrent_regNext <= 1'b0;
      reg_hcRhPortStatus_0_connected <= 1'b0;
      reg_hcRhPortStatus_0_CCS_regNext <= 1'b0;
      reg_hcRhPortStatus_1_connected <= 1'b0;
      reg_hcRhPortStatus_1_CCS_regNext <= 1'b0;
      interruptDelay_counter <= 3'b111;
      endpoint_dmaLogic_push <= 1'b0;
      _zz_when_UsbOhci_l253 <= 1'b1;
      token_stateReg <= UsbOhciWishbone_token_enumDef_BOOT;
      dataTx_stateReg <= UsbOhciWishbone_dataTx_enumDef_BOOT;
      dataRx_stateReg <= UsbOhciWishbone_dataRx_enumDef_BOOT;
      sof_stateReg <= UsbOhciWishbone_sof_enumDef_BOOT;
      endpoint_stateReg <= UsbOhciWishbone_endpoint_enumDef_BOOT;
      endpoint_dmaLogic_stateReg <= UsbOhciWishbone_endpoint_dmaLogic_enumDef_BOOT;
      operational_stateReg <= UsbOhciWishbone_operational_enumDef_BOOT;
      hc_stateReg <= UsbOhciWishbone_hc_enumDef_BOOT;
    end else begin
      dmaCtx_pendingCounter <= (_zz_dmaCtx_pendingCounter - _zz_dmaCtx_pendingCounter_3);
      if(ioDma_cmd_fire_1) begin
        dmaCtx_beatCounter <= (dmaCtx_beatCounter + 6'h01);
        if(io_dma_cmd_payload_last) begin
          dmaCtx_beatCounter <= 6'h0;
        end
      end
      if(io_dma_cmd_fire) begin
        io_dma_cmd_payload_first <= io_dma_cmd_payload_last;
      end
      if(ioDma_rsp_fire_1) begin
        dmaReadCtx_counter <= (dmaReadCtx_counter + 4'b0001);
        if(ioDma_rsp_payload_last) begin
          dmaReadCtx_counter <= 4'b0000;
        end
      end
      if(ioDma_cmd_fire_2) begin
        dmaWriteCtx_counter <= (dmaWriteCtx_counter + 4'b0001);
        if(ioDma_cmd_payload_last) begin
          dmaWriteCtx_counter <= 4'b0000;
        end
      end
      if(_zz_ctrl_rsp_ready) begin
        _zz_io_ctrl_rsp_valid_2 <= (ctrl_rsp_valid && _zz_io_ctrl_rsp_valid);
      end
      if(unscheduleAll_ready) begin
        doUnschedule <= 1'b0;
      end
      if(when_UsbOhci_l236) begin
        doSoftReset <= 1'b0;
      end
      io_phy_overcurrent_regNext <= io_phy_overcurrent;
      if(io_phy_ports_0_connect) begin
        reg_hcRhPortStatus_0_connected <= 1'b1;
      end
      if(io_phy_ports_0_disconnect) begin
        reg_hcRhPortStatus_0_connected <= 1'b0;
      end
      reg_hcRhPortStatus_0_CCS_regNext <= reg_hcRhPortStatus_0_CCS;
      if(io_phy_ports_1_connect) begin
        reg_hcRhPortStatus_1_connected <= 1'b1;
      end
      if(io_phy_ports_1_disconnect) begin
        reg_hcRhPortStatus_1_connected <= 1'b0;
      end
      reg_hcRhPortStatus_1_CCS_regNext <= reg_hcRhPortStatus_1_CCS;
      if(frame_reload) begin
        if(when_UsbOhci_l540) begin
          reg_hcFmNumber_overflow <= 1'b1;
        end
      end
      if(when_UsbOhci_l685) begin
        interruptDelay_counter <= (interruptDelay_counter - 3'b001);
      end
      if(when_UsbOhci_l689) begin
        interruptDelay_counter <= interruptDelay_load_payload;
      end
      if(interruptDelay_disable) begin
        interruptDelay_counter <= 3'b111;
      end
      endpoint_dmaLogic_push <= 1'b0;
      case(io_ctrl_cmd_payload_fragment_address)
        12'h004 : begin
          if(ctrl_doWrite) begin
            if(when_BusSlaveFactory_l942_5) begin
              reg_hcControl_IR <= io_ctrl_cmd_payload_fragment_data[8];
            end
            if(when_BusSlaveFactory_l942_6) begin
              reg_hcControl_RWC <= io_ctrl_cmd_payload_fragment_data[9];
            end
          end
        end
        12'h040 : begin
          if(ctrl_doWrite) begin
            if(when_BusSlaveFactory_l942_36) begin
              reg_hcPeriodicStart_PS[7 : 0] <= io_ctrl_cmd_payload_fragment_data[7 : 0];
            end
            if(when_BusSlaveFactory_l942_37) begin
              reg_hcPeriodicStart_PS[13 : 8] <= io_ctrl_cmd_payload_fragment_data[13 : 8];
            end
          end
        end
        default : begin
        end
      endcase
      _zz_when_UsbOhci_l253 <= 1'b0;
      token_stateReg <= token_stateNext;
      dataTx_stateReg <= dataTx_stateNext;
      dataRx_stateReg <= dataRx_stateNext;
      sof_stateReg <= sof_stateNext;
      case(sof_stateReg)
        UsbOhciWishbone_sof_enumDef_FRAME_TX : begin
        end
        UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD : begin
        end
        UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP : begin
          if(ioDma_rsp_valid) begin
            reg_hcFmNumber_overflow <= 1'b0;
          end
        end
        default : begin
        end
      endcase
      endpoint_stateReg <= endpoint_stateNext;
      endpoint_dmaLogic_stateReg <= endpoint_dmaLogic_stateNext;
      case(endpoint_dmaLogic_stateReg)
        UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : begin
        end
        UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : begin
        end
        UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : begin
          if(dataRx_wantExit) begin
            endpoint_dmaLogic_push <= (|endpoint_dmaLogic_byteCtx_sel);
          end
          if(dataRx_data_valid) begin
            if(when_UsbOhci_l1063) begin
              endpoint_dmaLogic_push <= 1'b1;
            end
          end
        end
        UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : begin
        end
        UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : begin
        end
        UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : begin
        end
        UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        end
        default : begin
        end
      endcase
      operational_stateReg <= operational_stateNext;
      hc_stateReg <= hc_stateNext;
      if(when_StateMachine_l238_8) begin
        doUnschedule <= 1'b1;
      end
      if(when_StateMachine_l238_9) begin
        doUnschedule <= 1'b1;
      end
      if(reg_hcCommandStatus_startSoftReset) begin
        doSoftReset <= 1'b1;
      end
    end
  end

  always @(posedge ctrl_clk) begin
    if(_zz_ctrl_rsp_ready) begin
      _zz_io_ctrl_rsp_payload_last <= ctrl_rsp_payload_last;
      _zz_io_ctrl_rsp_payload_fragment_opcode <= ctrl_rsp_payload_fragment_opcode;
      _zz_io_ctrl_rsp_payload_fragment_data <= ctrl_rsp_payload_fragment_data;
    end
    if(when_BusSlaveFactory_l366_1) begin
      if(when_BusSlaveFactory_l368_1) begin
        reg_hcCommandStatus_CLF <= _zz_reg_hcCommandStatus_CLF[0];
      end
    end
    if(when_BusSlaveFactory_l366_2) begin
      if(when_BusSlaveFactory_l368_2) begin
        reg_hcCommandStatus_BLF <= _zz_reg_hcCommandStatus_BLF[0];
      end
    end
    if(when_BusSlaveFactory_l366_3) begin
      if(when_BusSlaveFactory_l368_3) begin
        reg_hcCommandStatus_OCR <= _zz_reg_hcCommandStatus_OCR[0];
      end
    end
    if(when_BusSlaveFactory_l366_4) begin
      if(when_BusSlaveFactory_l368_4) begin
        reg_hcInterrupt_MIE <= _zz_reg_hcInterrupt_MIE[0];
      end
    end
    if(when_BusSlaveFactory_l335) begin
      if(when_BusSlaveFactory_l337) begin
        reg_hcInterrupt_MIE <= _zz_reg_hcInterrupt_MIE_1[0];
      end
    end
    if(when_BusSlaveFactory_l335_1) begin
      if(when_BusSlaveFactory_l337_1) begin
        reg_hcInterrupt_SO_status <= _zz_reg_hcInterrupt_SO_status[0];
      end
    end
    if(when_BusSlaveFactory_l366_5) begin
      if(when_BusSlaveFactory_l368_5) begin
        reg_hcInterrupt_SO_enable <= _zz_reg_hcInterrupt_SO_enable[0];
      end
    end
    if(when_BusSlaveFactory_l335_2) begin
      if(when_BusSlaveFactory_l337_2) begin
        reg_hcInterrupt_SO_enable <= _zz_reg_hcInterrupt_SO_enable_1[0];
      end
    end
    if(when_BusSlaveFactory_l335_3) begin
      if(when_BusSlaveFactory_l337_3) begin
        reg_hcInterrupt_WDH_status <= _zz_reg_hcInterrupt_WDH_status[0];
      end
    end
    if(when_BusSlaveFactory_l366_6) begin
      if(when_BusSlaveFactory_l368_6) begin
        reg_hcInterrupt_WDH_enable <= _zz_reg_hcInterrupt_WDH_enable[0];
      end
    end
    if(when_BusSlaveFactory_l335_4) begin
      if(when_BusSlaveFactory_l337_4) begin
        reg_hcInterrupt_WDH_enable <= _zz_reg_hcInterrupt_WDH_enable_1[0];
      end
    end
    if(when_BusSlaveFactory_l335_5) begin
      if(when_BusSlaveFactory_l337_5) begin
        reg_hcInterrupt_SF_status <= _zz_reg_hcInterrupt_SF_status[0];
      end
    end
    if(when_BusSlaveFactory_l366_7) begin
      if(when_BusSlaveFactory_l368_7) begin
        reg_hcInterrupt_SF_enable <= _zz_reg_hcInterrupt_SF_enable[0];
      end
    end
    if(when_BusSlaveFactory_l335_6) begin
      if(when_BusSlaveFactory_l337_6) begin
        reg_hcInterrupt_SF_enable <= _zz_reg_hcInterrupt_SF_enable_1[0];
      end
    end
    if(when_BusSlaveFactory_l335_7) begin
      if(when_BusSlaveFactory_l337_7) begin
        reg_hcInterrupt_RD_status <= _zz_reg_hcInterrupt_RD_status[0];
      end
    end
    if(when_BusSlaveFactory_l366_8) begin
      if(when_BusSlaveFactory_l368_8) begin
        reg_hcInterrupt_RD_enable <= _zz_reg_hcInterrupt_RD_enable[0];
      end
    end
    if(when_BusSlaveFactory_l335_8) begin
      if(when_BusSlaveFactory_l337_8) begin
        reg_hcInterrupt_RD_enable <= _zz_reg_hcInterrupt_RD_enable_1[0];
      end
    end
    if(when_BusSlaveFactory_l335_9) begin
      if(when_BusSlaveFactory_l337_9) begin
        reg_hcInterrupt_UE_status <= _zz_reg_hcInterrupt_UE_status[0];
      end
    end
    if(when_BusSlaveFactory_l366_9) begin
      if(when_BusSlaveFactory_l368_9) begin
        reg_hcInterrupt_UE_enable <= _zz_reg_hcInterrupt_UE_enable[0];
      end
    end
    if(when_BusSlaveFactory_l335_10) begin
      if(when_BusSlaveFactory_l337_10) begin
        reg_hcInterrupt_UE_enable <= _zz_reg_hcInterrupt_UE_enable_1[0];
      end
    end
    if(when_BusSlaveFactory_l335_11) begin
      if(when_BusSlaveFactory_l337_11) begin
        reg_hcInterrupt_FNO_status <= _zz_reg_hcInterrupt_FNO_status[0];
      end
    end
    if(when_BusSlaveFactory_l366_10) begin
      if(when_BusSlaveFactory_l368_10) begin
        reg_hcInterrupt_FNO_enable <= _zz_reg_hcInterrupt_FNO_enable[0];
      end
    end
    if(when_BusSlaveFactory_l335_12) begin
      if(when_BusSlaveFactory_l337_12) begin
        reg_hcInterrupt_FNO_enable <= _zz_reg_hcInterrupt_FNO_enable_1[0];
      end
    end
    if(when_BusSlaveFactory_l335_13) begin
      if(when_BusSlaveFactory_l337_13) begin
        reg_hcInterrupt_RHSC_status <= _zz_reg_hcInterrupt_RHSC_status[0];
      end
    end
    if(when_BusSlaveFactory_l366_11) begin
      if(when_BusSlaveFactory_l368_11) begin
        reg_hcInterrupt_RHSC_enable <= _zz_reg_hcInterrupt_RHSC_enable[0];
      end
    end
    if(when_BusSlaveFactory_l335_14) begin
      if(when_BusSlaveFactory_l337_14) begin
        reg_hcInterrupt_RHSC_enable <= _zz_reg_hcInterrupt_RHSC_enable_1[0];
      end
    end
    if(when_BusSlaveFactory_l335_15) begin
      if(when_BusSlaveFactory_l337_15) begin
        reg_hcInterrupt_OC_status <= _zz_reg_hcInterrupt_OC_status[0];
      end
    end
    if(when_BusSlaveFactory_l366_12) begin
      if(when_BusSlaveFactory_l368_12) begin
        reg_hcInterrupt_OC_enable <= _zz_reg_hcInterrupt_OC_enable[0];
      end
    end
    if(when_BusSlaveFactory_l335_16) begin
      if(when_BusSlaveFactory_l337_16) begin
        reg_hcInterrupt_OC_enable <= _zz_reg_hcInterrupt_OC_enable_1[0];
      end
    end
    if(reg_hcCommandStatus_OCR) begin
      reg_hcInterrupt_OC_status <= 1'b1;
    end
    if(when_BusSlaveFactory_l335_17) begin
      if(when_BusSlaveFactory_l337_17) begin
        reg_hcRhStatus_CCIC <= _zz_reg_hcRhStatus_CCIC[0];
      end
    end
    if(when_UsbOhci_l409) begin
      reg_hcRhStatus_CCIC <= 1'b1;
    end
    if(reg_hcRhStatus_setRemoteWakeupEnable) begin
      reg_hcRhStatus_DRWE <= 1'b1;
    end
    if(reg_hcRhStatus_clearRemoteWakeupEnable) begin
      reg_hcRhStatus_DRWE <= 1'b0;
    end
    if(reg_hcRhPortStatus_0_CSC_clear) begin
      reg_hcRhPortStatus_0_CSC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_0_CSC_set) begin
      reg_hcRhPortStatus_0_CSC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_0_CSC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_0_PESC_clear) begin
      reg_hcRhPortStatus_0_PESC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_0_PESC_set) begin
      reg_hcRhPortStatus_0_PESC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_0_PESC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_0_PSSC_clear) begin
      reg_hcRhPortStatus_0_PSSC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_0_PSSC_set) begin
      reg_hcRhPortStatus_0_PSSC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_0_PSSC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_0_OCIC_clear) begin
      reg_hcRhPortStatus_0_OCIC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_0_OCIC_set) begin
      reg_hcRhPortStatus_0_OCIC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_0_OCIC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_0_PRSC_clear) begin
      reg_hcRhPortStatus_0_PRSC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_0_PRSC_set) begin
      reg_hcRhPortStatus_0_PRSC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_0_PRSC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(when_UsbOhci_l460) begin
      reg_hcRhPortStatus_0_PES <= 1'b0;
    end
    if(when_UsbOhci_l460_1) begin
      reg_hcRhPortStatus_0_PES <= 1'b1;
    end
    if(when_UsbOhci_l460_2) begin
      reg_hcRhPortStatus_0_PES <= 1'b1;
    end
    if(when_UsbOhci_l461) begin
      reg_hcRhPortStatus_0_PSS <= 1'b0;
    end
    if(when_UsbOhci_l461_1) begin
      reg_hcRhPortStatus_0_PSS <= 1'b1;
    end
    if(when_UsbOhci_l462) begin
      reg_hcRhPortStatus_0_suspend <= 1'b1;
    end
    if(when_UsbOhci_l463) begin
      reg_hcRhPortStatus_0_resume <= 1'b1;
    end
    if(when_UsbOhci_l464) begin
      reg_hcRhPortStatus_0_reset <= 1'b1;
    end
    if(reg_hcRhDescriptorA_NPS) begin
      reg_hcRhPortStatus_0_PPS <= 1'b1;
    end else begin
      if(reg_hcRhDescriptorA_PSM) begin
        if(when_UsbOhci_l470) begin
          if(reg_hcRhPortStatus_0_clearPortPower) begin
            reg_hcRhPortStatus_0_PPS <= 1'b0;
          end
          if(reg_hcRhPortStatus_0_setPortPower) begin
            reg_hcRhPortStatus_0_PPS <= 1'b1;
          end
        end else begin
          if(reg_hcRhStatus_clearGlobalPower) begin
            reg_hcRhPortStatus_0_PPS <= 1'b0;
          end
          if(reg_hcRhStatus_setGlobalPower) begin
            reg_hcRhPortStatus_0_PPS <= 1'b1;
          end
        end
      end else begin
        if(reg_hcRhStatus_clearGlobalPower) begin
          reg_hcRhPortStatus_0_PPS <= 1'b0;
        end
        if(reg_hcRhStatus_setGlobalPower) begin
          reg_hcRhPortStatus_0_PPS <= 1'b1;
        end
      end
    end
    if(io_phy_overcurrent) begin
      reg_hcRhPortStatus_0_PPS <= 1'b0;
    end
    if(io_phy_ports_0_resume_fire) begin
      reg_hcRhPortStatus_0_resume <= 1'b0;
    end
    if(io_phy_ports_0_reset_fire_1) begin
      reg_hcRhPortStatus_0_reset <= 1'b0;
    end
    if(io_phy_ports_0_suspend_fire_1) begin
      reg_hcRhPortStatus_0_suspend <= 1'b0;
    end
    if(reg_hcRhPortStatus_1_CSC_clear) begin
      reg_hcRhPortStatus_1_CSC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_1_CSC_set) begin
      reg_hcRhPortStatus_1_CSC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_1_CSC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_1_PESC_clear) begin
      reg_hcRhPortStatus_1_PESC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_1_PESC_set) begin
      reg_hcRhPortStatus_1_PESC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_1_PESC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_1_PSSC_clear) begin
      reg_hcRhPortStatus_1_PSSC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_1_PSSC_set) begin
      reg_hcRhPortStatus_1_PSSC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_1_PSSC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_1_OCIC_clear) begin
      reg_hcRhPortStatus_1_OCIC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_1_OCIC_set) begin
      reg_hcRhPortStatus_1_OCIC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_1_OCIC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(reg_hcRhPortStatus_1_PRSC_clear) begin
      reg_hcRhPortStatus_1_PRSC_reg <= 1'b0;
    end
    if(reg_hcRhPortStatus_1_PRSC_set) begin
      reg_hcRhPortStatus_1_PRSC_reg <= 1'b1;
    end
    if(reg_hcRhPortStatus_1_PRSC_set) begin
      reg_hcInterrupt_RHSC_status <= 1'b1;
    end
    if(when_UsbOhci_l460_3) begin
      reg_hcRhPortStatus_1_PES <= 1'b0;
    end
    if(when_UsbOhci_l460_4) begin
      reg_hcRhPortStatus_1_PES <= 1'b1;
    end
    if(when_UsbOhci_l460_5) begin
      reg_hcRhPortStatus_1_PES <= 1'b1;
    end
    if(when_UsbOhci_l461_2) begin
      reg_hcRhPortStatus_1_PSS <= 1'b0;
    end
    if(when_UsbOhci_l461_3) begin
      reg_hcRhPortStatus_1_PSS <= 1'b1;
    end
    if(when_UsbOhci_l462_1) begin
      reg_hcRhPortStatus_1_suspend <= 1'b1;
    end
    if(when_UsbOhci_l463_1) begin
      reg_hcRhPortStatus_1_resume <= 1'b1;
    end
    if(when_UsbOhci_l464_1) begin
      reg_hcRhPortStatus_1_reset <= 1'b1;
    end
    if(reg_hcRhDescriptorA_NPS) begin
      reg_hcRhPortStatus_1_PPS <= 1'b1;
    end else begin
      if(reg_hcRhDescriptorA_PSM) begin
        if(when_UsbOhci_l470_1) begin
          if(reg_hcRhPortStatus_1_clearPortPower) begin
            reg_hcRhPortStatus_1_PPS <= 1'b0;
          end
          if(reg_hcRhPortStatus_1_setPortPower) begin
            reg_hcRhPortStatus_1_PPS <= 1'b1;
          end
        end else begin
          if(reg_hcRhStatus_clearGlobalPower) begin
            reg_hcRhPortStatus_1_PPS <= 1'b0;
          end
          if(reg_hcRhStatus_setGlobalPower) begin
            reg_hcRhPortStatus_1_PPS <= 1'b1;
          end
        end
      end else begin
        if(reg_hcRhStatus_clearGlobalPower) begin
          reg_hcRhPortStatus_1_PPS <= 1'b0;
        end
        if(reg_hcRhStatus_setGlobalPower) begin
          reg_hcRhPortStatus_1_PPS <= 1'b1;
        end
      end
    end
    if(io_phy_overcurrent) begin
      reg_hcRhPortStatus_1_PPS <= 1'b0;
    end
    if(io_phy_ports_1_resume_fire) begin
      reg_hcRhPortStatus_1_resume <= 1'b0;
    end
    if(io_phy_ports_1_reset_fire_1) begin
      reg_hcRhPortStatus_1_reset <= 1'b0;
    end
    if(io_phy_ports_1_suspend_fire_1) begin
      reg_hcRhPortStatus_1_suspend <= 1'b0;
    end
    frame_decrementTimer <= (frame_decrementTimer + 3'b001);
    if(frame_decrementTimerOverflow) begin
      frame_decrementTimer <= 3'b000;
    end
    if(when_UsbOhci_l526) begin
      reg_hcFmRemaining_FR <= (reg_hcFmRemaining_FR - 14'h0001);
      if(when_UsbOhci_l528) begin
        frame_limitCounter <= (frame_limitCounter - 15'h0001);
      end
    end
    if(frame_reload) begin
      reg_hcFmRemaining_FR <= reg_hcFmInterval_FI;
      reg_hcFmRemaining_FRT <= reg_hcFmInterval_FIT;
      reg_hcFmNumber_FN <= reg_hcFmNumber_FNp1;
      frame_limitCounter <= reg_hcFmInterval_FSMPS;
      frame_decrementTimer <= 3'b000;
    end
    if(io_phy_tick) begin
      rxTimer_counter <= (rxTimer_counter + 8'h01);
    end
    if(rxTimer_clear) begin
      rxTimer_counter <= 8'h0;
    end
    if(_zz_1) begin
      _zz_dataRx_history_0 <= _zz_dataRx_pid;
    end
    if(_zz_1) begin
      _zz_dataRx_history_1 <= _zz_dataRx_history_0;
    end
    if(priority_tick) begin
      priority_counter <= (priority_counter + 2'b01);
    end
    if(priority_skip) begin
      priority_bulk <= (! priority_bulk);
      priority_counter <= 2'b00;
    end
    endpoint_TD_isoOverrunReg <= endpoint_TD_isoOverrun;
    endpoint_TD_isoZero <= (endpoint_TD_isoLast ? (endpoint_TD_isoBaseNext < endpoint_TD_isoBase) : (endpoint_TD_isoBase == endpoint_TD_isoBaseNext));
    endpoint_TD_isoLastReg <= endpoint_TD_isoLast;
    endpoint_TD_tooEarlyReg <= endpoint_TD_tooEarly;
    endpoint_TD_lastOffset <= (endpoint_ED_F ? _zz_endpoint_TD_lastOffset : {(! endpoint_TD_isSinglePage),endpoint_TD_BE[11 : 0]});
    if(endpoint_TD_clear) begin
      endpoint_TD_retire <= 1'b0;
      endpoint_TD_dataPhaseUpdate <= 1'b0;
      endpoint_TD_upateCBP <= 1'b0;
      endpoint_TD_noUpdate <= 1'b0;
    end
    if(endpoint_applyNextED) begin
      case(endpoint_flowType)
        UsbOhciWishbone_FlowType_BULK : begin
          reg_hcBulkCurrentED_BCED_reg <= endpoint_ED_nextED;
        end
        UsbOhciWishbone_FlowType_CONTROL : begin
          reg_hcControlCurrentED_CCED_reg <= endpoint_ED_nextED;
        end
        default : begin
          reg_hcPeriodCurrentED_PCED_reg <= endpoint_ED_nextED;
        end
      endcase
    end
    if(endpoint_dmaLogic_byteCtx_increment) begin
      endpoint_dmaLogic_byteCtx_counter <= (endpoint_dmaLogic_byteCtx_counter + 13'h0001);
    end
    case(io_ctrl_cmd_payload_fragment_address)
      12'h004 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l942) begin
            reg_hcControl_CBSR[1 : 0] <= io_ctrl_cmd_payload_fragment_data[1 : 0];
          end
          if(when_BusSlaveFactory_l942_1) begin
            reg_hcControl_PLE <= io_ctrl_cmd_payload_fragment_data[2];
          end
          if(when_BusSlaveFactory_l942_2) begin
            reg_hcControl_IE <= io_ctrl_cmd_payload_fragment_data[3];
          end
          if(when_BusSlaveFactory_l942_3) begin
            reg_hcControl_CLE <= io_ctrl_cmd_payload_fragment_data[4];
          end
          if(when_BusSlaveFactory_l942_4) begin
            reg_hcControl_BLE <= io_ctrl_cmd_payload_fragment_data[5];
          end
          if(when_BusSlaveFactory_l942_7) begin
            reg_hcControl_RWE <= io_ctrl_cmd_payload_fragment_data[10];
          end
        end
      end
      12'h018 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l942_8) begin
            reg_hcHCCA_HCCA_reg[7 : 0] <= io_ctrl_cmd_payload_fragment_data[15 : 8];
          end
          if(when_BusSlaveFactory_l942_9) begin
            reg_hcHCCA_HCCA_reg[15 : 8] <= io_ctrl_cmd_payload_fragment_data[23 : 16];
          end
          if(when_BusSlaveFactory_l942_10) begin
            reg_hcHCCA_HCCA_reg[23 : 16] <= io_ctrl_cmd_payload_fragment_data[31 : 24];
          end
        end
      end
      12'h020 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l942_11) begin
            reg_hcControlHeadED_CHED_reg[3 : 0] <= io_ctrl_cmd_payload_fragment_data[7 : 4];
          end
          if(when_BusSlaveFactory_l942_12) begin
            reg_hcControlHeadED_CHED_reg[11 : 4] <= io_ctrl_cmd_payload_fragment_data[15 : 8];
          end
          if(when_BusSlaveFactory_l942_13) begin
            reg_hcControlHeadED_CHED_reg[19 : 12] <= io_ctrl_cmd_payload_fragment_data[23 : 16];
          end
          if(when_BusSlaveFactory_l942_14) begin
            reg_hcControlHeadED_CHED_reg[27 : 20] <= io_ctrl_cmd_payload_fragment_data[31 : 24];
          end
        end
      end
      12'h024 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l942_15) begin
            reg_hcControlCurrentED_CCED_reg[3 : 0] <= io_ctrl_cmd_payload_fragment_data[7 : 4];
          end
          if(when_BusSlaveFactory_l942_16) begin
            reg_hcControlCurrentED_CCED_reg[11 : 4] <= io_ctrl_cmd_payload_fragment_data[15 : 8];
          end
          if(when_BusSlaveFactory_l942_17) begin
            reg_hcControlCurrentED_CCED_reg[19 : 12] <= io_ctrl_cmd_payload_fragment_data[23 : 16];
          end
          if(when_BusSlaveFactory_l942_18) begin
            reg_hcControlCurrentED_CCED_reg[27 : 20] <= io_ctrl_cmd_payload_fragment_data[31 : 24];
          end
        end
      end
      12'h028 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l942_19) begin
            reg_hcBulkHeadED_BHED_reg[3 : 0] <= io_ctrl_cmd_payload_fragment_data[7 : 4];
          end
          if(when_BusSlaveFactory_l942_20) begin
            reg_hcBulkHeadED_BHED_reg[11 : 4] <= io_ctrl_cmd_payload_fragment_data[15 : 8];
          end
          if(when_BusSlaveFactory_l942_21) begin
            reg_hcBulkHeadED_BHED_reg[19 : 12] <= io_ctrl_cmd_payload_fragment_data[23 : 16];
          end
          if(when_BusSlaveFactory_l942_22) begin
            reg_hcBulkHeadED_BHED_reg[27 : 20] <= io_ctrl_cmd_payload_fragment_data[31 : 24];
          end
        end
      end
      12'h02c : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l942_23) begin
            reg_hcBulkCurrentED_BCED_reg[3 : 0] <= io_ctrl_cmd_payload_fragment_data[7 : 4];
          end
          if(when_BusSlaveFactory_l942_24) begin
            reg_hcBulkCurrentED_BCED_reg[11 : 4] <= io_ctrl_cmd_payload_fragment_data[15 : 8];
          end
          if(when_BusSlaveFactory_l942_25) begin
            reg_hcBulkCurrentED_BCED_reg[19 : 12] <= io_ctrl_cmd_payload_fragment_data[23 : 16];
          end
          if(when_BusSlaveFactory_l942_26) begin
            reg_hcBulkCurrentED_BCED_reg[27 : 20] <= io_ctrl_cmd_payload_fragment_data[31 : 24];
          end
        end
      end
      12'h030 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l942_27) begin
            reg_hcDoneHead_DH_reg[3 : 0] <= io_ctrl_cmd_payload_fragment_data[7 : 4];
          end
          if(when_BusSlaveFactory_l942_28) begin
            reg_hcDoneHead_DH_reg[11 : 4] <= io_ctrl_cmd_payload_fragment_data[15 : 8];
          end
          if(when_BusSlaveFactory_l942_29) begin
            reg_hcDoneHead_DH_reg[19 : 12] <= io_ctrl_cmd_payload_fragment_data[23 : 16];
          end
          if(when_BusSlaveFactory_l942_30) begin
            reg_hcDoneHead_DH_reg[27 : 20] <= io_ctrl_cmd_payload_fragment_data[31 : 24];
          end
        end
      end
      12'h034 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l942_31) begin
            reg_hcFmInterval_FI[7 : 0] <= io_ctrl_cmd_payload_fragment_data[7 : 0];
          end
          if(when_BusSlaveFactory_l942_32) begin
            reg_hcFmInterval_FI[13 : 8] <= io_ctrl_cmd_payload_fragment_data[13 : 8];
          end
          if(when_BusSlaveFactory_l942_33) begin
            reg_hcFmInterval_FSMPS[7 : 0] <= io_ctrl_cmd_payload_fragment_data[23 : 16];
          end
          if(when_BusSlaveFactory_l942_34) begin
            reg_hcFmInterval_FSMPS[14 : 8] <= io_ctrl_cmd_payload_fragment_data[30 : 24];
          end
          if(when_BusSlaveFactory_l942_35) begin
            reg_hcFmInterval_FIT <= io_ctrl_cmd_payload_fragment_data[31];
          end
        end
      end
      12'h044 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l942_38) begin
            reg_hcLSThreshold_LST[7 : 0] <= io_ctrl_cmd_payload_fragment_data[7 : 0];
          end
          if(when_BusSlaveFactory_l942_39) begin
            reg_hcLSThreshold_LST[11 : 8] <= io_ctrl_cmd_payload_fragment_data[11 : 8];
          end
        end
      end
      12'h048 : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l942_40) begin
            reg_hcRhDescriptorA_PSM <= io_ctrl_cmd_payload_fragment_data[8];
          end
          if(when_BusSlaveFactory_l942_41) begin
            reg_hcRhDescriptorA_NPS <= io_ctrl_cmd_payload_fragment_data[9];
          end
          if(when_BusSlaveFactory_l942_42) begin
            reg_hcRhDescriptorA_OCPM <= io_ctrl_cmd_payload_fragment_data[11];
          end
          if(when_BusSlaveFactory_l942_43) begin
            reg_hcRhDescriptorA_NOCP <= io_ctrl_cmd_payload_fragment_data[12];
          end
          if(when_BusSlaveFactory_l942_44) begin
            reg_hcRhDescriptorA_POTPGT[7 : 0] <= io_ctrl_cmd_payload_fragment_data[31 : 24];
          end
        end
      end
      12'h04c : begin
        if(ctrl_doWrite) begin
          if(when_BusSlaveFactory_l942_45) begin
            reg_hcRhDescriptorB_DR[1 : 0] <= io_ctrl_cmd_payload_fragment_data[2 : 1];
          end
          if(when_BusSlaveFactory_l942_46) begin
            reg_hcRhDescriptorB_PPCM[1 : 0] <= io_ctrl_cmd_payload_fragment_data[18 : 17];
          end
        end
      end
      default : begin
      end
    endcase
    if(when_UsbOhci_l253) begin
      reg_hcControl_CBSR <= 2'b00;
      reg_hcControl_PLE <= 1'b0;
      reg_hcControl_IE <= 1'b0;
      reg_hcControl_CLE <= 1'b0;
      reg_hcControl_BLE <= 1'b0;
      reg_hcControl_RWE <= 1'b0;
      reg_hcCommandStatus_CLF <= 1'b0;
      reg_hcCommandStatus_BLF <= 1'b0;
      reg_hcCommandStatus_OCR <= 1'b0;
      reg_hcCommandStatus_SOC <= 2'b00;
      reg_hcInterrupt_MIE <= 1'b0;
      reg_hcInterrupt_SO_status <= 1'b0;
      reg_hcInterrupt_SO_enable <= 1'b0;
      reg_hcInterrupt_WDH_status <= 1'b0;
      reg_hcInterrupt_WDH_enable <= 1'b0;
      reg_hcInterrupt_SF_status <= 1'b0;
      reg_hcInterrupt_SF_enable <= 1'b0;
      reg_hcInterrupt_RD_status <= 1'b0;
      reg_hcInterrupt_RD_enable <= 1'b0;
      reg_hcInterrupt_UE_status <= 1'b0;
      reg_hcInterrupt_UE_enable <= 1'b0;
      reg_hcInterrupt_FNO_status <= 1'b0;
      reg_hcInterrupt_FNO_enable <= 1'b0;
      reg_hcInterrupt_RHSC_status <= 1'b0;
      reg_hcInterrupt_RHSC_enable <= 1'b0;
      reg_hcInterrupt_OC_status <= 1'b0;
      reg_hcInterrupt_OC_enable <= 1'b0;
      reg_hcHCCA_HCCA_reg <= 24'h0;
      reg_hcPeriodCurrentED_PCED_reg <= 28'h0;
      reg_hcControlHeadED_CHED_reg <= 28'h0;
      reg_hcControlCurrentED_CCED_reg <= 28'h0;
      reg_hcBulkHeadED_BHED_reg <= 28'h0;
      reg_hcBulkCurrentED_BCED_reg <= 28'h0;
      reg_hcDoneHead_DH_reg <= 28'h0;
      reg_hcFmInterval_FI <= 14'h2edf;
      reg_hcFmInterval_FIT <= 1'b0;
      reg_hcFmRemaining_FR <= 14'h0;
      reg_hcFmRemaining_FRT <= 1'b0;
      reg_hcFmNumber_FN <= 16'h0;
      reg_hcLSThreshold_LST <= 12'h628;
      reg_hcRhDescriptorA_PSM <= 1'b0;
      reg_hcRhDescriptorA_NPS <= 1'b0;
      reg_hcRhDescriptorA_OCPM <= 1'b0;
      reg_hcRhDescriptorA_NOCP <= 1'b0;
      reg_hcRhDescriptorA_POTPGT <= 8'h0a;
      reg_hcRhDescriptorB_DR <= {1'b0,1'b0};
      reg_hcRhDescriptorB_PPCM <= {1'b1,1'b1};
      reg_hcRhStatus_DRWE <= 1'b0;
      reg_hcRhStatus_CCIC <= 1'b0;
      reg_hcRhPortStatus_0_resume <= 1'b0;
      reg_hcRhPortStatus_0_reset <= 1'b0;
      reg_hcRhPortStatus_0_suspend <= 1'b0;
      reg_hcRhPortStatus_0_PSS <= 1'b0;
      reg_hcRhPortStatus_0_PPS <= 1'b0;
      reg_hcRhPortStatus_0_PES <= 1'b0;
      reg_hcRhPortStatus_0_CSC_reg <= 1'b0;
      reg_hcRhPortStatus_0_PESC_reg <= 1'b0;
      reg_hcRhPortStatus_0_PSSC_reg <= 1'b0;
      reg_hcRhPortStatus_0_OCIC_reg <= 1'b0;
      reg_hcRhPortStatus_0_PRSC_reg <= 1'b0;
      reg_hcRhPortStatus_1_resume <= 1'b0;
      reg_hcRhPortStatus_1_reset <= 1'b0;
      reg_hcRhPortStatus_1_suspend <= 1'b0;
      reg_hcRhPortStatus_1_PSS <= 1'b0;
      reg_hcRhPortStatus_1_PPS <= 1'b0;
      reg_hcRhPortStatus_1_PES <= 1'b0;
      reg_hcRhPortStatus_1_CSC_reg <= 1'b0;
      reg_hcRhPortStatus_1_PESC_reg <= 1'b0;
      reg_hcRhPortStatus_1_PSSC_reg <= 1'b0;
      reg_hcRhPortStatus_1_OCIC_reg <= 1'b0;
      reg_hcRhPortStatus_1_PRSC_reg <= 1'b0;
    end
    case(dataRx_stateReg)
      UsbOhciWishbone_dataRx_enumDef_IDLE : begin
        if(!io_phy_rx_active) begin
          if(rxTimer_rxTimeout) begin
            dataRx_notResponding <= 1'b1;
          end
        end
      end
      UsbOhciWishbone_dataRx_enumDef_PID : begin
        dataRx_valids <= 2'b00;
        dataRx_pidError <= 1'b1;
        if(_zz_1) begin
          dataRx_pid <= _zz_dataRx_pid[3 : 0];
          dataRx_pidError <= (_zz_dataRx_pid[3 : 0] != (~ _zz_dataRx_pid[7 : 4]));
        end
      end
      UsbOhciWishbone_dataRx_enumDef_DATA : begin
        if(when_Misc_l70) begin
          if(when_Misc_l71) begin
            dataRx_crcError <= 1'b1;
          end
        end else begin
          if(_zz_1) begin
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
      if(_zz_1) begin
        if(when_Misc_l87) begin
          dataRx_stuffingError <= 1'b1;
        end
      end
    end
    case(sof_stateReg)
      UsbOhciWishbone_sof_enumDef_FRAME_TX : begin
        sof_doInterruptDelay <= (interruptDelay_done && (! reg_hcInterrupt_WDH_status));
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_CMD : begin
      end
      UsbOhciWishbone_sof_enumDef_FRAME_NUMBER_RSP : begin
        if(ioDma_rsp_valid) begin
          reg_hcInterrupt_SF_status <= 1'b1;
          if(reg_hcFmNumber_overflow) begin
            reg_hcInterrupt_FNO_status <= 1'b1;
          end
          if(sof_doInterruptDelay) begin
            reg_hcInterrupt_WDH_status <= 1'b1;
            reg_hcDoneHead_DH_reg <= 28'h0;
          end
        end
      end
      default : begin
      end
    endcase
    case(endpoint_stateReg)
      UsbOhciWishbone_endpoint_enumDef_ED_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ED_READ_RSP : begin
        if(when_UsbOhci_l188) begin
          endpoint_ED_words_0 <= dmaRspMux_vec_0[31 : 0];
        end
        if(when_UsbOhci_l188_1) begin
          endpoint_ED_words_1 <= dmaRspMux_vec_0[31 : 0];
        end
        if(when_UsbOhci_l188_2) begin
          endpoint_ED_words_2 <= dmaRspMux_vec_0[31 : 0];
        end
        if(when_UsbOhci_l188_3) begin
          endpoint_ED_words_3 <= dmaRspMux_vec_0[31 : 0];
        end
      end
      UsbOhciWishbone_endpoint_enumDef_ED_ANALYSE : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_RSP : begin
        if(when_UsbOhci_l188_4) begin
          endpoint_TD_words_0 <= dmaRspMux_vec_0[31 : 0];
        end
        if(when_UsbOhci_l188_5) begin
          endpoint_TD_words_1 <= dmaRspMux_vec_0[31 : 0];
        end
        if(when_UsbOhci_l188_6) begin
          endpoint_TD_words_2 <= dmaRspMux_vec_0[31 : 0];
        end
        if(when_UsbOhci_l188_7) begin
          endpoint_TD_words_3 <= dmaRspMux_vec_0[31 : 0];
        end
        if(when_UsbOhci_l891) begin
          if(when_UsbOhci_l188_8) begin
            endpoint_TD_isoBase <= dmaRspMux_vec_0[12 : 0];
          end
          if(when_UsbOhci_l188_9) begin
            endpoint_TD_isoBaseNext <= dmaRspMux_vec_0[28 : 16];
          end
        end
        if(when_UsbOhci_l891_1) begin
          if(when_UsbOhci_l188_10) begin
            endpoint_TD_isoBase <= dmaRspMux_vec_0[28 : 16];
          end
          if(when_UsbOhci_l188_11) begin
            endpoint_TD_isoBaseNext <= dmaRspMux_vec_0[12 : 0];
          end
        end
        if(when_UsbOhci_l891_2) begin
          if(when_UsbOhci_l188_12) begin
            endpoint_TD_isoBase <= dmaRspMux_vec_0[12 : 0];
          end
          if(when_UsbOhci_l188_13) begin
            endpoint_TD_isoBaseNext <= dmaRspMux_vec_0[28 : 16];
          end
        end
        if(when_UsbOhci_l891_3) begin
          if(when_UsbOhci_l188_14) begin
            endpoint_TD_isoBase <= dmaRspMux_vec_0[28 : 16];
          end
          if(when_UsbOhci_l188_15) begin
            endpoint_TD_isoBaseNext <= dmaRspMux_vec_0[12 : 0];
          end
        end
        if(when_UsbOhci_l891_4) begin
          if(when_UsbOhci_l188_16) begin
            endpoint_TD_isoBase <= dmaRspMux_vec_0[12 : 0];
          end
          if(when_UsbOhci_l188_17) begin
            endpoint_TD_isoBaseNext <= dmaRspMux_vec_0[28 : 16];
          end
        end
        if(when_UsbOhci_l891_5) begin
          if(when_UsbOhci_l188_18) begin
            endpoint_TD_isoBase <= dmaRspMux_vec_0[28 : 16];
          end
          if(when_UsbOhci_l188_19) begin
            endpoint_TD_isoBaseNext <= dmaRspMux_vec_0[12 : 0];
          end
        end
        if(when_UsbOhci_l891_6) begin
          if(when_UsbOhci_l188_20) begin
            endpoint_TD_isoBase <= dmaRspMux_vec_0[12 : 0];
          end
          if(when_UsbOhci_l188_21) begin
            endpoint_TD_isoBaseNext <= dmaRspMux_vec_0[28 : 16];
          end
        end
        if(when_UsbOhci_l891_7) begin
          if(when_UsbOhci_l188_22) begin
            endpoint_TD_isoBase <= dmaRspMux_vec_0[28 : 16];
          end
        end
        if(endpoint_TD_isoLast) begin
          endpoint_TD_isoBaseNext <= {(! endpoint_TD_isSinglePage),endpoint_TD_BE[11 : 0]};
        end
      end
      UsbOhciWishbone_endpoint_enumDef_TD_READ_DELAY : begin
      end
      UsbOhciWishbone_endpoint_enumDef_TD_ANALYSE : begin
        case(endpoint_flowType)
          UsbOhciWishbone_FlowType_CONTROL : begin
            reg_hcCommandStatus_CLF <= 1'b1;
          end
          UsbOhciWishbone_FlowType_BULK : begin
            reg_hcCommandStatus_BLF <= 1'b1;
          end
          default : begin
          end
        endcase
        endpoint_dmaLogic_byteCtx_counter <= endpoint_TD_firstOffset;
        endpoint_currentAddress <= {1'd0, endpoint_TD_firstOffset};
        endpoint_lastAddress <= _zz_endpoint_lastAddress_1[12:0];
        endpoint_zeroLength <= (endpoint_ED_F ? endpoint_TD_isoZero : (endpoint_TD_CBP == 32'h0));
        endpoint_dataPhase <= (endpoint_ED_F ? 1'b0 : (endpoint_TD_T[1] ? endpoint_TD_T[0] : endpoint_ED_C));
        if(endpoint_ED_F) begin
          if(endpoint_TD_isoOverrunReg) begin
            endpoint_TD_retire <= 1'b1;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_TD_CHECK_TIME : begin
        if(endpoint_timeCheck) begin
          endpoint_status_1 <= UsbOhciWishbone_endpoint_Status_FRAME_TIME;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_BUFFER_READ : begin
        if(when_UsbOhci_l1128) begin
          if(endpoint_timeCheck) begin
            endpoint_status_1 <= UsbOhciWishbone_endpoint_Status_FRAME_TIME;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_TOKEN : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_TX : begin
        if(dataTx_wantExit) begin
          if(endpoint_ED_F) begin
            endpoint_TD_words_0[31 : 28] <= 4'b0000;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_VALIDATE : begin
        endpoint_TD_words_0[31 : 28] <= 4'b0000;
        if(dataRx_notResponding) begin
          endpoint_TD_words_0[31 : 28] <= 4'b0101;
        end else begin
          if(dataRx_stuffingError) begin
            endpoint_TD_words_0[31 : 28] <= 4'b0010;
          end else begin
            if(dataRx_pidError) begin
              endpoint_TD_words_0[31 : 28] <= 4'b0110;
            end else begin
              if(endpoint_ED_F) begin
                case(dataRx_pid)
                  4'b1110, 4'b1010 : begin
                    endpoint_TD_words_0[31 : 28] <= 4'b0100;
                  end
                  4'b0011, 4'b1011 : begin
                  end
                  default : begin
                    endpoint_TD_words_0[31 : 28] <= 4'b0111;
                  end
                endcase
              end else begin
                case(dataRx_pid)
                  4'b1010 : begin
                    endpoint_TD_noUpdate <= 1'b1;
                  end
                  4'b1110 : begin
                    endpoint_TD_words_0[31 : 28] <= 4'b0100;
                  end
                  4'b0011, 4'b1011 : begin
                    if(when_UsbOhci_l1263) begin
                      endpoint_TD_words_0[31 : 28] <= 4'b0011;
                    end
                  end
                  default : begin
                    endpoint_TD_words_0[31 : 28] <= 4'b0111;
                  end
                endcase
              end
              if(when_UsbOhci_l1274) begin
                if(dataRx_crcError) begin
                  endpoint_TD_words_0[31 : 28] <= 4'b0001;
                end else begin
                  if(endpoint_dmaLogic_underflowError) begin
                    endpoint_TD_words_0[31 : 28] <= 4'b1001;
                  end else begin
                    if(endpoint_dmaLogic_overflow) begin
                      endpoint_TD_words_0[31 : 28] <= 4'b1000;
                    end
                  end
                end
              end
            end
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_RX : begin
        if(io_phy_rx_flow_valid) begin
          endpoint_ackRxFired <= 1'b1;
          endpoint_ackRxPid <= io_phy_rx_flow_payload_data[3 : 0];
          if(io_phy_rx_flow_payload_stuffingError) begin
            endpoint_ackRxStuffing <= 1'b1;
          end
          if(when_UsbOhci_l1200) begin
            endpoint_ackRxPidFailure <= 1'b1;
          end
        end
        if(io_phy_rx_active) begin
          endpoint_ackRxActivated <= 1'b1;
        end
        if(when_UsbOhci_l1205) begin
          if(when_UsbOhci_l1207) begin
            endpoint_TD_words_0[31 : 28] <= 4'b0110;
          end else begin
            if(endpoint_ackRxStuffing) begin
              endpoint_TD_words_0[31 : 28] <= 4'b0010;
            end else begin
              if(endpoint_ackRxPidFailure) begin
                endpoint_TD_words_0[31 : 28] <= 4'b0110;
              end else begin
                case(endpoint_ackRxPid)
                  4'b0010 : begin
                    endpoint_TD_words_0[31 : 28] <= 4'b0000;
                  end
                  4'b1010 : begin
                  end
                  4'b1110 : begin
                    endpoint_TD_words_0[31 : 28] <= 4'b0100;
                  end
                  default : begin
                    endpoint_TD_words_0[31 : 28] <= 4'b0111;
                  end
                endcase
              end
            end
          end
        end
        if(rxTimer_rxTimeout) begin
          endpoint_TD_words_0[31 : 28] <= 4'b0101;
        end
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_0 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_1 : begin
      end
      UsbOhciWishbone_endpoint_enumDef_ACK_TX_EOP : begin
      end
      UsbOhciWishbone_endpoint_enumDef_DATA_RX_WAIT_DMA : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_PROCESS : begin
        if(endpoint_ED_F) begin
          if(endpoint_TD_isoLastReg) begin
            endpoint_TD_retire <= 1'b1;
          end
        end else begin
          endpoint_TD_words_0[27 : 26] <= 2'b00;
          case(endpoint_TD_CC)
            4'b0000 : begin
              if(when_UsbOhci_l1331) begin
                endpoint_TD_retire <= 1'b1;
              end
              endpoint_TD_dataPhaseUpdate <= 1'b1;
              endpoint_TD_upateCBP <= 1'b1;
            end
            4'b1001 : begin
              endpoint_TD_retire <= 1'b1;
              endpoint_TD_dataPhaseUpdate <= 1'b1;
              endpoint_TD_upateCBP <= 1'b1;
            end
            4'b1000 : begin
              endpoint_TD_retire <= 1'b1;
              endpoint_TD_dataPhaseUpdate <= 1'b1;
            end
            4'b0010, 4'b0001, 4'b0110, 4'b0101, 4'b0111, 4'b0011 : begin
              endpoint_TD_words_0[27 : 26] <= _zz_endpoint_TD_words_0;
              if(when_UsbOhci_l1346) begin
                endpoint_TD_words_0[31 : 28] <= 4'b0000;
              end else begin
                endpoint_TD_retire <= 1'b1;
              end
            end
            default : begin
              endpoint_TD_retire <= 1'b1;
            end
          endcase
          if(endpoint_TD_noUpdate) begin
            endpoint_TD_retire <= 1'b0;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_TD_CMD : begin
        endpoint_ED_words_2[0] <= ((! endpoint_ED_F) && (endpoint_TD_CC != 4'b0000));
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_ED_CMD : begin
      end
      UsbOhciWishbone_endpoint_enumDef_UPDATE_SYNC : begin
        if(dmaCtx_pendingEmpty) begin
          if(endpoint_TD_retire) begin
            reg_hcDoneHead_DH_reg <= endpoint_ED_headP;
          end
        end
      end
      UsbOhciWishbone_endpoint_enumDef_ABORD : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l222_2) begin
      endpoint_status_1 <= UsbOhciWishbone_endpoint_Status_OK;
    end
    if(when_StateMachine_l238_4) begin
      endpoint_ackRxFired <= 1'b0;
      endpoint_ackRxActivated <= 1'b0;
      endpoint_ackRxPidFailure <= 1'b0;
      endpoint_ackRxStuffing <= 1'b0;
    end
    case(endpoint_dmaLogic_stateReg)
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_INIT : begin
        endpoint_dmaLogic_underflow <= 1'b0;
        endpoint_dmaLogic_overflow <= 1'b0;
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_TO_USB : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_FROM_USB : begin
        if(dataRx_wantExit) begin
          endpoint_dmaLogic_underflow <= when_UsbOhci_l1054;
          endpoint_dmaLogic_overflow <= ((! when_UsbOhci_l1054) && (_zz_endpoint_dmaLogic_overflow != endpoint_transactionSize));
          if(endpoint_zeroLength) begin
            endpoint_dmaLogic_underflow <= 1'b0;
            endpoint_dmaLogic_overflow <= (endpoint_dmaLogic_fromUsbCounter != 11'h0);
          end
          if(when_UsbOhci_l1054) begin
            endpoint_lastAddress <= _zz_endpoint_lastAddress_5[12:0];
          end
        end
        if(dataRx_data_valid) begin
          endpoint_dmaLogic_fromUsbCounter <= (endpoint_dmaLogic_fromUsbCounter + _zz_endpoint_dmaLogic_fromUsbCounter);
          if(_zz_2[0]) begin
            endpoint_dmaLogic_buffer[7 : 0] <= dataRx_data_payload;
          end
          if(_zz_2[1]) begin
            endpoint_dmaLogic_buffer[15 : 8] <= dataRx_data_payload;
          end
          if(_zz_2[2]) begin
            endpoint_dmaLogic_buffer[23 : 16] <= dataRx_data_payload;
          end
          if(_zz_2[3]) begin
            endpoint_dmaLogic_buffer[31 : 24] <= dataRx_data_payload;
          end
        end
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_VALIDATION : begin
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_CALC_CMD : begin
        endpoint_dmaLogic_length <= endpoint_dmaLogic_lengthCalc;
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_READ_CMD : begin
        if(ioDma_cmd_ready) begin
          endpoint_currentAddress <= (_zz_endpoint_currentAddress + 14'h0001);
        end
      end
      UsbOhciWishbone_endpoint_dmaLogic_enumDef_WRITE_CMD : begin
        if(ioDma_cmd_ready) begin
          if(endpoint_dmaLogic_beatLast) begin
            endpoint_currentAddress <= (_zz_endpoint_currentAddress_2 + 14'h0001);
          end
        end
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l238_5) begin
      endpoint_dmaLogic_fromUsbCounter <= 11'h0;
    end
    case(operational_stateReg)
      UsbOhciWishbone_operational_enumDef_SOF : begin
        if(sof_wantExit) begin
          if(when_UsbOhci_l1461) begin
            reg_hcInterrupt_SO_status <= 1'b1;
            reg_hcCommandStatus_SOC <= (reg_hcCommandStatus_SOC + 2'b01);
          end
          operational_allowBulk <= reg_hcControl_BLE;
          operational_allowControl <= reg_hcControl_CLE;
          operational_allowPeriodic <= reg_hcControl_PLE;
          operational_allowIsochronous <= reg_hcControl_IE;
          operational_periodicDone <= 1'b0;
          operational_periodicHeadFetched <= 1'b0;
          priority_bulk <= 1'b0;
          priority_counter <= 2'b00;
        end
      end
      UsbOhciWishbone_operational_enumDef_ARBITER : begin
        if(reg_hcControl_BLE) begin
          operational_allowBulk <= 1'b1;
        end
        if(reg_hcControl_CLE) begin
          operational_allowControl <= 1'b1;
        end
        if(!operational_askExit) begin
          if(!frame_limitHit) begin
            if(when_UsbOhci_l1487) begin
              if(!when_UsbOhci_l1488) begin
                if(reg_hcPeriodCurrentED_isZero) begin
                  operational_periodicDone <= 1'b1;
                end else begin
                  endpoint_flowType <= UsbOhciWishbone_FlowType_PERIODIC;
                  endpoint_ED_address <= reg_hcPeriodCurrentED_PCED_address;
                end
              end
            end else begin
              if(priority_bulk) begin
                if(operational_allowBulk) begin
                  if(reg_hcBulkCurrentED_isZero) begin
                    if(reg_hcCommandStatus_BLF) begin
                      reg_hcBulkCurrentED_BCED_reg <= reg_hcBulkHeadED_BHED_reg;
                      reg_hcCommandStatus_BLF <= 1'b0;
                    end
                  end else begin
                    endpoint_flowType <= UsbOhciWishbone_FlowType_BULK;
                    endpoint_ED_address <= reg_hcBulkCurrentED_BCED_address;
                  end
                end
              end else begin
                if(operational_allowControl) begin
                  if(reg_hcControlCurrentED_isZero) begin
                    if(reg_hcCommandStatus_CLF) begin
                      reg_hcControlCurrentED_CCED_reg <= reg_hcControlHeadED_CHED_reg;
                      reg_hcCommandStatus_CLF <= 1'b0;
                    end
                  end else begin
                    endpoint_flowType <= UsbOhciWishbone_FlowType_CONTROL;
                    endpoint_ED_address <= reg_hcControlCurrentED_CCED_address;
                  end
                end
              end
            end
          end
        end
      end
      UsbOhciWishbone_operational_enumDef_END_POINT : begin
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_CMD : begin
      end
      UsbOhciWishbone_operational_enumDef_PERIODIC_HEAD_RSP : begin
        if(ioDma_rsp_valid) begin
          operational_periodicHeadFetched <= 1'b1;
          reg_hcPeriodCurrentED_PCED_reg <= dmaRspMux_data[31 : 4];
        end
      end
      UsbOhciWishbone_operational_enumDef_WAIT_SOF : begin
      end
      default : begin
      end
    endcase
    if(when_StateMachine_l222_3) begin
      operational_allowPeriodic <= 1'b0;
    end
    case(hc_stateReg)
      UsbOhciWishbone_hc_enumDef_RESET : begin
      end
      UsbOhciWishbone_hc_enumDef_RESUME : begin
      end
      UsbOhciWishbone_hc_enumDef_OPERATIONAL : begin
      end
      UsbOhciWishbone_hc_enumDef_SUSPEND : begin
        if(when_UsbOhci_l1625) begin
          reg_hcInterrupt_RD_status <= 1'b1;
        end
      end
      UsbOhciWishbone_hc_enumDef_ANY_TO_RESET : begin
      end
      UsbOhciWishbone_hc_enumDef_ANY_TO_SUSPEND : begin
      end
      default : begin
      end
    endcase
  end

  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      ioDma_cmd_payload_first <= 1'b1;
    end else begin
      if(ioDma_cmd_fire_3) begin
        ioDma_cmd_payload_first <= ioDma_cmd_payload_last;
      end
    end
  end


endmodule

module UsbOhciWishbone_WishboneToBmb (
  input               io_input_CYC,
  input               io_input_STB,
  output              io_input_ACK,
  input               io_input_WE,
  input      [9:0]    io_input_ADR,
  output     [31:0]   io_input_DAT_MISO,
  input      [31:0]   io_input_DAT_MOSI,
  input      [3:0]    io_input_SEL,
  output              io_output_cmd_valid,
  input               io_output_cmd_ready,
  output              io_output_cmd_payload_last,
  output     [0:0]    io_output_cmd_payload_fragment_opcode,
  output     [11:0]   io_output_cmd_payload_fragment_address,
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

module UsbOhciWishbone_BmbToWishbone (
  input               io_input_cmd_valid,
  output              io_input_cmd_ready,
  input               io_input_cmd_payload_last,
  input      [0:0]    io_input_cmd_payload_fragment_opcode,
  input      [31:0]   io_input_cmd_payload_fragment_address,
  input      [5:0]    io_input_cmd_payload_fragment_length,
  input      [31:0]   io_input_cmd_payload_fragment_data,
  input      [3:0]    io_input_cmd_payload_fragment_mask,
  output              io_input_rsp_valid,
  input               io_input_rsp_ready,
  output              io_input_rsp_payload_last,
  output     [0:0]    io_input_rsp_payload_fragment_opcode,
  output     [31:0]   io_input_rsp_payload_fragment_data,
  output              io_output_CYC,
  output              io_output_STB,
  input               io_output_ACK,
  output              io_output_WE,
  output     [29:0]   io_output_ADR,
  input      [31:0]   io_output_DAT_MISO,
  output     [31:0]   io_output_DAT_MOSI,
  output     [3:0]    io_output_SEL,
  input               io_output_ERR,
  output     [2:0]    io_output_CTI,
  output     [1:0]    io_output_BTE,
  input               ctrl_clk,
  input               ctrl_reset
);

  wire       [11:0]   _zz_io_output_ADR;
  wire       [11:0]   _zz_io_output_ADR_1;
  wire       [11:0]   _zz_io_output_ADR_2;
  wire       [11:0]   _zz_io_output_ADR_3;
  wire       [5:0]    _zz_io_output_ADR_4;
  wire                inputCmd_valid;
  wire                inputCmd_ready;
  wire                inputCmd_payload_last;
  wire       [0:0]    inputCmd_payload_fragment_opcode;
  wire       [31:0]   inputCmd_payload_fragment_address;
  wire       [5:0]    inputCmd_payload_fragment_length;
  wire       [31:0]   inputCmd_payload_fragment_data;
  wire       [3:0]    inputCmd_payload_fragment_mask;
  reg                 io_input_cmd_rValid;
  wire                inputCmd_fire;
  reg                 io_input_cmd_rData_last;
  reg        [0:0]    io_input_cmd_rData_fragment_opcode;
  reg        [31:0]   io_input_cmd_rData_fragment_address;
  reg        [5:0]    io_input_cmd_rData_fragment_length;
  reg        [31:0]   io_input_cmd_rData_fragment_data;
  reg        [3:0]    io_input_cmd_rData_fragment_mask;
  reg        [3:0]    beatCounter;
  wire                beatLast;
  wire                when_BmbToWishbone_l27;
  wire                when_BmbToWishbone_l29;
  wire                inputCmd_fire_1;
  reg                 inputCmd_payload_first;
  reg                 _zz_io_input_rsp_valid;
  reg        [31:0]   io_output_DAT_MISO_regNext;
  reg                 beatLast_regNext;

  assign _zz_io_output_ADR = (_zz_io_output_ADR_1 + _zz_io_output_ADR_3);
  assign _zz_io_output_ADR_2 = inputCmd_payload_fragment_address[11 : 0];
  assign _zz_io_output_ADR_1 = _zz_io_output_ADR_2;
  assign _zz_io_output_ADR_4 = ({2'd0,beatCounter} <<< 2);
  assign _zz_io_output_ADR_3 = {6'd0, _zz_io_output_ADR_4};
  assign inputCmd_fire = (inputCmd_valid && inputCmd_ready);
  assign io_input_cmd_ready = (! io_input_cmd_rValid);
  assign inputCmd_valid = io_input_cmd_rValid;
  assign inputCmd_payload_last = io_input_cmd_rData_last;
  assign inputCmd_payload_fragment_opcode = io_input_cmd_rData_fragment_opcode;
  assign inputCmd_payload_fragment_address = io_input_cmd_rData_fragment_address;
  assign inputCmd_payload_fragment_length = io_input_cmd_rData_fragment_length;
  assign inputCmd_payload_fragment_data = io_input_cmd_rData_fragment_data;
  assign inputCmd_payload_fragment_mask = io_input_cmd_rData_fragment_mask;
  assign beatLast = (beatCounter == inputCmd_payload_fragment_length[5 : 2]);
  assign when_BmbToWishbone_l27 = (inputCmd_valid && io_output_ACK);
  assign when_BmbToWishbone_l29 = (inputCmd_ready && inputCmd_payload_last);
  assign io_output_ADR = ({inputCmd_payload_fragment_address[31 : 12],_zz_io_output_ADR} >>> 2);
  assign inputCmd_fire_1 = (inputCmd_valid && inputCmd_ready);
  assign io_output_CTI = (inputCmd_payload_last ? (inputCmd_payload_first ? 3'b000 : 3'b111) : 3'b010);
  assign io_output_BTE = 2'b00;
  assign io_output_SEL = ((inputCmd_payload_fragment_opcode == 1'b1) ? inputCmd_payload_fragment_mask : 4'b1111);
  assign io_output_WE = (inputCmd_payload_fragment_opcode == 1'b1);
  assign io_output_DAT_MOSI = inputCmd_payload_fragment_data;
  assign inputCmd_ready = (io_output_ACK && ((inputCmd_payload_fragment_opcode == 1'b1) || beatLast));
  assign io_output_CYC = inputCmd_valid;
  assign io_output_STB = inputCmd_valid;
  assign io_input_rsp_valid = _zz_io_input_rsp_valid;
  assign io_input_rsp_payload_fragment_data = io_output_DAT_MISO_regNext;
  assign io_input_rsp_payload_last = beatLast_regNext;
  assign io_input_rsp_payload_fragment_opcode = 1'b0;
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      io_input_cmd_rValid <= 1'b0;
      beatCounter <= 4'b0000;
      inputCmd_payload_first <= 1'b1;
      _zz_io_input_rsp_valid <= 1'b0;
    end else begin
      if(io_input_cmd_valid) begin
        io_input_cmd_rValid <= 1'b1;
      end
      if(inputCmd_fire) begin
        io_input_cmd_rValid <= 1'b0;
      end
      if(when_BmbToWishbone_l27) begin
        beatCounter <= (beatCounter + 4'b0001);
        if(when_BmbToWishbone_l29) begin
          beatCounter <= 4'b0000;
        end
      end
      if(inputCmd_fire_1) begin
        inputCmd_payload_first <= inputCmd_payload_last;
      end
      _zz_io_input_rsp_valid <= ((inputCmd_valid && io_output_ACK) && ((inputCmd_payload_fragment_opcode == 1'b0) || beatLast));
    end
  end

  always @(posedge ctrl_clk) begin
    if(io_input_cmd_ready) begin
      io_input_cmd_rData_last <= io_input_cmd_payload_last;
      io_input_cmd_rData_fragment_opcode <= io_input_cmd_payload_fragment_opcode;
      io_input_cmd_rData_fragment_address <= io_input_cmd_payload_fragment_address;
      io_input_cmd_rData_fragment_length <= io_input_cmd_payload_fragment_length;
      io_input_cmd_rData_fragment_data <= io_input_cmd_payload_fragment_data;
      io_input_cmd_rData_fragment_mask <= io_input_cmd_payload_fragment_mask;
    end
    io_output_DAT_MISO_regNext <= io_output_DAT_MISO;
    beatLast_regNext <= beatLast;
  end


endmodule

//UsbOhciWishbone_StreamCCByToggle_1 replaced by UsbOhciWishbone_StreamCCByToggle_1

//UsbOhciWishbone_StreamCCByToggle_1 replaced by UsbOhciWishbone_StreamCCByToggle_1

//UsbOhciWishbone_StreamCCByToggle_1 replaced by UsbOhciWishbone_StreamCCByToggle_1

//UsbOhciWishbone_StreamCCByToggle_1 replaced by UsbOhciWishbone_StreamCCByToggle_1

//UsbOhciWishbone_PulseCCByToggle_1 replaced by UsbOhciWishbone_PulseCCByToggle_1

//UsbOhciWishbone_PulseCCByToggle_1 replaced by UsbOhciWishbone_PulseCCByToggle_1

//UsbOhciWishbone_PulseCCByToggle_1 replaced by UsbOhciWishbone_PulseCCByToggle_1

//UsbOhciWishbone_BufferCC_32 replaced by UsbOhciWishbone_BufferCC_32

//UsbOhciWishbone_BufferCC_32 replaced by UsbOhciWishbone_BufferCC_32

//UsbOhciWishbone_BufferCC_29 replaced by UsbOhciWishbone_BufferCC_29

//UsbOhciWishbone_BufferCC_29 replaced by UsbOhciWishbone_BufferCC_29

//UsbOhciWishbone_StreamCCByToggle_1 replaced by UsbOhciWishbone_StreamCCByToggle_1

//UsbOhciWishbone_StreamCCByToggle_1 replaced by UsbOhciWishbone_StreamCCByToggle_1

//UsbOhciWishbone_StreamCCByToggle_1 replaced by UsbOhciWishbone_StreamCCByToggle_1

module UsbOhciWishbone_StreamCCByToggle_1 (
  input               io_input_valid,
  output              io_input_ready,
  output              io_output_valid,
  input               io_output_ready,
  input               ctrl_clk,
  input               ctrl_reset,
  input               phy_clk,
  input               ctrl_reset_syncronized
);

  wire                outHitSignal_buffercc_io_dataOut;
  wire                pushArea_target_buffercc_io_dataOut;
  wire                outHitSignal;
  wire                pushArea_hit;
  wire                pushArea_accept;
  reg                 pushArea_target;
  reg                 _zz_io_input_ready;
  wire                popArea_stream_valid;
  wire                popArea_stream_ready;
  wire                popArea_target;
  wire                popArea_stream_fire;
  reg                 popArea_hit;

  UsbOhciWishbone_BufferCC outHitSignal_buffercc (
    .io_dataIn     (outHitSignal                      ), //i
    .io_dataOut    (outHitSignal_buffercc_io_dataOut  ), //o
    .ctrl_clk      (ctrl_clk                          ), //i
    .ctrl_reset    (ctrl_reset                        )  //i
  );
  UsbOhciWishbone_BufferCC_2 pushArea_target_buffercc (
    .io_dataIn                 (pushArea_target                      ), //i
    .io_dataOut                (pushArea_target_buffercc_io_dataOut  ), //o
    .phy_clk                   (phy_clk                              ), //i
    .ctrl_reset_syncronized    (ctrl_reset_syncronized               )  //i
  );
  assign pushArea_hit = outHitSignal_buffercc_io_dataOut;
  assign pushArea_accept = ((! _zz_io_input_ready) && io_input_valid);
  assign io_input_ready = (_zz_io_input_ready && (pushArea_hit == pushArea_target));
  assign popArea_target = pushArea_target_buffercc_io_dataOut;
  assign popArea_stream_fire = (popArea_stream_valid && popArea_stream_ready);
  assign outHitSignal = popArea_hit;
  assign popArea_stream_valid = (popArea_target != popArea_hit);
  assign io_output_valid = popArea_stream_valid;
  assign popArea_stream_ready = io_output_ready;
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      pushArea_target <= 1'b0;
      _zz_io_input_ready <= 1'b0;
    end else begin
      if(pushArea_accept) begin
        pushArea_target <= (! pushArea_target);
      end
      if(pushArea_accept) begin
        _zz_io_input_ready <= 1'b1;
      end
      if(io_input_ready) begin
        _zz_io_input_ready <= 1'b0;
      end
    end
  end

  always @(posedge phy_clk or posedge ctrl_reset_syncronized) begin
    if(ctrl_reset_syncronized) begin
      popArea_hit <= 1'b0;
    end else begin
      if(popArea_stream_fire) begin
        popArea_hit <= popArea_target;
      end
    end
  end


endmodule

//UsbOhciWishbone_PulseCCByToggle_1 replaced by UsbOhciWishbone_PulseCCByToggle_1

//UsbOhciWishbone_PulseCCByToggle_1 replaced by UsbOhciWishbone_PulseCCByToggle_1

//UsbOhciWishbone_PulseCCByToggle_1 replaced by UsbOhciWishbone_PulseCCByToggle_1

//UsbOhciWishbone_BufferCC_32 replaced by UsbOhciWishbone_BufferCC_32

//UsbOhciWishbone_BufferCC_32 replaced by UsbOhciWishbone_BufferCC_32

//UsbOhciWishbone_BufferCC_29 replaced by UsbOhciWishbone_BufferCC_29

//UsbOhciWishbone_BufferCC_29 replaced by UsbOhciWishbone_BufferCC_29

module UsbOhciWishbone_PulseCCByToggle_1 (
  input               io_pulseIn,
  output              io_pulseOut,
  input               phy_clk,
  input               phy_reset,
  input               ctrl_clk,
  input               phy_reset_syncronized
);

  wire                inArea_target_buffercc_io_dataOut;
  reg                 inArea_target;
  wire                outArea_target;
  reg                 outArea_target_regNext;

  UsbOhciWishbone_BufferCC_4 inArea_target_buffercc (
    .io_dataIn                (inArea_target                      ), //i
    .io_dataOut               (inArea_target_buffercc_io_dataOut  ), //o
    .ctrl_clk                 (ctrl_clk                           ), //i
    .phy_reset_syncronized    (phy_reset_syncronized              )  //i
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

  always @(posedge ctrl_clk or posedge phy_reset_syncronized) begin
    if(phy_reset_syncronized) begin
      outArea_target_regNext <= 1'b0;
    end else begin
      outArea_target_regNext <= outArea_target;
    end
  end


endmodule

//UsbOhciWishbone_BufferCC_32 replaced by UsbOhciWishbone_BufferCC_32

module UsbOhciWishbone_FlowCCByToggle (
  input               io_input_valid,
  input               io_input_payload_stuffingError,
  input      [7:0]    io_input_payload_data,
  output              io_output_valid,
  output              io_output_payload_stuffingError,
  output     [7:0]    io_output_payload_data,
  input               phy_clk,
  input               phy_reset,
  input               ctrl_clk,
  input               phy_reset_syncronized
);

  wire                inputArea_target_buffercc_io_dataOut;
  wire                outHitSignal;
  reg                 inputArea_target;
  reg                 inputArea_data_stuffingError;
  reg        [7:0]    inputArea_data_data;
  wire                outputArea_target;
  reg                 outputArea_hit;
  wire                outputArea_flow_valid;
  wire                outputArea_flow_payload_stuffingError;
  wire       [7:0]    outputArea_flow_payload_data;
  reg                 outputArea_flow_m2sPipe_valid;
  reg                 outputArea_flow_m2sPipe_payload_stuffingError;
  reg        [7:0]    outputArea_flow_m2sPipe_payload_data;

  UsbOhciWishbone_BufferCC_4 inputArea_target_buffercc (
    .io_dataIn                (inputArea_target                      ), //i
    .io_dataOut               (inputArea_target_buffercc_io_dataOut  ), //o
    .ctrl_clk                 (ctrl_clk                              ), //i
    .phy_reset_syncronized    (phy_reset_syncronized                 )  //i
  );
  assign outputArea_target = inputArea_target_buffercc_io_dataOut;
  assign outputArea_flow_valid = (outputArea_target != outputArea_hit);
  assign outputArea_flow_payload_stuffingError = inputArea_data_stuffingError;
  assign outputArea_flow_payload_data = inputArea_data_data;
  assign io_output_valid = outputArea_flow_m2sPipe_valid;
  assign io_output_payload_stuffingError = outputArea_flow_m2sPipe_payload_stuffingError;
  assign io_output_payload_data = outputArea_flow_m2sPipe_payload_data;
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
      inputArea_data_stuffingError <= io_input_payload_stuffingError;
      inputArea_data_data <= io_input_payload_data;
    end
  end

  always @(posedge ctrl_clk or posedge phy_reset_syncronized) begin
    if(phy_reset_syncronized) begin
      outputArea_flow_m2sPipe_valid <= 1'b0;
      outputArea_hit <= 1'b0;
    end else begin
      outputArea_hit <= outputArea_target;
      outputArea_flow_m2sPipe_valid <= outputArea_flow_valid;
    end
  end

  always @(posedge ctrl_clk) begin
    if(outputArea_flow_valid) begin
      outputArea_flow_m2sPipe_payload_stuffingError <= outputArea_flow_payload_stuffingError;
      outputArea_flow_m2sPipe_payload_data <= outputArea_flow_payload_data;
    end
  end


endmodule

module UsbOhciWishbone_PulseCCByToggle (
  input               io_pulseIn,
  output              io_pulseOut,
  input               phy_clk,
  input               phy_reset,
  input               ctrl_clk,
  output              phy_reset_syncronized_1
);

  wire                bufferCC_io_dataOut;
  wire                inArea_target_buffercc_io_dataOut;
  reg                 inArea_target;
  wire                phy_reset_syncronized;
  wire                outArea_target;
  reg                 outArea_target_regNext;

  UsbOhciWishbone_BufferCC_3 bufferCC (
    .io_dataIn     (1'b0                 ), //i
    .io_dataOut    (bufferCC_io_dataOut  ), //o
    .ctrl_clk      (ctrl_clk             ), //i
    .phy_reset     (phy_reset            )  //i
  );
  UsbOhciWishbone_BufferCC_4 inArea_target_buffercc (
    .io_dataIn                (inArea_target                      ), //i
    .io_dataOut               (inArea_target_buffercc_io_dataOut  ), //o
    .ctrl_clk                 (ctrl_clk                           ), //i
    .phy_reset_syncronized    (phy_reset_syncronized              )  //i
  );
  assign phy_reset_syncronized = bufferCC_io_dataOut;
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

module UsbOhciWishbone_StreamCCByToggle (
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
  input               phy_clk,
  output              ctrl_reset_syncronized_1
);

  wire                outHitSignal_buffercc_io_dataOut;
  wire                bufferCC_io_dataOut;
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
  wire                when_Stream_l342;

  UsbOhciWishbone_BufferCC outHitSignal_buffercc (
    .io_dataIn     (outHitSignal                      ), //i
    .io_dataOut    (outHitSignal_buffercc_io_dataOut  ), //o
    .ctrl_clk      (ctrl_clk                          ), //i
    .ctrl_reset    (ctrl_reset                        )  //i
  );
  UsbOhciWishbone_BufferCC_1 bufferCC (
    .io_dataIn     (1'b0                 ), //i
    .io_dataOut    (bufferCC_io_dataOut  ), //o
    .phy_clk       (phy_clk              ), //i
    .ctrl_reset    (ctrl_reset           )  //i
  );
  UsbOhciWishbone_BufferCC_2 pushArea_target_buffercc (
    .io_dataIn                 (pushArea_target                      ), //i
    .io_dataOut                (pushArea_target_buffercc_io_dataOut  ), //o
    .phy_clk                   (phy_clk                              ), //i
    .ctrl_reset_syncronized    (ctrl_reset_syncronized               )  //i
  );
  assign pushArea_hit = outHitSignal_buffercc_io_dataOut;
  assign io_input_fire = (io_input_valid && io_input_ready);
  assign pushArea_accept = io_input_fire;
  assign io_input_ready = (pushArea_hit == pushArea_target);
  assign ctrl_reset_syncronized = bufferCC_io_dataOut;
  assign popArea_target = pushArea_target_buffercc_io_dataOut;
  assign popArea_stream_fire = (popArea_stream_valid && popArea_stream_ready);
  assign outHitSignal = popArea_hit;
  assign popArea_stream_valid = (popArea_target != popArea_hit);
  assign popArea_stream_payload_last = pushArea_data_last;
  assign popArea_stream_payload_fragment = pushArea_data_fragment;
  assign popArea_stream_fire_1 = (popArea_stream_valid && popArea_stream_ready);
  always @(*) begin
    popArea_stream_ready = popArea_stream_m2sPipe_ready;
    if(when_Stream_l342) begin
      popArea_stream_ready = 1'b1;
    end
  end

  assign when_Stream_l342 = (! popArea_stream_m2sPipe_valid);
  assign popArea_stream_m2sPipe_valid = popArea_stream_rValid;
  assign popArea_stream_m2sPipe_payload_last = popArea_stream_rData_last;
  assign popArea_stream_m2sPipe_payload_fragment = popArea_stream_rData_fragment;
  assign io_output_valid = popArea_stream_m2sPipe_valid;
  assign popArea_stream_m2sPipe_ready = io_output_ready;
  assign io_output_payload_last = popArea_stream_m2sPipe_payload_last;
  assign io_output_payload_fragment = popArea_stream_m2sPipe_payload_fragment;
  assign ctrl_reset_syncronized_1 = ctrl_reset_syncronized;
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

module UsbOhciWishbone_BufferCC_32 (
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

//UsbOhciWishbone_BufferCC_29 replaced by UsbOhciWishbone_BufferCC_29

//UsbOhciWishbone_BufferCC_29 replaced by UsbOhciWishbone_BufferCC_29

module UsbOhciWishbone_BufferCC_29 (
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

//UsbOhciWishbone_UsbLsFsPhyFilter replaced by UsbOhciWishbone_UsbLsFsPhyFilter

module UsbOhciWishbone_UsbLsFsPhyFilter (
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

module UsbOhciWishbone_Crc_2 (
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

module UsbOhciWishbone_Crc_1 (
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

module UsbOhciWishbone_Crc (
  input               io_flush,
  input               io_input_valid,
  input      [10:0]   io_input_payload,
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
  wire       [4:0]    _zz_state_9;
  wire       [4:0]    _zz_state_10;
  wire       [4:0]    _zz_state_11;
  reg        [4:0]    state_11;
  reg        [4:0]    state_10;
  reg        [4:0]    state_9;
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
  assign _zz_state_9 = (state_8 <<< 1);
  assign _zz_state_10 = (state_9 <<< 1);
  assign _zz_state_11 = (state_10 <<< 1);
  always @(*) begin
    state_11 = state_10;
    state_11 = (_zz_state_11 ^ ((io_input_payload[10] ^ state_10[4]) ? 5'h05 : 5'h0));
  end

  always @(*) begin
    state_10 = state_9;
    state_10 = (_zz_state_10 ^ ((io_input_payload[9] ^ state_9[4]) ? 5'h05 : 5'h0));
  end

  always @(*) begin
    state_9 = state_8;
    state_9 = (_zz_state_9 ^ ((io_input_payload[8] ^ state_8[4]) ? 5'h05 : 5'h0));
  end

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

  assign stateXor = (state ^ 5'h1f);
  assign accXor = (state_11 ^ 5'h1f);
  assign io_result = {stateXor[0],{stateXor[1],{stateXor[2],{stateXor[3],stateXor[4]}}}};
  assign io_resultNext = {accXor[0],{accXor[1],{accXor[2],{accXor[3],accXor[4]}}}};
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      state <= 5'h1f;
    end else begin
      if(io_input_valid) begin
        state <= state_11;
      end
      if(io_flush) begin
        state <= 5'h1f;
      end
    end
  end


endmodule

module UsbOhciWishbone_StreamFifo (
  input               io_push_valid,
  output              io_push_ready,
  input      [31:0]   io_push_payload,
  output              io_pop_valid,
  input               io_pop_ready,
  output     [31:0]   io_pop_payload,
  input               io_flush,
  output     [9:0]    io_occupancy,
  output     [9:0]    io_availability,
  input               ctrl_clk,
  input               ctrl_reset
);

  reg        [31:0]   _zz_logic_ram_port0;
  wire       [8:0]    _zz_logic_pushPtr_valueNext;
  wire       [0:0]    _zz_logic_pushPtr_valueNext_1;
  wire       [8:0]    _zz_logic_popPtr_valueNext;
  wire       [0:0]    _zz_logic_popPtr_valueNext_1;
  wire                _zz_logic_ram_port;
  wire                _zz_io_pop_payload;
  wire       [8:0]    _zz_io_availability;
  reg                 _zz_1;
  reg                 logic_pushPtr_willIncrement;
  reg                 logic_pushPtr_willClear;
  reg        [8:0]    logic_pushPtr_valueNext;
  reg        [8:0]    logic_pushPtr_value;
  wire                logic_pushPtr_willOverflowIfInc;
  wire                logic_pushPtr_willOverflow;
  reg                 logic_popPtr_willIncrement;
  reg                 logic_popPtr_willClear;
  reg        [8:0]    logic_popPtr_valueNext;
  reg        [8:0]    logic_popPtr_value;
  wire                logic_popPtr_willOverflowIfInc;
  wire                logic_popPtr_willOverflow;
  wire                logic_ptrMatch;
  reg                 logic_risingOccupancy;
  wire                logic_pushing;
  wire                logic_popping;
  wire                logic_empty;
  wire                logic_full;
  reg                 _zz_io_pop_valid;
  wire                when_Stream_l954;
  wire       [8:0]    logic_ptrDif;
  reg [31:0] logic_ram [0:511];

  assign _zz_logic_pushPtr_valueNext_1 = logic_pushPtr_willIncrement;
  assign _zz_logic_pushPtr_valueNext = {8'd0, _zz_logic_pushPtr_valueNext_1};
  assign _zz_logic_popPtr_valueNext_1 = logic_popPtr_willIncrement;
  assign _zz_logic_popPtr_valueNext = {8'd0, _zz_logic_popPtr_valueNext_1};
  assign _zz_io_availability = (logic_popPtr_value - logic_pushPtr_value);
  assign _zz_io_pop_payload = 1'b1;
  always @(posedge ctrl_clk) begin
    if(_zz_io_pop_payload) begin
      _zz_logic_ram_port0 <= logic_ram[logic_popPtr_valueNext];
    end
  end

  always @(posedge ctrl_clk) begin
    if(_zz_1) begin
      logic_ram[logic_pushPtr_value] <= io_push_payload;
    end
  end

  always @(*) begin
    _zz_1 = 1'b0;
    if(logic_pushing) begin
      _zz_1 = 1'b1;
    end
  end

  always @(*) begin
    logic_pushPtr_willIncrement = 1'b0;
    if(logic_pushing) begin
      logic_pushPtr_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    logic_pushPtr_willClear = 1'b0;
    if(io_flush) begin
      logic_pushPtr_willClear = 1'b1;
    end
  end

  assign logic_pushPtr_willOverflowIfInc = (logic_pushPtr_value == 9'h1ff);
  assign logic_pushPtr_willOverflow = (logic_pushPtr_willOverflowIfInc && logic_pushPtr_willIncrement);
  always @(*) begin
    logic_pushPtr_valueNext = (logic_pushPtr_value + _zz_logic_pushPtr_valueNext);
    if(logic_pushPtr_willClear) begin
      logic_pushPtr_valueNext = 9'h0;
    end
  end

  always @(*) begin
    logic_popPtr_willIncrement = 1'b0;
    if(logic_popping) begin
      logic_popPtr_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    logic_popPtr_willClear = 1'b0;
    if(io_flush) begin
      logic_popPtr_willClear = 1'b1;
    end
  end

  assign logic_popPtr_willOverflowIfInc = (logic_popPtr_value == 9'h1ff);
  assign logic_popPtr_willOverflow = (logic_popPtr_willOverflowIfInc && logic_popPtr_willIncrement);
  always @(*) begin
    logic_popPtr_valueNext = (logic_popPtr_value + _zz_logic_popPtr_valueNext);
    if(logic_popPtr_willClear) begin
      logic_popPtr_valueNext = 9'h0;
    end
  end

  assign logic_ptrMatch = (logic_pushPtr_value == logic_popPtr_value);
  assign logic_pushing = (io_push_valid && io_push_ready);
  assign logic_popping = (io_pop_valid && io_pop_ready);
  assign logic_empty = (logic_ptrMatch && (! logic_risingOccupancy));
  assign io_push_ready = (! logic_full);
  assign io_pop_valid = ((! logic_empty) && (! (_zz_io_pop_valid && (! logic_full))));
  assign io_pop_payload = _zz_logic_ram_port0;
  assign when_Stream_l954 = (logic_pushing != logic_popping);
  assign logic_ptrDif = (logic_pushPtr_value - logic_popPtr_value);
  assign io_occupancy = {(logic_risingOccupancy && logic_ptrMatch),logic_ptrDif};
  assign io_availability = {((! logic_risingOccupancy) && logic_ptrMatch),_zz_io_availability};
  assign logic_full = 1'b0;
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      logic_pushPtr_value <= 9'h0;
      logic_popPtr_value <= 9'h0;
      logic_risingOccupancy <= 1'b0;
      _zz_io_pop_valid <= 1'b0;
    end else begin
      logic_pushPtr_value <= logic_pushPtr_valueNext;
      logic_popPtr_value <= logic_popPtr_valueNext;
      _zz_io_pop_valid <= (logic_popPtr_valueNext == logic_pushPtr_value);
      if(when_Stream_l954) begin
        logic_risingOccupancy <= logic_pushing;
      end
      if(io_flush) begin
        logic_risingOccupancy <= 1'b0;
      end
    end
  end


endmodule

//UsbOhciWishbone_BufferCC_2 replaced by UsbOhciWishbone_BufferCC_2

//UsbOhciWishbone_BufferCC replaced by UsbOhciWishbone_BufferCC

//UsbOhciWishbone_BufferCC_2 replaced by UsbOhciWishbone_BufferCC_2

//UsbOhciWishbone_BufferCC replaced by UsbOhciWishbone_BufferCC

//UsbOhciWishbone_BufferCC_2 replaced by UsbOhciWishbone_BufferCC_2

//UsbOhciWishbone_BufferCC replaced by UsbOhciWishbone_BufferCC

//UsbOhciWishbone_BufferCC_2 replaced by UsbOhciWishbone_BufferCC_2

//UsbOhciWishbone_BufferCC replaced by UsbOhciWishbone_BufferCC

//UsbOhciWishbone_BufferCC_4 replaced by UsbOhciWishbone_BufferCC_4

//UsbOhciWishbone_BufferCC_4 replaced by UsbOhciWishbone_BufferCC_4

//UsbOhciWishbone_BufferCC_4 replaced by UsbOhciWishbone_BufferCC_4

//UsbOhciWishbone_BufferCC_2 replaced by UsbOhciWishbone_BufferCC_2

//UsbOhciWishbone_BufferCC replaced by UsbOhciWishbone_BufferCC

//UsbOhciWishbone_BufferCC_2 replaced by UsbOhciWishbone_BufferCC_2

//UsbOhciWishbone_BufferCC replaced by UsbOhciWishbone_BufferCC

//UsbOhciWishbone_BufferCC_2 replaced by UsbOhciWishbone_BufferCC_2

//UsbOhciWishbone_BufferCC replaced by UsbOhciWishbone_BufferCC

//UsbOhciWishbone_BufferCC_2 replaced by UsbOhciWishbone_BufferCC_2

//UsbOhciWishbone_BufferCC replaced by UsbOhciWishbone_BufferCC

//UsbOhciWishbone_BufferCC_4 replaced by UsbOhciWishbone_BufferCC_4

//UsbOhciWishbone_BufferCC_4 replaced by UsbOhciWishbone_BufferCC_4

//UsbOhciWishbone_BufferCC_4 replaced by UsbOhciWishbone_BufferCC_4

//UsbOhciWishbone_BufferCC_4 replaced by UsbOhciWishbone_BufferCC_4

//UsbOhciWishbone_BufferCC_4 replaced by UsbOhciWishbone_BufferCC_4

module UsbOhciWishbone_BufferCC_4 (
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

module UsbOhciWishbone_BufferCC_3 (
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

module UsbOhciWishbone_BufferCC_2 (
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

module UsbOhciWishbone_BufferCC_1 (
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

module UsbOhciWishbone_BufferCC (
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
