`include "config.vh"

module CPU_control (
	input wire [7:0] IR,			// instruction register
	
	output reg [3:0] adr_mode,	// alu_address mode
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
	output wire alu_sub
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
reg DEX;
reg DEY;

reg ASL_mem;
reg ASL_A;
reg ROL_mem;
reg ROL_A;
reg LSR_mem;
reg LSR_A;
reg ROR_mem;
reg ROR_A;

reg TAY;
reg TYA;
reg TXA;
reg TAX;
reg TXS;
reg TSX;


// output logic
// register read/write
assign from_A = STA | CMP             | TAY | TAX | ORA | AND | EOR | ADC | SBC;
assign to_A   = LDA                   | TYA | TXA | ORA | AND | EOR | ADC | SBC;
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
assign alu_inc = INX | INY;
assign alu_dec = DEX | DEY;
assign alu_or  = ORA;
assign alu_and = AND;
assign alu_eor = EOR;
assign alu_add = ADC;
assign alu_sub = SBC | CMP | CPY | CPX;


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
		adr_mode = `ADR_ABS;
	else if (IR == 8'h6C)
		adr_mode = `ADR_IND;
	else casex (IR)
	// IR = aaa bbb cc
	// b odd -- well defined
		8'bxxx_001_xx: adr_mode = `ADR_ZPG;
		8'bxxx_011_xx: adr_mode = `ADR_ABS; // 6C -> IND
		8'bxxx_101_xx: adr_mode = `ADR_ZPG_I;
		8'bxxx_111_xx: adr_mode = `ADR_ABS_I;
	
	// center (arithmetic instructions)
		8'bxxx_000_x1: adr_mode = `ADR_X_IND;
		8'bxxx_010_x1: adr_mode = `ADR_IMM;
		8'bxxx_100_x1: adr_mode = `ADR_IND_Y;
		8'bxxx_110_x1: adr_mode = `ADR_ABS_I;
		
	// other
		8'bxxx_100_00: adr_mode = `ADR_REL; // b=4 c=0 
		8'b1xx_000_x0: adr_mode = `ADR_IMM; // a>=4 b=0 c=even (LDX/Y CPY)
		8'b0xx_000_x0: adr_mode = `ADR_IMPL;// a<4 b=0 c=even 	20 -> ABS
		
		8'bxxx_x10_x0: adr_mode = `ADR_IMPL;// b=(2,6) c=even (stack, INC/DEC, transfers, ROL/Rs)
		
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
		8'hCA:   DEX = 1;
		default: DEX = 0;
	endcase
	
	casex (IR)
		8'h88:   DEY = 1;
		default: DEY = 0;
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

endmodule
