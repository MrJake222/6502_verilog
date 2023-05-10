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
	output wire [7:0] dbg_S_val,
	output wire [7:0] dbg_P_val
);

reg [7:0] data_bus_out_buf;
assign data_bus_out = RW ? 8'hZZ : data_bus_out_buf;

`define RW_READ		1'b1
`define RW_WRITE	1'b0

// ------------ address mode ------------ //
wire [4:0] cu_adr_mode;
wire cu_index; // X/Y

// ------------ instruction ------------ //
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
wire cu_from_mem;
wire cu_to_mem;

// alu control
wire cu_alu_inc;
wire cu_alu_dec;
wire cu_alu_or;
wire cu_alu_and;
wire cu_alu_eor;
wire cu_alu_add;
wire cu_alu_sub;
wire cu_alu_cmp;
wire cu_alu_shift_l;
wire cu_alu_shift_r;
wire cu_alu_shift_carry_in;

wire cu_update_alu_neg;
wire cu_update_alu_ov;
wire cu_update_alu_zero;
wire cu_update_alu_carry;

wire cu_update_clear_carry;
wire cu_update_set_carry;
wire cu_update_clear_int;
wire cu_update_set_int;
wire cu_update_clear_ov;

wire cu_branch_value;
wire cu_branch_neg;
wire cu_branch_ov;
wire cu_branch_carry;
wire cu_branch_zero;

reg [7:0] IR;

CPU_control CU (IR,
	cu_adr_mode,
	cu_index,
	
	cu_from_A, cu_to_A,
	cu_from_X, cu_to_X,
	cu_from_Y, cu_to_Y,
	cu_from_S, cu_to_S,

	cu_from_mem, cu_to_mem, 

	cu_alu_inc, cu_alu_dec,
	cu_alu_or, cu_alu_and,
	cu_alu_eor,
	cu_alu_add, cu_alu_sub, cu_alu_cmp,
	
	cu_alu_shift_l, cu_alu_shift_r,
	cu_alu_shift_carry_in,
    
    cu_update_alu_neg,
    cu_update_alu_ov,
    cu_update_alu_zero,
    cu_update_alu_carry,
    
    cu_update_clear_carry, cu_update_set_carry,
    cu_update_clear_int, cu_update_set_int,
    cu_update_clear_ov,
    
    cu_branch_value,
    cu_branch_neg, cu_branch_ov,
    cu_branch_carry, cu_branch_zero
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

reg flag_neg;
reg flag_ov;
reg flag_zero;
reg flag_carry;
wire [7:0] P = {
	flag_neg,
	flag_ov,
	1'b1, 1'b1, 1'b1, 1'b1,
	flag_zero,
	flag_carry
};

// alu carry in
reg alu_carry_in;
// alu operations
reg alu_add;
reg alu_sub;
reg alu_cmp;
reg alu_or;
reg alu_and;
reg alu_eor;
reg alu_inc;
reg alu_dec;
reg alu_shift_l;
reg alu_shift_r;
reg alu_shift_carry_in;

reg alu_pass_B;

reg [7:0] alu_A;
reg [7:0] alu_B;
wire [7:0] alu_out;

// alu flags out
wire alu_neg;
wire alu_ov;
wire alu_zero;
wire alu_carry_out;

// ALU
CPU_ALU ALU (
   .carry_in(alu_carry_in),
	    .add(alu_add),
	    .sub(alu_sub),
	    .cmp(alu_cmp),
	 .bit_or(alu_or),
	.bit_and(alu_and),
	.bit_eor(alu_eor),
	  .inc_B(alu_inc),
	  .dec_B(alu_dec),
	.shift_l(alu_shift_l),
	.shift_r(alu_shift_r),
.shift_carry_in(alu_shift_carry_in),
     .pass_B(alu_pass_B),

	.A(alu_A),
	.B(alu_B),
	
	.out(alu_out),
	
	.neg(alu_neg),
	.ov(alu_ov),
	.zero(alu_zero),
	.carry_out(alu_carry_out)
);

task alu_set_cu();
    alu_carry_in = flag_carry;
	alu_add = cu_alu_add;
	alu_sub = cu_alu_sub;
	alu_cmp = cu_alu_cmp;
	alu_or  = cu_alu_or;
	alu_and = cu_alu_and;
	alu_eor = cu_alu_eor;
	alu_inc = cu_alu_inc;
	alu_dec = cu_alu_dec;
	alu_shift_l = cu_alu_shift_l;
	alu_shift_r = cu_alu_shift_r;
	alu_shift_carry_in = cu_alu_shift_carry_in;
endtask

task alu_set_add();
    alu_carry_in = 0;
	alu_add = 1;
	alu_sub = 0;
	alu_cmp = 0;
	alu_or  = 0;
	alu_and = 0;
	alu_eor = 0;
	alu_inc = 0;
	alu_dec = 0;
	alu_shift_l = 0;
	alu_shift_r = 0;
	alu_shift_carry_in = 0;
endtask

task alu_set_inc();
    // carry in not set
    // inc/dec ignores carry
	alu_add = 0;
	alu_sub = 0;
	alu_cmp = 0;
	alu_or  = 0;
	alu_and = 0;
	alu_eor = 0;
	alu_inc = 1;
	alu_dec = 0;
	alu_shift_l = 0;
	alu_shift_r = 0;
	alu_shift_carry_in = 0;
endtask

task alu_set_dec();
	alu_add = 0;
	alu_sub = 0;
	alu_cmp = 0;
	alu_or  = 0;
	alu_and = 0;
	alu_eor = 0;
	alu_inc = 0;
	alu_dec = 1;
	alu_shift_l = 0;
	alu_shift_r = 0;
	alu_shift_carry_in = 0;
endtask

task alu_latch();
	alu_set_cu();
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
	
    if (cu_update_alu_neg)
        flag_neg <= alu_neg;
    if (cu_update_alu_ov)
        flag_ov <= alu_ov;
    if (cu_update_alu_zero)
        flag_zero <= alu_zero;
    if (cu_update_alu_carry)
        flag_carry <= alu_carry_out;
    
    if (cu_update_clear_carry)
        flag_carry <= 0;
    if (cu_update_set_carry)
        flag_carry <= 1;
    if (cu_update_clear_int)
        ;
    if (cu_update_set_int)
        ;
    if (cu_update_clear_ov)
        flag_ov <= 0;
endtask


task mem_write();
	RW <= `RW_WRITE;
	if (cu_from_A) data_bus_out_buf <= A;
	if (cu_from_X) data_bus_out_buf <= X;
	if (cu_from_Y) data_bus_out_buf <= Y;
	if (cu_from_S) data_bus_out_buf <= S;
endtask

// Logic

/*
 * state, PC helpers
 */

wire [15:0] PC_next = PC + 16'd1;
 
task set_PC_adr_bus(input [15:0] val);
	PC <= val;
	adr_bus <= val;
endtask

task set_PC_adr_bus_inc();
	set_PC_adr_bus(PC_next);
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
// increments state & PC, puts incremented PC on bus
task next_consume_put();
	state_inc();
	set_PC_adr_bus_inc();
endtask

// doesn't put PC on bus
// useful when consuming operand but not needing next operand
task next_consume();
	state_inc();
	PC <= PC_next;
endtask

// ...
task next_rst_consume();
	state_reset();
	set_PC_adr_bus_inc();
	RW <= `RW_READ;
endtask

// used on final state
// doesn't increment PC (but puts it on address bus), resets state and RW
task next_rst();
	adr_bus <= PC;
	state_reset();
	RW <= `RW_READ;
endtask

// used on intermediate state (not final)
// doesn'y consume any operands
task next_state_only();
	state_inc();
endtask


// set if page overflow/underflow occurs while branching/indexing
reg page_boundary;


task addr_abs_step_1();
	adr_low <= data_bus_in;
	next_consume_put();
endtask

task addr_abs_step_2();
	adr_bus <= { data_bus_in, adr_low };
	next_consume();

	if (cu_to_mem)
		// write to memory
		// CPU has to provide data this cycle
		// (memory write is next posedge)
		mem_write();
	
	// in case of read, data is fetched next cycle
endtask


task addr_abs_xy_step_1();
	alu_set_add();
	alu_A <= data_bus_in;
	if (cu_index == `ADR_INDEX_X)
		alu_B <= X;
	else
		alu_B <= Y;
	
	next_consume_put();
    page_boundary <= 0;
endtask

task addr_abs_xy_step_1_5_ov();
    adr_low <= alu_out;
    
    alu_B <= data_bus_in;
    alu_set_inc();
    
    // this intentonally stalls state
    // page_boundary to force addr_abs_xy_step_2
    page_boundary <= 1;
endtask

task addr_abs_xy_step_2();
    if (page_boundary)
        adr_bus <= { alu_out, adr_low };
    else
        adr_bus <= { data_bus_in, alu_out };
        
	next_consume();
	
	if (cu_to_mem)
		mem_write();
endtask


task addr_zpg_step_1();
    adr_bus <= { 8'h00, data_bus_in };
    next_consume();
	
	if (cu_to_mem)
		mem_write();
endtask


task addr_zpg_ind_y_step_1();
    adr_low <= data_bus_in;
    next_consume_put();
endtask

task addr_zpg_ind_y_step_2();
    adr_bus <= { 8'h00, adr_low };
    
    alu_B <= adr_low;
    alu_set_inc();
    
    next_state_only();
endtask

task addr_zpg_ind_y_step_3();
    adr_bus <= { 8'h00, alu_out };
    
    alu_A <= data_bus_in;
    alu_B <= Y;
    alu_set_add();
    
    next_state_only();
    page_boundary <= 0;
endtask

task addr_zpg_ind_y_step_3_5_ov();    
    adr_low <= alu_out;
    alu_B <= data_bus_in;
    alu_set_inc();
    
    // stalls state and sets page_boundary to force step 4
    page_boundary <= 1;
endtask

task addr_zpg_ind_y_step_4();
    if (page_boundary)
        adr_bus <= { alu_out, adr_low };
    else
        adr_bus <= { data_bus_in, alu_out };
    
    next_state_only();
    
    if (cu_to_mem)
		mem_write();
endtask


task exec_step_3();
	alu_latch();
	next_rst();
endtask


task exec_rmw_step_1();
	alu_set_cu();
	alu_B <= data_bus_in;
	next_state_only();
endtask

task exec_rmw_step_2();
	RW <= `RW_WRITE;
	data_bus_out_buf <= alu_out;
	next_state_only();
endtask

task exec_rmw_step_3();
	next_rst();
endtask

// TODO
// BRK
// interrupts, RTI
// pull/push processor
// 
// JMP 7C indexed indirect
// JMP 6C indirect
// 
// zeropage indexed
// indexed(X) indirect
// 
// 65c02
// STP, WAI
// BBR
// RMB
// zero page indexed indirect
// zero page indirect

always @ (negedge clk)
begin
	
	
	
	if (~n_reset)
	begin
		set_PC_adr_bus(16'h8000);
		RW <= `RW_READ;
		state <= 0;
	end else
	begin

		casex ({ cu_adr_mode, state })
			{`ADR_DONT_CARE, 3'd0}:
			begin
				IR <= data_bus_in;
				next_consume_put();
				
				alu_writeback();
				alu_pass_B <= 0;
			end
			
			/* --------------------- Absolute --------------------- */
			{`ADR_ABS, 3'd1}: addr_abs_step_1();
			{`ADR_ABS, 3'd2}: addr_abs_step_2();
			{`ADR_ABS, 3'd3}: exec_step_3();
			
			{`ADR_ABS_RMW, 3'd1}: addr_abs_step_1();
			{`ADR_ABS_RMW, 3'd2}: addr_abs_step_2();
			{`ADR_ABS_RMW, 3'd3}: exec_rmw_step_1();
			{`ADR_ABS_RMW, 3'd4}: exec_rmw_step_2();
			{`ADR_ABS_RMW, 3'd5}: exec_rmw_step_3();
			
			
			/* --------------------- Absolute JMP --------------------- */
			{`ADR_ABS_JMP, 3'd1}: addr_abs_step_1();
			{`ADR_ABS_JMP, 3'd2}:
			begin
				set_PC_adr_bus({data_bus_in, adr_low});
				state_reset();
			end

			
			/* ---------------------  Absolute indexed --------------------- */
			{`ADR_ABS_X_Y, 3'd1}: addr_abs_xy_step_1();
			{`ADR_ABS_X_Y, 3'd2}:
                if (alu_carry_out & ~page_boundary)
                    addr_abs_xy_step_1_5_ov(); // this stalls state on 2 and sets page_boundary to 1
                else
                    addr_abs_xy_step_2();
			{`ADR_ABS_X_Y, 3'd3}: exec_step_3();
			
			{`ADR_ABS_X_RMW, 3'd1}: addr_abs_xy_step_1();
			{`ADR_ABS_X_RMW, 3'd2}: addr_abs_xy_step_2();
			{`ADR_ABS_X_RMW, 3'd3}: exec_rmw_step_1();
			{`ADR_ABS_X_RMW, 3'd4}: exec_rmw_step_2();
			{`ADR_ABS_X_RMW, 3'd5}: exec_rmw_step_3();
			
            
            /* --------------------- Zeropage --------------------- */
            {`ADR_ZPG, 3'd1}: addr_zpg_step_1();
            {`ADR_ZPG, 3'd2}: exec_step_3();
            
            {`ADR_ZPG_RMW, 3'd1}: addr_zpg_step_1();
            {`ADR_ZPG_RMW, 3'd2}: exec_rmw_step_1();
            {`ADR_ZPG_RMW, 3'd3}: exec_rmw_step_2();
            {`ADR_ZPG_RMW, 3'd4}: exec_rmw_step_3();
            
            
            /* --------------------- Zeropage indirect indexed --------------------- */
			{`ADR_ZPG_IND_Y, 3'd1}: addr_zpg_ind_y_step_1();
			{`ADR_ZPG_IND_Y, 3'd2}: addr_zpg_ind_y_step_2();
			{`ADR_ZPG_IND_Y, 3'd3}: addr_zpg_ind_y_step_3();
			{`ADR_ZPG_IND_Y, 3'd4}: 
                if (alu_carry_out & ~page_boundary)
                    addr_zpg_ind_y_step_3_5_ov();
                else
                    addr_zpg_ind_y_step_4();
            {`ADR_ZPG_IND_Y, 3'd5}: exec_step_3();
            
            
			/* --------------------- Accumulator --------------------- */
			{`ADR_ACCUM, 3'd1}:
			begin
				alu_latch();
				next_rst();
			end
			
			
			/* --------------------- Immediate --------------------- */
			{`ADR_IMM, 3'd1}:
			begin
				alu_latch();
				next_rst_consume();
			end
			
			
			/* --------------------- Implied --------------------- */
			{`ADR_IMPL, 3'd1}:
			begin
				// implied mode used only for:
				// flags, nop, decrements, increments, transfers
				// no data bus used, we use alu_pass_B in case of
				// no inc/dec is active
				
				alu_pass_B <= 1;
				
				alu_latch();
				next_rst();
			end
			
			
			/* --------------------- Relative --------------------- */
			{`ADR_REL, 3'd1}:
			begin
				alu_A <= PC_next[7:0];
				alu_B <= data_bus_in;
				alu_set_add();
                
                if ((cu_branch_neg   && cu_branch_value == flag_neg  ) ||
                    (cu_branch_ov    && cu_branch_value == flag_ov   ) ||
                    (cu_branch_carry && cu_branch_value == flag_carry) ||
                    (cu_branch_zero  && cu_branch_value == flag_zero ))
                    
                    // take branch
                    next_consume_put();
                else
                
                    // don't take branch
                    next_rst_consume();
			end
			
			{`ADR_REL, 3'd2}:
			begin
                // PC is now +1 (no need to use PC_next)
                
				if (alu_B[7] && !alu_carry_out)
					// subtraction underflow
                    set_PC_adr_bus({PC[15:8] - 1, alu_out}); // TODO use alu
                
				else if (~alu_B[7] && alu_carry_out)
					// addition overflow
                    set_PC_adr_bus({PC[15:8] + 1, alu_out});
                
                else
                    // normal
                    set_PC_adr_bus({PC[15:8], alu_out});
				
				state_reset();
			end
		
		
			/* --------------------- Absolute/Stack JSR --------------------- */
            {`ADR_ABS_JSR, 3'd1}:
            begin
                adr_low <= data_bus_in;
                next_consume();
                
                adr_bus <= { 8'h01, S };
				
				alu_B <= S;
				alu_set_dec();
            end
            
            {`ADR_ABS_JSR, 3'd2}:
            begin
                RW <= `RW_WRITE;
                data_bus_out_buf <= PC[15:8];
            
                next_state_only();
            end
            
            {`ADR_ABS_JSR, 3'd3}:
            begin
                alu_B <= alu_out;
                
                adr_bus <= { 8'h01, alu_out };
                data_bus_out_buf <= PC[7:0];
                
                next_state_only();
            end
            
            {`ADR_ABS_JSR, 3'd4}:
            begin
                S <= alu_out;
                
                adr_bus <= PC;
                RW <= `RW_READ;
                
                next_state_only();
            end
            
            {`ADR_ABS_JSR, 3'd5}:
            begin
                set_PC_adr_bus({data_bus_in, adr_low});
                state_reset();
            end
            
            
            {`ADR_STACK_RTS, 3'd1}: 
            begin
                alu_B <= S;
				alu_set_inc();
				
				next_state_only();
            end
            
            {`ADR_STACK_RTS, 3'd2}: 
            begin
                alu_B <= alu_out;
				adr_bus <= { 8'h01, alu_out };
                
                next_state_only();
            end
            
            {`ADR_STACK_RTS, 3'd3}: 
            begin
                S <= alu_out;
				adr_bus <= { 8'h01, alu_out };
                adr_low <= data_bus_in;
                
                next_state_only();
            end
            
            {`ADR_STACK_RTS, 3'd4}: 
            begin
                S <= alu_out;
                PC <= {data_bus_in, adr_low};
                
                next_state_only();
            end
            
            {`ADR_STACK_RTS, 3'd5}:
            begin
                next_rst_consume();
            end

            
			/* --------------------- Stack push --------------------- */
			{`ADR_STACK_PH, 3'd1}:
			begin
				adr_bus <= { 8'h01, S };
				mem_write();
				
				alu_B <= S;
				alu_set_dec();
				
				next_state_only();
			end
			
			{`ADR_STACK_PH, 3'd2}:
			begin
				S <= alu_out;
				next_rst();
			end
			
			
			/* --------------------- Stack pull --------------------- */
			{`ADR_STACK_PL, 3'd1}:
			begin
				alu_B <= S;
				alu_set_inc();
				
				next_state_only();
			end
			
			{`ADR_STACK_PL, 3'd2}:
			begin
				adr_bus <= { 8'h01, alu_out };
				
				S <= alu_out;
				next_state_only();
			end
			
			{`ADR_STACK_PL, 3'd3}:
			begin
				alu_latch();
				next_rst();
			end
            
		endcase
	end
end

// debug
assign dbg_PC_val = PC;
assign dbg_IR_val = IR;
assign dbg_A_val = A;
assign dbg_X_val = X;
assign dbg_Y_val = Y;
assign dbg_S_val = S;
assign dbg_P_val = P;

endmodule
