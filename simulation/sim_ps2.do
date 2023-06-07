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


add wave -position insertpoint -color gold -label clk sim:/main/b2v_ps2/clk
add wave -position insertpoint -color gold -label n_reset sim:/main/b2v_ps2/n_reset

add wave -position insertpoint -color olive -label ps2_clk sim:/main/b2v_ps2/ps2_clk
add wave -position insertpoint -color olive -label ps2_data sim:/main/b2v_ps2/ps2_data

add wave -position insertpoint -color red -label rx_parity sim:/main/b2v_ps2/rx_parity
add wave -position insertpoint -color red -label rx_data sim:/main/b2v_ps2/rx_data
add wave -position insertpoint -color red -label rx_bit sim:/main/b2v_ps2/rx_bit
add wave -position insertpoint -color orange -label rx_finished sim:/main/b2v_ps2/rx_finished
add wave -position insertpoint -color orange -label rx_failed sim:/main/b2v_ps2/rx_failed
add wave -position insertpoint -color orange -label rx_F0 sim:/main/b2v_ps2/rx_F0
add wave -position insertpoint -color orange -label rx_E0 sim:/main/b2v_ps2/rx_E0

add wave -position insertpoint -color "hot pink" -label cpu_clk sim:/main/b2v_CPU0/clk
add wave -position insertpoint -color "hot pink" -label cpu_adr sim:/main/b2v_CPU0/adr_bus
add wave -position insertpoint -color "hot pink" -label cpu_X sim:/main/b2v_CPU0/X



# ~3.6864MHz
force -freeze sim:/main/clk_uart 0 {0 ns} , 1 {135.71 ns} -r {271.43 ns}
force -freeze sim:/main/button_clk 0 {0 ns}

# simple reset
force -drive sim:/main/master_n_reset 1 {0 ns} , 0 {100 ns} , 1 {300 ns}

# cpu clk
force -freeze sim:/main/b2v_dbgu0/cpu_free_run 1 {300 ns}


force -freeze sim:/main/b2v_ps2/ps2_clk  1 {0 us} -cancel { 1 us }
force -freeze sim:/main/b2v_ps2/ps2_data 1 {0 us} -cancel { 1 us }

run { 1 us }

# send E0
#force -freeze sim:/main/b2v_ps2/ps2_clk  1 {0 us} , 0 {30 us} -r { 60 us } -cancel { 660 us }
#force -freeze sim:/main/b2v_ps2/ps2_clk  1 {660001 ns} -cancel { 700 us }
#force -freeze sim:/main/b2v_ps2/ps2_data 0 {0 us} , 0 {60 us} , 0 {120 us} , 0 {180 us} , 0 {240 us} , 0 {300 us} , 1 {360 us} , 1 {420 us} , 1 {480 us} , 0 {540 us} , 1 {600 us}
#run { 700 us }

# send key 1C (key A)
force -freeze sim:/main/b2v_ps2/ps2_clk  1 {0 us} , 0 {30 us} -r { 60 us } -cancel { 660 us }
force -freeze sim:/main/b2v_ps2/ps2_clk  1 {660001 ns} -cancel { 700 us }
force -freeze sim:/main/b2v_ps2/ps2_data 0 {0 us} , 0 {60 us} , 0 {120 us} , 1 {180 us} , 1 {240 us} , 1 {300 us} , 0 {360 us} , 0 {420 us} , 0 {480 us} , 0 {540 us} , 1 {600 us}
run { 700 us }


# send F0
force -freeze sim:/main/b2v_ps2/ps2_clk  1 {0 us} , 0 {30 us} -r { 60 us } -cancel { 660 us }
force -freeze sim:/main/b2v_ps2/ps2_clk  1 {660001 ns} -cancel { 700 us }
force -freeze sim:/main/b2v_ps2/ps2_data 0 {0 us} , 0 {60 us} , 0 {120 us} , 0 {180 us} , 0 {240 us} , 1 {300 us} , 1 {360 us} , 1 {420 us} , 1 {480 us} , 1 {540 us} , 1 {600 us}
run { 700 us }

# send key 1C (key A)
force -freeze sim:/main/b2v_ps2/ps2_clk  1 {0 us} , 0 {30 us} -r { 60 us } -cancel { 660 us }
force -freeze sim:/main/b2v_ps2/ps2_clk  1 {660001 ns} -cancel { 700 us }
force -freeze sim:/main/b2v_ps2/ps2_data 0 {0 us} , 0 {60 us} , 0 {120 us} , 1 {180 us} , 1 {240 us} , 1 {300 us} , 0 {360 us} , 0 {420 us} , 0 {480 us} , 0 {540 us} , 1 {600 us}
run { 700 us }
