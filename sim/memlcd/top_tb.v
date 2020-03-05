`timescale 1ns/1ps

module top_tb();

reg clk12;
initial clk12 = 1'b1;
always #41.16666 clk12 = ~clk12;

wire success;
wire [15:0] report;

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
    .sim_report(report)
);

// make sure it eventually stops running for CI mode
initial #800_000 $finish;

endmodule
