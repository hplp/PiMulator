# Not used, left over
# Hierarchical cell: microblaze_0_local_memory
proc create_hier_cell_microblaze_0_local_memory { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_microblaze_0_local_memory() - Empty argument(s)!"}
     return
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

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB

  # Create pins
  create_bd_pin -dir I -type clk LMB_Clk
  create_bd_pin -dir I -from 0 -to 0 LMB_RST

  # Create instance: dlmb_bram_if_cntlr, and set properties
  set dlmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 dlmb_bram_if_cntlr ]
  set_property -dict [ list \
CONFIG.C_ECC {0} \
 ] $dlmb_bram_if_cntlr

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 dlmb_v10 ]

  # Create instance: ilmb_bram_if_cntlr, and set properties
  set ilmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 ilmb_bram_if_cntlr ]
  set_property -dict [ list \
CONFIG.C_ECC {0} \
 ] $ilmb_bram_if_cntlr

  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 ilmb_v10 ]

  # Create instance: lmb_bram, and set properties
  set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 lmb_bram ]
  set_property -dict [ list \
CONFIG.Memory_Type {True_Dual_Port_RAM} \
CONFIG.use_bram_block {BRAM_Controller} \
 ] $lmb_bram

  # Create interface connections
  connect_bd_intf_net -intf_net microblaze_0_dlmb [get_bd_intf_pins DLMB] [get_bd_intf_pins dlmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_bus [get_bd_intf_pins dlmb_bram_if_cntlr/SLMB] [get_bd_intf_pins dlmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_cntlr [get_bd_intf_pins dlmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net microblaze_0_ilmb [get_bd_intf_pins ILMB] [get_bd_intf_pins ilmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_bus [get_bd_intf_pins ilmb_bram_if_cntlr/SLMB] [get_bd_intf_pins ilmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_cntlr [get_bd_intf_pins ilmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net microblaze_0_Clk [get_bd_pins LMB_Clk] [get_bd_pins dlmb_bram_if_cntlr/LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins ilmb_bram_if_cntlr/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk]
  connect_bd_net -net microblaze_0_LMB_Rst [get_bd_pins LMB_RST] [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Not used, left over
# Hierarchical cell: mcu_0
proc create_hier_cell_mcu_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_mcu_0() - Empty argument(s)!"}
     return
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

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:mbdebug_rtl:3.0 DEBUG
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M0_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M0_AXIS
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S0_AXIS

  # Create pins
  create_bd_pin -dir I aclk
  create_bd_pin -dir I -from 0 -to 0 d1_aresetn
  create_bd_pin -dir I -from 0 -to 0 d1_reset
  create_bd_pin -dir I -from 0 -to 0 d2_aresetn
  create_bd_pin -dir I -from 0 -to 0 d2_reset
  create_bd_pin -dir I d3_reset

  # Create instance: axis_hdr_0, and set properties
  set axis_hdr_0 [ create_bd_cell -type ip -vlnv llnl.gov:user:axis_hdr:1.2 axis_hdr_0 ]

  # Create instance: microblaze_0, and set properties
  set microblaze_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:10.0 microblaze_0 ]
  set_property -dict [ list \
CONFIG.C_BASE_VECTORS {0xD0000000} \
CONFIG.C_CACHE_BYTE_SIZE {8192} \
CONFIG.C_DCACHE_ALWAYS_USED {1} \
CONFIG.C_DCACHE_BASEADDR {0x00000000} \
CONFIG.C_DCACHE_BYTE_SIZE {16384} \
CONFIG.C_DCACHE_HIGHADDR {0x7FFFFFFF} \
CONFIG.C_DCACHE_USE_WRITEBACK {1} \
CONFIG.C_DCACHE_VICTIMS {4} \
CONFIG.C_DEBUG_ENABLED {1} \
CONFIG.C_D_AXI {0} \
CONFIG.C_D_LMB {1} \
CONFIG.C_FAULT_TOLERANT {0} \
CONFIG.C_FSL_LINKS {1} \
CONFIG.C_ICACHE_ALWAYS_USED {0} \
CONFIG.C_ICACHE_STREAMS {0} \
CONFIG.C_I_LMB {1} \
CONFIG.C_USE_BARREL {1} \
CONFIG.C_USE_DCACHE {1} \
CONFIG.C_USE_DIV {1} \
CONFIG.C_USE_HW_MUL {1} \
CONFIG.C_USE_ICACHE {0} \
CONFIG.C_USE_INTERRUPT {0} \
CONFIG.C_USE_REORDER_INSTR {0} \
 ] $microblaze_0
# CONFIG.C_ICACHE_BASEADDR {0x00000000} \
# CONFIG.C_ICACHE_HIGHADDR {0x7FFFFFFF} \

  # Create instance: microblaze_0_local_memory
  create_hier_cell_microblaze_0_local_memory $hier_obj microblaze_0_local_memory

  # Create interface connections
  connect_bd_intf_net -intf_net S0_AXIS_1 [get_bd_intf_pins S0_AXIS] [get_bd_intf_pins axis_hdr_0/s_axis_sig]
  connect_bd_intf_net -intf_net axis_hdr_0_m_axis_hdr [get_bd_intf_pins axis_hdr_0/m_axis_hdr] [get_bd_intf_pins microblaze_0/S0_AXIS]
  connect_bd_intf_net -intf_net axis_hdr_0_m_axis_sig [get_bd_intf_pins M0_AXIS] [get_bd_intf_pins axis_hdr_0/m_axis_sig]
  connect_bd_intf_net -intf_net microblaze_0_M0_AXIS [get_bd_intf_pins axis_hdr_0/s_axis_hdr] [get_bd_intf_pins microblaze_0/M0_AXIS]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_DC [get_bd_intf_pins M0_AXI] [get_bd_intf_pins microblaze_0/M_AXI_DC]
  connect_bd_intf_net -intf_net microblaze_0_debug [get_bd_intf_pins DEBUG] [get_bd_intf_pins microblaze_0/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_1 [get_bd_intf_pins microblaze_0/DLMB] [get_bd_intf_pins microblaze_0_local_memory/DLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_1 [get_bd_intf_pins microblaze_0/ILMB] [get_bd_intf_pins microblaze_0_local_memory/ILMB]

  # Create port connections
  connect_bd_net -net d1_aresetn_1 [get_bd_pins d1_aresetn] [get_bd_pins axis_hdr_0/h2s_aresetn] [get_bd_pins axis_hdr_0/s2h_aresetn]
  connect_bd_net -net d1_reset_1 [get_bd_pins d1_reset] [get_bd_pins microblaze_0_local_memory/LMB_RST]
  connect_bd_net -net d3_reset_1 [get_bd_pins d3_reset] [get_bd_pins microblaze_0/Reset]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins aclk] [get_bd_pins axis_hdr_0/h2s_aclk] [get_bd_pins axis_hdr_0/s2h_aclk] [get_bd_pins microblaze_0/Clk] [get_bd_pins microblaze_0_local_memory/LMB_Clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: host_0
proc create_hier_cell_host_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_host_0() - Empty argument(s)!"}
     return
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

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS

  # Create pins
  create_bd_pin -dir I aclk
  create_bd_pin -dir I -from 0 -to 0 d1_aresetn
  create_bd_pin -dir I -from 0 -to 0 d2_aresetn

  # Create instance: axi_fifo_mm_s_0, and set properties
  set axi_fifo_mm_s_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_fifo_mm_s:4.1 axi_fifo_mm_s_0 ]
  set_property -dict [ list \
CONFIG.C_AXI4_BASEADDR {0x80001000} \
CONFIG.C_AXI4_HIGHADDR {0x80002FFF} \
CONFIG.C_USE_RX_CUT_THROUGH {true} \
CONFIG.C_USE_TX_CTRL {0} \
CONFIG.C_USE_TX_CUT_THROUGH {1} \
 ] $axi_fifo_mm_s_0

  # Need to retain value_src of defaults
  set_property -dict [ list \
CONFIG.C_AXI4_BASEADDR.VALUE_SRC {DEFAULT} \
CONFIG.C_AXI4_HIGHADDR.VALUE_SRC {DEFAULT} \
 ] $axi_fifo_mm_s_0

  # Create instance: axis_hdr_0, and set properties
  set axis_hdr_0 [ create_bd_cell -type ip -vlnv llnl.gov:user:axis_hdr:1.2 axis_hdr_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXIS_1 [get_bd_intf_pins S_AXIS] [get_bd_intf_pins axis_hdr_0/s_axis_sig]
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_fifo_mm_s_0/S_AXI]
  connect_bd_intf_net -intf_net axi_fifo_mm_s_0_AXI_STR_TXD [get_bd_intf_pins axi_fifo_mm_s_0/AXI_STR_TXD] [get_bd_intf_pins axis_hdr_0/s_axis_hdr]
  connect_bd_intf_net -intf_net axis_hdr_0_m_axis_hdr [get_bd_intf_pins axi_fifo_mm_s_0/AXI_STR_RXD] [get_bd_intf_pins axis_hdr_0/m_axis_hdr]
  connect_bd_intf_net -intf_net axis_hdr_0_m_axis_sig [get_bd_intf_pins M_AXIS] [get_bd_intf_pins axis_hdr_0/m_axis_sig]

  # Create port connections
  connect_bd_net -net S_ACLK_1 [get_bd_pins aclk] [get_bd_pins axi_fifo_mm_s_0/s_axi_aclk] [get_bd_pins axis_hdr_0/h2s_aclk] [get_bd_pins axis_hdr_0/s2h_aclk]
  connect_bd_net -net S_ARESETN_1 [get_bd_pins d1_aresetn] [get_bd_pins axis_hdr_0/h2s_aresetn] [get_bd_pins axis_hdr_0/s2h_aresetn]
  connect_bd_net -net d2_aresetn_1 [get_bd_pins d2_aresetn] [get_bd_pins axi_fifo_mm_s_0/s_axi_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: engine_0
proc create_hier_cell_engine_0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_engine_0() - Empty argument(s)!"}
     return
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

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  #create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  # Create pins
  #create_bd_pin -dir I M_ACLK
  #create_bd_pin -dir I -from 0 -to 0 M_D1_ARESETN
  #create_bd_pin -dir I -from 0 -to 0 M_D2_ARESETN
  #create_bd_pin -dir I S_ACLK
  #create_bd_pin -dir I -from 0 -to 0 S_D1_ARESETN
  #create_bd_pin -dir I -from 0 -to 0 S_D1_RESET
  #create_bd_pin -dir I -from 0 -to 0 S_D2_ARESETN
  #create_bd_pin -dir I -from 0 -to 0 S_D2_RESET
  #create_bd_pin -dir I S_D3_RESET

#  # Create instance: axi_data_0, and set properties
#  set axi_data_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_data_0 ]
#  set_property -dict [ list \
#CONFIG.ENABLE_ADVANCED_OPTIONS {1} \
#CONFIG.NUM_MI {1} \
#CONFIG.NUM_SI {3} \
#CONFIG.XBAR_DATA_WIDTH {64} \
# ] $axi_data_0

#  # Create instance: axi_lsu_0, and set properties
#  set axi_lsu_0 [ create_bd_cell -type ip -vlnv llnl.gov:user:axi_lsu:2.1 axi_lsu_0 ]
#  set_property -dict [ list \
#CONFIG.C_R_ADDR_PIPE_DEPTH {16} \
#CONFIG.C_R_INCLUDE_SF {0} \
#CONFIG.C_W_ADDR_PIPE_DEPTH {16} \
# ] $axi_lsu_0

#  # Create instance: axi_lsu_1, and set properties
#  set axi_lsu_1 [ create_bd_cell -type ip -vlnv llnl.gov:user:axi_lsu:2.1 axi_lsu_1 ]

#  set_property -dict [ list \
#CONFIG.SUPPORTS_NARROW_BURST {1} \
#CONFIG.MAX_BURST_LENGTH {256} \
# ] [get_bd_intf_pins /engine_0/axi_lsu_1/m_axi]

#  set_property -dict [ list \
#CONFIG.TDATA_NUM_BYTES {4} \
#CONFIG.TDEST_WIDTH {4} \
#CONFIG.TID_WIDTH {4} \
#CONFIG.TUSER_WIDTH {8} \
# ] [get_bd_intf_pins /engine_0/axi_lsu_1/m_axis_ctl]

#  set_property -dict [ list \
#CONFIG.TDATA_NUM_BYTES {8} \
#CONFIG.TDEST_WIDTH {4} \
#CONFIG.TID_WIDTH {4} \
#CONFIG.HAS_TKEEP {1} \
# ] [get_bd_intf_pins /engine_0/axi_lsu_1/m_axis_dat]
#CONFIG.ARB_ON_MAX_XFERS {0} 

  # Create instance: axis_ctl_0, and set properties
  set axis_ctl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 axis_ctl_0 ]
  set_property -dict [ list \
CONFIG.NUM_MI {3} \
CONFIG.NUM_SI {3} \
CONFIG.M00_AXIS_BASETDEST {0x00000000} \
CONFIG.M00_AXIS_HIGHTDEST {0x00000001} \
CONFIG.M01_AXIS_BASETDEST {0x00000002} \
CONFIG.M01_AXIS_HIGHTDEST {0x00000003} \
CONFIG.M02_AXIS_BASETDEST {0x00000004} \
CONFIG.M02_AXIS_HIGHTDEST {0x00000005} \
 ] $axis_ctl_0
#validate_bd_design -quiet -design $axis_ctl_0
#  set_property -quiet -dict [ list \
#CONFIG.ARB_ON_TLAST {1} \
#CONFIG.ARB_ON_MAX_XFERS {0} \
#CONFIG.ARB_ON_NUM_CYCLES {1024} \
# ] [get_bd_cells axis_ctl_0]
#report_property -all [get_bd_cells axis_ctl_0]

 # Create instance: axis_hash_0, and set properties
#  set axis_hash_0 [ create_bd_cell -type ip -vlnv llnl.gov:user:axis_hash:1.0 axis_hash_0 ]

#  set_property -dict [ list \
#CONFIG.TDATA_NUM_BYTES {4} \
#CONFIG.TDEST_WIDTH {4} \
#CONFIG.TID_WIDTH {4} \
#CONFIG.TUSER_WIDTH {8} \
# ] [get_bd_intf_pins /engine_0/axis_hash_0/m_axis_ctl]

#  set_property -dict [ list \
#CONFIG.TDATA_NUM_BYTES {8} \
#CONFIG.TDEST_WIDTH {4} \
#CONFIG.TID_WIDTH {4} \
#CONFIG.HAS_TKEEP {1} \
# ] [get_bd_intf_pins /engine_0/axis_hash_0/m_axis_dat]

  # Create instance: host_0
  create_hier_cell_host_0 $hier_obj host_0

set microblaze_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:10.0 microblaze_0 ]
set_property -dict [ list \
CONFIG.C_BASE_VECTORS {0xD0000000} \
CONFIG.C_USE_DCACHE {1} \
CONFIG.C_DCACHE_ALWAYS_USED {1} \
CONFIG.C_DCACHE_BASEADDR {0x00000000} \
CONFIG.C_DCACHE_HIGHADDR {0x7FFFFFFF} \
CONFIG.C_DCACHE_BYTE_SIZE {16384} \
CONFIG.C_DCACHE_ADDR_TAG {17} \
CONFIG.C_DCACHE_USE_WRITEBACK {1} \
CONFIG.C_DCACHE_VICTIMS {4} \
CONFIG.C_DEBUG_ENABLED {1} \
CONFIG.C_D_AXI {0} \
CONFIG.C_D_LMB {1} \
CONFIG.C_FAULT_TOLERANT {0} \
CONFIG.C_FSL_LINKS {1} \
CONFIG.C_USE_ICACHE {1} \
CONFIG.C_ICACHE_ALWAYS_USED {0} \
CONFIG.C_ICACHE_BASEADDR {0x00000000} \
CONFIG.C_ICACHE_HIGHADDR {0x7FFFFFFF} \
CONFIG.C_CACHE_BYTE_SIZE {16384} \
CONFIG.C_ADDR_TAG_BITS {17} \
CONFIG.C_ICACHE_STREAMS {0} \
CONFIG.C_I_LMB {1} \
CONFIG.C_USE_BARREL {1} \
CONFIG.C_USE_DIV {1} \
CONFIG.C_USE_HW_MUL {1} \
CONFIG.C_USE_INTERRUPT {0} \
CONFIG.C_USE_REORDER_INSTR {0} \
 ] $microblaze_0
apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config {local_mem "64KB" ecc "None" cache "16KB" debug_module "Debug Only" axi_periph "Disabled" axi_intc "0" clk "New External Port (100 MHz)" }  [get_bd_cells microblaze_0]
set_property -dict [list CONFIG.C_USE_ICACHE {0} CONFIG.C_ADDR_TAG_BITS {0}] $microblaze_0

current_bd_instance $oldCurInst
move_bd_cells [get_bd_cells engine_0] [get_bd_cells rst_microblaze_0_Clk_100M]
move_bd_cells [get_bd_cells engine_0] [get_bd_cells mdm_1]
delete_bd_objs [get_bd_nets microblaze_0_Clk_1] [get_bd_ports microblaze_0_Clk]
set_property name Clk [get_bd_pins engine_0/microblaze_0_Clk]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]

connect_bd_net [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn] [get_bd_pins engine_0/axis_ctl_0/aresetn]
startgroup
create_bd_cell -type ip -vlnv llnl.gov:user:axis_hdr:1.2 engine_0/axis_hdr_0
endgroup
connect_bd_net [get_bd_pins engine_0/axis_hdr_0/h2s_aresetn] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins engine_0/axis_hdr_0/s2h_aresetn] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins engine_0/host_0/d1_aresetn] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/peripheral_aresetn] [get_bd_pins engine_0/host_0/d2_aresetn]

connect_bd_intf_net [get_bd_intf_pins engine_0/axis_hdr_0/m_axis_hdr] [get_bd_intf_pins engine_0/microblaze_0/S0_AXIS]
connect_bd_intf_net [get_bd_intf_pins engine_0/axis_hdr_0/s_axis_hdr] [get_bd_intf_pins engine_0/microblaze_0/M0_AXIS]
connect_bd_intf_net [get_bd_intf_pins engine_0/S_AXI] -boundary_type upper [get_bd_intf_pins engine_0/host_0/S_AXI]

connect_bd_intf_net -boundary_type upper [get_bd_intf_pins engine_0/host_0/M_AXIS] [get_bd_intf_pins engine_0/axis_ctl_0/S00_AXIS]
connect_bd_intf_net [get_bd_intf_pins engine_0/axis_ctl_0/M00_AXIS] -boundary_type upper [get_bd_intf_pins engine_0/host_0/S_AXIS]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/host_0/aclk]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/axis_ctl_0/aclk]
connect_bd_intf_net [get_bd_intf_pins engine_0/axis_hdr_0/m_axis_sig] [get_bd_intf_pins engine_0/axis_ctl_0/S01_AXIS]
connect_bd_intf_net [get_bd_intf_pins engine_0/axis_hdr_0/s_axis_sig] [get_bd_intf_pins engine_0/axis_ctl_0/M01_AXIS]

connect_bd_intf_net [get_bd_intf_pins engine_0/microblaze_0/M_AXI_DC] [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP3_FPD]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM1_FPD" intc_ip "Auto" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins engine_0/host_0/axi_fifo_mm_s_0/S_AXI]

connect_bd_net [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/ext_reset_in] [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0]

connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/axis_hdr_0/h2s_aclk]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/axis_hdr_0/s2h_aclk]

create_bd_cell -type ip -vlnv llnl.gov:user:axi_lsu:2.3 engine_0/axi_lsu_0
set_property -dict [list CONFIG.C_AXI_MAP_ADDR_WIDTH {40}] [get_bd_cells engine_0/axi_lsu_0]
connect_bd_intf_net [get_bd_intf_pins engine_0/axi_lsu_0/s_axis_ctl] [get_bd_intf_pins engine_0/axis_ctl_0/M02_AXIS]
connect_bd_intf_net [get_bd_intf_pins engine_0/axi_lsu_0/m_axis_ctl] [get_bd_intf_pins engine_0/axis_ctl_0/S02_AXIS]
connect_bd_intf_net [get_bd_intf_pins engine_0/axi_lsu_0/s_axis_dat] [get_bd_intf_pins engine_0/axi_lsu_0/m_axis_dat]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/axi_lsu_0/ctl_aclk]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/axi_lsu_0/data_aclk]
connect_bd_net [get_bd_pins engine_0/axi_lsu_0/ctl_aresetn] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins engine_0/axi_lsu_0/data_aresetn] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 engine_0/axi_interconnect_0
set_property -dict [list CONFIG.NUM_SI {2} CONFIG.NUM_MI {1}] [get_bd_cells engine_0/axi_interconnect_0]
set_property -dict [list CONFIG.XBAR_DATA_WIDTH.VALUE_SRC USER] [get_bd_cells engine_0/axi_interconnect_0]
set_property -dict [list CONFIG.ENABLE_ADVANCED_OPTIONS {1} CONFIG.XBAR_DATA_WIDTH {64}] [get_bd_cells engine_0/axi_interconnect_0]
delete_bd_objs [get_bd_intf_nets engine_0/Conn1]
connect_bd_intf_net [get_bd_intf_pins engine_0/microblaze_0/M_AXI_DC] -boundary_type upper [get_bd_intf_pins engine_0/axi_interconnect_0/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins engine_0/axi_lsu_0/m_axi] -boundary_type upper [get_bd_intf_pins engine_0/axi_interconnect_0/S01_AXI]
connect_bd_intf_net [get_bd_intf_pins engine_0/M_AXI_DC] -boundary_type upper [get_bd_intf_pins engine_0/axi_interconnect_0/M00_AXI]
connect_bd_net [get_bd_pins engine_0/axi_interconnect_0/ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins engine_0/axi_interconnect_0/M00_ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins engine_0/axi_interconnect_0/S00_ACLK] [get_bd_pins engine_0/Clk]
connect_bd_net [get_bd_pins engine_0/axi_interconnect_0/S01_ACLK] [get_bd_pins engine_0/Clk]
connect_bd_net [get_bd_pins engine_0/axi_interconnect_0/ARESETN] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins engine_0/axi_interconnect_0/M00_ARESETN] [get_bd_pins rst_pl_clk1/peripheral_aresetn]
# TODO: Put these on engine_0/rst_microblaze_0_Clk_100M/peripheral_aresetn.
connect_bd_net [get_bd_pins engine_0/axi_interconnect_0/S00_ARESETN] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins engine_0/axi_interconnect_0/S01_ARESETN] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]
# TODO: Make sure that axi_interconnect_0 will support 16 outstanding read and write transactions. The following override gives an error.
# ERROR: [BD 41-738] Exec TCL: the object '/engine_0/axi_interconnect_0/xbar' is part of the appcore 'axi_interconnect_0' and cannot be modified directly.
# set_property -dict [list CONFIG.M00_READ_ISSUING.VALUE_SRC USER CONFIG.M00_WRITE_ISSUING.VALUE_SRC USER] [get_bd_cells engine_0/axi_interconnect_0/xbar]
# set_property CONFIG.M00_READ_ISSUING 16 [get_bd_cells engine_0/axi_interconnect_0/xbar]
# set_property CONFIG.M00_WRITE_ISSUING 16 [get_bd_cells engine_0/axi_interconnect_0/xbar]

# Creating delays and setting their properties
set axi_delay_2 [ create_bd_cell -type ip -vlnv llnl.gov:user:axi_delay:1.2 axi_delay_2 ]
set axi_delay_3 [ create_bd_cell -type ip -vlnv llnl.gov:user:axi_delay:1.2 axi_delay_3 ]
set_property -dict [list CONFIG.C_AXI_PROTOCOL {0} CONFIG.C_MEM_ADDR_WIDTH {36} CONFIG.C_FIFO_DEPTH_B {32} CONFIG.C_FIFO_DEPTH_R {512} CONFIG.C_AXI_ID_WIDTH {6} CONFIG.C_AXI_ADDR_WIDTH {40} CONFIG.C_AXI_DATA_WIDTH {64}] [get_bd_cells axi_delay_2]
set_property -dict [list CONFIG.C_AXI_PROTOCOL {0} CONFIG.C_MEM_ADDR_WIDTH {36} CONFIG.C_FIFO_DEPTH_B {32} CONFIG.C_FIFO_DEPTH_R {512} CONFIG.C_AXI_ID_WIDTH {6} CONFIG.C_AXI_ADDR_WIDTH {40} CONFIG.C_AXI_DATA_WIDTH {64}] [get_bd_cells axi_delay_3]

# Creating shims and setting their properties
set axi_shim_2 [ create_bd_cell -type ip -vlnv llnl.gov:user:axi_shim:1.4 axi_shim_2 ]
set_property -dict [list CONFIG.C_AXI_PROTOCOL {0} CONFIG.C_MAP_WIDTH {20} CONFIG.C_MAP_IN {00000000000000000000} CONFIG.C_MAP_OUT {00001000000000000000} CONFIG.C_AXI_ID_WIDTH {4} CONFIG.C_AXI_ADDR_WIDTH {40} CONFIG.C_AXI_DATA_WIDTH {64}] [get_bd_cells axi_shim_2]
set_property -dict [list CONFIG.C_AXI_ID_WIDTH {4}] [get_bd_cells axi_shim_2]
set axi_shim_3 [ create_bd_cell -type ip -vlnv llnl.gov:user:axi_shim:1.4 axi_shim_3 ]
set_property -dict [list CONFIG.C_AXI_PROTOCOL {0} CONFIG.C_MAP_WIDTH {5} CONFIG.C_MAP_IN {00000} CONFIG.C_MAP_OUT {00011} CONFIG.C_AXI_ID_WIDTH {4} CONFIG.C_AXI_ADDR_WIDTH {40} CONFIG.C_AXI_DATA_WIDTH {64}] [get_bd_cells axi_shim_3]
set_property -dict [list CONFIG.C_AXI_ID_WIDTH {4}] [get_bd_cells axi_shim_3]

# connecting shims back to back
connect_bd_intf_net [get_bd_intf_pins axi_shim_2/m_axi] [get_bd_intf_pins axi_shim_3/s_axi]

# adding axi_interconnect IP to connect shim with delays
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_1
set_property -dict [list CONFIG.NUM_MI {2} CONFIG.NUM_SI {1}] [get_bd_cells axi_interconnect_1]
set_property -dict [list CONFIG.XBAR_DATA_WIDTH.VALUE_SRC USER] [get_bd_cells axi_interconnect_1]
set_property -dict [list CONFIG.ENABLE_ADVANCED_OPTIONS {1} CONFIG.XBAR_DATA_WIDTH {64}] [get_bd_cells axi_interconnect_1]

# connect shim and delays to axi_interconnect
connect_bd_intf_net [get_bd_intf_pins axi_shim_3/m_axi] -boundary_type upper [get_bd_intf_pins axi_interconnect_1/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_delay_2/s_axi] -boundary_type upper [get_bd_intf_pins axi_interconnect_1/M00_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_delay_3/s_axi] -boundary_type upper [get_bd_intf_pins axi_interconnect_1/M01_AXI]

connect_bd_net [get_bd_pins axi_interconnect_1/ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_interconnect_1/S00_ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_interconnect_1/M00_ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_interconnect_1/M01_ACLK] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_interconnect_1/ARESETN] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_1/S00_ARESETN] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_1/M00_ARESETN] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_1/M01_ARESETN] [get_bd_pins rst_pl_clk1/interconnect_aresetn]

delete_bd_objs [get_bd_intf_nets engine_0_M_AXI_DC]

connect_bd_intf_net [get_bd_intf_pins axi_delay_2/m_axi] [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP2_FPD]
connect_bd_intf_net [get_bd_intf_pins axi_delay_3/m_axi] [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP3_FPD]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM1_FPD" intc_ip "Auto" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_delay_2/s_axi_lite]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/zynq_ultra_ps_e_0/M_AXI_HPM1_FPD" intc_ip "Auto" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_delay_3/s_axi_lite]

connect_bd_net [get_bd_pins axi_delay_2/s_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_delay_2/m_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_delay_3/s_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_delay_3/m_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_shim_2/s_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_shim_2/m_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_shim_3/s_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins axi_shim_3/m_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]

connect_bd_net [get_bd_pins axi_delay_2/s_axi_aresetn] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_delay_2/m_axi_aresetn] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_delay_3/s_axi_aresetn] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_delay_3/m_axi_aresetn] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_shim_2/s_axi_aresetn] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_shim_2/m_axi_aresetn] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_shim_3/s_axi_aresetn] [get_bd_pins rst_pl_clk1/interconnect_aresetn]
connect_bd_net [get_bd_pins axi_shim_3/m_axi_aresetn] [get_bd_pins rst_pl_clk1/interconnect_aresetn]

# Connect engine to shim
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins engine_0/M_AXI_DC] [get_bd_intf_pins axi_shim_2/s_axi]

# Connect APM slot 1 to engine memory path
connect_bd_intf_net [get_bd_intf_pins axi_perf_mon_0/SLOT_1_AXI] [get_bd_intf_pins axi_shim_2/s_axi]

set_property range 64K [get_bd_addr_segs {engine_0/microblaze_0/Data/SEG_dlmb_bram_if_cntlr_Mem}]
set_property range 64K [get_bd_addr_segs {engine_0/microblaze_0/Instruction/SEG_ilmb_bram_if_cntlr_Mem}]

  # Create instance: mcu_0
  #create_hier_cell_mcu_0 $hier_obj mcu_0

  # Create instance: mdm_0, and set properties
  #set mdm_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm_0 ]
  # Restore current instance
  #current_bd_instance $oldCurInst
}

set_property -dict [list CONFIG.PSU__USE__S_AXI_GP4 {1} CONFIG.PSU__SAXIGP4__DATA_WIDTH {64}] [get_bd_cells zynq_ultra_ps_e_0]
set_property -dict [list CONFIG.PSU__USE__S_AXI_GP5 {1} CONFIG.PSU__SAXIGP5__DATA_WIDTH {64}] [get_bd_cells zynq_ultra_ps_e_0]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/saxihp2_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/saxihp3_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]

create_hier_cell_engine_0 [current_bd_instance .] engine_0

# assign_bd_address
# assign_bd_address -offset 0x0000000000 -range   2G [get_bd_addr_segs {axi_shim_2/s_axi/mem0}]
assign_bd_address -offset 0x0000000000 -range 128G [get_bd_addr_segs {axi_shim_3/s_axi/mem0}]
assign_bd_address -offset 0x0800000000 -range   1M [get_bd_addr_segs {axi_delay_2/s_axi/mem0}]
assign_bd_address -offset 0x1800000000 -range  32G [get_bd_addr_segs {axi_delay_3/s_axi/mem0}]
assign_bd_address [get_bd_addr_segs {zynq_ultra_ps_e_0/SAXIGP4/HP2_DDR_HIGH}]
assign_bd_address [get_bd_addr_segs {zynq_ultra_ps_e_0/SAXIGP4/HP2_DDR_LOW}]
assign_bd_address [get_bd_addr_segs {zynq_ultra_ps_e_0/SAXIGP5/HP3_DDR_HIGH}]
assign_bd_address [get_bd_addr_segs {zynq_ultra_ps_e_0/SAXIGP5/HP3_DDR_LOW}]

create_bd_addr_seg -offset 0x00000000 -range  2G [get_bd_addr_spaces engine_0/microblaze_0/Data] [get_bd_addr_segs axi_shim_2/s_axi/mem0] SEG_axi_shim_2_mem0
create_bd_addr_seg -offset 0x00000000 -range 16G [get_bd_addr_spaces engine_0/axi_lsu_0/m_axi] [get_bd_addr_segs axi_shim_2/s_axi/mem0] SEG_axi_shim_2_mem0
# set_property range  2G [get_bd_addr_segs {microblaze_0/Data/SEG_axi_shim_2_mem0}]
# set_property range 16G [get_bd_addr_segs {engine_0/axi_lsu_0/m_axi/SEG_axi_shim_2_mem0}]

validate_bd_design
save_bd_design

# TODO: why can't this be merged with previous set_property. Seems to need a validate or it gives warning and error.
# WARNING: [IP_Flow 19-3374] An attempt to modify the value of disabled parameter 'ARB_ON_TLAST'
set_property -dict [list CONFIG.ARB_ON_TLAST {1} CONFIG.ARB_ON_MAX_XFERS {0} CONFIG.ARB_ON_NUM_CYCLES {1024}] [get_bd_cells engine_0/axis_ctl_0]
