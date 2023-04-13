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



add wave -position insertpoint -color olive -label clk sim:/main/b2v_dbgu0/uart0/clk
add wave -position insertpoint -color olive -label n_reset sim:/main/n_reset

add wave -position insertpoint -color hotpink -label rx sim:/main/b2v_dbgu0/uart0/rx

#add wave -position insertpoint -color coral -radix decimal -label rx_cnt sim:/main/b2v_dbgu0/uart0/rx_cnt
#add wave -position insertpoint -color coral -label rx_enable sim:/main/b2v_dbgu0/uart0/rx_enable
#add wave -position insertpoint -color violet -label rx_byte sim:/main/b2v_dbgu0/uart0/rx_byte
add wave -position insertpoint -color cyan -label rx_data sim:/main/b2v_dbgu0/uart0/rx_data
#add wave -position insertpoint -color cyan -radix ascii -label rx_data sim:/main/b2v_dbgu0/uart0/rx_data
add wave -position insertpoint -color cyan -label rx_ready sim:/main/b2v_dbgu0/uart0/rx_ready

#add wave -position insertpoint -color green -radix decimal -label tx_cnt sim:/main/b2v_dbgu0/uart0/tx_cnt
#add wave -position insertpoint -color green -label tx_enable sim:/main/b2v_dbgu0/uart0/tx_enable
add wave -position insertpoint -color orange -label tx_data sim:/main/b2v_dbgu0/uart0/tx_data
add wave -position insertpoint -color orange -label tx_write sim:/main/b2v_dbgu0/uart0/tx_write
add wave -position insertpoint -color orange -label tx_finished sim:/main/b2v_dbgu0/uart0/tx_finished
#add wave -position insertpoint -color violet -label tx_byte sim:/main/b2v_dbgu0/uart0/tx_byte

add wave -position insertpoint -color hotpink -label tx sim:/main/b2v_dbgu0/uart0/tx



add wave -position insertpoint -color hotpink -label rx_byte sim:/main/b2v_dbgu0/rx_byte
add wave -position insertpoint -color hotpink -label rx_data sim:/main/b2v_dbgu0/rx_data
add wave -position insertpoint -color hotpink -label instr_rx_finish sim:/main/b2v_dbgu0/instr_rx_finish

add wave -position insertpoint -color hotpink -label tx_byte sim:/main/b2v_dbgu0/tx_byte
add wave -position insertpoint -color hotpink -label tx_data sim:/main/b2v_dbgu0/tx_data
add wave -position insertpoint -color hotpink -label transmit sim:/main/b2v_dbgu0/transmit
add wave -position insertpoint -color hotpink -label instr_tx_finish sim:/main/b2v_dbgu0/instr_tx_finish

add wave -position insertpoint -color red -label adr_ptr sim:/main/b2v_dbgu0/adr_ptr
add wave -position insertpoint -color red -label data_bus_in sim:/main/b2v_dbgu0/data_bus_in
add wave -position insertpoint -color red -label data_bus_out sim:/main/b2v_dbgu0/data_bus_out
add wave -position insertpoint -color red -label RW sim:/main/b2v_dbgu0/RW
add wave -position insertpoint -color red -label mem_op sim:/main/b2v_dbgu0/mem_op



# ~3.6864MHz
force -freeze sim:/main/clk_uart 1 {0 ns} , 0 {135 ns} -r {270 ns}

# simple reset
force -drive sim:/main/n_reset 1 {0 ns} , 0 {100 ns} , 1 {160 ns}

#                                   start        D0             D1          D2            D3            D4          D5             D6            D7            stop
# set address pointer instr=01 alow=00 ahigh=80
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 1 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 1 {78.1 us} , 1 {86.8 us} ; run {96 us}
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}

# write to memory instr=02 val=ab
#force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 1 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
#force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 1 {17.36 us} , 1 {26 us} , 0 {34.7 us} , 1 {43.4 us} , 0 {52 us} , 1 {60.76 us} , 0 {69.4 us} , 1 {78.1 us} , 1 {86.8 us} ; run {96 us}
#force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
#force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}

# read from memory instr=03
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 1 {17.36 us} , 1 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}

# get A, X, Y, S 0x04
#force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 1 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us}
#force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us}
#force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us}
#force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us}

# instruction
run {400 us}

# response + padding
run {450 us}
