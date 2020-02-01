#!/bin/bash
# create_template_cisco_snmp.sh
# version 1.00
# 01/02/2020


create_cmd_cisco_snmp() {
       

  # cmd_net_cisco_snmp_environment
  exist_object CMD cmd_net_cisco_snmp_environment
  [ $? -ne 0 ] && exec_clapi CMD ADD "cmd_net_cisco_snmp_environment;check; \$CENTREONPLUGINS\$/centreon_cisco_standard_snmp.pl --plugin=network::cisco::standard::snmp::plugin --mode=environment --hostname=$HOSTADDRESS$ --snmp-version='\$_HOSTSNMPVERSION\$' --snmp-community='\$_HOSTSNMPCOMMUNITY\$' --component='\$_SERVICECOMPONENT\$' \$_HOSTSNMPOPTION\$ \$_SERVICEOPTION\$"

  # cmd_net_cisco_snmp_cpu
  exist_object CMD cmd_net_cisco_snmp_cpu 
  [ $? -ne 0 ] && exec_clapi CMD ADD "cmd_net_cisco_snmp_cpu;check;\$CENTREONPLUGINS\$/centreon_cisco_standard_snmp.pl --plugin=network::cisco::standard::snmp::plugin --mode=cpu --hostname=\$HOSTADDRESS\$ --snmp-version='\$_HOSTSNMPVERSION\$' --snmp-community='\$_HOSTSNMPCOMMUNITY\$' \$_HOSTSNMPOPTION\$ --warning-core-5s='\$_SERVICEWARNINGCORE5S\$' --critical-core-5s='\$_SERVICECRITICALCORE5S\$' --warning-core-1m='\$_SERVICEWARNINGCORE1M\$' --critical-core-1m='\$_SERVICECRITICALCORE1M\$' --warning-core-5m='\$_SERVICEWARNINGCORE5M\$' --critical-core-5m='\$_SERVICECRITICALCORE5M\$' --warning-average-5s='\$_SERVICEWARNINGAVERAGE5S\$' --critical-average-5s='\$_SERVICECRITICALAVERAGE5S\$' --warning-average-1m='\$_SERVICEWARNINGAVERAGE1M\$' --critical-average-1m='\$_SERVICECRITICALAVERAGE1M\$' --warning-average-5m='\$_SERVICEWARNINGAVERAGE5M\$' --critical-average-5m='\$_SERVICECRITICALAVERAGE5M\$' \$_SERVICEOPTION\$"

  # cmd_net_cisco_snmp_memory
  exist_object CMD cmd_net_cisco_snmp_memory
  [ $? -ne 0 ] && exec_clapi CMD ADD "cmd_net_cisco_snmp_memory;check;\$CENTREONPLUGINS\$/centreon_cisco_standard_snmp.pl --plugin=network::cisco::standard::snmp::plugin --mode=memory --hostname=\$HOSTADDRESS\$ --snmp-version='\$_HOSTSNMPVERSION\$' --snmp-community='\$_HOSTSNMPCOMMUNITY\$' \$_HOSTSNMPOPTION\$ --warning-usage='\$_SERVICEWARNING\$' --critical-usage='\$_SERVICECRITICAL\$' \$_SERVICEOPTION\$"

  # cmd_net_cisco_snmp_traffic_global
  exist_object CMD cmd_net_cisco_snmp_traffic_global
  [ $? -ne 0 ] && exec_clapi CMD ADD "cmd_net_cisco_snmp_traffic_global;check;\$CENTREONPLUGINS\$/centreon_cisco_standard_snmp.pl --plugin=network::cisco::standard::snmp::plugin --mode=interfaces --hostname=\$HOSTADDRESS\$ --snmp-version='\$_HOSTSNMPVERSION\$' --snmp-community='\$_HOSTSNMPCOMMUNITY\$' \$_HOSTSNMPOPTION\$ --interface='\$_SERVICEFILTER\$' --name --add-status --add-traffic --critical-status='\$_SERVICECRITICALSTATUS\$' --warning-in-traffic='\$_SERVICEWARNINGIN\$' --critical-in-traffic='\$_SERVICECRITICALIN\$' --warning-out-traffic='\$_SERVICEWARNINGOUT\$' --critical-out-traffic='\$_SERVICECRITICALOUT\$' \$_SERVICEOPTION\$"


}

create_stpl_cisco_snmp() {

  ## CPU snmp
  #stpl_net_cisco_snmp_cpu
  exist_object STPL stpl_os_windows_snmp_cpu
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_net_cisco_snmp_cpu;cpu;service-generique-actif"
    exec_clapi STPL setparam "stpl_net_cisco_snmp_cpu;check_command;cmd_net_cisco_snmp_cpu"
    exec_clapi STPL setmacro "stpl_net_cisco_snmp_cpu;WARNINGCORE5M;90"
    exec_clapi STPL setmacro "stpl_net_cisco_snmp_cpu;CRITICALCORE5M;95"
    exec_clapi STPL setmacro "stpl_net_cisco_snmp_cpu;OPTION;--verbose"
    exec_clapi STPL setparam "stpl_net_cisco_snmp_cpu;graphtemplate;CPU"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_net_cisco_snmp_cpu;icon_image;Hardware/cpu2.png"
  fi


  ## Environment SNMP
  #stpl_net_cisco_snmp_environment
  exist_object STPL stpl_net_cisco_snmp_environment
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_net_cisco_snmp_environment;environment;service-generique-actif"
    exec_clapi STPL setparam "stpl_net_cisco_snmp_environment;check_command;cmd_net_cisco_snmp_environment"
    exec_clapi STPL setmacro "stpl_net_cisco_snmp_environment;COMPONENT;'.*'"
    exec_clapi STPL setmacro "stpl_net_cisco_snmp_environment;OPTION;--verbose  --filter-perfdata='^(sensor\.(celsius_|rpm_)|temp_)'"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_net_cisco_snmp_environment;icon_image;Networks/switch.png"
  fi

  ## MEMORY SNMP
  #stpl_net_cisco_snmp_memory
  exist_object STPL stpl_net_cisco_snmp_memory
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_net_cisco_snmp_memory;Memory;service-generique-actif"
    exec_clapi STPL setparam "stpl_net_cisco_snmp_memory;check_command;cmd_net_cisco_snmp_cpu"
    exec_clapi STPL setmacro "stpl_net_cisco_snmp_memory;WARNING;80"
    exec_clapi STPL setmacro "stpl_net_cisco_snmp_memory;CRITICAL;90"
    exec_clapi STPL setmacro "stpl_net_cisco_snmp_memory;OPTION;--verbose"
    exec_clapi STPL setparam "stpl_net_cisco_snmp_memory;graphtemplate;Memory"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_net_cisco_snmp_memory;icon_image;Hardware/memory2.png"
  fi
  
  ## DISK Global SNMP
  #stpl_net_cisco_snmp_traffic_global
  exist_object STPL stpl_net_cisco_snmp_traffic_global
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_net_cisco_snmp_traffic_global;Traffic-global;service-generique-actif"
    exec_clapi STPL setparam "stpl_net_cisco_snmp_traffic_global;check_command;cmd_net_cisco_snmp_traffic_global"
    exec_clapi STPL setmacro "stpl_net_cisco_snmp_traffic_global;FILTER;'.*'"
    exec_clapi STPL setmacro "stpl_net_cisco_snmp_traffic_global;WARNINGIN;80"
    exec_clapi STPL setmacro "stpl_net_cisco_snmp_traffic_global;CRITICALIN;90"
    exec_clapi STPL setmacro "stpl_net_cisco_snmp_traffic_global;WARNINGOUT;80"
    exec_clapi STPL setmacro "stpl_net_cisco_snmp_traffic_global;CRITICALOUT;90"
    exec_clapi STPL setmacro "stpl_net_cisco_snmp_traffic_global;OPTION;--verbose"
    exec_clapi STPL setparam "stpl_net_cisco_snmp_traffic_global;graphtemplate;Traffic"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_net_cisco_snmp_traffic_global;icon_image;Other/diagram.png"
  fi

}

create_cisco_snmp () {
  
  ##NET-Cisco-snmp
  exist_object HTPL htpl_NET-Cisco-snmp
  if [ $? -ne 0 ]
  then
    exec_clapi HTPL add "htpl_NET-Cisco-snmp;HTPL_NET-Cisco-SNMP;;;;"
    exec_clapi STPL addhost "stpl_net_cisco_snmp_cpu;htpl_NET-Cisco-snmp"
    exec_clapi STPL addhost "stpl_net_cisco_snmp_environment;htpl_NET-Cisco-snmp"
    exec_clapi STPL addhost "stpl_net_cisco_snmp_traffic_global;htpl_NET-Cisco-snmp"
    exec_clapi STPL addhost "stpl_net_cisco_snmp_memory;htpl_NET-Cisco-snmp"
    exec_clapi HTPL addtemplate "htpl_NET-Cisco-snmp;generic-host"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi HTPL setparam "htpl_NET-Cisco-snmp;icon_image;Networks/hub.png"
  fi
}
