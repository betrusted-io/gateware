// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//

package hmac512_pkg;

  // this currently uses the
  // fully asynchronous implemenation
  localparam int NumAlerts = 1;
  localparam logic [NumAlerts-1:0] AlertAsyncOn = NumAlerts'(1'b1);

  localparam int MsgFifoDepth = 16;

  localparam int NumRound = 80;   // SHA-512

  typedef logic [63:0] sha_word_t;
  localparam int WordByte = $bits(sha_word_t)/8;

  typedef struct packed {
    sha_word_t           data;
    logic [WordByte-1:0] mask;
  } sha_fifo_t;


  localparam sha_word_t InitHash [8]= '{
    64'h6a09e667f3bcc908, 64'hbb67ae8584caa73b, 64'h3c6ef372fe94f82b, 64'ha54ff53a5f1d36f1,
    64'h510e527fade682d1, 64'h9b05688c2b3e6c1f, 64'h1f83d9abfb41bd6b, 64'h5be0cd19137e2179
  };

  localparam sha_word_t CubicRootPrime [80] = '{
    64'h428a2f98d728ae22, 64'h7137449123ef65cd, 64'hb5c0fbcfec4d3b2f, 64'he9b5dba58189dbbc, 64'h3956c25bf348b538,
    64'h59f111f1b605d019, 64'h923f82a4af194f9b, 64'hab1c5ed5da6d8118, 64'hd807aa98a3030242, 64'h12835b0145706fbe,
    64'h243185be4ee4b28c, 64'h550c7dc3d5ffb4e2, 64'h72be5d74f27b896f, 64'h80deb1fe3b1696b1, 64'h9bdc06a725c71235,
    64'hc19bf174cf692694, 64'he49b69c19ef14ad2, 64'hefbe4786384f25e3, 64'h0fc19dc68b8cd5b5, 64'h240ca1cc77ac9c65,
    64'h2de92c6f592b0275, 64'h4a7484aa6ea6e483, 64'h5cb0a9dcbd41fbd4, 64'h76f988da831153b5, 64'h983e5152ee66dfab,
    64'ha831c66d2db43210, 64'hb00327c898fb213f, 64'hbf597fc7beef0ee4, 64'hc6e00bf33da88fc2, 64'hd5a79147930aa725,
    64'h06ca6351e003826f, 64'h142929670a0e6e70, 64'h27b70a8546d22ffc, 64'h2e1b21385c26c926, 64'h4d2c6dfc5ac42aed,
    64'h53380d139d95b3df, 64'h650a73548baf63de, 64'h766a0abb3c77b2a8, 64'h81c2c92e47edaee6, 64'h92722c851482353b,
    64'ha2bfe8a14cf10364, 64'ha81a664bbc423001, 64'hc24b8b70d0f89791, 64'hc76c51a30654be30, 64'hd192e819d6ef5218,
    64'hd69906245565a910, 64'hf40e35855771202a, 64'h106aa07032bbd1b8, 64'h19a4c116b8d2d0c8, 64'h1e376c085141ab53,
    64'h2748774cdf8eeb99, 64'h34b0bcb5e19b48a8, 64'h391c0cb3c5c95a63, 64'h4ed8aa4ae3418acb, 64'h5b9cca4f7763e373,
    64'h682e6ff3d6b2b8a3, 64'h748f82ee5defb2fc, 64'h78a5636f43172f60, 64'h84c87814a1f0ab72, 64'h8cc702081a6439ec,
    64'h90befffa23631e28, 64'ha4506cebde82bde9, 64'hbef9a3f7b2c67915, 64'hc67178f2e372532b, 64'hca273eceea26619c,
    64'hd186b8c721c0c207, 64'heada7dd6cde0eb1e, 64'hf57d4f7fee6ed178, 64'h06f067aa72176fba, 64'h0a637dc5a2c898a6,
    64'h113f9804bef90dae, 64'h1b710b35131c471b, 64'h28db77f523047d84, 64'h32caab7b40c72493, 64'h3c9ebe0a15c9bebc,
    64'h431d67c49c100d4c, 64'h4cc5d4becb3e42b6, 64'h597f299cfc657e2a, 64'h5fcb6fab3ad6faec, 64'h6c44198c4a475817
  };

  function automatic sha_word_t conv_endian( input sha_word_t v, input logic swap);
    sha_word_t conv_data = {<<8{v}};
    conv_endian = (swap) ? conv_data : v ;
  endfunction : conv_endian

  function automatic sha_word_t rotr( input sha_word_t v , input int amt );
    rotr = (v >> amt) | (v << (64-amt));
  endfunction : rotr

  function automatic sha_word_t shiftr( input sha_word_t v, input int amt );
    shiftr = (v >> amt);
  endfunction : shiftr

  function automatic sha_word_t [7:0] compress( input sha_word_t w, input sha_word_t k,
                                                input sha_word_t [7:0] h_i);
    automatic sha_word_t sigma_0, sigma_1, ch, maj, temp1, temp2;

    sigma_1 = rotr(h_i[4], 14) ^ rotr(h_i[4], 18) ^ rotr(h_i[4], 41);
    ch = (h_i[4] & h_i[5]) ^ (~h_i[4] & h_i[6]);
    temp1 = (h_i[7] + sigma_1 + ch + k + w);
    sigma_0 = rotr(h_i[0], 28) ^ rotr(h_i[0], 34) ^ rotr(h_i[0], 39);
    maj = (h_i[0] & h_i[1]) ^ (h_i[0] & h_i[2]) ^ (h_i[1] & h_i[2]);
    temp2 = (sigma_0 + maj);

    compress[7] = h_i[6];          // h = g
    compress[6] = h_i[5];          // g = f
    compress[5] = h_i[4];          // f = e
    compress[4] = h_i[3] + temp1;  // e = (d + temp1)
    compress[3] = h_i[2];          // d = c
    compress[2] = h_i[1];          // c = b
    compress[1] = h_i[0];          // b = a
    compress[0] = (temp1 + temp2); // a = (temp1 + temp2)
  endfunction : compress

  function automatic sha_word_t calc_w(input sha_word_t w_0,
                                       input sha_word_t w_1,
                                       input sha_word_t w_9,
                                       input sha_word_t w_14);
    automatic sha_word_t sum0, sum1;
    sum0 = rotr(w_1,   1) ^ rotr(w_1,  8) ^ shiftr(w_1,   7);
    sum1 = rotr(w_14, 19) ^ rotr(w_14, 61) ^ shiftr(w_14,  6);
    calc_w = w_0 + sum0 + w_9 + sum1;
  endfunction : calc_w

  typedef enum logic [31:0] {
    NoError                    = 32'h 0000_0000,
    SwPushMsgWhenShaDisabled   = 32'h 0000_0001,
    SwHashStartWhenShaDisabled = 32'h 0000_0002,
    SwUpdateSecretKeyInProcess = 32'h 0000_0003,
    SwHashStartWhenActive      = 32'h 0000_0004,
    SwPushMsgWhenDisallowed    = 32'h 0000_0005
  } err_code_e;

endpackage : hmac512_pkg
