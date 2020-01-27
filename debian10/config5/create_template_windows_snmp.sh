#!/bin/bash
# create_template_windows_snmp.sh
# version 1.00
# 27/01/2020


create_cmd_windows_snmp() {
       
  # Commandes CPU SNMP 	
	

  # cmd_os_windows_snmp_swap
  exist_object CMD cmd_os_windows_snmp_swap
  [ $? -ne 0 ] && exec_clapi CMD ADD 'cmd_os_windows_snmp_swap;check;$CENTREONPLUGINS$/centreon_windows_snmp.pl --plugin=os::windows::snmp::plugin --mode=swap --host=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_HOSTOPTION$ $_SERVICEOPTION$'

  # cmd_os_windows_snmp_cpu
  exist_object CMD cmd_os_windows_snmp_cpu 
  [ $? -ne 0 ] && exec_clapi CMD ADD 'cmd_os_windows_snmp_cpu;check;$CENTREONPLUGINS$/centreon_windows_snmp.pl --plugin=os::windows::snmp::plugin --mode=cpu --hostname=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ --warning-average=$_SERVICEWARNING$ --critical-average=$_SERVICECRITICAL$ $_HOSTOPTION$ $_SERVICEOPTION$'

  # cmd_os_windows_snmp_memory
  exist_object CMD cmd_os_windows_snmp_memory
  [ $? -ne 0 ] && exec_clapi CMD ADD 'cmd_os_windows_snmp_memory;check;$CENTREONPLUGINS$/centreon_windows_snmp.pl --plugin=os::windows::snmp::plugin --mode=memory --hostname=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ --warning-memory=$_SERVICEWARNING$ --critical-memory=$_SERVICECRITICAL$ $_HOSTOPTION$ $_SERVICEOPTION$'

  # cmd_os_windows_snmp_disk_global
  exist_object CMD cmd_os_windows_snmp_disk_global
  [ $? -ne 0 ] && exec_clapi CMD ADD 'cmd_os_windows_snmp_disk_global;check;$CENTREONPLUGINS$/centreon_windows_snmp.pl --plugin=os::windows::snmp::plugin --mode=storage --hostname=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ --storage=$_SERVICEFILTER$ --name --regexp --warning-usage=$_SERVICEWARNING$ --critical-usage=$_SERVICECRITICAL$ $_HOSTOPTION$ $_SERVICEOPTION$'


}

create_stpl_windows_snmp() {

  ## CPU snmp
  #stpl_os_windows_snmp_cpu
  exist_object STPL stpl_os_windows_snmp_cpu
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_os_windows_snmp_cpu;cpu;service-generique-actif"
    exec_clapi STPL setparam "stpl_os_windows_snmp_cpu;check_command;cmd_os_windows_snmp_cpu"
    exec_clapi STPL setmacro "stpl_os_windows_snmp_cpu;WARNING;80"
    exec_clapi STPL setmacro "stpl_os_windows_snmp_cpu;CRITICAL;90"
    exec_clapi STPL setparam "stpl_os_windows_snmp_cpu;graphtemplate;CPU"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_os_windows_snmp_cpu;icon_image;Hardware/cpu2.png"
  fi


  ## SWAP SNMP
  #stpl_os_windows_snmp_swap
  exist_object STPL stpl_os_windows_snmp_swap
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_os_windows_snmp_swap;Load;service-generique-actif"
    exec_clapi STPL setparam "stpl_os_windows_snmp_swap;check_command;cmd_os_windows_snmp_swap"
    exec_clapi STPL setmacro "stpl_os_windows_snmp_swap;WARNING;80"
    exec_clapi STPL setmacro "stpl_os_windows_snmp_swap;CRITICAL;90"
    exec_clapi STPL setparam "stpl_os_windows_snmp_swap;graphtemplate;Memory"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_os_windows_snmp_swap;icon_image;Hardware/memory.png"
  fi

  ## MEMORY SNMP
  #stpl_os_windows_snmp_memory
  exist_object STPL stpl_os_windows_snmp_memory
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_os_windows_snmp_memory;Memory;service-generique-actif"
    exec_clapi STPL setparam "stpl_os_windows_snmp_memory;check_command;cmd_os_windows_snmp_memory"
    exec_clapi STPL setmacro "stpl_os_windows_snmp_memory;WARNING;80"
    exec_clapi STPL setmacro "stpl_os_windows_snmp_memory;CRITICAL;90"
    exec_clapi STPL setparam "stpl_os_windows_snmp_memory;graphtemplate;Memory"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_os_windows_snmp_memory;icon_image;Hardware/memory2.png"
  fi
  
  ## DISK Global SNMP
  #stpl_os_windows_snmp_disk_global
  exist_object STPL stpl_os_windows_snmp_disk_global
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_os_windows_snmp_disk_global;Disk-global;service-generique-actif"
    exec_clapi STPL setparam "stpl_os_windows_snmp_disk_global;check_command;cmd_os_windows_snmp_disk_global"
    exec_clapi STPL setmacro "stpl_os_windows_snmp_disk_global;FILTER;'.*'"
    exec_clapi STPL setmacro "stpl_os_windows_snmp_disk_global;WARNING;80"
    exec_clapi STPL setmacro "stpl_os_windows_snmp_disk_global;CRITICAL;90"
    exec_clapi STPL setparam "stpl_os_windows_snmp_disk_global;graphtemplate;Storage"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_os_windows_snmp_disk_global;icon_image;Hardware/disque.png"
  fi

}

create_windows_snmp () {
  
  ##OS-Windows-snmp
  exist_object HTPL htpl_OS-Windows-SNMP
  if [ $? -ne 0 ]
  then
    exec_clapi HTPL add "htpl_OS-Windows-SNMP;HTPL_OS-Windows-SNMP;;;;"
    exec_clapi STPL addhost "stpl_os_windows_snmp_cpu;htpl_OS-Windows-SNMP"
    exec_clapi STPL addhost "stpl_os_windows_snmp_swap;htpl_OS-Windows-SNMP"
    exec_clapi STPL addhost "stpl_os_windows_snmp_disk_global;htpl_OS-Windows-SNMP"
    exec_clapi STPL addhost "stpl_os_windows_snmp_memory;htpl_OS-Windows-SNMP"
    exec_clapi HTPL addtemplate "htpl_OS-Windows-SNMP;generic-host"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi HTPL setparam "htpl_OS-Windows-SNMP;icon_image;OS/windows.png"
  fi
}
