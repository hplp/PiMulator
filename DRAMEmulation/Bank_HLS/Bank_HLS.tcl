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
add_files Bank.h
add_files Bank.cpp
add_files -tb test_Bank.cpp -cflags "-Wno-unknown-pragmas"

variable TARGET [lindex $argv 2]
puts "FPGA TARGET Device is $TARGET"

if {$TARGET=="xc7z020clg400-1"} {
    # Pynq Solution
    puts "Pynq solution"
    open_solution -reset "Pynq_Solution"
    set_part {xc7z020clg400-1} -tool vivado
    create_clock -period 10 -name default
    csim_design -clean -compiler clang
} elseif {$TARGET=="xczu3eg-sfva625-1-i-es1"} {
    # UltraZed 3EG Solution
    puts "UltraZed solution"
    open_solution -reset "UZ_Solution"
    set_part {xczu3eg-sfva625-1-i-es1} -tool vivado
    create_clock -period 4 -name default
    csim_design -clean -compiler clang
}

csynth_design
#cosim_design
export_design -rtl verilog -format ip_catalog -vendor "HPLP" -library "PiMulator"

exit
