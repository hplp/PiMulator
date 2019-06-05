module overflow_detector(
	// AXI stream in
	input_axis_tvalid,
	input_axis_tready,
	input_axis_tdata,

	// AXI stream out
	output_axis_tvalid,
	output_axis_tready,
	output_axis_tdata,

	// clock and reset
	aclk,
	aresetn
);
input input_axis_tvalid;
output input_axis_tready;
input [127:0] input_axis_tdata;

output output_axis_tvalid;
input output_axis_tready;
output [127:0] output_axis_tdata;

input aclk;
input aresetn;

reg overflow;

assign input_axis_tready = 1'b1;
//assign input_axis_tready = output_axis_tready;
assign output_axis_tvalid = input_axis_tvalid;
assign output_axis_tdata = {input_axis_tdata[127:32], input_axis_tdata[31] | overflow, input_axis_tdata[30:0]};

wire overflow_now;
assign overflow_now = input_axis_tvalid & ~output_axis_tready;

always @(posedge aclk) begin
	if (aresetn == 1'b0) overflow <= 1'b0;
	else if (overflow_now) overflow <= 1'b1;
	else if (input_axis_tvalid) overflow <= 1'b0;
	else overflow <= overflow;
end

endmodule
