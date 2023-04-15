module UART (
    input wire clk,
    input wire n_reset,
    
    input wire rx,
    output reg rx_ready, // module sets it to 1 when transfer finishes
                         // for one clock period
    output reg [7:0] rx_data,
    
    output reg tx,
    input wire tx_write,    // user sets to 1 to start a transfer
                            // one pulse is sufficient
    output reg tx_finished, // module sets to 1 when transfer finished
                            // for one clock pulse
    input wire [7:0] tx_data,
    
    
    
    output reg dbg_rx_sample
);

localparam CLK_FREQ = 3686400;
localparam UART_FREQ = 115200;
//localparam CLK_FREQ = 11000000;
//localparam UART_FREQ = 57600;
localparam BIT_CLK = (CLK_FREQ - 1) / UART_FREQ + 1;
localparam ONE_AND_HALF_BIT_CLK = BIT_CLK + (BIT_CLK / 2);

initial begin
$display(BIT_CLK);
$display(ONE_AND_HALF_BIT_CLK);
end

// min freq CLK_FREQ / 2^CNT_WIDTH
// must fit ONE_AND_HALF_BIT_CLK
localparam CNT_WIDTH = 9;

// ------------------------------------------------------------ //
// RX

reg [CNT_WIDTH-1:0] rx_cnt;
reg rx_enable;
reg [3:0] rx_bit;

always @ (negedge clk)
begin
    if (~n_reset) begin
        rx_enable <= 0;
        rx_ready <= 0;
    end
    // no reset, falling edge (start bit), rx not in progress (~enable)
    // start the transfer
    else if (~rx & ~rx_enable)
    begin
        rx_cnt <= ONE_AND_HALF_BIT_CLK;
        rx_enable <= 1;
        rx_bit <= 0;
    end
    
    if (rx_enable)
        rx_cnt <= rx_cnt - 1;
    
    if (rx_cnt == 0)
    begin
        rx_cnt <= BIT_CLK;
        rx_bit <= rx_bit + 1;
        if (rx_bit == 8)
        begin
            // receive stop bit
            // end of transmission
            rx_ready <= 1;
            rx_enable <= 0;
        end
        else begin
            // less than 8 -> receive data
            rx_data[rx_bit] <= rx;
            dbg_rx_sample <= 1;
        end
    end
    
    // rx_ready one clock wide pulse
    if (rx_ready)
        rx_ready <= 0;
    
    if (dbg_rx_sample)
        dbg_rx_sample <= 0;
end


// ------------------------------------------------------------ //
// chain

//reg [7:0] tx_data;

/*always @ (negedge clk)
begin
    if (rx_ready & ~tx_write)
    begin
        rx_ready <= 0;
        tx_write <= 1;
        tx_data <= rx_data + 8'h10;
    end
end*/


// ------------------------------------------------------------ //
// TX

reg [CNT_WIDTH-1:0] tx_cnt;
reg tx_enable;
reg [3:0] tx_bit;

always @ (negedge clk)
begin
    if (~n_reset)
    begin
        tx <= 1; // idle
        tx_enable <= 0;
        tx_finished <= 0;
    end
    // no reset, not in progress
    // tx start write
    else if (tx_write & ~tx_enable)
    begin
        tx_enable <= 1;
    
        tx_cnt <= BIT_CLK;
        tx_bit <= 0;
        tx <= 0;
    end
    
    if (tx_enable)
        tx_cnt <= tx_cnt - 1;
    
    if (tx_cnt == 0)
    begin
        tx_cnt <= BIT_CLK;
        tx_bit <= tx_bit + 1;
        if (tx_bit == 8)
            // send stop bit
            tx <= 1;
        else if (tx_bit == 9)
        begin
            // end of transmission
            tx_finished <= 1;
            tx_enable <= 0;
        end
        else begin
            // less than 8 -> transmit data
            tx <= tx_data[tx_bit];
        end
    end
    
    // one clock wide finished pulse
    if (tx_finished)
        tx_finished <= 0;
end

endmodule
