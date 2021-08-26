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

// simulate some key presses, the first one bounces on release, plus some more regular ones
reg [11:0] presscount;
initial presscount = 12'd0;
always @(posedge lpclk) begin
   presscount <= presscount + 1;
end
always @(*) begin
   if (presscount < 12'd300) begin
      row <= {4'b0, col[8] | col[9], 3'b0}; // initial key press, long enough to debounce
   end else if ((presscount < 12'd600) && (presscount < 12'd650)) begin
      row <= 0;  // bounce it
   end else if ((presscount < 12'd700) && (presscount < 12'd750)) begin
      row <= {4'b0, col[2] | col[4], 3'b0};
   end else if (presscount < 12'd1100) begin
      row <= 0;  // now let it go for a while
   end else if (presscount < 12'd1800) begin
      row <= {5'b0, col[3], 2'b0};
   end else if (presscount < 12'd2400) begin
      row <= 0;
   end else if (presscount < 12'd3200) begin
      row <= {4'b0, col[1] | col[7], 2'b0};
   end else if (presscount < 12'd4000) begin
      row <= 0;
   end else if (presscount < 12'd4800) begin
      row <= {5'b0, col[0], 2'b0};
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
