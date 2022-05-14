namespace eval subDB {

proc _get_script_dir {} {
	
	set script_path [file normalize [info script]]
	set script_folder [file dirname $script_path]
	return $script_folder
}


proc _get_host_time_id {} {
	
	set host [ info host ]
	set systemtime [ clock seconds ]
	set datetime [ clock format $systemtime -format "_%Y%m%d_%H%M%S" ]
	return "${host}${datetime}"
}



### TODO: Account for Non-Project Batch mode!
### TODO: Allow to set path by parameter
### TODO: Lots of error checking :(
proc _establish_data_path {} {

	global env
	global ERRORINFO

	global db_subdir_EXTRACTED_COMPONENTS
	global db_subdir_CONFIG_FILE_TEMPLATE
	global db_subdir_BITSTREAM_CONFIG_FILES
	global db_subdir_INPUT_BITSTREAM
	global db_subdir_MMI_FILE
	global db_subdir_MEM_CONFIG_FILES
	global db_subdir_OUTPUT_BITSTREAMS

	if { [catch {current_project} result ] } {
		# no project open
		if { [ info exists env(DIVEBITS_PROJECT_PATH) ] } {
			set db_prj_path $env(DIVEBITS_PROJECT_PATH)
		} else {
			puts "ERROR: No project open and no DiveBits data path specified. Cannot run operation."
			return -code error
		}
	} else {
		# project open
		set vivado_prj_path [ get_property DIRECTORY [current_project] ]
		set db_data_file "${vivado_prj_path}/db_data.path"

		if { [ file exists $db_data_file ] } {
			# read db_data.path
			set file_id [open $db_data_file r]
			set file_data [read $file_id]
			close $file_id
			set file_lines [split $file_data "\n"]
			set db_prj_path [ lindex $file_lines 1 ]		;# get second line; first is comment
			set env(DIVEBITS_PROJECT_PATH) $db_prj_path

		} else {
			if { [ info exists env(DIVEBITS_PROJECT_PATH) ] } {
				set db_prj_path $env(DIVEBITS_PROJECT_PATH)
			} else {
				set db_prj_path "${vivado_prj_path}/DiveBits_data"
				set env(DIVEBITS_PROJECT_PATH) $db_prj_path
			}

			set file_id [open $db_data_file "w"]
			puts $file_id "# Location of DiveBits data for this Vivado project"
			puts $file_id $db_prj_path
			close $file_id

		}
	}
	
	file mkdir $db_prj_path
	file mkdir "${db_prj_path}/${db_subdir_EXTRACTED_COMPONENTS}"
	file mkdir "${db_prj_path}/${db_subdir_CONFIG_FILE_TEMPLATE}"
	file mkdir "${db_prj_path}/${db_subdir_BITSTREAM_CONFIG_FILES}"
	file mkdir "${db_prj_path}/${db_subdir_INPUT_BITSTREAM}"
	file mkdir "${db_prj_path}/${db_subdir_MMI_FILE}"
	file mkdir "${db_prj_path}/${db_subdir_MEM_CONFIG_FILES}"
	file mkdir "${db_prj_path}/${db_subdir_OUTPUT_BITSTREAMS}"
}


proc _open_block_diagram {} {

	### TODO allow specifying BD path

	set design_fileset [ lindex [ get_filesets -filter { FILESET_TYPE == DesignSrcs } ] 0 ]
	set block_design_paths [ get_files -of_objects $design_fileset -filter { FILE_TYPE == "Block Designs" } ]

	set min_path_depth 10000
	foreach bd_path $block_design_paths {
		# TODO handle forwards slashes in Windows
		set path_depth [expr {[llength [split $bd_path "/"]] - 1}]
		if { $path_depth < $min_path_depth } {
			set min_path_depth $path_depth
			set block_design_path $bd_path
		}
	}
	puts "Top BD path is $block_design_path"
	
	open_bd_design $block_design_path
}


proc _elaborate_rtl {} {

	set design_fileset [ lindex [ get_filesets -filter { FILESET_TYPE == DesignSrcs } ] 0 ]

	set RTL_SUCCESS [synth_design -rtl -rtl_skip_ip -name rtl_1]
	puts "RTL Analysis output: ${RTL_SUCCESS}"
}


proc _extract_block_diagram_components {} {

	global env
	global db_subdir_EXTRACTED_COMPONENTS

	set blocklist [ get_bd_cells -hierarchical ]

	## identify config block, extract data and and remove from block list
	foreach block $blocklist {
			set DB_ADDRESS [ get_property CONFIG.DB_ADDRESS [ get_bd_cells $block ] ]
			if { $DB_ADDRESS == 0 } {
				set config_block $block
				set blocklist [ lsearch -all -inline -not -exact $blocklist $config_block ]
				set configname [ get_property NAME [ get_bd_cells $block ] ]
				set configpath [ get_property PATH [ get_bd_cells $block ] ]
				set BRAMcount [ get_property CONFIG.DB_NUM_OF_32K_ROMS [ get_bd_cells $block ] ]
			}
		}
	### TODO check that there's exactly 1 config block

	set yamlpath "${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_EXTRACTED_COMPONENTS}/db_components.yaml"
	set yamlfile [open $yamlpath w]

	# extract config block data
	set hosttime_id [ subDB::_get_host_time_id ]
	puts $yamlfile "Hosttime_ID: $hosttime_id"
	puts $yamlfile "db_config_block:"
	puts $yamlfile "  BLOCK_PATH: $configpath"

	## output all DB_* properties
	set PROPLIST [ list_property $config_block ]
	set PROPLIST [ lsearch -all -inline -glob $PROPLIST "CONFIG.DB*" ]
	foreach prop $PROPLIST {
			set propval [ get_property $prop [ get_bd_cells $config_block ] ]
			set prop [ string range $prop 7 [ string length $prop ] ]
			puts $yamlfile "  $prop: $propval"
		}
	puts $yamlfile ""

	
	
	## remove non-divebits components
	foreach block $blocklist {
			set DB_ADDRESS [ get_property CONFIG.DB_ADDRESS [ get_bd_cells $block ] ]
			if { [ string length $DB_ADDRESS ] == 0 } {

				set blocklist [ lsearch -all -inline -not -exact $blocklist $block ]
			}
		}


		
	## Make sure each DB_ADDRESS is only used once
	# Get DB addresses into list
	set db_addr_list []
	foreach block $blocklist { lappend db_addr_list [ get_property CONFIG.DB_ADDRESS $block ] }

	if { [ llength $db_addr_list ] != [ llength $blocklist ] } {
		puts "ERROR: Incorrect number of Divebits component addresses"
		return 0
	}
	
	
	set new_addr_iterator 1
	
	for {set i 0} {$i < [ llength $db_addr_list ] } {incr i} {
		
		set db_addr [ lindex $db_addr_list $i ]
		set curr_pos [ lsearch $db_addr_list $db_addr ]
		set next_pos [ lsearch -start $curr_pos+1   $db_addr_list $db_addr ]
		
		# if number turns up again change second iteration
		if { $next_pos != -1} {
			# find new number not in the list yet
			while { [ lsearch $db_addr_list $new_addr_iterator ] != -1} { incr new_addr_iterator }
			# change in block properties
			set_property CONFIG.DB_ADDRESS $new_addr_iterator [ lindex $blocklist $next_pos ]
			# change in address list			
			lset db_addr_list $next_pos $new_addr_iterator
		}
		
	}
	### TODO check user authorization? Validate? Only do when double numbers are there?
	save_bd_design
		

	# start component list
	puts $yamlfile "db_components:"

	## output all DB_* properties
	foreach block $blocklist {
			set compname [ get_property NAME [ get_bd_cells $block ] ]
			set comppath [ get_property PATH [ get_bd_cells $block ] ]
			puts $yamlfile "  - BLOCK_PATH: $comppath"
			
			set PROPLIST [ list_property  $block ]
			set PROPLIST [ lsearch -all -inline -glob $PROPLIST "CONFIG.DB*" ]
			foreach prop $PROPLIST {
					set propval [ get_property $prop [ get_bd_cells $block ] ]
					set prop [ string range $prop 7 [ string length $prop ] ]
					puts $yamlfile "    $prop: $propval"
				}
			puts $yamlfile ""
		}
		
	# close and check-print YAML file
	close $yamlfile
	
	set return_vals "$configpath $BRAMcount"
	return $return_vals
}


proc _extract_rtl_components {} {

	global env
	global db_subdir_EXTRACTED_COMPONENTS

	set blocklist [ get_cells ]

	## identify config block, extract data and and remove from block list
	foreach block $blocklist {
			set DB_ADDRESS [ get_property DB_ADDRESS [ get_cells $block ] ]
			if { $DB_ADDRESS == 0 } {
				set config_block $block
				set blocklist [ lsearch -all -inline -not -exact $blocklist $config_block ]
				set configpath [ get_property NAME [ get_cells $block ] ]
				set BRAMcount [ get_property DB_NUM_OF_32K_ROMS [ get_cells $block ] ]
			}
		}
	### TODO check that there's exactly 1 config block

	set yamlpath "${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_EXTRACTED_COMPONENTS}/db_components.yaml"
	set yamlfile [open $yamlpath w]

	# extract config block data
	set hosttime_id [ subDB::_get_host_time_id ]
	puts $yamlfile "Hosttime_ID: $hosttime_id"
	puts $yamlfile "db_config_block:"
	puts $yamlfile "  BLOCK_PATH: $configpath"

	## output all DB_* properties
	set PROPLIST [ list_property $config_block ]
	set PROPLIST [ lsearch -all -inline -glob $PROPLIST "DB*" ]
	foreach prop $PROPLIST {
			set propval [ get_property $prop [ get_cells $config_block ] ]
			set prop [ string range $prop 0 [ string length $prop ] ]
			puts $yamlfile "  $prop: $propval"
		}
	puts $yamlfile ""

	
	
	## remove non-divebits components
	foreach block $blocklist {
			set DB_ADDRESS [ get_property DB_ADDRESS [ get_cells $block ] ]
			if { [ string length $DB_ADDRESS ] == 0 } {

				set blocklist [ lsearch -all -inline -not -exact $blocklist $block ]
			}
		}


		
	## Make sure each DB_ADDRESS is only used once
	# Get DB addresses into list
	set db_addr_list []
	foreach block $blocklist { lappend db_addr_list [ get_property DB_ADDRESS $block ] }

	if { [ llength $db_addr_list ] != [ llength $blocklist ] } {
		puts "ERROR: Incorrect number of Divebits component addresses"
		return 0
	}
	
	
	set new_addr_iterator 1

	for {set i 0} {$i < [ llength $db_addr_list ] } {incr i} {
		
		set db_addr [ lindex $db_addr_list $i ]
		set curr_pos [ lsearch $db_addr_list $db_addr ]
		set next_pos [ lsearch -start $curr_pos+1   $db_addr_list $db_addr ]
		
		# if number turns up again change second iteration
		if { $next_pos != -1} {

			# output list of addresses and break with error
			puts ""
			puts ""
			puts ""
			puts "ERROR: DiveBits address(es) used multiple times"
			puts ""
			puts "DB_ADDRESS \t Instance name"
			puts "---------- \t -------------"

			for {set j 0} {$j < [ llength $db_addr_list ] } {incr j} {

				set blockaddr [ lindex $db_addr_list $j ]
				set blockname [ lindex $blocklist $j ]
				puts "\t$blockaddr \t\t $blockname"
			}
			puts "---------- \t -------------"
			puts "In RTL design mode, the DB_ADDRESS generic has to be set by hand to unique numbers for each component"
			# close Elaborated RTL design
			close_design -quiet
			error "Aborted on identical DB_ADDRESS"

		}
		
	}

	# start component list
	puts $yamlfile "db_components:"

	## output all DB_* properties
	foreach block $blocklist {
			set comppath [ get_property NAME [ get_cells $block ] ]
			puts $yamlfile "  - BLOCK_PATH: $comppath"
			
			set PROPLIST [ list_property  $block ]
			set PROPLIST [ lsearch -all -inline -glob $PROPLIST "DB*" ]
			foreach prop $PROPLIST {
					set propval [ get_property $prop [ get_cells $block ] ]
					set prop [ string range $prop 0 [ string length $prop ] ]
					puts $yamlfile "    $prop: $propval"
				}
			puts $yamlfile ""
		}
		
	# close and check-print YAML file
	close $yamlfile
	
	set return_vals "$configpath $BRAMcount"
	return $return_vals
}


proc _install_python3_pyyaml { } {

	global env

	## save and clear Python path variables, so Python 2.x is out
	if { [ info exists env(PYTHONPATH) ] } {
		set PYTHONPATH_bak $env(PYTHONPATH)
		unset env(PYTHONPATH)
	}
	if { [ info exists env(PYTHONHOME) ] } {
		set PYTHONHOME_bak $env(PYTHONHOME)
		unset env(PYTHONHOME)
	}
	
	## run script
	set py_output [ exec python3 -m pip install pyyaml ]
	puts $py_output

	## restore path variables
	if { [ info exists env(PYTHONPATH_bak) ] } {
		set env(PYTHONPATH) $PYTHONPATH_bak 
	}

	if { [ info exists env(PYTHONHOME_bak) ] } {
		set env(PYTHONHOME) $PYTHONHOME_bak
	}
	
	return

}


proc _call_python3_script { py_script_path args } {

	global env

	## save and clear Python path variables, so Python 2.x is out
	if { [ info exists env(PYTHONPATH) ] } {
		set PYTHONPATH_bak $env(PYTHONPATH)
		unset env(PYTHONPATH)
	}
	if { [ info exists env(PYTHONHOME) ] } {
		set PYTHONHOME_bak $env(PYTHONHOME)
		unset env(PYTHONHOME)
	}
	set PATH_BAK $env(PATH)
	set env(PATH) [ regsub -all {python} $PATH_BAK nowrongpy ]
	
	## run script
	set py_output [ exec python3 $py_script_path $args ]
	puts $py_output

	set env(PATH) $PATH_BAK

	## restore path variables
	if { [ info exists env(PYTHONPATH_bak) ] } {
		set env(PYTHONPATH) $PYTHONPATH_bak 
	}

	if { [ info exists env(PYTHONHOME_bak) ] } {
		set env(PYTHONHOME) $PYTHONHOME_bak
	}
	
	return

}


proc _open_implementation {} {

	### TODO allow specifying implementation run - this takes first one
	set design_fileset [ lindex [ get_filesets -filter { FILESET_TYPE == DesignSrcs } ] 0 ]
	set implementation_run [ lindex [ get_runs -filter " IS_IMPLEMENTATION == true && SRCSET == ${design_fileset}" ] 0 ]
	### TODO check if there is one left
	set progress [ get_property PROGRESS [ get_runs $implementation_run ] ]
	if { $progress != "100%" } {
		puts "ERROR: Unfinished implementation run."
		return -code error
	}
	
	set needs_refresh [ get_property NEEDS_REFRESH [ get_runs $implementation_run ] ]
	if { $needs_refresh == 1 } {
		puts "ERROR: Implementation run not up-to-date."
		return -code error
	}
	
	open_run $implementation_run
	
	set impl_run_dir [ get_property DIRECTORY [ get_runs $implementation_run ] ]
	return $impl_run_dir
	
}


proc _extract_brams {} {

	# get all BRAMs in implementation
	set bmemlist [ get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ BMEM.*.* } ]
	
	set ramlist [ lsearch -all -inline $bmemlist *divebits_rom32k_gen_magic1701* ]
	if {  [ llength $ramlist ] == 0 } {
		puts "ERROR: No DiveBits config BRAMs found";
		return 0
	}
	set ramlist [ lsort $ramlist ]
	
	set loclist []
	set loclist_stripped []

	foreach ram $ramlist { lappend loclist [ get_property LOC $ram ] }
	foreach loc $loclist { lappend loclist_stripped [ string range $loc 7 [ string length $loc ]-1 ] }

	return $loclist_stripped
}


proc _generate_mmi_file { filepath loclist device } {

	set bram_count [llength $loclist]
	set mem_top [ expr (4096*$bram_count)-1 ]

	set mmifile [open $filepath w]
	puts $mmifile "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
	puts $mmifile ""
	puts $mmifile "<MemInfo Version=\"1\" Minor=\"6\">"
	puts $mmifile ""
	puts $mmifile "	<Processor Endianness=\"Little\" InstPath=\"divebits/config\">"
	
	
	puts $mmifile "		<AddressSpace Name=\"db_config_BRAMs\" Begin=\"0\" End=\"${mem_top}\">"
	puts $mmifile ""
	
	set first_word 0
	
	for { set i 0 } { $i < $bram_count } { incr i } {
		set loc [ lindex $loclist $i ]
		set last_word [ expr $first_word+1023 ]
	
		puts $mmifile "			<BusBlock>"
		puts $mmifile "				<BitLane MemType=\"RAMB36\" Placement=\"${loc}\">"
		puts $mmifile "					<DataWidth MSB=\"31\" LSB=\"0\"/>"
		puts $mmifile "						<AddressRange Begin=\"${first_word}\" End=\"${last_word}\"/>"
		puts $mmifile "					<Parity ON=\"false\" NumBits=\"0\"/>"
		puts $mmifile "				</BitLane>"
		puts $mmifile "			</BusBlock>"
		puts $mmifile ""
		set first_word [ expr $last_word+1 ]
		
	}
	
	puts $mmifile "		</AddressSpace>"
	puts $mmifile "	</Processor>"
	puts $mmifile ""
	puts $mmifile "	<Config>"
	puts $mmifile "		<Option Name=\"Part\" Val=\"${device}\"/>"
	puts $mmifile "	</Config>"

	puts $mmifile ""
	puts $mmifile "	<DRC>"
	puts $mmifile "		<Rule Name=\"RDADDRCHANGE\" Val=\"false\"/>"
	puts $mmifile "	</DRC>"
	puts $mmifile ""
	puts $mmifile "</MemInfo>"

	close $mmifile
}

}
# end of subDB namespace



proc DB_set_DiveBits_data_path { {data_path ""} } {

	global env

	if { $data_path == "" } {
		::subDB::_establish_data_path
	} else {
		set env(DIVEBITS_PROJECT_PATH) $data_path
		::subDB::_establish_data_path
	}
	puts "DiveBits data path set to $env(DIVEBITS_PROJECT_PATH)"
}


proc DB_0a_add_block_ip_repo { } {

	global db_toolpath
	
	set old_dir [ pwd ]
	
	set ip_repo_list [ get_property  ip_repo_paths  [current_project] ]

	cd $db_toolpath
	set db_repo_relative "../block_ip_xil/"
	set db_repo_absolute [ file normalize $db_repo_relative ]
	
	if {[ lsearch -exact $ip_repo_list $db_repo_absolute ] >= 0} {
		puts "DiveBits block IP repository is already included in project."
	} else {
		puts "Adding DiveBits block IP repository..."
		lappend ip_repo_list $db_repo_absolute
		set_property  ip_repo_paths $ip_repo_list [current_project]
		update_ip_catalog
	}
	
	cd $old_dir

}

proc DB_0b_add_rtl_ip_repo { } {

	global db_toolpath
	
	set old_dir [ pwd ]
	
	#set ip_repo_list [ get_property  ip_repo_paths  [current_project] ]

	cd $db_toolpath
	set db_repo_relative "../hdl_ip_xil/"
	add_files -norecurse $db_repo_relative
	
	cd $old_dir

}


proc DB_1a_block_component_extraction { } {

	global db_toolpath
	global env
	global db_subdir_EXTRACTED_COMPONENTS
	global db_subdir_CONFIG_FILE_TEMPLATE

	::subDB::_establish_data_path
	::subDB::_open_block_diagram
	set config_bram_info [ ::subDB::_extract_block_diagram_components ]
	
	::subDB::_call_python3_script "--version"
	::subDB::_call_python3_script \
				"${db_toolpath}/DB_extract.py" \
				"-x ${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_EXTRACTED_COMPONENTS}/" \
				"-t ${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_CONFIG_FILE_TEMPLATE}/"

	set CONFIG_BLOCK_PATH [ lindex $config_bram_info 0 ]
	set NUM_BRAMS [ lindex $config_bram_info 1 ]

	set python_tcl_file "${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_EXTRACTED_COMPONENTS}/set_bram_count.tcl"
	if { [ file exists $python_tcl_file ] } {
		source -notrace $python_tcl_file
	} else {
		puts "No Python-generated tcl file found..."
		set $REQUIRED_BRAMS $NUM_BRAMS
	}
	
	if { $REQUIRED_BRAMS != $NUM_BRAMS } {	
		puts "Setting DB_NUM_OF_32K_ROMS parameter to $REQUIRED_BRAMS..."
		set_property CONFIG.DB_NUM_OF_32K_ROMS $REQUIRED_BRAMS [ get_bd_cells $CONFIG_BLOCK_PATH ]
		save_bd_design
	} else {
		puts "DB_NUM_OF_32K_ROMS already correct size"
	}
	

	### TODO check success of each, add success/failure message
}


proc DB_1b_rtl_component_extraction { } {

	global db_toolpath
	global env
	global db_subdir_EXTRACTED_COMPONENTS
	global db_subdir_CONFIG_FILE_TEMPLATE

	::subDB::_establish_data_path
	::subDB::_elaborate_rtl
	set config_bram_info [ ::subDB::_extract_rtl_components ]
	
	::subDB::_call_python3_script "--version"
	::subDB::_call_python3_script \
				"${db_toolpath}/DB_extract.py" \
				"-x ${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_EXTRACTED_COMPONENTS}/" \
				"-t ${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_CONFIG_FILE_TEMPLATE}/"

	set CONFIG_BLOCK_PATH [ lindex $config_bram_info 0 ]
	set NUM_BRAMS [ lindex $config_bram_info 1 ]

	set python_tcl_file "${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_EXTRACTED_COMPONENTS}/set_bram_count.tcl"
	if { [ file exists $python_tcl_file ] } {
		source -notrace $python_tcl_file
	} else {
		puts "No Python-generated tcl file found..."
		set $REQUIRED_BRAMS $NUM_BRAMS
	}


	if { $REQUIRED_BRAMS != $NUM_BRAMS } {	


		puts ""
		puts ""
		puts ""
		puts "ERROR: DiveBits data storage requires ${REQUIRED_BRAMS} BlockRAMs"
		puts "       but the generic DB_NUM_OF_32K_ROMS ERROR of the"
		puts "       divebits_config  module is set to ${NUM_BRAMS}."
		puts ""
		puts "In RTL design mode, the DB_NUM_OF_32K_ROMS generic has to be specified"
		puts "by hand to values other than 1 (the default)"
		puts ""
		# close Elaborated RTL design
		close_design -quiet
		error "Aborted on incorrect generic  DB_NUM_OF_32K_ROMS  for  divebits_config"

	} else {
		puts "DB_NUM_OF_32K_ROMS already correct size"
	}

	# close Elaborated RTL design
	close_design -quiet

	### TODO check success of each, add success/failure message
}


proc DB_2_get_memory_data_and_bitstream { { special_path "" } } {

	global env
	global db_subdir_MMI_FILE
	global db_subdir_INPUT_BITSTREAM
	
	::subDB::_establish_data_path
	set impl_run_dir [ ::subDB::_open_implementation ]
	
	set ram_locs [ ::subDB::_extract_brams ]
	set project_device [ get_parts -of_objects [get_projects] ]
	
	::subDB::_generate_mmi_file "${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_MMI_FILE}/db_config_rams.mmi" $ram_locs $project_device

	if { $special_path ne "" } {
		if { [ file exists $special_path ] } {
			set bitstream_path $special_path
		} else {
			puts "ERROR: Specified bitstream does not exist."
			return -code error
		}
	} else {
		set bitstream_paths [ glob -nocomplain $impl_run_dir/*.bit ]
		set bitstream_path [ lindex $bitstream_paths 0 ]
	}

	if { [ file exists $bitstream_path ] } {
		file copy -force $bitstream_path "${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_INPUT_BITSTREAM}/input.bit"
		puts "INFO: Copied $bitstream_path to  /${db_subdir_INPUT_BITSTREAM}/  folder."
	} else {
		puts "ERROR: No bitstream available yet, have you run implementation/bitstream generation?"
		return -code error
	}
}


### TODO clean out mem and outbut bitstream dirs before generating new ones
proc DB_3_generate_bitstreams {} {

	global db_toolpath
	global env
	global db_subdir_INPUT_BITSTREAM
	global db_subdir_MMI_FILE
	global db_subdir_MEM_CONFIG_FILES
	global db_subdir_BITSTREAM_CONFIG_FILES
	global db_subdir_OUTPUT_BITSTREAMS
	global db_subdir_CONFIG_FILE_TEMPLATE
	global db_subdir_EXTRACTED_COMPONENTS

#set PREP_START_SECS [ clock seconds ]
	
	::subDB::_establish_data_path

	# clear old generated mem files
	set old_memfiles [glob -nocomplain "${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_MEM_CONFIG_FILES}/*.mem"]
	if { $old_memfiles != "" } {
		eval file delete $old_memfiles
	}
	
	::subDB::_call_python3_script \
				"${db_toolpath}/DB_generate.py" \
				"-x ${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_EXTRACTED_COMPONENTS}/" \
				"-c ${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_BITSTREAM_CONFIG_FILES}/" \
				"-m ${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_MEM_CONFIG_FILES}/"

#set PREP_STOP_SECS [ clock seconds ]
#set PREP_DIFF_SECS [ expr $PREP_STOP_SECS - $PREP_START_SECS ]
#puts "PREP START: $PREP_START_SECS - PREP STOP: $PREP_STOP_SECS  =  $PREP_DIFF_SECS secs"

	set memfiles [ glob -tails -nocomplain -directory "${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_MEM_CONFIG_FILES}" "*.mem" ]
	set memfiles [ lsort $memfiles ]
	
	set stripped_filenames []
	foreach memfile $memfiles {
		lappend stripped_filenames [ string range $memfile 0 end-4 ]
	}
	
	set bitstream_in "${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_INPUT_BITSTREAM}/input.bit"
	set mmifile "${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_MMI_FILE}/db_config_rams.mmi"
	
	set bitstream_in_size [ file size $bitstream_in ]

#set UM_START_SECS [ clock seconds ]
	
	# clear old generated bitstreams if present
	set old_bitfiles [glob -nocomplain "${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_OUTPUT_BITSTREAMS}/*.bit"]
	if { $old_bitfiles != "" } {
		eval file delete $old_bitfiles
	}

	# start updatemem in separate processes
	foreach filename $stripped_filenames {
	
		set memfile "${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_MEM_CONFIG_FILES}/${filename}.mem"
		set bitstream_out "${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_OUTPUT_BITSTREAMS}/${filename}.bit"
		
		set um_command "updatemem -force -meminfo $mmifile -bit $bitstream_in -data $memfile -proc divebits/config -out $bitstream_out"
		puts "EXECUTING updatemem -force -meminfo $mmifile -bit $bitstream_in -data $memfile -proc divebits/config -out $bitstream_out"
		set um_output [ exec updatemem -force -meminfo $mmifile -bit $bitstream_in -data $memfile -proc divebits/config -out $bitstream_out & ]
		puts $um_output
	}
	
	# wait until all bitstreams generated
	foreach filename $stripped_filenames {
	
		set bitstream_out "${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_OUTPUT_BITSTREAMS}/${filename}.bit"
		# exists
		while { 0 == [ file exists $bitstream_out ] } {
			unset -nocomplain WAITDONE ; after 1000 set WAITDONE 1 ; vwait WAITDONE
		}
		# has reached expected size
		
		while { $bitstream_in_size != [ file size $bitstream_out ] } {
			unset -nocomplain WAITDONE ; after 1000 set WAITDONE 1 ; vwait WAITDONE
			set bitstream_out_size [ file size $bitstream_out ]
		}
		# has no write lock
		while { 0 == [ file writable $bitstream_out ] } {
			unset -nocomplain WAITDONE ; after 1000 set WAITDONE 1 ; vwait WAITDONE
		}
	}

#set UM_STOP_SECS [ clock seconds ]
#set UM_DIFF_SECS [ expr $UM_STOP_SECS - $UM_START_SECS ]
#puts "UM START: $UM_START_SECS - UM STOP: $UM_STOP_SECS  =  $UM_DIFF_SECS secs"
	set num_bitstreams [ llength $stripped_filenames ]
	puts "**** Completion: $num_bitstreams diversified bitstreams generated. ****"

}


proc DB_PT_run_python3_config_generator { py_script_path args } {

	global db_toolpath
	global env
	global db_subdir_INPUT_BITSTREAM
	global db_subdir_MMI_FILE
	global db_subdir_MEM_CONFIG_FILES
	global db_subdir_BITSTREAM_CONFIG_FILES
	global db_subdir_OUTPUT_BITSTREAMS
	global db_subdir_CONFIG_FILE_TEMPLATE
	global db_subdir_EXTRACTED_COMPONENTS
	
	::subDB::_establish_data_path
	
	::subDB::_call_python3_script \
				"$py_script_path" \
				"-t ${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_CONFIG_FILE_TEMPLATE}/" \
				"-c ${env(DIVEBITS_PROJECT_PATH)}/${db_subdir_BITSTREAM_CONFIG_FILES}/" \
				"$args"

}


proc DB_HELP {} {

	global message

	set message "\n" ; append message "\n" ; append message "\n" ; append message "\n"
	append message "*****************************************************************************************" ; append message "\n"
	append message "**** DiveBits tools - function overview: ************************************************" ; append message "\n"
	append message "" ; append message "\n"
	append message " call  DB_set_DiveBits_data_path \$DATA_PATH           to specify DB data location        " ; append message "\n"
	append message "" ; append message "\n"
	append message " call  DB_0a_add_block_ip_repo                        to add DiveBits IP repository      " ; append message "\n"
	append message "" ; append message "\n"
	append message " call  DB_0b_add_rtl_ip_repo                          to add DiveBits RTL to project     " ; append message "\n"
	append message "" ; append message "\n"
	append message " call  DB_1a_block_component_extraction               after block design is finished     " ; append message "\n"
	append message "" ; append message "\n"
	append message " call  DB_1b_rtl_component_extraction                 after HDL design is finished       " ; append message "\n"
	append message "" ; append message "\n"
	append message " call  DB_2_get_memory_data_and_bitstream \$BIT_PATH   after implementation               " ; append message "\n"
	append message "          (\$bit_path  only needs to specified                                            " ; append message "\n"
	append message "           when another tool (e.g. Vitis, SDK) has                                       " ; append message "\n"
	append message "           modified the bitstream post-implementation)                                   " ; append message "\n"
	append message "" ; append message "\n"
	append message " call  DB_PT_run_python3_config_generator \$SCRIPT     to make config files               " ; append message "\n"
	append message "" ; append message "\n"
	append message " call  DB_3_generate_bitstreams                       to make diversified bitstreams     " ; append message "\n"
	append message "" ; append message "\n"
	append message " call  DB_HELP                                        for this list                      " ; append message "\n"
	append message "*****************************************************************************************" ; append message "\n"

}


### TODO: IS THERE MORE THAN CAN BE MOVED INTO PYTHON (portability?) Calling Xilinx-specific Tcl stuff from Python?
global db_toolpath

set db_toolpath [ ::subDB::_get_script_dir ]
#::subDB::_install_python3_pyyaml

global db_subdir_EXTRACTED_COMPONENTS
global db_subdir_CONFIG_FILE_TEMPLATE
global db_subdir_BITSTREAM_CONFIG_FILES
global db_subdir_INPUT_BITSTREAM
global db_subdir_MMI_FILE
global db_subdir_MEM_CONFIG_FILES
global db_subdir_OUTPUT_BITSTREAMS

set db_subdir_EXTRACTED_COMPONENTS "1_extracted_components"
set db_subdir_CONFIG_FILE_TEMPLATE "2_config_file_template"
set db_subdir_BITSTREAM_CONFIG_FILES "3_bitstream_config_files"
set db_subdir_INPUT_BITSTREAM "4_input_bitstream"
set db_subdir_MMI_FILE "5_mmi_file"
set db_subdir_MEM_CONFIG_FILES "6_mem_config_files"
set db_subdir_OUTPUT_BITSTREAMS "7_output_bitstreams"

DB_HELP
