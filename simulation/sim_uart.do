# coral 
# cyan 
# firebrick 
# gold 
# green
# greenyellow 
# khaki 
# olive 
# orange 
# red 
# violet
# hotpink

exec vmake work > Makefile
make

vlog -reportprogress 300 -work work /home/norbert/Projects/6502_v2/6502_verilog/main.v

vsim -t ns -L altera_mf_ver -L lpm_ver work.main -voptargs=+acc



add wave -position insertpoint -color hotpink -label clk sim:/main/b2v_uart1/clk
add wave -position insertpoint -color hotpink -label rx sim:/main/b2v_uart1/rx
add wave -position insertpoint -color hotpink -label n_reset sim:/main/n_reset

add wave -position insertpoint -color coral -radix decimal -label rx_cnt sim:/main/b2v_uart1/rx_cnt
add wave -position insertpoint -color coral -label rx_enable sim:/main/b2v_uart1/rx_enable
#add wave -position insertpoint -color coral -label rx_byte sim:/main/b2v_uart1/rx_byte
add wave -position insertpoint -color cyan -label rx_data sim:/main/b2v_uart1/rx_data
add wave -position insertpoint -color cyan -radix ascii -label rx_data sim:/main/b2v_uart1/rx_data
add wave -position insertpoint -color cyan -label rx_ready sim:/main/b2v_uart1/rx_ready

add wave -position insertpoint -color firebrick -label tx_data sim:/main/b2v_uart1/tx_data
add wave -position insertpoint -color firebrick -label tx_write sim:/main/b2v_uart1/tx_write

add wave -position insertpoint -color green -radix decimal -label tx_cnt sim:/main/b2v_uart1/tx_cnt
add wave -position insertpoint -color green -label tx_enable sim:/main/b2v_uart1/tx_enable
#add wave -position insertpoint -color green -label tx_data sim:/main/b2v_uart1/tx_data
#add wave -position insertpoint -color green -label tx_write sim:/main/b2v_uart1/tx_write
add wave -position insertpoint -color khaki -label tx_byte sim:/main/b2v_uart1/tx_byte

add wave -position insertpoint -color hotpink -label tx sim:/main/b2v_uart1/tx



# ~3.6864MHz
force -freeze sim:/main/clk_uart 1 {0 ns} , 0 {135 ns} -r {270 ns}

# simple reset
force -drive sim:/main/n_reset 1 {0 ns} , 0 {100 ns} , 1 {160 ns}

# Q
force -drive sim:/main/b2v_uart1/rx 0 {8.7 us} , 1 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 1 {52 us} , 0 {60.76 us} , 1 {69.4 us} , 0 {78.1 us} , 1 {86.8 us}
run {95.486 us}

# E
force -drive sim:/main/b2v_uart1/rx 0 {8.7 us} , 1 {17.36 us} , 0 {26 us} , 1 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 1 {69.4 us} , 0 {78.1 us} , 1 {86.8 us}
run {95.486 us}


run {110 us}
