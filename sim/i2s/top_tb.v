`timescale 1ns/1ps

module top_tb();

/////////// boilerplate in here
`include "common.v"

/////////// DUT code below here

wire pin;
wire [3:0] bus;

wire sclk;
reg fpga_reset;

reg mclk;
initial mclk = 1'b1;
//always #651 mclk = ~mclk;  // 768kHz
always #65 mclk = ~mclk;  // run 10x faster for faster simulation

reg sync;
initial sync = 1'b1;
//always #(1302 * 24) sync = ~sync;  // 24x2 bit sync
always #(130 * 24) sync = ~sync;  // 24x2 bit sync

initial begin
  fpga_reset = 1'b1;  // fpga reset is extra-long to get past init delays of SPINOR; in reality, this is all handled by the config engine
  #1_000;
  fpga_reset = 1'b0;
end

wire tx0, tx1;

top dut (
    // don't touch these two lines
    .refclk(clk12),
    .rst(fpga_reset),

    // dut I/O goes here
    .i2s0_clk(mclk),
    .i2s0_tx(tx0),
    .i2s0_rx(tx0),
    .i2s0_sync(sync),

    .i2s1_clk(mclk),
    .i2s1_sync(sync),
    .i2s1_tx(tx1),

    // don't touch these three lines
    .sim_success(success),
    .sim_done(done),
    .sim_report(report)
);

// add extra variables for CI watching here   
initial begin
   $dumpvars(0, mclk);
   $dumpvars(0, sync);
   $dumpvars(0, tx0);
   $dumpvars(0, tx1);
end

// DUT-specific end condition to make sure it eventually stops running for CI mode
initial #1_000_000 $finish;

endmodule
