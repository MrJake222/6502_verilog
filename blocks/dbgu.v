module dbgu (
    input wire clk,
    input wire n_reset,
    
    input wire rx,
    output wire tx,
    
    input wire [7:0] val_A,
    input wire [7:0] val_X,
    input wire [7:0] val_Y,
    input wire [7:0] val_S,
    
    output reg [7:0] data_bus_out,
    input reg [7:0] data_bus_in,
    output reg RW,
    output reg mem_op
);

wire uart_rx_ready;
wire [7:0] uart_rx_data;

reg uart_tx_write;
wire uart_tx_finished;
reg [7:0] uart_tx_data;

UART uart0 (
    .clk(clk),
    .n_reset(n_reset),
    .rx(rx),
    .tx(tx),
    
    .rx_ready(uart_rx_ready),
    .rx_data(uart_rx_data),
    
    .tx_write(uart_tx_write),
    .tx_finished(uart_tx_finished),
    .tx_data(uart_tx_data)
);

reg [1:0] rx_byte;
reg [7:0] rx_data [3:0];
reg instr_rx_finish;

reg [1:0] tx_byte;
reg [7:0] tx_data [3:0];
reg instr_tx_finish;
reg transmit;

reg mem_read;

reg [15:0] adr_ptr;

always @ (negedge clk)
begin
/* instruction reception */
    if (~n_reset)
    begin
        uart_tx_write <= 0;
        
        rx_byte <= 0;
        instr_rx_finish <= 0;
        
        instr_tx_finish <= 0;
        transmit <= 0;
        tx_byte <= 0;
        
        mem_op <= 0;
        mem_read <= 0;
    end

    if (uart_rx_ready)
    begin
        rx_data[rx_byte] <= uart_rx_data;
        if (rx_byte == 3)
            instr_rx_finish <= 1;
            
        rx_byte <= rx_byte + 1;
    end
    
    if (instr_rx_finish)
    begin
        instr_rx_finish <= 0;
        rx_byte <= 0;
        // end of instruction
        // start execution
        
        // instruction select
        case (rx_data[0])
            8'h01: // set address pointer
            begin
                adr_ptr <= {rx_data[2], rx_data[1]};
            end
            
            8'h02: // write to memory
            begin
                RW <= 0;
                data_bus_out <= rx_data[1];
                mem_op <= 1;
            end
            
            8'h03: // read from memory
            begin
                RW <= 1;
                mem_op <= 1;
                mem_read <= 1;
            end
            
            8'h04: // get A, X, Y, S
            begin
                tx_data[0] <= val_A;
                tx_data[1] <= val_X;
                tx_data[2] <= val_Y;
                tx_data[3] <= val_S;
                transmit <= 1;
            end
        endcase
    end


/* execution */
    if (mem_op)
    begin
        mem_op <= 0;
        adr_ptr <= adr_ptr + 1;
    end
    
    if (mem_read)
    begin
        mem_read <= 0;
        tx_data[0] <= data_bus_in;
        transmit <= 1;
    end


/* response transmission */
    if (transmit | uart_tx_finished)
    begin
        if (instr_tx_finish)
        begin
            instr_tx_finish <= 0;
            tx_byte <= 0;
        end        
        else
        begin
            transmit <= 0;
            
            uart_tx_data <= tx_data[tx_byte];
            uart_tx_write <= 1;
            
            if (tx_byte == 3)
                instr_tx_finish <= 1;
            
            tx_byte <= tx_byte + 1;
        end
    end
    
    // one clock pulse
    if (uart_tx_write)
        uart_tx_write <= 0;


    /*if (instruction_ready)
    begin
        
    end*/
end

endmodule
