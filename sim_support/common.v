/////////// test bench boilerplate
// build a reference clock
reg clk12;
initial clk12 = 1'b1;
always #41.16666 clk12 = ~clk12;

wire success;
wire failure;
wire [15:0] report;

// termination condition upon success
always @(*) begin
    if (success == 1'b1) begin
        #500 $finish;
    end
    if (failure == 1'b1) begin
        #500 $finish;
    end
end

initial begin
    $dumpfile("ci.vcd");
    // $dumpvars(0, dut); will dump *everything*
    $dumpvars(0, success);
    $dumpvars(0, failure);
    $dumpvars(0, report);
end
