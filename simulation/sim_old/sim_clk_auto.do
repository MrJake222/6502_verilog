exec vmake work > Makefile
make

vlog -reportprogress 300 -work work /home/norbert/Projects/6502_v2/6502_verilog/blocks/clk_auto.v

vsim -L altera_mf_ver -L lpm_ver work.clk_auto -voptargs=+acc

add wave -position insertpoint -color "hot pink" -label clk_x2 sim:/clk_auto/clk_x2
add wave -position insertpoint -color "hot pink" -label n_reset_in sim:/clk_auto/n_reset_in

add wave -position insertpoint -color "green yellow" -label clk sim:/clk_auto/clk
add wave -position insertpoint -color "green yellow" -label mem_clk sim:/clk_auto/mem_clk
add wave -position insertpoint -color "green yellow" -label n_reset_out sim:/clk_auto/n_reset_out

force -freeze sim:/clk_auto/clk_x2 1 0, 100 {25 ns} -r {50 ns}

force -drive sim:/clk_auto/n_reset_in 0 {0 ns} , 1 {65 ns}

run 100
