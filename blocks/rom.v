module ROM (
	input wire mem_clk,
	input wire [15:0] addr,
	output wire [7:0] data
);

wire [7:0] q;

rom_memory memory (
	.address(addr[14:0]),
	.clock(mem_clk),
	.q(q)
);

wire select = addr[15];

assign data = select ? q : 8'hZZ;

endmodule