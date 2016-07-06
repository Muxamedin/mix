namespace eval ::onevent {
    
}
namespace eval ::onevent::treview {
    
}

proc ::onevent::test {hi} {
    puts "test"
}

#--------------------------------------------------------------------------------
# newFile - adding new file 
#           procedure for menu
#--------------------------------------------------------------------------------
proc ::onevent::newFile { } {
	tk_messageBox -message "This is empty procedure - soon it will be work "
}

#--------------------------------------------------------------------------------
# exitProc - exit from application using menu 
#           procedure for menu
#--------------------------------------------------------------------------------
proc ::onevent::exitProc {} {
   tk_messageBox -message "Thank you for using our app. You've choosed action for exit."   
   #here should be actions before exit - saving data , closing files
   exit
}

#--------------------------------------------------------------------------------
# planing - plans for user 
#           procedure for menu
#--------------------------------------------------------------------------------
proc ::onevent::planing { } {
	tk_messageBox -message "This is empty procedure - soon it will be work "
}

#--------------------------------------------------------------------------------
# RoadMap - creating maps with planing for future
#           procedure for menu
#--------------------------------------------------------------------------------
proc ::onevent::RoadMap { } {
	tk_messageBox -message "This is empty procedure - soon it will be work "
}

#--------------------------------------------------------------------------------
# includeDB - switch to another db
#           procedure for menu
#--------------------------------------------------------------------------------
proc ::onevent::includeDB { } {
	tk_messageBox -message "This is empty procedure - soon it will be work "
}

proc ::onevent::openFile { } {
	tk_messageBox -message "This is empty procedure - soon it will be work "
}

#--------------------------------------------------------------------------------
# newProject - you can add new name of project to database  
#           
#--------------------------------------------------------------------------------
proc ::onevent::newProject { } {
    ::dialog::add_proj "::dbase::db_add_project" 
}

proc ::onevent::merge_prj { } {
	tk_messageBox -message "This is empty procedure - soon it will be work. Merging projects "
}

proc ::onevent::dell_prj { } {
	tk_messageBox -message "This is empty procedure - soon it will be work . Delete Project from database"
}

proc ::onevent::login { } {
	tk_messageBox -message "This is empty procedure - soon it will be work . Login to the db"
}

proc ::onevent::sStatus { } {
	tk_messageBox -message "This is empty procedure - soon it will be work. Send status about daily progress. "
}

proc ::onevent::copy { } {
	tk_messageBox -message "This is empty procedure - soon it will be work "
}
proc ::onevent::cut { } {
	tk_messageBox -message "This is empty procedure - soon it will be work "
}
proc ::onevent::paste { } {
	tk_messageBox -message "This is empty procedure - soon it will be work "
}
proc ::onevent::dell { } {
	tk_messageBox -message "This is empty procedure - soon it will be work "
}
proc ::onevent::chooseLenguage { } {
	tk_messageBox -message "This is empty procedure - soon it will be work "
}
proc ::onevent::spellChecker { } {
	tk_messageBox -message "This is empty procedure - soon it will be work "
}
proc ::onevent::about { } {
    tk_messageBox -message "Tool for run  preflight for Electric Flow"
}
proc ::onevent::help { } {
    tk_messageBox -message " Hot keys :
     ctrl + a - select all
     ctrl + c - copy selected
     ctrl + v - insert from booffer
     ctrl + h - deletes string after curssor
     When you typing you can use  arrows\n  - Key-down go to listbox dictionary\n  - Key-left to choose from dictionary listbox
     Enter or Double-button-1 choose from list box by selected position "
}
proc ::onevent::editPreflight_xml {} {
    tk_messageBox -message "Eddition xml file "
}

proc ::onevent::runPreflight {} {
    tk_messageBox -message "Eddition xml file "
}


# addTaskToDb  -  add new task 
#         options_for_task - list with pairs for task 
#
proc ::onevent::addTaskToDb { options_for_task } {
    global config
    array set task_array $options_for_task
    #( NULL, $task(key) , $task(project) , $task(title) , $task(description) , $task(points) , $task(status_id) , $task(deadline) , $task(created_at), $task(edited_at))
    
    set prepare_array(title)   "$task_array(-title)"
    set prepare_array(project) [::dbase::get_projID_byName  $::config(dbPath) $task_array(-topic) ] 
    foreach itemDate { "-hours" "-mins" "-year" "-day_number"} {
        if {![ string is integer $task_array($itemDate) ]} {
            set task_array($itemDate) 0
        } 
    }
    set prepare_array(deadline) "$task_array(-month)/$task_array(-day_number)/$task_array(-year)-$task_array(-hours):$task_array(-mins)"
    set date [clock format [clock seconds] -format %D-%T ]
    set  prepare_array(created_at)  $date 
    set  prepare_array(edited_at)   $date
    set  prepare_array(key)   "Y"
    set prepare_array(description) ""
    #-title {Use Device  from Nokia} -topic {IoT Nokia} -year 2019 -month July -day_number 18 -mins 9 -hours 1
     #NULL, $task(key) , $task(project) , $task(title) , $task(description) , $task(points) , $task(status_id) , $task(deadline) , $task(created_at), $task(edited_at))
    ::dbase::db_store_task $config(dbPath) [array get prepare_array]
    
}

proc ::onevent::treeClick { args } {
 #tk_messageBox -message $args
 set tree $args
 tk_messageBox -message [$tree  selection]
 #set a  [ [lindex $args 0] identify component  [lindex $args 1]  [lindex $args 2]  ]
}

# chooseTemplate 
#           when you will choose from menu which report do you want to see - you will get text template special for your choice
#           
proc ::onevent::chooseTemplate { temlatenumber } {
	global frameText
	global debug_console 	 ; # консоль выполнения действий
    
	set date(start) [clock seconds]
	set date(date) [clock format $date(start) -format %D]
	set date(time24) [clock format $date(start) -format %H]
	set date(dayY) [clock format $date(start) -format %j]
	set date(nMonth) [clock format $date(start) -format %m]
	set date(time) [clock format $date(start) -format %T]
	set date(nWeek) [clock format $date(start) -format %W]
	set date(nDayWeek) [clock format $date(start) -format %u]
	set date(year) [clock format $date(start) -format %Y]
	set date(workDOrNot) work
	$frameText  delete 1.0 end  ; # clear text pane
	$debug_console delete 1.0 end  ; # clear console pane
    #$debug_console insert insert 
			#tk_messageBox -message "temlatenumber=$temlatenumber"
	if { $temlatenumber == 1 || $temlatenumber == 5 } {
			$debug_console insert insert "\[$date(time24)\] -> Chose: Daily \n"		    
			$frameText insert insert "--------------------------------------------------------------------------------\n"
			$frameText insert insert "$date(dayY) (d/y) - $date(nWeek) (w/y)\n$date(date)\n\t\t\t Daily report:\nCompleted:\n\t1) ...\n\nInProgress:\n\nProblems:  \n"
            $frameText insert insert    "--------------------------------------------------------------------------------\n"
	}
	if { $temlatenumber == 2 || $temlatenumber == 5 } {
			$debug_console insert insert "\[$date(time24)\] -> Chose: Weekly \n"
			$frameText insert insert    "--------------------------------------------------------------------------------\n"
			$frameText insert insert "$date(dayY) (d/y) - $date(nWeek) (w/y)\n$date(date)\n\t\t\t Weekly Plans:\nCompleted:\n\t1) ...\n\nInProgress:\n\nProblems:  \n"
            $frameText insert insert    "--------------------------------------------------------------------------------\n"
	}
	if { $temlatenumber == 3 || $temlatenumber == 5} {
            $debug_console insert insert   "\[$date(time24)\] -> Chose: Plans Weekly \n"
			$frameText insert insert "--------------------------------------------------------------------------------\n"
			$frameText insert insert "$date(nDayWeek).w - $date(nMonth).m $date(year).y\n\t\t\t Week plans: \n\t\t\n\n\t Task 1) ... priority (P0) ... subscription ... {}     \n\nInProgress from previous week:\n\nProblems:  \n"
            $frameText insert insert    "--------------------------------------------------------------------------------\n"
	}
	if { $temlatenumber == 4 || $temlatenumber == 5} {
            $debug_console insert insert   	"\[$date(time24)\] -> Chose: Plans \n"
			$frameText insert insert "--------------------------------------------------------------------------------\n"
			$frameText insert insert "$date(nMonth).m $date(year).y\n\t\t\tMonth plans:\n\nCompleted:\n\t1) ...\n\nInProgress:\n\nProblems:  \n"
            $frameText insert insert    "--------------------------------------------------------------------------------\n"
	}
		
		
}
##@@TreeView events
#---------------------------------------------------------
## Press -- ButtonPress binding.
#
proc ::onevent::treview::Press {w x y} {
    focus $w
    switch -- [$w identify region $x $y] {
	nothing { }
	heading { ttk::treeview::heading.press $w $x $y
        #tk_messageBox -message "heading"
    }
	separator { #ttk::treeview::resize.press $w $x $y
        #tk_messageBox -message "separator"
    }
	tree -
	cell {
	    set item [$w identify item $x $y]
        #tk_messageBox -message $item 
	    ttk::treeview::SelectOp $w $item choose
	    switch -glob -- [$w identify element $x $y] {
		*indicator { }
		*disclosure { ttk::treeview::Toggle $w $item    }
	    }
	}
    }
}


proc ::onevent::preflightUpdate {  } {
    global envar config
    set tree $envar(widg,tree)
    set scm  [ $tree insert TPreflight end -text SCM  -tags "node" -values [list "" "Scm configurations" "" "" "" "" ""] ]
    #tk_messageBox -message [::dbase::db_get_scm $config(dbPath)]
    foreach { id  name  type client port user template} [::dbase::db_get_scm $config(dbPath)]   {
        set inf "name $name,  type $type, client $client,  port $port, user $user, template $template"
        set taginfo "info: $inf"
        $tree insert $scm end -text $name  -tags "$taginfo scmcolor" -values [list "" "$inf" "$id" "$type" "" "" ""] 
    }
    #$tree  insert $scm end -text "???"  -tags "" -values [list "" "Scm configurations" "" "" "" "" ""] 
    set server     [ $tree insert TPreflight end -text SERVER  -tags "node" -values [list "" "Server configurations" "" "" "" "" ""] ]
    foreach { id hostName userName password } [::dbase::db_get_from $config(dbPath)  server]   {
        set inf "name $id,  id $id hostName $hostName userName  $userName password $password"
        set taginfo "info: $inf"
        $tree insert $server end -text $id  -tags "$taginfo servercolor" -values [list "" "$inf" "$hostName" "" "" "" ""] 
    }
     
    set procedures [ $tree insert TPreflight end -text PROCEDURES  -tags "node" -values [list "" "Procedures" "" "" "" "" ""] ]
    foreach { id  procedure} [::dbase::db_get_procedure $config(dbPath)]   {
        set inf "name $id, procedure $procedure  "
        set taginfo "info: $inf"
        $tree insert $procedures end -text $id  -tags "$taginfo procedurescolor" -values [list "" "$inf" "" "" "" "" ""] 
    }
    
    $tree tag configure scmcolor -background #C6DEFF
    $tree tag configure procedurescolor -background #C6DEFF
}  
    
proc ::onevent::tree_history_fill { lst } {
    global envar config
    if { [ llength $lst ] } {
        set tree $envar(widg,tree)
        set i 0
        foreach {id key project title  description points status_id deadline created_at edited_at } $lst {
            if { [expr $i % 2]  } {
                set ttk "ttk"
                
            } else {
                set ttk "ttks"
            }
            incr i
            set child [  $tree insert History end  -text $title  -tags "$ttk task$id" -values [list [ ::dbase::get_projname_byID  $::config(dbPath) $project] $description "" "$created_at" "" "$status_id" "$deadline"] ]
            set child1 [  $tree insert $child end  -text Actions  -tags "$ttk task$id Actions" ]
           
           #bind $tree.History.$child <Any-Key> { ::onevent::treeClick [list %W %x %y %X %Y ]}
           #$tree tag bind History $child { ::onevent::treeClick  [list %W %x %y %X %Y ] }
        }
        $tree focus $child
        $tree tag configure ttk -background #FFFACD
        $tree tag configure ttks -background #F0FFF0
        $tree tag configure "task2"  -foreground  blue
        #$tree tag bind ttk <1> { tk_messageBox -message %W ; tk_messageBox -message [ %W focus]   }; # the item clicked can be found via [.tree focus]
    } 
    
}
# importPreflight -
#   path2File
proc ::onevent::importPreflight {} {
    set path2File [ tk_getOpenFile -title "getting preflight file" -defaultextension ".preflight" ]
    set xml [::preflight::import $path2File ]
    if { $xml ne 0 } {
        set ::gEvent(consoledebug) "$path2File - not empty. Started editing of file."
        ::preflight::View $xml
        set ::gEvent(consoledebug) "Done ...."
        
    } else {
        set ::gEvent(consoledebug) "Error: empty  preflight xml file, $path2File. "
    }
	
}

# importPreflight -
#   path2File
proc ::onevent::savePreflight {} {
       #parray ::preflight::txtArr
        set ::gEvent(consoledebug) "Preflight information: \n - [array get ::preflight::txtArr]"
        foreach item [ array get ::preflight::txtArr ] {
            set item2 $item
            if { [regexp {^scm(.+)$} $item match re ]} {
                
                lappend scm  $re $::preflight::txtArr($item)
            }
            if { [regexp {^procedure_parametr(.+)$} $item match re ] } {
                lappend procedure_parametr $re $::preflight::txtArr($item)
            }
            if { [regexp {^proceduree(.+)$} $item match re ]} {
                lappend procedure $re $::preflight::txtArr($item)
            }
            if { [regexp {^server(.+)$} $item match re ]} {
                lappend server $re $::preflight::txtArr($item)
            }
        }
        #tk_messageBox -message "$server $scm $procedure_parametr $procedure"
        
        lappend xmltext "<?xml version=\"1.0\" encoding=\"utf-8\"?> \n <data>"  
        lappend xmltext  "<server>"
        foreach {key value}  $server     {
            lappend xmltext  "<$key>$value</$key>"
        }   
        lappend xmltext  "</server>"
        lappend xmltext  "<procedure>"
        foreach {key value}  $procedure     {
            lappend xmltext  "<$key>$value</$key>"
        }
        foreach {key value}  $procedure_parametr     {
            lappend xmltext  "<parameter>
                        <name>$key</name>
                        <value>$value</value>
            </parameter>"
        }   
        lappend xmltext  "</procedure>"
        lappend xmltext  "<scm>"
        foreach {key value}  $scm     {
            lappend xmltext  "<$key>$value</$key>"
        }   
        lappend xmltext  "</scm>"
        lappend xmltext  "</data>"
        set xmltextresult [join $xmltext \n ]
        tk_messageBox -message  $xmltextresult
        set ::gEvent(preflight) $xmltextresult
        
}


# importPreflight -
#   path2File
proc ::onevent::buildPreflight {} {
       #parray ::preflight::txtArr
       #
       #
       #
       set path2File [ tk_getOpenFile -title "getting preflight file" -defaultextension ".preflight" ]
       catch { eval  [list exec "C:\\cygwin\\usr\\local\\tools\\i686_win32\\bin\\ecclientpreflight.exe" "--p4changelist" "124820"  "-c" "$path2File"] } status
        tk_messageBox -message  $status             
       
}


proc d {} {
    
    
       if {![llength [array get ::preflight::txtArr] ] }  {
          
       
        set ::gEvent(consoledebug) "Preflight information: \n - [array get ::preflight::txtArr]"
        foreach item [ array get ::preflight::txtArr ] {
            set item2 $item
            if { [regexp {^scm(.+)$} $item match re ]} {
                
                lappend scm  $re $::preflight::txtArr($item)
            }
            if { [regexp {^procedure_parametr(.+)$} $item match re ] } {
                lappend procedure_parametr $re $::preflight::txtArr($item)
            }
            if { [regexp {^proceduree(.+)$} $item match re ]} {
                lappend procedure $re $::preflight::txtArr($item)
            }
            if { [regexp {^server(.+)$} $item match re ]} {
                lappend server $re $::preflight::txtArr($item)
            }
        }
        #tk_messageBox -message "$server $scm $procedure_parametr $procedure"
        
        lappend xmltext "<?xml version=\"1.0\" encoding=\"utf-8\"?> \n <data>"  
        lappend xmltext  "<server>"
        foreach {key value}  $server     {
            lappend xmltext  "<$key>$value</$key>"
        }   
        lappend xmltext  "</server>"
        lappend xmltext  "<procedure>"
        foreach {key value}  $procedure     {
            lappend xmltext  "<$key>$value</$key>"
        }
        foreach {key value}  $procedure_parametr     {
            lappend xmltext  "<parameter>
                        <name>$key</name>
                        <value>$value</value>
            </parameter>"
        }   
        lappend xmltext  "</procedure>"
        lappend xmltext  "<scm>"
        foreach {key value}  $scm     {
            lappend xmltext  "<$key>$value</$key>"
        }   
        lappend xmltext  "</scm>"
        lappend xmltext  "</data>"
        set xmltextresult [join $xmltext \n ]
        catch { eval  "exec C:\\cygwin\\usr\\local\\tools\\i686_win32\\bin\\ecclientpreflight.exe --p4changelist 124820  -c $xmltextresult" } status
         tk_messageBox -message $status 
        } else {
            tk_messageBox -message "No preflight file "
        }
        
       
        #tk_messageBox -message  $xmltextresult
        #set ::gEvent(preflight) $xmltextresult
}