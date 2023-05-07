`include "config.vh"

module CPU_control (
	input wire [7:0] IR,			// instruction register
	
	output reg [4:0] adr_mode,	// alu_address mode
	output reg index,			// index register (when indexed mode)
	
	output reg branch,			// conditional branch
	output reg flag,				// flag mangling
	
	// These bits represent what should happen during this instruction
	// (doesn't account when it should execute)
	
	// register read/write
	// where to get/latch data 
	output wire from_A,
	output wire to_A,
	output wire from_X,
	output wire to_X,
	output wire from_Y,
	output wire to_Y,
	output wire from_S,
	output wire to_S,
	
	// memory direction (where applicable, Read-Modify-Write)
	output wire from_mem,
	output wire to_mem,
	
	// alu control
	output wire alu_inc,
	output wire alu_dec,
	output wire alu_or,
	output wire alu_and,
	output wire alu_eor,
	output wire alu_add,
	output wire alu_sub,
	output wire alu_shift_l,
	output wire alu_shift_r,
	output wire alu_shift_carry_in
);

// comb outputs
reg ORA;
reg AND;
reg EOR;
reg ADC;
reg STA;
reg LDA;
reg CMP;
reg SBC;

reg STX;
reg STY;
reg LDX;
reg LDY;
reg CPX;
reg CPY;
reg INX;
reg INY;
reg INC;
reg DEX;
reg DEY;
reg DEC;

reg ASL_A;
reg ASL_mem;
reg ROL_A;
reg ROL_mem;
reg LSR_A;
reg LSR_mem;
reg ROR_A;
reg ROR_mem;

reg TAY;
reg TYA;
reg TXA;
reg TAX;
reg TXS;
reg TSX;

reg PHA;
reg PLA;


// output logic
// register read/write
assign from_A = STA | CMP             | TAY | TAX | ORA | AND | EOR | ADC | SBC | ASL_A | ROL_A | LSR_A | ROR_A | PHA;
assign to_A   = LDA                   | TYA | TXA | ORA | AND | EOR | ADC | SBC | ASL_A | ROL_A | LSR_A | ROR_A | PLA;
assign from_X = STX | CPX | INX | DEX | TXA | TXS;
assign to_X   = LDX       | INX | DEX | TAX | TSX;
assign from_Y = STY | CPY | INY | DEY | TYA;
assign to_Y   = LDY       | INY | DEY | TAY;
assign from_S = TSX;
assign to_S   = TXS;

// memory read/write
assign from_mem = LDA | LDX | LDY | CMP | CPX | CPY | ORA | AND | EOR | ADC | SBC;
assign to_mem   = STA | STX | STY;

// alu control
assign alu_inc = INX | INY | INC;
assign alu_dec = DEX | DEY | DEC;
assign alu_or  = ORA;
assign alu_and = AND;
assign alu_eor = EOR;
assign alu_add = ADC;
assign alu_sub = SBC | CMP | CPY | CPX;
assign alu_shift_l = ASL_A | ASL_mem | ROL_A | ROL_mem;
assign alu_shift_r = LSR_A | LSR_mem | ROR_A | ROR_mem;
assign alu_shift_carry_in = ROL_A | ROL_mem | ROR_A | ROR_mem;


// helper wires
wire [2:0] ira = IR[7:5];	// instruction kind
wire [2:0] irb = IR[4:2];	// alu_addressing mode
wire [1:0] irc = IR[1:0];	// instruction group (one-hot, almost)


// ----------------------------------------------------
// decoders
// addressing mode

always @*
begin

	if (IR == 8'h20)
		adr_mode = `ADR_ABS_JSR;
	else if (IR == 8'h6C)
		adr_mode = `ADR_ABS_IND;
	else if (IR == 8'h4C)
		adr_mode = `ADR_ABS_JMP;
	else casex (IR)
	// IR = aaa bbb cc
	// b odd -- well defined
		8'bxxx_001_0x,
		8'b10x_001_1x: adr_mode = `ADR_ZPG;
		8'b0xx_001_1x,
		8'b11x_001_1x: adr_mode = `ADR_ZPG_RMW;
		
		8'bxxx_011_0x, // 4C, 6C -> see above if
		8'b10x_011_1x: adr_mode = `ADR_ABS;
		8'b0xx_011_1x,
		8'b11x_011_1x: adr_mode = `ADR_ABS_RMW;
		
		8'bxxx_101_0x,
		8'b10x_101_1x: adr_mode = `ADR_ZPG_X_Y;
		8'b0xx_101_1x,
		8'b11x_101_1x: adr_mode = `ADR_ZPG_X_RMW;
		
		8'bxxx_111_0x,
		8'b10x_111_1x: adr_mode = `ADR_ABS_X_Y;
		8'b0xx_111_1x,
		8'b11x_111_1x: adr_mode = `ADR_ABS_X_RMW;
		
	
	// center (arithmetic instructions)
		8'bxxx_000_x1: adr_mode = `ADR_ABS_X_IND;
		8'bxxx_010_x1: adr_mode = `ADR_IMM;
		8'bxxx_100_x1: adr_mode = `ADR_ZPG_IND_Y;
		8'bxxx_110_x1: adr_mode = `ADR_ABS_X_Y;
		
	// other
		8'bxxx_100_00: adr_mode = `ADR_REL; // b=4 c=0 
		8'b1xx_000_x0: adr_mode = `ADR_IMM; // a>=4 b=0 c=even (LDX/Y CPY)
		
		8'b000_000_x0: adr_mode = `ADR_STACK_BRK;
		8'b001_000_x0: adr_mode = `ADR_ABS_JSR;
		8'b010_000_x0: adr_mode = `ADR_STACK_RTI;
		8'b011_000_x0: adr_mode = `ADR_STACK_RTS;
		
		8'b1xx_x10_x0: adr_mode = `ADR_IMPL;
		
		8'b0x0_010_00: adr_mode = `ADR_STACK_PH;
		8'b0x1_010_00: adr_mode = `ADR_STACK_PL;
		
		8'b0xx_110_00: adr_mode = `ADR_IMPL;
		8'b0xx_x10_10: adr_mode = `ADR_ACCUM;
		
		default:
			adr_mode = `ADR_INVAL;
	endcase
	
	casex (IR)
		8'h96, // STX ZPG_Y
		8'hB6, // LDX ZPG_Y
		8'hBE, // LDX ABS_Y
		8'bxxx_100_x1, // IND_Y arithmetic
		8'bxxx_110_x1: // ABS_Y arithmetic
			index = `ADR_INDEX_Y;
		
		default:
			index = `ADR_INDEX_X;
	endcase
	
end

// ----------------------------------------------------
// operations

// branches
always @*
begin
	casex (IR)
	/*  BPL : 000 100 00
		BMI : 001 100 00
		BVC : 010 100 00
		BVS : 011 100 00
		BCC : 100 100 00
		BCS : 101 100 00
		BNE : 110 100 00
		BEQ : 111 100 00 */
			8'bxxx_100_00: branch = 1;
		
		default: branch = 0;
	endcase
end

// flags
always @*
begin
	casex (IR)
	/*  CLC : 000 110 00
		SEC : 001 110 00
		CLI : 010 110 00
		SEI : 011 110 00
		
		TYA : 100 110 00  <- not this
			
		CLV : 101 110 00
		CLD : 110 110 00
		SED : 111 110 00 */
			8'bxxx_110_00: flag = (ira != 3'b100);
		
		default: flag = 0;
	endcase
end

// alu + accumulator
always @*
begin
	casex (IR)
		8'b000_xxx_01:
			ORA = 1;
			
		default: ORA = 0;
	endcase
	
	casex (IR)
		8'b001_xxx_01:
			AND = 1;
			
		default: AND = 0;
	endcase
	
	casex (IR)
		8'b010_xxx_01:
			EOR = 1;
			
		default: EOR = 0;
	endcase
	
	casex (IR)
		8'b011_xxx_01:
			ADC = 1;
			
		default: ADC = 0;
	endcase
	
	casex (IR)
		8'b100_xxx_01:
			STA = 1;
			
		default: STA = 0;
	endcase
	
	casex (IR)
		8'b101_xxx_01:
			LDA = 1;
			
		default: LDA = 0;
	endcase
		
	casex (IR)
		8'b110_xxx_01:
			CMP = 1;
			
		default: CMP = 0;
	endcase
	
	casex (IR)
		8'b111_xxx_01:
			SBC = 1;
			
		default: SBC = 0;
	endcase
end

// X/Y
always @*
begin
	casex (IR)
		8'b100_xx1_x0: begin
			STX = IR[1];
			STY = ~IR[1];
		end
		
		default: begin
			STX = 0;
			STY = 0;
		end
	endcase
	
	casex (IR) 
		8'b101_000_x0,
		8'b101_xx1_x0: begin
			LDX = IR[1];
			LDY = ~IR[1];
		end
		
		default: begin
			LDX = 0;
			LDY = 0;
		end
	endcase
	
	casex (IR) 
		8'b11x_0x1_00,
		8'b11x_000_00: begin
			CPX = IR[5];
			CPY = ~IR[5];
		end
		
		default: begin
			CPX = 0;
			CPY = 0;
		end
	endcase
	
	casex (IR) 
		8'b11x_010_00: begin
			INX = IR[5];
			INY = ~IR[5];
		end
		
		default: begin
			INX = 0;
			INY = 0;
		end
	endcase
	
	casex (IR)
		8'b111_xx1_10:
			INC = 1;
		default: INC = 0;
	endcase
	
	casex (IR)
		8'hCA:   DEX = 1;
		default: DEX = 0;
	endcase
	
	casex (IR)
		8'h88:   DEY = 1;
		default: DEY = 0;
	endcase
	
	casex (IR)
		8'b110_xx1_10:
			DEC = 1;
		default: DEC = 0;
	endcase
end

// register transfers
always @*
begin
	casex (IR)
		8'hA8:   TAY = 1;
		default: TAY = 0;
	endcase

	casex (IR)
		8'h98:   TYA = 1;
		default: TYA = 0;
	endcase

	casex (IR)
		8'h8A:   TXA = 1;
		default: TXA = 0;
	endcase

	casex (IR)
		8'hAA:   TAX = 1;
		default: TAX = 0;
	endcase

	casex (IR)
		8'h9A:   TXS = 1;
		default: TXS = 0;
	endcase

	casex (IR)
		8'hBA:   TSX = 1;
		default: TSX = 0;
	endcase
end

// shifts
always @*
begin
	casex (IR)
		8'b000_xxx_10: begin
			ASL_A   = ~IR[2];
			ASL_mem =  IR[2];
		end
		default: begin
			ASL_A = 0;
			ASL_mem = 0;
		end
	endcase

	casex (IR)
		8'b001_xxx_10: begin
			ROL_A   = ~IR[2];
			ROL_mem =  IR[2];
		end
		default: begin
			ROL_A = 0;
			ROL_mem = 0;
		end
	endcase

	casex (IR)
		8'b010_xxx_10: begin
			LSR_A   = ~IR[2];
			LSR_mem =  IR[2];
		end
		default: begin
			LSR_A = 0;
			LSR_mem = 0;
		end
	endcase

	casex (IR)
		8'b011_xxx_10: begin
			ROR_A   = ~IR[2];
			ROR_mem =  IR[2];
		end
		default: begin
			ROR_A = 0;
			ROR_mem = 0;
		end
	endcase
end

// stack
// register transfers
always @*
begin
	casex (IR)
		8'h48:   PHA = 1;
		default: PHA = 0;
	endcase

	casex (IR)
		8'h68:   PLA = 1;
		default: PLA = 0;
	endcase
end

endmodule
