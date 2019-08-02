open_project compress
set_top compress
add_files compress/compress.cpp
add_files -tb compress/compress_tb.cpp
open_solution "solution1"
set_part {xczu9eg-ffvb1156-2-i} -tool vivado
create_clock -period 3.333333 -name default
csynth_design
export_design -rtl verilog -format ip_catalog -description "APM Stream Compressor" -vendor "llnl.gov" -library "user" -display_name "APM Stream Compressor"
exit
