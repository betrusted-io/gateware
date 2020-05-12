// adapter from sv to verilog for litex integration

module sha512_litex
  import hmac512_pkg::*;
(
  input clk_i,
  input rst_ni,

  // Control signals
  input reg_hash_start,     // this should be a 1-cycle pulse
  input reg_hash_process,   // this should be a 1-cycle pulse

  output ctrl_freeze,  // control registers need to be locked out of updating during HMAC processng
  input        sha_en,   // If disabled, it clears internal content.
  input endian_swap,
  input digest_swap,

  output sha_hash_done,

  output [63:0] digest_0,
  output [63:0] digest_1,
  output [63:0] digest_2,
  output [63:0] digest_3,
  output [63:0] digest_4,
  output [63:0] digest_5,
  output [63:0] digest_6,
  output [63:0] digest_7,

  output [63:0]  msg_length,  // actually 128 bits long, but we only report the bottom 64

  // data write interface
  input [63:0] msg_fifo_wdata,
  input [7:0] msg_fifo_write_mask,
  input msg_fifo_we,
  input msg_fifo_req,   // set when we want to send data
  output msg_fifo_gnt,  // set when we're able to take data

  // plumbing to fifo on level up
  output local_fifo_wvalid,
  input local_fifo_wready,
  output [71:0] local_fifo_wdata_mask,
  input  local_fifo_rvalid,
  output local_fifo_rready,
  input [71:0] local_fifo_rdata_mask,

  // these should trigger interrupts
  output reg err_valid,
  input err_valid_pending,
  output reg fifo_full_event
);

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
  logic [63:0] msg_fifo_wmask;
  for (genvar i = 0; i < 64; i++) begin : gen_msg_fifo_wmask
      assign msg_fifo_wmask[i] = msg_fifo_write_mask[i / 8]; // copy byte mask to bit mask
  end
  logic [63:0] msg_fifo_rdata;
  logic        msg_fifo_rvalid;
  logic [1:0]  msg_fifo_rerror;
  logic [63:0] msg_fifo_wdata_endian;
  logic [63:0] msg_fifo_wmask_endian;

  logic        packer_ready;
  logic        packer_flush_done;

  logic        reg_fifo_wvalid;
  sha_word_t   reg_fifo_wdata;
  sha_word_t   reg_fifo_wmask;

  logic        shaf_rvalid;
  sha_fifo_t   shaf_rdata;
  logic        shaf_rready;

  logic        sha_hash_start;
  logic        hash_start;      // Valid hash_start_signal
  logic        sha_hash_process;


  logic [127:0] sha_message_length;
  logic [127:0] message_length;   // bits but byte based

  // basic logic conversions
  sha_word_t [7:0] digest;
  assign digest_0 = conv_endian(digest[0], digest_swap);
  assign digest_1 = conv_endian(digest[1], digest_swap);
  assign digest_2 = conv_endian(digest[2], digest_swap);
  assign digest_3 = conv_endian(digest[3], digest_swap);
  assign digest_4 = conv_endian(digest[4], digest_swap);
  assign digest_5 = conv_endian(digest[5], digest_swap);
  assign digest_6 = conv_endian(digest[6], digest_swap);
  assign digest_7 = conv_endian(digest[7], digest_swap);

  assign msg_length = message_length[63:0];  // return only the lower 64 bits

  logic                 cfg_block;  // Prevent changing config
  logic                 msg_allowed; // MSG_FIFO from software is allowed

  assign ctrl_freeze = cfg_block;

    /////////////////////
  // Control signals //
  /////////////////////
  assign hash_start = reg_hash_start & sha_en;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      cfg_block <= '0;
    end else if (hash_start) begin
      cfg_block <= 1'b 1;
    end else if (sha_hash_done) begin
      cfg_block <= 1'b 0;
    end
  end

  // Open up the MSG_FIFO from the TL-UL port when it is ready
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      msg_allowed <= '0;
    end else if (hash_start) begin
      msg_allowed <= 1'b 1;
    end else if (packer_flush_done) begin
      msg_allowed <= 1'b 0;
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


  ///////////////
  // Instances //
  ///////////////

  assign msg_fifo_rvalid = msg_fifo_req & ~msg_fifo_we;
  assign msg_fifo_rdata  = '1;  // Return all F
  assign msg_fifo_rerror = '1;  // Return error for read access
  assign msg_fifo_gnt    = msg_fifo_req & packer_ready;

  // FIFO control
  sha_fifo_t reg_fifo_wentry;
  assign reg_fifo_wentry.data = conv_endian(reg_fifo_wdata, 1'b1); // always convert
  assign reg_fifo_wentry.mask = {msg_fifo_wmask[0],  msg_fifo_wmask[8],
                                 msg_fifo_wmask[16], msg_fifo_wmask[24],
                                 msg_fifo_wmask[32], msg_fifo_wmask[40],
                                 msg_fifo_wmask[48], msg_fifo_wmask[56]
      };
  assign fifo_full   = ~fifo_wready;
  assign fifo_empty  = ~fifo_rvalid;
  assign fifo_wvalid = reg_fifo_wvalid;

  assign fifo_wdata  = reg_fifo_wentry;

  /// monkey patch in a fifo at the upper level
  assign local_fifo_wvalid = fifo_wvalid & sha_en;
  assign fifo_wready = local_fifo_wready;
  assign local_fifo_wdata_mask[63:0] = fifo_wdata.data;
  assign local_fifo_wdata_mask[71:64] = fifo_wdata.mask;
  assign fifo_rvalid = local_fifo_rvalid;
  assign local_fifo_rready = fifo_rready;
  assign fifo_rdata.data = local_fifo_rdata_mask[63:0];
  assign fifo_rdata.mask = local_fifo_rdata_mask[71:64];

  // TL-UL to MSG_FIFO byte write handling
  logic msg_write;

  assign msg_write = msg_fifo_req & msg_fifo_we & msg_allowed;

  logic [$clog2(64+1)-1:0] wmask_ones;

  always_comb begin
    wmask_ones = '0;
    for (int i = 0 ; i < 64 ; i++) begin
      wmask_ones = wmask_ones + msg_fifo_wmask[i];
    end
  end

  // Calculate written message
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      message_length <= '0;
    end else if (hash_start) begin
      message_length <= '0;
    end else if (msg_write && sha_en && packer_ready) begin
      message_length <= message_length + 128'(wmask_ones);
    end
  end


  // Convert endian here
  //    prim_packer always packs to the right, but SHA engine assumes incoming
  //    to be big-endian, [31:24] comes first. So, the data is reverted after
  //    prim_packer before the message fifo. here to reverse if not big-endian
  //    before pushing to the packer.
  assign msg_fifo_wdata_endian = conv_endian(msg_fifo_wdata, ~endian_swap);
  assign msg_fifo_wmask_endian = conv_endian(msg_fifo_wmask, ~endian_swap);

  prim_packer512 #(
    .InW      (64),
    .OutW     (64)
  ) u_packer512 (
    .clk_i,
    .rst_ni,

    .valid_i      (msg_write & sha_en),
    .data_i       (msg_fifo_wdata_endian),
    .mask_i       (msg_fifo_wmask_endian),
    .ready_o      (packer_ready),

    .valid_o      (reg_fifo_wvalid),
    .data_o       (reg_fifo_wdata),
    .mask_o       (reg_fifo_wmask),
    .ready_i      (fifo_wready),

    .flush_i      (reg_hash_process),
    .flush_done_o (packer_flush_done) // ignore at this moment
  );

  assign  shaf_rvalid = fifo_rvalid;
  assign  shaf_rdata = fifo_rdata;
  assign  fifo_rready = shaf_rready;
  assign sha_hash_start = hash_start;
  assign sha_hash_process = reg_hash_process;
  assign sha_message_length = message_length;
  sha512 u_sha512 (
    .clk_i,
    .rst_ni,

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

endmodule
