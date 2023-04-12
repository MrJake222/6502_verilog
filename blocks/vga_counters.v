module VGA_counters (
	input wire clk,
	input wire n_reset,
	output wire [8:0] pix,
	output wire [8:0] line,
	output reg h_sync,
	output reg v_sync,
	output wire visible
);

// using mode 800x600 but counting only 400x600
// usable 400x300, pixel clock (clk) 20MHz

reg [1:0] v_area; // v_area[0] horizontal
						// v_area[1] vertical
						
assign visible = &v_area;

reg [9:0] _pix;  // internal pix number
reg [9:0] _line; // internal line number

// don't output MSB
assign pix = _pix[8:0];

// don't output LSB
assign line = _line[9:1];

always @ (posedge clk)
begin
	if (~n_reset) begin
		_pix = 0;
		_line = 0;
		h_sync = 0;
		v_sync = 0;
		v_area = 2'b11;
	end
	else begin
		_pix = _pix + 1'b1;

		case (_pix)
			8: v_area[0] = 1;		// visible area
			408: v_area[0] = 0;	// no visible area
			428: h_sync = 1; 		// sync pulse
			492: h_sync = 0; 		// no sync pulse
			528: begin
				// new line
				_pix = 0;
				_line = _line + 1'b1;				
			end
		endcase
		
		case (_line)
			600: v_area[1] = 0; 	// no visible
			601: v_sync = 1;		// sync pulse
			605: v_sync = 0;		// no sync pulse
			628: begin
				_line = 0;		// new frame
				v_area[1] = 1;		// visible area
			end
		endcase
	end
end

endmodule