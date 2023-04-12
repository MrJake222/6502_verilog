exec vmake work > Makefile
make

vlog -reportprogress 300 -work work /home/norbert/Projects/6502_v2/6502_verilog/main.v

vsim -t ns -L altera_mf_ver -L lpm_ver work.main -voptargs=+acc

add wave -position insertpoint -color "hot pink" -label clk sim:/main/b2v_CPU0/clk
add wave -position insertpoint -color "hot pink" -label n_reset sim:/main/b2v_CPU0/n_reset
add wave -position insertpoint -color "green yellow" -label addr sim:/main/b2v_CPU0/addr_bus
add wave -position insertpoint -color "green yellow" -label data sim:/main/b2v_CPU0/data_bus
add wave -position insertpoint -color "green" -label data_latch sim:/main/b2v_CPU0/data_latch
add wave -position insertpoint -color "green" -label RW sim:/main/b2v_CPU0/RW
add wave -position insertpoint -color "cyan" -label state sim:/main/b2v_CPU0/state

add wave -position insertpoint -color "cyan" -label PC sim:/main/b2v_CPU0/PC
add wave -position insertpoint -color "cyan" -label IR sim:/main/b2v_CPU0/IR
add wave -position insertpoint -color "red" -label ira sim:/main/b2v_CPU0/ira
add wave -position insertpoint -color "red" -label irb sim:/main/b2v_CPU0/irb
add wave -position insertpoint -color "red" -label irc sim:/main/b2v_CPU0/irc
add wave -position insertpoint -color "magenta" -label A sim:/main/b2v_CPU0/A
add wave -position insertpoint -color "cyan" -label AL sim:/main/b2v_CPU0/AL

add wave -position insertpoint -color "pink" -label maddr sim:/main/b2v_CPU0/maddr
add wave -position insertpoint -color "pink" -label mo sim:/main/b2v_CPU0/mo
add wave -position insertpoint -color "green" -label m_next_state sim:/main/b2v_CPU0/m_next_state
add wave -position insertpoint -color "green" -label m_addr_select sim:/main/b2v_CPU0/m_addr_select
add wave -position insertpoint -color "green" -label m_PC_inc sim:/main/b2v_CPU0/m_PC_inc
add wave -position insertpoint -color "green" -label m_latch_AL sim:/main/b2v_CPU0/m_latch_AL
add wave -position insertpoint -color "green" -label m_latch_A sim:/main/b2v_CPU0/m_latch_A

force -freeze sim:/main/clk 0 {0 ns} , 1 {25 ns} -r {50 ns}

# simple reset
force -drive sim:/main/n_reset 0 {0 ns} , 1 {65 ns}

run {900 ns}
