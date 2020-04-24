#!/bin/bash
# create_apps_centreon.sh
# version 1.00
# 24/04/2020
# for v 20.04.0

create_stpl_poller () {

  ###SNMP Process centengine
  ## stpl_app_centreon_process-engine
  exist_object STPL stpl_app_centreon_process-engine
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_centreon_process-engine;process-engine;service-generique-actif"
    exec_clapi STPL setparam "stpl_app_centreon_process-engine;check_command;cmd_os_linux_snmp_process"
    exec_clapi STPL setmacro "stpl_app_centreon_process-engine;PROCESSNAME;centengine"
    exec_clapi STPL setmacro "stpl_app_centreon_process-engine;CRITICAL;1:1"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_app_centreon_process-engine;icon_image;Hardware/process2.png"
  fi
  
  ###SNMP Process ntpd
  ## stpl_app_centreon_process-ntpd
  exist_object STPL stpl_app_centreon_process-ntpd
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_centreon_process-ntpd;process-ntpd;service-generique-actif"
    exec_clapi STPL setparam "stpl_app_centreon_process-ntpd;check_command;cmd_os_linux_snmp_process"
    exec_clapi STPL setmacro "stpl_app_centreon_process-ntpd;PROCESSNAME;ntpd"
    exec_clapi STPL setmacro "stpl_app_centreon_process-ntpd;CRITICAL;1:1"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_app_centreon_process-ntpd;icon_image;Hardware/process2.png"
  fi
  
  ###SNMP Process sshd
  ## stpl_app_centreon_process-sshd
  exist_object STPL stpl_app_centreon_process-sshd
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_centreon_process-sshd;process-sshd;service-generique-actif"
    exec_clapi STPL setparam "stpl_app_centreon_process-sshd;check_command;cmd_os_linux_snmp_process"
    exec_clapi STPL setmacro "stpl_app_centreon_process-sshd;PROCESSNAME;ssh"
    exec_clapi STPL setmacro "stpl_app_centreon_process-sshd;CRITICAL;1:"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_app_centreon_process-sshd;icon_image;Hardware/process2.png"
  fi
}

create_stpl_central () {
	
  ###SNMP Process cron
  ## stpl_app_centreon_process-cron
  exist_object STPL stpl_app_centreon_process-cron
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_centreon_process-cron;process-cron;service-generique-actif"
    exec_clapi STPL setparam "stpl_app_centreon_process-cron;check_command;cmd_os_linux_snmp_process"
    exec_clapi STPL setmacro "stpl_app_centreon_process-cron;PROCESSNAME;cron"
    exec_clapi STPL setmacro "stpl_app_centreon_process-cron;CRITICAL;1:"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_app_centreon_process-cron;icon_image;Hardware/process2.png"
  fi
  
  ###SNMP Process gorgoned
  ## stpl_app_centreon_process-gorgoned
  exist_object STPL stpl_app_centreon_process-gorgoned
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_centreon_process-gorgoned;process-gorgoned;service-generique-actif"
    exec_clapi STPL setparam "stpl_app_centreon_process-gorgoned;check_command;cmd_os_linux_snmp_process"
    exec_clapi STPL setmacro "stpl_app_centreon_process-gorgoned;PROCESSNAME;'perl'"
    exec_clapi STPL setmacro "stpl_app_centreon_process-gorgoned;PROCESSARGS;'/usr/bin/gorgoned'"
    exec_clapi STPL setmacro "stpl_app_centreon_process-gorgoned;CRITICAL;1:1"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_app_centreon_process-gorgoned;icon_image;Hardware/process2.png"
  fi
  
  ###SNMP Process broker-sql
  ## stpl_app_centreon_process-broker-sql
  exist_object STPL stpl_app_centreon_process-broker-sql
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_centreon_process-broker-sql;process-broker-sql;service-generique-actif"
    exec_clapi STPL setparam "stpl_app_centreon_process-broker-sql;check_command;cmd_os_linux_snmp_process"
    exec_clapi STPL setmacro "stpl_app_centreon_process-broker-sql;PROCESSNAME;cbd"
    exec_clapi STPL setmacro "stpl_app_centreon_process-broker-sql;PROCESSARGS;'/etc/centreon-broker/central-broker(.xml|.json)'"
    exec_clapi STPL setmacro "stpl_app_centreon_process-broker-sql;CRITICAL;1:1"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_app_centreon_process-broker-sql;icon_image;Hardware/process2.png"
  fi

  ###SNMP Process broker-rrd
  ## stpl_app_centreon_process-broker-rrd
  exist_object STPL stpl_app_centreon_process-broker-rrd
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_centreon_process-broker-rrd;process-broker-rrd;service-generique-actif"
    exec_clapi STPL setparam "stpl_app_centreon_process-broker-rrd;check_command;cmd_os_linux_snmp_process"
    exec_clapi STPL setmacro "stpl_app_centreon_process-broker-rrd;PROCESSNAME;cbd"
    exec_clapi STPL setmacro "stpl_app_centreon_process-broker-rrd;PROCESSARGS;'/etc/centreon-broker/central-rrd(.xml|.json)'"
    exec_clapi STPL setmacro "stpl_app_centreon_process-broker-rrd;CRITICAL;1:1"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_app_centreon_process-broker-rrd;icon_image;Hardware/process2.png"
  fi
}

create_centreon_poller() {

  ##App-centreon-poller
  exist_object HTPL htpl_App-centreon-poller
  if [ $? -ne 0 ]
  then
    exec_clapi HTPL add "htpl_App-centreon-poller;HTPL_App-centreon-poller;;;;"
    exec_clapi STPL addhost "stpl_app_centreon_process-engine;htpl_App-centreon-poller"
    exec_clapi STPL addhost "stpl_app_centreon_process-ntpd;htpl_App-centreon-poller"
    exec_clapi STPL addhost "stpl_app_centreon_process-sshd;htpl_App-centreon-poller"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi HTPL setparam "htpl_App-centreon-poller;icon_image;Hardware/processing.png"
  fi
}

create_centreon_central() {

  ##App-centreon-central
  exist_object HTPL htpl_App-centreon-central
  if [ $? -ne 0 ]
  then
    exec_clapi HTPL add "htpl_App-centreon-central;HTPL_App-centreon-central;;;;"
    exec_clapi STPL addhost "stpl_app_centreon_process-cron;htpl_App-centreon-central"
    exec_clapi STPL addhost "stpl_app_centreon_process-gorgoned;htpl_App-centreon-central"
    exec_clapi STPL addhost "stpl_app_centreon_process-broker-sql;htpl_App-centreon-central"
    exec_clapi STPL addhost "stpl_app_centreon_process-broker-rrd;htpl_App-centreon-central"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi HTPL setparam "htpl_App-centreon-central;icon_image;Hardware/processing.png"
  fi
}
