# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"


}

proc update_PARAM_VALUE.ITERATION_COUNT { PARAM_VALUE.ITERATION_COUNT } {
	# Procedure called to update ITERATION_COUNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ITERATION_COUNT { PARAM_VALUE.ITERATION_COUNT } {
	# Procedure called to validate ITERATION_COUNT
	return true
}


proc update_MODELPARAM_VALUE.ITERATION_COUNT { MODELPARAM_VALUE.ITERATION_COUNT PARAM_VALUE.ITERATION_COUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ITERATION_COUNT}] ${MODELPARAM_VALUE.ITERATION_COUNT}
}

