`timescale 1ns/1ps

module top_tb();

/////////// boilerplate in here
`include "common.v"

/////////// DUT code below here

wire pin;
wire [3:0] bus;

sim_bench dut (
    // don't touch these two lines
    .refclk(clk12),
    .rst(1'b0),

    // dut I/O goes here

    // don't touch these three lines
    .sim_success(success),
    .sim_done(done),
    .sim_report(report)
);

// add extra variables for CI watching here   
initial begin
   $dumpvars(0, pin);
   $dumpvars(0, bus);
end

// DUT-specific end condition to make sure it eventually stops running for CI mode
initial #2_000_000 $finish;

endmodule
