#!/bin/bash
# create_base.sh
# version 1.02
# 14/10/2019
# add icone
# version 1.01
# 12/10/2019
# use debug
# version 1.00
# 09/04/2019


create_cmd_base () {

  # check_HOST_ALIVE
  exist_object CMD check_host_alive
  [ $? -ne 0 ] && exec_clapi CMD ADD 'check_host_alive;2;$USER1$/check_icmp -H $HOSTADDRESS$ -w 3000.0,80% -c 5000.0,100% -p 1 '
  
  # check_ping
  exist_object CMD check_ping
  [ $? -ne 0 ] && exec_clapi CMD ADD 'check_ping;check;$USER1$/check_icmp -H $HOSTADDRESS$ -n $_SERVICEPACKETNUMBER$ -w $_SERVICEWARNING$ -c $_SERVICECRITICAL$'
}

create_stpl_base () {
  # service-generique-actif
  exist_object STPL service-generique-actif
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "service-generique-actif;service-generique-actif;"
    exec_clapi STPL setparam "service-generique-actif;check_period;24x7"
    exec_clapi STPL setparam "service-generique-actif;max_check_attempts;3"
    exec_clapi STPL setparam "service-generique-actif;normal_check_interval;5"
    exec_clapi STPL setparam "service-generique-actif;retry_check_interval;2"
    exec_clapi STPL setparam "service-generique-actif;active_checks_enabled;1"
    exec_clapi STPL setparam "service-generique-actif;passive_checks_enabled;0"
    exec_clapi STPL setparam "service-generique-actif;notifications_enabled;1"
    exec_clapi STPL addcontactgroup "service-generique-actif;Supervisors"
    exec_clapi STPL setparam "service-generique-actif;notification_interval;0"
    exec_clapi STPL setparam "service-generique-actif;notification_period;24x7"
    exec_clapi STPL setparam "service-generique-actif;notification_options;w,c,r,f,s"
    exec_clapi STPL setparam "service-generique-actif;first_notification_delay;0"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "service-generique-actif;icon_image;Hardware/services.png"
  fi
  
  ## Ping Lan
  #Ping-Lan-service
  exist_object STPL Ping-Lan-service
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "Ping-Lan-service;Ping-Lan;service-generique-actif"
    exec_clapi STPL setparam "Ping-Lan-service;check_command;check_ping"
    exec_clapi STPL setmacro "Ping-Lan-service;PACKETNUMBER;5"
    exec_clapi STPL setmacro "Ping-Lan-service;WARNING;220,20%"
    exec_clapi STPL setmacro "Ping-Lan-service;CRITICAL;400,50%"
    exec_clapi STPL setparam "Ping-Lan-service;graphtemplate;Latency"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "Ping-Lan-service;icon_image;Hardware/ping.png"
  fi
}

create_htpl_base () {
	
  #generic-host
  exist_object HTPL generic-host
  if [ $? -ne 0 ]
  then
    exec_clapi HTPL ADD "generic-host;generic-host;;;;"
    exec_clapi HTPL setparam "generic-host;check_command;check_host_alive"
    exec_clapi HTPL setparam "generic-host;check_period;24x7"
    exec_clapi HTPL setparam "generic-host;notification_period;24x7"
    exec_clapi HTPL setparam "generic-host;host_max_check_attempts;5"
    exec_clapi HTPL setparam "generic-host;host_active_checks_enabled;1"
    exec_clapi HTPL setparam "generic-host;host_passive_checks_enabled;0"
    exec_clapi HTPL setparam "generic-host;host_checks_enabled;2"
    exec_clapi HTPL setparam "generic-host;host_obsess_over_host;2"
    exec_clapi HTPL setparam "generic-host;host_check_freshness;2"
    exec_clapi HTPL setparam "generic-host;host_event_handler_enabled;2"
    exec_clapi HTPL setparam "generic-host;host_flap_detection_enabled;2"
    exec_clapi HTPL setparam "generic-host;host_process_perf_data;2"
    exec_clapi HTPL setparam "generic-host;host_retain_status_information;2"
    exec_clapi HTPL setparam "generic-host;host_retain_nonstatus_information;2"
    exec_clapi HTPL setparam "generic-host;host_notification_interval;0"
    exec_clapi HTPL setparam "generic-host;host_notification_options;d,r"
    exec_clapi HTPL setparam "generic-host;host_notifications_enabled;0"
    exec_clapi HTPL setparam "generic-host;contact_additive_inheritance;0"
    exec_clapi HTPL setparam "generic-host;cg_additive_inheritance;0"
    exec_clapi HTPL setparam "generic-host;host_snmp_community;public"
    exec_clapi HTPL setparam "generic-host;host_snmp_version;2c"
    exec_clapi STPL addhost "Ping-Lan-service;generic-host"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi HTPL setparam "generic-host;icon_image;Hardware/setting.png"
  fi	
}

