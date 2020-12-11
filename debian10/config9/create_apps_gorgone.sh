#!/bin/bash
# create_apps_gorgone.sh
# version 1.01
# 11/12/2020
# add template generic-host
# version 1.00
# 08/10/2020
# for v 20.04.0

create_cmd_gorgone() {
  
  #cmd_app_gorgone_events
  exist_object CMD cmd_app_gorgone_events
  [ $? -ne 0 ] &&   exec_clapi CMD ADD 'cmd_app_gorgone_events;check;$CENTREONPLUGINS$/centreon_gorgone_restapi.pl --plugin=apps::gorgone::restapi::plugin --mode=events --hostname=$HOSTADDRESS$ --api-username=$_HOSTGORGONEUSERNAME$ --api-password=$_HOSTGORGONEPASSWORD$ --port=$_HOSTGORGONEPORT$ --proto=$_HOSTGORGONEPROTOCOLE$ $_HOSTGORGONEOPTION$ --warning-events-total=$_SERVICEWARNINGEVENTSTOTAL$ --critical-events-total=$_SERVICECRITICALEVENTSTOTAL$ --warning-event-total=$_SERVICEWARNINGEVENTTOTAL$ --critical-event-total=$_SERVICECRITICALEVENTTOTAL$ $_SERVICEOPTION$'

  #cmd_app_gorgone_nodes
  exist_object CMD cmd_app_gorgone_nodes
  [ $? -ne 0 ] &&   exec_clapi CMD ADD 'cmd_app_gorgone_nodes;check;$CENTREONPLUGINS$/centreon_gorgone_restapi.pl --plugin=apps::gorgone::restapi::plugin --mode=nodes --hostname=$HOSTADDRESS$ --api-username=$_HOSTGORGONEUSERNAME$ --api-password=$_HOSTGORGONEPASSWORD$ --port=$_HOSTGORGONEPORT$ --proto=$_HOSTGORGONEPROTOCOLE$ $_HOSTGORGONEOPTION$ --filter-node-id=$_SERVICEFILTERNODEID$ --warning-ping-received-lasttime=$_SERVICEWARNINGPINGRECEIVEDLASTTIME$ --critical-ping-received-lasttime=$_SERVICECRITICALPINGRECEIVEDLASTTIME$ $_SERVICEOPTIONS$'


}

create_stpl_gorgone () {

  ## stpl_app_gorgone_events
  exist_object STPL stpl_app_gorgone_events
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_gorgone_events;events;service-generique-actif"
    exec_clapi STPL setparam "stpl_app_gorgone_events;check_command;cmd_app_gorgone_events"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_app_gorgone_events;icon_image;Hardware/process2.png"
  fi
  
  ## stpl_app_gorgone_nodes
  exist_object STPL stpl_app_gorgone_nodes
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_app_gorgone_nodes;nodes;service-generique-actif"
    exec_clapi STPL setparam "stpl_app_gorgone_nodes;check_command;cmd_app_gorgone_nodes"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_app_gorgone_nodes;icon_image;Hardware/process2.png"
  fi
  
}

create_app_centreon_gorgone() {

  ##App-centreon-gorgone
  exist_object HTPL htpl_App-centreon-gorgone
  if [ $? -ne 0 ]
  then
    exec_clapi HTPL add "htpl_App-centreon-gorgone;HTPL_App-centreon-poller;;;;"
    exec_clapi STPL addhost "stpl_app_gorgone_events;htpl_App-centreon-gorgone"
    exec_clapi STPL addhost "stpl_app_gorgone_nodes;htpl_App-centreon-gorgone"
    exec_clapi HTPL setmacro "htpl_App-centreon-gorgone;GORGONEUSERNAME;"
    exec_clapi HTPL setmacro "htpl_App-centreon-gorgone;GORGONEPASSWORD;"
    exec_clapi HTPL setmacro "htpl_App-centreon-gorgone;GORGONEPORT;8085"
    exec_clapi HTPL setmacro "htpl_App-centreon-gorgone;GORGONEPROTOCOLE;http"
    exec_clapi HTPL setmacro "htpl_App-centreon-gorgone;GORGONEOPTION;"
    exec_clapi HTPL addtemplate "htpl_App-centreon-gorgone;generic-host"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi HTPL setparam "htpl_App-centreon-gorgone;icon_image;Hardware/processing.png"
  fi
}

