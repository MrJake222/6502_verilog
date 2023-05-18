module PS2 (
	input wire ps2_clk,
	input wire ps2_data,
	input wire RESB,
    
    input wire sys_clk,
    input wire [15:0] sys_adr,
    output reg [7:0] sys_data,
    output reg sys_irq,
    
    output wire [9:0] dbg
);

// 0x4000 - 0x5FFF
wire sys_select = ~sys_adr[15] & sys_adr[14] & ~sys_adr[13];
wire sys_rs = sys_adr[0];

reg [3:0] rx_bit;
reg rx_finished;
reg rx_failed;
reg rx_F0;
reg rx_E0;
wire [7:0] reg_status = {
    rx_finished,
    rx_failed,
    rx_F0,
    rx_E0,
    
    1'b0,
    1'b0,
    1'b0,
    1'b0
};

reg [7:0] reg_data;
reg parity;

task reset();
	rx_bit <= 0;
	parity <= 1; // odd parity
endtask

always @ (posedge ps2_clk, negedge RESB)
begin
	if (~RESB)
	begin
		reset();
		rx_finished <= 0;
		rx_failed <= 0;
	end else
	begin
		if (rx_bit == 0)
        begin
			// start - always 0
			rx_failed |= ps2_data; // fail if 1
            rx_finished <= 0;
        end
		
		else if (rx_bit == 9)
			// parity
			rx_failed |= (ps2_data == parity); // fail if parity failed
		
		else if (rx_bit == 10)
		begin
			// stop - always 1
			rx_failed |= ~ps2_data; // fail if 0
			rx_finished <= 1;
            
            if (reg_data == 8'hF0)
                rx_F0 <= 1;
            else if (reg_data == 8'hE0)
                rx_E0 <= 1;
            else
                rx_finished <= 1;
		end
		
		else
		begin
			// between 1 - 8 (ps2_data bits)
			reg_data[rx_bit - 1] <= ps2_data;
			parity ^= ps2_data;
		end
		
		
		if (rx_bit == 10)
			reset();
		else
			rx_bit <= rx_bit + 1;
	end
end

reg rx_finished_latched;

always @ (posedge sys_clk, negedge RESB)
begin
    if (~RESB)
    begin
        sys_data <= 8'hZZ;
        sys_irq <= 1;
        rx_finished_latched <= 0;
    end else
    begin
        if (rx_finished & ~rx_finished_latched)
            // rising edge -> interrupt
            sys_irq <= 0;
        
        else if (sys_select & ~sys_rs)
            // system ack on status read
            sys_irq <= 1;
            
        rx_finished_latched <= rx_finished;
        
        if (sys_select)
        begin
            if (sys_rs == 0)
                sys_data <= reg_status;
            else
                sys_data <= reg_data;
        end else
        begin
            sys_data <= 8'hZZ;
        end
    end
end

assign dbg = {
    rx_finished,
    sys_irq,
    reg_data
};

endmodule
