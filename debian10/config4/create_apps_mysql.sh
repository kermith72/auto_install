#!/bin/bash
# create_apps_mysql.sh
# version 1.03
# 12/10/2019
# use debug
# version 1.02
# 09/07/2019
# modify plugin sql mode threads-connected
# version 1.01
# 20/05/2019
# use centreon-plugins fatpacked
# version 1.00
# 09/04/2019

create_cmd_mysql() {
  
  #cmd_app_db_mysl
  exist_object CMD cmd_app_db_mysl
  [ $? -ne 0 ] &&   exec_clapi CMD ADD 'cmd_app_db_mysl;check;$CENTREONPLUGINS$/centreon_mysql.pl --plugin=database::mysql::plugin --host=$HOSTADDRESS$ --mode=$_SERVICEMODE$ --username=$_HOSTMYSQLUSERNAME$ --password=$_HOSTMYSQLPASSWORD$  --port=$_HOSTMYSQLPORT$  --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
  
  exist_object CMD cmd_app_db_mysl_queries
  [ $? -ne 0 ] &&   exec_clapi CMD ADD 'cmd_app_db_mysl_queries;check;$CENTREONPLUGINS$/centreon_mysql.pl --plugin=database::mysql::plugin --host=$HOSTADDRESS$ --mode=queries --username=$_HOSTMYSQLUSERNAME$ --password=$_HOSTMYSQLPASSWORD$  --port=$_HOSTMYSQLPORT$  --warning-total=$_SERVICEWARNING-TOTAL$ --critical-total=$_SERVICECRITICAL-TOTAL$ $_SERVICEOPTION$ '

  exist_object CMD cmd_app_db_mysl_threads-connected
  [ $? -ne 0 ] &&   exec_clapi CMD ADD 'cmd_app_db_mysl_threads-connected;check;$CENTREONPLUGINS$/centreon_mysql.pl --plugin=database::mysql::plugin --host=$HOSTADDRESS$ --mode=threads-connected --username=$_HOSTMYSQLUSERNAME$ --password=$_HOSTMYSQLPASSWORD$  --port=$_HOSTMYSQLPORT$  --warning-usage=$_SERVICEWARNING$ --critical-usage=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
	
}

create_stpl_mysql() {

  ## MySQL
  ## stpl_app_db_mysl
  exist_object STPL stpl_app_db_mysql
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_db_mysql;app_db_mysql;service-generique-actif"
    exec_clapi STPL setparam "stpl_app_db_mysql;check_command;cmd_app_db_mysl"
    exec_clapi STPL setparam "stpl_app_db_mysql;service_is_volatile;2"
    exec_clapi STPL setparam "stpl_app_db_mysql;service_active_checks_enabled;2"
    exec_clapi STPL setparam "stpl_app_db_mysql;service_passive_checks_enabled;2"
    exec_clapi STPL setparam "stpl_app_db_mysql;service_parallelize_check;2"
    exec_clapi STPL setparam "stpl_app_db_mysql;service_obsess_over_service;2"
    exec_clapi STPL setparam "stpl_app_db_mysql;service_check_freshness;2"
    exec_clapi STPL setparam "stpl_app_db_mysql;service_event_handler_enabled;2"
    exec_clapi STPL setparam "stpl_app_db_mysql;service_flap_detection_enabled;2"
    exec_clapi STPL setparam "stpl_app_db_mysql;service_process_perf_data;2"
    exec_clapi STPL setparam "stpl_app_db_mysql;service_retain_status_information;2"
    exec_clapi STPL setparam "stpl_app_db_mysql;service_retain_nonstatus_information;2"
    exec_clapi STPL setparam "stpl_app_db_mysql;service_notifications_enabled;2"
  fi

  ##MySQL_connection-time
  ## stpl_app_db_mysl-connection-time
  exist_object STPL stpl_app_db_mysql-connection-time  
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_db_mysql-connection-time;MySQL_connection-time;stpl_app_db_mysql"
    exec_clapi STPL setmacro "stpl_app_db_mysql-connection-time;mode;connection-time"
    exec_clapi STPL setmacro "stpl_app_db_mysql-connection-time;warning;200"
    exec_clapi STPL setmacro "stpl_app_db_mysql-connection-time;critical;600"
  fi
  
  ###MySQL_qcache
  ## stpl_app_db_mysl-qcache-hitrate
  exist_object STPL stpl_app_db_mysql-qcache-hitrate  
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_db_mysql-qcache-hitrate;MySQL_qcache-hitrate;stpl_app_db_mysql"
    exec_clapi STPL setmacro "stpl_app_db_mysql-qcache-hitrate;critical;10:"
    exec_clapi STPL setmacro "stpl_app_db_mysql-qcache-hitrate;mode;qcache-hitrate"
    exec_clapi STPL setmacro "stpl_app_db_mysql-qcache-hitrate;option;--lookback"
    exec_clapi STPL setmacro "stpl_app_db_mysql-qcache-hitrate;warning;30:"
  fi

  ###MySQL_queries
  ## stpl_app_db_mysl-queries
  exist_object STPL stpl_app_db_mysql-queries  
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_db_mysql-queries;MySQL_queries;stpl_app_db_mysql"
    exec_clapi STPL setparam "stpl_app_db_mysql-queries;check_command;cmd_app_db_mysl_queries"
    exec_clapi STPL setmacro "stpl_app_db_mysql-queries;warning-total;200"
    exec_clapi STPL setmacro "stpl_app_db_mysql-queries;critical-total;300"
  fi

  ###MySQL_slow
  ## stpl_app_db_mysl-slow-queries
  exist_object STPL stpl_app_db_mysql-slow-queries  
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_db_mysql-slow-queries;MySQL_slow-queries;stpl_app_db_mysql"
    exec_clapi STPL setmacro "stpl_app_db_mysql-slow-queries;mode;slow-queries"
    exec_clapi STPL setmacro "stpl_app_db_mysql-slow-queries;warning;0.1"
    exec_clapi STPL setmacro "stpl_app_db_mysql-slow-queries;critical;0.2"
  fi
  
  ###MySQL_threads
  ## stpl_app_db_mysl-threads-connected
  exist_object STPL stpl_app_db_mysql-threads-connected  
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_db_mysql-threads-connected;MySQL_threads-connected;stpl_app_db_mysql"
    exec_clapi STPL setparam "stpl_app_db_mysql-threads-connected;check_command;cmd_app_db_mysl_threads-connected"
    exec_clapi STPL setmacro "stpl_app_db_mysql-threads-connected;warning;10"
    exec_clapi STPL setmacro "stpl_app_db_mysql-threads-connected;critical;20"
  fi

  ###MySQLdatabases
  ## stpl_app_db_mysl-databases-size
  exist_object STPL stpl_app_db_mysql-databases-size  
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_db_mysql-databases-size;MySQLdatabases-size;stpl_app_db_mysql"
    exec_clapi STPL setmacro "stpl_app_db_mysql-databases-size;mode;databases-size"
    exec_clapi STPL setmacro "stpl_app_db_mysql-databases-size;filter;centreon"
  fi

  ###MySQLdatabases
  ## stpl_app_db_mysl-databases-size_detail
  exist_object STPL stpl_app_db_mysql-databases-size_detail  
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_db_mysql-databases-size_detail;MySQLdatabases-size_detail;stpl_app_db_mysql"
    exec_clapi STPL setmacro "stpl_app_db_mysql-databases-size_detail;mode;databases-size"
    exec_clapi STPL setmacro "stpl_app_db_mysql-databases-size_detail;warning;200"
    exec_clapi STPL setmacro "stpl_app_db_mysql-databases-size_detail;critical;600"
    exec_clapi STPL setmacro "stpl_app_db_mysql-databases-size_detail;filter;centreon"
  fi

  ###MySQL_open-files
  ## stpl_app_db_mysl-open-files
  exist_object STPL stpl_app_db_mysql-open-files  
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_db_mysql-open-files;MySQL_open-files;stpl_app_db_mysql"
    exec_clapi STPL setmacro "stpl_app_db_mysql-open-files;mode;open-files"
    exec_clapi STPL setmacro "stpl_app_db_mysql-open-files;warning;60"
    exec_clapi STPL setmacro "stpl_app_db_mysql-open-files;critical;100"
  fi
  
  ###MySQL_long-queries
  ## stpl_app_db_mysl-long-queries
  exist_object STPL stpl_app_db_mysql-long-queries  
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_db_mysql-long-queries;MySQL_long-queries;stpl_app_db_mysql"
    exec_clapi STPL setmacro "stpl_app_db_mysql-long-queries;mode;long-queries"
    exec_clapi STPL setmacro "stpl_app_db_mysql-long-queries;warning;0.1"
    exec_clapi STPL setmacro "stpl_app_db_mysql-long-queries;critical;0.2"
  fi
  
  ###MySQL_uptime
  ## stpl_app_db_mysl-uptime
  exist_object STPL stpl_app_db_mysql-uptime  
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_db_mysql-uptime;MySQL_uptime;stpl_app_db_mysql"
    exec_clapi STPL setmacro "stpl_app_db_mysql-uptime;mode;uptime"
    #*********************** Warning 6 mois=15778800 Sec   Critical 1 ans=31557600 Sec *******************************
    exec_clapi STPL setmacro "stpl_app_db_mysql-uptime;warning;15778800"
    exec_clapi STPL setmacro "stpl_app_db_mysql-uptime;critical;31557600"
  fi
}

create_apps_mysql () {

##App-MySQL-Serveur
  exist_object HTPL htpl_App-MySQL 
  if [ $? -ne 0 ]
  then
    exec_clapi HTPL add "htpl_App-MySQL;HTPL_App_MySQL;;;;"
    exec_clapi STPL addhost "stpl_app_db_mysql-connection-time;htpl_App-MySQL"
    exec_clapi STPL addhost "stpl_app_db_mysql-qcache-hitrate;htpl_App-MySQL"
    exec_clapi STPL addhost "stpl_app_db_mysql-queries;htpl_App-MySQL"
    exec_clapi STPL addhost "stpl_app_db_mysql-slow-queries;htpl_App-MySQL"
    exec_clapi STPL addhost "stpl_app_db_mysql-threads-connected;htpl_App-MySQL"
    exec_clapi STPL addhost "stpl_app_db_mysql-databases-size;htpl_App-MySQL"
    exec_clapi STPL addhost "stpl_app_db_mysql-open-files;htpl_App-MySQL"
    exec_clapi STPL addhost "stpl_app_db_mysql-long-queries;htpl_App-MySQL"
    exec_clapi STPL addhost "stpl_app_db_mysql-uptime;htpl_App-MySQL"
    exec_clapi HTPL setmacro "htpl_App-MySQL;MYSQLUSERNAME;"
    exec_clapi HTPL setmacro "htpl_App-MySQL;MYSQLPASSWORD;"
    exec_clapi HTPL setmacro "htpl_App-MySQL;MYSQLPORT;3306"
  fi
}
