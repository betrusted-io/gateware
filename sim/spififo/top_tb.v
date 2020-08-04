`timescale 1ns/1ps

module top_tb();

/////////// boilerplate in here
`include "common.v"

/////////// DUT code below here

wire cipo;
wire sclk;
wire csn;
wire copi;

sim_bench dut (
    // don't touch these two lines
    .refclk(clk12),
    .rst(1'b0),

    // dut I/O goes here
    .com_sclk(sclk),
    .com_copi(copi),
    .com_cipo(cipo),
    .com_csn(csn),

    .peripheral_sclk(sclk),
    .peripheral_copi(copi),
    .peripheral_cipo(cipo),
    .peripheral_csn(csn),

    // don't touch these three lines
    .sim_success(success),
    .sim_done(done),
    .sim_report(report)
);

// reg [15:0] value;
// initial cipo = 1'b0;
// initial value = 16'ha503;
// always @(posedge sclk) begin
//    cipo <= value[15];
//    value <= {value[14:0],value[15]};
// end

// add extra variables for CI watching here   
initial begin
   $dumpvars(0, sclk);
   $dumpvars(0, cipo);
   $dumpvars(0, copi);
   $dumpvars(0, csn);
end

// DUT-specific end condition to make sure it eventually stops running for CI mode
initial #4_000_000 $finish;

endmodule
