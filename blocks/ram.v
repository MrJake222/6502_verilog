module RAM (
	input wire mem_clk,
	input wire [15:0] addr,	
	inout wire [7:0] data,
	
	input wire RW
);

// select 0x0000 - 0x7FFF
wire select = ~addr[15];

// output enable -> read(RW=1) and selected
wire OE = RW & select;

// write enable -> write(RW=0) and selected
wire WE = ~RW & select;

wire [7:0] q;
assign data = OE ? q : 8'hZZ;

ram_memory memory (
	.address(addr[14:0]),
	.clock(mem_clk),
	
	.q(q),
	
	.data(data),
	.wren(WE)
);

endmodule