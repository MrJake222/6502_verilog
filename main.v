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
// VERSION		"Version 21.1.1 Build 850 06/23/2022 SJ Lite Edition"
// CREATED		"Wed Apr 12 20:58:18 2023"

module main(
	MAX10_CLK1_50,
	KEY,
	VGA_HS,
	VGA_VS,
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	VGA_B,
	VGA_G,
	VGA_R
);


input wire	MAX10_CLK1_50;
input wire	[1:0] KEY;
output wire	VGA_HS;
output wire	VGA_VS;
output wire	[7:0] HEX0;
output wire	[7:0] HEX1;
output wire	[7:0] HEX2;
output wire	[7:0] HEX3;
output wire	[3:0] VGA_B;
output wire	[3:0] VGA_G;
output wire	[3:0] VGA_R;

wire	[15:0] addr;
wire	clk;
wire	clk_uart;
wire	[7:0] data;
wire	n_reset;
wire	uart_rx;
wire	uart_tx;
wire	SYNTHESIZED_WIRE_6;
wire	[7:0] SYNTHESIZED_WIRE_1;
wire	[7:0] SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;

assign	SYNTHESIZED_WIRE_6 = 1;




CPU	b2v_CPU0(
	.clk(clk),
	.n_reset(n_reset),
	.data_bus(data),
	.RW(SYNTHESIZED_WIRE_4),
	.addr_bus(addr),
	
	.dbg_A_val(SYNTHESIZED_WIRE_1),
	.dbg_IR_val(SYNTHESIZED_WIRE_3));


hex_decoder	b2v_hex_A(
	.dot(SYNTHESIZED_WIRE_6),
	.data(SYNTHESIZED_WIRE_1),
	.disp_high(HEX3),
	.disp_low(HEX2));


hex_decoder	b2v_hex_IR(
	.dot(SYNTHESIZED_WIRE_6),
	.data(SYNTHESIZED_WIRE_3),
	.disp_high(HEX1),
	.disp_low(HEX0));


assign	clk =  ~KEY[1];


RAM	b2v_ram0(
	.mem_clk(clk),
	.RW(SYNTHESIZED_WIRE_4),
	.addr(addr),
	.data(data)
	);


ROM	b2v_rom0(
	.mem_clk(clk),
	.addr(addr),
	.data(data));


UART	b2v_uart1(
	.clk(clk_uart),
	.n_reset(n_reset),
	.rx(uart_rx)
	);


VGA	b2v_VGA0(
	.clk_20MHz(SYNTHESIZED_WIRE_5),
	.n_reset(n_reset),
	
	
	
	
	.h_sync(VGA_HS),
	.v_sync(VGA_VS),
	.B(VGA_B),
	.G(VGA_G),
	.R(VGA_R));


pll	b2v_vga_pll(
	.inclk0(MAX10_CLK1_50),
	.c0(SYNTHESIZED_WIRE_5),
	
	.c2(clk_uart));

assign	n_reset = KEY[0];
assign	n_reset = KEY[0];

endmodule
