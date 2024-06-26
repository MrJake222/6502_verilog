module hex_decoder (
	input wire [7:0] data,
	
	// dot after low
	input wire dot,
	
	output reg [7:0] disp_high,
	output reg [7:0] disp_low
);

function [6:0] disp (
	input [3:0] nibble
);
begin
	case (nibble)
		4'h0: disp = 7'b0111111;
		4'h1: disp = 7'b0000110;
		4'h2: disp = 7'b1011011;
		4'h3: disp = 7'b1001111;
		4'h4: disp = 7'b1100110;
		4'h5: disp = 7'b1101101;
		4'h6: disp = 7'b1111101;
		4'h7: disp = 7'b0000111;
		4'h8: disp = 7'b1111111;
		4'h9: disp = 7'b1101111;
		4'hA: disp = 7'b1110111;
		4'hB: disp = 7'b1111100;
		4'hC: disp = 7'b0111001;
		4'hD: disp = 7'b1011110;
		4'hE: disp = 7'b1111001;
		4'hF: disp = 7'b1110001;
	endcase
end
endfunction

always @*
begin
	disp_high = ~disp(data[7:4]);
	disp_low = ~(disp(data[3:0]) | (dot << 7));
end

endmodule