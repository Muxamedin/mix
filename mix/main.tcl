#!/usr/bin/tclsh \
    exec  wish "$0" ${1+ "$@"}

package require Tk
#package require Thread
#package require sqlite3
#getting path to the directory where was started application

#directory where was invoked main script
set run_Directory [file join [pwd] [file dirname [info script]]]

# array with environment variables
set envar(ext) ".db"
set envar(var,stor) {}

# config - array
#        array for storing config data which will use in application
set config(main_dir) $run_Directory                                            ; # top dir for application
set config(whereIsSituatedDb) "[file join $run_Directory usr store]"           ; # path to directory with database 
set config(dbName) "db$envar(ext)"                                             ; # db name 
set config(dbPath) [ file join $config(whereIsSituatedDb) $config(dbName)]     ; # path to db
set config(lib)    [ file join $config(main_dir) lib]
set config(filesInLibFolder) [list  "controller.tcl" "Dialog.tcl"  "sql_db.tcl" ]
set config(preflight)    [ file join $config(main_dir) usr macros preflight]
#set config(macros) [file join $config(main_dir) macros]

#--------------------------------------------------------------------------------                                                                                
lappend auto_path $config(whereIsSituatedDb)
lappend auto_path [file dirname [info script] ]
#--------------------------------------------------------------------------------

#Events 
set gEvent(created_task) {}
set gEvent(consoledebug)  {}
#--------------------------------------------------------------------------------
#tracerEventsGlobalArray   - tracer for array by index
#      event on writing to the array by index    
proc tracerEventsGlobalArray {arrname index args} {
    global config envar
    upvar #0 $arrname var
    #puts "$arrname $index $args"
    ::onevent::addTaskToDb $var($index)
    set ::gEvent(consoledebug) "Added task with options:  $var($index)"
    clean_child_intree_node  $envar(widg,tree) "History" 
    tree_history_fill [ ::dbase::db_get_tasks $config(dbPath) ]
}
trace add variable ::gEvent(created_task) {array write } tracerEventsGlobalArray

#tracerEventsConsoleDebug   - tracer for array by index
#      event on writing to the array by index    
proc tracerEventsConsoleDebug {arrname index args} {
    global config envar
    upvar #0 $arrname var
    writeToConsoleW "$var($index)"
}
trace add variable ::gEvent(consoledebug) {array write } tracerEventsConsoleDebug

proc tracerEventsAddPref {arrname index args} {
    global config envar
    upvar #0 $arrname var
    #::dbase::db_store_preflight  $config(dbPath) $var($index)
    #clean_child_intree_node  $envar(widg,tree) "History" 
}
trace add variable ::gEvent(preflight) {array write } tracerEventsAddPref

#Manipulation with console widget
#--------------------------------------------------------------------------------
# writeToConsoleW - overwrite console widget
#      text_message - message which will be added to widget
proc writeToConsoleW { text_message } {
     $::debug_console delete 1.0 end  ; # clear console pane
     $::debug_console insert insert $text_message
}

# appendToConsoleW - append message to console from new line
#      text_message - message which will be added to widget
proc appendToConsoleW { text_message } {
     $::debug_console insert insert "$text_message; "
}
# appendToConsoleW - append message to console from new line
#      text_message - message which will be added to widget
proc appendToTextW { text_message } {
     $::stringCounter insert insert "$text_message "
}
#--------------------------------------------------------------------------------
#Manipulation with console widget
# options for main window 
set windowparams {
    title "Preflight tool"
    minsize {100 100}
    resizable {1 1}
}
#--------------------------------------------------------------------------------
# user configuration of main window
set userconfig {
    menubar yes
}

# read dictionary global "wDictList"
#set run_Directory [file join [pwd] [file dirname [info script]]]   ; # path to directory where was run application editor
set file_Dir [file join $run_Directory wordsFromFile ]   ; #
set file_path [file join $file_Dir en_GB_my.dic ]
proc load_words_from_file {file_} {
    #tk_messageBox -message "$file_path"
    if { ! [ catch { open $file_ r } fId ] } {
	    #global wDictList
	    #tk_messageBox -message "all ok file opened"
	    set count 0
	    foreach line [split [read $fId] \n] {
			lappend words_list $line
			# puts "$count $line"
			incr count
	    }
	    close $fId
        return $words_list
	    #tk_messageBox -message "$wDictList"
    } else {
		tk_messageBox -message "Error: $fId \n May be $file_ is busy or absent."
        exit
    }
}

set wDictList [load_words_from_file $file_path]
# setting up menu
set menu {
	File {
        "New file"           { -command {::onevent::newFile}   }
        "Open file"          { -command {::onevent::openFile}  }
        "Include DB"         { -command {::onevent::includeDB} }
        "RoadMap"            { -command {::onevent::RoadMap}   }
        "Planing file"       { -command {::onevent::planing}   }
        Exit                 { -command {::onevent::exitProc}  }
    }
    Project {
        "Create new project" { -command {::onevent::newProject} }
        "Merge projects"     { -command {::onevent::merge_prj}  }
        "Delete project"     { -command {::onevent::dell_prj}   }
    }
    Connection {
        "Log in"             { -command {::onevent::login  } }
        "Log out"            { -command  {::onevent::logout} }
        "Send status"        { -command {::onevent::sStatus} }
    }
    Edit {
        Copy                 {-command  {::onevent::copy}    }
        Paste                {-command  {::onevent::paste}   }
        Cut                  {-command  {::onevent::cut}     }
        Delete               {-command  {::onevent::dell}    }
    }
    View {
        "Language"           {-command {::onevent::chooseLenguage}  }
        "SpellChecker"       {-command {::onevent::spellChecker}    }
    }
    Pluggins {
        "import .preflight"    {-command {::onevent::importPreflight} }
    }
    Tools {
        "Template daily"           { -command { ::onevent::chooseTemplate 1} }
        "Template weekly"          { -command {::onevent::chooseTemplate 2}  }
        "Template plans for week"  { -command {::onevent::chooseTemplate 3}  }
        "Template plans for month" { -command {::onevent::chooseTemplate 4}  }
        "Template - get All"       { -command {::onevent::chooseTemplate 5}  }
        "Generate standup report"  { -command { ::onevent::chooseTemplate 1} }
        
    }
    Help {
        About                { -command {::onevent::about}    }
        Help                 { -command {::onevent::help}     }
    }
    -name menu
}
# window setup
proc setup-window {w params} {
    wm title $w [dict get $params title]
    wm resizable $w {*}[dict get $params resizable]
    wm minsize $w {*}[dict get $params minsize]
    $w config -bg white
}

# build-menu
#	    pin menu to window 
#       menu -  dictionary contans menu's setup
#        w    -  main window 
#       args -   
#       frame .menu_frame -borderwidth 5
#       pack  .menu_frame -side top -fill x 
proc build-menu {menu w args } {
    
    dict with args {
        set options [dict filter $menu key -*]
        if {[dict exists $options -command]} {
            $w add command -command [dict get $options -command] -label $label
        } else {
            if {[dict exists $options -name]} {
                set name [dict get $options -name]
            }
            set m [menu $w.$name -tearoff 0]
            #menu $m -tearoff 0
            foreach {k v} $menu {
                if {![string match -* $k]} {
                    build-menu $v $m label $k name [incr i] 
                }
            }
            if {[llength $args]} {
                $w add cascade -menu $m -label $label 
            } else {
                $w configure -menu $m
            }
            return $m
        }
    }
    #setting color for menu
    $w config -activebackground black  -activeforeground white -background white
}
# findWordsFromList - serch in list with words by mask
#       maska - regexpr for search words in list
proc findWordsFromList { maska} {
    global wDictList
    global lb
    global frameText
    global panedHsupport
    global wordStruct
    global filteredList
    global top_frame 	 ; # верхний фрайм
    global realword
    #set maska_
    #set realword $maska
    set mas [string tolower $maska]
    append  mas *
    #set filteredList_ [ lsearch -all -inline $wDictList $mas ]
    set filteredList [lsort [ lsearch -all -inline $wDictList $mas ]]  			;# mach list
    if { [llength $filteredList] > 0 } {
    	# size creates listbox  
    	# if listbox item < 28 - autosize
    	# else creates listbox 28x28chars
    	if {[llength $filteredList] < 15} { 
    		set lb [ listbox $panedHsupport.s -foreground blue -font "serif 10" -bg white -height [ expr [llength $filteredList] + 1] -width 0  ]
    		} else {
    			set lb [ listbox .s -foreground blue  -font "serif 10" -bg white -height 28 -width 28 ]		
    		}
    	
		$lb insert 0 "w = [llength $filteredList] - \[press arrow down \]"
		# coordinates where to place listbox
		place $lb -x [expr {$wordStruct(coordX) + 25 }] -y 10 
		set count 0
		foreach item $filteredList {
			incr count
			$lb insert $count "$count. $item "
        }
		bind $frameText <Key-Down> { focus $lb}
		#bind $frameText <Key-space>   {  destroy $lb ; bind $frameText <Key-space> {} ; bind $frameText <Key-Down> {} }    
		bind $lb <Key-Right>   {focus $frameText ;  set check [ $lb curselection]; cleverComplite $check ; after 5 {destroy $lb}   }
		bind $lb <Key-Return>   {  set check [ $lb curselection]; cleverComplite  $check ; destroy $lb   }
		bind $lb <Double-Button-1>   {  set check [ $lb curselection] ;   cleverComplite $check ; destroy $lb    }
		bind $lb <Key-Escape>   {focus $frameText  }
		bind $lb <Key-space>   {focus $frameText ;  set check [ $lb curselection]; cleverComplite $check ; after 5 {destroy $lb}   }
	}
}
proc toUserStyletyping { mask word} {
    set lengs [string length $mask]
    return [string replace $word 0 [expr {$lengs - 1}] $mask]
}
# procedure compliter
# compliting next part of word \
when chosed word from list box  it printed to text from firs char of word - after first part of word was deleted\
choosing from listbox : Enter, Double-button-1, arrow-right,\
discard list box : space , escape
# rOneWord numder of listbox row
proc cleverComplite { rOneWord } {
    global filteredList
    global frameText
    global wordStruct
    global top_frame
    global lb
    set varSh $wordStruct(charIndex)
   # tk_messageBox -message "$varSh $wordStruct(charPosition) $wordStruct(charLinePosition) [$frameText index 1.0]- [ string length $wordStruct(word)]"
    #set i [ $frameText index "insert - 1 lines"]
    set sh  [expr { $wordStruct(charPosition) - [ string length $wordStruct(word)] } ]
    set sh [expr { $sh - 1}]
    if { $rOneWord == 0  } {
	focus $frameText
	#after 1 { focus $frameText ;  bind $frameText <Key-space> {} ; bind $frameText <Key-Down> {} ; destroy $lb  }
	bind $frameText  <Key-Left>  { focus $frameText ;  bind $frameText <Key-space> {} ; bind $frameText <Key-Down> {} ; destroy $lb  }
	#bind $top_frame  <Key-Return>  { focus $frameText ;  bind $frameText <Key-space> {} ; bind $frameText <Key-Down> {} ; destroy $lb  }
	bind $frameText <Key-space> {}
	bind $frameText <Key-Down> {}
	bind $frameText  <Key-Left> {}
	bind $frameText <Key-Return> {}

    } 
    # number of row != 0 
    if { $rOneWord > 0  } {
    	#tk_messageBox -message wordstart
    	#kill first chars of word
     $frameText delete "insert - [ string length $wordStruct(word)] char"  insert
     set insertWordFromLb [lindex $filteredList [ expr {$rOneWord - 1}]  ]
     set insertWordFromLb [toUserStyletyping $wordStruct(word) $insertWordFromLb]
     $frameText insert  insert $insertWordFromLb
     #tk_messageBox -message
     focus $frameText
     bind $top_frame  <Key-Left>  { focus $frameText ;  bind $frameText <Key-space> {} ; bind $frameText <Key-Down> {} ; destroy $lb  }
     bind $frameText <Key-Down> {}
     bind $top_frame  <Key-Left> {}
     
    } 
    
}

#textHendler handler
# winHendle - path to text
# largs     - list of args \
# largs 0	    - %K  \ 
# largs 1	    - %A  \
# largs 2	    - %x  \
# largs 3	    - %W  \

array set wordStruct {
    prevChar {}
    lwords   {}
    prevCharPosition {}
    charPosition     {}
    charLinePosition {}
    coordX    {}
    coordY    {}
    curSymPos {}
    endSymPos {}
}

proc textHendler { winHendle largs  } {
    global  stringCounter  debug_console frameText  lb
	#--
	global wordStruct			; # array -info about word
	set wordStruct(char) {}			; # to clear
	set wordStruct(word) {}			; # to clear
	set wordStruct(charPosition) {}		; # to clear
	set wordStruct(firstCharWord) {}	; # to clear
	set wordStruct(coordX) {}
    set wordStruct(coordY) {}
    set wordStruct(coordXX) [lindex $largs 5]
    set wordStruct(coordYY) [lindex $largs 4]
	set wordStruct(curSymPos) {}
	set wordStruct(endSymPos) {}
	set wordStruct(charIndex) {}
	# delete listbox from text
	if {[ info exists lb ]} { destroy $lb
	    bind $frameText	<Key-space> {}
	    bind $frameText	<Key-Up> {}
	    bind $frameText	<Key-Down> {}
	}
	# hendle  non char symbol
	# clear console text
	$debug_console delete 1.0 end
	# service information	
	$debug_console insert insert  "K=[lindex $largs 0] A=[lindex $largs 1] x=[lindex $largs 2] W=[lindex $largs 3] Y=[lindex $largs 4] x=[lindex $largs 5] y=[lindex $largs 6] " ; # test message
	set a [$winHendle bbox insert] 
	set wordStruct(coordX) [lindex $a 0]
	set wordStruct(coordY) [lindex $a 1] 
	$debug_console insert insert "\ncoord of char: wordStruct(coordX) = $wordStruct(coordX), wordStruct(coordY)= $wordStruct(coordY)\n"
    	# chars or symbols
	if {  [ regexp {[\w]}  [lindex $largs 1] matchCh]  } {
	    # current number of symbol in the string
	    set wordStruct(charPosition)     [ lindex [split [$winHendle index insert] .] 1 ]
	    # get current number of string 
	    set wordStruct(charLinePosition) [ lindex [split [$winHendle index insert] .] 0 ]
	    set wordStruct(char) [lindex $largs 1]
	    #test  
	    $debug_console insert insert "\n -> line: wordStruct(charLinePosition) = $wordStruct(charLinePosition)"
	    #end test 
	    if { $wordStruct(charPosition) == 0 } {
		    set wordStruct(word) $wordStruct(char)
		    $debug_console insert insert " stringLine :  -> $wordStruct(word)  \t"
            
		} else {
		    for { set i 0  } { $i < $wordStruct(charPosition) } { incr i }  {
		    # get string from the begining to current symbol 
		    set stringLine [ $winHendle get  "insert linestart" insert]
		    # get symbol before current symbol
		    set var [ $winHendle get  "insert -[expr {$i + 1}] char"]
		    #test  
		    $debug_console insert insert "$stringLine : $var -> $wordStruct(charPosition) -- $i \t"
		    #end test 
		    # if symbol is not char
		    if {  [ regexp {\W} $var ss ]  } {
		        set var1 [ $winHendle get  "$wordStruct(charLinePosition).[expr {$wordStruct(charPosition)- $i } ]"  insert ]
			#end test 
			set wordStruct(charIndex) [ expr { [ expr { $wordStruct(charPosition)- $i } ] - 0 } ]
		        set wordStruct(word)  $var1
		        append wordStruct(word) $wordStruct(char)
			$debug_console insert insert "\nwordStruct(word)--+-- $wordStruct(word)"
			#main call for working with list from dictionary
			findWordsFromList $wordStruct(word)
		        break
		    }
		    # if we gets to begin of string 
		    if { $i == [ expr { $wordStruct(charPosition) - 1 }  ]  } {
			set var1 [ $winHendle get  "insert linestart"  insert ]
			set wordStruct(word)  $var1
		        append wordStruct(word) $wordStruct(char)
		        $debug_console insert insert "\nfrom line start--+-> $wordStruct(word) "		
		    }
		 if { $wordStruct(word) != ""  } {
		    #set wordStruct(startPosition) [ $wordStruct(charLinePosition).[expr {$wordStruct(charPosition)- $i } ]]
			set wordStruct(endPosition) [$winHendle index insert]
			#main call for working with list from dictionary
		    findWordsFromList $wordStruct(word)
		       
		    }
		}
		
	    }
	    set wordStruct(firstCharWord) [ regexp { [^\w ] } $wordStruct(word) mmatch1]
	    $debug_console insert insert " word: [ $winHendle get "insert wordstart" "insert wordend"] ( [$winHendle index "insert wordstart"] [$winHendle index insert] [$winHendle index  "insert wordend"]  )  $wordStruct(charPosition) $wordStruct(firstCharWord)"
	    #$debug_console insert insert "[ $winHendle sget -text  ]"
	    set	wordStruct(prevChar) $wordStruct(char)     ; # 
	}
	# обработка печатных символов 	  
	if { ! [ regexp {[A-Za-z0-9]}  [lindex $largs 1] matchCh]  } {
		set wchar [lindex $largs 0]
	    	$debug_console insert end " $wchar"
		set Tab Tab
		if { $wchar == $Tab } {
		    $debug_console insert end " \[ [$winHendle index insert]\]$wchar ----!!!!"
		}
		
	    }

} 
#----------------------------------------------------------------------------------------------------
# init of application
proc initW {} { 
    
	global windowparams  ; # windows property
	global userconfig    ; # user configuration
	global menu 		 ; # 
	global top_frame 	 ; # 	
	global bottom_frame	 ; # 
	global debug_console 	 ; # console
	
	global stringCounter     ; # 
	global frameText 	 ; # text handle
    global panedHsupport     ; # 
	
    global config
    # load files from lib folder
    foreach item $config(filesInLibFolder) {
        set fileName [ file join $config(lib) $item]
            if { [file exists  $fileName] } {
            source $fileName
        } else {
            tk_messageBox -message "There is no file $fileName . Please be sure that file exists." -title "Error message" -icon "error"
            exit
        }
    }
    set filePreflight [ file join $config(preflight) preflight.tcl ]
    source $filePreflight
    ::dbase::db_create $config(dbPath)  
	setup-window . $windowparams
	if {[dict get $userconfig menubar]} {
   		build-menu $menu .
	}
	#---------------------------------------------------------
	set bottom_frame [frame  .slfr -bg  #99FF33  ] 
	pack $bottom_frame  -fill x -side bottom -expand 0 
	#---------------------------------------------------------
    #paned window for tree and text frame
   	set top_frame [panedwindow .topfr -orient vertical -bg green  ]
    pack $top_frame  -expand yes -fill both  
	#---------------------------------------------------------
    # handles for top and bottom pane of paned frame
    set top_ofpaned    [frame $top_frame.top ]
    set bottom_ofpaned [frame $top_frame.bottom]
    #set top_frame [panedwindow .topfr -orient vertical -bg green  ]
    #---------------------------------------------------------
    
    # create frame for managing tree
    set toolBar_toTree [frame $top_ofpaned.buttons_toTree -bg "white"]
    # create buttons
    # 
    set addTask    [button $toolBar_toTree.but_addTask \
                    -text "Add Task" \
                    -command "::dialog::addTask" \
                    -bg "yellow" \
                    -relief flat \
                    -overrelief groove ]
    set crt_proj      [button $toolBar_toTree.but_crtproj \
                    -text "Create Project" \
                    -command {::onevent::newProject} \
                    -bg "white" \
                    -relief flat \
                    -overrelief groove]
    set preflight    [button $toolBar_toTree.but_preflight \
                    -text "Run preflight" \
                    -command {::onevent::buildPreflight } \
                    -bg "white" \
                    -relief flat \
                    -overrelief groove]
    # add buttons to manage frame
    grid  $addTask  $crt_proj  $preflight 
    #$preflight configure -state disabled
    
    #pack $preflight $crt_proj $addTask    -side right -padx 3
    pack $toolBar_toTree  -fill x -side top
    
    # creating tree and set it to $top_ofpaned as a parrent
    ::dialog::TreeSetting $top_ofpaned
    $top_frame add $top_ofpaned -minsize 400
    $top_frame add $bottom_ofpaned -minsize 10
    
    
    set panedHsupport [panedwindow $bottom_ofpaned.hpaned ]
    pack $panedHsupport  -side top -expand  yes -fill both 
    
	set frameText [text $panedHsupport.fTE  -font "Tahoma 12" \
                   -fg #00FF00  -bg #363636    -tabs 50  ]
    $frameText config -insertbackground blue
    
	set stringCounter [text $panedHsupport.strCnt  -font curier -fg #FFFAFA  -bg #363636 -width 50  ]	
	
    $panedHsupport add $frameText -minsize 700
    $panedHsupport add $stringCounter -minsize 10
    
	#---------------------------------------------------------	

	set debug_console  [text .slfr.infCon   -font "tahoma 8" -fg red  -height 7  -tabs 50 ]

	#set leftConsole_onBottomFrame [labelframe .slfr.infCon2  -text "Calendar"   -font tahoma -fg black  -height 7  -width 250   ]

	pack $debug_console   -side left  -padx {1 0}  -pady {1 1}  -fill x  -expand yes
	#---------------------------------------------------------
	bind $bottom_frame  <Enter>   { %W config -bg blue  }
	bind $bottom_frame  <Leave>   { %W config -bg white }
	bind $top_frame	    <Enter>     { %W config -bg grey  }
	bind $top_frame     <Leave>    { %W config -bg white }
	bind $frameText     <Any-Key>	  {  textHendler  $frameText [list  %K %A %X %W %Y %x %y] }
    ::onevent::preflightUpdate
    
}

proc tree_history_fill { lst } {
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
#clean_child_intree_node
#       work with tree
proc clean_child_intree_node  { root node }  {
    #$envar(widg,tree)
    set child [ $root children $node ]
    $root delete $child 
}
proc addTask_to_db {} {
    ::dialog::addTask
}

#--------------------#--------------------------------------------------------------------------------------------------------------------------
# описание точки входа в приложен:ие 
proc main {} {
    global config envar
# стартовая настройка окна приложения
	initW
    tree_history_fill [ ::dbase::db_get_tasks $config(dbPath) ]
    
}


main


 