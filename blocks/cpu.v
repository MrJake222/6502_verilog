`include "config.vh"

module CPU (
	input wire clk,
	input wire n_reset,
	
	// buses
	output wire [15:0] addr_bus,
	inout wire [7:0] data_bus,
	
	// control signals
	output reg RW, // write = 0
	
	// debug signals
	output wire [7:0] dbg_IR_val,
	output wire [7:0] dbg_A_val
);

// Control wires/regs
// controlled here or by submodules

// IR
wire [7:0] IR_val;

// State
wire [2:0] state_val;

// Control unit outputs (not respecting timings)
// based only on current instruction
// ------------ address mode ------------ //
wire [3:0] adr_mode;
wire index; // X/Y

// gluing together reset, address mode and current state
// RAMS = reset addr mode state
wire [7:0] RAMS = { ~n_reset, adr_mode, state_val };

// ------------ instruction ------------ //
wire branch, flag;
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

CPU_control CU (IR_val,
	adr_mode, index,
	branch, flag,
	
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


// Timing values 
// derived from RAMS
// ------------ registers ------------ //
// controlled by state machine
reg PC_load;
reg PC_inc;
reg state_reset;
reg IR_load;

reg adr_low_latch;
reg adr_high_latch;


reg tim_work_cycle;  // marks when CPU should do majority of work (not reading program memory)
                     // memory writes, register reads, latching to ALU

// write back from ALU out to register
// first latch to alu output on the last cycle of instruction
// then on 1st cycle of new instruction latch appropriate register
reg tim_writeback;



// ------------ timed ALU signals ------------ //
// controlled here (timing-aware version ALU signals)
// this control directly all the dataflow of the CPU

// where to get/latch data 
// used by registers to latch/output data
wire from_A = cu_from_A & tim_work_cycle;
wire to_A   = cu_to_A   & tim_writeback;
wire from_X = cu_from_X & tim_work_cycle;
wire to_X   = cu_to_X   & tim_writeback;
wire from_Y = cu_from_Y & tim_work_cycle;
wire to_Y   = cu_to_Y   & tim_writeback;
wire from_S = cu_from_S & tim_work_cycle;
wire to_S   = cu_to_S   & tim_writeback;

// buffer direction control
reg from_mem;
reg to_mem;
always @*
begin	
	if (tim_work_cycle)
	begin
		from_mem = cu_from_mem;
		to_mem = cu_to_mem;
		RW = cu_from_mem;
	end else
	begin
		from_mem = 1;
		to_mem = 0;
		RW = 1;
	end
end

// datapath control
wire reg_to_mem = cu_reg_to_mem & tim_work_cycle; // direct write from register to memory
											      //   used to open side bus buffer and output to internal data bus
wire reg_to_reg = cu_reg_to_reg & tim_work_cycle; // internal register transfer (passes ALU - used for increments)
										          //   used to open side bus buffer
wire mem_to_reg = cu_mem_to_reg & tim_work_cycle; // direct read from memory to register
								                  //   variable itself unused for now
wire mem_to_mem = cu_mem_to_mem & tim_work_cycle; // not implemented (RMW)

// alu control (async)
wire alu_inc = cu_alu_inc;
wire alu_dec = cu_alu_dec;
wire alu_or  = cu_alu_or;
wire alu_and = cu_alu_and;
wire alu_eor = cu_alu_eor;
wire alu_add = cu_alu_add;
wire alu_sub = cu_alu_sub;


// ------------ other control signals ------------ //
// Bus fabric
wire [7:0] intr_data_bus;
wire [7:0] side_bus;

wire sb2data_pass = reg_to_mem | reg_to_reg;

// ALU
wire [7:0] alu_val;

wire alu_out_latch = tim_work_cycle;

reg operand_from_rom;
always @*
begin
	case (adr_mode)
		`ADR_IMM,
		`ADR_REL:
			operand_from_rom = 1;
		
		default: operand_from_rom = 0;
	endcase
end

wire mem_indirect = tim_work_cycle & ~operand_from_rom;


// Instances

// clocked
CPU_counter #( .WIDTH(16) ) PC (
	.clk(clk),
	.OE(~mem_indirect),
	.WE(PC_load),
	.cnt_enable(PC_inc),
	.bus_in(16'h8000),
	.bus_out(addr_bus)
);

CPU_counter #( .WIDTH(3) ) state_reg (
	.clk(clk),
	.OE(1),
	.WE(state_reset),
	.cnt_enable(1),
	.bus_in(3'd0),
	.bus_out(state_val)
);

CPU_register IR (
	.clk(clk),
	.OE(1),
	.WE(IR_load),
	.data_bus_in(intr_data_bus),
	.data_bus_out(IR_val)
);

// address buffers
CPU_register adr_low_reg (
	.clk(clk),
	.OE(mem_indirect),
	.WE(adr_low_latch),
	.data_bus_in(intr_data_bus),
	.data_bus_out(addr_bus[7:0])
);

CPU_register adr_high_reg (
	.clk(clk),
	.OE(mem_indirect),
	.WE(adr_high_latch),
	.data_bus_in(intr_data_bus),
	.data_bus_out(addr_bus[15:8])
);

// Data register
CPU_register A_reg (
	.clk(clk),
	.OE(from_A),
	.WE(to_A),
	.data_bus_in(side_bus),
	.data_bus_out(side_bus)
);

// Index registers
CPU_register X_reg (
	.clk(clk),
	.OE(from_X),
	.WE(to_X),
	.data_bus_in(side_bus),
	.data_bus_out(side_bus)
);

CPU_register Y_reg (
	.clk(clk),
	.OE(from_Y),
	.WE(to_Y),
	.data_bus_in(side_bus),
	.data_bus_out(side_bus)
);

// Stack register
CPU_register S_reg (
	.clk(clk),
	.OE(from_S),
	.WE(to_S),
	.data_bus_in(side_bus),
	.data_bus_out(side_bus)
);


// combinational
CPU_bus_buffer mem_buffer (
	.port_A(data_bus),
	.port_B(intr_data_bus),
	.AB(from_mem),
	.BA(to_mem)
);

// ALU
CPU_ALU ALU (
	.add(alu_add),
	.sub(alu_sub),
	
	.inc_A(alu_inc),
	
	.A(intr_data_bus),
	.B(side_bus),
	
	.out(alu_val)
);

CPU_register ALU_out_reg (
	.clk(clk),
	.OE(tim_writeback),
	.WE(alu_out_latch),
	.data_bus_in(alu_val),
	.data_bus_out(side_bus)
);

CPU_bus_buffer side_data_buffer (
	.port_A(intr_data_bus),
	.port_B(side_bus),
	.AB(0),
	.BA(sb2data_pass)
);

// Logic

// setup internal workings control
// variable-oriented design
// coherent blocks controlling one variable with RAMS
always @ (posedge clk)
begin
	// ----------------------------------------
	// basic processor workings
	casex(RAMS)
		// reset
		8'b1_xxxx_xxx:
			PC_load <= 1;
		
		default: PC_load <= 0;
	endcase
	
	casex(RAMS)
		// {1'bx, `ADR_ABS, 3'd2},
		{1'bx, `ADR_ABS, 3'd3},
		{1'bx, `ADR_IMPL, 3'd1}:
			PC_inc <= 0;
		
		default: PC_inc <= 1;
	endcase
	
	// ----------------------------------------
	// state counter reset
	// used on reset & addressing mode end
	casex(RAMS)
		// reset
		8'b1_xxxx_xxx,
		
		// no external reset
		{1'b0, `ADR_ABS, 3'd3},
		{1'b0, `ADR_IMM, 3'd1},
		{1'b0, `ADR_IMPL, 3'd1}:
		
			state_reset <= 1;
		
		
		default: state_reset <= 0;
	endcase
	
	// IR load always on state 0
	casex(RAMS)
		8'b0_xxxx_000:
			IR_load <= 1;
		
		default: IR_load <= 0;
	endcase
	
	// ----------------------------------------
	// memory address latches
	casex (RAMS)
		{1'bx, `ADR_ABS, 3'd1}:
			adr_low_latch <= 1;
			
		default: adr_low_latch <= 0;
	endcase
		
	casex (RAMS)
		{1'bx, `ADR_ABS, 3'd2}:
			adr_high_latch <= 1;
			
		default: adr_high_latch <= 0;
	endcase
	
	// ----------------------------------------
	// register access
	casex (RAMS)
		{1'bx, 4'bxxxx, 3'd0}:
			tim_writeback <= 1;
			
		default: tim_writeback <= 0;
	endcase
end

// same as above but for combinational logic
always @*
begin
	casex (RAMS)
		{1'bx, `ADR_ABS, 3'd3},
		{1'bx, `ADR_IMM, 3'd1},
		{1'bx, `ADR_IMPL, 3'd1}:
			tim_work_cycle <= 1;
	
		default: tim_work_cycle <= 0;
	endcase
end

// debug
assign dbg_IR_val = IR_val;
// assign dbg_A_val = acc_out;

endmodule
