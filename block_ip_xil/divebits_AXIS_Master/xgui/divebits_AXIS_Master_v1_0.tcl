
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/divebits_AXIS_Master_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DB_DAISY_CHAIN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_ADDRESS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DB_DATA_WIDTH" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "DB_NUM_DATA_WORDS" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "C_M00_AXIS_TDATA_WIDTH" -parent ${Page_0}
  #Adding Group
  set Local_release [ipgui::add_group $IPINST -name "Local release" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "DB_LOCAL_RELEASE" -parent ${Local_release}
  ipgui::add_param $IPINST -name "DB_RELEASE_HIGH_ACTIVE" -parent ${Local_release}
  ipgui::add_param $IPINST -name "DB_RELEASE_DELAY_CYCLES" -parent ${Local_release}



}

proc update_PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH { PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH PARAM_VALUE.DB_DATA_WIDTH } {
	# Procedure called to update C_M00_AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
	
	set C_M00_AXIS_TDATA_WIDTH ${PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH}
	set DB_DATA_WIDTH ${PARAM_VALUE.DB_DATA_WIDTH}
	set values(DB_DATA_WIDTH) [get_property value $DB_DATA_WIDTH]
	set_property value [gen_USERPARAMETER_C_M00_AXIS_TDATA_WIDTH_VALUE $values(DB_DATA_WIDTH)] $C_M00_AXIS_TDATA_WIDTH
}

proc validate_PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH { PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH } {
	# Procedure called to validate C_M00_AXIS_TDATA_WIDTH
	return true
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

proc update_PARAM_VALUE.DB_DATA_WIDTH { PARAM_VALUE.DB_DATA_WIDTH } {
	# Procedure called to update DB_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_DATA_WIDTH { PARAM_VALUE.DB_DATA_WIDTH } {
	# Procedure called to validate DB_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.DB_LOCAL_RELEASE { PARAM_VALUE.DB_LOCAL_RELEASE } {
	# Procedure called to update DB_LOCAL_RELEASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_LOCAL_RELEASE { PARAM_VALUE.DB_LOCAL_RELEASE } {
	# Procedure called to validate DB_LOCAL_RELEASE
	return true
}

proc update_PARAM_VALUE.DB_NUM_DATA_WORDS { PARAM_VALUE.DB_NUM_DATA_WORDS } {
	# Procedure called to update DB_NUM_DATA_WORDS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DB_NUM_DATA_WORDS { PARAM_VALUE.DB_NUM_DATA_WORDS } {
	# Procedure called to validate DB_NUM_DATA_WORDS
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


proc update_MODELPARAM_VALUE.C_M00_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_M00_AXIS_TDATA_WIDTH PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M00_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_M00_AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.DB_ADDRESS { MODELPARAM_VALUE.DB_ADDRESS PARAM_VALUE.DB_ADDRESS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_ADDRESS}] ${MODELPARAM_VALUE.DB_ADDRESS}
}

proc update_MODELPARAM_VALUE.DB_TYPE { MODELPARAM_VALUE.DB_TYPE PARAM_VALUE.DB_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_TYPE}] ${MODELPARAM_VALUE.DB_TYPE}
}

proc update_MODELPARAM_VALUE.DB_NUM_DATA_WORDS { MODELPARAM_VALUE.DB_NUM_DATA_WORDS PARAM_VALUE.DB_NUM_DATA_WORDS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_NUM_DATA_WORDS}] ${MODELPARAM_VALUE.DB_NUM_DATA_WORDS}
}

proc update_MODELPARAM_VALUE.DB_DATA_WIDTH { MODELPARAM_VALUE.DB_DATA_WIDTH PARAM_VALUE.DB_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DB_DATA_WIDTH}] ${MODELPARAM_VALUE.DB_DATA_WIDTH}
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

