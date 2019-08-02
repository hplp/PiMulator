# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  ipgui::add_param $IPINST -name "C_AXI_PROTOCOL" -layout horizontal
  ipgui::add_param $IPINST -name "C_MEM_ADDR_WIDTH"
  ipgui::add_param $IPINST -name "C_COUNTER_WIDTH"
  ipgui::add_param $IPINST -name "C_FIFO_DEPTH_AW"
  ipgui::add_param $IPINST -name "C_FIFO_DEPTH_W"
  ipgui::add_param $IPINST -name "C_FIFO_DEPTH_B"
  ipgui::add_param $IPINST -name "C_FIFO_DEPTH_AR"
  ipgui::add_param $IPINST -name "C_FIFO_DEPTH_R"
  ipgui::add_param $IPINST -name "C_AXI_LITE_ADDR_WIDTH"
  ipgui::add_param $IPINST -name "C_AXI_LITE_DATA_WIDTH"
  ipgui::add_param $IPINST -name "C_AXI_ID_WIDTH"
  ipgui::add_param $IPINST -name "C_AXI_ADDR_WIDTH"
  ipgui::add_param $IPINST -name "C_AXI_DATA_WIDTH"

}

proc update_PARAM_VALUE.C_AXI_ADDR_WIDTH { PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	# Procedure called to update C_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_ADDR_WIDTH { PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_DATA_WIDTH { PARAM_VALUE.C_AXI_DATA_WIDTH } {
	# Procedure called to update C_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_DATA_WIDTH { PARAM_VALUE.C_AXI_DATA_WIDTH } {
	# Procedure called to validate C_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_ID_WIDTH { PARAM_VALUE.C_AXI_ID_WIDTH } {
	# Procedure called to update C_AXI_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_ID_WIDTH { PARAM_VALUE.C_AXI_ID_WIDTH } {
	# Procedure called to validate C_AXI_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH { PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH } {
	# Procedure called to update C_AXI_LITE_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH { PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH } {
	# Procedure called to validate C_AXI_LITE_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_LITE_DATA_WIDTH { PARAM_VALUE.C_AXI_LITE_DATA_WIDTH } {
	# Procedure called to update C_AXI_LITE_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_LITE_DATA_WIDTH { PARAM_VALUE.C_AXI_LITE_DATA_WIDTH } {
	# Procedure called to validate C_AXI_LITE_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_PROTOCOL { PARAM_VALUE.C_AXI_PROTOCOL } {
	# Procedure called to update C_AXI_PROTOCOL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_PROTOCOL { PARAM_VALUE.C_AXI_PROTOCOL } {
	# Procedure called to validate C_AXI_PROTOCOL
	return true
}

proc update_PARAM_VALUE.C_COUNTER_WIDTH { PARAM_VALUE.C_COUNTER_WIDTH } {
	# Procedure called to update C_COUNTER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_COUNTER_WIDTH { PARAM_VALUE.C_COUNTER_WIDTH } {
	# Procedure called to validate C_COUNTER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_FIFO_DEPTH_AR { PARAM_VALUE.C_FIFO_DEPTH_AR } {
	# Procedure called to update C_FIFO_DEPTH_AR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FIFO_DEPTH_AR { PARAM_VALUE.C_FIFO_DEPTH_AR } {
	# Procedure called to validate C_FIFO_DEPTH_AR
	return true
}

proc update_PARAM_VALUE.C_FIFO_DEPTH_AW { PARAM_VALUE.C_FIFO_DEPTH_AW } {
	# Procedure called to update C_FIFO_DEPTH_AW when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FIFO_DEPTH_AW { PARAM_VALUE.C_FIFO_DEPTH_AW } {
	# Procedure called to validate C_FIFO_DEPTH_AW
	return true
}

proc update_PARAM_VALUE.C_FIFO_DEPTH_B { PARAM_VALUE.C_FIFO_DEPTH_B } {
	# Procedure called to update C_FIFO_DEPTH_B when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FIFO_DEPTH_B { PARAM_VALUE.C_FIFO_DEPTH_B } {
	# Procedure called to validate C_FIFO_DEPTH_B
	return true
}

proc update_PARAM_VALUE.C_FIFO_DEPTH_R { PARAM_VALUE.C_FIFO_DEPTH_R } {
	# Procedure called to update C_FIFO_DEPTH_R when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FIFO_DEPTH_R { PARAM_VALUE.C_FIFO_DEPTH_R } {
	# Procedure called to validate C_FIFO_DEPTH_R
	return true
}

proc update_PARAM_VALUE.C_FIFO_DEPTH_W { PARAM_VALUE.C_FIFO_DEPTH_W } {
	# Procedure called to update C_FIFO_DEPTH_W when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_FIFO_DEPTH_W { PARAM_VALUE.C_FIFO_DEPTH_W } {
	# Procedure called to validate C_FIFO_DEPTH_W
	return true
}

proc update_PARAM_VALUE.C_MEM_ADDR_WIDTH { PARAM_VALUE.C_MEM_ADDR_WIDTH } {
	# Procedure called to update C_MEM_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MEM_ADDR_WIDTH { PARAM_VALUE.C_MEM_ADDR_WIDTH } {
	# Procedure called to validate C_MEM_ADDR_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_AXI_PROTOCOL { MODELPARAM_VALUE.C_AXI_PROTOCOL PARAM_VALUE.C_AXI_PROTOCOL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_PROTOCOL}] ${MODELPARAM_VALUE.C_AXI_PROTOCOL}
}

proc update_MODELPARAM_VALUE.C_MEM_ADDR_WIDTH { MODELPARAM_VALUE.C_MEM_ADDR_WIDTH PARAM_VALUE.C_MEM_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MEM_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_MEM_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_COUNTER_WIDTH { MODELPARAM_VALUE.C_COUNTER_WIDTH PARAM_VALUE.C_COUNTER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_COUNTER_WIDTH}] ${MODELPARAM_VALUE.C_COUNTER_WIDTH}
}

proc update_MODELPARAM_VALUE.C_FIFO_DEPTH_AW { MODELPARAM_VALUE.C_FIFO_DEPTH_AW PARAM_VALUE.C_FIFO_DEPTH_AW } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_DEPTH_AW}] ${MODELPARAM_VALUE.C_FIFO_DEPTH_AW}
}

proc update_MODELPARAM_VALUE.C_FIFO_DEPTH_W { MODELPARAM_VALUE.C_FIFO_DEPTH_W PARAM_VALUE.C_FIFO_DEPTH_W } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_DEPTH_W}] ${MODELPARAM_VALUE.C_FIFO_DEPTH_W}
}

proc update_MODELPARAM_VALUE.C_FIFO_DEPTH_B { MODELPARAM_VALUE.C_FIFO_DEPTH_B PARAM_VALUE.C_FIFO_DEPTH_B } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_DEPTH_B}] ${MODELPARAM_VALUE.C_FIFO_DEPTH_B}
}

proc update_MODELPARAM_VALUE.C_FIFO_DEPTH_AR { MODELPARAM_VALUE.C_FIFO_DEPTH_AR PARAM_VALUE.C_FIFO_DEPTH_AR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_DEPTH_AR}] ${MODELPARAM_VALUE.C_FIFO_DEPTH_AR}
}

proc update_MODELPARAM_VALUE.C_FIFO_DEPTH_R { MODELPARAM_VALUE.C_FIFO_DEPTH_R PARAM_VALUE.C_FIFO_DEPTH_R } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_FIFO_DEPTH_R}] ${MODELPARAM_VALUE.C_FIFO_DEPTH_R}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH { MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH PARAM_VALUE.C_AXI_LITE_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_LITE_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI_LITE_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_ID_WIDTH { MODELPARAM_VALUE.C_AXI_ID_WIDTH PARAM_VALUE.C_AXI_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_ID_WIDTH}] ${MODELPARAM_VALUE.C_AXI_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_ADDR_WIDTH PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_AXI_DATA_WIDTH PARAM_VALUE.C_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI_DATA_WIDTH}
}

