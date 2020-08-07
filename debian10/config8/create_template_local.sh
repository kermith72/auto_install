#!/bin/bash
# create_template_local.sh
# version 1.05
# 07/08/2020
# change parameter network and disk interface
# version 1.04
# 29/05/2020
# bug fix cpu and swap
# version 1.03
# 14/10/2019
# add icone
# version 1.02
# 12/10/2019
# use debug
# version 1.01
# 20/05/2019
# use centreon-plugins fatpacked
# version 1.00
# 09/04/2019


create_cmd_local() {
	
  # cmd_os_linux_local_cpu
  exist_object CMD cmd_os_linux_local_cpu
  [ $? -ne 0 ] && exec_clapi CMD ADD 'cmd_os_linux_local_cpu;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=cpu --warning-average=$_SERVICEWARNING$ --critical-average=$_SERVICECRITICAL$ $_SERVICEOPTION$ '


  # cmd_os_linux_local_load
  exist_object CMD cmd_os_linux_local_load
  [ $? -ne 0 ] && exec_clapi CMD ADD 'cmd_os_linux_local_load;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=load --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEOPTION$ '

  # cmd_os_linux_local_swap
  exist_object CMD cmd_os_linux_local_swap
  [ $? -ne 0 ] && exec_clapi CMD ADD 'cmd_os_linux_local_swap;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=swap --warning-usage-prct=$_SERVICEWARNING$ --critical-usage-prct=$_SERVICECRITICAL$ $_SERVICEOPTION$ '

  # cmd_os_linux_local_memory
  exist_object CMD cmd_os_linux_local_memory
  [ $? -ne 0 ] && exec_clapi CMD ADD 'cmd_os_linux_local_memory;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=memory --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEOPTION$ '

  # cmd_os_linux_local_disk_name
  exist_object CMD cmd_os_linux_local_disk_name
  [ $? -ne 0 ] && exec_clapi CMD ADD 'cmd_os_linux_local_disk_name;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=storage --filter-mountpoint=$_SERVICEDISKNAME$ --warning-usage=$_SERVICEWARNING$ --critical-usage=$_SERVICECRITICAL$ $_SERVICEOPTION$ '

  # cmd_os_linux_local_network_name
  exist_object CMD cmd_os_linux_local_network_name
  [ $? -ne 0 ] && exec_clapi CMD ADD 'cmd_os_linux_local_network_name;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=traffic --speed=$_SERVICESPEED$ --filter-interface=$_SERVICEINTERFACE$ --warning-out=$_SERVICEWARNING$ --critical-out=$_SERVICECRITICAL$ --warning-in=$_SERVICEWARNING$ --critical-in=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
 
}

create_stpl_local () {

  ## CPU local
  #stpl_os_linux_local_cpu
  exist_object STPL stpl_os_linux_local_cpu
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_os_linux_local_cpu;cpu-local;service-generique-actif"
    exec_clapi STPL setparam "stpl_os_linux_local_cpu;check_command;cmd_os_linux_local_cpu"
    exec_clapi STPL setmacro "stpl_os_linux_local_cpu;WARNING;70"
    exec_clapi STPL setmacro "stpl_os_linux_local_cpu;CRITICAL;90"
    exec_clapi STPL setparam "stpl_os_linux_local_cpu;graphtemplate;CPU"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_os_linux_local_cpu;icon_image;Hardware/cpu2.png"
  fi
  
  ## LOAD
  #stpl_os_linux_local_load
  exist_object STPL stpl_os_linux_local_load
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_os_linux_local_load;Load-local;service-generique-actif"
    exec_clapi STPL setparam "stpl_os_linux_local_load;check_command;cmd_os_linux_local_load"
    exec_clapi STPL setmacro "stpl_os_linux_local_load;WARNING;4,3,2"
    exec_clapi STPL setmacro "stpl_os_linux_local_load;CRITICAL;6,5,4"
    exec_clapi STPL setparam "stpl_os_linux_local_load;graphtemplate;LOAD_Average"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_os_linux_local_load;icon_image;Hardware/load2.png"
  fi
  
  ## SWAP
  #stpl_os_linux_local_swap
  exist_object STPL stpl_os_linux_local_swap
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_os_linux_local_swap;Swap-local;service-generique-actif"
    exec_clapi STPL setparam "stpl_os_linux_local_swap;check_command;cmd_os_linux_local_swap"
    exec_clapi STPL setmacro "stpl_os_linux_local_swap;WARNING;80"
    exec_clapi STPL setmacro "stpl_os_linux_local_swap;CRITICAL;90"
    exec_clapi STPL setparam "stpl_os_linux_local_swap;graphtemplate;Memory"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_os_linux_local_swap;icon_image;Hardware/memory.png"
  fi
  
  ## MEMORY
  #stpl_os_linux_local_memory
  exist_object STPL stpl_os_linux_local_memory
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_os_linux_local_memory;Memory-local;service-generique-actif"
    exec_clapi STPL setparam "stpl_os_linux_local_memory;check_command;cmd_os_linux_local_memory"
    exec_clapi STPL setmacro "stpl_os_linux_local_memory;WARNING;70"
    exec_clapi STPL setmacro "stpl_os_linux_local_memory;CRITICAL;90"     
    exec_clapi STPL setparam "stpl_os_linux_local_memory;graphtemplate;Memory"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_os_linux_local_memory;icon_image;Hardware/memory2.png"
  fi

  ## DISK
  ## Modele Disk
  ###stpl_os_linux_local_disk_name
  exist_object STPL stpl_os_linux_local_disk_name
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_os_linux_local_disk_name;disk-local-name;service-generique-actif"
    exec_clapi STPL setparam "stpl_os_linux_local_disk_name;check_command;cmd_os_linux_local_disk_name"
    exec_clapi STPL setmacro "stpl_os_linux_local_disk_name;WARNING;80"
    exec_clapi STPL setmacro "stpl_os_linux_local_disk_name;CRITICAL;90"
    exec_clapi STPL setparam "stpl_os_linux_local_disk_name;graphtemplate;Storage"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_os_linux_local_disk_name;icon_image;Hardware/disque.png"
  fi

  ## TRAFFIC
  # stpl_os_linux_local_network_name
  exist_object STPL stpl_os_linux_local_network_name
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_os_linux_local_network_name;Traffic-local;service-generique-actif"
    exec_clapi STPL setparam "stpl_os_linux_local_network_name;check_command;cmd_os_linux_local_network_name"
    exec_clapi STPL setmacro "stpl_os_linux_local_network_name;WARNINGOUT;70"
    exec_clapi STPL setmacro "stpl_os_linux_local_network_name;CRITICALOUT;80"
    exec_clapi STPL setmacro "stpl_os_linux_local_network_name;WARNINGIN;70"
    exec_clapi STPL setmacro "stpl_os_linux_local_network_name;CRITICALIN;80"
    exec_clapi STPL setmacro "stpl_os_linux_local_network_name;SPEED;1000"
    exec_clapi STPL setmacro "stpl_os_linux_local_network_name;OPTION;--units=%"
    exec_clapi STPL setmacro "stpl_os_linux_local_network_name;INTERFACE;eth0"
    exec_clapi STPL setparam "stpl_os_linux_local_network_name;graphtemplate;Traffic"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_os_linux_local_network_name;icon_image;Other/traffic2.png"
  fi
}

create_linux_local () {

  ##OS-Linux-local
  exist_object HTPL htpl_OS-Linux-local
  if [ $? -ne 0 ]
  then
    exec_clapi HTPL add "htpl_OS-Linux-local;HTPL_OS-Linux-local;;;;"
    exec_clapi STPL addhost "stpl_os_linux_local_cpu;htpl_OS-Linux-local"
    exec_clapi STPL addhost "stpl_os_linux_local_load;htpl_OS-Linux-local"
    exec_clapi STPL addhost "stpl_os_linux_local_memory;htpl_OS-Linux-local"
    exec_clapi STPL addhost "stpl_os_linux_local_swap;htpl_OS-Linux-local"
    exec_clapi HTPL addtemplate "htpl_OS-Linux-local;generic-host"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi HTPL setparam "htpl_OS-Linux-local;icon_image;OS/linux.png"
  fi

}
