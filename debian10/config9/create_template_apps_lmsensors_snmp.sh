#!/bin/bash
# create_template_apps_lmsensors_snmp.sh
# version 1.00
# 11/12/2020

create_cmd_lmsensors() {
       
  # Commande  
  # Macro système
  #   hostname
  # Macro Hôte
  #   HOSTSNMPCOMMUNITY
  #   HOSTSNMPVERSION
  # Macro Service		
  #   SERVICECOMPONENT
  #   SERVICEWARNING
  #   SERVICECRITICAL
  #   SERVICEOPTIONS
  # cmd_lmsensors_snmp
  exist_object CMD cmd_lmsensors_snmp
  [ $? -ne 0 ] && exec_clapi CMD ADD "cmd_lmsensors_snmp;check;\$CENTREONPLUGINS\$/centreon_lmsensors_snmp.pl --plugin=apps::lmsensors::snmp::plugin --mode=sensors --hostname=\$HOSTADDRESS\$ --snmp-community='\$_HOSTSNMPCOMMUNITY\$' --snmp-version=\$_HOSTSNMPVERSION\$ --component='\$_SERVICECOMPONENT\$' --warning=\$_SERVICEWARNING\$ --critical=\$_SERVICECRITICAL\$ \$_SERVICEOPTIONS\$"

}

create_stpl_lmsensors_snmp() {

  ## lm-sensors
  #stpl_lmsensors_snmp
  exist_object STPL stpl_lmsensors_snmp
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_lmsensors_snmp;lm-sensors;service-generique-actif"
    exec_clapi STPL setparam "stpl_lmsensors_snmp;check_command;cmd_lmsensors_snmp"
    exec_clapi STPL setmacro "stpl_lmsensors_snmp;COMPONENT;"
    exec_clapi STPL setmacro "stpl_lmsensors_snmp;WARNING;"
    exec_clapi STPL setmacro "stpl_lmsensors_snmp;CRITICAL;"
    exec_clapi STPL setmacro "stpl_lmsensors_snmp;OPTIONS;"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_lmsensors_snmp;icon_image;Hardware/status.png"
  fi

}

create_app_lmsensors_snmp () {
  
  ##App_lmsensors_snmp
  exist_object HTPL htpl_App_lmsensors_snmp
  if [ $? -ne 0 ]
  then
    exec_clapi HTPL add "htpl_App_lmsensors_snmp;htpl_App_lmsensors_snmp;;;;"
    exec_clapi STPL addhost "stpl_lmsensors_snmp;htpl_App_lmsensors_snmp"
    exec_clapi HTPL addtemplate "htpl_App_lmsensors_snmp;generic-host"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi HTPL setparam "htpl_App_lmsensors_snmp;icon_image;Hardware/status.png"
  fi
}
