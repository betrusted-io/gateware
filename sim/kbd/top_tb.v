`timescale 1ns/1ps

module top_tb();

/////////// boilerplate in here
`include "common.v"

/////////// DUT code below here

reg lpclk;
initial lpclk = 1'b1;
//always #15258.789 lpclk = ~lpclk;
always #400 lpclk = ~lpclk;   // speed up faster than real-time, but still much slower than main clocks

wire [8:0] row;
wire [9:0] col;

sim_bench dut (
    // don't touch these two lines
    .refclk(clk12),
    .rst(0),

    // dut I/O goes here
    .kbd_row(row),
    .kbd_col(col),

    .lpclk(lpclk),

    // don't touch these three lines
    .sim_success(success),
    .sim_done(done),
    .sim_report(report)
);

// simulate a key that's pressed
assign row = {4'b0, col[2] | col[4], 3'b0};

// add extra variables for CI watching here   
initial begin
   $dumpvars(0, row);
   $dumpvars(0, col);
end

// DUT-specific end condition to make sure it eventually stops running for CI mode
initial #800_000 $finish;

endmodule
