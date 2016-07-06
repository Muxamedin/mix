namespace eval ::generator {
}

namespace eval ::dialog {
    variable add_task
    variable add_proj
}    


# ::dialog::init_arr_addtask  - presetting data for for add task dialog
#       
proc ::dialog::init_arr_addtask {} {
    global config
    array set ::dialog::add_task {
        day_number 1
        remind  "Never"
        hours   "hours"
        mins    "minutes"
        month   "January"
        lremind { "Once" "Dayly" "Weekly" "Monthly" "Never"}
        topic_var "New"
        wyear     ""
        handleCalendar ""
        choosed_day 1
        
    }
    set ::dialog::add_task(topic_lst)  [ ::dbase::db_get_taskgroup $config(dbPath)]
    #set ::dialog::add_task(month)   "January"
}

# addTask - dialog for adding task
#    creates window for user and should add information to db about new created task
#    no arguments
#           
proc ::dialog::addTask { } {
    ::dialog::init_arr_addtask
    set w_topLevel .dialogwindow
    catch {destroy $w_topLevel }
    toplevel $w_topLevel
    wm title $w_topLevel "Add task"
    #wm iconname $w_topLevel "unicodeout"

    # expected size of window  400x300    !!!
    wm minsize $w_topLevel 400 300
    wm resizable $w_topLevel 0 0
    wm geometry $w_topLevel +600+200
    wm attributes  $w_topLevel -topmost 1
    #MAIN frame
    set  fst_layer [frame $w_topLevel.fst_layer -bg white ]
    #labelframes
    set lfr  [labelframe  $fst_layer.labelfr  -text "Configure new task" -fg blue -bg white]
    set lfr1 [labelframe  $fst_layer.labelfr1 -text "Calendar"  -bg white]
    set lfr2 [labelframe  $fst_layer.labelfr2 -text "Setting"  -bg white]
    set lfr3 [labelframe  $fst_layer.labelfr3 -text "Service buttons" -fg blue -bg white ]
        
    set hour_label   [label $lfr2.label_hour -text "Time event"  -bg white -fg red]
    set remind_label [label $lfr2.label_howoften -text "How often remind:"  -bg white -fg red]
    set etime_hour   [ttk::combobox $lfr2.time_hour -state readonly -textvariable ::dialog::add_task(hours) \
                      -values [::generator::genLst_inrange 0 24 ] -width 7]
    set etime_min    [ttk::combobox $lfr2.time_min  -state readonly -textvariable ::dialog::add_task(mins) \
                      -values [::generator::genLst_inrange 0 60 ] -width 7 ]
    set reminder     [ttk::combobox $lfr2.reminder  -state readonly -textvariable ::dialog::add_task(remind)\
                      -values $::dialog::add_task(lremind) ]
   
    grid $hour_label -pady 2 -columnspan 2   -sticky w
    grid $etime_hour $etime_min -padx 1
    grid $remind_label -row 4 -pady 2 -columnspan 2 -sticky w  
    grid $reminder  -columnspan 2 -row 5
        
    set label_topic [label $lfr.label_topic -text "Choose project name:" -bg white -fg green]
    set ::dialog::add_task(topic_var) [lindex $::dialog::add_task(topic_lst) 0]
    set topic [ttk::combobox $lfr.topic -state readonly -textvariable ::dialog::add_task(topic_var)\
               -values $::dialog::add_task(topic_lst) -width 12 ]
    
    #global  ttitle
    
    #set ttitle_v "Title"
    set ::dialog::add_task(ttitle_v) "Task title"
    set label_ttitle [label $lfr.label_ttitle -text "$::dialog::add_task(ttitle_v) (short issue description):"   -bg white -fg green  ]
    
    set ::dialog::add_task(ttitle) [ttk::entry $lfr.ttitle -textvariable ::dialog::add_task(ttitle_v) -width 45]
    # need to switch off debug 
    # bind $ttitle  <Any-Key>	{  textHendler  $ttitle [list  %K %A %X %W %Y ] }
    grid $label_topic     -row 0 -column 0 -sticky e
    grid $topic   -pady 3 -row 1 -column 0 -sticky w

    grid $label_ttitle    -row 0 -column 2  
    grid $::dialog::add_task(ttitle)  -pady 3 -row 1 -column 2   -sticky ne
    #setup year widget
    set value_year [clock format [clock seconds] -format %Y]
    for {set a 0 } {$a < 10} {incr a} {
        lappend lyear $value_year
        incr value_year
    }
    
    set month [list January February March April May Jun July August September October November December ]
    set  ::dialog::add_task(wyear) [lindex $lyear 0]
    set  ::dialog::add_task(month) [ lindex $month [ expr [clock format [clock seconds] -format %m] - 1] ]
    #setup month widget
    set calendar_month [ttk::combobox $lfr1.month -state readonly -textvariable ::dialog::add_task(month)   -values [list January February March April May Jun July August September October November December ]  -width 10 ]
    set calendar_year  [ttk::combobox $lfr1.year -state readonly -textvariable ::dialog::add_task(wyear)   -values $lyear  -width 6 ]
    bind $calendar_month <<ComboboxSelected>>  { ::dialog::change_calendar  [list  .dialogwindow.fst_layer.labelfr1.month .dialogwindow.fst_layer.labelfr1.year ]}
    bind $calendar_year <<ComboboxSelected>>   { ::dialog::change_calendar  [list  .dialogwindow.fst_layer.labelfr1.month .dialogwindow.fst_layer.labelfr1.year]}        
    set calendar [frame $lfr1.calendar ]
    #create days for month in calendar
    #add_task(handleCalendar)
    set ::dialog::add_task(handleCalendar) [ ::dialog::private_drawCalendar_in $calendar private_day_cmd]
     
    #private_fill_calendar   $handleCalendar  [clock format [clock seconds] -format %m]  [clock format [clock seconds] -format %Y] 
    #create days for month in calendar
    ::dialog::private_fill_calendar   $::dialog::add_task(handleCalendar)  [clock format [clock seconds] -format %m]   [clock format [clock seconds] -format %Y] 
    grid $calendar_month $calendar_year -padx 2
    grid $calendar -columnspan 2  -sticky nsew 
    grid rowconfigure $lfr1 1 -weight 1
    #grid columnconfigure $lfr1  -weight 1
    
    pack $lfr  -fill x
    pack $lfr3 -fill x    -side bottom -padx 2 -ipady 4
    pack $lfr1 -fill both -side left   -padx 2 -expand 1
    pack $lfr2 -fill y    -side right  -padx 2
    
    button $lfr3.cancel     -text "Cancel"    -command "destroy $w_topLevel"   -bg white  -width 10
    button $lfr3.continue   -text "Done"      -command "::dialog::ev_onDone $w_topLevel" -bg white  -width 10
    button $lfr3.additional -text "Ext.Setup" -command "destroy $w_topLevel"   -bg white  -width 10
    pack $lfr3.cancel $lfr3.continue $lfr3.additional -side right -padx 3
    pack  $fst_layer  -expand 1 -fill both 
   
    
}
proc ::dialog::ev_onDone { widg } {
    global envar  gEvent
        set month [list January February March April May Jun July August September October November December ]
        set nmonth [ expr [ lsearch $month $::dialog::add_task(month)] + 1  ]
    set  result [list -title $::dialog::add_task(ttitle_v) \
                -topic $::dialog::add_task(topic_var) \
                -year $::dialog::add_task(wyear) \
                -month  $nmonth \
                -day_number $::dialog::add_task(choosed_day) \
                -mins $::dialog::add_task(mins) \
                -hours $::dialog::add_task(hours) \
    ]
    destroy $widg
    #tk_messageBox -message  $result
    set gEvent(created_task)  $result
    unset ::dialog::add_task
}

#genLst_inrange - generates liat of digits in range
#   first - integer - first digit in range
#    - default is  0
#   last - ineger  - last digit in range
#    - default is  0
#   return: generatedLst  - list of integers in range (first..last)
proc ::generator::genLst_inrange { { first 0} {last 100} } {
    for {set i $first} {$i < $last} {incr i} {lappend generatedLst $i }
    return $generatedLst
}
# private_drawCalendar_in 
#   inframe - point to frame 
#   day_cmd - delegatee of procedure for button event
#   return: list of button's handles
proc ::dialog::private_drawCalendar_in {inframe day_cmd} {
    set a 0
    set day_in_week [list Mo Tu We Th Fr Sa Su ]
    for {set index 0} {$index < 49 } {incr index} {
        if { $index < 7} {
            set text_ [lindex $day_in_week $index]
            set state "disabled"
        } else {
            set text_ [expr {$index - 6 } ]
            set state "normal"
        }
        set bt [button $inframe.$index -text $text_ -bg white -relief flat -overrelief groove -state $state -command "$day_cmd $inframe.$index "]
        grid $bt -row [expr {$index / 7}]  -column [expr { $index % 7}]  -sticky nsew
        if { $index > 6} { lappend sqButton_list $bt }
    }
    return $sqButton_list
}

proc private_day_cmd { ref_toWidg } {
    #global add_task
    set ::dialog::add_task(choosed_day) [$ref_toWidg cget -text]
    foreach e  $::dialog::add_task(handleCalendar)  {
        set color "white"
        if { $::dialog::add_task(choosed_day) == [$e cget -text] } {
             set color "blue"
        }   
        $e configure -bg $color
    }
#    tk_messageBox -message [$ref_toWidg cget -text]
}

proc ::dialog::private_fill_calendar {dayReffs month year } {
    #global add_task
    set startOfMonth [clock format [clock seconds] -format $month/01/$year]
    
    set startOfWeek  [clock format [clock scan "+0 month" -base [clock scan $startOfMonth] ] -format %u]
    set cntDay       [clock format [clock scan "+1 month -1 day" -base [clock scan $startOfMonth] ] -format %d]
    
    #tk_messageBox -message "startOfMonth = $startOfMonth  cntDay = $cntDay startOfWeek = $startOfWeek "
    set shift [expr { $startOfWeek - 1 } ]
    set lastday_in_month [expr { $shift + $cntDay - 1}]
    for {set i 0 } { $i < [llength $dayReffs]} {incr i} {
        if { $i <  $shift  || $i > $lastday_in_month } {
            #[lindex $dayReffs $i  ]  configure -state normal 
            [lindex $dayReffs $i  ]  configure -text "" -state disabled -bg white
        } else {
            set value [expr $i - $shift  + 1]
            if { $::dialog::add_task(choosed_day) > $cntDay } {
                set value 1
                set ::dialog::add_task(choosed_day) $value
            }
            if { $::dialog::add_task(choosed_day) == $value } {
                [lindex $dayReffs $i ]  configure -bg blue
            } else {
                [lindex $dayReffs $i ]  configure -bg white
            }   
            [lindex $dayReffs $i ]  configure -text $value -state normal 
            
        }
    }
    
}
#::dialog::change_calendar
#   options -
proc ::dialog::change_calendar { options } {
    #global  add_task
    set hmonth [lindex $options 0]
    #tk_messageBox -message "$hmonth [$hmonth cget -value ] "   
    set nmonth [expr { [lsearch [$hmonth cget -value ] $::dialog::add_task(month)] + 1} ]
    ::dialog::private_fill_calendar $::dialog::add_task(handleCalendar) $nmonth $::dialog::add_task(wyear) 
    #tk_messageBox -message " $month  "   
}

#--------------------------------------------------------------------------------
# dialog_add_proj - creates dialog for adding new project name to db
#          cmd_name - name for callback command  
#--------------------------------------------------------------------------------
proc ::dialog::add_proj { cmd_name } {
    set w_topLevel .dialog_add_proj
    catch {destroy $w_topLevel }
    toplevel $w_topLevel
    set ::dialog::add_proj  "New"
    wm title $w_topLevel "Add new project"
    #wm iconname $w_topLevel "unicodeout"
    # expected size of window  400x300    !!!
    wm minsize $w_topLevel 300 0
    wm resizable $w_topLevel 0 0
    set  fst_layer [frame $w_topLevel.fst_layer -bg white ]
    set lfr  [labelframe  $fst_layer.labelfr  -text "Create new project name" -fg blue -bg white]
    set lfr1 [labelframe  $fst_layer.labelfr1 -text "Make your choice" -fg blue -bg white ]
    set name [ttk::entry  $lfr.ent  -textvariable ::dialog::add_proj ]
    # --------------------------------------------------------------------------
    pack $name -fill x -padx 2 -pady 2
    pack $lfr $lfr1  -fill x -padx 2 -pady 2
    # --------------------------------------------------------------------------    
    button $lfr1.cancel     -text "Cancel"   -command "destroy $w_topLevel"   -bg white  -width 10
    button $lfr1.continue   -text "Accept"   -command "$cmd_name ::dialog::add_proj ; destroy .dialog_add_proj" -bg white  -width 10
    
    # --------------------------------------------------------------------------
    pack $lfr1.cancel $lfr1.continue  -side right -padx 3 -pady 1
    pack  $fst_layer  -expand 1 -fill both
    # --------------------------------------------------------------------------
    
}
# ::dialog::TreeSetting - creates  tree controll
#       parent - parent widget for tree
#       
proc ::dialog::TreeSetting { parent } {
    global col envar
    array set col {
        project  "group name"
        desc     "description"
        summary  "summary"
        created  "created"
        created  "created"
        started  "started"
        owner    "event"
        state   "status"
    }
    # columns list
    set list_col [list $col(project) $col(desc) $col(summary) $col(created) $col(started) $col(state)  $col(owner)]
    # create tree
    set tree [ttk::treeview  $parent.tree -columns $list_col -yscroll  "$parent.tree.vsb  set" -xscroll "$parent.tree.hsb set" ]
    set envar(widg,tree) $tree
	# create scroll bar
    scrollbar $tree.vsb -orient vertical -command     "$::envar(widg,tree) yview"
	scrollbar $tree.hsb  -orient horizontal -command "$::envar(widg,tree) xview"
    # add text to columns head
    foreach i $list_col {
        $tree heading $i -text $i  -anchor center  
    }
    # setting  width for every column
    $tree column #0 -width 200
    $tree column $col(project) -width 70 
    $tree column $col(summary) -width 50
    $tree column $col(created) -width 50
    $tree column $col(started) -width 50
    $tree column $col(state)   -width 50
    $tree column $col(owner)   -width 50
    $tree column $col(desc)    -width 250
    
    pack  $tree -expand yes -fill both
    # packing scrols
    pack $tree.vsb -fill y -side right
    pack $tree.hsb -fill x -side bottom
    $tree  insert "" end -id Progress    -tags "node" -text "Progress" -values [list "" "Tasks in progress" "" "" "" "" ""] -open 0
    $tree  insert Progress end   -text "No tasks added" -values [list "" "Change status for any task " "" "" "" "" ""]
    $tree  insert "" end -id Pending -tags "node" -text "Pending" -values [list "" "Pending tasks for user attention" "" "" "" "" ""] -open 0
    
    $tree  insert "" end -id Ready -tags "node" -text "Ready to fix"  -values [list "" "Ready solution for task but not marked as done" "" "" "" "" ""]
    $tree  insert Ready end   -text "task manager" -values [list "" "create mechanism for sorting tasks by data and priority" "" "" "" "" ""]
    
    $tree  insert {} end -id "History" -tags "node" -text "History"  -values [list "" "Progress for all tasks" "" "" "" "" "" ] -open 1
    $tree  insert "" end -id Done -tags "node" -text "Done" -values [list "" "Already done tasks" "" "" "" "" ""] -open 0
    $tree  insert Done end  -text "sub Direct"
    $tree  insert "" end -id WontFix -tags "node" -text "Won't fix" -values [list "" "Issue will not be done as it is not correct or it is impossible create solution for it" "" "" "" "" ""]   -open 0
    $tree  insert "" end -id TPreflight  -tags "preflight" -text "Preflight Templates" -values [list "" "Templates for setting setup file for preFlight " "" "" "" "" ""] -open 0    
    #bind $tree <KeyPress> {tk_messageBox -message " %W %A %K" ; tk_messageBox -message [%W item [ %W selection] ] }
    #bind $tree <Any-Key> { ::onevent::treeClick   %W   }
    #bind Treeview <KeyRelease> [list ::tv::treeviewKeyPressReset %A]
    bind $tree <KeyPress> { ::appendToConsoleW [%W focus] }
    $tree tag configure node -background #F5F5F5
    $tree tag configure preflight -background 	#F5F5F5
    $tree tag bind preflight <KeyRelease> {
           tk_messageBox -message  "[%W  selection] [%W focus]" 
    }
    
    #bind $tree	<ButtonPress-1> 	{ ::onevent::treview::Press %W %x %y }
    #bind Treeview <FocusOut> [list ::tv::treeviewKeyPressReset ""]
    #bind $tree <KeyPress> {tk_messageBox -message " %W %A %K" ; tk_messageBox -message [%W item [ %W selection] ] }
    #bind $tree <Any-Key> { ::onevent::treeClick   %W   }
    #bind Treeview <KeyRelease> [list ::tv::treeviewKeyPressReset %A]
    #bind $tree <KeyPress> { ::appendToConsoleW [%W focus] }
    #bind $tree	<ButtonPress-1> 	{ ::onevent::treview::Press %W %x %y }
    #bind Treeview <FocusOut> [list ::tv::treeviewKeyPressReset ""]
    
}    



