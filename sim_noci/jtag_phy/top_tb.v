`timescale 1ns/1ps

module top_tb();

/////////// boilerplate in here
`include "common.v"

/////////// DUT code below here

wire tck, tdi, tms;
reg tdo;

initial begin
    assign tdo = 1'b1; // just return an 0x3F for now
end

sim_bench dut (
    // don't touch these two lines
    .refclk(clk12),
    .rst(0),

    // dut I/O goes here
    .jtag_tdi(tdi),
    .jtag_tdo(tdo),
    .jtag_tms(tms),
    .jtag_tck(tck),

    // don't touch these three lines
    .sim_success(success),
    .sim_done(done),
    .sim_report(report)
);

// add extra variables for CI watching here   
initial begin
   $dumpvars(0, tck);
   $dumpvars(0, tdi);
   $dumpvars(0, tdo);
   $dumpvars(0, tms);
end

// DUT-specific end condition to make sure it eventually stops running for CI mode
initial #800_000 $finish;

endmodule
