############################################################
## This file is generated automatically by Vivado HLS.
## There are a few modifications.
## This tcl script will generate the HLS project for the DRAM Bank
## The target devices are the Pynq and UltraZed 3EG board
## Run 'vivado_hls -f Bank_HLS.tcl' to generate the HLS project
## Then, run 'vivado_hls -p Bank_HLS' to open the HLS project
############################################################
open_project -reset Bank_HLS
set_top Bank
add_files Bank.cpp
add_files -tb test_Bank.cpp -cflags "-Wno-unknown-pragmas"

# Pynq Solution
open_solution -reset "Pynq_Solution"
set_part {xc7z020clg400-1} -tool vivado
create_clock -period 10 -name default

# UltraZed 3EG Solution
open_solution -reset "UZ_Solution"
set_part {xczu3eg-sfva625-1-i-es1} -tool vivado
create_clock -period 4 -name default

#config_compile -no_signed_zeros=0 -unsafe_math_optimizations=0
#config_export -format ip_catalog -rtl vhdl -vivado_phys_opt place -vivado_report_level 0
#config_schedule -effort medium -enable_dsp_full_reg=0 -relax_ii_for_timing=0 -verbose=0
#config_bind -effort medium
#config_sdx -optimization_level none -target none
#set_clock_uncertainty 12.5%

#csim_design -clean
#csynth_design
#cosim_design -trace_level all -rtl vhdl -tool xsim
#export_design -rtl vhdl -format ip_catalog

exit
