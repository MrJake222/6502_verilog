module VGA (
	input wire clk_20MHz,			// 20MHz clock
	input wire n_reset,				// negated reset
	
	input wire [7:0] data,			// data bus
	input wire [11:0] wraddress,	// address bus
	input wire wren,					// write enable
	input wire wrclock,				// write clock
	
	output wire h_sync,
	output wire v_sync,
	output wire [3:0] R,
	output wire [3:0] G,
	output wire [3:0] B
);

// Counter logic
wire [8:0] pix;
wire [8:0] line;
wire visible;

VGA_counters counters (clk_20MHz, n_reset, pix, line, h_sync, v_sync, visible);

// pix[2:0] one-hot encoding
wire [7:0] pixel_index;
demux_3bit pixel_demuxer (pix[2:0], pixel_index);

// clock
// different polarity -> latching 25ns after counters change
wire mem_clock = ~clk_20MHz;

// Character + color RAM (read on rising)
// 8K x 8bit
wire [7:0] cram_q;
wire [12:0] cram_addr;

vga_char_ram cram (
	// computer system port
	.data(data),				// input data
	.wraddress(wraddress),	// input address
	.wren(wren),				// write enable
	.wrclock(wrclock),		// write clock
	
	// display side port
	.q(cram_q),
	.rdaddress(cram_addr),
	.rdclock(mem_clock)
);

// 8 x 8 bit grid of characters
// don't use 3 lower bits, 8 pixels/lines -> 1 character
assign cram_addr[5:0] = pix[8:3];
assign cram_addr[11:6] = line[8:3];
assign cram_addr[12] = pix[2]; // color info after half of character

reg [7:0] curr_char;

always @ (posedge mem_clock & pixel_index[3])
begin
	// latch character code to curr_char
	// after this cram_q changes to color code
	curr_char = cram_q;
end

// Character ROM (read on rising)
// 2K x 8bit
wire [7:0] crom_q;
wire [10:0] crom_addr;

vga_char_rom crom (
	.q(crom_q),
	.address(crom_addr),
	.clock(mem_clock)
);

// extract 8 lines from ROM, each 8 bits (pixel values)
assign crom_addr[2:0] = line[2:0];
// extract 256 characters based on RAM entry
assign crom_addr[10:3] = curr_char;

reg [7:0] _pix_data;
reg [7:0] pix_data;
reg [7:0] _color;
reg [7:0] color;

always @ (posedge mem_clock & pixel_index[7])
begin
	// prepare values for output
	_pix_data = crom_q;
	_color = cram_q;
end

always @ (posedge pixel_index[0])
begin
	// latch values for output
	pix_data = _pix_data;
	color = _color;
end

// output to screen

// pixel format
// pix_data & pixel index -> pixel from foreground
wire is_fg = |(pix_data & pixel_index);

// color format
// format {NO_BLINK FGx3, BRIGHT BGx3}
// nBl RGB Br RGB
// nBlink = 0 -> blinking

// foreground
wire n_blink = color[7];
wire [2:0] fg = color[6:4];

// background
wire bright = color[3];
wire [2:0] bg = color[2:0];

// bright pixel is foreground or with BRIGHT set
wire is_bright = bright | is_fg;

// current pixel color
wire [2:0] pixel_color = is_fg ? fg : bg;
wire [2:0] pixel_bright_bit = is_bright ? pixel_color : 3'b000;

wire [3:0] _R = { pixel_bright_bit[2], {3{pixel_color[2]}} };
wire [3:0] _G = { pixel_bright_bit[1], {3{pixel_color[1]}} };
wire [3:0] _B = { pixel_bright_bit[0], {3{pixel_color[0]}} };

// generate blink clock with 4-bit counter
// 1/16 of frame = 3.75 Hz
reg [3:0] blink_clk;
always @ (posedge v_sync)
begin
	blink_clk = blink_clk + 1'b1;
end

// visible if
// - background
// - no blink
// - blinking character on
// visible area
wire _visible = (~is_fg | n_blink | blink_clk[3]) & visible;

// 3 bit fg with blink
assign R = {4{_visible}} & _R;
assign G = {4{_visible}} & _G;
assign B = {4{_visible}} & _B;

// 4 bit color
/*assign R = 			visible & fg ? {4{color[7]}} : {4{color[3]}};
assign G[3:2] = 	visible & fg ? {2{color[6]}} : {2{color[2]}};
assign G[1:0] = 	visible & fg ? {2{color[5]}} : {2{color[1]}};
assign B = 			visible & fg ? {4{color[4]}} : {4{color[0]}};*/

endmodule
