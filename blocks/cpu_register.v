module CPU_register #(parameter WIDTH=8) (
	input wire clk,	// clock (latching data on negedge)
	input wire OE,		// output enable, output Z if 0
	input wire WE,		// write enable, writes data to register on negedge when 1
	
	input wire [WIDTH-1:0] data_bus_in,
	output wire [WIDTH-1:0] data_bus_out,
	
	output wire [WIDTH-1:0] dbg_value
);

reg [WIDTH-1:0] value;

assign data_bus_out = OE ? value : {WIDTH{1'bZ}};
assign dbg_value = value;

always @ (negedge clk)
begin
	if (WE) begin
		value <= data_bus_in;
	end
end

endmodule