############################################################
## This file was initially generated automatically by Vivado HLS.
## There are a few modifications.
## This tcl script will generate the HLS project for the DRAM Bank.
## The target devices are the Pynq and UltraZed 3EG (ES1) board.
## Run 'vivado_hls -f Bank_HLS.tcl' to generate the HLS project.
## Then, run 'vivado_hls -p Bank_HLS' to open the HLS project.
############################################################

open_project -reset Bank_HLS
set_top Bank
add_files Bank.cpp
add_files Bank.h
add_files -tb test_Bank.cpp -cflags "-Wno-unknown-pragmas"

variable TARGET [lindex $argv 2]
puts "FPGA TARGET Device is $TARGET"

if {$TARGET=="xc7z020clg400-1"} {
    # Pynq-Z1 Solution
    puts "Pynq-Z1 solution"
    open_solution -reset "Pynq_Solution"
    set_part $TARGET -tool vivado
    create_clock -period 10 -name default
} elseif {$TARGET=="xczu3eg-sfva625-1-i-es1"} {
    # UltraZed 3EG Solution
    puts "UltraZed-EG solution"
    open_solution -reset "UZ_Solution"
    set_part $TARGET -tool vivado
    create_clock -period 4 -name default
} else {
    puts "Attempting solution for $TARGET"
    open_solution -reset "t_solution"
    set_part $TARGET -tool vivado
    create_clock -period 10 -name default
}

csim_design -clean -compiler gcc
csynth_design
cosim_design -setup -O -reduce_diskspace -compiler gcc -trace_level port
export_design -rtl verilog -format ip_catalog -vendor "HPLP" -library "PiMulator"

exit
