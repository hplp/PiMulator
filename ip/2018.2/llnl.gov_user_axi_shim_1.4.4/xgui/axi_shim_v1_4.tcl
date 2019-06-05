# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  ipgui::add_param $IPINST -name "C_AXI_PROTOCOL" -layout horizontal
  ipgui::add_param $IPINST -name "C_AXI_ID_WIDTH"
  ipgui::add_param $IPINST -name "C_AXI_ADDR_WIDTH"
  ipgui::add_param $IPINST -name "C_AXI_DATA_WIDTH"
  ipgui::add_param $IPINST -name "C_MAP_WIDTH"
  ipgui::add_param $IPINST -name "C_MAP_IN"
  ipgui::add_param $IPINST -name "C_MAP_OUT"

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

proc update_PARAM_VALUE.C_AXI_PROTOCOL { PARAM_VALUE.C_AXI_PROTOCOL } {
	# Procedure called to update C_AXI_PROTOCOL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_PROTOCOL { PARAM_VALUE.C_AXI_PROTOCOL } {
	# Procedure called to validate C_AXI_PROTOCOL
	return true
}

proc update_PARAM_VALUE.C_MAP_IN { PARAM_VALUE.C_MAP_IN } {
	# Procedure called to update C_MAP_IN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MAP_IN { PARAM_VALUE.C_MAP_IN } {
	# Procedure called to validate C_MAP_IN
	return true
}

proc update_PARAM_VALUE.C_MAP_OUT { PARAM_VALUE.C_MAP_OUT } {
	# Procedure called to update C_MAP_OUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MAP_OUT { PARAM_VALUE.C_MAP_OUT } {
	# Procedure called to validate C_MAP_OUT
	return true
}

proc update_PARAM_VALUE.C_MAP_WIDTH { PARAM_VALUE.C_MAP_WIDTH } {
	# Procedure called to update C_MAP_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_MAP_WIDTH { PARAM_VALUE.C_MAP_WIDTH } {
	# Procedure called to validate C_MAP_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_AXI_PROTOCOL { MODELPARAM_VALUE.C_AXI_PROTOCOL PARAM_VALUE.C_AXI_PROTOCOL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_PROTOCOL}] ${MODELPARAM_VALUE.C_AXI_PROTOCOL}
}

proc update_MODELPARAM_VALUE.C_MAP_WIDTH { MODELPARAM_VALUE.C_MAP_WIDTH PARAM_VALUE.C_MAP_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MAP_WIDTH}] ${MODELPARAM_VALUE.C_MAP_WIDTH}
}

proc update_MODELPARAM_VALUE.C_MAP_IN { MODELPARAM_VALUE.C_MAP_IN PARAM_VALUE.C_MAP_IN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MAP_IN}] ${MODELPARAM_VALUE.C_MAP_IN}
}

proc update_MODELPARAM_VALUE.C_MAP_OUT { MODELPARAM_VALUE.C_MAP_OUT PARAM_VALUE.C_MAP_OUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_MAP_OUT}] ${MODELPARAM_VALUE.C_MAP_OUT}
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

