// address modes

`define ADR_ZPG	    4'd0	// zeropage	00xx
`define ADR_ZPG_I	4'd1	// zeropage indexed with X/Y
	
`define ADR_IMM	    4'd2	// immediate
`define ADR_REL	    4'd3	// relative (used with branches)
	
`define ADR_ABS	    4'd4	// absolute
`define ADR_ABS_I	4'd5	// absolute indexed with X/Y
	
`define ADR_IND	    4'd6	// M(op) (only used for JMP ind)
`define ADR_IND_Y	4'd7	// M(op)+y
	
`define ADR_IMPL	4'd8	// implied
`define ADR_X_IND	4'd9	// M(op+X)

`define ADR_INVAL	    4'd15       // default case
`define ADR_DONT_CARE	4'bXXXX     // don't cares (correct width)


`define ADR_INDEX_X	1'd0
`define ADR_INDEX_Y	1'd1
