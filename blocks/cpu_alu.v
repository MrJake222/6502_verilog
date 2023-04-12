module CPU_ALU (
	// input wire clk,	// clock (latching out on negedge)
	
	input wire add,
	input wire sub,
	
	// default is out=A
	input wire pass_B, // out=B
	input wire inc_A,  // out=A+1
	input wire inc_B,  // out=1+B
	
	input wire [7:0] A,
	input wire [7:0] B,
	
	output reg [7:0] out
);

// TODO rewrite as multiplexer
// TODO unify increments

reg [7:0] Ai;
reg [7:0] Bi;
always @*
begin
	if (pass_B)
		Ai = 8'h00;
	else if (inc_B)
		Ai = 8'h01;
	else
		Ai = A;
	
	if (inc_A)
		Bi = 8'h01;
	else
		Bi = B;
end

always @*
begin
	if (add | pass_B | inc_A | inc_B)
		out = Ai + Bi;
	else if (sub)
		out = Ai - Bi;
	else
		out = Ai;
end

endmodule
