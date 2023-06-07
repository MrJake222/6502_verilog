module PS2 (
	input wire ps2_clk__,
	input wire ps2_data__,
	
    input wire clk,
    input wire n_reset,
    
    input wire [15:0] sys_adr,
    output reg [7:0] sys_data,
    output wire sys_irq,
    
    output wire [9:0] dbg
);

// double clocking
reg ps2_clk_, ps2_clk, ps2_data_, ps2_data;
always @ (posedge clk)
begin
    ps2_clk_ <= ps2_clk__;
    ps2_clk <= ps2_clk_;
    
    ps2_data_ <= ps2_data__;
    ps2_data <= ps2_data_;
end

// 0x4000 - 0x5FFF
wire sys_select = ~sys_adr[15] & sys_adr[14] & ~sys_adr[13];
wire sys_rs = sys_adr[0];

`define R_STATUS 0
`define R_DATA   1

reg ps2_clk_l;

reg rx_parity;
reg [7:0] rx_data;
reg [3:0] rx_bit;
reg rx_finished;
reg rx_failed;
reg rx_F0;
reg rx_E0;
wire [7:0] rx_status = {
    rx_finished,
    rx_failed,
    rx_F0,
    rx_E0,
    
    1'b0,
    1'b0,
    1'b0,
    1'b0
};

assign sys_irq = ~rx_finished; // active low

task rx_new();
    rx_parity <= 1; // odd parity
    rx_bit <= -1;   // all ones (flips to 0 at start bit)
endtask

task rx_ack();
    rx_finished <= 0;
    rx_failed <= 0;
    rx_F0 <= 0;
    rx_E0 <= 0;
endtask

always @ (posedge clk)
begin
    if (~n_reset)
    begin
        ps2_clk_l <= 1; // idle state
        rx_new();
        rx_ack();
    end else
    begin
        // no reset
        if (ps2_clk_l & ~ps2_clk)
        begin
            // after falling edge (clk low)
            if (rx_bit == -1)
                // start bit
                rx_failed |= ps2_data; // fail if start high
            
            else if (rx_bit == 8)
                // parity
                rx_failed |= (ps2_data != rx_parity); // fail if parity failed
            
            else if (rx_bit == 9)
                // stop bit
                rx_failed |= ~ps2_data; // fail if stop low
                
            else
            begin
                // data bits (rx_bit 0 to 7)
                rx_data[rx_bit] <= ps2_data;
                rx_parity ^= ps2_data;
            end
            
            if (rx_bit == 9)
            begin
                // stop bit
                
                // if F0/E0 don't finish
                // wait for code after the break/extended code
                if (rx_data == 8'hF0)
                    rx_F0 <= 1;
                else if (rx_data == 8'hE0)
                    rx_E0 <= 1;
                else
                    rx_finished <= 1;
                    
                rx_new();
            end
            else
                // any other bit
                rx_bit <= rx_bit + 1;
        end
        
        ps2_clk_l <= ps2_clk;
        
        if (sys_select)
        begin
            // cpu selected this device
            if (sys_rs == `R_STATUS)
                sys_data <= rx_status;
            
            if (sys_rs == `R_DATA)
            begin
                sys_data <= rx_data;
                // clear irq
                // reset module
                rx_ack();
            end
        end else
        begin
            // not selected
            // release data lines
            sys_data <= 8'hZZ;
        end
    end
end


assign dbg = {
    1'b0,
    1'b0,
    
    rx_finished,    // 1 bit 7
    rx_failed,      // 1 bit 6
    rx_F0,          // 1 bit 5
    rx_E0,          // 1 bit 4
    
    rx_bit // 4 bit 0123
    
};

endmodule
