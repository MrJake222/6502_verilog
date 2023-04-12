module CPU_counter #(parameter WIDTH=16) (
	input wire clk,	// clock (counting on negedge)
	input wire OE,		// output enable, output Z if 0
	input wire WE,		// write enable, writes data to register on negedge when 1
	input wire cnt_enable, // counts up when 1 on negedge
	
	input wire [WIDTH-1:0] bus_in,
	output wire [WIDTH-1:0] bus_out
);

reg [WIDTH-1:0] value;

assign bus_out = OE ? value : {WIDTH{1'bZ}};

always @ (negedge clk)
begin
	if (WE)
		value <= bus_in;
	
	else if (cnt_enable)
		value <= value + 1;
end

endmodule