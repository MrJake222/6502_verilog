exec vmake work > Makefile
make

vlog -reportprogress 300 -work work /home/norbert/Projects/6502_v2/6502_verilog/main.v

vsim -t ns -L altera_mf_ver -L lpm_ver work.main -voptargs=+acc



add wave -position insertpoint -color "hot pink" -label clk sim:/main/b2v_CPU0/clk
add wave -position insertpoint -color "hot pink" -label n_reset sim:/main/b2v_CPU0/n_reset


add wave -position insertpoint -color "cyan" -label PC_no_inc sim:/main/b2v_CPU0/PC_no_inc
add wave -position insertpoint -color "cyan" -label PC_no_drive_bus sim:/main/b2v_CPU0/PC_no_drive_bus
add wave -position insertpoint -color "cyan" -label "PC val" sim:/main/b2v_CPU0/PC

add wave -position insertpoint -color "olive" -label state_reset sim:/main/b2v_CPU0/state_reset
add wave -position insertpoint -color "olive" -label state sim:/main/b2v_CPU0/state
add wave -position insertpoint -color "olive" -label RAMS sim:/main/b2v_CPU0/RAMS

add wave -position insertpoint -color "green yellow" -label adr sim:/main/b2v_CPU0/adr_bus
add wave -position insertpoint -color "green" -label RW sim:/main/b2v_CPU0/RW
add wave -position insertpoint -color "green yellow" -label data sim:/main/b2v_CPU0/data_bus_in
add wave -position insertpoint -color "green yellow" -label data sim:/main/b2v_CPU0/data_bus_out

add wave -position insertpoint -color "red" -label "IR val" sim:/main/b2v_CPU0/IR





#add wave -position insertpoint -color "violet" -label "from_A" sim:/main/b2v_CPU0/from_A
#add wave -position insertpoint -color "violet" -label "to_A" sim:/main/b2v_CPU0/to_A
#add wave -position insertpoint -color "violet" -label "cu_from_A" sim:/main/b2v_CPU0/cu_from_A
#add wave -position insertpoint -color "violet" -label "cu_to_A" sim:/main/b2v_CPU0/cu_to_A
add wave -position insertpoint -color "violet" -label "A val" sim:/main/b2v_CPU0/A

#add wave -position insertpoint -color "violet" -label "from_X" sim:/main/b2v_CPU0/from_X
#add wave -position insertpoint -color "violet" -label "to_X" sim:/main/b2v_CPU0/to_X
#add wave -position insertpoint -color "violet" -label "cu_from_X" sim:/main/b2v_CPU0/cu_from_X
#add wave -position insertpoint -color "violet" -label "cu_to_X" sim:/main/b2v_CPU0/cu_to_X
add wave -position insertpoint -color "violet" -label "X val" sim:/main/b2v_CPU0/X

#add wave -position insertpoint -color "violet" -label "from_Y" sim:/main/b2v_CPU0/from_Y
#add wave -position insertpoint -color "violet" -label "to_Y" sim:/main/b2v_CPU0/to_Y
add wave -position insertpoint -color "violet" -label "Y val" sim:/main/b2v_CPU0/Y

#add wave -position insertpoint -color "violet" -label "from_S" sim:/main/b2v_CPU0/from_S
#add wave -position insertpoint -color "violet" -label "to_S" sim:/main/b2v_CPU0/to_S
add wave -position insertpoint -color "violet" -label "S val" sim:/main/b2v_CPU0/S

#add wave -position insertpoint -color "orange" -label "cu_from_mem" sim:/main/b2v_CPU0/cu_from_mem
#add wave -position insertpoint -color "orange" -label "from_mem" sim:/main/b2v_CPU0/from_mem
#add wave -position insertpoint -color "coral" -label "cu_to_mem" sim:/main/b2v_CPU0/cu_to_mem
#add wave -position insertpoint -color "coral" -label "to_mem" sim:/main/b2v_CPU0/to_mem



add wave -position insertpoint -color "khaki" -label adr_low sim:/main/b2v_CPU0/adr_low
#add wave -position insertpoint -color "khaki" -label "adr_high_latch" sim:/main/b2v_CPU0/adr_high_latch


#add wave -position insertpoint -color "firebrick" -label "alu A" sim:/main/b2v_CPU0/ALU/A
#add wave -position insertpoint -color "firebrick" -label "alu B" sim:/main/b2v_CPU0/ALU/B
#add wave -position insertpoint -color "firebrick" -label "alu B intr" sim:/main/b2v_CPU0/ALU/Bi
#add wave -position insertpoint -color "firebrick" -label "alu A inc" sim:/main/b2v_CPU0/ALU/inc_A
#add wave -position insertpoint -color "firebrick" -label "alu add" sim:/main/b2v_CPU0/ALU/add
#add wave -position insertpoint -color "firebrick" -label "alu sub" sim:/main/b2v_CPU0/ALU/sub

#add wave -position insertpoint -color "firebrick" -label "alu out" sim:/main/b2v_CPU0/ALU/out
#add wave -position insertpoint -color "firebrick" -label "alu out latch" sim:/main/b2v_CPU0/alu_out_latch
#add wave -position insertpoint -color "firebrick" -label "alu out reg" sim:/main/b2v_CPU0/ALU_out_reg/value


force -freeze sim:/main/cpu_clk 1 {0 ns} , 0 {25 ns} -r {50 ns}

# simple reset
force -freeze sim:/main/cpu_n_reset 1 {0 ns} , 0 {20 ns} , 1 {30 ns}

run {900 ns}
#run {700 ns}
