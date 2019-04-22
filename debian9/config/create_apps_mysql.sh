#!/bin/bash
# create_apps_mysql.sh
# version 1.00
# 09/04/2019

create_cmd_mysql() {
  
  #cmd_app_db_mysl
  exist_object CMD cmd_app_db_mysl
  [ $? -ne 0 ] &&   $CLAPI -o CMD -a ADD -v 'cmd_app_db_mysl;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=database::mysql::plugin --host=$HOSTADDRESS$ --mode=$_SERVICEMODE$ --username=$_HOSTMYSQLUSERNAME$ --password=$_HOSTMYSQLPASSWORD$  --port=$_HOSTMYSQLPORT$  --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
  
  exist_object CMD cmd_app_db_mysl_queries
  [ $? -ne 0 ] &&   $CLAPI -o CMD -a ADD -v 'cmd_app_db_mysl_queries;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=database::mysql::plugin --host=$HOSTADDRESS$ --mode=queries --username=$_HOSTMYSQLUSERNAME$ --password=$_HOSTMYSQLPASSWORD$  --port=$_HOSTMYSQLPORT$  --warning-total=$_SERVICEWARNING-TOTAL$ --critical-total=$_SERVICECRITICAL-TOTAL$ $_SERVICEOPTION$ '
	
}

create_stpl_mysql() {

  ## MySQL
  ## stpl_app_db_mysl
  exist_object STPL stpl_app_db_mysql
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_app_db_mysql;app_db_mysql;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_app_db_mysql;check_command;cmd_app_db_mysl"
    $CLAPI -o STPL -a setparam -v "stpl_app_db_mysql;service_is_volatile;2"
    $CLAPI -o STPL -a setparam -v "stpl_app_db_mysql;service_active_checks_enabled;2"
    $CLAPI -o STPL -a setparam -v "stpl_app_db_mysql;service_passive_checks_enabled;2"
    $CLAPI -o STPL -a setparam -v "stpl_app_db_mysql;service_parallelize_check;2"
    $CLAPI -o STPL -a setparam -v "stpl_app_db_mysql;service_obsess_over_service;2"
    $CLAPI -o STPL -a setparam -v "stpl_app_db_mysql;service_check_freshness;2"
    $CLAPI -o STPL -a setparam -v "stpl_app_db_mysql;service_event_handler_enabled;2"
    $CLAPI -o STPL -a setparam -v "stpl_app_db_mysql;service_flap_detection_enabled;2"
    $CLAPI -o STPL -a setparam -v "stpl_app_db_mysql;service_process_perf_data;2"
    $CLAPI -o STPL -a setparam -v "stpl_app_db_mysql;service_retain_status_information;2"
    $CLAPI -o STPL -a setparam -v "stpl_app_db_mysql;service_retain_nonstatus_information;2"
    $CLAPI -o STPL -a setparam -v "stpl_app_db_mysql;service_notifications_enabled;2"
  fi

  ##MySQL_connection-time
  ## stpl_app_db_mysl-connection-time
  exist_object STPL stpl_app_db_mysql-connection-time  
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_app_db_mysql-connection-time;MySQL_connection-time;stpl_app_db_mysql"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-connection-time;mode;connection-time"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-connection-time;warning;200"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-connection-time;critical;600"
  fi
  
  ###MySQL_qcache
  ## stpl_app_db_mysl-qcache-hitrate
  exist_object STPL stpl_app_db_mysql-qcache-hitrate  
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_app_db_mysql-qcache-hitrate;MySQL_qcache-hitrate;stpl_app_db_mysql"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-qcache-hitrate;critical;10:"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-qcache-hitrate;mode;qcache-hitrate"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-qcache-hitrate;option;--lookback"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-qcache-hitrate;warning;30:"
  fi

  ###MySQL_queries
  ## stpl_app_db_mysl-queries
  exist_object STPL stpl_app_db_mysql-queries  
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_app_db_mysql-queries;MySQL_queries;stpl_app_db_mysql"
    $CLAPI -o STPL -a setparam -v "stpl_app_db_mysql-queries;check_command;cmd_app_db_mysl_queries"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-queries;warning-total;200"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-queries;critical-total;300"
  fi

  ###MySQL_slow
  ## stpl_app_db_mysl-slow-queries
  exist_object STPL stpl_app_db_mysql-slow-queries  
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_app_db_mysql-slow-queries;MySQL_slow-queries;stpl_app_db_mysql"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-slow-queries;mode;slow-queries"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-slow-queries;warning;0.1"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-slow-queries;critical;0.2"
  fi
  
  ###MySQL_threads
  ## stpl_app_db_mysl-threads-connected
  exist_object STPL stpl_app_db_mysql-threads-connected  
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_app_db_mysql-threads-connected;MySQL_threads-connected;stpl_app_db_mysql"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-threads-connected;mode;threads-connected"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-threads-connected;warning;10"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-threads-connected;critical;20"
  fi

  ###MySQLdatabases
  ## stpl_app_db_mysl-databases-size
  exist_object STPL stpl_app_db_mysql-databases-size  
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_app_db_mysql-databases-size;MySQLdatabases-size;stpl_app_db_mysql"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-databases-size;mode;databases-size"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-databases-size;filter;centreon"
  fi

  ###MySQLdatabases
  ## stpl_app_db_mysl-databases-size_detail
  exist_object STPL stpl_app_db_mysql-databases-size_detail  
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_app_db_mysql-databases-size_detail;MySQLdatabases-size_detail;stpl_app_db_mysql"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-databases-size_detail;mode;databases-size"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-databases-size_detail;warning;200"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-databases-size_detail;critical;600"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-databases-size_detail;filter;centreon"
  fi

  ###MySQL_open-files
  ## stpl_app_db_mysl-open-files
  exist_object STPL stpl_app_db_mysql-open-files  
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_app_db_mysql-open-files;MySQL_open-files;stpl_app_db_mysql"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-open-files;mode;open-files"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-open-files;warning;60"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-open-files;critical;100"
  fi
  
  ###MySQL_long-queries
  ## stpl_app_db_mysl-long-queries
  exist_object STPL stpl_app_db_mysql-long-queries  
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_app_db_mysql-long-queries;MySQL_long-queries;stpl_app_db_mysql"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-long-queries;mode;long-queries"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-long-queries;warning;0.1"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-long-queries;critical;0.2"
  fi
  
  ###MySQL_uptime
  ## stpl_app_db_mysl-uptime
  exist_object STPL stpl_app_db_mysql-uptime  
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_app_db_mysql-uptime;MySQL_uptime;stpl_app_db_mysql"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-uptime;mode;uptime"
    #*********************** Warning 6 mois=15778800 Sec   Critical 1 ans=31557600 Sec *******************************
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-uptime;warning;15778800"
    $CLAPI -o STPL -a setmacro -v "stpl_app_db_mysql-uptime;critical;31557600"
  fi
}

create_apps_mysql () {

##App-MySQL-Serveur
  exist_object HTPL htpl_App-MySQL 
  if [ $? -ne 0 ]
  then
    $CLAPI -o HTPL -a add -v "htpl_App-MySQL;HTPL_App_MySQL;;;;"
    $CLAPI -o STPL -a addhost -v "stpl_app_db_mysql-connection-time;htpl_App-MySQL"
    $CLAPI -o STPL -a addhost -v "stpl_app_db_mysql-qcache-hitrate;htpl_App-MySQL"
    $CLAPI -o STPL -a addhost -v "stpl_app_db_mysql-queries;htpl_App-MySQL"
    $CLAPI -o STPL -a addhost -v "stpl_app_db_mysql-slow-queries;htpl_App-MySQL"
    $CLAPI -o STPL -a addhost -v "stpl_app_db_mysql-threads-connected;htpl_App-MySQL"
    $CLAPI -o STPL -a addhost -v "stpl_app_db_mysql-databases-size;htpl_App-MySQL"
    $CLAPI -o STPL -a addhost -v "stpl_app_db_mysql-open-files;htpl_App-MySQL"
    $CLAPI -o STPL -a addhost -v "stpl_app_db_mysql-long-queries;htpl_App-MySQL"
    $CLAPI -o STPL -a addhost -v "stpl_app_db_mysql-uptime;htpl_App-MySQL"
    $CLAPI -o HTPL -a setmacro -v "htpl_App-MySQL;MYSQLUSERNAME;"
    $CLAPI -o HTPL -a setmacro -v "htpl_App-MySQL;MYSQLPASSWORD;"
    $CLAPI -o HTPL -a setmacro -v "htpl_App-MySQL;MYSQLPORT;3306"
  fi
}
