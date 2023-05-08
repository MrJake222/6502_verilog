module CPU_ALU (
	// input wire clk,	// clock (latching out on negedge)
	input wire carry_in,
	
	input wire add,
	input wire sub,
	input wire cmp, // same as sub, but no carry
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
	
	output reg [7:0] out,
	output reg neg,
	output reg ov,
	output reg zero,
	output reg carry_out
);

// TODO rewrite as multiplexer

reg [7:0] Ai;
reg [7:0] Aii;

always @*
begin	
	if (inc_B | dec_B)
		Ai = 1;
	else
		Ai = A;
		
	if (sub | cmp | dec_B)
		Aii = ~Ai;
	else
		Aii = Ai;
end

always @*
begin
	if (add | sub | cmp | inc_B | dec_B)
		{carry_out, out} = B + Aii + (carry_in | cmp);
		
	else if (bit_or)
		{carry_out, out} = B | Aii;
		
	else if (bit_and)
		{carry_out, out} = B & Aii;
		
	else if (bit_eor)
		{carry_out, out} = B ^ Aii;
		
	else if (shift_l)
		if (shift_carry_in)
			{carry_out, out} = (B << 1) | carry_in;
		else
			{carry_out, out} = B << 1;
		
	else if (shift_r)
		if (shift_carry_in)
			{carry_out, out} = (carry_in << 7) | (B >> 1);
		else
			{carry_out, out} = B >> 1;
	
	else if (pass_B)
		{carry_out, out} = B;
		
	else
		{carry_out, out} = Aii;
end

always @*
begin
	neg = out[7];
	ov = (Aii[7] ^ out[7]) & (B[7] ^ out[7]);
	zero = (out == 0);
end

endmodule
