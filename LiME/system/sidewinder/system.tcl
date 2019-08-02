
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set_param board.repoPaths [list "../../board"]
set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project psu_lime ./ -part xczu19eg-ffvc1760-2-i
   set_property BOARD_PART fidus.com:sidewinder100:part0:1.0 [current_project]
}

set_property  ip_repo_paths  "../../ip/$scripts_vivado_version ../../ip/hls" [current_project]
update_ip_catalog

# CHANGE DESIGN NAME HERE
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################

# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.2 zynq_ultra_ps_e_0

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""

#create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
#apply_board_connection -board_interface "led_8bits" -ip_intf "axi_gpio_0/GPIO" -diagram "system" 
apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells zynq_ultra_ps_e_0]

# Needs to be applied after setting board presets
set_property -dict [list CONFIG.PSU__USE__M_AXI_GP0 {1} CONFIG.PSU__USE__M_AXI_GP1 {1} CONFIG.PSU__USE__S_AXI_GP2 {1} CONFIG.PSU__USE__S_AXI_GP3 {1}] [get_bd_cells zynq_ultra_ps_e_0]
set_property -dict [list CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {250}] [get_bd_cells zynq_ultra_ps_e_0]
set_property -dict [list CONFIG.PSU__FPGA_PL1_ENABLE {1} CONFIG.PSU__CRL_APB__PL1_REF_CTRL__SRCSEL {IOPLL} CONFIG.PSU__CRL_APB__PL1_REF_CTRL__FREQMHZ {300}] [get_bd_cells zynq_ultra_ps_e_0]
set_property -dict [list CONFIG.PSU__NUM_FABRIC_RESETS {2}] [get_bd_cells zynq_ultra_ps_e_0]
set_property -dict [list CONFIG.PSU__HIGH_ADDRESS__ENABLE {1}] [get_bd_cells zynq_ultra_ps_e_0]
# set_property -dict [list CONFIG.PSU__CRL_APB__PL1_REF_CTRL__DIVISOR0 {5}] [get_bd_cells zynq_ultra_ps_e_0]
# set_property -dict [list CONFIG.PSU__CRF_APB__APLL_CTRL__FBDIV {66}] [get_bd_cells zynq_ultra_ps_e_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_pl_clk0
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/zynq_ultra_ps_e_0/pl_clk0 (249 MHz)" }  [get_bd_pins rst_pl_clk0/slowest_sync_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins rst_pl_clk0/ext_reset_in]

create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_pl_clk1
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/zynq_ultra_ps_e_0/pl_clk1 (299 MHz)" }  [get_bd_pins rst_pl_clk1/slowest_sync_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn1] [get_bd_pins rst_pl_clk1/ext_reset_in]

connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/maxihpm1_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/saxihp0_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/saxihp1_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]

# Creating delays and setting their properties
set axi_delay_0 [ create_bd_cell -type ip -vlnv llnl.gov:user:axi_delay:1.2 axi_delay_0 ]
set axi_delay_1 [ create_bd_cell -type ip -vlnv llnl.gov:user:axi_delay:1.2 axi_delay_1 ]
set_property -dict [list CONFIG.C_AXI_PROTOCOL {0} CONFIG.C_MEM_ADDR_WIDTH {36} CONFIG.C_FIFO_DEPTH_B {32} CONFIG.C_FIFO_DEPTH_R {512} CONFIG.C_AXI_ID_WIDTH {6} CONFIG.C_AXI_ADDR_WIDTH {40} CONFIG.C_AXI_DATA_WIDTH {128}] [get_bd_cells axi_delay_0]
set_property -dict [list CONFIG.C_AXI_PROTOCOL {0} CONFIG.C_MEM_ADDR_WIDTH {36} CONFIG.C_FIFO_DEPTH_B {32} CONFIG.C_FIFO_DEPTH_R {512} CONFIG.C_AXI_ID_WIDTH {6} CONFIG.C_AXI_ADDR_WIDTH {40} CONFIG.C_AXI_DATA_WIDTH {128}] [get_bd_cells axi_delay_1]

# Creating shims and setting their properties
set axi_shim_0 [ create_bd_cell -type ip -vlnv llnl.gov:user:axi_shim:1.4 axi_shim_0 ]
set_property -dict [list CONFIG.C_AXI_PROTOCOL {0} CONFIG.C_MAP_WIDTH {20} CONFIG.C_MAP_IN {00010000000000000000} CONFIG.C_MAP_OUT {00001000000000000000} CONFIG.C_AXI_ID_WIDTH {16} CONFIG.C_AXI_ADDR_WIDTH {40} CONFIG.C_AXI_DATA_WIDTH {128}] [get_bd_cells axi_shim_0]
set axi_shim_1 [ create_bd_cell -type ip -vlnv llnl.gov:user:axi_shim:1.4 axi_shim_1 ]
set_property -dict [list CONFIG.C_AXI_PROTOCOL {0} CONFIG.C_MAP_WIDTH {5} CONFIG.C_MAP_IN {00010} CONFIG.C_MAP_OUT {00011} CONFIG.C_AXI_ID_WIDTH {16} CONFIG.C_AXI_ADDR_WIDTH {40} CONFIG.C_AXI_DATA_WIDTH {128}] [get_bd_cells axi_shim_1]

# connecting shims back to back
connect_bd_intf_net [get_bd_intf_pins axi_shim_0/m_axi] [get_bd_intf_pins axi_shim_1/s_axi]

# adding smartconnect IP to connect shim with delays
create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0
set_property -dict [list CONFIG.NUM_MI {2} CONFIG.NUM_SI {1}] [get_bd_cells smartconnect_0]

# connecting shim with smartconnect
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins axi_shim_1/m_axi]

# connecting smartconenct with delays  
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins axi_delay_0/s_axi]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M01_AXI] [get_bd_intf_pins axi_delay_1/s_axi]

# connecting slave port of shim with HPM0 master
connect_bd_intf_net [get_bd_intf_pins axi_shim_0/s_axi] [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_FPD]

# connecting master port of delay0 with HP0 slave
connect_bd_intf_net [get_bd_intf_pins axi_delay_0/m_axi] [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP0_FPD]

# connecting master port of delay1 with HP1 slave
connect_bd_intf_net [get_bd_intf_pins axi_delay_1/m_axi] [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP1_FPD]

# connecting control slave port of delay0 with GP1 master via main AXI interconnect
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM1_FPD" Clk "Auto" }  [get_bd_intf_pins axi_delay_0/s_axi_lite]

# connecting control slave port of delay1 with GP1 master via main AXI interconnect
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM1_FPD" Clk "Auto" }  [get_bd_intf_pins axi_delay_1/s_axi_lite]

#connecting clocks
connect_bd_net [get_bd_pins smartconnect_0/aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_delay_0/s_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_delay_0/m_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_delay_1/s_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_delay_1/m_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_shim_0/s_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_shim_0/m_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_shim_1/s_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_shim_1/m_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]

#connecting resets
connect_bd_net [get_bd_pins smartconnect_0/aresetn] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_delay_0/s_axi_aresetn] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_delay_0/m_axi_aresetn] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_delay_1/s_axi_aresetn] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_delay_1/m_axi_aresetn] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_shim_0/s_axi_aresetn] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_shim_0/m_axi_aresetn] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_shim_1/s_axi_aresetn] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_shim_1/m_axi_aresetn] [get_bd_pins rst_pl_clk1/interconnect_aresetn]

set_property location {2 767 58} [get_bd_cells axi_shim_0]
set_property location {3 1200 44} [get_bd_cells axi_shim_1]
set_property location {3.5 1511 57} [get_bd_cells smartconnect_0]
set_property location {5 1735 -47} [get_bd_cells axi_delay_0]
set_property location {5 1790 159} [get_bd_cells axi_delay_1]

create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_0

set axi_perf_mon_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:axi_perf_mon:5.0 axi_perf_mon_0 ]
set_property -dict [ list \
CONFIG.C_ENABLE_EVENT_LOG {1} \
CONFIG.C_GLOBAL_COUNT_WIDTH {64} \
CONFIG.C_NUM_MONITOR_SLOTS {2} \
CONFIG.C_NUM_OF_COUNTERS {8} \
CONFIG.C_SHOW_AXI_IDS {1} \
CONFIG.C_SHOW_AXI_LEN {1} \
 ] $axi_perf_mon_0

set axi_tcd_0 [ create_bd_cell -type ip -vlnv llnl.gov:user:axi_tcd:1.1 axi_tcd_0 ]
set_property -dict [ list \
CONFIG.C_MEM_ADDR_WIDTH {34} \
CONFIG.C_M_AXI_ADDR_WIDTH {34} \
CONFIG.C_M_AXI_DATA_WIDTH {512} \
CONFIG.C_M_AXI_ID_WIDTH {4} \
CONFIG.C_S_AXIS_TDATA_WIDTH {512} \
 ] $axi_tcd_0

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM1_FPD" intc_ip "Auto" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_tcd_0/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM1_FPD" intc_ip "Auto" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_perf_mon_0/S_AXI]

connect_bd_net [get_bd_pins axi_tcd_0/s_axis_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_tcd_0/s_axis_aresetn] [get_bd_pins rst_pl_clk1/peripheral_aresetn]

connect_bd_intf_net [get_bd_intf_pins axi_perf_mon_0/SLOT_0_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_FPD]
connect_bd_intf_net [get_bd_intf_pins axi_perf_mon_0/M_AXIS] [get_bd_intf_pins axi_tcd_0/s_axis]

connect_bd_net [get_bd_pins axi_perf_mon_0/core_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_perf_mon_0/m_axis_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_perf_mon_0/slot_0_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_perf_mon_0/slot_1_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]

connect_bd_net [get_bd_pins axi_perf_mon_0/core_aresetn] [get_bd_pins rst_pl_clk1/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_perf_mon_0/m_axis_aresetn] [get_bd_pins rst_pl_clk1/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_perf_mon_0/slot_0_axi_aresetn] [get_bd_pins rst_pl_clk1/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_perf_mon_0/slot_1_axi_aresetn] [get_bd_pins rst_pl_clk1/peripheral_aresetn]

apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {PL_DDR_CLK} Manual_Source {Auto}}  [get_bd_intf_pins ddr4_0/C0_SYS_CLK]
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "ddr4_sdram ( DDR4 SDRAM ) " }  [get_bd_intf_pins ddr4_0/C0_DDR4]
apply_bd_automation -rule xilinx.com:bd_rule:board -config {Board_Interface "reset ( FPGA Reset ) " }  [get_bd_pins ddr4_0/sys_rst]
make_bd_pins_external [get_bd_pins ddr4_0/c0_init_calib_complete]

set_property CONFIG.POLARITY ACTIVE_LOW [get_bd_ports reset]
delete_bd_objs [get_bd_nets reset_1]
create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0
set_property -dict [list CONFIG.C_SIZE {1} CONFIG.C_OPERATION {not} CONFIG.LOGO_FILE {data/sym_notgate.png}] [get_bd_cells util_vector_logic_0]
connect_bd_net [get_bd_ports reset] [get_bd_pins util_vector_logic_0/Op1]
connect_bd_net [get_bd_pins ddr4_0/sys_rst] [get_bd_pins util_vector_logic_0/Res]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/axi_tcd_0/m_axi" intc_ip "Auto" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]
delete_bd_objs [get_bd_intf_nets axi_tcd_0_m_axi] [get_bd_intf_nets axi_smc_M00_AXI] [get_bd_cells axi_smc]
connect_bd_intf_net [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI] [get_bd_intf_pins axi_tcd_0/m_axi]
set_property offset 0x00000000 [get_bd_addr_segs {axi_tcd_0/m_axi/SEG_ddr4_0_C0_DDR4_ADDRESS_BLOCK}]

assign_bd_address -offset 0x1000000000 -range  16G [get_bd_addr_segs {axi_shim_0/s_axi/mem0}]
assign_bd_address -offset 0x0000000000 -range 128G [get_bd_addr_segs {axi_shim_1/s_axi/mem0}]
assign_bd_address -offset 0x0800000000 -range   1M [get_bd_addr_segs {axi_delay_0/s_axi/mem0}]
assign_bd_address -offset 0x1800000000 -range  32G [get_bd_addr_segs {axi_delay_1/s_axi/mem0}]
assign_bd_address [get_bd_addr_segs {zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_HIGH}]
assign_bd_address [get_bd_addr_segs {zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_LOW}]
assign_bd_address [get_bd_addr_segs {zynq_ultra_ps_e_0/SAXIGP3/HP1_DDR_HIGH}]
assign_bd_address [get_bd_addr_segs {zynq_ultra_ps_e_0/SAXIGP3/HP1_DDR_LOW}]
# assign_bd_address

save_bd_design
validate_bd_design
