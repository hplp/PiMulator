open_project eth_fifo_interface
set_top eth_fifo_interface
add_files eth_fifo_interface/eth_fifo_interface.cpp
add_files -tb eth_fifo_interface/eth_fifo_interface.cpp
open_solution "solution1"
set_part {xczu9eg-ffvb1156-2-i} -tool vivado
create_clock -period 3.333333 -name default
csynth_design
export_design -rtl verilog -format ip_catalog -description "AXIS to Ethernet FIFO" -vendor "llnl.gov" -library "user" -display_name "AXIS to Ethernet FIFO"
exit
