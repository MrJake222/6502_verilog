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


add wave -position insertpoint -color gold -label master_n_reset sim:/main/master_n_reset

add wave -position insertpoint -color olive -label dbgu_clk sim:/main/b2v_dbgu0/uart0/clk
add wave -position insertpoint -color olive -label dbgu_n_reset sim:/main/b2v_dbgu0/n_reset

add wave -position insertpoint -color hotpink -label rx sim:/main/b2v_dbgu0/uart0/rx
add wave -position insertpoint -color hotpink -label rx_sample sim:/main/b2v_dbgu0/uart0/dbg_rx_sample

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



#add wave -position insertpoint -color gold -label dbg_select sim:/main/b2v_rom0/dbg_select
#add wave -position insertpoint -color gold -label dbg_OE sim:/main/b2v_rom0/dbg_OE
#add wave -position insertpoint -color gold -label dbg_WE sim:/main/b2v_rom0/dbg_WE
#add wave -position insertpoint -color gold -label dbg_q sim:/main/b2v_rom0/dbg_q
#add wave -position insertpoint -color gold -label dbg_data_out sim:/main/b2v_rom0/dbg_data_out


#add wave -position insertpoint -color gold -label cpu_clk sim:/main/b2v_dbgu0/cpu_clk
#add wave -position insertpoint -color gold -label cpu_n_reset sim:/main/b2v_dbgu0/cpu_n_reset




add wave -position insertpoint -color olive -label "clk@CPU" sim:/main/b2v_CPU0/clk
add wave -position insertpoint -color olive -label "n_reset@CPU" sim:/main/b2v_CPU0/n_reset
#add wave -position insertpoint -color olive -label state_reset sim:/main/b2v_CPU0/state_reset
add wave -position insertpoint -color olive -label state sim:/main/b2v_CPU0/state_reg/value

#add wave -position insertpoint -color olive -label IR_load sim:/main/b2v_CPU0/IR_load
add wave -position insertpoint -color olive -label "IR val" sim:/main/b2v_CPU0/IR/value

add wave -position insertpoint -color "green yellow" -label addr sim:/main/b2v_CPU0/addr_bus
add wave -position insertpoint -color "green yellow" -label data sim:/main/b2v_CPU0/data_bus
add wave -position insertpoint -color "green" -label data_bus_internal sim:/main/b2v_CPU0/intr_data_bus
add wave -position insertpoint -color "green" -label RW sim:/main/b2v_CPU0/RW

#add wave -position insertpoint -color "violet" -label "from_A" sim:/main/b2v_CPU0/from_A
add wave -position insertpoint -color "violet" -label "to_A" sim:/main/b2v_CPU0/to_A
#add wave -position insertpoint -color "violet" -label "cu_from_A" sim:/main/b2v_CPU0/cu_from_A
add wave -position insertpoint -color "violet" -label "cu_to_A" sim:/main/b2v_CPU0/cu_to_A
add wave -position insertpoint -color "violet" -label "A val" sim:/main/b2v_CPU0/A_reg/value



# ~3.6864MHz
force -freeze sim:/main/clk_uart 1 {0 ns} , 0 {135 ns} -r {270 ns}
force -freeze sim:/main/button_clk 0 {0 ns}

# simple reset
force -drive sim:/main/master_n_reset 1 {0 ns} , 0 {100 ns} , 1 {160 ns}

#                                   start        D0             D1          D2            D3            D4          D5             D6            D7            stop
# set address pointer low instr=01 alow=00
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 1 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}

# set address pointer high instr=02 ahigh=80
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 1 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 1 {78.1 us} , 1 {86.8 us} ; run {96 us}

# get addr pointer instr=03
#force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 1 {17.36 us} , 1 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
#force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
#run {200 us}

# write to memory instr=04 data=a9,55 *2
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 1 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 1 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 1 {43.4 us} , 0 {52 us} , 1 {60.76 us} , 0 {69.4 us} , 1 {78.1 us} , 1 {86.8 us} ; run {96 us}
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 1 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 1 {17.36 us} , 0 {26 us} , 1 {34.7 us} , 0 {43.4 us} , 1 {52 us} , 0 {60.76 us} , 1 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}

# set address pointer low instr=01 alow=00
#force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 1 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
#force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}

# read from memory 2-byte instr=05
#force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 1 {17.36 us} , 0 {26 us} , 1 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
#force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
#run { 200 us}

# set cpu to reset instr=21
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 1 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 1 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}

# run for x cycles instr=20 x=4=1(reset)+2(LDA)+1(writeback)
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 1 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 1 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}

run { 10 us }

# get A, S 0x10
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 1 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}
force -drive sim:/main/b2v_dbgu0/rx 0 {8.7 us} , 0 {17.36 us} , 0 {26 us} , 0 {34.7 us} , 0 {43.4 us} , 0 {52 us} , 0 {60.76 us} , 0 {69.4 us} , 0 {78.1 us} , 1 {86.8 us} ; run {96 us}

run { 200 us }
