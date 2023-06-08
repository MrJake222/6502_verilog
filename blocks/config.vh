// address modes

// based on 65c02 docs

`define ADR_INVAL		5'd0	  // Invalid address mode
`define ADR_DONT_CARE	5'bXXXXX  // don't cares (correct width)

`define ADR_ABS			5'd1	// 1a absolute
`define ADR_ABS_RMW		5'd2	// 1b absolute (RMW)
`define ADR_ABS_JMP		5'd3	// 1c absolute JUMP
`define ADR_ABS_JSR		5'd4	// 1d absolute JUMP to subroutine

`define ADR_ABS_X_IND	5'd5	// 2  absolute indexed X indirect M(op+X) (WDC EXT, JMP only)

`define ADR_ABS_X_Y		5'd6	// 3a absolute indexed X op+X / 4 absolute indexed Y op+Y (see ADR_INDEX_X/Y)
`define ADR_ABS_X_RMW	5'd7	// 3b absolute indexed X op+X (RMW)

// 4 -> see 3a

`define ADR_ABS_IND		5'd8	// 5 absolute indirect M(op) (JMP only)
`define ADR_ACCUM		5'd9	// 6 accumulator

`define ADR_IMM			5'd10	// 7 immediate

`define ADR_IMPL		5'd11	// 8a implied
`define ADR_IMPL_STP	5'd12	// 8b stop the clock						(WDC EXT)
`define ADR_IMPL_WAI	5'd13	// 8c wait for interrupt					(WDC EXT)

`define ADR_REL			5'd14	// 9a relative (branches)
`define ADR_REL_BIT		5'd15	// 9b relative bit branch (zeropage)		(WDC EXT)

`define ADR_STACK_INT	5'd16	// 10a stack (interrupt)
`define ADR_STACK_BRK	5'd17	// 10b stack (software interrupt)
`define ADR_STACK_RTI	5'd18	// 10c stack (return from interrupt)
`define ADR_STACK_RTS	5'd19	// 10d stack (return from subroutine)
`define ADR_STACK_PH	5'd20	// 10e stack (push)
`define ADR_STACK_PL	5'd21	// 10f stack (pull)

`define ADR_ZPG			5'd22	// 11a zeropage	
`define ADR_ZPG_RMW		5'd23	// 11b zeropage	(RMW)
`define ADR_ZPG_BIT		5'd24	// 11c zeropage	(RMW, set/reset memory bit)	(WDC EXT)
// 11d -> see 9b

`define ADR_ZPG_X_IND	5'd25	// 12  zeropage indexed X indirect M(zp+x)
`define ADR_ZPG_X_Y		5'd26	// 13a zeropage indexed X zp+x / 14 zeropage indexed Y zp+y (see ADR_INDEX_X/Y)
`define ADR_ZPG_X_RMW	5'd27	// 13b zeropage indexed X zp+x (RMW)
// 14 -> see 13a

`define ADR_ZPG_IND		5'd28	// 15  zeropage indirect M(op)
`define ADR_ZPG_IND_Y	5'd29	// 16  zeropage indirect indexed Y M(op)+y


`define ADR_INDEX_X	1'd0
`define ADR_INDEX_Y	1'd1
