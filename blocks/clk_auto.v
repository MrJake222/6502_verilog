module clk_auto (
	input wire clk_x2,
	input wire n_reset_in,
	
	output reg clk,
	output reg mem_clk,
	output reg n_reset_out
);

reg [1:0] cnt;

always @ (posedge clk_x2)
begin
	if (~n_reset_in)
		clk <= 0;
	
	else
		clk <= ~clk;
end

always @ (negedge clk_x2)
begin
	if (~n_reset_in) begin
		mem_clk <= 0;
		
		cnt <= 0;
		n_reset_out <= 0;
	end
	
	else begin
		case (cnt)
			0: cnt <= 1;
			1: cnt <= 2;
			2: n_reset_out <= 1;
		endcase
		
		mem_clk <= ~mem_clk;
	end
end

endmodule