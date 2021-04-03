`timescale 1ns/1ps

module top_tb();

/////////// boilerplate in here
`include "common.v"

/////////// DUT code below here

reg lpclk;
initial lpclk = 1'b1;
//always #15258.789 lpclk = ~lpclk;
always #400 lpclk = ~lpclk;   // speed up faster than real-time, but still much slower than main clocks

reg  [8:0] row;
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

// simulate two key presses, the first one bounces on release, the second one holds until end of simulation
reg [10:0] presscount;
initial presscount = 11'd0;
always @(posedge lpclk) begin
   presscount <= presscount + 1;
end
always @(*) begin
   if (presscount < 11'd300) begin
      row <= {4'b0, col[2] | col[4], 3'b0}; // initial key press, long enough to debounce
   end else if ((presscount < 11'd600) && (presscount < 11'd650)) begin
      row <= 0;  // bounce it
   end else if ((presscount < 11'd700) && (presscount < 11'd750)) begin
      row <= {4'b0, col[2] | col[4], 3'b0};
   end else if (presscount < 11'd1100) begin
      row <= 0;  // now let it go for a while
   end else begin
      row <= {5'b0, col[1], 2'b0}; // second key press to end the simulation
   end
end


// add extra variables for CI watching here   
initial begin
   $dumpvars(0, row);
   $dumpvars(0, col);
end

// DUT-specific end condition to make sure it eventually stops running for CI mode
initial #8_000_000 $finish;

endmodule
