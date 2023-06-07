module VGA (
	input wire clk_20MHz,			// 20MHz clock
	input wire n_reset,				// negated reset
	
    input wire sys_clk,				// write clock
	input wire [15:0] sys_addr,	    // address bus
	input wire [7:0] sys_data,		// data bus
	
	output wire h_sync,
	output wire v_sync,
	output wire [3:0] R,
	output wire [3:0] G,
	output wire [3:0] B
);

// 0x6000 - 0x7FFF
wire select = ~sys_addr[15] & sys_addr[14] & sys_addr[13];

// Counter logic
wire [8:0] pix;
wire [8:0] line;
wire visible;

VGA_counters counters (clk_20MHz, n_reset, pix, line, h_sync, v_sync, visible);


// Character + color RAM (read on rising)
// 8K x 8bit
wire [7:0] cram_q;
wire [12:0] cram_addr;

// 8 x 8 bit grid of characters
// don't use 3 lower bits, 8 pixels/8 lines -> 1 character
assign cram_addr[5:0]  = pix[8:3];
assign cram_addr[11:6] = line[8:3];
assign cram_addr[12]   = pix[2]; // color info after half of character

vga_char_ram cram (
	// computer system port
	.data(sys_data),				// input data
	.wraddress(sys_addr[12:0]),	    // input address
	.wren(select),				    // write enable
	.wrclock(sys_clk),		        // write clock
	
	// display side port
	.q(cram_q),
	.rdaddress(cram_addr),
	.rdclock(clk_20MHz)
);


// Character ROM (read on rising)
// 2K x 8bit
wire [7:0] crom_q;
wire [10:0] crom_addr;

// link between cram and crom (latched)
reg [7:0] curr_char;

// extract 8 lines from ROM, each 8 bits (pixel values)
assign crom_addr[2:0] = line[2:0];
// extract one of 256 characters based on RAM entry
assign crom_addr[10:3] = curr_char;

vga_char_rom crom (
	.q(crom_q),
	.address(crom_addr),
	.clock(clk_20MHz)
);

reg [7:0] pix_data;
reg [7:0] color;

always @ (negedge clk_20MHz)
begin
    case (pix[2:0])
        3'd3:
            // latch character code to curr_char
            // after this cram_q changes to color code
            curr_char = cram_q;
        
        3'd7:
        begin
            pix_data = crom_q;
            color = cram_q;
        end
    endcase
end


// generate blink clock with 4-bit counter
// 16 frames = 3.75 Hz
localparam BLINK_BITS = 6;
reg [BLINK_BITS-1:0] blink_clk;
reg blink_inc;
always @ (negedge clk_20MHz)
begin
    if (v_sync)
    begin
        if (blink_inc)
            blink_clk = blink_clk + 1'b1;
        blink_inc = 0;
    end else
    begin
        blink_inc = 1;
    end
end


// output to screen

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


// pix[2:0] one-hot encoding
wire [7:0] pixel_index;
demux_3bit pixel_demuxer (pix[2:0], pixel_index);
wire is_fg = |(pix_data & pixel_index) & (n_blink | blink_clk[BLINK_BITS-1]);


// bright pixel is with BRIGHT set or foreground
wire is_bright = bright | is_fg;

// current pixel color
wire [2:0] pixel_color = is_fg ? fg : bg;
wire [2:0] pixel_bright_bits = is_bright ? pixel_color : 3'b000;

wire [3:0] _R = { pixel_bright_bits[2], {3{pixel_color[2]}} };
wire [3:0] _G = { pixel_bright_bits[1], {3{pixel_color[1]}} };
wire [3:0] _B = { pixel_bright_bits[0], {3{pixel_color[0]}} };

// output only if visible area
assign R = {4{visible}} & _R;
assign G = {4{visible}} & _G;
assign B = {4{visible}} & _B;

// 4 bit color
/*assign R = 			visible & fg ? {4{color[7]}} : {4{color[3]}};
assign G[3:2] = 	visible & fg ? {2{color[6]}} : {2{color[2]}};
assign G[1:0] = 	visible & fg ? {2{color[5]}} : {2{color[1]}};
assign B = 			visible & fg ? {4{color[4]}} : {4{color[0]}};*/

endmodule
