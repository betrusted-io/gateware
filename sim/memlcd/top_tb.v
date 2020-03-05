`timescale 1ns/1ps

module top_tb();

/////////// boilerplate in here
`include "common.v"

/////////// DUT code below here

wire si;
wire sclk;
wire scs;

top dut (
    .refclk(clk12),
    .rst(0),
    .lcd_sclk(sclk),
    .lcd_si(si),
    .lcd_scs(scs),

    .sim_success(success),
    .sim_failure(failure),
    .sim_report(report)
);

// DUT-specific end condition to make sure it eventually stops running for CI mode
initial #800_000 $finish;

endmodule
