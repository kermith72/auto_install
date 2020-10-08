#!/bin/bash
# create_config_initialV9.sh
# version 9.00
# 08/10/2020
# new option without host configuration
# version 8.00
# 07/08/2020
# new plugin centreon 20020803
# version 7.00
# 29/05/2020
# bugfix cpu
# version 6.00
# 24/04/2020
# add new template apps centreon for gorgone
# version 5.02
# 31/03/2020
# add template windows nrpe
# version 5.02
# 25/01/2020
# add template cisco
# version 5.01
# 25/01/2020
# add template windows
# version 5
# 13/01/2020
# update plugin mysql
# version 4.02
# 14/10/2019
# add parameter icone
# version 4.01
# 12/10/2019
# use debug
# version 4
# date 20/05/2019
# use centreon-plugins fatpacked
# version 3.02
# Enhancements : fix notification for admin
# version 3.01
# date 14/04/2019
# bugfix name ip for raspberry
# date 09/04/2019
# version 3
# date 09/04/2019
# code improvement
# date 28/03/2019
# change name template
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

# define directory
BASE_DIR=$(dirname $0)

. $BASE_DIR/config5/functions.sh
. $BASE_DIR/config5/create_base.sh
. $BASE_DIR/config8/create_template_local.sh
. $BASE_DIR/config7/create_template_snmp.sh
. $BASE_DIR/config5/create_template_windows_snmp.sh
. $BASE_DIR/config5/create_template_windows_nrpe.sh
. $BASE_DIR/config5/create_template_cisco_snmp.sh
. $BASE_DIR/config5/create_apps_mysql.sh
. $BASE_DIR/config6/create_apps_centreon.sh
. $BASE_DIR/config9/create_apps_gorgone.sh

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} -u=<user centreon> -p=<passwd centreon> -d=<user database centreon> -w=<passwd database> -s=[yes|no] -t=[yes|no] -m=[restart|reload] -db=[yes|no]
This program create initial configuration
    -u|--user                 User Centreon.
    -p|--password             Password Centreon.
    -d|--userdatabase         User Database Centreon
    -w|--passworddatabase     Password Database Centreon.
    -s|--storage              Create Storage service (yes/no)
    -m|--method               Method start engine
    -i|--icone                Add icones
    -t|--without              without host configuration
    -db|--debug               print command
    -h|--help                 help
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
    -i=*|--icone=*)
      ADD_ICONE="${i#*=}"
      shift # past argument=value
      ;;
    -t=*|--without=*)
      ADD_HOST="${i#*=}"
      shift # past argument=value
      ;;
    -db=*|--debug=*)
      DEBUG="${i#*=}"
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

# Check yes/no Storage
if [[ $ADD_STORAGE =~ ^[yY][eE][sS]|[yY]$ ]]; then
  ADD_STORAGE="yes"
else
  ADD_STORAGE="no"
fi

# Check yes/no Icone
if [[ $ADD_ICONE =~ ^[yY][eE][sS]|[yY]$ ]]; then
  ADD_ICONE="yes"
else
  ADD_ICONE="no"
fi

# Check yes/no Without Host Configuration
if [[ $ADD_HOST =~ ^[yY][eE][sS]|[yY]$ ]]; then
  ADD_HOST="yes"
else
  ADD_HOST="no"
fi

# Check yes/no Install Web
if [[ $DEBUG =~ ^[yY][eE][sS]|[yY]$ ]]; then
  DEBUG="yes"
else
  DEBUG="no"
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

check_credential

##################
#***** CMD  ******
##################
echo "Create Command base"

create_cmd_base

echo "Create Command local"

create_cmd_local

echo "Create Command snmp"

create_cmd_snmp

echo "Create Command Windows snmp"

create_cmd_windows_snmp

echo "Create Command Windows nrpe"

create_cmd_windows_nrpe

echo "Create Command Cisco snmp"

create_cmd_cisco_snmp

echo "Create Command mysql"

create_cmd_mysql

echo "Create Command gorgone"

create_cmd_gorgone

#*****************

###############################
#***** SERVICES MODELES  ******
###############################
echo "Create template service base"

create_stpl_base

echo "Create template service local"

create_stpl_local

echo "Create template service snmp"

create_stpl_snmp

echo "Create template service Windows snmp"

create_stpl_windows_snmp

echo "Create template service Windows nrpe"

create_stpl_windows_nrpe

echo "Create template service Cisco snmp"

create_stpl_cisco_snmp

#*****************

echo "Create template service local database"

create_stpl_mysql

echo "Create template app centreon poller"

create_stpl_poller

echo "Create template app centreon central"

create_stpl_central

echo "Create template app centreon gorgone"

create_stpl_gorgone

################################
#*******HOTES MODELES **********
################################
echo "Create templates host"
echo "- base"
create_htpl_base
echo "- linux local"
create_linux_local
echo "- linux snmp"
create_linux_snmp
echo "- poller"
create_centreon_poller
echo "- central"
create_centreon_central
echo "- mysql"
create_apps_mysql
echo "- windows snmp"
create_windows_snmp
echo "- windows nrpe"
create_windows_nrpe
echo "- cisco"
create_cisco_snmp
echo "- gorgone"
create_app_centreon_gorgone


if [ "$ADD_HOST" == "yes" ]
then
  ################################################################
  #               Creation hote Supervision                      #
  ################################################################
  echo "Create Central"
  exist_object host Central
  if [ $? -ne 0 ]
  then
    $CLAPI -o host -a add -v "Central;Monitoring Server;127.0.0.1;;central;"
    $CLAPI -o host -a addtemplate -v "Central;htpl_OS-Linux-local"
    if [ "$ADD_STORAGE" == "yes" ]
    then
      echo "add storage"
      for i in `/usr/lib/centreon/plugins/centreon_linux_local.pl --plugin=os::linux::local::plugin --mode=list-storages --filter-type=ext | /bin/grep -v Skipping | /bin/sed '1d' | /usr/bin/awk ' { print $1} '`
      do
        $CLAPI -o service -a add -v "Central;Storage-$i;stpl_os_linux_local_disk_name"
        $CLAPI -o service -a setmacro -v "Central;Storage-`echo $i | sed "s/'//g"`;DISKNAME;$i"
      done
    fi
    $CLAPI -o host -a addtemplate -v "Central;htpl_App-MySQL"
    $CLAPI -o host -a addtemplate -v "Central;htpl_App-centreon-poller"
    $CLAPI -o host -a addtemplate -v "Central;htpl_App-centreon-central"
    $CLAPI -o host -a setmacro -v "Central;SNMPCOMMUNITY;public"
    $CLAPI -o host -a setmacro -v "Central;SNMPVERSION;2c"
    $CLAPI -o host -a setmacro -v "Central;MYSQLUSERNAME;${USER_BDD}"
    $CLAPI -o host -a setmacro -v "Central;MYSQLPASSWORD;${PWD_BDD}"

    # application des modeles a l hote
    $CLAPI -o host -a applytpl -v "Central"

    #retrieve name interface
    NAMEINTERFACE=`ip link | grep 'state UP' | awk -F: '$0 !~ "lo|vir|^[^0-9]"{print $2a;getline}'`

    $CLAPI -o service -a add -v "Central;Interface-$NAMEINTERFACE;stpl_os_linux_local_network_name"
    $CLAPI -o service -a setmacro -v "Central;Interface-$NAMEINTERFACE;INTERFACE;$NAMEINTERFACE"
  fi
fi

### application des commandes de notification pour l'admin

$CLAPI -o contact -a setparam -v "admin;hostnotifcmd;host-notify-by-email"
$CLAPI -o contact -a setparam -v "admin;svcnotifcmd;service-notify-by-email"

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
