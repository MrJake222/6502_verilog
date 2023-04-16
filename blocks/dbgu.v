module dbgu (
   // system
    input wire clk,
    input wire n_reset,
	 
   // uart
    input wire rx,
    output wire tx,
    
	// cpu
    input wire [15:0] val_PC,
    input wire [7:0] val_IR,
    input wire [7:0] val_A,
    input wire [7:0] val_X,
    input wire [7:0] val_Y,
    input wire [7:0] val_S,
    output reg cpu_clk,
    output reg cpu_n_reset,
	 
   // memory
    output reg [15:0] adr_ptr,
    output wire [7:0] data_bus_out,
    input wire [7:0] data_bus_in,
    output reg RW,
    output wire mem_op,
    
    
    output wire [7:0] dbg_vect
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
    .tx_data(uart_tx_data),
    
    .dbg_vect(dbg_vect)
);

reg rx_byte;             // 0-1; no of byte received
reg [7:0] rx_data [1:0]; // 2-bytes of received instruction
reg instr_rx_finish;

reg tx_byte;             // 0-1; no of byte sent
reg [7:0] tx_data [1:0]; // 2-bytes of response
reg instr_tx_finish;
reg transmit;

reg mem_write;
reg mem_read;
reg mem_read_idx;
assign mem_op = mem_write | mem_read;

reg [7:0] data_bus_out_buf;
assign data_bus_out = RW ? 8'hZZ : data_bus_out_buf;

reg [7:0] cpu_cycles;    // for how long should cpu run

task echo_request ();
begin
	tx_data[0] <= rx_data[0];
	tx_data[1] <= rx_data[1];
	transmit <= 1;
end
endtask

always @ (negedge clk)
begin
/* reset */
    if (~n_reset)
    begin
        uart_tx_write <= 0;
        
        rx_byte <= 0;
        instr_rx_finish <= 0;
        
        instr_tx_finish <= 0;
        transmit <= 0;
        tx_byte <= 0;
        
        mem_write <= 0;
        mem_read <= 0;
        
        cpu_clk <= 0;
        cpu_cycles <= 0;
        cpu_n_reset <= 1;
    end

/* instruction reception */
    if (uart_rx_ready)
    begin
        rx_data[rx_byte] <= uart_rx_data;
        if (rx_byte == 1)
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
            8'h01: // set address pointer low
            begin
                adr_ptr[7:0] <= rx_data[1];
                echo_request();
            end
            
            8'h02: // set address pointer high
            begin
                adr_ptr[15:8] <= rx_data[1];
                echo_request();
            end
            
            8'h03: // get address pointer
            begin
                tx_data[0] <= adr_ptr[7:0];
                tx_data[1] <= adr_ptr[15:8];
                transmit <= 1;
            end
            
            8'h04: // write to memory
            begin
                RW <= 0;
                data_bus_out_buf <= rx_data[1];
                mem_write <= 1;
            end
            
            8'h05: // read from memory 2-byte
            begin
                RW <= 1;
                mem_read <= 1;
                mem_read_idx <= 0;
            end
            
            8'h10: // get A, S
            begin
                tx_data[0] <= val_A;
                tx_data[1] <= val_S;
                transmit <= 1;
            end
            
            8'h11: // get X, Y
            begin
                tx_data[0] <= val_X;
                tx_data[1] <= val_Y;
                transmit <= 1;
            end
            
            8'h12: // get IR
            begin
                tx_data[0] <= val_IR;
                // tx_data[1] <= ???;
                transmit <= 1;
            end
            
            8'h13: // get PC
            begin
                tx_data[0] <= val_PC[7:0];
                tx_data[1] <= val_PC[15:8];
                transmit <= 1;
            end
            
            8'h20: // run CPU for x cycles
            begin
                cpu_cycles <= rx_data[1];
                echo_request();
            end
            
            8'h21: // reset cpu on next cycle
            begin
                cpu_n_reset <= 0;
                echo_request();
            end
        endcase
    end


/* memory access */
    if (mem_op)
        adr_ptr <= adr_ptr + 1;

    if (mem_write)
    begin
        mem_write <= 0;
        echo_request();
    end
    
    if (mem_read)
    begin
        tx_data[mem_read_idx] <= data_bus_in;
    
        if (mem_read_idx == 1)
        begin
            // end of read
            transmit <= 1;
            mem_read <= 0;
        end
        
        mem_read_idx <= mem_read_idx + 1;
    end
    
/* cpu run control */
    if (cpu_cycles > 0)
    begin
        cpu_clk <= ~cpu_clk;
        if (cpu_clk)
        begin
            // falling edge
            cpu_cycles <= cpu_cycles - 1;
            cpu_n_reset <= 1;
        end
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
            
            if (tx_byte == 1)
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
