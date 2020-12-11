`timescale 1ns/1ps

module top_tb();

/////////// boilerplate in here
`include "common.v"

/////////// DUT code below here

wire noisebias_on;
wire [1:0] noise_on;

sim_bench dut (
    // don't touch these two lines
    .refclk(clk12),
    .rst(1'b0),

    // dut I/O goes here
    .noise_noisebias_on(noisebias_on),
    .noise_noise_on(noise_on),

	.analog_usbdet_p(0),
	.analog_usbdet_n(0),
	.analog_vbus_div(0),
	.analog_noise0(0),
	.analog_noise1(0),
	.analog_usbdet_p_n(0),
	.analog_usbdet_n_n(0),
	.analog_vbus_div_n(0),
	.analog_noise0_n(0),
	.analog_noise1_n(0),
	.analog_ana_vn(0),
	.analog_ana_vp(0),

    // don't touch these three lines
    .sim_success(success),
    .sim_done(done),
    .sim_report(report)
);

// add extra variables for CI watching here   
initial begin
   $dumpvars(0, noisebias_on);
   $dumpvars(0, noise_on);
end

// DUT-specific end condition to make sure it eventually stops running for CI mode
initial #80_000_000 $finish;

endmodule
