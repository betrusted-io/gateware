`timescale 1ns/1ps

module top_tb();

/////////// boilerplate in here
`include "common.v"

/////////// DUT code below here

wire pin;
wire [3:0] bus;

top dut (
    // don't touch these two lines
    .refclk(clk12),
    .rst(0),

    // dut I/O goes here
    .template_pin(pin),
    .template_bus(bus),

    // don't touch these three lines
    .sim_success(success),
    .sim_failure(failure),
    .sim_report(report)
);

// DUT-specific end condition to make sure it eventually stops running for CI mode
initial #800_000 $finish;

endmodule
