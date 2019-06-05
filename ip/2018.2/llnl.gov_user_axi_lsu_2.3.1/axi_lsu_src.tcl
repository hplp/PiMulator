# From open project, type:
# source [get_property DIRECTORY [current_project]]/axi_lsu_src.tcl

set repo_base C:/Xilinx/Vivado/2018.2/data/ip/xilinx
set proj_base [get_property DIRECTORY [current_project]]
# Option: [add_files -norecurse ...]
# To determine the files in a library, look in component.xml
# see xilinx_anylanguagebehavioralsimulation_view_fileset
# see xilinx_vhdlsynthesis_view_fileset
# Ignore library specification warnings for Verilog files
# VHDL source files need the library specification for mixed-lang. simulation

set_property target_language VHDL [current_project]

# blk_mem_gen
set blk_mem_gen blk_mem_gen_v8_4
set bmg_rev _1
set_property -dict [ list LIBRARY $blk_mem_gen$bmg_rev USED_IN {synthesis} ] [add_files -fileset sources_1 $repo_base/$blk_mem_gen/hdl]
set_property -dict [ list LIBRARY $blk_mem_gen$bmg_rev USED_IN {simulation} ] [add_files -fileset sim_1 $repo_base/$blk_mem_gen/simulation/$blk_mem_gen.v]

# fifo_generator
set fifo_generator fifo_generator_v13_2
set fg_rev _2
set_property -dict [ list LIBRARY $fifo_generator$fg_rev USED_IN {synthesis} ] [add_files $repo_base/$fifo_generator/hdl/${fifo_generator}_vhsyn_rfs.vhd]
set_property -dict [ list LIBRARY $fifo_generator$fg_rev USED_IN {simulation} ] [add_files -fileset sim_1 $repo_base/$fifo_generator/hdl/${fifo_generator}_rfs.vhd]
set_property -dict [ list LIBRARY $fifo_generator$fg_rev USED_IN {simulation} ] [add_files -fileset sim_1 $repo_base/$fifo_generator/simulation/fifo_generator_vlog_beh.v]
set_property -dict [ list LIBRARY $fifo_generator$fg_rev USED_IN {simulation} ] [add_files -fileset sim_1 $repo_base/$fifo_generator/hdl/${fifo_generator}_rfs.v]

# lib_cdc
set lib_cdc lib_cdc_v1_0
set lc_rev _2
set_property -dict [ list LIBRARY $lib_cdc$lc_rev USED_IN {synthesis simulation} ] [add_files $repo_base/$lib_cdc/hdl]

# lib_fifo
set lib_fifo lib_fifo_v1_0
set lf_rev _11
set_property -dict [ list LIBRARY $lib_fifo$lf_rev USED_IN {synthesis simulation} ] [add_files $repo_base/$lib_fifo/hdl]

# lib_pkg_v1_0
set lib_pkg lib_pkg_v1_0
set lp_rev _2
set_property -dict [ list LIBRARY $lib_pkg$lp_rev USED_IN {synthesis simulation} ] [add_files $repo_base/$lib_pkg/hdl]

# lib_srl_fifo_v1_0
set lib_srl lib_srl_fifo_v1_0
set ls_rev _2
set_property -dict [ list LIBRARY $lib_srl$ls_rev USED_IN {synthesis simulation} ] [add_files $repo_base/$lib_srl/hdl]

# axi_datamover
set axi_datamover axi_datamover_v5_1
set dm_rev _19
set_property -dict [ list LIBRARY $axi_datamover$dm_rev USED_IN {synthesis simulation} ] [add_files $repo_base/$axi_datamover/hdl]

# axi_lsu
set axi_lsu axi_lsu_lib
set_property -dict [ list LIBRARY $axi_lsu USED_IN {synthesis simulation} ] [add_files $proj_base/hdl/vhdl/axis_port.vhd $proj_base/hdl/vhdl/axi_lsu_cmd.vhd $proj_base/hdl/vhdl/axi_lsu_ctl.vhd $proj_base/hdl/vhdl/axi_lsu.vhd]
set_property top axi_lsu [current_fileset]

# axi_bram_ctrl
set axi_bram_ctrl axi_bram_ctrl_v4_0
set_property -dict [ list LIBRARY $axi_bram_ctrl USED_IN {simulation} ] [add_files -fileset sim_1 $repo_base/$axi_bram_ctrl/hdl]

# test bench
set_property -dict [ list LIBRARY work USED_IN {simulation} ] [add_files -fileset sim_1 $proj_base/hdl/example/axi_write.vhd $proj_base/hdl/example/axi_lsu_tb.vhd]
set_property top axi_lsu_tb [get_filesets sim_1]
