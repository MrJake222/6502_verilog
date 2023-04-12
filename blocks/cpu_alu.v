module CPU_ALU (
	// input wire clk,	// clock (latching out on negedge)
	
	input wire add,
	input wire sub,
	
	// default is out=A
	input wire inc_A,  // out=A+1
	
	input wire [7:0] A,
	input wire [7:0] B,
	
	output reg [7:0] out
);

// TODO rewrite as multiplexer
// TODO unify increments

reg [7:0] Bi;
always @*
begin	
	if (inc_A)
		Bi = 8'h01;
	else
		Bi = B;
end

always @*
begin
	if (add | inc_A)
		out = Bi + A;
	else if (sub)
		out = Bi - A;
	else
		out = A;
end

endmodule
