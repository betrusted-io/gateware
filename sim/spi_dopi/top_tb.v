`timescale 1ns/1ps

module top_tb();

/////////// boilerplate in here
`include "common.v"

/////////// DUT code below here

wire sclk;
wire [7:0] sio;
wire dqs;
wire ecsb;
wire csn;
reg reset;

reg fpga_reset;

initial begin
  reset = 1'b1;
  #11_000;
  reset = 1'b0;
end

initial begin
  fpga_reset = 1'b1;  // fpga reset is extra-long to get past init delays of SPINOR; in reality, this is all handled by the config engine
  #40_000;
  fpga_reset = 1'b0;
end

MX66UM1G45G rom(
  .SCLK(sclk),
  .CS(csn),
  .SIO(sio),
  .DQS(dqs),
  .ECSB(ecsb),
  .RESET(~reset)
);

sim_bench dut (
    .refclk(clk12),
    .rst(fpga_reset),

    .spiflash_8x_cs_n(csn),
    .spiflash_8x_dq(sio),
    .spiflash_8x_dqs(dqs),
    .spiflash_8x_ecs_n(ecsb),
    .spiflash_8x_sclk(sclk),

    // don't touch these three lines
    .sim_success(success),
    .sim_done(done),
    .sim_report(report)
);

// add extra variables for CI watching here   
initial begin
   $dumpvars(0, sclk);
   $dumpvars(0, csn);
   $dumpvars(0, sio);
   $dumpvars(0, dqs);
   $dumpvars(0, ecsb);
   $dumpvars(0, reset);
end

// DUT-specific end condition to make sure it eventually stops running for CI mode
initial #800_000 $finish;

endmodule
