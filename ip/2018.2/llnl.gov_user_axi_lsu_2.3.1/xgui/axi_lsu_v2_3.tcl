# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  ipgui::add_param $IPINST -name "C_AXI_MAP_ID_WIDTH"
  ipgui::add_param $IPINST -name "C_AXI_MAP_DATA_WIDTH"
  ipgui::add_param $IPINST -name "C_AXI_MAP_ADDR_WIDTH"
  ipgui::add_param $IPINST -name "C_AXIS_DAT_TDEST_WIDTH"
  ipgui::add_param $IPINST -name "C_AXIS_DAT_TID_WIDTH"
  ipgui::add_param $IPINST -name "C_AXIS_DAT_TDATA_WIDTH"
  ipgui::add_param $IPINST -name "C_AXIS_CTL_TUSER_WIDTH"
  ipgui::add_param $IPINST -name "C_AXIS_CTL_TDEST_WIDTH"
  ipgui::add_param $IPINST -name "C_AXIS_CTL_TID_WIDTH"
  ipgui::add_param $IPINST -name "C_AXIS_CTL_TDATA_WIDTH"
  ipgui::add_param $IPINST -name "C_W_INCLUDE_SF"
  ipgui::add_param $IPINST -name "C_W_ADDR_PIPE_DEPTH"
  ipgui::add_param $IPINST -name "C_R_INCLUDE_SF"
  ipgui::add_param $IPINST -name "C_R_ADDR_PIPE_DEPTH"
  ipgui::add_param $IPINST -name "C_BTT_USED"
  ipgui::add_param $IPINST -name "C_MAX_BURST_LEN"
  ipgui::add_param $IPINST -name "C_CTL_FIFO_DEPTH"
  ipgui::add_param $IPINST -name "C_CTL_IS_ASYNC"

}

proc update_PARAM_VALUE.C_AXI_MAP_ID_WIDTH { PARAM_VALUE.C_AXI_MAP_ID_WIDTH } {
	# Procedure called to update C_AXI_MAP_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_MAP_ID_WIDTH { PARAM_VALUE.C_AXI_MAP_ID_WIDTH } {
	# Procedure called to validate C_AXI_MAP_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_MAP_DATA_WIDTH { PARAM_VALUE.C_AXI_MAP_DATA_WIDTH } {
	# Procedure called to update C_AXI_MAP_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_MAP_DATA_WIDTH { PARAM_VALUE.C_AXI_MAP_DATA_WIDTH } {
	# Procedure called to validate C_AXI_MAP_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_MAP_ADDR_WIDTH { PARAM_VALUE.C_AXI_MAP_ADDR_WIDTH } {
	# Procedure called to update C_AXI_MAP_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_MAP_ADDR_WIDTH { PARAM_VALUE.C_AXI_MAP_ADDR_WIDTH } {
	# Procedure called to validate C_AXI_MAP_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXIS_DAT_TDEST_WIDTH { PARAM_VALUE.C_AXIS_DAT_TDEST_WIDTH } {
	# Procedure called to update C_AXIS_DAT_TDEST_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_DAT_TDEST_WIDTH { PARAM_VALUE.C_AXIS_DAT_TDEST_WIDTH } {
	# Procedure called to validate C_AXIS_DAT_TDEST_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXIS_DAT_TID_WIDTH { PARAM_VALUE.C_AXIS_DAT_TID_WIDTH } {
	# Procedure called to update C_AXIS_DAT_TID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_DAT_TID_WIDTH { PARAM_VALUE.C_AXIS_DAT_TID_WIDTH } {
	# Procedure called to validate C_AXIS_DAT_TID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXIS_DAT_TDATA_WIDTH { PARAM_VALUE.C_AXIS_DAT_TDATA_WIDTH } {
	# Procedure called to update C_AXIS_DAT_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_DAT_TDATA_WIDTH { PARAM_VALUE.C_AXIS_DAT_TDATA_WIDTH } {
	# Procedure called to validate C_AXIS_DAT_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXIS_CTL_TUSER_WIDTH { PARAM_VALUE.C_AXIS_CTL_TUSER_WIDTH } {
	# Procedure called to update C_AXIS_CTL_TUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_CTL_TUSER_WIDTH { PARAM_VALUE.C_AXIS_CTL_TUSER_WIDTH } {
	# Procedure called to validate C_AXIS_CTL_TUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXIS_CTL_TDEST_WIDTH { PARAM_VALUE.C_AXIS_CTL_TDEST_WIDTH } {
	# Procedure called to update C_AXIS_CTL_TDEST_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_CTL_TDEST_WIDTH { PARAM_VALUE.C_AXIS_CTL_TDEST_WIDTH } {
	# Procedure called to validate C_AXIS_CTL_TDEST_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXIS_CTL_TID_WIDTH { PARAM_VALUE.C_AXIS_CTL_TID_WIDTH } {
	# Procedure called to update C_AXIS_CTL_TID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_CTL_TID_WIDTH { PARAM_VALUE.C_AXIS_CTL_TID_WIDTH } {
	# Procedure called to validate C_AXIS_CTL_TID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXIS_CTL_TDATA_WIDTH { PARAM_VALUE.C_AXIS_CTL_TDATA_WIDTH } {
	# Procedure called to update C_AXIS_CTL_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_CTL_TDATA_WIDTH { PARAM_VALUE.C_AXIS_CTL_TDATA_WIDTH } {
	# Procedure called to validate C_AXIS_CTL_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_W_INCLUDE_SF { PARAM_VALUE.C_W_INCLUDE_SF } {
	# Procedure called to update C_W_INCLUDE_SF when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_W_INCLUDE_SF { PARAM_VALUE.C_W_INCLUDE_SF } {
	# Procedure called to validate C_W_INCLUDE_SF
	return true
}

proc update_PARAM_VALUE.C_W_ADDR_PIPE_DEPTH { PARAM_VALUE.C_W_ADDR_PIPE_DEPTH } {
	# Procedure called to update C_W_ADDR_PIPE_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_W_ADDR_PIPE_DEPTH { PARAM_VALUE.C_W_ADDR_PIPE_DEPTH } {
	# Procedure called to validate C_W_ADDR_PIPE_DEPTH
	return true
}

proc update_PARAM_VALUE.C_R_INCLUDE_SF { PARAM_VALUE.C_R_INCLUDE_SF } {
	# Procedure called to update C_R_INCLUDE_SF when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_R_INCLUDE_SF { PARAM_VALUE.C_R_INCLUDE_SF } {
	# Procedure called to validate C_R_INCLUDE_SF
	return true
}

proc update_PARAM_VALUE.C_R_ADDR_PIPE_DEPTH { PARAM_VALUE.C_R_ADDR_PIPE_DEPTH } {
	# Procedure called to update C_R_ADDR_PIPE_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_R_ADDR_PIPE_DEPTH { PARAM_VALUE.C_R_ADDR_PIPE_DEPTH } {
	# Procedure called to validate C_R_ADDR_PIPE_DEPTH
	return true
}

proc update_PARAM_VALUE.C_BTT_USED { PARAM_VALUE.C_BTT_USED } {
	# Procedure called to update C_BTT_USED when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_BTT_USED { PARAM_VALUE.C_BTT_USED } {
	# Procedure called to validate C_BTT_USED
	return true
}

proc update_PARAM_VALUE.C_MAX_BURST_LEN { PARAM_VALUE.C_MAX_BURST_LEN } {
	# Procedure called to update C_MAX_BURST_LEN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MAX_BURST_LEN { PARAM_VALUE.C_MAX_BURST_LEN } {
	# Procedure called to validate C_MAX_BURST_LEN
	return true
}

proc update_PARAM_VALUE.C_CTL_FIFO_DEPTH { PARAM_VALUE.C_CTL_FIFO_DEPTH } {
	# Procedure called to update C_CTL_FIFO_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CTL_FIFO_DEPTH { PARAM_VALUE.C_CTL_FIFO_DEPTH } {
	# Procedure called to validate C_CTL_FIFO_DEPTH
	return true
}

proc update_PARAM_VALUE.C_CTL_IS_ASYNC { PARAM_VALUE.C_CTL_IS_ASYNC } {
	# Procedure called to update C_CTL_IS_ASYNC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_CTL_IS_ASYNC { PARAM_VALUE.C_CTL_IS_ASYNC } {
	# Procedure called to validate C_CTL_IS_ASYNC
	return true
}


proc update_MODELPARAM_VALUE.C_CTL_IS_ASYNC { MODELPARAM_VALUE.C_CTL_IS_ASYNC PARAM_VALUE.C_CTL_IS_ASYNC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CTL_IS_ASYNC}] ${MODELPARAM_VALUE.C_CTL_IS_ASYNC}
}

proc update_MODELPARAM_VALUE.C_CTL_FIFO_DEPTH { MODELPARAM_VALUE.C_CTL_FIFO_DEPTH PARAM_VALUE.C_CTL_FIFO_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_CTL_FIFO_DEPTH}] ${MODELPARAM_VALUE.C_CTL_FIFO_DEPTH}
}

proc update_MODELPARAM_VALUE.C_MAX_BURST_LEN { MODELPARAM_VALUE.C_MAX_BURST_LEN PARAM_VALUE.C_MAX_BURST_LEN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MAX_BURST_LEN}] ${MODELPARAM_VALUE.C_MAX_BURST_LEN}
}

proc update_MODELPARAM_VALUE.C_BTT_USED { MODELPARAM_VALUE.C_BTT_USED PARAM_VALUE.C_BTT_USED } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_BTT_USED}] ${MODELPARAM_VALUE.C_BTT_USED}
}

proc update_MODELPARAM_VALUE.C_R_ADDR_PIPE_DEPTH { MODELPARAM_VALUE.C_R_ADDR_PIPE_DEPTH PARAM_VALUE.C_R_ADDR_PIPE_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_R_ADDR_PIPE_DEPTH}] ${MODELPARAM_VALUE.C_R_ADDR_PIPE_DEPTH}
}

proc update_MODELPARAM_VALUE.C_R_INCLUDE_SF { MODELPARAM_VALUE.C_R_INCLUDE_SF PARAM_VALUE.C_R_INCLUDE_SF } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_R_INCLUDE_SF}] ${MODELPARAM_VALUE.C_R_INCLUDE_SF}
}

proc update_MODELPARAM_VALUE.C_W_ADDR_PIPE_DEPTH { MODELPARAM_VALUE.C_W_ADDR_PIPE_DEPTH PARAM_VALUE.C_W_ADDR_PIPE_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_W_ADDR_PIPE_DEPTH}] ${MODELPARAM_VALUE.C_W_ADDR_PIPE_DEPTH}
}

proc update_MODELPARAM_VALUE.C_W_INCLUDE_SF { MODELPARAM_VALUE.C_W_INCLUDE_SF PARAM_VALUE.C_W_INCLUDE_SF } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_W_INCLUDE_SF}] ${MODELPARAM_VALUE.C_W_INCLUDE_SF}
}

proc update_MODELPARAM_VALUE.C_AXIS_CTL_TDATA_WIDTH { MODELPARAM_VALUE.C_AXIS_CTL_TDATA_WIDTH PARAM_VALUE.C_AXIS_CTL_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_CTL_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_AXIS_CTL_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXIS_CTL_TID_WIDTH { MODELPARAM_VALUE.C_AXIS_CTL_TID_WIDTH PARAM_VALUE.C_AXIS_CTL_TID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_CTL_TID_WIDTH}] ${MODELPARAM_VALUE.C_AXIS_CTL_TID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXIS_CTL_TDEST_WIDTH { MODELPARAM_VALUE.C_AXIS_CTL_TDEST_WIDTH PARAM_VALUE.C_AXIS_CTL_TDEST_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_CTL_TDEST_WIDTH}] ${MODELPARAM_VALUE.C_AXIS_CTL_TDEST_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXIS_CTL_TUSER_WIDTH { MODELPARAM_VALUE.C_AXIS_CTL_TUSER_WIDTH PARAM_VALUE.C_AXIS_CTL_TUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_CTL_TUSER_WIDTH}] ${MODELPARAM_VALUE.C_AXIS_CTL_TUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXIS_DAT_TDATA_WIDTH { MODELPARAM_VALUE.C_AXIS_DAT_TDATA_WIDTH PARAM_VALUE.C_AXIS_DAT_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_DAT_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_AXIS_DAT_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXIS_DAT_TID_WIDTH { MODELPARAM_VALUE.C_AXIS_DAT_TID_WIDTH PARAM_VALUE.C_AXIS_DAT_TID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_DAT_TID_WIDTH}] ${MODELPARAM_VALUE.C_AXIS_DAT_TID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXIS_DAT_TDEST_WIDTH { MODELPARAM_VALUE.C_AXIS_DAT_TDEST_WIDTH PARAM_VALUE.C_AXIS_DAT_TDEST_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXIS_DAT_TDEST_WIDTH}] ${MODELPARAM_VALUE.C_AXIS_DAT_TDEST_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_MAP_ID_WIDTH { MODELPARAM_VALUE.C_AXI_MAP_ID_WIDTH PARAM_VALUE.C_AXI_MAP_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_MAP_ID_WIDTH}] ${MODELPARAM_VALUE.C_AXI_MAP_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_MAP_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_MAP_ADDR_WIDTH PARAM_VALUE.C_AXI_MAP_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_MAP_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_MAP_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_MAP_DATA_WIDTH { MODELPARAM_VALUE.C_AXI_MAP_DATA_WIDTH PARAM_VALUE.C_AXI_MAP_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_MAP_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI_MAP_DATA_WIDTH}
}

