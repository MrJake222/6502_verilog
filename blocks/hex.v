/*module hex #(
	// parameters
	parameter DISPLAY = 0
) (
	input wire [3:0] hb,    // half bit
	input wire dot,			// 1 - dot lit
	output reg [7:0] HEX0,
	output reg [7:0] HEX1,
	output reg [7:0] HEX2,
	output reg [7:0] HEX3,
	output reg [7:0] HEX4,
	output reg [7:0] HEX5
);

wire [7:0] disp;

hex_decoder decoder (hb, dot, disp);

always
begin
	case (DISPLAY)
		0: assign HEX0 = disp;
		1: assign HEX1 = disp;
		2: assign HEX2 = disp;
		3: assign HEX3 = disp;
		4: assign HEX4 = disp;
		5: assign HEX5 = disp;
	endcase
end

endmodule*/