module CPU_bus_buffer (
	input wire AB, // pass from A to B on 1
	input wire BA, // pass from B to A on 1
	
	inout wire [7:0] port_A,
	inout wire [7:0] port_B
);

assign port_A = (BA) ? port_B : 8'hZZ;
assign port_B = (AB) ? port_A : 8'hZZ;

endmodule
