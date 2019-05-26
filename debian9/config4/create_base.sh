#!/bin/bash
# create_base.sh
# version 1.00
# 09/04/2019

create_cmd_base () {

  # check_HOST_ALIVE
  exist_object CMD check_host_alive
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'check_host_alive;2;$USER1$/check_icmp -H $HOSTADDRESS$ -w 3000.0,80% -c 5000.0,100% -p 1 '

  # check_ping
  exist_object CMD check_ping
  [ $? -ne 0 ] && $CLAPI -o CMD -a ADD -v 'check_ping;check;$USER1$/check_icmp -H $HOSTADDRESS$ -n $_SERVICEPACKETNUMBER$ -w $_SERVICEWARNING$ -c $_SERVICECRITICAL$'
}

create_stpl_base () {
  # service-generique-actif
  exist_object STPL service-generique-actif
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "service-generique-actif;service-generique-actif;"
    $CLAPI -o STPL -a setparam -v "service-generique-actif;check_period;24x7"
    $CLAPI -o STPL -a setparam -v "service-generique-actif;max_check_attempts;3"
    $CLAPI -o STPL -a setparam -v "service-generique-actif;normal_check_interval;5"
    $CLAPI -o STPL -a setparam -v "service-generique-actif;retry_check_interval;2"
    $CLAPI -o STPL -a setparam -v "service-generique-actif;active_checks_enabled;1"
    $CLAPI -o STPL -a setparam -v "service-generique-actif;passive_checks_enabled;0"
    $CLAPI -o STPL -a setparam -v "service-generique-actif;notifications_enabled;1"
    $CLAPI -o STPL -a addcontactgroup -v "service-generique-actif;Supervisors"
    $CLAPI -o STPL -a setparam -v "service-generique-actif;notification_interval;0"
    $CLAPI -o STPL -a setparam -v "service-generique-actif;notification_period;24x7"
    $CLAPI -o STPL -a setparam -v "service-generique-actif;notification_options;w,c,r,f,s"
    $CLAPI -o STPL -a setparam -v "service-generique-actif;first_notification_delay;0"
  fi
  
  ## Ping Lan
  #Ping-Lan-service
  exist_object STPL Ping-Lan-service
  if [ $? -ne 0 ]
  then
    $CLAPI -o STPL -a add -v "Ping-Lan-service;Ping-Lan;service-generique-actif"
    $CLAPI -o STPL -a setparam -v "Ping-Lan-service;check_command;check_ping"
    $CLAPI -o STPL -a setmacro -v "Ping-Lan-service;PACKETNUMBER;5"
    $CLAPI -o STPL -a setmacro -v "Ping-Lan-service;WARNING;220,20%"
    $CLAPI -o STPL -a setmacro -v "Ping-Lan-service;CRITICAL;400,50%"
    $CLAPI -o STPL -a setparam -v "Ping-Lan-service;graphtemplate;Latency"
  fi
}

create_htpl_base () {
	
  #generic-host
  exist_object HTPL generic-host
  if [ $? -ne 0 ]
  then
    $CLAPI -o HTPL -a ADD -v "generic-host;generic-host;;;;"
    $CLAPI -o HTPL -a setparam -v "generic-host;check_command;check_host_alive"
    $CLAPI -o HTPL -a setparam -v "generic-host;check_period;24x7"
    $CLAPI -o HTPL -a setparam -v "generic-host;notification_period;24x7"
    $CLAPI -o HTPL -a setparam -v "generic-host;host_max_check_attempts;5"
    $CLAPI -o HTPL -a setparam -v "generic-host;host_active_checks_enabled;1"
    $CLAPI -o HTPL -a setparam -v "generic-host;host_passive_checks_enabled;0"
    $CLAPI -o HTPL -a setparam -v "generic-host;host_checks_enabled;2"
    $CLAPI -o HTPL -a setparam -v "generic-host;host_obsess_over_host;2"
    $CLAPI -o HTPL -a setparam -v "generic-host;host_check_freshness;2"
    $CLAPI -o HTPL -a setparam -v "generic-host;host_event_handler_enabled;2"
    $CLAPI -o HTPL -a setparam -v "generic-host;host_flap_detection_enabled;2"
    $CLAPI -o HTPL -a setparam -v "generic-host;host_process_perf_data;2"
    $CLAPI -o HTPL -a setparam -v "generic-host;host_retain_status_information;2"
    $CLAPI -o HTPL -a setparam -v "generic-host;host_retain_nonstatus_information;2"
    $CLAPI -o HTPL -a setparam -v "generic-host;host_notification_interval;0"
    $CLAPI -o HTPL -a setparam -v "generic-host;host_notification_options;d,r"
    $CLAPI -o HTPL -a setparam -v "generic-host;host_notifications_enabled;0"
    $CLAPI -o HTPL -a setparam -v "generic-host;contact_additive_inheritance;0"
    $CLAPI -o HTPL -a setparam -v "generic-host;cg_additive_inheritance;0"
    $CLAPI -o HTPL -a setparam -v "generic-host;host_snmp_community;public"
    $CLAPI -o HTPL -a setparam -v "generic-host;host_snmp_version;2c"
    $CLAPI -o STPL -a addhost -v "Ping-Lan-service;generic-host"
  fi	
}

