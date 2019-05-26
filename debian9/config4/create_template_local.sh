#!/bin/bash
# create_template_local.sh
# version 1.01
# 20/05/2019
# use centreon-plugins fatpacked
# version 1.00
# 09/04/2019

create_cmd_local() {
	
  # cmd_os_linux_local_cpu
  exist_object CMD cmd_os_linux_local_cpu
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_cpu;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=cpu --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEOPTION$ '

  #-----------------------------------------------------------------------------------------------------------------------------------
  # Modes Available:
  #   cpu  
  #		 --warning-average
  #		 --critical-average
  #        --warning-core
  #        --critical-core         
  #   cpu-detailed
  #		 --warning-*  ->'user', 'nice', 'system','idle', 'wait', 'kernel', 'interrupt', 'softirq', 'steal','guest', 'guestnice'
  #        --critical-* ->'user', 'nice', 'system','idle', 'wait', 'kernel', 'interrupt', 'softirq', 'steal','guest', 'guestnice'
  # Commandes CPU SNMP 
  #cmd_os_linux_local_cpu
  exist_object CMD cmd_os_linux_local_cpu-average
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_cpu-average;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=cpu --warning-average=$_SERVICEWARNING$ --critical-average=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
  
  exist_object CMD cmd_os_linux_local_cpu-core
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_cpu-core;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=cpu --warning-core=$_SERVICEWARNING$ --critical-core=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
  
  # cmd_os_linux_local_cpu-detailed
  exist_object CMD cmd_os_linux_local_cpu-det-user
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_cpu-det-user;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=cpu-detailed --warning-user=$_SERVICEWARNING$ --critical-user=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
  
  exist_object CMD cmd_os_linux_local_cpu-det-nice
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_cpu-det-nice;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=cpu-detailed --warning-nice=$_SERVICEWARNING$ --critical-nice=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
  
  exist_object CMD cmd_os_linux_local_cpu-det-system
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_cpu-det-system;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=cpu-detailed --warning-system=$_SERVICEWARNING$ --critical-system=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
  
  exist_object CMD cmd_os_linux_local_cpu-det-idle
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_cpu-det-idle;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=cpu-detailed --warning-idle=$_SERVICEWARNING$ --critical-idle=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
  
  exist_object CMD cmd_os_linux_local_cpu-det-wait
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_cpu-det-wait;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=cpu-detailed --warning-wait=$_SERVICEWARNING$ --critical-wait=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
  
  exist_object CMD cmd_os_linux_local_cpu-det-kernel
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_cpu-det-kernel;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=cpu-detailed --warning-kernel=$_SERVICEWARNING$ --critical-kernel=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
  
  exist_object CMD cmd_os_linux_local_cpu-det-interrupt
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_cpu-det-interrupt;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=cpu-detailed --warning-interrupt=$_SERVICEWARNING$ --critical-interrupt=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
  
  exist_object CMD cmd_os_linux_local_cpu-det-softirq
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_cpu-det-softirq;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=cpu-detailed --warning-softirq=$_SERVICEWARNING$ --critical-softirq=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
  
  exist_object CMD cmd_os_linux_local_cpu-det-steal
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_cpu-det-steal;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=cpu-detailed --warning-steal=$_SERVICEWARNING$ --critical-steal=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
  
  exist_object CMD cmd_os_linux_local_cpu-det-guest
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_cpu-det-guest;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=cpu-detailed --warning-guest=$_SERVICEWARNING$ --critical-guest=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
  
  exist_object CMD cmd_os_linux_local_cpu-det-guestnice
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_cpu-det-guestnice;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=cpu-detailed --warning-guestnice=$_SERVICEWARNING$ --critical-guestnice=$_SERVICECRITICAL$ $_SERVICEOPTION$ '


  # cmd_os_linux_local_load
  exist_object CMD cmd_os_linux_local_load
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_load;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=load --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEOPTION$ '

  # cmd_os_linux_local_swap
  exist_object CMD cmd_os_linux_local_swap
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_swap;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=swap --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEOPTION$ '

  # cmd_os_linux_local_memory
  exist_object CMD cmd_os_linux_local_memory
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_memory;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=memory --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEOPTION$ '

  # cmd_os_linux_local_disk_name
  exist_object CMD cmd_os_linux_local_disk_name
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_disk_name;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=storage --name=$_SERVICEDISKNAME$ --warning-usage=$_SERVICEWARNING$ --critical-usage=$_SERVICECRITICAL$ $_SERVICEOPTION$ '

  # cmd_os_linux_local_network_name
  exist_object CMD cmd_os_linux_local_network_name
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_network_name;check;$CENTREONPLUGINS$/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=traffic --speed=$_SERVICESPEED$ --name=$_SERVICEINTERFACE$ --warning-out=$_SERVICEWARNING$ --critical-out=$_SERVICECRITICAL$ --warning-in=$_SERVICEWARNING$ --critical-in=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
 
}

create_stpl_local () {

  ## CPU local
  #stpl_os_linux_local_cpu
  exist_object STPL stpl_os_linux_local_cpu
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_cpu;cpu-local;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu;check_command;cmd_os_linux_local_cpu"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu;WARNING;70"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu;CRITICAL;90"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu;graphtemplate;CPU"
  fi

  ## Services MODELES CPU local
  #stpl_os_linux_local_cpu-average
  exist_object STPL stpl_os_linux_local_cpu-average
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_cpu-average;cpu-average;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-average;check_command;cmd_os_linux_local_cpu-average"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-average;WARNING;70"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-average;CRITICAL;90"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-average;graphtemplate;CPU"
  fi
  
  #stpl_os_linux_local_cpu-core
  exist_object STPL stpl_os_linux_local_cpu-core
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_cpu-core;cpu-core;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-core;check_command;cmd_os_linux_local_cpu-core"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-core;WARNING;70"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-core;CRITICAL;90"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-core;graphtemplate;CPU"
  fi
  
  #stpl_os_linux_local_cpu-det-user
  exist_object STPL stpl_os_linux_local_cpu-det-user
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_cpu-det-user;cpu-det-user;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-user;check_command;cmd_os_linux_local_cpu-det-user"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-user;WARNING;70"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-user;CRITICAL;90"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-user;graphtemplate;CPU"
  fi
  
  #stpl_os_linux_local_cpu-det-nice
  exist_object STPL stpl_os_linux_local_cpu-det-nice
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_cpu-det-nice;cpu-det-nice;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-nice;check_command;cmd_os_linux_local_cpu-det-nice"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-nice;WARNING;70"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-nice;CRITICAL;90"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-nice;graphtemplate;CPU"
  fi
  
  #stpl_os_linux_local_cpu-det-system
  exist_object STPL stpl_os_linux_local_cpu-det-system
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_cpu-det-system;cpu-det-system;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-system;check_command;cmd_os_linux_local_cpu-det-system"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-system;WARNING;70"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-system;CRITICAL;90"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-system;graphtemplate;CPU"
  fi
  
  #stpl_os_linux_local_cpu-det-idle
  exist_object STPL stpl_os_linux_local_cpu-det-idle
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_cpu-det-idle;cpu-det-idle;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-idle;check_command;cmd_os_linux_local_cpu-det-idle"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-idle;WARNING;70"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-idle;CRITICAL;90"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-idle;graphtemplate;CPU"
  fi
  
  #stpl_os_linux_local_cpu-det-wait
  exist_object STPL stpl_os_linux_local_cpu-det-wait
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_cpu-det-wait;cpu-det-wait;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-wait;check_command;cmd_os_linux_local_cpu-det-wait"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-wait;WARNING;70"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-wait;CRITICAL;90"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-wait;graphtemplate;CPU"
  fi
  
  #stpl_os_linux_local_cpu-det-kernel
  exist_object STPL stpl_os_linux_local_cpu-det-kernel
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_cpu-det-kernel;cpu-det-kernel;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-kernel;check_command;cmd_os_linux_local_cpu-det-kernel"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-kernel;WARNING;70"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-kernel;CRITICAL;90"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-kernel;graphtemplate;CPU"
  fi
  
  #stpl_os_linux_local_cpu-det-interrupt
  exist_object STPL stpl_os_linux_local_cpu-det-interrupt
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_cpu-det-interrupt;cpu-det-interrupt;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-interrupt;check_command;cmd_os_linux_local_cpu-det-interrupt"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-interrupt;WARNING;70"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-interrupt;CRITICAL;90"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-interrupt;graphtemplate;CPU"
  fi
  
  #stpl_os_linux_local_cpu-det-softirq
  exist_object STPL stpl_os_linux_local_cpu-det-softirq
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_cpu-det-softirq;cpu-det-softirq;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-softirq;check_command;cmd_os_linux_local_cpu-det-softirq"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-softirq;WARNING;70"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-softirq;CRITICAL;90"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-softirq;graphtemplate;CPU"
  fi
  
  #stpl_os_linux_local_cpu-det-steal
  exist_object STPL stpl_os_linux_local_cpu-det-steal
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_cpu-det-steal;cpu-det-steal;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-steal;check_command;cmd_os_linux_local_cpu-det-steal"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-steal;WARNING;70"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-steal;CRITICAL;90"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-steal;graphtemplate;CPU"
  fi
  
  #stpl_os_linux_local_cpu-det-guest
  exist_object STPL stpl_os_linux_local_cpu-det-guest
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_cpu-det-guest;cpu-det-guest;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-guest;check_command;cmd_os_linux_local_cpu-det-guest"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-guest;WARNING;70"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-guest;CRITICAL;90"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-guest;graphtemplate;CPU"
  fi
  
  #stpl_os_linux_local_cpu-det-guestnice
  exist_object STPL stpl_os_linux_local_cpu-det-guestnice
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_cpu-det-guestnice;cpu-det-guestnice;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-guestnice;check_command;cmd_os_linux_local_cpu-det-guestnice"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-guestnice;WARNING;70"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu-det-guestnice;CRITICAL;90"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu-det-guestnice;graphtemplate;CPU"
  fi
  
  ## LOAD
  #stpl_os_linux_local_load
  exist_object STPL stpl_os_linux_local_load
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_load;Load-local;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_load;check_command;cmd_os_linux_local_load"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_load;WARNING;4,3,2"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_load;CRITICAL;6,5,4"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_load;graphtemplate;LOAD_Average"
  fi
  
  ## SWAP
  #stpl_os_linux_local_swap
  exist_object STPL stpl_os_linux_local_swap
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_swap;Swap-local;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_swap;check_command;cmd_os_linux_local_swap"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_swap;WARNING;80"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_swap;CRITICAL;90"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_swap;graphtemplate;Memory"
  fi
  
  ## MEMORY
  #stpl_os_linux_local_memory
  exist_object STPL stpl_os_linux_local_memory
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_memory;Memory-local;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_memory;check_command;cmd_os_linux_local_memory"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_memory;WARNING;70"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_memory;CRITICAL;90"     
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_memory;graphtemplate;Memory"
  fi

  ## DISK
  ## Modele Disk
  ###stpl_os_linux_local_disk_name
  exist_object STPL stpl_os_linux_local_disk_name
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_disk_name;disk-local-name;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_disk_name;check_command;cmd_os_linux_local_disk_name"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_disk_name;WARNING;80"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_disk_name;CRITICAL;90"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_disk_name;graphtemplate;Storage"
  fi

  ## TRAFFIC
  # stpl_os_linux_local_network_name
  exist_object STPL stpl_os_linux_local_network_name
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "stpl_os_linux_local_network_name;Traffic-local;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_network_name;check_command;cmd_os_linux_local_network_name"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_network_name;WARNINGOUT;70"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_network_name;CRITICALOUT;80"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_network_name;WARNINGIN;70"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_network_name;CRITICALIN;80"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_network_name;SPEED;1000"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_network_name;OPTION;--units=%"
    $CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_network_name;INTERFACE;eth0"
    $CLAPI -o STPL -a setparam -v "stpl_os_linux_local_network_name;graphtemplate;Traffic"
  fi
}

create_linux_local () {

  ##OS-Linux-local
  exist_object HTPL htpl_OS-Linux-local
  if [ $? -ne 0 ]
  then
    $CLAPI -o HTPL -a add -v "htpl_OS-Linux-local;HTPL_OS-Linux-local;;;;"
    $CLAPI -o STPL -a addhost -v "stpl_os_linux_local_cpu;htpl_OS-Linux-local"
    $CLAPI -o STPL -a addhost -v "stpl_os_linux_local_load;htpl_OS-Linux-local"
    $CLAPI -o STPL -a addhost -v "stpl_os_linux_local_memory;htpl_OS-Linux-local"
    $CLAPI -o STPL -a addhost -v "stpl_os_linux_local_swap;htpl_OS-Linux-local"
    $CLAPI -o HTPL -a addtemplate -v "htpl_OS-Linux-local;generic-host"
  fi

}
