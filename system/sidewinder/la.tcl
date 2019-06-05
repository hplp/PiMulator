set axi_lsu_1 [ create_bd_cell -type ip -vlnv llnl.gov:user:axi_lsu:2.3 engine_0/axi_lsu_1 ]
set_property -dict [list CONFIG.C_AXI_MAP_ADDR_WIDTH {40}] [get_bd_cells engine_0/axi_lsu_1]
set axi_lsu_2 [ create_bd_cell -type ip -vlnv llnl.gov:user:axi_lsu:2.3 engine_0/axi_lsu_2 ]
set_property -dict [list CONFIG.C_AXI_MAP_ADDR_WIDTH {40}] [get_bd_cells engine_0/axi_lsu_2]
set axis_flow_0 [ create_bd_cell -type ip -vlnv llnl.gov:user:axis_flow:1.0 engine_0/axis_flow_0 ]
set axis_hash_0 [ create_bd_cell -type ip -vlnv llnl.gov:user:axis_hash:1.0 engine_0/axis_hash_0 ]
set axis_probe_0 [ create_bd_cell -type ip -vlnv llnl.gov:user:axis_probe:1.1 engine_0/axis_probe_0 ]
set fifo_generator_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 engine_0/fifo_generator_0 ]
set_property -dict [ list \
CONFIG.Empty_Threshold_Assert_Value_axis {510} \
CONFIG.Empty_Threshold_Assert_Value_rach {14} \
CONFIG.Empty_Threshold_Assert_Value_wach {14} \
CONFIG.Empty_Threshold_Assert_Value_wrch {14} \
CONFIG.Enable_TLAST {true} \
CONFIG.FIFO_Implementation_rach {Common_Clock_Distributed_RAM} \
CONFIG.FIFO_Implementation_wach {Common_Clock_Distributed_RAM} \
CONFIG.FIFO_Implementation_wrch {Common_Clock_Distributed_RAM} \
CONFIG.Full_Threshold_Assert_Value_axis {511} \
CONFIG.Full_Threshold_Assert_Value_rach {15} \
CONFIG.Full_Threshold_Assert_Value_wach {15} \
CONFIG.Full_Threshold_Assert_Value_wrch {15} \
CONFIG.INTERFACE_TYPE {AXI_STREAM} \
CONFIG.Input_Depth_axis {512} \
CONFIG.Reset_Type {Asynchronous_Reset} \
CONFIG.TDATA_NUM_BYTES {8} \
CONFIG.TDEST_WIDTH {4} \
CONFIG.TID_WIDTH {4} \
CONFIG.TKEEP_WIDTH {8} \
CONFIG.TSTRB_WIDTH {8} \
CONFIG.TUSER_WIDTH {0} \
 ] $fifo_generator_0
 
connect_bd_intf_net [get_bd_intf_pins engine_0/axi_lsu_1/m_axis_dat] [get_bd_intf_pins engine_0/axis_flow_0/s_axis_dat1]
connect_bd_intf_net [get_bd_intf_pins engine_0/axis_flow_0/m_axis_dat1] [get_bd_intf_pins engine_0/axis_hash_0/s_axis_dat]
connect_bd_intf_net [get_bd_intf_pins engine_0/axis_flow_0/m_axis_dat2] [get_bd_intf_pins engine_0/fifo_generator_0/S_AXIS]
connect_bd_intf_net [get_bd_intf_pins engine_0/fifo_generator_0/M_AXIS] [get_bd_intf_pins engine_0/axis_probe_0/s_axis_dat1]
connect_bd_intf_net [get_bd_intf_pins engine_0/axi_lsu_2/m_axis_dat] [get_bd_intf_pins engine_0/axis_probe_0/s_axis_dat2]
connect_bd_intf_net [get_bd_intf_pins engine_0/axis_hash_0/m_axis_dat] [get_bd_intf_pins engine_0/axi_lsu_1/s_axis_dat]
connect_bd_intf_net [get_bd_intf_pins engine_0/axis_probe_0/m_axis_dat1] [get_bd_intf_pins engine_0/axi_lsu_2/s_axis_dat]

connect_bd_net [get_bd_pins engine_0/axis_flow_0/ctl_aresetn] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins engine_0/axis_flow_0/data_aresetn] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/axis_flow_0/ctl_aclk]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/axis_flow_0/data_aclk]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/axi_lsu_1/ctl_aclk]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/axi_lsu_1/data_aclk]
connect_bd_net [get_bd_pins engine_0/axi_lsu_1/ctl_aresetn] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins engine_0/axi_lsu_1/data_aresetn] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/axi_lsu_2/ctl_aclk]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/axi_lsu_2/data_aclk]
connect_bd_net [get_bd_pins engine_0/axi_lsu_2/ctl_aresetn] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins engine_0/axi_lsu_2/data_aresetn] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/fifo_generator_0/s_aclk]
connect_bd_net [get_bd_pins engine_0/fifo_generator_0/s_aresetn] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/axis_hash_0/ctl_aclk]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/axis_hash_0/data_aclk]
connect_bd_net [get_bd_pins engine_0/axis_hash_0/ctl_aresetn] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins engine_0/axis_hash_0/data_aresetn] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/axis_probe_0/ctl_aclk]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/axis_probe_0/data_aclk]
connect_bd_net [get_bd_pins engine_0/axis_probe_0/ctl_aresetn] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins engine_0/axis_probe_0/data_aresetn] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]

set_property -dict [list CONFIG.NUM_SI {7} CONFIG.NUM_MI {7} CONFIG.M03_AXIS_BASETDEST {0x00000006} CONFIG.M04_AXIS_BASETDEST {0x00000008} CONFIG.M05_AXIS_BASETDEST {0x0000000A} CONFIG.M06_AXIS_BASETDEST {0x0000000C} CONFIG.M03_AXIS_HIGHTDEST {0x00000007} CONFIG.M04_AXIS_HIGHTDEST {0x00000009} CONFIG.M05_AXIS_HIGHTDEST {0x0000000B} CONFIG.M06_AXIS_HIGHTDEST {0x0000000D}] [get_bd_cells engine_0/axis_ctl_0]
connect_bd_intf_net [get_bd_intf_pins engine_0/axis_ctl_0/M03_AXIS] [get_bd_intf_pins engine_0/axi_lsu_1/s_axis_ctl]
connect_bd_intf_net [get_bd_intf_pins engine_0/axi_lsu_1/m_axis_ctl] [get_bd_intf_pins engine_0/axis_ctl_0/S03_AXIS]
connect_bd_intf_net [get_bd_intf_pins engine_0/axis_ctl_0/M04_AXIS] [get_bd_intf_pins engine_0/axis_hash_0/s_axis_ctl]
connect_bd_intf_net [get_bd_intf_pins engine_0/axis_hash_0/m_axis_ctl] [get_bd_intf_pins engine_0/axis_ctl_0/S04_AXIS]
connect_bd_intf_net [get_bd_intf_pins engine_0/axis_ctl_0/M05_AXIS] [get_bd_intf_pins engine_0/axi_lsu_2/s_axis_ctl]
connect_bd_intf_net [get_bd_intf_pins engine_0/axi_lsu_2/m_axis_ctl] [get_bd_intf_pins engine_0/axis_ctl_0/S05_AXIS]
connect_bd_intf_net [get_bd_intf_pins engine_0/axis_ctl_0/M06_AXIS] [get_bd_intf_pins engine_0/axis_probe_0/s_axis_ctl]
connect_bd_intf_net [get_bd_intf_pins engine_0/axis_probe_0/m_axis_ctl] [get_bd_intf_pins engine_0/axis_ctl_0/S06_AXIS]

set_property -dict [list CONFIG.NUM_SI {4} CONFIG.NUM_MI {1}] [get_bd_cells engine_0/axi_interconnect_0]
connect_bd_intf_net [get_bd_intf_pins engine_0/axi_lsu_1/m_axi] -boundary_type upper [get_bd_intf_pins engine_0/axi_interconnect_0/S02_AXI]
connect_bd_intf_net [get_bd_intf_pins engine_0/axi_lsu_2/m_axi] -boundary_type upper [get_bd_intf_pins engine_0/axi_interconnect_0/S03_AXI]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/axi_interconnect_0/S02_ACLK]
connect_bd_net [get_bd_pins engine_0/Clk] [get_bd_pins engine_0/axi_interconnect_0/S03_ACLK]
connect_bd_net [get_bd_pins engine_0/axi_interconnect_0/S02_ARESETN] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]
connect_bd_net [get_bd_pins engine_0/axi_interconnect_0/S03_ARESETN] [get_bd_pins engine_0/rst_microblaze_0_Clk_100M/interconnect_aresetn]

# assign_bd_address [get_bd_addr_segs {axi_shim_2/s_axi/memory}]

create_bd_addr_seg -offset 0x00000000 -range 16G [get_bd_addr_spaces engine_0/axi_lsu_1/m_axi] [get_bd_addr_segs axi_shim_2/s_axi/mem0] SEG_axi_shim_2_mem0
create_bd_addr_seg -offset 0x00000000 -range 16G [get_bd_addr_spaces engine_0/axi_lsu_2/m_axi] [get_bd_addr_segs axi_shim_2/s_axi/mem0] SEG_axi_shim_2_mem0

save_bd_design
validate_bd_design
