## PROGRAM "Quartus Prime"
## VERSION "Version 22.1"		
## DATE    "29 Mar 2023"  		
##
## DEVICE  "10M50DAF484C7G"
##
#**************************************************************
# Time Information
#**************************************************************
set_time_format -unit ns -decimal_places 3  		
#**************************************************************
# Create Clock
#************************************************************** 		
create_clock -name {clk} -period 4.000 -waveform { 0.000 2.000 } [get_ports {clk}]
create_clock -name {clkx2} -period 4.000 -waveform { 0.000 2.000 } [get_ports {clkx2}]
#**************************************************************
# Set Clock Uncertainty
#**************************************************************
set_clock_uncertainty -rise_from [get_clocks {clkx2}] -rise_to [get_clocks {clkx2}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clkx2}] -fall_to [get_clocks {clkx2}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clkx2}] -rise_to [get_clocks {clkx2}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clkx2}] -fall_to [get_clocks {clkx2}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clkx2}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clkx2}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clkx2}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clkx2}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {clk}] -rise_to [get_clocks {clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk}] -fall_to [get_clocks {clk}]  0.020  
#**************************************************************
# Set False Path
#************************************************************** 		
set_false_path -from [get_clocks {clk clkx2}] -through [get_pins -compatibility_mode *]  -to [get_clocks {clk clkx2}]