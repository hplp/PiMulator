############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 1986-2018 Xilinx, Inc. All Rights Reserved.
############################################################
open_project -reset Bank_HLS
set_top Bank
add_files Bank.cpp
add_files -tb test_Bank.cpp -cflags "-Wno-unknown-pragmas"

#Solution
open_solution -reset "Pynq_Solution"
set_part {xc7z020clg400-1} -tool vivado
create_clock -period 10 -name default
config_compile -no_signed_zeros=0 -unsafe_math_optimizations=0
config_export -format ip_catalog -rtl vhdl -vivado_phys_opt place -vivado_report_level 0
config_schedule -effort medium -enable_dsp_full_reg=0 -relax_ii_for_timing=0 -verbose=0
config_bind -effort medium
config_sdx -optimization_level none -target none
set_clock_uncertainty 12.5%
#source "directives.tcl"
csim_design -clean
csynth_design
#cosim_design -trace_level all -rtl vhdl -tool xsim
export_design -rtl vhdl -format ip_catalog

exit
