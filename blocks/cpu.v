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

reg alu_add;
reg alu_sub;
reg alu_or;
reg alu_and;
reg alu_eor;
reg alu_inc;
reg [7:0] ALU_A;
reg [7:0] ALU_B;
wire [7:0] alu_val;

// ALU
CPU_ALU ALU (
	.add(alu_add),
	.sub(alu_sub),
	.bit_or(alu_or),
	.bit_and(alu_and),
	.bit_eor(alu_eor),
	
	.inc_A(alu_inc),
	
	.A(ALU_A),
	.B(ALU_B),
	
	.out(alu_val)
);

// Logic
// gluing together reset, address mode and current state
// RAMS = reset addr mode state (positive logic)
wire [7:0] RAMS = { ~n_reset, cu_adr_mode, state };

task set_PC_adr_bus(input [15:0] val);
begin
	PC <= val;
	adr_bus <= val;
end
endtask

task set_PC_adr_bus_inc();
begin
	set_PC_adr_bus(PC + 1);
end
endtask

task state_inc();
begin
	state <= state + 1;
end
endtask

task state_reset();
begin
	state <= 0;
end
endtask

task next();
begin
	state_inc();
	set_PC_adr_bus_inc();
end
endtask

task next_rst();
begin
	state_reset();
	set_PC_adr_bus_inc();
	RW <= `RW_READ;
end
endtask

task next_state();
begin
	state_inc();
end
endtask

always @ (negedge clk)
begin
	
	
	
	if (~n_reset)
	begin
		set_PC_adr_bus(16'h8000);
		RW <= `RW_READ;
		state <= 0;
	
		// exceptional conditions
		//PC_no_inc <= 0;
		//PC_no_drive_bus <= 0;
		//state_reset <= 1;
		//instr_execute <= 0;
	end else
	begin

		/*if (state_reset)
		begin
			state_reset <= 0;
			state <= 0;
			RW <= `RW_READ;
		end else
		begin*/
			casex (RAMS)
				{1'b0, `ADR_DONT_CARE, 3'd0}:
				begin
					IR <= data_bus_in;
					next();
				end
				
				/* --------------------- Absolute addressing --------------------- */
				{1'b0, `ADR_ABS, 3'd1}:
				begin
					adr_low <= data_bus_in;
					//PC_no_drive_bus <= 1;
					//PC_no_inc <= 1;
					next();
				end
				
				{1'b0, `ADR_ABS, 3'd2}:
				begin
					adr_bus <= { data_bus_in, adr_low };
					//state_reset <= 1;
					
					if (cu_to_mem)
					begin
						// write to memory
						// CPU only provides data
						RW <= `RW_WRITE;
						if (cu_from_A) data_bus_out_buf <= A;
						if (cu_from_X) data_bus_out_buf <= X;
						if (cu_from_Y) data_bus_out_buf <= Y;
						if (cu_from_S) data_bus_out_buf <= S;
						
					end else
					begin
						// read from memory
						// need to perform the read on the next cycle
						//instr_execute <= 1;
					end
					
					// next();
					next_state();
				end
				
				{1'b0, `ADR_ABS, 3'd3}:
				begin
					if (cu_to_A) A <= data_bus_in;
					if (cu_to_X) X <= data_bus_in;
					if (cu_to_Y) Y <= data_bus_in;
					if (cu_to_S) S <= data_bus_in;
					
					next_rst();
				end
				
				/* --------------------- Immediate addressing --------------------- */
				{1'b0, `ADR_IMM, 3'd1}:
				begin
					//state_reset <= 1; // TODO this needs to be earlier
					
					if (cu_to_A) A <= data_bus_in; // TODO write to alu, single statement or task
					if (cu_to_X) X <= data_bus_in;
					if (cu_to_Y) Y <= data_bus_in;
					if (cu_to_S) S <= data_bus_in;
					
					next_rst();
				end
			endcase
		
			//state <= state + 1;
		//end
		
		
		
		
		/*if (instr_execute)
		begin
			instr_execute <= 0;
			
			if (cu_to_A) A <= data_bus_in;
			if (cu_to_X) X <= data_bus_in;
			if (cu_to_Y) Y <= data_bus_in;
			if (cu_to_S) S <= data_bus_in;
		end*/
	end
end

endmodule
