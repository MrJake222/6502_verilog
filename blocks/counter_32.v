module COUNTER_32 (input wire clk,
						 output reg [31:0] out);

always @ (posedge clk)
begin
	out = out + 1;
end

endmodule