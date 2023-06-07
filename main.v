// Copyright (C) 2022  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and any partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details, at
// https://fpgasoftware.intel.com/eula.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 22.1std.0 Build 915 10/25/2022 SC Lite Edition"
// CREATED		"Mon May 22 14:41:21 2023"

module main(
	MAX10_CLK1_50,
	KEY,
	VGA_HS,
	VGA_VS,
	GPIO,
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	LEDR,
	VGA_B,
	VGA_G,
	VGA_R
);


input wire	MAX10_CLK1_50;
input wire	[1:0] KEY;
output wire	VGA_HS;
output wire	VGA_VS;
inout wire	[3:0] GPIO;
output wire	[7:0] HEX0;
output wire	[7:0] HEX1;
output wire	[7:0] HEX2;
output wire	[7:0] HEX3;
output wire	[9:0] LEDR;
output wire	[3:0] VGA_B;
output wire	[3:0] VGA_G;
output wire	[3:0] VGA_R;

wire	[15:0] addr_bus;
wire	[15:0] adr_ptr;
wire	button_clk;
wire	clk_uart;
wire	cpu_clk;
wire	cpu_irqb;
wire	cpu_n_reset;
wire	[7:0] data;
wire	dbgu_cpu_clk;
wire	dbgu_cpu_n_reset;
wire	[7:0] gdfx_temp0;
wire	master_n_reset;
wire	RW;
wire	uart_rx;
wire	uart_tx;
wire	[7:0] SYNTHESIZED_WIRE_0;
wire	[7:0] SYNTHESIZED_WIRE_1;
wire	[7:0] SYNTHESIZED_WIRE_2;
wire	[15:0] SYNTHESIZED_WIRE_3;
wire	[7:0] SYNTHESIZED_WIRE_4;
wire	[7:0] SYNTHESIZED_WIRE_5;
wire	[7:0] SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_16;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_17;
wire	SYNTHESIZED_WIRE_18;
wire	SYNTHESIZED_WIRE_15;

assign	SYNTHESIZED_WIRE_16 = 0;




CPU	b2v_CPU0(
	.clk(cpu_clk),
	.n_reset(cpu_n_reset),
	.IRQB(cpu_irqb),
	.data_bus_in(data),
	.RW(RW),
	.adr_bus(addr_bus),
	.data_bus_out(data),
	.dbg_A_val(SYNTHESIZED_WIRE_0),
	.dbg_IR_val(SYNTHESIZED_WIRE_1),
	.dbg_P_val(SYNTHESIZED_WIRE_2),
	.dbg_PC_val(SYNTHESIZED_WIRE_3),
	.dbg_S_val(SYNTHESIZED_WIRE_4),
	.dbg_X_val(SYNTHESIZED_WIRE_5),
	.dbg_Y_val(SYNTHESIZED_WIRE_6));

assign	cpu_clk = dbgu_cpu_clk | button_clk;

assign	cpu_n_reset = master_n_reset & dbgu_cpu_n_reset;


dbgu	b2v_dbgu0(
	.clk(clk_uart),
	.n_reset(master_n_reset),
	.rx(uart_rx),
	.data_bus_in(gdfx_temp0),
	.val_A(SYNTHESIZED_WIRE_0),
	.val_IR(SYNTHESIZED_WIRE_1),
	.val_P(SYNTHESIZED_WIRE_2),
	.val_PC(SYNTHESIZED_WIRE_3),
	.val_S(SYNTHESIZED_WIRE_4),
	.val_X(SYNTHESIZED_WIRE_5),
	.val_Y(SYNTHESIZED_WIRE_6),
	.tx(uart_tx),
	.cpu_clk(dbgu_cpu_clk),
	.cpu_n_reset(dbgu_cpu_n_reset),
	.RW(SYNTHESIZED_WIRE_18),
	.mem_op(SYNTHESIZED_WIRE_17),
	.adr_ptr(adr_ptr),
	.data_bus_out(gdfx_temp0)
	);


hex_decoder	b2v_hex_disp_0(
	.dot(SYNTHESIZED_WIRE_16),
	.data(adr_ptr[7:0]),
	.disp_high(HEX1),
	.disp_low(HEX0));


hex_decoder	b2v_hex_disp_1(
	.dot(SYNTHESIZED_WIRE_16),
	.data(adr_ptr[15:8]),
	.disp_high(HEX3),
	.disp_low(HEX2));


assign	button_clk =  ~KEY[1];

assign	SYNTHESIZED_WIRE_9 =  ~GPIO[2];

assign	SYNTHESIZED_WIRE_10 =  ~GPIO[3];


PS2	b2v_ps2(
	.ps2_clk(SYNTHESIZED_WIRE_9),
	.ps2_data(SYNTHESIZED_WIRE_10),
	.clk(clk_uart),
	.n_reset(master_n_reset),
	.sys_adr(addr_bus),
	.sys_irq(cpu_irqb),
	.dbg(LEDR),
	.sys_data(data));


RAM	b2v_ram0(
	.mem_clk(cpu_clk),
	.RW(RW),
	.dbg_mem_op(SYNTHESIZED_WIRE_17),
	.dbg_mem_clk(clk_uart),
	.dbg_RW(SYNTHESIZED_WIRE_18),
	.addr(addr_bus),
	.data(data),
	.dbg_addr(adr_ptr),
	.dbg_data_in(gdfx_temp0),
	
	.dbg_data_out(gdfx_temp0));


ROM	b2v_rom0(
	.mem_clk(cpu_clk),
	.dbg_mem_op(SYNTHESIZED_WIRE_17),
	.dbg_mem_clk(clk_uart),
	.dbg_RW(SYNTHESIZED_WIRE_18),
	.addr(addr_bus),
	.dbg_addr(adr_ptr),
	.dbg_data_in(gdfx_temp0),
	.data(data),
	.dbg_data_out(gdfx_temp0));


VGA	b2v_VGA0(
	.clk_20MHz(SYNTHESIZED_WIRE_15),
	.n_reset(master_n_reset),
	.sys_clk(cpu_clk),
	.sys_addr(addr_bus),
	.sys_data(data),
	.h_sync(VGA_HS),
	.v_sync(VGA_VS),
	.B(VGA_B),
	.G(VGA_G),
	.R(VGA_R));


pll	b2v_vga_pll(
	.inclk0(MAX10_CLK1_50),
	.c0(SYNTHESIZED_WIRE_15),
	
	.c2(clk_uart));

assign	master_n_reset = KEY[0];
assign	GPIO[0] = uart_tx;
assign	GPIO[1] = uart_rx;
assign	master_n_reset = KEY[0];
assign	uart_rx = GPIO[1];
assign	uart_tx = GPIO[0];

endmodule
