# Copyright (c) 2016 BMikhail Solutions
# Package for ElectricFlow preflight 

# Parser for array to get information about division. 
# Arguments:
# 			xmlArr - name of array with data from xml
# 			nName  - name of node : can be  Server, Scm or Procedures
# Return:
# 			no
# Result will be added to xmlArr(nName)
#
namespace eval ::preflight {
	variable xmlArr
	variable txtArr
}

proc getInformationByNodeName {xmlArr nName } {
	upvar #0 $xmlArr xmlarr 
    set obj_id [ $xmlarr(root) getElementsByTagName $nName ]
    set obj_child_list [$obj_id childNodes]
	set obj_pairs_list {}
	foreach item $obj_child_list {
		set nodeItem [$item childNodes] 
		if { [llength $nodeItem] == 1  &&  [ [lindex $nodeItem 0] nodeName] == "#text" } {
			lappend obj_pairs_list [$item nodeName] [ [lindex $nodeItem 0] nodeValue]
		} 
   }
	set xmlarr($nName) $obj_pairs_list
}

proc ::preflight::getScm    { name_gArr } { ::getInformationByNodeName $name_gArr scm   }
proc ::preflight::getServer { name_gArr } { ::getInformationByNodeName $name_gArr server}

# for a procedure we has enother structure 
proc ::preflight::getProcedure { name_gArr } {
	upvar #0 $name_gArr xmlarr 
	set obj_id [ $xmlarr(root) getElementsByTagName "procedure" ]
	set obj_child_list [$obj_id childNodes]
	set obj_procedure_list {}
	set obj_parametr_list {}
	# 
	foreach item $obj_child_list {
		set nodeItem [$item childNodes] 
		if { [llength $nodeItem] == 1  &&  [ [lindex $nodeItem 0] nodeName] == "#text" } {
			lappend obj_procedure_list [$item nodeName] [ [lindex $nodeItem 0] nodeValue]
		}
		if { [$item nodeName] == "parameter" } {
			set name  [ $item getElementsByTagName "name"  ]
			set value [ $item getElementsByTagName "value" ]
			lappend obj_parametr_list [ [$name childNodes] nodeValue ] [ [$value childNodes] nodeValue]
		}
   }
   set xmlarr(procedure) $obj_procedure_list 
   set xmlarr(procedure,parametr) $obj_parametr_list 
}

proc RunBuild {} {
	tk_messageBox -message "Here I going to run preflight"
}
proc SavePreflightFile {} {
	tk_messageBox -message "Save to file - if setting was changed"
	parray ::preflight::txtArr
}

# View procedure
# 	tk interactive pane
# 	View of xml document special format for preflight
# 	On View you can see or change fields - which can change setting for custom preflight

proc ::preflight::View { xml } {
	set w_topLevel .dialog_preflight
    catch { destroy $w_topLevel }
    toplevel $w_topLevel
    #set ::dialog::add_proj  "New"
    wm title $w_topLevel "preflight"
	#wm resizable $w_topLevel 0 0
    #wm geometry $w_topLevel +600+200
    wm resizable $w_topLevel 0 0
	::preflight::getPreflightStructure $xml
	#global xmlArr
	#global txtArr
	# frame container with white bg, for all frames
	set bottom_frame [frame  $w_topLevel.bottom -bg  white ]
	pack $bottom_frame  -fill x -side top -expand 1
	set scm_layer [labelframe $bottom_frame.scm -bg white -text scm -pady 2 -fg blue ]
	grid $scm_layer  
	# add fields with info for scm
	foreach {name value} $::preflight::xmlArr(scm) {
		set ::preflight::txtArr(scm$name) $value
		set label_a [label  $scm_layer.$name -text "$name" -bg white]
		#set $value $value
		set entry_a [entry  $scm_layer.$name$value -width 20 -relief sunken -textvariable ::preflight::txtArr(scm$name)  -width 60]
			grid $label_a $entry_a  
	}
	set server_layer [labelframe $bottom_frame.server -bg white -text server -pady 2 -fg blue ]
	grid $server_layer
	# add fields with info for server
	foreach {name value} $::preflight::xmlArr(server) {
		set ::preflight::txtArr(server$name) $value
		set label_a [label  $server_layer.$name -text "$name" -bg white]
		#set $value $value
		set entry_a [entry  $server_layer.$name$value -width 20 -relief sunken -textvariable ::preflight::txtArr(server$name) -width 59]
		if {  [string match $name "password"] } { $entry_a config -show *}
		grid $label_a $entry_a  
	}
	set procedure_layer [labelframe $bottom_frame.procedure -bg white -text procedure   -pady 2 -fg blue ]
	grid $procedure_layer
	foreach {name value} $::preflight::xmlArr(procedure) {
		set ::preflight::txtArr(proceduree$name) $value
		set label_a [label  $procedure_layer.$name -text "$name" -bg white ]
		#set $value $value
		set entry_a [entry  $procedure_layer.$name$value -width 20 -relief sunken -textvariable ::preflight::txtArr(proceduree$name) -width 45 ]
		grid $label_a $entry_a  
	}
	foreach {name value} $::preflight::xmlArr(procedure,parametr) {
		if { ($value == 1 ) || ($value == 0)} {
			continue
		}
		set ::preflight::txtArr(procedure_parametr$name) $value
		set label_a [label  $procedure_layer.$name -text "$name"  -bg white]
		set entry_a [entry  $procedure_layer.$name$value -width 20 -relief sunken -textvariable ::preflight::txtArr(procedure_parametr$name) -width 45]	
		grid $label_a $entry_a
	}
	foreach {name value} $::preflight::xmlArr(procedure,parametr) {
		if { ($value == 1 ) || ($value == 0)} {
			set ::preflight::txtArr(procedure_parametr$name) $value
			set label_a [label  $procedure_layer.$name -text "$name"  -bg white]
			set checkbox_a [checkbutton  $procedure_layer.$name$value -text "Choose for use option"  -variable ::preflight::txtArr(procedure_parametr$name) -bg white ]	
			grid $label_a $checkbox_a			
		} 
	}
	# buttons
	set buttons_layer [labelframe $bottom_frame.buttons -bg white -text "manage preflight"   -pady 2 -fg blue ]
	grid $buttons_layer -sticky ew
	set cancel_b [button  $buttons_layer.cancel_b -text "Cancel" -bg white -command "destroy $w_topLevel" ]
	set build_b  [button  $buttons_layer.build_b  -text "Build"  -bg white -command RunBuild ]
	set save_b   [button  $buttons_layer.save_b   -text "Save"   -bg white -command ::onevent::savePreflight ]
	grid $cancel_b $build_b $save_b  -padx 2
}

# save to XML 
proc SaveXML { {path {} } } {
}



#import - 
#	filename
#	return : text of xml file or 0 if was a problem 
proc  ::preflight::import { filename } {
	#tk_messageBox -message $filename
	#set file_name [lindex $::argv 0]
	if { [file exists $filename] } {
		set  fp [open $filename r ]
		fconfigure $fp -encoding utf-8
		set xml [read  $fp]
		close  $fp
		if { [llength $xml] > 0 } {
			return $xml
		} else {
			tk_messageBox -message "Seems file $filename is empty"
		}
	} else {
		tk_messageBox -message "There is no file $filename - please sure that path is correct or file exists."
		
	}
	return 0
}

#------------------------------------------------------------------------------------

# getPreflightStructure - procedure for reading xml in dom model and then  get information about every of nodes
# Arguments:
# 			xml  - text from xml file
# Return:
# 			no
# 
proc ::preflight::getPreflightStructure { xml } {
	if  { [catch { package require tdom }] } { 
		puts "There are no package  tdom. Exit."
		exit 1
	}
	# parcer for xml - create DOM on doc 
	dom parse  $xml doc
	# get root element for doc
	$doc documentElement root
	# work with data structure 
	array set ::preflight::xmlArr [ list doc $doc root $root ]
	::preflight::getScm       ::preflight::xmlArr
	::preflight::getServer    ::preflight::xmlArr
	::preflight::getProcedure ::preflight::xmlArr

}



