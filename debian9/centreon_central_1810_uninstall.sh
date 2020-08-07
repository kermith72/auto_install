#!/bin/bash
# uninstall script Centreon for Debian Stretch
# v 1.00
# 23/09/2019
# 
#
export DEBIAN_FRONTEND=noninteractive
# Variables
## Versions
VERSION_BATCH="v 1.00"
CLIB_VER="18.10.0"
CONNECTOR_VER="18.10.0"
ENGINE_VER="18.10.0"
PLUGIN_VER="2.2"
PLUGIN_CENTREON_VER="20190704"
BROKER_VER="18.10.1"
CENTREON_VER="18.10.7"
# MariaDB Series
MARIADB_VER='10.0'
## Sources URL
BASE_URL="http://files.download.centreon.com/public"
CLIB_URL="${BASE_URL}/centreon-clib/centreon-clib-${CLIB_VER}.tar.gz"
CONNECTOR_URL="${BASE_URL}/centreon-connectors/centreon-connectors-${CONNECTOR_VER}.tar.gz"
ENGINE_URL="${BASE_URL}/centreon-engine/centreon-engine-${ENGINE_VER}.tar.gz"
PLUGIN_URL="https://www.monitoring-plugins.org/download/monitoring-plugins-${PLUGIN_VER}.tar.gz"
PLUGIN_CENTREON_URL="${BASE_URL}/centreon-plugins/centreon-plugins-${PLUGIN_CENTREON_VER}.tar.gz"
BROKER_URL="${BASE_URL}/centreon-broker/centreon-broker-${BROKER_VER}.tar.gz"
CENTREON_URL="${BASE_URL}/centreon/centreon-web-${CENTREON_VER}.tar.gz"
CLAPI_URL="${BASE_URL}/Modules/CLAPI/centreon-clapi-${CLAPI_VER}.tar.gz"
## Sources widgetsMonitoring engine init.d script
WIDGET_HOST_VER="18.10.1"
WIDGET_HOSTGROUP_VER="18.10.0"
WIDGET_SERVICE_VER="18.10.2"
WIDGET_SERVICEGROUP_VER="18.10.0"
WIDGET_GRID_MAP_VER="18.10.0"
WIDGET_TOP_CPU_VER="18.10.0"
WIDGET_TOP_MEMORY_VER="18.10.0"
WIDGET_TACTICAL_OVERVIEW_VER="18.10.0"
WIDGET_HTTP_LOADER_VER="18.10.0"
WIDGET_ENGINE_STATUS_VER="18.10.0"
WIDGET_GRAPH_VER="18.10.0"
WIDGET_BASE="http://files.download.centreon.com/public/centreon-widgets"
WIDGET_HOST="${WIDGET_BASE}/centreon-widget-host-monitoring/centreon-widget-host-monitoring-${WIDGET_HOST_VER}.tar.gz"
WIDGET_HOSTGROUP="${WIDGET_BASE}/centreon-widget-hostgroup-monitoring/centreon-widget-hostgroup-monitoring-${WIDGET_HOSTGROUP_VER}.tar.gz"
WIDGET_SERVICE="${WIDGET_BASE}/centreon-widget-service-monitoring/centreon-widget-service-monitoring-${WIDGET_SERVICE_VER}.tar.gz"
WIDGET_SERVICEGROUP="${WIDGET_BASE}/centreon-widget-servicegroup-monitoring/centreon-widget-servicegroup-monitoring-${WIDGET_SERVICEGROUP_VER}.tar.gz"
WIDGET_GRID_MAP="${WIDGET_BASE}/centreon-widget-grid-map/centreon-widget-grid-map-${WIDGET_GRID_MAP_VER}.tar.gz"
WIDGET_TOP_CPU="https://github.com/centreon/centreon-widget-live-top10-cpu-usage.git"
WIDGET_TOP_MEMORY="https://github.com/centreon/centreon-widget-live-top10-memory-usage.git"
WIDGET_TACTICAL_OVERVIEW="${WIDGET_BASE}/centreon-widget-tactical-overview/centreon-widget-tactical-overview-${WIDGET_TACTICAL_OVERVIEW_VER}.tar.gz"
WIDGET_HTTP_LOADER="${WIDGET_BASE}/centreon-widget-httploader/centreon-widget-httploader-${WIDGET_HTTP_LOADER_VER}.tar.gz"
WIDGET_ENGINE_STATUS="${WIDGET_BASE}/centreon-widget-engine-status/centreon-widget-engine-status-${WIDGET_ENGINE_STATUS_VER}.tar.gz"
WIDGET_GRAPH="${WIDGET_BASE}/centreon-widget-graph-monitoring/centreon-widget-graph-monitoring-${WIDGET_GRAPH_VER}.tar.gz"
## nrpe
NRPE_VERSION="3.2.1"
NRPE_URL="https://github.com/NagiosEnterprises/nrpe/archive/nrpe-3.2.1.tar.gz"
## source script
DIR_SCRIPT=$(cd $( dirname ${BASH_SOURCE[0]}) && pwd )
## Temp install dir
DL_DIR="/usr/local/src"
## Install dir
INSTALL_DIR="/usr/share"
## Log install file
INSTALL_LOG=${DL_DIR}"/centreon-install.log"
## Set mysql-server root password
MYSQL_PASSWORD="password"
## Users and groups
ENGINE_USER="centreon-engine"
ENGINE_GROUP="centreon-engine"
BROKER_USER="centreon-broker"
BROKER_GROUP="centreon-broker"
CENTREON_USER="centreon"
CENTREON_GROUP="centreon"
## TMPL file (template install file for Centreon)
CENTREON_TMPL="centreon_engine.tmpl"
ETH0_IP=`/sbin/ip route get 8.8.8.8 | /usr/bin/awk 'NR==1 {print $NF}'`
## TimeZone php
VARTIMEZONE="Europe/Paris"
## verbose script
SCRIPT_VERBOSE=false

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} -n=[yes|no] -v

This program create Central Centreon

    -n|--nrpe     : add check_nrpe
    -v|--verbose  : add messages
    -h|--help     : help
EOF
}

function text_params () {
  ESC_SEQ="\x1b["
  bold=`tput bold`
  normal=`tput sgr0`
  COL_RESET=$ESC_SEQ"39;49;00m"
  COL_GREEN=$ESC_SEQ"32;01m"
  COL_RED=$ESC_SEQ"31;01m"
  STATUS_FAIL="[$COL_RED${bold}FAIL${normal}$COL_RESET]"
  STATUS_OK="[$COL_GREEN${bold} OK ${normal}$COL_RESET]"
}

function nonfree_uninstall () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
           Add Stretch repo for non-free
======================================================================
" | tee -a ${INSTALL_LOG}

rm /etc/apt/sources.list.d/stretch-nonfree.list


}


function mariadb_uninstall() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                        Uninstall BDD Centreon
======================================================================
" | tee -a ${INSTALL_LOG}

/usr/bin/mysql <<EOF
drop database centreon;
drop database centreon_storage;
use mysql;
drop user 'centreon'@'localhost';
EOF

}

function clib_uninstall () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                          uninstall Clib
======================================================================
" | tee -a ${INSTALL_LOG}


cd ${DL_DIR}
if [[ -e centreon-clib-${CLIB_VER}.tar.gz ]] ;
then
    rm centreon-clib-${CLIB_VER}.tar.gz
    rm -rf centreon-clib-${CLIB_VER}/
fi

[ "$SCRIPT_VERBOSE" = true ] && echo "====> Delete files" | tee -a ${INSTALL_LOG}

rm /usr/lib/pkgconfig/centreon-clib.pc
rm /usr/lib/libcentreon_clib.so
rm -rf /usr/include/com/centreon/

}

function centreon_connectors_uninstall () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
               Uninstall Centreon connectors
======================================================================
" | tee -a ${INSTALL_LOG}


cd ${DL_DIR}
if [[ -e centreon-connectors-${CONNECTOR_VER}.tar.gz ]]
  then
    rm centreon-connectors-${CONNECTOR_VER}.tar.gz
    rm -rf centreon-connector-${CONNECTOR_VER}/
fi

[ "$SCRIPT_VERBOSE" = true ] && echo "====> Delete files" | tee -a ${INSTALL_LOG}

rm /usr/lib/centreon-connector/centreon_connector_perl
rm /usr/lib/centreon-connector/centreon_connector_ssh



}

function centreon_engine_uninstall () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                    Uninstall Centreon Engine
======================================================================
" | tee -a ${INSTALL_LOG}

systemctl stop centengine.service >> ${INSTALL_LOG}
systemctl disable centengine.service >> ${INSTALL_LOG}
systemctl daemon-reload >> ${INSTALL_LOG}

cd ${DL_DIR}
if [[ -e centreon-engine-${ENGINE_VER}.tar.gz ]]
  then
    rm centreon-engine-${ENGINE_VER}.tar.gz
    rm -rf centreon-engine-${ENGINE_VER}/
fi


[ "$SCRIPT_VERBOSE" = true ] && echo "====> Delete Files" | tee -a ${INSTALL_LOG}

rm /usr/lib/pkgconfig/centengine.pc
rm /lib/systemd/system/centengine.service
rm /etc/logrotate.d/centengine
rm /usr/sbin/centengine
rm /usr/sbin/centenginestats
rm -rf /usr/include/centreon-engine/
rm -rf /etc/centreon-engine/
rm -rf /var/log/centreon-engine/
rm /usr/lib/centreon-engine/externalcmd.so

groupdel ${ENGINE_GROUP}
userdel -r ${ENGINE_GROUP}

}

function monitoring_plugin_uninstall () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                     Uninstall Monitoring Plugins
======================================================================
" | tee -a ${INSTALL_LOG}


cd ${DL_DIR}
if [[ -e monitoring-plugins-${PLUGIN_VER}.tar.gz ]]
  then
    rm monitoring-plugins-${PLUGIN_VER}.tar.gz
    rm -rf monitoring-plugins-${PLUGIN_VER}/
fi


[ "$SCRIPT_VERBOSE" = true ] && echo "====> Delete files" | tee -a ${INSTALL_LOG}

rm -rf /usr/lib/nagios/

}


function centreon_plugins_uninstall() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
=======================================================================
                    Uninstall Centreon Plugins
=======================================================================
" | tee -a ${INSTALL_LOG}
cd ${DL_DIR}

if [[ -e centreon-plugins-${PLUGIN_CENTREON_VER}.tar.gz ]]
  then
    rm centreon-plugins-${PLUGIN_CENTREON_VER}.tar.gz
    rm -rf centreon-plugins-${PLUGIN_CENTREON_VER}/
fi

rm -rf /usr/lib/centreon/plugins/

}

function centreon_broker_uninstall() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                     Uninstall Centreon Broker
======================================================================
" | tee -a ${INSTALL_LOG}


[ "$SCRIPT_VERBOSE" = true ] && echo "
==================   Uninstall rrdtools 1.4.7     =====================
" | tee -a ${INSTALL_LOG}


cd ${DL_DIR}
rm rrdtool-1.4.7.tar.gz
rm -rf rrdtool-1.4.7/

[ "$SCRIPT_VERBOSE" = true ] && echo "====> Delete files" | tee -a ${INSTALL_LOG}


rm /usr/lib/pkgconfig/librrd.pc
rm /etc/ld.so.conf.d/rrdtool-broker.conf
rm -rf /opt/


cd ${DL_DIR}
if [[ -e centreon-broker-${BROKER_VER}.tar.gz ]]
  then
    rm centreon-broker-${BROKER_VER}.tar.gz
    rm -rf centreon-broker-${BROKER_VER}/
fi

[ "$SCRIPT_VERBOSE" = true ] && echo "====> Delete files" | tee -a ${INSTALL_LOG}


systemctl stop cbd.service >> ${INSTALL_LOG}
systemctl disable cbd.service >> ${INSTALL_LOG}
systemctl daemon-reload >> ${INSTALL_LOG}
 
rm -rf /var/log/centreon-broker/
rm -rf /var/lib/centreon-broker/

rm /lib/systemd/system/cbd.service
rm -rf /etc/centreon-broker/
rm /usr/sbin/cbd
rm -rf /usr/include/centreon-broker/
rm /usr/sbin/cbwd
rm -rf /usr/share/centreon/lib/centreon-broker/
rm -rf /usr/lib/centreon-broker/
rm -rf /var/log/centreon-broker/


groupdel ${BROKER_GROUP}
userdel -r ${BROKER_GROUP}
}

function php_fpm_uninstall() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                     Uninstall Php-fpm
======================================================================
" | tee -a ${INSTALL_LOG}

rm /etc/apt/sources.list.d/php.list


}

function uninstall_centreon_tmpl() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                  Centreon template generation
======================================================================
" | tee -a ${INSTALL_LOG}
rm ${DL_DIR}/${CENTREON_TMPL} 
}

function centreon_uninstall () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                  Uninstall Centreon Web Interface
======================================================================
" | tee -a ${INSTALL_LOG}



cd ${DL_DIR}

if [[ -e centreon-web-${CENTREON_VER}.tar.gz ]]
  then
    rm centreon-web-${CENTREON_VER}.tar.gz
    rm -rf centreon-web-${CENTREON_VER}/
fi


groupdel ${CENTREON_GROUP}
userdel -r ${CENTREON_GROUP}

}

function post_uninstall () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
=====================================================================
                          Post install
=====================================================================
" | tee -a ${INSTALL_LOG}

#delete files

rm -rf ${INSTALL_DIR}/centreon/
rm /etc/mysql/conf.d/centreon.cnf
rm -rf /var/log/centreon/
rm -rf /usr/share/perl5/centreon/
rm /var/lib/apache2/conf/disabled_by_admin/centreon
rm /etc/sudoers.d/centreon
rm /etc/php/7.1/fpm/pool.d/centreon.conf
rm /etc/cron.d/centreon
rm /etc/cron.d/centstorage
rm -rf /etc/centreon/
rm /etc/rc0.d/K01centreontrapd
rm /etc/rc1.d/K01centreontrapd
rm /etc/rc2.d/S01centreontrapd
rm /etc/rc3.d/S01centreontrapd
rm /etc/rc4.d/S01centreontrapd
rm /etc/rc5.d/S01centreontrapd
rm /etc/rc6.d/K01centreontrapd
rm -rf /etc/snmp/centreon_traps/
rm /etc/default/centreontrapd
rm /etc/init.d/centreontrapd
rm /etc/logrotate.d/centreon
rm /etc/logrotate.d/centreontrapd

a2disconf centreon.conf >> ${INSTALL_LOG}
systemctl restart apache2 php7.1-fpm >> ${INSTALL_LOG}

rm /etc/apache2/conf-available/centreon.conf
rm -rf /var/lib/centreon/


}

##ADDONS

function widget_uninstall() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
=======================================================================
                         Uninstall WIDGETS
=======================================================================
" | tee -a ${INSTALL_LOG}
cd ${DL_DIR}
  rm -rf centreon-widget-live-top10-cpu-usage/
  rm -rf centreon-widget-live-top10-memory-usage/

}

function add_check_nrpe() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
=======================================================================
                         Install check_nrpe3
=======================================================================
" | tee -a ${INSTALL_LOG}


cd ${DL_DIR}
if [[ -e nrpe.tar.gz ]] ;
  then
    rm nrpe.tar.gz
    rm -rf nrpe-nrpe-${NRPE_VERSION}/
fi


[ "$SCRIPT_VERBOSE" = true ] && echo "====> Delete Files" | tee -a ${INSTALL_LOG}


}

function main () {
  if [ "$ADD_NRPE" == "yes" ]
  then
echo "
================| Centreon Central Uninstall details $VERSION_BATCH |============
                  MariaDB    : ${MARIADB_VER}
                  Clib       : ${CLIB_VER}
                  Connector  : ${CONNECTOR_VER}
                  Engine     : ${ENGINE_VER}
                  Plugins    : ${PLUGIN_VER} & ${PLUGIN_CENTREON_VER}
                  Broker     : ${BROKER_VER}
                  Centreon   : ${CENTREON_VER}
                  NRPE       : ${NRPE_VERSION}
                  Install dir: ${INSTALL_DIR}
                  Source dir : ${DL_DIR}
======================================================================
"
  else
echo "
================| Centreon Central Uninstall details $VERSION_BATCH |============
                  MariaDB    : ${MARIADB_VER}
                  Clib       : ${CLIB_VER}
                  Connector  : ${CONNECTOR_VER}
                  Engine     : ${ENGINE_VER}
                  Plugins    : ${PLUGIN_VER} & ${PLUGIN_CENTREON_VER}
                  Broker     : ${BROKER_VER}
                  Centreon   : ${CENTREON_VER}
                  Install dir: ${INSTALL_DIR}
                  Source dir : ${DL_DIR}
======================================================================
"
  fi
text_params

nonfree_uninstall 2>> ${INSTALL_LOG} 
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step1${normal}  => repo non-free on Stretch Uninstall                      ${STATUS_FAIL}"
  else
    echo -e "${bold}Step1${normal}  => repo non-free on Stretch Uninstall                      ${STATUS_OK}"
fi

mariadb_uninstall 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step2${normal}  => Uninstall BDD Centreon                                       ${STATUS_FAIL}"
  else
    echo -e "${bold}Step2${normal}  => Uninstall BDD Centreon                                       ${STATUS_OK}"
fi

clib_uninstall 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step3${normal}  => Clib uninstall                                          ${STATUS_FAIL}"
  else
    echo -e "${bold}Step3${normal}  => Clib uninstall                                          ${STATUS_OK}"
fi

centreon_connectors_uninstall 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step4${normal}  => Centreon Perl and SSH connectors uninstall              ${STATUS_FAIL}"
  else
    echo -e "${bold}Step4${normal}  => Centreon Perl and SSH connectors uninstall              ${STATUS_OK}"
fi

centreon_engine_uninstall 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step5${normal}  => Centreon Engine uninstall                               ${STATUS_FAIL}"
  else
    echo -e "${bold}Step5${normal}  => Centreon Engine uninstall                               ${STATUS_OK}"
fi

monitoring_plugin_uninstall 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step6${normal}  => Monitoring plugins uninstall                            ${STATUS_FAIL}"
  else
    echo -e "${bold}Step6${normal}  => Monitoring plugins uninstall                            ${STATUS_OK}"
fi

centreon_plugins_uninstall 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step7${normal}  => Centreon plugins uninstall                              ${STATUS_FAIL}"
  else
    echo -e "${bold}Step7${normal}  => Centreon plugins uninstall                              ${STATUS_OK}"
fi

centreon_broker_uninstall 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step8${normal}  => Centreon Broker uninstall                               ${STATUS_FAIL}"
  else
    echo -e "${bold}Step8${normal}  => Centreon Broker uninstall                               ${STATUS_OK}"
fi

php_fpm_uninstall 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step9${normal}  => Php-fpm uninstall                                       ${STATUS_FAIL}"
  else
    echo -e "${bold}Step9${normal}  => Php-fpm uninstall                                       ${STATUS_OK}"
fi


uninstall_centreon_tmpl 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step10${normal}  => Uninstall Centreon template                           ${STATUS_FAIL}"
  else
    echo -e "${bold}Step10${normal}  => Uninstall Centreon template                           ${STATUS_OK}"
fi

centreon_uninstall 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step11${normal}  => Centreon web interface uninstall                        ${STATUS_FAIL}"
  else
    echo -e "${bold}Step11${normal}  => Centreon web interface uninstall                        ${STATUS_OK}"
fi

post_uninstall 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step12${normal} => Post uninstall                                          ${STATUS_FAIL}"
  else
    echo -e "${bold}Step12${normal} => Post uninstall                                          ${STATUS_OK}"
fi

widget_uninstall 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step13${normal} => Widgets uninstall                                       ${STATUS_FAIL}"
  else
    echo -e "${bold}Step13${normal} => Widgets uninstall                                       ${STATUS_OK}"
fi
if [ "$ADD_NRPE" == "yes" ]
then
  add_check_nrpe 2>>${INSTALL_LOG}
  if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step14${normal} => Nrpe install                                          ${STATUS_FAIL}"
  else
    echo -e "${bold}Step14${normal} => Nrpe install                                          ${STATUS_OK}"
  fi

fi
echo ""
echo "##### Install completed #####" | tee -a ${INSTALL_LOG}
}


#check menu
for i in "$@"
do
  case $i in
    -n=*|--nrpe=*)
      ADD_NRPE="${i#*=}"
      shift # past argument=value
      ;;
    -v|--verbose)
      SCRIPT_VERBOSE=true
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

# Check NRPE yes/no
if [[ $ADD_NRPE =~ ^[yY][eE][sS]|[yY]$ ]]; then
  ADD_NRPE="yes"
else
  ADD_NRPE="no"
fi

# Exec main function
main
echo -e ""
echo -e "${bold}Go to http://${ETH0_IP}/centreon to complete the setup${normal} "
echo -e ""
