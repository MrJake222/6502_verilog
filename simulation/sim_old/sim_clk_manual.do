exec vmake work > Makefile
make

vlog -reportprogress 300 -work work /home/norbert/Projects/6502_v2/6502_verilog/blocks/clk_manual.v

vsim -L altera_mf_ver -L lpm_ver work.clk_manual -voptargs=+acc

add wave -position insertpoint -color "hot pink" -label clk_x2 sim:/clk_manual/clk_x2
add wave -position insertpoint -color "hot pink" -label btn sim:/clk_manual/btn
add wave -position insertpoint -color "hot pink" -label n_reset sim:/clk_manual/n_reset

add wave -position insertpoint -color "green yellow" -label clk sim:/clk_manual/clk
add wave -position insertpoint -color "green yellow" -label mem_clk sim:/clk_manual/mem_clk

add wave -position insertpoint -color "cyan" -label enable sim:/clk_manual/enable

force -freeze sim:/clk_manual/clk_x2 1 0, 100 {25 ns} -r {50 ns}

force -drive sim:/clk_manual/n_reset 0 {0 ns} , 1 {65 ns}

force -drive sim:/clk_manual/btn 1 {0 ns} , 0 {90 ns} , 1 {110 ns}

run 100
