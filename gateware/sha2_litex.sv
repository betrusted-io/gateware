// adapter from sv to verilog for litex integration

module sha2_litex
  import hmac_pkg::*;
(
  input clk_i,
  input rst_ni,

  // Below Regster interface can be changed
  input [31:0]    secret_key_0,
  input [31:0]    secret_key_1,
  input [31:0]    secret_key_2,
  input [31:0]    secret_key_3,
  input [31:0]    secret_key_4,
  input [31:0]    secret_key_5,
  input [31:0]    secret_key_6,
  input [31:0]    secret_key_7,
  input [7:0]     secret_key_re,

  // Control signals
  input reg_hash_start,     // this should be a 1-cycle pulse
  input reg_hash_process,   // this should be a 1-cycle pulse

  output ctrl_freeze,  // control registers need to be locked out of updating during HMAC processng
  input        sha_en,   // If disabled, it clears internal content.
  input hmac_en,
  input endian_swap,
  input digest_swap,

  output reg_hash_done,

  input wipe_secret_re,
  input [31:0] wipe_secret_v,


  output [31:0] digest_0,
  output [31:0] digest_1,
  output [31:0] digest_2,
  output [31:0] digest_3,
  output [31:0] digest_4,
  output [31:0] digest_5,
  output [31:0] digest_6,
  output [31:0] digest_7,

  output [63:0]  msg_length,

  output [31:0] error_code,

  // data write interface
  input [31:0] msg_fifo_wdata,
  input [3:0] msg_fifo_write_mask,
  input msg_fifo_we,
  input msg_fifo_req,   // set when we want to send data
  output msg_fifo_gnt,  // set when we're able to take data

  // plumbing to fifo on level up
  output local_fifo_wvalid,
  input local_fifo_wready,
  output [31:0] local_fifo_wdata,
  input  local_fifo_rvalid,
  output local_fifo_rready,
  input [31:0] local_fifo_rdata,

  // these should trigger interrupts
  output reg err_valid,
  input err_valid_pending,
  output reg fifo_full_event
);

  logic [255:0] secret_key;

  logic        fifo_rvalid;
  logic        fifo_rready;
  sha_fifo_t   fifo_rdata;

  logic        fifo_wvalid, fifo_wready;
  sha_fifo_t   fifo_wdata;
  logic        fifo_full;
  logic        fifo_empty;
  logic [4:0]  fifo_depth;

  //logic        msg_fifo_req;
  //logic        msg_fifo_gnt;
  //logic        msg_fifo_we;
  logic [8:0]  msg_fifo_addr;   // NOT_READ
  //logic [31:0] msg_fifo_wdata;
  logic [31:0] msg_fifo_wmask;
  for (genvar i = 0; i < 31; i++) begin : gen_msg_fifo_wmask
      assign msg_fifo_wmask[i] = msg_fifo_write_mask[i / 8]; // copy byte mask to bit mask
  end
  logic [31:0] msg_fifo_rdata;
  logic        msg_fifo_rvalid;
  logic [1:0]  msg_fifo_rerror;
  logic [31:0] msg_fifo_wdata_endian;
  logic [31:0] msg_fifo_wmask_endian;

  logic        packer_ready;
  logic        packer_flush_done;

  logic        reg_fifo_wvalid;
  sha_word_t   reg_fifo_wdata;
  sha_word_t   reg_fifo_wmask;
  logic        hmac_fifo_wsel;
  logic        hmac_fifo_wvalid;
  logic [2:0]  hmac_fifo_wdata_sel;

  logic        shaf_rvalid;
  sha_fifo_t   shaf_rdata;
  logic        shaf_rready;

  //logic        sha_en;
  //logic        hmac_en;
  //logic        endian_swap;
  //logic        digest_swap;

  //logic        reg_hash_start;
  logic        sha_hash_start;
  logic        hash_start;      // Valid hash_start_signal
  //logic        reg_hash_process;
  logic        sha_hash_process;

  //logic        reg_hash_done;
  logic        sha_hash_done;

  logic [63:0] sha_message_length;
  logic [63:0] message_length;   // bits but byte based

  // basic logic conversions
  err_code_e err_code;
  assign error_code = err_code;

  sha_word_t [7:0] digest;
  assign digest_0 = conv_endian(digest[0], digest_swap);
  assign digest_1 = conv_endian(digest[1], digest_swap);
  assign digest_2 = conv_endian(digest[2], digest_swap);
  assign digest_3 = conv_endian(digest[3], digest_swap);
  assign digest_4 = conv_endian(digest[4], digest_swap);
  assign digest_5 = conv_endian(digest[5], digest_swap);
  assign digest_6 = conv_endian(digest[6], digest_swap);
  assign digest_7 = conv_endian(digest[7], digest_swap);

  assign msg_length = message_length;

  logic        wipe_secret;
  assign wipe_secret = wipe_secret_re;
  logic [31:0] wipe_v;
  assign wipe_v = wipe_secret_v;

  sha_word_t [7:0] key_adapter;
  assign key_adapter[0] = secret_key_0;
  assign key_adapter[1] = secret_key_1;
  assign key_adapter[2] = secret_key_2;
  assign key_adapter[3] = secret_key_3;
  assign key_adapter[4] = secret_key_4;
  assign key_adapter[5] = secret_key_5;
  assign key_adapter[6] = secret_key_6;
  assign key_adapter[7] = secret_key_7;

  logic                 cfg_block;  // Prevent changing config
  assign ctrl_freeze = cfg_block;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      secret_key <= '0;
    end else if (wipe_secret) begin
      secret_key <= secret_key ^ {8{wipe_v}};
    end else if (!cfg_block) begin
      // Allow updating secret key only when the engine is in Idle.
      for (int i = 0; i < 8; i++) begin
        if (secret_key_re[i]) begin
          secret_key[32*i+:32] <= key_adapter[7-i];
        end
      end
    end
  end

  /////////////////////
  // Control signals //
  /////////////////////
  assign hash_start = reg_hash_start & sha_en;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      cfg_block <= '0;
    end else if (hash_start) begin
      cfg_block <= 1'b 1;
    end else if (reg_hash_done) begin
      cfg_block <= 1'b 0;
    end
  end

  ////////////////
  // Interrupts //
  ////////////////
  logic fifo_full_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) fifo_full_q <= 1'b0;
    else fifo_full_q <= fifo_full;
  end

  //logic fifo_full_event;
  assign fifo_full_event = fifo_full & !fifo_full_q;


  assign msg_fifo_rvalid = msg_fifo_req & ~msg_fifo_we;
  assign msg_fifo_rdata  = '1;  // Return all F
  assign msg_fifo_rerror = '1;  // Return error for read access
  assign msg_fifo_gnt    = msg_fifo_req & ~hmac_fifo_wsel & packer_ready;

  // FIFO control
  sha_fifo_t reg_fifo_wentry;
  assign reg_fifo_wentry.data = conv_endian(reg_fifo_wdata, 1'b1); // always convert
  assign reg_fifo_wentry.mask = {msg_fifo_wmask[0],  msg_fifo_wmask[8],
                                 msg_fifo_wmask[16], msg_fifo_wmask[24]};
  assign fifo_full   = ~fifo_wready;
  assign fifo_empty  = ~fifo_rvalid;
  assign fifo_wvalid = (hmac_fifo_wsel && fifo_wready) ? hmac_fifo_wvalid : reg_fifo_wvalid;
  assign fifo_wdata  = (hmac_fifo_wsel) ? '{data: digest[hmac_fifo_wdata_sel], mask: '1}
                                       : reg_fifo_wentry;

  /// monkey patch in a fifo at the upper level
  assign local_fifo_wvalid = fifo_wvalid & sha_en;
  assign fifo_wready = local_fifo_wready;
  assign local_fifo_wdata = fifo_wdata;
  assign fifo_rvalid = local_fifo_rvalid;
  assign local_fifo_rready = fifo_rready;
  assign rdata = local_fifo_rdata;

  // TL-UL to MSG_FIFO byte write handling
  logic msg_write;

  assign msg_write = msg_fifo_req & msg_fifo_we & ~hmac_fifo_wsel;

  logic [$clog2(32+1)-1:0] wmask_ones;

  always_comb begin
    wmask_ones = '0;
    for (int i = 0 ; i < 32 ; i++) begin
      wmask_ones = wmask_ones + reg_fifo_wmask[i];
    end
  end

  // Calculate written message
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      message_length <= '0;
    end else if (hash_start) begin
      message_length <= '0;
    end else if (reg_fifo_wvalid && fifo_wready && !hmac_fifo_wsel) begin
      message_length <= message_length + 64'(wmask_ones);
    end
  end

  // Convert endian here
  //    prim_packer always packs to the right, but SHA engine assumes incoming
  //    to be big-endian, [31:24] comes first. So, the data is reverted after
  //    prim_packer before the message fifo. here to reverse if not big-endian
  //    before pushing to the packer.
  assign msg_fifo_wdata_endian = conv_endian(msg_fifo_wdata, ~endian_swap);
  assign msg_fifo_wmask_endian = conv_endian(msg_fifo_wmask, ~endian_swap);

  prim_packer #(
    .InW      (32),
    .OutW     (32)
  ) u_packer (
    .clk_i,
    .rst_ni,

    .valid_i      (msg_write & sha_en),
    .data_i       (msg_fifo_wdata_endian),
    .mask_i       (msg_fifo_wmask_endian),
    .ready_o      (packer_ready),

    .valid_o      (reg_fifo_wvalid),
    .data_o       (reg_fifo_wdata),
    .mask_o       (reg_fifo_wmask),
    .ready_i      (fifo_wready & ~hmac_fifo_wsel),

    .flush_i      (reg_hash_process),
    .flush_done_o (packer_flush_done) // ignore at this moment
  );


  hmac_core u_hmac (
    .clk_i,
    .rst_ni,

    .secret_key,

    .wipe_secret,
    .wipe_v,

    .hmac_en,

    .reg_hash_start   (hash_start),
    .reg_hash_process (packer_flush_done), // Trigger after all msg written
    .hash_done      (reg_hash_done),
    .sha_hash_start,
    .sha_hash_process,
    .sha_hash_done,

    .sha_rvalid     (shaf_rvalid),
    .sha_rdata      (shaf_rdata),
    .sha_rready     (shaf_rready),

    .fifo_rvalid,
    .fifo_rdata,
    .fifo_rready,

    .fifo_wsel      (hmac_fifo_wsel),
    .fifo_wvalid    (hmac_fifo_wvalid),
    .fifo_wdata_sel (hmac_fifo_wdata_sel),
    .fifo_wready,

    .message_length,
    .sha_message_length
  );

  sha2 u_sha2 (
    .clk_i,
    .rst_ni,

    .wipe_secret,
    .wipe_v,

    .fifo_rvalid      (shaf_rvalid),
    .fifo_rdata       (shaf_rdata),
    .fifo_rready      (shaf_rready),

    .sha_en,
    .hash_start       (sha_hash_start),
    .hash_process     (sha_hash_process),
    .hash_done        (sha_hash_done),

    .message_length   (sha_message_length),

    .digest
  );

  /////////////////////////
  // HMAC Error Handling //
  /////////////////////////
  logic msg_push_sha_disabled, hash_start_sha_disabled, update_seckey_inprocess;
  assign msg_push_sha_disabled = msg_write & ~sha_en;
  assign hash_start_sha_disabled = reg_hash_start & ~sha_en;

  always_comb begin
    update_seckey_inprocess = 1'b0;
    if (cfg_block) begin
      for (int i = 0 ; i < 8 ; i++) begin
        if (secret_key_re[i]) begin
          update_seckey_inprocess = update_seckey_inprocess | 1'b1;
        end
      end
    end else begin
      update_seckey_inprocess = 1'b0;
    end
  end


  // Update ERR_CODE register and interrupt only when no pending interrupt.
  // This ensures only the first event of the series of events can be seen to sw.
  // It is recommended that the software reads ERR_CODE register when interrupt
  // is pending to avoid any race conditions.
  assign err_valid = ~err_valid_pending &
                   ( msg_push_sha_disabled | hash_start_sha_disabled
                   | update_seckey_inprocess);

  always_comb begin
    err_code = NoError;
    unique case (1'b1)
      msg_push_sha_disabled: begin
        err_code = SwPushMsgWhenShaDisabled;
      end
      hash_start_sha_disabled: begin
        err_code = SwHashStartWhenShaDisabled;
      end

      update_seckey_inprocess: begin
        err_code = SwUpdateSecretKeyInProcess;
      end

      default: begin
        err_code = NoError;
      end
    endcase
  end


endmodule
