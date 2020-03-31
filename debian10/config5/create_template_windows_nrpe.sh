#!/bin/bash
# create_template_windows_nrpe.sh
# version 1.00
# 31/03/2020


create_cmd_windows_nrpe() {
       
  # Commandes nrpe 	
	

  # cmd_os_windows_nrpe_swap
  exist_object CMD cmd_os_windows_nrpe_swap
  [ $? -ne 0 ] && exec_clapi CMD ADD "cmd_os_windows_nrpe_swap;check;\$USER1\$/check_nrpe -H \$HOSTADDRESS\$ -t \$_HOSTTIMEOUT\$ -p \$_HOSTPORT\$ \$_HOSTOPTION\$  -c check_pagefile -a 'detail-syntax=\$_SERVICEDETAILSYNTAX\$' \"warning=\$_SERVICEWARNING\$\" \"critical=\$_SERVICECRITICAL\$\" \"perf-config=\$_SERVICEPERFCONFIG\$\" \"filter=\$_SERVICEFILTER\$\" \$_SERVICEOPTION\$"

  # cmd_os_windows_nrpe_cpu
  exist_object CMD cmd_os_windows_nrpe_cpu 
  [ $? -ne 0 ] && exec_clapi CMD ADD "cmd_os_windows_nrpe_cpu;check;\$USER1\$/check_nrpe -H \$HOSTADDRESS\$ -t \$_HOSTTIMEOUT\$ -p \$_HOSTPORT\$ \$_HOSTOPTION\$ -c check_cpu -a \"warning=\$_SERVICEWARNING\$\" \"critical=\$_SERVICECRITICAL\$\" \$_SERVICEOPTION\$"

  # cmd_os_windows_nrpe_memory
  exist_object CMD cmd_os_windows_nrpe_memory
  [ $? -ne 0 ] && exec_clapi CMD ADD "cmd_os_windows_nrpe_memory;check;\$USER1\$/check_nrpe -H \$HOSTADDRESS\$ -t \$_HOSTTIMEOUT\$ -p \$_HOSTPORT\$ \$_HOSTOPTION\$ -c check_memory -a 'detail-syntax=\$_SERVICEDETAILSYNTAX\$' \"warning=\$_SERVICEWARNING\$\" \"critical=\$_SERVICECRITICAL\$\" \"perf-config=\$_SERVICEPERFCONFIG\$\" \"filter=\$_SERVICEFILTER\$\" \$_SERVICEOPTION\$"

  # cmd_os_windows_nrpe_disk_global
  exist_object CMD cmd_os_windows_nrpe_disk_global
  [ $? -ne 0 ] && exec_clapi CMD ADD "cmd_os_windows_nrpe_disk_global;check;\$USER1\$/check_nrpe -H \$HOSTADDRESS\$ -t \$_HOSTTIMEOUT\$ -p \$_HOSTPORT\$ \$_HOSTOPTION\$ -c check_drivesize -a \"drive=\$_SERVICEDRIVE\$\" \"warning=\$_SERVICEWARNING\$\" \"critical=\$_SERVICECRITICAL\$\" \"perf-config=\$_SERVICEPERFCONFIG\$\" \"filter=\$_SERVICEFILTER\$\" \$_SERVICEOPTION\$"


}

create_stpl_windows_nrpe() {

  ## CPU nrpe
  #stpl_os_windows_nrpe_cpu
  exist_object STPL stpl_os_windows_nrpe_cpu
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_os_windows_nrpe_cpu;cpu;service-generique-actif"
    exec_clapi STPL setparam "stpl_os_windows_nrpe_cpu;check_command;cmd_os_windows_nrpe_cpu"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_cpu;WARNING;time = '5m' and load > 80"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_cpu;CRITICAL;time = '5m' and load > 90"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_cpu;OPTION;show-all"
    exec_clapi STPL setparam "stpl_os_windows_nrpe_cpu;graphtemplate;CPU"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_os_windows_nrpe_cpu;icon_image;Hardware/cpu2.png"
  fi


  ## SWAP nrpe
  #stpl_os_windows_nrpe_swap
  exist_object STPL stpl_os_windows_nrpe_swap
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_os_windows_nrpe_swap;swap;service-generique-actif"
    exec_clapi STPL setparam "stpl_os_windows_nrpe_swap;check_command;cmd_os_windows_nrpe_swap"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_swap;WARNING;none"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_swap;CRITICAL;used > 0"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_swap;DETAILSYNTAX;\${name} \${used} (\${size})"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_swap;PERFCONFIG;*(prefix:'used_')*(unit:B)%(ignored:true)"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_swap;FILTER;size > 0 and name = 'total'"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_swap;OPTION;perf-syntax=swap"
    exec_clapi STPL setparam "stpl_os_windows_nrpe_swap;graphtemplate;Memory"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_os_windows_nrpe_swap;icon_image;Hardware/memory.png"
  fi

  ## MEMORY nrpe
  #stpl_os_windows_nrpe_memory
  exist_object STPL stpl_os_windows_nrpe_memory
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_os_windows_nrpe_memory;Memory;service-generique-actif"
    exec_clapi STPL setparam "stpl_os_windows_nrpe_memory;check_command;cmd_os_windows_nrpe_memory"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_memory;WARNING;used > 80%"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_memory;CRITICAL;used > 90%"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_memory;DETAILSYNTAX;%(type) free: %(free) used: %(used) size: %(size)"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_memory;PERFCONFIG;used(unit:B)%(ignored:true)"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_memory;FILTER;type = 'physical'"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_memory;OPTION;perf-syntax=used"
    exec_clapi STPL setparam "stpl_os_windows_snmp_memory;graphtemplate;Memory"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_os_windows_snmp_memory;icon_image;Hardware/memory2.png"
  fi
  
  ## DISK Global nrpe
  #stpl_os_windows_nrpe_disk_global
  exist_object STPL stpl_os_windows_nrpe_disk_global
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_os_windows_nrpe_disk_global;Disk-global;service-generique-actif"
    exec_clapi STPL setparam "stpl_os_windows_nrpe_disk_global;check_command;cmd_os_windows_nrpe_disk_global"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_disk_global;DRIVE;*"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_disk_global;WARNING;total_used>80%"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_disk_global;CRITICAL;total_used>90%"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_disk_global;PERFCONFIG;used(unit:B)used %(ignored:true)"
    exec_clapi STPL setmacro "stpl_os_windows_nrpe_disk_global;FILTER;type = 'fixed' and name not regexp '.*yst.*'"
    exec_clapi STPL setparam "stpl_os_windows_nrpe_disk_global;graphtemplate;Storage"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_os_windows_nrpe_disk_global;icon_image;Hardware/disque.png"
  fi

}

create_windows_nrpe () {
  
  ##OS-Windows-nrpe
  exist_object HTPL htpl_OS-Windows-NRPE
  if [ $? -ne 0 ]
  then
    exec_clapi HTPL add "htpl_OS-Windows-NRPE;HTPL_OS-Windows-NRPE;;;;"
    exec_clapi HTPL setmacro "htpl_OS-Windows-NRPE;TIMEOUT;30"
    exec_clapi HTPL setmacro "htpl_OS-Windows-NRPE;PORT;5666"
    exec_clapi HTPL setmacro "htpl_OS-Windows-NRPE;OPTION;-u -2 -P 8192"
    exec_clapi STPL addhost "stpl_os_windows_nrpe_cpu;htpl_OS-Windows-NRPE"
    exec_clapi STPL addhost "stpl_os_windows_nrpe_swap;htpl_OS-Windows-NRPE"
    exec_clapi STPL addhost "stpl_os_windows_nrpe_disk_global;htpl_OS-Windows-NRPE"
    exec_clapi STPL addhost "stpl_os_windows_nrpe_memory;htpl_OS-Windows-NRPE"
    exec_clapi HTPL addtemplate "htpl_OS-Windows-NRPE;generic-host"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi HTPL setparam "htpl_OS-Windows-NRPE;icon_image;OS/windows.png"
  fi
}
