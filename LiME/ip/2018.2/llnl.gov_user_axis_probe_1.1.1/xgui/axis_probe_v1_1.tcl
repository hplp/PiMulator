# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_AXIS_CTL_TDATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXIS_CTL_TDEST_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXIS_CTL_TID_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXIS_CTL_TUSER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXIS_DAT_TDATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXIS_DAT_TDEST_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXIS_DAT_TID_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_CTL_IS_ASYNC" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_AXIS_CTL_TDATA_WIDTH { PARAM_VALUE.C_AXIS_CTL_TDATA_WIDTH } {
	# Procedure called to update C_AXIS_CTL_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_CTL_TDATA_WIDTH { PARAM_VALUE.C_AXIS_CTL_TDATA_WIDTH } {
	# Procedure called to validate C_AXIS_CTL_TDATA_WIDTH
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

proc update_PARAM_VALUE.C_AXIS_CTL_TUSER_WIDTH { PARAM_VALUE.C_AXIS_CTL_TUSER_WIDTH } {
	# Procedure called to update C_AXIS_CTL_TUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_CTL_TUSER_WIDTH { PARAM_VALUE.C_AXIS_CTL_TUSER_WIDTH } {
	# Procedure called to validate C_AXIS_CTL_TUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXIS_DAT_TDATA_WIDTH { PARAM_VALUE.C_AXIS_DAT_TDATA_WIDTH } {
	# Procedure called to update C_AXIS_DAT_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXIS_DAT_TDATA_WIDTH { PARAM_VALUE.C_AXIS_DAT_TDATA_WIDTH } {
	# Procedure called to validate C_AXIS_DAT_TDATA_WIDTH
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

