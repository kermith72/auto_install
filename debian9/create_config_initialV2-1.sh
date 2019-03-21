#!/bin/bash
# create_config_initial.sh
# version 2.1
# date 21/03/2019
# add template cpu based on Hugues's script
# debug template mysql queries
# debug service traffic add name interface
# version 2.01
# date 07/03/2019
# debug by hugues
# stpl_app_db_mysl-databases-size
# version 2.00
# date 27/06/2018
# use API Clapi
# $USER_CENTREON name of admin
# $PWD_CENTREON password admin
# $USER_BDD name of user database Centreon
# $PWD_BDD password user database Centreon
# $ADD_STORAGE add storage /tmp /var /home
# $MODE_START method start engine
# based on Hugues's script
## hugues@ruelle.fr
## Centreon Configuration initial -> DEBIAN 8 -> CENTREON 2.8.12
## V 0.23 # 14/09/2017
## "Centreon-plugins_pl"
##"""""""""""""""""""""""""""""""""""""""""""""""""""""""#
##                                                       #
##   Commandes + Modeles Services + Modeles Hotes        #
##                                                       #
##   Hote : "Supervision"                                #
##   Service : Cpu                                       #
##			  Mem                            #
##			  Swap                           #
##			  Disk"/" 		         #
##			  Traffic "Eth0"                 #
##             Mysql                                     #
##      	- RESTE a faire : Services (apache2...)  #
##             Version Plugin Centreon  + MAJ            #
##         Logos et Liens Wiki des Modeles / Hotes       #
##                                                       #
##"""""""""""""""""""""""""""""""""""""""""""""""""""""""#
# version 1.0.1
# bug pollertest before pollergenerate create error
#add method start engine
# version 2.00
# new commands and templates



# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} -u=<user centreon> -p=<passwd centreon> -d=<user database centreon> -w=<passwd database> -s=[yes|no] -m=[restart|reload]

This program create initial configuration

    -u|--user User Centreon.
    -p|--password Password Centreon.
    -d|--userdatabase User Database Centreon
    -w|--passworddatabase Password Database Centreon.
    -s|--storage Create Storage service (yes/no)
    -m|--method Method start engine
    -h|--help     help
EOF
}

for i in "$@"
do
  case $i in
    -u=*|--user=*)
      USER_CENTREON="${i#*=}"
      shift # past argument=value
      ;;
    -p=*|--password=*)
      PWD_CENTREON="${i#*=}"
      shift # past argument=value
      ;;
    -d=*|--userdatabase=*)
      USER_BDD="${i#*=}"
      shift # past argument=value
      ;;
    -w=*|--passworddatabase=*)
      PWD_BDD="${i#*=}"
      shift # past argument=value
      ;;
    -s=*|--storage=*)
      ADD_STORAGE="${i#*=}"
      shift # past argument=value
      ;;
    -m=*|--method=*)
      MODE_START="${i#*=}"
      shift # past argument=value
      ;;
    -h|--help)
      show_help
      exit 2
      ;;
    *)
            # unknown option
    ;;
  esac
done


# Check for missing parameters
if [[ -z "$USER_CENTREON" ]] || [[ -z "$PWD_CENTREON" ]] || [[ -z "$USER_BDD" ]] || [[ -z "$PWD_BDD" ]] || [[ -z "$ADD_STORAGE" ]]; then
    echo "Missing parameters!"
    show_help
    exit 2
fi

# Check yes/no
if [[ $ADD_STORAGE =~ ^[yY][eE][sS]|[yY]$ ]]; then
  ADD_STORAGE="yes"
else
  ADD_STORAGE="no"
fi

# Check reload/restart
if [[ $MODE_START =~ ^[rR][eE][sS][tT][aA][rR][tT]$ ]]; then
  MODE_START="-a pollerrestart -v 1"
else
  MODE_START="-a pollerreload -v 1"
fi

################################################################
#                       Parametres                             #
#                                                              #
#                                                              #
CLAPI_DIR=/usr/share/centreon/bin
CLAPI="${CLAPI_DIR}/centreon -u ${USER_CENTREON} -p ${PWD_CENTREON}"
#                                                              #
################################################################

##################
#***** CMD  ******
##################
echo "Create Command"
# check_HOST_ALIVE
RESULT=`$CLAPI -o CMD -a ADD -v 'check_host_alive;2;$USER1$/check_icmp -H $HOSTADDRESS$ -w 3000.0,80% -c 5000.0,100% -p 1 '`
if [ "$RESULT" == "Invalid credentials." ]
then
   echo "Invalid credential !!!!!"
   exit 0
fi

# check_ping
$CLAPI -o CMD -a ADD -v 'check_ping;check;$USER1$/check_icmp -H $HOSTADDRESS$ -n $_SERVICEPACKETNUMBER$ -w $_SERVICEWARNING$ -c $_SERVICECRITICAL$'

# cmd_os_linux_local_cpu
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_cpu;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::local::plugin --mode=cpu --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEOPTION$ '

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
#cmd_os_linux_snmp_cpu
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_snmp_cpu-average;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=cpu --warning-average=$_SERVICEWARNING$ --critical-average=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_snmp_cpu-core;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=cpu --warning-core=$_SERVICEWARNING$ --critical-core=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
# cmd_os_linux_snmp_cpu-detailed
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_snmp_cpu-det-user;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=cpu-detailed --warning-user=$_SERVICEWARNING$ --critical-user=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_snmp_cpu-det-nice;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=cpu-detailed --warning-nice=$_SERVICEWARNING$ --critical-nice=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_snmp_cpu-det-system;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=cpu-detailed --warning-system=$_SERVICEWARNING$ --critical-system=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_snmp_cpu-det-idle;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=cpu-detailed --warning-idle=$_SERVICEWARNING$ --critical-idle=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_snmp_cpu-det-wait;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=cpu-detailed --warning-wait=$_SERVICEWARNING$ --critical-wait=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_snmp_cpu-det-kernel;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=cpu-detailed --warning-kernel=$_SERVICEWARNING$ --critical-kernel=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_snmp_cpu-det-interrupt;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=cpu-detailed --warning-interrupt=$_SERVICEWARNING$ --critical-interrupt=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_snmp_cpu-det-softirq;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=cpu-detailed --warning-softirq=$_SERVICEWARNING$ --critical-softirq=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_snmp_cpu-det-steal;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=cpu-detailed --warning-steal=$_SERVICEWARNING$ --critical-steal=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_snmp_cpu-det-guest;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=cpu-detailed --warning-guest=$_SERVICEWARNING$ --critical-guest=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_snmp_cpu-det-guestnice;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=cpu-detailed --warning-guestnice=$_SERVICEWARNING$ --critical-guestnice=$_SERVICECRITICAL$ $_SERVICEOPTION$ '


# cmd_os_linux_local_load
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_load;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::local::plugin --mode=load --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEOPTION$ '

# cmd_os_linux_local_swap
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_swap;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::local::plugin --mode=swap --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEOPTION$ '

# cmd_os_linux_local_memory
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_memory;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::local::plugin --mode=memory --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEOPTION$ '


# cmd_os_linux_local_disk_name
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_disk_name;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::local::plugin --mode=storage --name=$_SERVICEDISKNAME$ --warning-usage=$_SERVICEWARNING$ --critical-usage=$_SERVICECRITICAL$ $_SERVICEOPTION$ '

# cmd_os_linux_local_network_name
$CLAPI -o CMD -a ADD -v 'cmd_os_linux_local_network_name;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=os::linux::local::plugin --mode=traffic --speed=$_SERVICESPEED$ --name=$_SERVICEINTERFACE$ --warning-out=$_SERVICEWARNING$ --critical-out=$_SERVICECRITICAL$ --warning-in=$_SERVICEWARNING$ --critical-in=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
 # WARNING IN ET OUT DE LA COMMANDE A REPRENDRE Dans le service template ... !!!!

#-----------------------------------------------------------------------------------------------------------------------------------
# Modes Available:
#   connection-time
#		 --warning
#        --critical
#   databases-size
#		 --warning
#        --critical
#        --filter  
#   innodb-bufferpool-hitrate
#		 --warning
#        --critical
#        --lookback
#   long-queries
#		 --warning
#        --critical
#        --filter-user
#        --filter-command
#   myisam-keycache-hitrate
#		 --warning
#        --critical
#        --lookback
#   open-files
#   qcache-hitrate
#   queries
#		 --warning-*  ->'total', 'update', 'insert','total', 'update', 'insert','delete', 'truncate', 'select', 'begin', 'commit'           
#        --critical-* ->'total', 'update', 'insert','total', 'update', 'insert','delete', 'truncate', 'select', 'begin', 'commit' 
#   replication-master-master
#   replication-master-slave
#   slow-queries
#   sql
#   sql-string
#   tables-size
#   threads-connected
#   uptime
#   cpu  
#		 --warning-average
#		 --critical-average
#        --warning-core
#        --critical-core         
# Commandes CPU SNMP #cmd_app_db_mysl
$CLAPI -o CMD -a ADD -v 'cmd_app_db_mysl;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=database::mysql::plugin --host=$HOSTADDRESS$ --mode=$_SERVICEMODE$ --username=$_HOSTMYSQLUSERNAME$ --password=$_HOSTMYSQLPASSWORD$  --port=$_HOSTMYSQLPORT$  --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEOPTION$ '
$CLAPI -o CMD -a ADD -v 'cmd_app_db_mysl_queries;check;$CENTREONPLUGINS$/centreon_plugins.pl --plugin=database::mysql::plugin --host=$HOSTADDRESS$ --mode=queries --username=$_HOSTMYSQLUSERNAME$ --password=$_HOSTMYSQLPASSWORD$  --port=$_HOSTMYSQLPORT$  --warning-total=$_SERVICEWARNING-TOTAL$ --critical-total=$_SERVICECRITICAL-TOTAL$ $_SERVICEOPTION$ '

#*****************

###############################
#***** SERVICES MODELES  ******
###############################
echo "Create template service"
# service-generique-actif
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
echo "Create template service local"

## Ping Lan
#Ping-Lan-service
$CLAPI -o STPL -a add -v "Ping-Lan-service;Ping-Lan;service-generique-actif"
$CLAPI -o STPL -a setparam -v "Ping-Lan-service;check_command;check_ping"
$CLAPI -o STPL -a setmacro -v "Ping-Lan-service;PACKETNUMBER;5"
$CLAPI -o STPL -a setmacro -v "Ping-Lan-service;WARNING;220,20%"
$CLAPI -o STPL -a setmacro -v "Ping-Lan-service;CRITICAL;400,50%"
$CLAPI -o STPL -a setparam -v "Ping-Lan-service;graphtemplate;Latency"


## CPU
#stpl_os_linux_local_cpu
$CLAPI -o STPL -a add -v "stpl_os_linux_local_cpu;Cpu-local;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu;check_command;cmd_os_linux_local_cpu"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu;WARNING;70"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_cpu;CRITICAL;90"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_local_cpu;graphtemplate;CPU"

## Services MODELES CPU SNMP 
#stpl_os_linux_snmp_cpu_snmp_cpu-average
$CLAPI -o STPL -a add -v "stpl_os_linux_snmp_cpu-average;Cpu-snmp-average;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-average;check_command;cmd_os_linux_snmp_cpu-average"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-average;WARNING;70"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-average;CRITICAL;90"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-average;graphtemplate;CPU"
#stpl_os_linux_snmp_cpu_snmp_cpu-core
$CLAPI -o STPL -a add -v "stpl_os_linux_snmp_cpu-core;Cpu-snmp--core;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-core;check_command;cmd_os_linux_snmp_cpu-core"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-core;WARNING;70"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-core;CRITICAL;90"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-core;graphtemplate;CPU"
#stpl_os_linux_snmp_cpu-det-user
$CLAPI -o STPL -a add -v "stpl_os_linux_snmp_cpu-det-user;Cpu-snmp-det-user;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-user;check_command;cmd_os_linux_snmp_cpu-det-user"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-user;WARNING;70"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-user;CRITICAL;90"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-user;graphtemplate;CPU"
#stpl_os_linux_snmp_cpu-det-nice
$CLAPI -o STPL -a add -v "stpl_os_linux_snmp_cpu-det-nice;Cpu-snmp-nice;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-nice;check_command;cmd_os_linux_snmp_cpu-det-nice"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-nice;WARNING;70"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-nice;CRITICAL;90"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-nice;graphtemplate;CPU"
#stpl_os_linux_snmp_cpu-det-system
$CLAPI -o STPL -a add -v "stpl_os_linux_snmp_cpu-det-system;Cpu-snmp;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-system;check_command;cmd_os_linux_snmp_cpu-det-system"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-system;WARNING;70"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-system;CRITICAL;90"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-system;graphtemplate;CPU"
#stpl_os_linux_snmp_cpu-det-idle
$CLAPI -o STPL -a add -v "stpl_os_linux_snmp_cpu-det-idle;Cpu-snmp;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-idle;check_command;cmd_os_linux_snmp_cpu-det-idle"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-idle;WARNING;70"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-idle;CRITICAL;90"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-idle;graphtemplate;CPU"
#stpl_os_linux_snmp_cpu-det-wait
$CLAPI -o STPL -a add -v "stpl_os_linux_snmp_cpu-det-wait;Cpu-snmp;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-wait;check_command;cmd_os_linux_snmp_cpu-det-wait"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-wait;WARNING;70"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-wait;CRITICAL;90"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-wait;graphtemplate;CPU"
#stpl_os_linux_snmp_cpu-det-kernel
$CLAPI -o STPL -a add -v "stpl_os_linux_snmp_cpu-det-kernel;Cpu-snmp;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-kernel;check_command;cmd_os_linux_snmp_cpu-det-kernel"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-kernel;WARNING;70"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-kernel;CRITICAL;90"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-kernel;graphtemplate;CPU"
#stpl_os_linux_snmp_cpu-det-interrupt
$CLAPI -o STPL -a add -v "stpl_os_linux_snmp_cpu-det-interrupt;Cpu-snmp;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-interrupt;check_command;cmd_os_linux_snmp_cpu-det-interrupt"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-interrupt;WARNING;70"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-interrupt;CRITICAL;90"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-interrupt;graphtemplate;CPU"
#stpl_os_linux_snmp_cpu-det-softirq
$CLAPI -o STPL -a add -v "stpl_os_linux_snmp_cpu-det-softirq;Cpu-snmp;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-softirq;check_command;cmd_os_linux_snmp_cpu-det-softirq"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-softirq;WARNING;70"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-softirq;CRITICAL;90"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-softirq;graphtemplate;CPU"
#stpl_os_linux_snmp_cpu-det-steal
$CLAPI -o STPL -a add -v "stpl_os_linux_snmp_cpu-det-steal;Cpu-snmp;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-steal;check_command;cmd_os_linux_snmp_cpu-det-steal"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-steal;WARNING;70"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-steal;CRITICAL;90"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-steal;graphtemplate;CPU"
#stpl_os_linux_snmp_cpu-det-guest
$CLAPI -o STPL -a add -v "stpl_os_linux_snmp_cpu-det-guest;Cpu-snmp;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-guest;check_command;cmd_os_linux_snmp_cpu-det-guest"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-guest;WARNING;70"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-guest;CRITICAL;90"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-guest;graphtemplate;CPU"
#stpl_os_linux_snmp_cpu-det-guestnice
$CLAPI -o STPL -a add -v "stpl_os_linux_snmp_cpu-det-guestnice;Cpu-snmp;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-guestnice;check_command;cmd_os_linux_snmp_cpu-det-guestnice"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-guestnice;WARNING;70"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_snmp_cpu-det-guestnice;CRITICAL;90"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_snmp_cpu-det-guestnice;graphtemplate;CPU"

## LOAD
#stpl_os_linux_local_load
$CLAPI -o STPL -a add -v "stpl_os_linux_local_load;Load-local;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_local_load;check_command;cmd_os_linux_local_load"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_load;WARNING;4,3,2"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_load;CRITICAL;6,5,4"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_local_load;graphtemplate;LOAD_Average"

## MEMORY
#stpl_os_linux_local_memory
$CLAPI -o STPL -a add -v "stpl_os_linux_local_memory;Memory-local;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_local_memory;check_command;cmd_os_linux_local_memory"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_memory;WARNING;70"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_memory;CRITICAL;90"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_local_memory;graphtemplate;Memory"

## SWAP
#stpl_os_linux_local_swap
$CLAPI -o STPL -a add -v "stpl_os_linux_local_swap;Swap-local;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_local_swap;check_command;cmd_os_linux_local_swap"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_swap;WARNING;80"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_swap;CRITICAL;90"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_local_swap;graphtemplate;Memory"

echo "Create template service local disk"

## DISK
## Modele Disk
###stpl_os_linux_local_disk_name
$CLAPI -o STPL -a add -v "stpl_os_linux_local_disk_name;disk-local-name;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_local_disk_name;check_command;cmd_os_linux_local_disk_name"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_disk_name;WARNING;80"
$CLAPI -o STPL -a setmacro -v "stpl_os_linux_local_disk_name;CRITICAL;90"
$CLAPI -o STPL -a setparam -v "stpl_os_linux_local_disk_name;graphtemplate;Storage"
### Disk home
####disk-local-home-Model-Service
#$CLAPI -o STPL -a add -v "disk-local-home-Model-Service;Disk-local-Home;disk-local-Model-Service"
#$CLAPI -o STPL -a setmacro -v "disk-local-home-Model-Service;OPTION;--name /home"

echo "Create template service local traffic"

## TRAFFIC
# stpl_os_linux_local_network_name
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

#*****************

echo "Create template service local database"

## MySQL
## stpl_app_db_mysl
$CLAPI -o STPL -a add -v "stpl_app_db_mysl;app_db_mysl;service-generique-actif"
$CLAPI -o STPL -a setparam -v "stpl_app_db_mysl;check_command;cmd_app_db_mysl"
$CLAPI -o STPL -a setparam -v "stpl_app_db_mysl;service_is_volatile;2"
$CLAPI -o STPL -a setparam -v "stpl_app_db_mysl;service_active_checks_enabled;2"
$CLAPI -o STPL -a setparam -v "stpl_app_db_mysl;service_passive_checks_enabled;2"
$CLAPI -o STPL -a setparam -v "stpl_app_db_mysl;service_parallelize_check;2"
$CLAPI -o STPL -a setparam -v "stpl_app_db_mysl;service_obsess_over_service;2"
$CLAPI -o STPL -a setparam -v "stpl_app_db_mysl;service_check_freshness;2"
$CLAPI -o STPL -a setparam -v "stpl_app_db_mysl;service_event_handler_enabled;2"
$CLAPI -o STPL -a setparam -v "stpl_app_db_mysl;service_flap_detection_enabled;2"
$CLAPI -o STPL -a setparam -v "stpl_app_db_mysl;service_process_perf_data;2"
$CLAPI -o STPL -a setparam -v "stpl_app_db_mysl;service_retain_status_information;2"
$CLAPI -o STPL -a setparam -v "stpl_app_db_mysl;service_retain_nonstatus_information;2"
$CLAPI -o STPL -a setparam -v "stpl_app_db_mysl;service_notifications_enabled;2"

###MySQL_connection-time
## stpl_app_db_mysl-connection-time
$CLAPI -o STPL -a add -v "stpl_app_db_mysl-connection-time;MySQL_connection-time;stpl_app_db_mysl"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-connection-time;mode;connection-time"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-connection-time;warning;200"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-connection-time;critical;600"

###MySQL_qcache
## stpl_app_db_mysl-qcache-hitrate
$CLAPI -o STPL -a add -v "stpl_app_db_mysl-qcache-hitrate;MySQL_qcache-hitrate;stpl_app_db_mysl"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-qcache-hitrate;critical;10:"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-qcache-hitrate;mode;qcache-hitrate"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-qcache-hitrate;option;--lookback"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-qcache-hitrate;warning;30:"

###MySQL_queries
## stpl_app_db_mysl-queries
$CLAPI -o STPL -a add -v "stpl_app_db_mysl-queries;MySQL_queries;stpl_app_db_mysl"
$CLAPI -o STPL -a setparam -v "stpl_app_db_mysl-queries;check_command;cmd_app_db_mysl_queries"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-queries;warning-total;200"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-queries;critical-total;300"

###MySQL_slow
## stpl_app_db_mysl-slow-queries
$CLAPI -o STPL -a add -v "stpl_app_db_mysl-slow-queries;MySQL_slow-queries;stpl_app_db_mysl"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-slow-queries;mode;slow-queries"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-slow-queries;warning;0.1"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-slow-queries;critical;0.2"

###MySQL_threads
## stpl_app_db_mysl-threads-connected
$CLAPI -o STPL -a add -v "stpl_app_db_mysl-threads-connected;MySQL_threads-connected;stpl_app_db_mysl"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-threads-connected;mode;threads-connected"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-threads-connected;warning;10"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-threads-connected;critical;20"

###MySQLdatabases
## stpl_app_db_mysl-databases-size
$CLAPI -o STPL -a add -v "stpl_app_db_mysl-databases-size;MySQLdatabases-size;stpl_app_db_mysl"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-databases-size;mode;databases-size"
#$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-databases-size;warning;200"
#$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-databases-size;critical;600"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-databases-size;filter;centreon"

###MySQLdatabases
## stpl_app_db_mysl-databases-size_detail
$CLAPI -o STPL -a add -v "stpl_app_db_mysl-databases-size_detail;MySQLdatabases-size_detail;stpl_app_db_mysl"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-databases-size_detail;mode;databases-size"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-databases-size_detail;warning;200"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-databases-size_detail;critical;600"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-databases-size_detail;filter;centreon"

###MySQL_open-files
## stpl_app_db_mysl-open-files
$CLAPI -o STPL -a add -v "stpl_app_db_mysl-open-files;MySQL_open-files;stpl_app_db_mysl"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-open-files;mode;open-files"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-open-files;warning;60"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-open-files;critical;100"

###MySQL_long-queries
## stpl_app_db_mysl-long-queries
$CLAPI -o STPL -a add -v "stpl_app_db_mysl-long-queries;MySQL_long-queries;stpl_app_db_mysl"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-long-queries;mode;long-queries"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-long-queries;warning;0.1"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-long-queries;critical;0.2"

###MySQL_uptime
## stpl_app_db_mysl-uptime
$CLAPI -o STPL -a add -v "stpl_app_db_mysl-uptime;MySQL_uptime;stpl_app_db_mysl"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-uptime;mode;uptime"
#*********************** Warning 6 mois=15778800 Sec   Critical 1 ans=31557600 Sec *******************************
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-uptime;warning;15778800"
$CLAPI -o STPL -a setmacro -v "stpl_app_db_mysl-uptime;critical;31557600"


################################
#*******HOTES MODELES **********
################################
echo "Create template host"
#generic-host
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


##OS-Linux-local
$CLAPI -o HTPL -a add -v "htpl_OS-Linux-local;HTPL_OS-Linux-local;;;;"
$CLAPI -o STPL -a addhost -v "stpl_os_linux_local_cpu;htpl_OS-Linux-local"
$CLAPI -o STPL -a addhost -v "stpl_os_linux_local_load;htpl_OS-Linux-local"
$CLAPI -o STPL -a addhost -v "stpl_os_linux_local_memory;htpl_OS-Linux-local"
$CLAPI -o STPL -a addhost -v "stpl_os_linux_local_swap;htpl_OS-Linux-local"
#$CLAPI -o STPL -a addhost -v "Traffic-local-Model-Service;htpl_OS-Linux-local"

##OS-Linux-local-storage
#$CLAPI -o HTPL -a add -v "OS-Linux-local-storage;TPL_OS-Linux-local-storage;;;;"
#$CLAPI -o STPL -a addhost -v "disk-local-home-Model-Service;OS-Linux-local-storage"
#$CLAPI -o STPL -a addhost -v "disk-local-tmp-Model-Service;OS-Linux-local-storage"
#$CLAPI -o STPL -a addhost -v "disk-local-var-Model-Service;OS-Linux-local-storage"
#$CLAPI -o STPL -a addhost -v "disk-local-usr-Model-Service;OS-Linux-local-storage"



##MySQL-Serveur
$CLAPI -o HTPL -a add -v "htpl_MySQL-Server;HTPL_MySQL-Server-local;;;;"
$CLAPI -o STPL -a addhost -v "stpl_app_db_mysl-connection-time;htpl_MySQL-Server"
$CLAPI -o STPL -a addhost -v "stpl_app_db_mysl-qcache-hitrate;htpl_MySQL-Server"
$CLAPI -o STPL -a addhost -v "stpl_app_db_mysl-queries;htpl_MySQL-Server"
$CLAPI -o STPL -a addhost -v "stpl_app_db_mysl-slow-queries;htpl_MySQL-Server"
$CLAPI -o STPL -a addhost -v "stpl_app_db_mysl-threads-connected;htpl_MySQL-Server"
$CLAPI -o STPL -a addhost -v "stpl_app_db_mysl-databases-size;htpl_MySQL-Server"
$CLAPI -o STPL -a addhost -v "stpl_app_db_mysl-open-files;htpl_MySQL-Server"
$CLAPI -o STPL -a addhost -v "stpl_app_db_mysl-long-queries;htpl_MySQL-Server"
$CLAPI -o STPL -a addhost -v "stpl_app_db_mysl-uptime;htpl_MySQL-Server"
$CLAPI -o HTPL -a setmacro -v "htpl_MySQL-Server;MYSQLUSERNAME;${USER_BDD}"
$CLAPI -o HTPL -a setmacro -v "htpl_MySQL-Server;MYSQLPASSWORD;${PWD_BDD}"
$CLAPI -o HTPL -a setmacro -v "htpl_MySQL-Server;MYSQLPORT;3306"

################################################################
#               Creation hote Supervision                      #
################################################################
echo "Create Central"
$CLAPI -o host -a add -v "Central;Monitoring Server;127.0.0.1;;central;"
$CLAPI -o host -a addtemplate -v "Central;generic-host"
$CLAPI -o host -a addtemplate -v "Central;htpl_OS-Linux-local"
if [ "$ADD_STORAGE" == "yes" ]
then
  echo "add storage"
  for i in `/usr/lib/centreon/plugins/centreon_plugins.pl --plugin=os::linux::local::plugin --mode=list-storages --filter-type=ext | /bin/grep -v Skipping | /bin/sed '1d' | /usr/bin/awk ' { print $1} '`
  do
    $CLAPI -o service -a add -v "Central;Storage-$i;stpl_os_linux_local_disk_name"
    $CLAPI -o service -a setmacro -v "Central;Storage-`echo $i | sed "s/'//g"`;DISKNAME;$i"
     
  done
fi
$CLAPI -o host -a addtemplate -v "Central;htpl_MySQL-Server"
# application des modeles a l hote
$CLAPI -o host -a applytpl -v "Central"

#retrieve name interface
NAMEINTERFACE=`ip link | awk -F: '$0 !~ "lo|vir|^[^0-9]"{print $2a;getline}'`

$CLAPI -o service -a add -v "Central;Interface-$NAMEINTERFACE;stpl_os_linux_local_network_name"
$CLAPI -o service -a setmacro -v "Central;Interface-$NAMEINTERFACE;INTERFACE;$NAMEINTERFACE"


### application de la configation poller "central"

#*****************

RESULT=`$CLAPI -a pollergenerate -v 1`
if [ $? = 0 ];then
   RESULT=`$CLAPI -a pollertest -v 1`
   if [ $? != 0 ];then
     echo "Error Test configuration !!!"
     exit 1
   fi
   RESULT=`$CLAPI -a cfgmove -v 1`
   if [ $? != 0 ];then
     echo "Error Move configuration !!!"
     exit 1
   fi
   RESULT=`$CLAPI $MODE_START`
   if [ $? = 0 ];then
     echo "Configuration OK !"
   else
     echo "Error Reload/Restart Configuration !!!"
   fi
else
  echo "Error generate configuration !!!"
fi
