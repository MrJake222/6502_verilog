module UART (
	input wire clk,
	input wire n_reset,
	
	input wire rx,
	output reg rx_ready, // module asserts it to 1, when transfer finishes
	//input wire rx_ack,   // user sets to 1 to acknowledge data read
	output reg [7:0] rx_data,

	
	output reg tx,
	output reg tx_write // user asserts to 1, module asserts to 0
						 // upon transfer completion
	//input wire [7:0] tx_data
);

localparam CLK_FREQ = 3686400;
localparam UART_FREQ = 115200;
localparam BIT_CLK = CLK_FREQ / UART_FREQ;
localparam HALF_BIT_CLK = CLK_FREQ / UART_FREQ / 2;

// min freq CLK_FREQ / 2^CNT_WIDTH
localparam CNT_WIDTH = 8;

// ------------------------------------------------------------ //
// RX

reg [CNT_WIDTH-1:0] rx_cnt;
reg rx_enable;
reg [3:0] rx_byte;

always @ (negedge clk)
begin
	if (~n_reset)
	begin
		rx_enable <= 0;
		rx_ready <= 0;
	end
	
	else if (~rx & ~rx_enable & ~rx_ready)
	begin
		rx_cnt <= BIT_CLK + HALF_BIT_CLK;
		rx_enable <= 1;
		rx_byte <= 0;
	end
end

always @ (posedge clk)
begin
	if (rx_enable)
		rx_cnt <= rx_cnt - 1;
	
	if (rx_cnt == 0)
	begin
		rx_cnt <= BIT_CLK;
		rx_byte = rx_byte + 1;
		if (rx_byte < 9)
		begin
			rx_data = rx_data >> 1;
			if (rx)
				rx_data = rx_data | 8'h80;
		end
		else begin
			rx_ready <= 1;
			rx_enable <= 0;
		end
	end
end


// ------------------------------------------------------------ //
// chain

reg [7:0] tx_data;

always @ (negedge clk)
begin
	if (rx_ready & ~tx_write)
	begin
		rx_ready <= 0;
		tx_write <= 1;
		tx_data <= rx_data + 8'h10;
	end
end


// ------------------------------------------------------------ //
// TX

reg [CNT_WIDTH-1:0] tx_cnt;
reg tx_enable;
reg [3:0] tx_byte;

always @ (negedge clk)
begin
	if (~n_reset)
	begin
		tx_enable <= 0;
		tx_write <= 0;
	end
			
	else if (tx_write & ~tx_enable)
	begin
		tx_enable <= 1;
	
		tx_cnt <= BIT_CLK;
		tx_byte <= 0;
		tx <= 0;
	end
end

always @ (posedge clk)
begin
	if (tx_enable)
		tx_cnt <= tx_cnt - 1;
	
	if (tx_cnt == 0)
	begin
		tx_cnt <= BIT_CLK;
		tx_byte = tx_byte + 1;
		if (tx_byte < 9)
		begin
			tx <= tx_data & 8'h01;
			tx_data = tx_data >> 1;
		end
		else begin
			tx <= 1;
			tx_write <= 0;
			tx_enable <= 0;
		end
	end
end

endmodule
