module main(
	input wire MAX10_CLK1_50,
	
	input wire [1:0] KEY,
	
	// VGA connector
	output wire VGA_HS,
	output wire VGA_VS,
	output wire [3:0] VGA_R,
	output wire [3:0] VGA_G,
	output wire [3:0] VGA_B,
	
	// GPIO header (PS/2 + UART)
	inout wire [35:0] GPIO,
	
	// debug output
	// hex digits (dbgu address counter)
	output wire [7:0] HEX0,
	output wire [7:0] HEX1,
	output wire [7:0] HEX2,
	output wire [7:0] HEX3,
	
	// PS/2 debug bits
	output wire [9:0] LEDR
);

// ------------------------- IO CONFIG & CLOCKS ------------------------- //
wire master_n_reset = KEY[0];

wire clk_vga;
wire clk_uart;

// input: 50MHz
// c0 --     20MHz (VGA)
// c1 --      1MHz (CPU -- unused, cpu driven from dbgu)
// c2 -- 3.6864MHz (UART source clock)
pll	vga_pll(
	.inclk0(MAX10_CLK1_50),
	.c0(clk_vga),
	
	.c2(clk_uart));


// UART
wire uart_rx = GPIO[26];
wire uart_tx;
assign GPIO[27] = uart_tx;

wire ps2_clk = GPIO[11];
wire ps2_data = GPIO[10];

// ------------------------- Debug unit ------------------------- //

wire dbgu_RW;
wire [15:0] dbgu_addr_bus;
wire [7:0] dbgu_data_bus;
wire dbgu_mem_op;

wire [7:0] dbg_A_val;
wire [7:0] dbg_IR_val;
wire [7:0] dbg_P_val;
wire [15:0] dbg_PC_val;
wire [7:0] dbg_S_val;
wire [7:0] dbg_X_val;
wire [7:0] dbg_Y_val;

wire dbgu_cpu_clk;
wire dbgu_cpu_n_reset;

dbgu dbgu0(
	.clk(clk_uart),
	.n_reset(master_n_reset),
	.rx(uart_rx),
	.tx(uart_tx),
	
	// debug memory interface
	.RW(dbgu_RW),
	.adr_ptr(dbgu_addr_bus),
	.data_bus_in(dbgu_data_bus),
	.data_bus_out(dbgu_data_bus),
	.mem_op(dbgu_mem_op),
	
	// debug CPU register read
	.val_A(dbg_A_val),
	.val_IR(dbg_IR_val),
	.val_P(dbg_P_val),
	.val_PC(dbg_PC_val),
	.val_S(dbg_S_val),
	.val_X(dbg_X_val),
	.val_Y(dbg_Y_val),
	
	// debug CPU control
	.cpu_clk(dbgu_cpu_clk),
	.cpu_n_reset(dbgu_cpu_n_reset)
);

// ------------------------- CPU ------------------------- //

wire cpu_clk = dbgu_cpu_clk;
wire cpu_n_reset = master_n_reset & dbgu_cpu_n_reset;

wire cpu_irqb;

wire cpu_RW;
wire [15:0] cpu_addr_bus;
wire [7:0] cpu_data_bus;

CPU cpu0 (
	// control signals
	.clk(cpu_clk),
	.n_reset(cpu_n_reset),
	.IRQB(cpu_irqb),
	
	// memory bus signals
	.RW(cpu_RW),
	.adr_bus(cpu_addr_bus),
	.data_bus_in(cpu_data_bus),
	.data_bus_out(cpu_data_bus),
	
	// debug signals
	.dbg_A_val(dbg_A_val),
	.dbg_IR_val(dbg_IR_val),
	.dbg_P_val(dbg_P_val),
	.dbg_PC_val(dbg_PC_val),
	.dbg_S_val(dbg_S_val),
	.dbg_X_val(dbg_X_val),
	.dbg_Y_val(dbg_Y_val)
);

// debug display of dbgu_addr_bus on HEX3..0
hex_decoder	hex_disp_1(
	.dot(0),
	.data(dbgu_addr_bus[15:8]),
	.disp_high(HEX3),
	.disp_low(HEX2)
);

hex_decoder	hex_disp_0(
	.dot(0),
	.data(dbgu_addr_bus[7:0]),
	.disp_high(HEX1),
	.disp_low(HEX0)
);

PS2	ps2(
	// external data input
	.ps2_clk__(ps2_clk),
	.ps2_data__(ps2_data),
	
	// clocking and reset
	.clk(clk_uart),
	.n_reset(master_n_reset),
	    
	// system bus
	.sys_adr(cpu_addr_bus),
	.sys_irq(cpu_irqb),
	.sys_data_out(cpu_data_bus),
	
	.dbg(LEDR)
);


RAM	ram0(
	.mem_clk(cpu_clk),
	.RW(cpu_RW),
	.addr(cpu_addr_bus),
	.data(cpu_data_bus),
	
	// debug unit interface
	.dbg_mem_clk(clk_uart),
	.dbg_RW(dbgu_RW),
	.dbg_addr(dbgu_addr_bus),
	.dbg_data_in(dbgu_data_bus),
	.dbg_data_out(dbgu_data_bus),
	.dbg_mem_op(dbgu_mem_op)
);


ROM	rom0(
	.mem_clk(cpu_clk),
	.addr(cpu_addr_bus),
	.data(cpu_data_bus),
	
	// debug unit interface
	.dbg_mem_clk(clk_uart),
	.dbg_RW(dbgu_RW),
	.dbg_addr(dbgu_addr_bus),
	.dbg_data_in(dbgu_data_bus),	
	.dbg_data_out(dbgu_data_bus),
	.dbg_mem_op(dbgu_mem_op)
);


VGA	VGA0(
	// clock & reset
	.clk_20MHz(clk_vga),
	.n_reset(master_n_reset),
	
	// cpu interface (read/write)
	.sys_clk(cpu_clk),
	.RW(cpu_RW),
	.sys_addr(cpu_addr_bus),
	.sys_data_in(cpu_data_bus),
	.sys_data_out_(cpu_data_bus),
	
	// external signals out
	.h_sync(VGA_HS),
	.v_sync(VGA_VS),
	.B(VGA_B),
	.G(VGA_G),
	.R(VGA_R)
);

endmodule
