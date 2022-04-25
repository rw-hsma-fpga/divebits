# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DB_DAISY_CHAIN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_ADDRESS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_VECTOR_WIDTH" -parent ${Page_0}
  set DB_DEFAULT_VALUE_ALL [ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_ALL" -parent ${Page_0}]
  set_property tooltip {Keep zero if you want set individual defaults, otherwise this is added} ${DB_DEFAULT_VALUE_ALL}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_00" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_01" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_03" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DEFAULT_VALUE_02" -parent ${Page_0}
  #Adding Group
  set Local_release [ipgui::add_group $IPINST -name "Local release" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "DB_LOCAL_RELEASE" -parent ${Local_release}
  ipgui::add_param $IPINST -name "DB_RELEASE_HIGH_ACTIVE" -parent ${Local_release}
  ipgui::add_param $IPINST -name "DB_RELEASE_DELAY_CYCLES" -parent ${Local_release}



}

proc update_PARAM_VALUE.DB_ADDRESS { PARAM_VALUE.DB_ADDRESS } {
	# Procedure called to update DB_ADDRESS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_ADDRESS { PARAM_VALUE.DB_ADDRESS } {
	# Procedure called to validate DB_ADDRESS
	return true
}

proc update_PARAM_VALUE.DB_DAISY_CHAIN { PARAM_VALUE.DB_DAISY_CHAIN } {
	# Procedure called to update DB_DAISY_CHAIN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DAISY_CHAIN { PARAM_VALUE.DB_DAISY_CHAIN } {
	# Procedure called to validate DB_DAISY_CHAIN
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_00 { PARAM_VALUE.DB_DEFAULT_VALUE_00 } {
	# Procedure called to update DB_DEFAULT_VALUE_00 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_00 { PARAM_VALUE.DB_DEFAULT_VALUE_00 } {
	# Procedure called to validate DB_DEFAULT_VALUE_00
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_01 { PARAM_VALUE.DB_DEFAULT_VALUE_01 } {
	# Procedure called to update DB_DEFAULT_VALUE_01 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_01 { PARAM_VALUE.DB_DEFAULT_VALUE_01 } {
	# Procedure called to validate DB_DEFAULT_VALUE_01
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_02 { PARAM_VALUE.DB_DEFAULT_VALUE_02 } {
	# Procedure called to update DB_DEFAULT_VALUE_02 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_02 { PARAM_VALUE.DB_DEFAULT_VALUE_02 } {
	# Procedure called to validate DB_DEFAULT_VALUE_02
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_03 { PARAM_VALUE.DB_DEFAULT_VALUE_03 } {
	# Procedure called to update DB_DEFAULT_VALUE_03 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_03 { PARAM_VALUE.DB_DEFAULT_VALUE_03 } {
	# Procedure called to validate DB_DEFAULT_VALUE_03
	return true
}

proc update_PARAM_VALUE.DB_DEFAULT_VALUE_ALL { PARAM_VALUE.DB_DEFAULT_VALUE_ALL } {
	# Procedure called to update DB_DEFAULT_VALUE_ALL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DEFAULT_VALUE_ALL { PARAM_VALUE.DB_DEFAULT_VALUE_ALL } {
	# Procedure called to validate DB_DEFAULT_VALUE_ALL
	return true
}

proc update_PARAM_VALUE.DB_LOCAL_RELEASE { PARAM_VALUE.DB_LOCAL_RELEASE } {
	# Procedure called to update DB_LOCAL_RELEASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_LOCAL_RELEASE { PARAM_VALUE.DB_LOCAL_RELEASE } {
	# Procedure called to validate DB_LOCAL_RELEASE
	return true
}

proc update_PARAM_VALUE.DB_RELEASE_DELAY_CYCLES { PARAM_VALUE.DB_RELEASE_DELAY_CYCLES } {
	# Procedure called to update DB_RELEASE_DELAY_CYCLES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_RELEASE_DELAY_CYCLES { PARAM_VALUE.DB_RELEASE_DELAY_CYCLES } {
	# Procedure called to validate DB_RELEASE_DELAY_CYCLES
	return true
}

proc update_PARAM_VALUE.DB_RELEASE_HIGH_ACTIVE { PARAM_VALUE.DB_RELEASE_HIGH_ACTIVE } {
	# Procedure called to update DB_RELEASE_HIGH_ACTIVE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_RELEASE_HIGH_ACTIVE { PARAM_VALUE.DB_RELEASE_HIGH_ACTIVE } {
	# Procedure called to validate DB_RELEASE_HIGH_ACTIVE
	return true
}

proc update_PARAM_VALUE.DB_TYPE { PARAM_VALUE.DB_TYPE } {
	# Procedure called to update DB_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_TYPE { PARAM_VALUE.DB_TYPE } {
	# Procedure called to validate DB_TYPE
	return true
}

proc update_PARAM_VALUE.DB_VECTOR_WIDTH { PARAM_VALUE.DB_VECTOR_WIDTH } {
	# Procedure called to update DB_VECTOR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_VECTOR_WIDTH { PARAM_VALUE.DB_VECTOR_WIDTH } {
	# Procedure called to validate DB_VECTOR_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.DB_ADDRESS { MODELPARAM_VALUE.DB_ADDRESS PARAM_VALUE.DB_ADDRESS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_ADDRESS}] ${MODELPARAM_VALUE.DB_ADDRESS}
}

proc update_MODELPARAM_VALUE.DB_TYPE { MODELPARAM_VALUE.DB_TYPE PARAM_VALUE.DB_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_TYPE}] ${MODELPARAM_VALUE.DB_TYPE}
}

proc update_MODELPARAM_VALUE.DB_VECTOR_WIDTH { MODELPARAM_VALUE.DB_VECTOR_WIDTH PARAM_VALUE.DB_VECTOR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_VECTOR_WIDTH}] ${MODELPARAM_VALUE.DB_VECTOR_WIDTH}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_ALL { MODELPARAM_VALUE.DB_DEFAULT_VALUE_ALL PARAM_VALUE.DB_DEFAULT_VALUE_ALL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_ALL}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_ALL}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_00 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_00 PARAM_VALUE.DB_DEFAULT_VALUE_00 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_00}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_00}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_01 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_01 PARAM_VALUE.DB_DEFAULT_VALUE_01 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_01}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_01}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_02 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_02 PARAM_VALUE.DB_DEFAULT_VALUE_02 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_02}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_02}
}

proc update_MODELPARAM_VALUE.DB_DEFAULT_VALUE_03 { MODELPARAM_VALUE.DB_DEFAULT_VALUE_03 PARAM_VALUE.DB_DEFAULT_VALUE_03 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DEFAULT_VALUE_03}] ${MODELPARAM_VALUE.DB_DEFAULT_VALUE_03}
}

proc update_MODELPARAM_VALUE.DB_DAISY_CHAIN { MODELPARAM_VALUE.DB_DAISY_CHAIN PARAM_VALUE.DB_DAISY_CHAIN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DAISY_CHAIN}] ${MODELPARAM_VALUE.DB_DAISY_CHAIN}
}

proc update_MODELPARAM_VALUE.DB_LOCAL_RELEASE { MODELPARAM_VALUE.DB_LOCAL_RELEASE PARAM_VALUE.DB_LOCAL_RELEASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_LOCAL_RELEASE}] ${MODELPARAM_VALUE.DB_LOCAL_RELEASE}
}

proc update_MODELPARAM_VALUE.DB_RELEASE_HIGH_ACTIVE { MODELPARAM_VALUE.DB_RELEASE_HIGH_ACTIVE PARAM_VALUE.DB_RELEASE_HIGH_ACTIVE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_RELEASE_HIGH_ACTIVE}] ${MODELPARAM_VALUE.DB_RELEASE_HIGH_ACTIVE}
}

proc update_MODELPARAM_VALUE.DB_RELEASE_DELAY_CYCLES { MODELPARAM_VALUE.DB_RELEASE_DELAY_CYCLES PARAM_VALUE.DB_RELEASE_DELAY_CYCLES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_RELEASE_DELAY_CYCLES}] ${MODELPARAM_VALUE.DB_RELEASE_DELAY_CYCLES}
}

