`timescale 1ns/1ps

module top_tb();

/////////// boilerplate in here
`include "common.v"

/////////// DUT code below here

wire pin;
wire [3:0] bus;

wire sram_oe_n;
wire [31:0] sram_d;
wire [21:0] sram_adr;

top dut (
    // don't touch these two lines
    .refclk(clk12),
    .rst(0),

    // dut I/O goes here
    .sram_d(sram_d),
    .sram_oe_n(sram_oe_n),
    .sram_adr(sram_adr),

    // don't touch these three lines
    .sim_success(success),
    .sim_done(done),
    .sim_report(report)
);

assign sram_d = sram_oe_n ? 32'hzzzz_zzzzz : (sram_adr + 32'h0001_0000);

// add extra variables for CI watching here   
initial begin
   $dumpvars(0, sram_d);
   $dumpvars(0, sram_adr);
   $dumpvars(0, sram_oe_n);
end

// DUT-specific end condition to make sure it eventually stops running for CI mode
initial #800_000 $finish;

endmodule
