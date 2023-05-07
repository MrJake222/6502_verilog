module CPU_ALU (
	// input wire clk,	// clock (latching out on negedge)
	
	input wire add,
	input wire sub,
	input wire bit_or,
	input wire bit_and,
	input wire bit_eor,
	input wire shift_l,
	input wire shift_r,
	input wire shift_carry_in,
	
	// default is out=A
	input wire inc_B,  // out=B+1
	input wire dec_B,  // out=B-1
	input wire pass_B, // out=B
	
	input wire [7:0] A,
	input wire [7:0] B,
	
	output reg [7:0] out
);

// TODO rewrite as multiplexer

reg [7:0] Ai;
always @*
begin	
	if (inc_B | dec_B)
		Ai = 8'h01;
	else
		Ai = A;
end

always @*
begin
	if (add | inc_B)
		out = B + Ai;
		
	else if (sub | dec_B)
		out = B - Ai;
		
	else if (bit_or)
		out = B | Ai;
		
	else if (bit_and)
		out = B & Ai;
		
	else if (bit_eor)
		out = B ^ Ai;
		
	else if (shift_l)
		out = B << 1;
		
	else if (shift_r)
		out = B >> 1;
		
	else if (pass_B)
		out = B;
		
	else
		out = Ai;
end

endmodule
