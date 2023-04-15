module RAM (
  // cpu
	input wire mem_clk,
	input wire [15:0] addr,	
	inout wire [7:0] data,
	input wire RW,
	
  // debug
   input wire dbg_mem_op, // select from dbgu
   input wire dbg_mem_clk,
	input wire [15:0] dbg_addr,	
	input wire [7:0] dbg_data_in,
	output wire [7:0] dbg_data_out,
	input wire dbg_RW
);

// select 0x0000 - 0x7FFF
wire select = ~addr[15];

// output enable -> read(RW=1) and selected
wire OE = RW & select;

// write enable -> write(RW=0) and selected
wire WE = ~RW & select;

wire [7:0] q;
assign data = OE ? q : 8'hZZ;


wire dbg_select = ~dbg_addr[15] & dbg_mem_op;
wire dbg_OE = dbg_RW & dbg_select;
wire dbg_WE = ~dbg_RW & dbg_select;
wire [7:0] dbg_q;
assign dbg_data_out = dbg_OE ? dbg_q : 8'hZZ;

ram_memory memory (
  // cpu side
	.address_a(addr[14:0]),
	.clock_a(mem_clk),
	.q_a(q),
	
	.data_a(data),
	.wren_a(WE),
	
  // debug side
   .address_b(dbg_addr[14:0]),
	.clock_b(dbg_mem_clk),
	.q_b(dbg_q),
	
	.data_b(dbg_data_in),
	.wren_b(dbg_WE)
);

endmodule