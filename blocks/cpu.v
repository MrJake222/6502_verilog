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

//wire cu_alu_op = cu_add | cu_sub; // also alu output enable
//wire cu_sb_pass = cu_to_mem | (cu_from_mem & ~cu_alu_op);


// Timing values 
// ~~(all positive logic)~~
// ~~(controlled by clocked logic on posedge)~~
// derived from RAMS
// ------------ registers ------------ //
// controlled by state machine
reg PC_load;
reg PC_inc;

reg state_reset;

reg IR_load;

reg reg_read1, reg_read2;


reg ram_cycle;  // marks when CPU should prepare all data for RAM memory access
					//   (address, data for writing)

//reg reg_read;  // register outputs data to bus
reg reg_write; // register latched data from bus
               //   now high iif state=0 (latch from alu_out_reg)

//reg mem_indirect;   // address forced from address registers, PC disabled
					//   (reading from address specified by operands)
//reg data_in_force;  // data forcefully let in from data bus
					//   (reading instruction data)
//reg data_in;		// data let in through buffer from data bus to internal data bus
					//   (normal instruction cycle)
//reg data_out;		// data let out to data bus from internal buffer

//reg data_in_force1;
//reg data_in_force2;
//wire data_in_force = data_in_force1 & data_in_force2;

reg adr_low_latch;
reg adr_high_latch;

// first latch to alu output on the last cycle of instruction
// then on 1st cycle of new instruction latch appropriate register
// (effectively logic is the same as previous reg_write was)
reg alu_out_latch;


// ------------ timed ALU signals ------------ //
// controlled here (timing-aware version ALU signals)
// this control directly all the dataflow of the CPU

reg reg_read;
always @*
begin

	if (ram_cycle)
		reg_read = 1;
	else
		reg_read = reg_read1;

end

// where to get/latch data 
// used by registers to latch/output data
wire from_A = cu_from_A & reg_read;
wire to_A   = cu_to_A   & reg_write;
wire from_X = cu_from_X & reg_read;
wire to_X   = cu_to_X   & reg_write;
wire from_Y = cu_from_Y & reg_read;
wire to_Y   = cu_to_Y   & reg_write;
wire from_S = cu_from_S & reg_read;
wire to_S   = cu_to_S   & reg_write;

// buffer direction control
reg from_mem;
reg to_mem;
always @*
begin
	/*if (data_in_force)
		from_mem = 1;
	else if (data_in)
		from_mem = cu_from_mem;
	else
		from_mem = 0;
	
	
	if (data_in_force)
		to_mem = 0;
	else if (data_out)
		to_mem = cu_to_mem;
	else
		to_mem = 0;
	
	
	if (mem_indirect)
		RW = cu_from_mem;
	else
		RW = 1;*/
		
	if (ram_cycle)
	begin
		from_mem = cu_from_mem;
		to_mem = cu_to_mem;
		RW = cu_from_mem;
	end else
	begin
		from_mem = ~reg_read1;
		to_mem = 0;
		RW = 1;
	end
end

// datapath control
wire reg_to_mem = cu_reg_to_mem & reg_read; // direct write from register to memory
											//   used to open side bus buffer and output to internal data bus
wire reg_to_reg = cu_reg_to_reg & reg_read; // internal register transfer (passes ALU - used for increments)
											//   used to open side bus buffer
wire mem_to_reg = cu_mem_to_reg; // direct read from memory to register
								 //   used to pass A reg in ALU (it's default i think?)
wire mem_to_mem = cu_mem_to_mem; // not implemented (RMW)

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

wire sb2data_pass = (reg_to_mem | reg_to_reg) & reg_read;
wire data2sb_pass = 0;//cu_sb_pass & any_w;

// ALU
wire [7:0] alu_val;

// Register mangling (load/increment)
// wire alu_b_zero = cu_reg_transfer;//~cu_alu_op;
// wire alu_b_one = 0;

wire alu_out_oe = reg_write;

// Output enable to side bus
wire alu_oe;



// Instances

// clocked
CPU_counter #( .WIDTH(16) ) PC (
	.clk(clk),
	.OE(~ram_cycle),
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
	.OE(ram_cycle),
	.WE(adr_low_latch),
	.data_bus_in(intr_data_bus),
	.data_bus_out(addr_bus[7:0])
);

CPU_register adr_high_reg (
	.clk(clk),
	.OE(ram_cycle),
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
	
	.pass_B(0),
	.inc_A(alu_inc),
	.inc_B(0),
	
	.A(intr_data_bus),
	.B(side_bus),
	
	.out(alu_val)
);

CPU_register ALU_out_reg (
	.clk(clk),
	.OE(alu_out_oe),
	.WE(alu_out_latch),
	.data_bus_in(alu_val),
	.data_bus_out(side_bus)
);

CPU_bus_buffer side_data_buffer (
	.port_A(intr_data_bus),
	.port_B(side_bus),
	.AB(data2sb_pass),
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
	// register access
	/*casex (RAMS)
		{1'bx, `ADR_ABS, 3'd3},
		{1'bx, `ADR_ABS, 3'd4},
		{1'bx, `ADR_IMM, 3'd1},
		{1'bx, `ADR_IMPL, 3'd1}:
			reg_access <= 1;
			
		default: reg_access <= 0;
	endcase*/
	casex (RAMS)
		{1'bx, 4'bxxxx, 3'd0}:
			reg_write <= 1;
			
		default: reg_write <= 0;
	endcase
	
	casex (RAMS)
		{1'bx, `ADR_ABS, 3'd3},
		{1'bx, `ADR_IMM, 3'd1},
		{1'bx, `ADR_IMPL, 3'd1}:
			alu_out_latch <= 1;
			
		default: alu_out_latch <= 0;
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
	// bus buffer control + register r/w
	/*casex (RAMS)
		{1'bx, `ADR_ABS, 3'd3}:
			data_in <= 1;
	
		default: data_in <= 0;
	endcase
	
	reg_read2 <= reg_read1;
	
	// critical section
	casex (RAMS)
		{1'bx, `ADR_ABS, 3'd3},
		{1'bx, `ADR_IMPL, 3'd1}:
			data_in_force <= 0;
			
		default: data_in_force <= 1;
	endcase*/
	
	casex (RAMS)
		{1'bx, `ADR_ABS, 3'd3},
		{1'bx, `ADR_IMM, 3'd1},
		{1'bx, `ADR_IMPL, 3'd1}:
			reg_read1 <= 1;
			
		default: reg_read1 <= 0;
	endcase
end

// same as above but for combinational logic
always @*
begin
	
	/*casex (RAMS)
		{1'bx, `ADR_ABS, 3'd3},
		{1'bx, `ADR_IMM, 3'd1},
		{1'bx, `ADR_IMPL, 3'd1}:
		//{1'bx, 4'dX, 3'd0}:
			reg_read1 <= 1;
			
		default: reg_read1 <= 0;
	endcase
	
	// mem_indirect = data_out maybe??
	
	// ----------------------------------------
	// bus buffer control
	casex (RAMS)
		{1'bx, `ADR_ABS, 3'd3}:
		//{1'bx, `ADR_IMPL, 3'd1}:
			data_in_force1 <= 0;
			
		default: data_in_force1 <= 1;
	endcase
	
	casex (RAMS)
		{1'bx, `ADR_ABS, 3'd3}:
			mem_indirect <= 1;
		
		default: mem_indirect <= 0;
	endcase*/
	
	casex (RAMS)
		{1'bx, `ADR_ABS, 3'd3}:
			ram_cycle <= 1;
	
		default: ram_cycle <= 0;
	endcase
end

// debug
assign dbg_IR_val = IR_val;
// assign dbg_A_val = acc_out;

endmodule
