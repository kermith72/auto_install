#!/bin/bash
# create_template_snmp.sh
# version 1.01
# 20/05/2019
# use centreon-plugins fatpacked
# version 1.00
# 09/04/2019
# use debug
# version 1.01
# 12/10/2019

create_cmd_snmp() {
  #-----------------------------------------------------------------------------------------------------------------------------------
  # Modes Available:
  #   connection-time
  #		 --warning
  #        --critical
  #   databases-size
  #		 --warning
  #        --critical
  #        --filter  
  #   innodb-bufferpool-hitrate
  #		 --warning
  #        --critical
  #        --lookback
  #   long-queries
  #		 --warning
  #        --critical
  #        --filter-user
  #        --filter-command
  #   myisam-keycache-hitrate
  #		 --warning
  #        --critical
  #        --lookback
  #   open-files
  #   qcache-hitrate
  #   queries
  #		 --warning-*  ->'total', 'update', 'insert','total', 'update', 'insert','delete', 'truncate', 'select', 'begin', 'commit'           
  #        --critical-* ->'total', 'update', 'insert','total', 'update', 'insert','delete', 'truncate', 'select', 'begin', 'commit' 
  #   replication-master-master
  #   replication-master-slave
  #   slow-queries
  #   sql
  #   sql-string
  #   tables-size
  #   threads-connected
  #   uptime
  #   cpu  
  #		 --warning-average
  #		 --critical-average
  #        --warning-core
  #        --critical-core         
  # Commandes CPU SNMP 	
	

  # check_centreon_plugin_load_SNMP
  exist_object CMD cmd_os_linux_snmp_load
  [ $? -ne 0 ] && exec_clapi CMD ADD 'cmd_os_linux_snmp_load;check;$CENTREONPLUGINS$/centreon_linux_snmp.pl --plugin=os::linux::snmp::plugin --mode=load --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ --host=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ $_HOSTOPTION$ $_SERVICEOPTION$'

  # check_centreon_plugin_cpu_SNMP
  exist_object CMD cmd_os_linux_snmp_cpu 
  [ $? -ne 0 ] && exec_clapi CMD ADD 'cmd_os_linux_snmp_cpu;check;$CENTREONPLUGINS$/centreon_linux_snmp.pl --plugin=os::linux::snmp::plugin --mode=cpu --warning-average=$_SERVICEWARNINGAVERAGE$ --critical-average=$_SERVICECRITICALAVERAGE$ --warning-core=$_SERVICEWARNINGCORE$ --critical-core=$_SERVICECRITICALCORE$ --host=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ $_HOSTOPTION$ $_SERVICEOPTION$'

  # check_centreon_plugin_memory_SNMP
  exist_object CMD cmd_os_linux_snmp_memory
  [ $? -ne 0 ] && exec_clapi CMD ADD 'cmd_os_linux_snmp_memory;check;$CENTREONPLUGINS$/centreon_linux_snmp.pl --plugin=os::linux::snmp::plugin --mode=memory --warning-usage=$_SERVICEWARNING$ --critical-usage=$_SERVICECRITICAL$ --host=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ $_HOSTOPTION$ $_SERVICEOPTION$'


  #check_centreon_plugin_SNMP_traffic
  exist_object CMD cmd_os_linux_snmp_traffic  
  [ $? -ne 0 ] && exec_clapi CMD ADD 'cmd_os_linux_snmp_traffic;check;$CENTREONPLUGINS$/centreon_linux_snmp.pl --plugin=os::linux::snmp::plugin --mode=interface --speed-in=$_SERVICESPEEDIN$ --speed-out=$_SERVICESPEEDOUT$ --interface=$_SERVICEINTERFACE$ --warning-in-traffic=$_SERVICEWARNINGIN$ --critical-in-traffic=$_SERVICECRITICALIN$ --warning-out-traffic=$_SERVICEWARNINGOUT$ --critical-out-traffic=$_SERVICECRITICALOUT$ --host=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ $_SERVICEOPTION$'

  #check processcount 
  exist_object CMD cmd_os_linux_snmp_process
  [ $? -ne 0 ] && exec_clapi CMD ADD 'cmd_os_linux_snmp_process;check;$CENTREONPLUGINS$/centreon_linux_snmp.pl --plugin=os::linux::snmp::plugin --mode=processcount --hostname=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ $_HOSTOPTION$ --process-name=$_SERVICEPROCESSNAME$ --process-path=$_SERVICEPROCESSPATH$ --process-args=$_SERVICEPROCESSARGS$ --regexp-name --regexp-path --regexp-args --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEOPTION$' 


  # cmd_os_linux_local_disk_name
  exist_object CMD cmd_os_linux_snmp_disk_name
  [ $? -ne 0 ] && exec_clapi CMD ADD 'cmd_os_linux_snmp_disk_name;check;$CENTREONPLUGINS$/centreon_linux_snmp.pl --plugin=os::linux::snmp::plugin --mode=storage --hostname=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ $_HOSTOPTION$ --name=$_SERVICEDISKNAME$ --warning-usage=$_SERVICEWARNING$ --critical-usage=$_SERVICECRITICAL$ $_SERVICEOPTION$ '

}

create_stpl_snmp() {

  ## CPU snmp
  #stpl_os_linux_snmp_cpu
  exist_object STPL stpl_os_linux_snmp_cpu
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_os_linux_snmp_cpu;cpu;service-generique-actif"
    exec_clapi STPL setparam "stpl_os_linux_snmp_cpu;check_command;cmd_os_linux_snmp_cpu"
    exec_clapi STPL setmacro "stpl_os_linux_snmp_cpu;WARNING;70"
    exec_clapi STPL setmacro "stpl_os_linux_snmp_cpu;CRITICAL;90"
    exec_clapi STPL setparam "stpl_os_linux_snmp_cpu;graphtemplate;CPU"
  fi


  ## LOAD SNMP
  #stpl_os_linux_snmp_load
  exist_object STPL stpl_os_linux_snmp_load
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_os_linux_snmp_load;Load;service-generique-actif"
    exec_clapi STPL setparam "stpl_os_linux_snmp_load;check_command;cmd_os_linux_snmp_load"
    exec_clapi STPL setmacro "stpl_os_linux_snmp_load;WARNING;4,3,2"
    exec_clapi STPL setmacro "stpl_os_linux_snmp_load;CRITICAL;6,5,4"
    exec_clapi STPL setparam "stpl_os_linux_snmp_load;graphtemplate;LOAD_Average"
  fi

  ## MEMORY SNMP
  #stpl_os_linux_snmp_memory
  exist_object STPL stpl_os_linux_snmp_memory
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_os_linux_snmp_memory;Memory;service-generique-actif"
    exec_clapi STPL setparam "stpl_os_linux_snmp_memory;check_command;cmd_os_linux_snmp_memory"
    exec_clapi STPL setmacro "stpl_os_linux_snmp_memory;WARNING;70"
    exec_clapi STPL setmacro "stpl_os_linux_snmp_memory;CRITICAL;90"
    exec_clapi STPL setparam "stpl_os_linux_snmp_memory;graphtemplate;Memory"
  fi
}

create_linux_snmp () {
  
  ##OS-Linux-snmp
  exist_object HTPL htpl_OS-Linux-SNMP
  if [ $? -ne 0 ]
  then
    exec_clapi HTPL add "htpl_OS-Linux-SNMP;HTPL_OS-Linux-SNMP;;;;"
    exec_clapi STPL addhost "stpl_os_linux_snmp_cpu;htpl_OS-Linux-SNMP"
    exec_clapi STPL addhost "stpl_os_linux_snmp_load;htpl_OS-Linux-SNMP"
    exec_clapi STPL addhost "stpl_os_linux_snmp_memory;htpl_OS-Linux-SNMP"
    exec_clapi HTPL addtemplate "htpl_OS-Linux-SNMP;generic-host"
  fi
}
