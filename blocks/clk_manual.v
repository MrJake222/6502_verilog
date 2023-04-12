// too fast when button kept pressed
// no delayed reset for the rest of the system

module clk_manual (
	input wire clk_x2,
	input wire btn,
	input wire n_reset,
	
	output reg clk,
	output reg mem_clk
);

reg enable;
reg cnt;

always @ (posedge clk_x2)
begin
	if (~n_reset) begin
		enable <= 0;
		clk <= 0;
		cnt <= 0;
	end
	
	else if (~btn & ~enable) begin
		enable <= 1;
		cnt <= 0;
		clk <= 1;
	end
	
	else begin
		case (cnt)
			0: clk <= 0;
			1: enable <= 0;
		endcase
		
		cnt <= cnt + 1'd1;
	end
end

always @ (negedge clk_x2)
begin
	if (~n_reset)
		mem_clk <= 0;
	
	else if (enable)
		case (cnt)
			0: mem_clk <= 1;
			1: mem_clk <= 0;
		endcase
end

endmodule