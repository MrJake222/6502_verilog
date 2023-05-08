module ROM (
  // cpu
	input wire mem_clk,
	input wire [15:0] addr,
	output wire [7:0] data,
	
  // debug	
	input wire dbg_mem_op, // select from dbgu
	input wire dbg_mem_clk,
	input wire [15:0] dbg_addr,
	input wire [7:0] dbg_data_in,
	output wire [7:0] dbg_data_out,
	input wire dbg_RW
);

// select 0x8000 - 0xFFFF
wire select = addr[15];

wire [7:0] q;
assign data = select ? q : 8'hZZ;

wire dbg_select = dbg_addr[15] & dbg_mem_op;
wire dbg_OE = dbg_RW & dbg_select;
wire dbg_WE = ~dbg_RW & dbg_select;
wire [7:0] dbg_q;
assign dbg_data_out = dbg_OE ? dbg_q : 8'hZZ;

rom_memory memory (
  // cpu
	.address_a(addr[14:0]),
	.clock_a(mem_clk),
	.q_a(q),
	
	// for CPU this is read-only memory
	.data_a(8'h00),
	.wren_a(1'h0),
	
  // debug
	.address_b(dbg_addr[14:0]),
	.clock_b(dbg_mem_clk),
	.q_b(dbg_q),
	
	.data_b(dbg_data_in),
	.wren_b(dbg_WE)
);



endmodule