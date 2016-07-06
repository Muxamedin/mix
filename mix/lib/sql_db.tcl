
namespace eval dbase {
    
}

package require sqlite3
# proc created new db
# if db from path exists - trying to open and create backup for db 
proc ::dbase::db_create { db_path } {
    if { ! [file exists $db_path] } {
	# creating new base
		if { [catch { sqlite3 dbcmd $db_path } Err] } {
			tk_messageBox -message "Can't create new DB at start . $db_path Error : $Err"
			return 0
        }
        #create_gtables
        ::dbase::db_create_tables dbcmd    
	} else {
	#test - can open 
		if {  [ catch { sqlite3 dbcmd $db_path } Err ] } {
		    # dbcmd backup  main [file join [file dirname $db_path ] bckp_[file tail $db_path] ]
            tk_messageBox -message "Can't open data base $db_path. Database can be damaged. Error : $Err.\n Try to restore database from backup db "
			return 0
		} 
	}
   dbcmd close
   return 1
}

proc db_restore { db_path } {
	if { ! [ catch { sqlite3 dbcmd $db_path } Err] } {
		     dbcmd restore  main [file join [file dirname $db_path ] bckp_[file tail $db_path] ]
 
		} else {
				tk_messageBox -message "Can't open data base $db_path when trying to  restore db. Database can be damaged. Error : $Err.\n Try to restore database from backup file [file join [file dirname $db_path ] bckp_[file tail $db_path] ] "
				return 0
		}
	dbcmd close	
	return 1
}

# restore data base from enother one
proc ::dbase::db_restore_from { db_path from } {
	if { ! [ catch { sqlite3 dbcmd $db_path } Err] } {
		    if {  [catch { dbcmd restore  main $from} err] } {
		     	if {! [file exists $from] } {
		     		tk_messageBox -message "Can't find $from. "
		     	} else {
		     		tk_messageBox -message "ERROR : $err\n Database can be damaged."
		     	}
		     	return 0
		    } else {
		    	dbcmd close
		    }
	} else { tk_messageBox -message "ERROR : $Err \n Can't open $db_path in restorefromdb process" }
	return 1
}

proc db_fill_onstart { db_id } {
    $db_id eval { INSERT INTO statuses VALUES( NULL, "Done" )}
    $db_id eval { INSERT INTO statuses VALUES( NULL, "Ready to fix" ) }
    $db_id eval { INSERT INTO statuses VALUES( NULL, "Pending" ) }
    $db_id eval { INSERT INTO statuses VALUES( NULL, "Won't fix" ) }
    $db_id eval { INSERT INTO statuses VALUES( NULL, "InProgress" ) }
    $db_id eval { INSERT INTO projectgroup VALUES( NULL, "New" ) }   ;#  project name  - will have all tasks with empty project name
    $db_id eval { INSERT INTO projectgroup VALUES( NULL, "NMB" ) }      
    $db_id eval { INSERT INTO projectgroup VALUES( NULL, "EC" ) }
    $db_id eval { INSERT INTO projectgroup VALUES( NULL, "Home-Task" ) }
    $db_id eval { INSERT INTO projectgroup VALUES( NULL, "Future" ) }
    $db_id eval {INSERT INTO scm VALUES ( NULL, "P4", "perforce", "bmikhail-nimbus-main" , "p4:3710", "bmikhail", "build-commander-main"  ) }
    $db_id eval {INSERT INTO server VALUES ( NULL, "chronic3" , "bmikhail", ""  ) }
    $db_id eval {INSERT INTO procedures VALUES ( NULL, "Commander", "Master", "1", "bmikhail", "main" , "0", "1" , "1" , "1", "0", "1" , "1" , "1","0", "1" , "1" , "1",  "oracle", "new-installjamer" ) }
    array set procedure {
    "projectName"            "Commander"
     "procedureName"         "Master"
     "preFlightUser"         "bmikhail"
     "brunch"                "main"
     "dbType"                "oracle"
     "preFlightTeg"          "debugging-uninst-Action-WIN"
     "preFlight"   "1"
      "doDbDump"   "0"
      "skipSystemTests"      "0"
      "skipServerUnitTests"  "0"
      "skipOnWindows"        "0"
      "skipOnLinux"          "0"
      "skipAgent64"          "0"
      "skipSeparateAgentinstaller"       "0"
      "skipOnHpux"           "0"
      "skipOnMacintel"       "0"
      "skipOnSol86"          "0"
      "skipOnSolaris"        "0"
      "paralelModTest"       "0"
    }
    set procc [array get procedure]
    $db_id eval {INSERT INTO procedure VALUES ( NULL, $procc ) } 
                
}




proc ::dbase::inset_task { db_id args } {
    array set task $args
    $db_id eval {INSERT INTO tasks VALUES( NULL, $task(key) , $task(project) , $task(tile), $task(description) , $task(points) , $task(status_id) ,$task(dedline) , $task(created), $task(edited)) }
}

#--------------------------------------------------------------------------------
# db_add_project - adding project to database
#           name_value -  value of project name 
#--------------------------------------------------------------------------------
proc ::dbase::db_add_project { name_value } {
    global config
    upvar #0 $name_value name
    if {  $name == "" } {
        puts "there is no name of project"
        return 0
    }
    sqlite3 dbcmd $config(dbPath)       
    set db_id dbcmd
    set prj_names [$db_id eval "SELECT * FROM projectgroup"]
    if { [lsearch $prj_names $name] == -1    } {
        $db_id eval "INSERT INTO projectgroup VALUES( NULL, \"$name\" ) "     
    } else {
        tk_messageBox -message "Project name \"$name\" already exists"
    }
    $db_id close
}

proc ::dbase::db_create_tables { db_id } {
	#global tables
    array set tables {
                tasks          { "id  INTEGER PRIMARY KEY AUTOINCREMENT"  "key varchar(100)" "project int(11) DEFAULT 1" "title varchar(255) DEFAULT \' \'" "description text DEFAULT \' \' " "points int(11) DEFAULT 0" "status_id int(11) DEFAULT 1" "deadline DATE DEFAULT 0" "created_at DATE DEFAULT 0" "edited_at DATE DEFAULT 0" }
                statuses       { "id INTEGER PRIMARY KEY ASC" " name text NOT NULL" }
                comments       { "id INTEGER PRIMARY KEY ASC" "tsk_id int(11) DEFAULT 0" "content text NOT NULL" "created_at int(11) DEFAULT 0" "edited_at int(11) DEFAULT 0"}
                scm            { "id  INTEGER PRIMARY KEY AUTOINCREMENT"  "name varchar(50)"  "type varchar(50)" "client varchar(50)" "port varchar(50)" "user varchar(50)" "template varchar(50)" }
                server          { "id  INTEGER PRIMARY KEY AUTOINCREMENT"  "hostName varchar(50)" "userName varchar(50)" "password int(20)" }
                procedures     { "id  INTEGER PRIMARY KEY AUTOINCREMENT"  "projectName varchar(50)" "procedureName varchar(50)" "preFlight int(1) DEFAULT 0" "preFlightUser varchar(50)" "branch varchar(50)" "doDbDump int(1) DEFAULT 0" "skipSystemTests int(1) DEFAULT 0" "skipServerUnitTests int(1) DEFAULT 0" 
                "skipOnWindows int(1) DEFAULT 0" "skipOnLinux int(1) DEFAULT 0"   "skipAgent64 int(1) DEFAULT 0" "skipSeparateAgentInstaller int(1) DEFAULT 0" 
                 "skipOnHpux int(1) DEFAULT 0" "skipOnMacintel int(1) DEFAULT 0"  "skipOnSol86 int(1) DEFAULT 0" "skipOnSolaris int(1) DEFAULT 0" "parallelModtest int(1) DEFAULT 0" "dbType varchar(50)"
                "preFlightTag varchar(50)" }
                procedure     { "id  INTEGER PRIMARY KEY AUTOINCREMENT" "proclist varchar(550)" }
                preflight      {"id  INTEGER PRIMARY KEY AUTOINCREMENT" "scm_id int(10) DEFAULT 0" "procedures_id int(10) DEFAULT 0"  "server_id int(10) DEFAULT 0"}
                preflights      {"id  INTEGER PRIMARY KEY AUTOINCREMENT" "xml varchar(5000)"}
                commits        { "id INTEGER PRIMARY KEY ASC" "content text NOT NULL" "date int(11) DEFAULT 0" "on_tasks text NOT NULL" "type_id int(11) DEFAULT 1" "created_at int(11) DEFAULT 0"}
                commit_types   { "id INTEGER PRIMARY KEY ASC" "name varchar(255) NOT NULL" "periodic_id int(11) DEFAULT 0"}
                periodics      { "id INTEGER PRIMARY KEY ASC" "name varchar(255) NOT NULL"}
                settings       { "id INTEGER PRIMARY KEY ASC" "key varchar(255) NOT NULL" "value varchar(255) NOT NULL" "type_id int(11) DEFAULT 1"}
                settings_types { "id INTEGER PRIMARY KEY ASC" "name varchar(255) NOT NULL"}
                schedules      { "id INTEGER PRIMARY KEY ASC" "event_type_id int(11) NOT NULL" "chat_room_id int(11) NOT NULL"  "time int(11) DEFAULT 0" "periodic_id int(11) DEFAULT 0"}
                event_types    { "id INTEGER PRIMARY KEY ASC" "name varchar(255) NOT NULL"}
                chat_rooms     { "id INTEGER PRIMARY KEY ASC" "name varchar(255) NOT NULL" "chat_id int(11) DEFAULT 0" "chat_oui int(11) DEFAULT 0"}
                admin_ka       { "id INTEGER PRIMARY KEY ASC" "user_name varchar(255) NOT NULL" "pswd varchar(255) NOT NULL" "mail varchar(255) NOT NULL" "key varchar(255) NOT NULL"}
                chats          { "id INTEGER PRIMARY KEY ASC" "name varchar(255) NOT NULL" }
                projectgroup   { "id INTEGER PRIMARY KEY ASC" "group_name text" }
    }
	foreach item  [array names tables ]  {
		set table_command [join $tables($item) " , "]
        set tablename $item
        append str_cmd "CREATE TABLE $tablename"
        append str_cmd "("
        append str_cmd $table_command
        append str_cmd ")"
		$db_id eval  $str_cmd
        unset str_cmd
    }
    #for testing:dont forget to  kill it
    db_fill_onstart $db_id
}

proc db_get_testreq {db_id} {
    set ltable [$db_id eval "SELECT * FROM tasks"]
	tk_messageBox -message  "$ltable"
}

#set path "G:/proj/TextRedactor/usr/store/mytest.db"
proc ::dbase::db_get_tasks { dbpath  } {
    sqlite3 dbcmd $dbpath
    set ltable [ dbcmd eval "SELECT * FROM tasks" ]
    dbcmd close
    return $ltable
}

#db_get_scm -
#   dbpath - path to database
#   return list from scm
proc ::dbase::db_get_scm { dbpath  } {
    sqlite3 dbcmd $dbpath
    set ltable [ dbcmd eval "SELECT * FROM scm" ]
    dbcmd close
    return $ltable
}
#db_get_from -
#   dbpath - path to database
#   return list from scm
proc ::dbase::db_get_from { dbpath  tableName } {
    sqlite3 dbcmd $dbpath
    set query "SELECT * FROM $tableName"
    set ltable [ dbcmd eval $query ]
    dbcmd close
    return $ltable
}
 
#db_get_procedures -
#   dbpath - path to database
#   return list from scm
proc ::dbase::db_get_procedure { dbpath  } {
    sqlite3 dbcmd $dbpath
    set ltable [ dbcmd eval "SELECT * FROM procedure" ]
    dbcmd close
    return $ltable
}


#db_get_taskgroup - 
#   dbpath  - path to database
#   return list of task group
proc ::dbase::db_get_taskgroup { dbpath  } {
    sqlite3 dbcmd $dbpath
    set lgroup_names [ dbcmd eval "SELECT group_name FROM projectgroup" ]
    dbcmd close
    return $lgroup_names
}

proc ::dbase::db_store_task { dbpath task } {
    sqlite3 dbcmd $dbpath
    array set data $task
                                                    #{ "id" "key" "project" "title " "description" "points " "status_id" "deadline" "created_at" "edited_at" }
    set name [ dbcmd eval {INSERT INTO tasks VALUES( NULL, $data(key) , $data(project) , $data(title) , $data(description) , $data(points) , $data(status_id) , $data(deadline) , $data(created_at), $data(edited_at)) }  ]
    dbcmd close
}

proc ::dbase::db_store_preflight { dbpath xml } {
    sqlite3 dbcmd $dbpath
    #array set data $task
                                                    #{ "id" "key" "project" "title " "description" "points " "status_id" "deadline" "created_at" "edited_at" }
    dbcmd eval "INSERT INTO preflights VALUES( NULL, \"$xml\" )"  ]
    dbcmd close
}


 #$db_id eval {INSERT INTO tasks VALUES( NULL, "" , 1 , "This is a title of issue", "This is big description of task  lets think about it together" , "" , "" , 12 , "12:12:12", 12) }

proc ::dbase::get_projname_byID { dbpath id } {
    sqlite3 dbcmd $dbpath
    set name [ dbcmd eval "SELECT group_name FROM projectgroup WHERE id=$id"     ]
    dbcmd close
    return $name
}

proc ::dbase::get_projID_byName { dbpath name } {
    sqlite3 dbcmd $dbpath
    set name [ dbcmd eval "SELECT id FROM projectgroup WHERE group_name=\"$name\""     ]
    dbcmd close
    return $name
}


#set path "G:/proj/TextRedactor/usr/store/mytest.db"
#file delete -force $path
#db_create $path  
#sqlite3 dbcmd $path
#---
#db_fill_onstart dbcmd
#db_get_testreq dbcmd

#---
#dbcmd close

#exit