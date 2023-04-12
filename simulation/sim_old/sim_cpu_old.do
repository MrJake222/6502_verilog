exec vmake work > Makefile
make

vlog -reportprogress 300 -work work /home/norbert/Projects/6502_v2/6502_verilog/6502_verilog.v

vsim -L altera_mf_ver -L lpm_ver work.processor_verilog -voptargs=+acc

add wave -position insertpoint -color "hot pink" -label clk sim:/processor_verilog/b2v_CPU0/clk
add wave -position insertpoint -color "hot pink" -label n_reset sim:/processor_verilog/b2v_CPU0/n_reset
add wave -position insertpoint -color "green yellow" -label addr sim:/processor_verilog/b2v_CPU0/addr_bus
add wave -position insertpoint -color "green yellow" -label data sim:/processor_verilog/b2v_CPU0/data_bus
add wave -position insertpoint -color "cyan" -label state sim:/processor_verilog/b2v_CPU0/state
# add wave -position insertpoint -color "cyan" -label r1 sim:/processor_verilog/b2v_CPU0/r1
# add wave -position insertpoint -color "cyan" -label r2 sim:/processor_verilog/b2v_CPU0/r2
# add wave -position insertpoint -color "cyan" -label r_neg sim:/processor_verilog/b2v_CPU0/r_neg
add wave -position insertpoint -color "cyan" -label PC sim:/processor_verilog/b2v_CPU0/PC
add wave -position insertpoint -color "cyan" -label IR sim:/processor_verilog/b2v_CPU0/IR
add wave -position insertpoint -color "magenta" -label A sim:/processor_verilog/b2v_CPU0/A
add wave -position insertpoint -color "cyan" -label _address sim:/processor_verilog/b2v_CPU0/_address
# add wave -position insertpoint -color "magenta" -label X sim:/processor_verilog/b2v_CPU0/X
# add wave -position insertpoint -color "magenta" -label Y sim:/processor_verilog/b2v_CPU0/Y

force -freeze sim:/processor_verilog/b2v_CPU0/clk 1 0, 0 {50 ps} -r 100

# simple reset
force -drive sim:/processor_verilog/b2v_CPU0/n_reset 1'h0 -cancel 75
force -drive sim:/processor_verilog/b2v_CPU0/n_reset 1'h1 76

# advanced reset (second reset after 825 ticks)
# force -drive sim:/processor_verilog/b2v_CPU0/n_reset 1'h0 -cancel 75
# force -drive sim:/processor_verilog/b2v_CPU0/n_reset 1'h1 76 -cancel 825
# force -drive sim:/processor_verilog/b2v_CPU0/n_reset 1'h0 826 -cancel 900
# force -drive sim:/processor_verilog/b2v_CPU0/n_reset 1'h1 901

run 100
