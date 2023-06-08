exec vmake work > Makefile
make

vlog -reportprogress 300 -work work /home/norbert/Projects/6502_v2/6502_verilog/main.v

vsim -t ns -L altera_mf_ver -L lpm_ver work.main -voptargs=+acc



add wave -position insertpoint -color "hot pink" -label clk sim:/main/b2v_CPU0/clk
#add wave -position insertpoint -color "hot pink" -label n_reset sim:/main/b2v_CPU0/n_reset
#add wave -position insertpoint -color "hot pink" -label IRQB sim:/main/b2v_CPU0/IRQB


add wave -position insertpoint -color "cyan" -label "PC val" sim:/main/b2v_CPU0/PC

add wave -position insertpoint -color "olive" -label state sim:/main/b2v_CPU0/state
#add wave -position insertpoint -color "olive" -label RAMS sim:/main/b2v_CPU0/RAMS
#add wave -position insertpoint -color "olive" -radix unsigned -label cu_adr_mode sim:/main/b2v_CPU0/cu_adr_mode
#add wave -position insertpoint -color "olive" -radix unsigned -label adr_fake sim:/main/b2v_CPU0/adr_fake
add wave -position insertpoint -color "olive" -radix unsigned -label adr_mode sim:/main/b2v_CPU0/adr_mode
#add wave -position insertpoint -color "olive" -label reset_routine sim:/main/b2v_CPU0/reset_routine

add wave -position insertpoint -color "green yellow" -label adr sim:/main/addr_bus
add wave -position insertpoint -color "green" -label RW sim:/main/RW
add wave -position insertpoint -color "green yellow" -label data sim:/main/data

add wave -position insertpoint -color "red" -label "IR val" sim:/main/b2v_CPU0/IR


#add wave -position insertpoint -color "violet" -label "cu_from_A" sim:/main/b2v_CPU0/cu_from_A
#add wave -position insertpoint -color "violet" -label "cu_to_A" sim:/main/b2v_CPU0/cu_to_A
add wave -position insertpoint -color "violet" -label "A val" sim:/main/b2v_CPU0/A

#add wave -position insertpoint -color "violet" -label "cu_from_X" sim:/main/b2v_CPU0/cu_from_X
#add wave -position insertpoint -color "violet" -label "cu_to_X" sim:/main/b2v_CPU0/cu_to_X
add wave -position insertpoint -color "violet" -label "X val" sim:/main/b2v_CPU0/X

#add wave -position insertpoint -color "violet" -label "from_Y" sim:/main/b2v_CPU0/cu_from_Y
#add wave -position insertpoint -color "violet" -label "to_Y" sim:/main/b2v_CPU0/cu_to_Y
add wave -position insertpoint -color "violet" -label "Y val" sim:/main/b2v_CPU0/Y

#add wave -position insertpoint -color "violet" -label "from_S" sim:/main/b2v_CPU0/cu_from_S
#add wave -position insertpoint -color "violet" -label "to_S" sim:/main/b2v_CPU0/cu_to_S
add wave -position insertpoint -color "violet" -label "S val" sim:/main/b2v_CPU0/S



add wave -position insertpoint -color "khaki" -label adr_low sim:/main/b2v_CPU0/adr_low


add wave -position insertpoint -color "firebrick" -label "alu A" sim:/main/b2v_CPU0/ALU/A
#add wave -position insertpoint -color "firebrick" -label "alu Aii" sim:/main/b2v_CPU0/ALU/Aii
add wave -position insertpoint -color "firebrick" -label "alu B" sim:/main/b2v_CPU0/ALU/B
#add wave -position insertpoint -color "orange" -label "alu add" sim:/main/b2v_CPU0/ALU/add
#add wave -position insertpoint -color "orange" -label "alu sub" sim:/main/b2v_CPU0/ALU/sub
#add wave -position insertpoint -color "orange" -label "alu cmp" sim:/main/b2v_CPU0/ALU/cmp
#add wave -position insertpoint -color "orange" -label "alu dec_B" sim:/main/b2v_CPU0/ALU/dec_B
#add wave -position insertpoint -color "orange" -label "alu inc_B" sim:/main/b2v_CPU0/ALU/inc_B
#add wave -position insertpoint -color "orange" -label "alu carry_in" sim:/main/b2v_CPU0/ALU/carry_in

add wave -position insertpoint -color "firebrick" -label "alu out" sim:/main/b2v_CPU0/ALU/out
add wave -position insertpoint -color "firebrick" -label "flag neg" sim:/main/b2v_CPU0/flag_neg
add wave -position insertpoint -color "firebrick" -label "flag ov" sim:/main/b2v_CPU0/flag_ov
add wave -position insertpoint -color "firebrick" -label "flag int" sim:/main/b2v_CPU0/flag_int
add wave -position insertpoint -color "firebrick" -label "flag zero" sim:/main/b2v_CPU0/flag_zero
add wave -position insertpoint -color "firebrick" -label "flag carry" sim:/main/b2v_CPU0/flag_carry



force -freeze sim:/main/cpu_clk 1 {0 ns} , 0 {25 ns} -r {50 ns}

# simple reset
force -freeze sim:/main/cpu_n_reset 1 {0 ns} , 0 {20 ns} , 1 {30 ns}

# irq
force -freeze sim:/main/cpu_irqb 1 {0 ns} , 0 {840 ns} , 1 {1325 ns}


run {900 ns}
#run {500 ns}
#run {500 ns}
