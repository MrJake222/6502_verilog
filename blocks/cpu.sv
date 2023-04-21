`include "config.vh"

module CPU (
	input wire clk,
	input wire n_reset,
	
	// buses
	output reg [15:0] adr_bus,
	output wire [7:0] data_bus_out,
	input wire [7:0] data_bus_in,
	
	// control signals
	output reg RW,
	
	// debug signals
	output wire [15:0] dbg_PC_val,
	output wire [7:0] dbg_IR_val,
	output wire [7:0] dbg_A_val,
	output wire [7:0] dbg_X_val,
	output wire [7:0] dbg_Y_val,
	output wire [7:0] dbg_S_val
);

reg [7:0] data_bus_out_buf;
assign data_bus_out = RW ? 8'hZZ : data_bus_out_buf;

`define RW_READ		1'b1
`define RW_WRITE	1'b0

// ------------ address mode ------------ //
wire [3:0] cu_adr_mode;
wire cu_index; // X/Y

// ------------ instruction ------------ //
wire cu_branch;
wire cu_flag;

// where to get/latch data 
wire cu_from_A;
wire cu_to_A;
wire cu_from_X;
wire cu_to_X;
wire cu_from_Y;
wire cu_to_Y;
wire cu_from_S;

wire cu_to_S;
// memory read/write
// buffer direction control
wire cu_from_mem;   // any data required from memory (for reg_to_mem) or ALU operation?
wire cu_to_mem;     // any data needs to be written to memory?

// datapath control
wire cu_reg_to_mem; // direct write from register to memory
wire cu_reg_to_reg; // internal register transfer
wire cu_mem_to_reg; // direct read from memory to register
wire cu_mem_to_mem;

// alu control
wire cu_alu_inc;
wire cu_alu_dec;
wire cu_alu_or;
wire cu_alu_and;
wire cu_alu_eor;
wire cu_alu_add;
wire cu_alu_sub;

reg [7:0] IR;

CPU_control CU (IR,
	cu_adr_mode,
	cu_index,
	
	cu_branch,
	cu_flag,
	
	cu_from_A, cu_to_A,
	cu_from_X, cu_to_X,
	cu_from_Y, cu_to_Y,
	cu_from_S, cu_to_S, 

	cu_from_mem, cu_to_mem, 
	
	cu_reg_to_mem, cu_reg_to_reg,
	cu_mem_to_reg, cu_mem_to_mem, 

	cu_alu_inc, cu_alu_dec,
	cu_alu_or, cu_alu_and,
	cu_alu_eor,
	cu_alu_add, cu_alu_sub
);


reg [15:0] PC;
reg [2:0] state;
`define STATE_DONT_CARE	3'bXXX
reg [7:0] adr_low;
//reg [7:0] adr_high;

reg [7:0] A;
reg [7:0] X;
reg [7:0] Y;
reg [7:0] S;


/*reg alu_add;
reg alu_sub;
reg alu_or;
reg alu_and;
reg alu_eor;
reg alu_inc;*/
reg [7:0] alu_A;
reg [7:0] alu_B;
wire [7:0] alu_out;

reg alu_pass_B;

// ALU
CPU_ALU ALU (
	    .add(cu_alu_add),
	    .sub(cu_alu_sub),
	 .bit_or(cu_alu_or),
	.bit_and(cu_alu_and),
	.bit_eor(cu_alu_eor),
	  .inc_B(cu_alu_inc),
     .pass_B(alu_pass_B),

	.A(alu_A),
	.B(alu_B),
	
	.out(alu_out)
);

task alu_latch();
	alu_A <= data_bus_in;
	if (cu_from_A) alu_B <= A;
	if (cu_from_X) alu_B <= X;
	if (cu_from_Y) alu_B <= Y;
	if (cu_from_S) alu_B <= S;
endtask

task alu_writeback();
	if (cu_to_A) A <= alu_out;
	if (cu_to_X) X <= alu_out;
	if (cu_to_Y) Y <= alu_out;
	if (cu_to_S) S <= alu_out;
endtask


// Logic
// gluing together reset, address mode and current state
// RAMS = reset addr mode state (positive logic)
wire [7:0] RAMS = { ~n_reset, cu_adr_mode, state };

/*
 * state, PC helpers
 */
task set_PC_adr_bus(input [15:0] val);
	PC <= val;
	adr_bus <= val;
endtask

task set_PC_adr_bus_inc();
	set_PC_adr_bus(PC + 1);
endtask

task state_inc();
	state <= state + 1;
endtask

task state_reset();
	state <= 0;
endtask


/*
 * end-of-state helper functions
 */
// used on intermediate state (not final)
// increments state & PC
task next();
	state_inc();
	set_PC_adr_bus_inc();
endtask

// used on final state
// increments PC, resets state and RW
task next_rst();
	state_reset();
	set_PC_adr_bus_inc();
	RW <= `RW_READ;
endtask

// used on final state
// doesn't increment PC, resets state and RW
// used for example in implied mode when operand is not used
task next_rst_no_PC();
	state_reset();
	RW <= `RW_READ;
endtask

// used on intermediate state (not final)
// but when address bus is loaded with something (stack, abs address)
// doesn't increment and push out PC
task next_state_only();
	state_inc();
endtask



task mem_write();
	RW <= `RW_WRITE;
	if (cu_from_A) data_bus_out_buf <= A;
	if (cu_from_X) data_bus_out_buf <= X;
	if (cu_from_Y) data_bus_out_buf <= Y;
	if (cu_from_S) data_bus_out_buf <= S;
endtask


always @ (negedge clk)
begin
	
	
	
	if (~n_reset)
	begin
		set_PC_adr_bus(16'h8000);
		RW <= `RW_READ;
		state <= 0;
	end else
	begin

		casex (RAMS)
			{1'b0, `ADR_DONT_CARE, 3'd0}:
			begin
				IR <= data_bus_in;
				next();
				
				alu_writeback();
				alu_pass_B <= 0;
			end
			
			
			/* --------------------- Absolute addressing --------------------- */
			{1'b0, `ADR_ABS, 3'd1}:
			begin
				adr_low <= data_bus_in;
				next();
			end
			
			{1'b0, `ADR_ABS, 3'd2}:
			begin
				adr_bus <= { data_bus_in, adr_low };
				next_state_only();

				if (cu_to_mem)
					// write to memory
					// CPU has to provide data this cycle
					// (memory write is next posedge)
					mem_write();
				
				// in case of read, data is fetched next cycle
			end
			
			{1'b0, `ADR_ABS, 3'd3}:
			begin
				alu_latch();
				next_rst();
			end
			
			
			/* --------------------- Immediate addressing --------------------- */
			{1'b0, `ADR_IMM, 3'd1}:
			begin				
				alu_latch();
				next_rst();
			end
			
			
			/* --------------------- Implied --------------------- */
			{1'b0, `ADR_IMPL, 3'd1}:
			begin
				// implied mode used only for:
				// flags, nop, decrements, increments, transfers
				// no data bus used, we use alu_pass_B in case of
				// no inc/dec is active
				
				alu_pass_B <= 1;
				alu_latch();
				
				next_rst_no_PC();
			end
		endcase
	end
end

endmodule
