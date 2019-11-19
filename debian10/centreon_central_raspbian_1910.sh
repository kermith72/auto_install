#!/bin/bash
# Centreon 19.10 + engine install script for Raspian Buster
# v 1.39
# 19/11/2019
# Thanks to Remy and Pixelabs
#
export DEBIAN_FRONTEND=noninteractive
# Variables
## Versions
VERSION_BATCH="v 1.39"
CLIB_VER="19.10.0"
CONNECTOR_VER="19.10.0"
ENGINE_VER="19.10.6"
PLUGIN_VER="2.2"
PLUGIN_CENTREON_VER="20191016"
BROKER_VER="19.10.1"
CENTREON_VER="19.10.1"
# MariaDB Series
MARIADB_VER='10.0'
## Sources URL
BASE_URL="http://files.download.centreon.com/public"
CLIB_URL="${BASE_URL}/centreon-clib/centreon-clib-${CLIB_VER}.tar.gz"
CONNECTOR_URL="${BASE_URL}/centreon-connectors/centreon-connector-${CONNECTOR_VER}.tar.gz"
ENGINE_URL="${BASE_URL}/centreon-engine/centreon-engine-${ENGINE_VER}.tar.gz"
PLUGIN_URL="https://www.monitoring-plugins.org/download/monitoring-plugins-${PLUGIN_VER}.tar.gz"
PLUGIN_CENTREON_URL="${BASE_URL}/centreon-plugins/centreon-plugins-${PLUGIN_CENTREON_VER}.tar.gz"
BROKER_URL="${BASE_URL}/centreon-broker/centreon-broker-${BROKER_VER}.tar.gz"
CENTREON_URL="${BASE_URL}/centreon/centreon-web-${CENTREON_VER}.tar.gz"
CLAPI_URL="${BASE_URL}/Modules/CLAPI/centreon-clapi-${CLAPI_VER}.tar.gz"
## Sources widgetsMonitoring engine init.d script
WIDGET_HOST_VER="19.10.0"
WIDGET_HOSTGROUP_VER="19.10.0"
WIDGET_SERVICE_VER="19.10.1"
WIDGET_SERVICEGROUP_VER="19.10.0"
WIDGET_GRID_MAP_VER="19.10.0"
WIDGET_TOP_CPU_VER="19.10.0"
WIDGET_TOP_MEMORY_VER="19.10.0"
WIDGET_TACTICAL_OVERVIEW_VER="19.10.0"
WIDGET_HTTP_LOADER_VER="19.10.0"
WIDGET_ENGINE_STATUS_VER="19.10.0"
WIDGET_GRAPH_VER="19.10.0"
WIDGET_BASE="http://files.download.centreon.com/public/centreon-widgets"
WIDGET_HOST="${WIDGET_BASE}/centreon-widget-host-monitoring/centreon-widget-host-monitoring-${WIDGET_HOST_VER}.tar.gz"
WIDGET_HOSTGROUP="${WIDGET_BASE}/centreon-widget-hostgroup-monitoring/centreon-widget-hostgroup-monitoring-${WIDGET_HOSTGROUP_VER}.tar.gz"
WIDGET_SERVICE="${WIDGET_BASE}/centreon-widget-service-monitoring/centreon-widget-service-monitoring-${WIDGET_SERVICE_VER}.tar.gz"
WIDGET_SERVICEGROUP="${WIDGET_BASE}/centreon-widget-servicegroup-monitoring/centreon-widget-servicegroup-monitoring-${WIDGET_SERVICEGROUP_VER}.tar.gz"
WIDGET_GRID_MAP="${WIDGET_BASE}/centreon-widget-grid-map/centreon-widget-grid-map-${WIDGET_GRID_MAP_VER}.tar.gz"
WIDGET_TOP_CPU="${WIDGET_BASE}/centreon-widget-live-top10-cpu-usage/centreon-widget-live-top10-cpu-usage-${WIDGET_TOP_CPU_VER}.tar.gz"
WIDGET_TOP_MEMORY="${WIDGET_BASE}/centreon-widget-live-top10-memory-usage/centreon-widget-live-top10-memory-usage-${WIDGET_TOP_MEMORY_VER}.tar.gz"
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
ETH0_IP=`/sbin/ip route get 8.8.8.8 | /usr/bin/awk 'NR==1 {print $7}'`
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


function mariadb_install() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                        Install MariaDB
======================================================================
" | tee -a ${INSTALL_LOG}

apt-get install -y mariadb-server >> ${INSTALL_LOG}
}

function clib_install () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                          Install Clib
======================================================================
" | tee -a ${INSTALL_LOG}

apt-get install -y build-essential cmake >> ${INSTALL_LOG}

cd ${DL_DIR}
if [[ -e centreon-clib-${CLIB_VER}.tar.gz ]] ;
  then
    echo 'File already exist !' | tee -a ${INSTALL_LOG}
  else
    wget ${CLIB_URL} -O ${DL_DIR}/centreon-clib-${CLIB_VER}.tar.gz >> ${INSTALL_LOG}
fi

tar xzf centreon-clib-${CLIB_VER}.tar.gz
cd centreon-clib-${CLIB_VER}

[ "$SCRIPT_VERBOSE" = true ] && echo "====> Compilation" | tee -a ${INSTALL_LOG}

# add directive compilation
sed -i '32i\set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++98 -fpermissive")' ${DL_DIR}/centreon-clib-${CLIB_VER}/build/CMakeLists.txt

cmake \
   -DWITH_TESTING=0 \
   -DWITH_PREFIX=/usr \
   -DWITH_SHARED_LIB=1 \
   -DWITH_STATIC_LIB=0 \
   -DWITH_PKGCONFIG_DIR=/usr/lib/pkgconfig . >> ${INSTALL_LOG}
make >> ${INSTALL_LOG}
make install >> ${INSTALL_LOG}

}

function centreon_connectors_install () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
               Install Centreon Perl connectors
======================================================================
" | tee -a ${INSTALL_LOG}
apt-get install -y libperl-dev >> ${INSTALL_LOG}

cd ${DL_DIR}
if [[ -e centreon-connector-${CONNECTOR_VER}.tar.gz ]]
  then
    echo 'File already exist !' | tee -a ${INSTALL_LOG}
  else
    wget ${CONNECTOR_URL} -O ${DL_DIR}/centreon-connector-${CONNECTOR_VER}.tar.gz >> ${INSTALL_LOG}
    [ $? != 0 ] && return 1
fi

tar xzf centreon-connector-${CONNECTOR_VER}.tar.gz
cd ${DL_DIR}/centreon-connector-${CONNECTOR_VER}/perl/build

[ "$SCRIPT_VERBOSE" = true ] && echo "====> Compilation" | tee -a ${INSTALL_LOG}

# add directive compilation
sed -i '27i\set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++98 -fpermissive")' ${DL_DIR}/centreon-connector-${CONNECTOR_VER}/perl/build/CMakeLists.txt

cmake \
 -DWITH_PREFIX=/usr  \
 -DWITH_PREFIX_BINARY=/usr/lib/centreon-connector  \
 -DWITH_CENTREON_CLIB_INCLUDE_DIR=/usr/include \
 -DWITH_TESTING=0 . >> ${INSTALL_LOG}
make >> ${INSTALL_LOG}
make install >> ${INSTALL_LOG}

[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
               Install Centreon SSH connectors
======================================================================
" | tee -a ${INSTALL_LOG}
# install Centreon SSH Connector
apt-get install -y libssh2-1-dev libgcrypt-dev >> ${INSTALL_LOG}

# Cleanup to prevent space full on /var
apt-get clean >> ${INSTALL_LOG}

cd ${DL_DIR}/centreon-connector-${CONNECTOR_VER}/ssh/build

[ "$SCRIPT_VERBOSE" = true ] && echo "====> Compilation" | tee -a ${INSTALL_LOG}

# add directive compilation
sed -i '27i\set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++98 -fpermissive")' ${DL_DIR}/centreon-connector-${CONNECTOR_VER}/ssh/build/CMakeLists.txt


cmake \
 -DWITH_PREFIX=/usr  \
 -DWITH_PREFIX_BINARY=/usr/lib/centreon-connector  \
 -DWITH_CENTREON_CLIB_INCLUDE_DIR=/usr/include \
 -DWITH_TESTING=0 . >> ${INSTALL_LOG}
make >> ${INSTALL_LOG}
make install >> ${INSTALL_LOG}
}

function centreon_engine_install () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                    Install Centreon Engine
======================================================================
" | tee -a ${INSTALL_LOG}
git clone https://github.com/kermith72/auto_install.git
groupadd -g 6001 ${ENGINE_GROUP}
useradd -u 6001 -g ${ENGINE_GROUP} -m -r -d /var/lib/centreon-engine -c "Centreon-engine Admin" -s /bin/bash ${ENGINE_USER}

apt-get install -y libcgsi-gsoap-dev zlib1g-dev libssl-dev libxerces-c-dev >> ${INSTALL_LOG}

# Cleanup to prevent space full on /var
apt-get clean >> ${INSTALL_LOG}

cd ${DL_DIR}
if [[ -e centreon-engine-${ENGINE_VER}.tar.gz ]]
  then
    echo 'File already exist !' | tee -a ${INSTALL_LOG}
  else
    wget ${ENGINE_URL} -O ${DL_DIR}/centreon-engine-${ENGINE_VER}.tar.gz >> ${INSTALL_LOG}
    [ $? != 0 ] && return 1
fi

tar xzf centreon-engine-${ENGINE_VER}.tar.gz
cd ${DL_DIR}/centreon-engine-${ENGINE_VER}

[ "$SCRIPT_VERBOSE" = true ] && echo "====> Compilation" | tee -a ${INSTALL_LOG}


cmake \
   -DWITH_CENTREON_CLIB_INCLUDE_DIR=/usr/include \
   -DWITH_CENTREON_CLIB_LIBRARY_DIR=/usr/lib \
   -DWITH_PREFIX=/usr \
   -DWITH_PREFIX_BIN=/usr/sbin \
   -DWITH_PREFIX_CONF=/etc/centreon-engine \
   -DWITH_USER=${ENGINE_USER} \
   -DWITH_GROUP=${ENGINE_GROUP} \
   -DWITH_LOGROTATE_SCRIPT=1 \
   -DWITH_VAR_DIR=/var/log/centreon-engine \
   -DWITH_RW_DIR=/var/lib/centreon-engine/rw \
   -DWITH_STARTUP_SCRIPT=systemd  \
   -DWITH_STARTUP_DIR=/lib/systemd/system  \
   -DWITH_PKGCONFIG_SCRIPT=1 \
   -DWITH_PKGCONFIG_DIR=/usr/lib/pkgconfig \
   -DWITH_TESTING=0 . >> ${INSTALL_LOG}
make >> ${INSTALL_LOG}
make install >> ${INSTALL_LOG}

systemctl enable centengine.service >> ${INSTALL_LOG}
systemctl daemon-reload >> ${INSTALL_LOG}
}

function monitoring_plugin_install () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                     Install Monitoring Plugins
======================================================================
" | tee -a ${INSTALL_LOG}

apt-get install --force-yes -y monitoring-plugins  libgnutls28-dev libssl-dev libkrb5-dev \
        libldap2-dev libsnmp-dev gawk \
        libwrap0-dev libmcrypt-dev smbclient fping gettext dnsutils libmodule-build-perl libmodule-install-perl \
        libnet-snmp-perl >> ${INSTALL_LOG}

#modify plugin check_icmp
chown -R root:${ENGINE_GROUP} /usr/lib/nagios/plugins/check_icmp
chmod u+s /usr/lib/nagios/plugins/check_icmp

# Cleanup to prevent space full on /var
apt-get clean >> ${INSTALL_LOG}

cd ${DL_DIR}
if [[ -e monitoring-plugins-${PLUGIN_VER}.tar.gz ]]
  then
    echo 'File already exist !' | tee -a ${INSTALL_LOG}
  else
    wget --no-check-certificate ${PLUGIN_URL} -O ${DL_DIR}/monitoring-plugins-${PLUGIN_VER}.tar.gz >> ${INSTALL_LOG}
    [ $? != 0 ] && return 1
fi

tar xzf monitoring-plugins-${PLUGIN_VER}.tar.gz
cd ${DL_DIR}/monitoring-plugins-${PLUGIN_VER}

[ "$SCRIPT_VERBOSE" = true ] && echo "====> Compilation" | tee -a ${INSTALL_LOG}

./configure --with-nagios-user=${ENGINE_USER} --with-nagios-group=${ENGINE_GROUP} \
--prefix=/usr/lib/nagios/plugins --libexecdir=/usr/lib/nagios/plugins --enable-perl-modules --with-openssl=/usr/bin/openssl \
--enable-extra-opts >> ${INSTALL_LOG}

make >> ${INSTALL_LOG}
make install >> ${INSTALL_LOG}
}


function centreon_plugins_install() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
=======================================================================
                    Install Centreon Plugins
=======================================================================
" | tee -a ${INSTALL_LOG}
cd ${DL_DIR}
DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes libxml-libxml-perl libjson-perl libwww-perl libxml-xpath-perl \
            libxml-simple-perl libdatetime-perl libdate-manip-perl libnet-ldap-perl \
            libnet-telnet-perl libnet-ntp-perl libnet-dns-perl libdbi-perl libdbd-mysql-perl libdbd-pg-perl git-core >> ${INSTALL_LOG}

cd ${DL_DIR}
if [[ -e centreon-plugins-${PLUGIN_CENTREON_VER}.tar.gz ]]
  then
    echo 'File already exist !' | tee -a ${INSTALL_LOG}
  else
    wget ${PLUGIN_CENTREON_URL} -O ${DL_DIR}/centreon-plugins-${PLUGIN_CENTREON_VER}.tar.gz >> ${INSTALL_LOG}
fi

tar xzf centreon-plugins-${PLUGIN_CENTREON_VER}.tar.gz
cd ${DL_DIR}/centreon-plugins-${PLUGIN_CENTREON_VER}

chown -R ${ENGINE_USER}:${ENGINE_GROUP} *
chmod +x *
mkdir -p /usr/lib/centreon/plugins
cp -Rp * /usr/lib/centreon/plugins/

#bug plugin 20191016
if [[ ${PLUGIN_CENTREON_VER} == "20191016" ]]; then
  cd ${DL_DIR}
  if [[ -e centreon-plugins-20190704.tar.gz ]]
  then
    echo 'File already exist !' | tee -a ${INSTALL_LOG}
  else
    wget http://files.download.centreon.com/public/centreon-plugins/centreon-plugins-20190704.tar.gz -O ${DL_DIR}/centreon-plugins-20190704.tar.gz >> ${INSTALL_LOG}
  fi

  tar xzf centreon-plugins-20190704.tar.gz
  cd ${DL_DIR}/centreon-plugins-20190704
  chown -R ${ENGINE_USER}:${ENGINE_GROUP} *
  chmod +x *
  cp centreon_centreon_database.pl /usr/lib/centreon/plugins/
  cp centreon_mysql.pl /usr/lib/centreon/plugins/
fi

}

function centreon_broker_install() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                     Install Centreon Broker
======================================================================
" | tee -a ${INSTALL_LOG}

groupadd -g 6002 ${BROKER_GROUP}
useradd -u 6002 -g ${BROKER_GROUP} -m -r -d /var/lib/centreon-broker -c "Centreon-broker Admin" -s /bin/bash  ${BROKER_USER}
usermod -aG ${BROKER_GROUP} ${ENGINE_USER}

apt-get install git librrd-dev libqt4-dev libqt4-sql-mysql libgnutls28-dev lsb-release liblua5.2-dev -y >> ${INSTALL_LOG}

# Cleanup to prevent space full on /var
apt-get clean >> ${INSTALL_LOG}

cd ${DL_DIR}
if [[ -e centreon-broker-${BROKER_VER}.tar.gz ]]
  then
    echo 'File already exist !' | tee -a ${INSTALL_LOG}
  else
    wget ${BROKER_URL} -O ${DL_DIR}/centreon-broker-${BROKER_VER}.tar.gz >> ${INSTALL_LOG}
    [ $? != 0 ] && return 1
fi

tar xzf centreon-broker-${BROKER_VER}.tar.gz
cd ${DL_DIR}/centreon-broker-${BROKER_VER}

[ "$SCRIPT_VERBOSE" = true ] && echo "====> Compilation broker" | tee -a ${INSTALL_LOG}

cmake \
    -DWITH_DAEMONS='central-broker;central-rrd' \
    -DWITH_GROUP=${BROKER_GROUP} \
    -DWITH_PREFIX=/usr \
    -DWITH_PREFIX_BIN=/usr/sbin  \
    -DWITH_PREFIX_CONF=/etc/centreon-broker  \
    -DWITH_PREFIX_LIB=/usr/lib/centreon-broker \
    -DWITH_PREFIX_VAR=/var/lib/centreon-broker \
    -DWITH_PREFIX_MODULES=/usr/share/centreon/lib/centreon-broker \
    -DWITH_STARTUP_SCRIPT=systemd  \
    -DWITH_STARTUP_DIR=/lib/systemd/system  \
    -DWITH_TESTING=0 \
    -DWITH_USER=${BROKER_USER} . >> ${INSTALL_LOG}
make >> ${INSTALL_LOG}
make install >> ${INSTALL_LOG}
systemctl enable cbd.service >> ${INSTALL_LOG}
systemctl daemon-reload >> ${INSTALL_LOG}

if [[ -d /var/log/centreon-broker ]]
  then
    echo "Directory already exist!" | tee -a ${INSTALL_LOG}
  else
    mkdir /var/log/centreon-broker
fi
chown ${BROKER_USER}:${ENGINE_GROUP} /var/log/centreon-broker
chmod 775 /var/log/centreon-broker
if [[ -d /var/lib/centreon-broker ]]
  then
    chmod 775 /var/lib/centreon-broker
fi


# Cleanup to prevent space full on /var
apt-get clean >> ${INSTALL_LOG}
}

function php_fpm_install() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                     Install Php-fpm
======================================================================
" | tee -a ${INSTALL_LOG}

apt-get install php php7.3-opcache libapache2-mod-php php-mysql \
	php-curl php-json php-gd php-intl php-mbstring php-xml \
	php-zip php-fpm php-readline -y >> ${INSTALL_LOG}
	

DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes ntp \
	rrdtool php-sqlite3 php-pear sudo tofrodos bsd-mailx lsb-release \
	mariadb-server libconfig-inifiles-perl libcrypt-des-perl \
	librrds-perl libdigest-hmac-perl libdigest-sha-perl libgd-perl \
	php-ldap php-snmp php7.3-db snmp snmpd snmptrapd libnet-snmp-perl \
	libsnmp-perl snmp-mibs-downloader >> ${INSTALL_LOG}


# Cleanup to prevent space full on /var
apt-get clean >> ${INSTALL_LOG}

a2enmod proxy_fcgi setenvif proxy rewrite >> ${INSTALL_LOG}
a2enconf php7.3-fpm >> ${INSTALL_LOG}
a2dismod php7.3 >> ${INSTALL_LOG}
systemctl restart apache2 php7.3-fpm >> ${INSTALL_LOG}

}

function create_centreon_tmpl() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                  Centreon template generation
======================================================================
" | tee -a ${INSTALL_LOG}
cat > ${DL_DIR}/${CENTREON_TMPL} << EOF
#Centreon template
PROCESS_CENTREON_WWW=1
PROCESS_CENTSTORAGE=1
PROCESS_CENTCORE=1
PROCESS_CENTREON_PLUGINS=1
PROCESS_CENTREON_SNMP_TRAPS=1

LOG_DIR="$BASE_DIR/log"
LOG_FILE="$LOG_DIR/install_centreon.log"
TMPDIR="/tmp/centreon-setup"
SNMP_ETC="/etc/snmp/"
PEAR_MODULES_LIST="pear.lst"
PEAR_AUTOINST=1

INSTALL_DIR_CENTREON="${INSTALL_DIR}/centreon"
CENTREON_BINDIR="${INSTALL_DIR}/centreon/bin"
CENTREON_DATADIR="${INSTALL_DIR}/centreon/data"
CENTREON_USER=${CENTREON_USER}
CENTREON_GROUP=${CENTREON_GROUP}
PLUGIN_DIR="/usr/lib/nagios/plugins"
CENTREON_LOG="/var/log/centreon"
CENTREON_ETC="/etc/centreon"
CENTREON_RUNDIR="/var/run/centreon"
CENTREON_GENDIR="/var/cache/centreon"
CENTSTORAGE_RRD="/var/lib/centreon"
CENTREON_CACHEDIR="/var/cache/centreon"
CENTSTORAGE_BINDIR="${INSTALL_DIR}/centreon/bin"
CENTCORE_BINDIR="${INSTALL_DIR}/centreon/bin"
CENTREON_VARLIB="/var/lib/centreon"
CENTPLUGINS_TMP="/var/lib/centreon/centplugins"
CENTPLUGINSTRAPS_BINDIR="${INSTALL_DIR}/centreon/bin"
SNMPTT_BINDIR="${INSTALL_DIR}/centreon/bin"
CENTCORE_INSTALL_INIT=1
CENTCORE_INSTALL_RUNLVL=1
CENTSTORAGE_INSTALL_INIT=0
CENTSTORAGE_INSTALL_RUNLVL=0
CENTREONTRAPD_BINDIR="${INSTALL_DIR}/centreon/bin"
CENTREONTRAPD_INSTALL_INIT=1
CENTREONTRAPD_INSTALL_RUNLVL=1
CENTREON_PLUGINS=/usr/lib/centreon/plugins

INSTALL_DIR_NAGIOS="/usr/bin"
CENTREON_ENGINE_USER="${ENGINE_USER}"
MONITORINGENGINE_USER="${CENTREON_USER}"
MONITORINGENGINE_LOG="/var/log/centreon-engine"
MONITORINGENGINE_INIT_SCRIPT="centengine"
MONITORINGENGINE_BINARY="/usr/sbin/centengine"
MONITORINGENGINE_ETC="/etc/centreon-engine"
NAGIOS_PLUGIN="/usr/lib/nagios/plugins"
FORCE_NAGIOS_USER=1
NAGIOS_GROUP="${CENTREON_GROUP}"
FORCE_NAGIOS_GROUP=1
NAGIOS_INIT_SCRIPT="/etc/init.d/centengine"
CENTREON_ENGINE_CONNECTORS="/usr/lib/centreon-connector"
BROKER_USER="${BROKER_USER}"
BROKER_ETC="/etc/centreon-broker"
BROKER_INIT_SCRIPT="cbd"
BROKER_LOG="/var/log/centreon-broker"
SERVICE_BINARY="/usr/sbin/service"

DIR_APACHE="/etc/apache2"
DIR_APACHE_CONF="/etc/apache2/conf-available"
APACHE_CONF="apache.conf"
WEB_USER="www-data"
WEB_GROUP="www-data"
APACHE_RELOAD=1
BIN_RRDTOOL="/opt/rddtool-broker/bin/rrdtool"
BIN_MAIL="/usr/bin/mail"
BIN_SSH="/usr/bin/ssh"
BIN_SCP="/usr/bin/scp"
PHP_BIN="/usr/bin/php"
GREP="/bin/grep"
CAT="/bin/cat"
SED="/bin/sed"
CHMOD="/bin/chmod"
CHOWN="/bin/chown"

RRD_PERL="/usr/lib/perl5"
SUDO_FILE="/etc/sudoers.d/centreon"
FORCE_SUDO_CONF=1
INIT_D="/etc/init.d"
CRON_D="/etc/cron.d"
PEAR_PATH="/usr/share/php/"
PHP_FPM_SERVICE="php7.3-fpm"
PHP_FPM_RELOAD=1
DIR_PHP_FPM_CONF="/etc/php/7.3/fpm/pool.d/"
EOF
}

function centreon_maj () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                  Maj Centreon Web Interface
======================================================================
" | tee -a ${INSTALL_LOG}

cd ${DL_DIR}

if [[ -e centreon-web-${CENTREON_VER}.tar.gz ]]
  then
    echo 'File already exist!' | tee -a ${INSTALL_LOG}
  else
    wget ${CENTREON_URL} -O ${DL_DIR}/centreon-web-${CENTREON_VER}.tar.gz >> ${INSTALL_LOG}
    [ $? != 0 ] && return 1
fi

tar xzf centreon-web-${CENTREON_VER}.tar.gz
cd ${DL_DIR}/centreon-web-${CENTREON_VER}


# clean /tmp
rm -rf /tmp/*



if [ "$INSTALL_WEB" == "yes" ]
then
  [ "$SCRIPT_VERBOSE" = true ] && echo " Apply Centreon template " | tee -a ${INSTALL_LOG}

  #./install.sh -u /etc/centreon -f ${DL_DIR}/${CENTREON_TMPL} >> ${INSTALL_LOG}
fi 

}

function centreon_install () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                  Install Centreon Web Interface
======================================================================
" | tee -a ${INSTALL_LOG}


# modify snmp parameter for systemd
sed -i -e "s/-Lsd/-LS4d/g" /lib/systemd/system/snmpd.service
sed -i -e "s/-Lsd/-On -Lf \/var\/log\/snmptrapd.log/g" /lib/systemd/system/snmptrapd.service

# modify snmp parameter
sed -i -e "s/view   systemonly/#view   systemonly/g" /etc/snmp/snmpd.conf
sed -i -e "s/#rocommunity public  localhost/rocommunity public  localhost/g" /etc/snmp/snmpd.conf
sed -i -e "s/rocommunity public  default    -V systemonly/# rocommunity public  default    -V systemonly/g" /etc/snmp/snmpd.conf
sed -i -e "s/defaultMonitors/#defaultMonitors/g" /etc/snmp/snmpd.conf
sed -i -e "s/linkUpDownNotifications/#linkUpDownNotifications/g" /etc/snmp/snmpd.conf

sed -i -e "s/mibs/#mibs/g" /etc/snmp/snmp.conf;

systemctl daemon-reload >> ${INSTALL_LOG}
systemctl restart snmpd snmptrapd >> ${INSTALL_LOG}


cd ${DL_DIR}

if [[ -e centreon-web-${CENTREON_VER}.tar.gz ]]
  then
    echo 'File already exist!' git clone https://github.com/kermith72/auto_install.git| tee -a ${INSTALL_LOG}
  else
    wget ${CENTREON_URL} -O ${DL_DIR}/centreon-web-${CENTREON_VER}.tar.gz >> ${INSTALL_LOG}
    [ $? != 0 ] && return 1
fi

groupadd -g 6000 ${CENTREON_GROUP}
useradd -u 6000 -g ${CENTREON_GROUP} -m -r -d /var/lib/centreon -c "Centreon Web user" -s /bin/bash ${CENTREON_USER}
usermod -aG ${CENTREON_GROUP} ${ENGINE_USER}

tar xzf centreon-web-${CENTREON_VER}.tar.gz
cd ${DL_DIR}/centreon-web-${CENTREON_VER}


# clean /tmp
rm -rf /tmp/*

# maj pear
/usr/bin/pear install pear >> ${INSTALL_LOG}
/usr/bin/pear install date >> ${INSTALL_LOG}
/usr/bin/pear install db >> ${INSTALL_LOG}

# Install composer
[ "$SCRIPT_VERBOSE" = true ] && echo "====> Install Composer" | tee -a ${INSTALL_LOG}
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"  >> ${INSTALL_LOG}
php composer-setup.php --install-dir=/usr/bin --filename=composer  >> ${INSTALL_LOG}

#build php dependencies
composer install --no-dev --optimize-autoloader  >> ${INSTALL_LOG}

# add node-js
curl -sL https://deb.nodesource.com/setup_12.x | bash - >> ${INSTALL_LOG}
apt-get install -y nodejs >> ${INSTALL_LOG}

#modify file package.json
sed -i -e "s/19.10.0/19.10.1/g" package.json

#build javascript dependencies
npm install >> ${INSTALL_LOG}
npm run build >> ${INSTALL_LOG}


if [ "$INSTALL_WEB" == "yes" ]
then
  [ "$SCRIPT_VERBOSE" = true ] && echo " Apply Centreon template " | tee -a ${INSTALL_LOG}

  /bin/bash ${DL_DIR}/centreon-web-${CENTREON_VER}/install.sh -i -f ${DL_DIR}/${CENTREON_TMPL} >> ${INSTALL_LOG}
fi 
}

function post_install () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
=====================================================================
                          Post install
=====================================================================
" | tee -a ${INSTALL_LOG}

#bug fix 
sed -i -e 's/@PHP_BIN@/\/usr\/bin\/php/g' ${INSTALL_DIR}/centreon/bin/centreon
sed -i -e 's/@PHP_BIN@/\/usr\/bin\/php/g' ${INSTALL_DIR}/centreon/bin/export-mysql-indexes
sed -i -e 's/@PHP_BIN@/\/usr\/bin\/php/g' ${INSTALL_DIR}/centreon/bin/generateSqlLite
sed -i -e 's/@PHP_BIN@/\/usr\/bin\/php/g' ${INSTALL_DIR}/centreon/bin/import-mysql-indexes

#Modify default config
# Monitoring engine information
sed -i -e "s/share\/centreon-engine/sbin/g" ${INSTALL_DIR}/centreon/www/install/var/engines/centreon-engine;
sed -i -e "s/lib64/lib/g" ${INSTALL_DIR}/centreon/www/install/var/engines/centreon-engine;
# sed -i -e "s/CENTREONPLUGINS/CENTREON_PLUGINS/g" ${INSTALL_DIR}/centreon/www/install/var/engines/centreon-engine;
# Broker module information
sed -i -e "s/lib64\/nagios\/cbmod.so/lib\/centreon-broker\/cbmod.so/g" ${INSTALL_DIR}/centreon/www/install/var/brokers/centreon-broker;
# bug Centreon_plugin
# sed -i -e "s/CENTREONPLUGINS/CENTREON_PLUGINS/g" ${INSTALL_DIR}/centreon/www/install/steps/functions.php;
sed -i -e "s/centreon_plugins'] = \"\"/centreon_plugins'] = \"\/usr\/lib\/centreon\/plugins\"/g" ${INSTALL_DIR}/centreon/www/install/install.conf.php;

# bug goup centreon-engine 
/usr/sbin/usermod -aG ${ENGINE_GROUP} ${BROKER_USER}
/usr/sbin/usermod -aG ${ENGINE_GROUP} www-data
/usr/sbin/usermod -aG ${ENGINE_GROUP} ${CENTREON_USER}

#bug statistic centengine issue #8084
sed -i -e 's/"-s $self->{interval}"/"-s", $self->{interval}/g' /usr/share/perl5/centreon/script/nagiosPerfTrace.pm

cd ${DL_DIR}/centreon-web-${CENTREON_VER}
# Add API key for Centreon
# https://gist.github.com/earthgecko/3089509
# bash generate random 64 character alphanumeric string (upper and lowercase) and 
APIKEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
#modify file .env
sed -i -e "s/%APP_SECRET%/${APIKEY}/g" .env
#generate .env.local.php
composer dump-env prod

#Modify right cache
chown -R ${CENTREON_USER}:${CENTREON_GROUP} /var/cache/centreon
chmod -R 775 /var/cache/centreon

#copy files
cp .env ${INSTALL_DIR}/centreon
cp .env.local.php ${INSTALL_DIR}/centreon
cp container.php ${INSTALL_DIR}/centreon/
mv api ${INSTALL_DIR}/centreon/
cp config/bootstrap.php ${INSTALL_DIR}/centreon/config/
cp config/bundles.php ${INSTALL_DIR}/centreon/config/
cp config/services.yaml ${INSTALL_DIR}/centreon/config/
mv config/Modules ${INSTALL_DIR}/centreon/config/
mv config/packages ${INSTALL_DIR}/centreon/config/
mv config/routes ${INSTALL_DIR}/centreon/config/
chown -R root: ${INSTALL_DIR}/centreon/config/*

# Add mysql config for Centreon
cat >  /etc/mysql/conf.d/centreon.cnf << EOF
[mysqld]
innodb_file_per_table=1
open_files_limit=32000
sql_mode='ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'
EOF

# Modifiy config systemd
sed -i -e "s/LimitNOFILE=16364/LimitNOFILE=32000/g" /lib/systemd/system/mariadb.service;

systemctl daemon-reload >> ${INSTALL_LOG}
systemctl restart mysql >> ${INSTALL_LOG}

/usr/bin/mysql <<EOF
use mysql;
update user set plugin='' where user='root';
flush privileges;
EOF

# add Timezone
VARTIMEZONEP=`echo ${VARTIMEZONE} | sed 's:\/:\\\/:g' `
sed -i -e "s/;date.timezone =/date.timezone = ${VARTIMEZONEP}/g" /etc/php/7.3/fpm/php.ini


# reload conf apache
a2enconf centreon.conf >> ${INSTALL_LOG}
systemctl restart apache2 php7.3-fpm >> ${INSTALL_LOG}

## Workarounds
## config:  cannot open '/var/lib/centreon-broker/module-temporary.tmp-1-central-module-output-master-failover'
## (mode w+): Permission denied)
chmod 775 /var/lib/centreon/centplugins
chown ${CENTREON_USER}:${CENTREON_USER} /var/lib/centreon/centplugins

#add cgroup centreon
echo '[Unit]
Description=Cgroup Centreon

[Service]
Type=oneshot
ExecStart=/bin/true
ExecReload=/bin/true
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target' > /lib/systemd/system/centreon.service

systemctl daemon-reload
systemctl enable centreon

# Install pack icônes V2 Pixelabs
[ "$SCRIPT_VERBOSE" = true ] && echo "====> Install Pack Icônes V2 Pixelabs" | tee -a ${INSTALL_LOG}
tar xzf ${DIR_SCRIPT}/icones_pixelabs_v2.tar.gz -C ${DL_DIR}
cp -r ${DL_DIR}/icones_pixelabs_v2/* ${INSTALL_DIR}/centreon/www/img/media/
chown -R www-data:www-data ${INSTALL_DIR}/centreon/www/img/media/
}

##ADDONS

function widget_install() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
=======================================================================
                         Install WIDGETS
=======================================================================
" | tee -a ${INSTALL_LOG}
cd ${DL_DIR}
verify_version "$WIDGET_HOST_VER" "$WIDGET_HOST_VER_OLD"
if [[ $? -eq 1 ]]; then
  wget -qO- ${WIDGET_HOST} | tar -C ${INSTALL_DIR}/centreon/www/widgets --strip-components 1 -xzv >> ${INSTALL_LOG}
  maj_conf "WIDGET_HOST" "$WIDGET_HOST_VER_OLD" "$WIDGET_HOST_VER"
fi
verify_version "$WIDGET_HOSTGROUP_VER" "$WIDGET_HOSTGROUP_VER_OLD"
if [[ $? -eq 1 ]]; then
  wget -qO- ${WIDGET_HOSTGROUP} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv >> ${INSTALL_LOG}
  maj_conf "WIDGET_HOSTGROUP" "$WIDGET_HOSTGROUP_VER_OLD" "$WIDGET_HOSTGROUP_VER"
fi
verify_version "$WIDGET_SERVICE_VER" "$WIDGET_SERVICE_VER_OLD"
if [[ $? -eq 1 ]]; then
  wget -qO- ${WIDGET_SERVICE} | tar -C ${INSTALL_DIR}/centreon/www/widgets --strip-components 1 -xzv >> ${INSTALL_LOG}
  maj_conf "WIDGET_SERVICE" "$WIDGET_SERVICE_VER_OLD" "$WIDGET_SERVICE_VER"
fi
verify_version "$WIDGET_GRID_MAP_VER" "$WIDGET_GRID_MAP_VER_OLD"
if [[ $? -eq 1 ]]; then
  wget -qO- ${WIDGET_GRID_MAP} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv >> ${INSTALL_LOG}
  maj_conf "WIDGET_GRID_MAP" "$WIDGET_GRID_MAP_VER_OLD" "$WIDGET_GRID_MAP_VER"
fi
verify_version "$WIDGET_TOP_CPU_VER" "$WIDGET_TOP_CPU_VER_OLD"
if [[ $? -eq 1 ]]; then
  wget -qO- ${WIDGET_TOP_CPU} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv >> ${INSTALL_LOG}
  maj_conf "WIDGET_TOP_CPU" "$WIDGET_TOP_CPU_VER_OLD" "$WIDGET_TOP_CPU_VER"
fi
verify_version "$WIDGET_TOP_MEMORY_VER" "$WIDGET_TOP_MEMORY_VER_OLD"
if [[ $? -eq 1 ]]; then
  wget -qO- ${WIDGET_TOP_MEMORY} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv >> ${INSTALL_LOG}
  maj_conf "WIDGET_TOP_MEMORY" "$WIDGET_TOP_MEMORY_VER_OLD" "$WIDGET_TOP_MEMORY_VER"
fi
verify_version "$WIDGET_TACTICAL_OVERVIEW_VER" "$WIDGET_TACTICAL_OVERVIEW_VER_OLD"
if [[ $? -eq 1 ]]; then
  wget -qO- ${WIDGET_TACTICAL_OVERVIEW} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv >> ${INSTALL_LOG}
  maj_conf "WIDGET_TACTICAL_OVERVIEW" "$WIDGET_TACTICAL_OVERVIEW_VER_OLD" "$WIDGET_TACTICAL_OVERVIEW_VER"
fi
verify_version "$WIDGET_HTTP_LOADER_VER" "$WIDGET_HTTP_LOADER_VER_OLD"
if [[ $? -eq 1 ]]; then
  wget -qO- ${WIDGET_HTTP_LOADER} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv >> ${INSTALL_LOG}
  maj_conf "WIDGET_HTTP_LOADER" "$WIDGET_HTTP_LOADER_VER_OLD" "$WIDGET_HTTP_LOADER_VER"
fi
verify_version "$WIDGET_ENGINE_STATUS_VER" "$WIDGET_ENGINE_STATUS_VER_OLD"
if [[ $? -eq 1 ]]; then
  wget -qO- ${WIDGET_ENGINE_STATUS} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv >> ${INSTALL_LOG}
  maj_conf "WIDGET_ENGINE_STATUS" "$WIDGET_ENGINE_STATUS_VER_OLD" "$WIDGET_ENGINE_STATUS_VER"
fi
verify_version "$WIDGET_SERVICEGROUP_VER" "$WIDGET_SERVICEGROUP_VER_OLD"
if [[ $? -eq 1 ]]; then
  wget -qO- ${WIDGET_SERVICEGROUP} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv >> ${INSTALL_LOG}
  maj_conf "WIDGET_SERVICEGROUP" "$WIDGET_SERVICEGROUP_VER_OLD" "$WIDGET_SERVICEGROUP_VER"
fi
verify_version "$WIDGET_GRAPH_VER" "$WIDGET_GRAPH_VER_OLD"
if [[ $? -eq 1 ]]; then
  wget -qO- ${WIDGET_GRAPH} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv >> ${INSTALL_LOG}
  maj_conf "WIDGET_GRAPH" "$WIDGET_GRAPH_VER_OLD" "$WIDGET_GRAPH_VER"
fi
  chown -R ${CENTREON_USER}:${CENTREON_GROUP} ${INSTALL_DIR}/centreon/www/widgets
  
  #bug fix tactical-overview
  sed -i -e "s/\$res = \$db->query(\$queryPEND);/#\$res = \$db->query(\$queryPEND);/g" ${INSTALL_DIR}/centreon/www/widgets/tactical-overview/src/hosts_status.php
}

function add_check_nrpe() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
=======================================================================
                         Install check_nrpe3
=======================================================================
" | tee -a ${INSTALL_LOG}

apt-get install -y libssl-dev >> ${INSTALL_LOG}	
cd ${DL_DIR}
if [[ -e nrpe.tar.gz ]] ;
  then
    echo 'File already exist !' | tee -a ${INSTALL_LOG}
  else
    wget --no-check-certificate -O nrpe.tar.gz ${NRPE_URL} >> ${INSTALL_LOG}
    [ $? != 0 ] && return 1
fi

tar xzf nrpe.tar.gz
cd ${DL_DIR}/nrpe-nrpe-${NRPE_VERSION}

[ "$SCRIPT_VERBOSE" = true ] && echo "====> Compilation" | tee -a ${INSTALL_LOG}

./configure --with-nagios-user=${ENGINE_USER} --with-nrpe-user=${ENGINE_USER} --with-nagios-group=${ENGINE_USER} --with-nrpe-group=${ENGINE_USER} --libexecdir=/usr/lib/nagios/plugins  >> ${INSTALL_LOG}
make all  >> ${INSTALL_LOG}
make install-plugin  >> ${INSTALL_LOG}
}

function main () {
  if [ "$ADD_NRPE" == "yes" ]
  then
echo "
================| Centreon Central Install details $VERSION_BATCH |============
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
================| Centreon Central Install details $VERSION_BATCH |============
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

mariadb_install 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step1${normal}  => MariaDB Install                                       ${STATUS_FAIL}"
  else
    echo -e "${bold}Step1${normal}  => MariaDB Install                                       ${STATUS_OK}"
fi

verify_version "$CLIB_VER" "$CLIB_VER_OLD"
if [[ $? -eq 1 ]];
  then
    clib_install 2>>${INSTALL_LOG}
    if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step2${normal}  => Clib install                                          ${STATUS_FAIL}"
      else
        echo -e "${bold}Step2${normal}  => Clib install                                          ${STATUS_OK}"
        maj_conf "CLIB_VER" "$CLIB_VER_OLD" "$CLIB_VER"
    fi
  else
    echo -e "${bold}Step2${normal}  => Clib already installed                                ${STATUS_OK}"
fi


verify_version "$CONNECTOR_VER" "$CONNECTOR_VER_OLD"
if [[ $? -eq 1 ]];
  then
    centreon_connectors_install 2>>${INSTALL_LOG}
    if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step3${normal}  => Centreon Perl and SSH connectors install              ${STATUS_FAIL}"
      else
        echo -e "${bold}Step3${normal}  => Centreon Perl and SSH connectors install              ${STATUS_OK}"
        maj_conf "CONNECTOR_VER" "$CONNECTOR_VER_OLD" "$CONNECTOR_VER"
    fi
  else
    echo -e  "${bold}Step3${normal}  => Centreon Perl and SSH connectors already installed    ${STATUS_OK}"
fi

verify_version "$ENGINE_VER" "$ENGINE_VER_OLD"
if [[ $? -eq 1 ]];
  then
    if [ ! -z "$ENGINE_VER_OLD" ]; then
      /bin/systemctl stop centengine
    fi 
    centreon_engine_install 2>>${INSTALL_LOG}
    if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step4${normal}  => Centreon Engine install                               ${STATUS_FAIL}"
      else
        echo -e "${bold}Step4${normal}  => Centreon Engine install                               ${STATUS_OK}"
        maj_conf "ENGINE_VER" "$ENGINE_VER_OLD" "$ENGINE_VER"
    fi
  else
    echo -e     "${bold}Step4${normal}  => Centreon Engine already installed                     ${STATUS_OK}"
fi

verify_version "$PLUGIN_VER" "$PLUGIN_VER_OLD"
if [[ $? -eq 1 ]];
  then
    monitoring_plugin_install 2>>${INSTALL_LOG}
    if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step5${normal}  => Monitoring plugins install                            ${STATUS_FAIL}"
      else
        echo -e "${bold}Step5${normal}  => Monitoring plugins install                            ${STATUS_OK}"
        maj_conf "PLUGIN_VER" "$PLUGIN_VER_OLD" "$PLUGIN_VER"    
    fi
  else
    echo -e     "${bold}Step5${normal}  => Monitoring plugins already installed                  ${STATUS_OK}"
fi

verify_version "$PLUGIN_CENTREON_VER" "$PLUGIN_CENTREON_VER_OLD"
if [[ $? -eq 1 ]];
  then
    centreon_plugins_install 2>>${INSTALL_LOG}
    if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step6${normal}  => Centreon plugins install                              ${STATUS_FAIL}"
      else
        echo -e   "${bold}Step6${normal}  => Centreon plugins install                              ${STATUS_OK}"
        maj_conf "PLUGIN_CENTREON_VER" "$PLUGIN_CENTREON_VER_OLD" "$PLUGIN_CENTREON_VER"    
    fi
  else
    echo -e     "${bold}Step6${normal}  => Centreon plugins already installed                    ${STATUS_OK}"
fi


verify_version "$BROKER_VER" "$BROKER_VER_OLD"
if [[ $? -eq 1 ]];
  then
    if [ ! -z "$BROKER_VER_OLD" ]; then
      /bin/systemctl stop centengine
      /bin/systemctl stop cbd
    fi 
    centreon_broker_install 2>>${INSTALL_LOG}
    if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step7${normal}  => Centreon Broker install                               ${STATUS_FAIL}"
      else
        echo -e "${bold}Step7${normal}  => Centreon Broker install                               ${STATUS_OK}"
        maj_conf "BROKER_VER" "$BROKER_VER_OLD" "$BROKER_VER"    
    fi
  else
    echo -e     "${bold}Step7${normal}  => Centreon Broker already installed                     ${STATUS_OK}"
fi


verify_version "$CENTREON_VER" "$CENTREON_VER_OLD"
if [[ $? -eq 1 ]];
  then
    php_fpm_install 2>>${INSTALL_LOG}
    if [[ $? -ne 0 ]];
    then
      echo -e "${bold}Step8${normal}  => Php-fpm install                                       ${STATUS_FAIL}"
    else
      echo -e "${bold}Step8${normal}  => Php-fpm install                                       ${STATUS_OK}"
  fi
  else
    echo -e   "${bold}Step8${normal}  => Php-fpm already installed                             ${STATUS_OK}"
fi


verify_version "$CENTREON_VER" "$CENTREON_VER_OLD"
if [[ $? -eq 1 ]];
  then
    if [ -z "$CENTREON_VER_OLD" ]; 
    then
      create_centreon_tmpl 2>>${INSTALL_LOG}
      if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step9${normal}  => Centreon template generation                          ${STATUS_FAIL}"
      else
        echo -e "${bold}Step9${normal}  => Centreon template generation                          ${STATUS_OK}"
      fi
    else 
      create_centreon_tmpl 2>>${INSTALL_LOG}
      echo -e "${bold}Step9${normal}  => Centreon template generation                          ${STATUS_OK}"
    fi
  else
    echo -e   "${bold}Step9${normal}  => Centreon template already installed                   ${STATUS_OK}"
fi


verify_version "$CENTREON_VER" "$CENTREON_VER_OLD"
if [[ $? -eq 1 ]];
  then
    if [ -z "$CENTREON_VER_OLD" ]; 
    then
      centreon_install 2>>${INSTALL_LOG}
      if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step10${normal}  => Centreon web interface install                        ${STATUS_FAIL}"
      else
        echo -e "${bold}Step10${normal}  => Centreon web interface install                        ${STATUS_OK}"
        maj_conf "CENTREON_VER" "$CENTREON_VER_OLD" "$CENTREON_VER"    
      fi
    else 
      centreon_maj 2>>${INSTALL_LOG}
      if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step10${normal}  => Centreon web interface maj                            ${STATUS_FAIL}"
      else
        echo -e "${bold}Step10${normal}  => Centreon web interface maj                           ${STATUS_OK}"
        maj_conf "CENTREON_VER" "$CENTREON_VER_OLD" "$CENTREON_VER"    
      fi
    fi
  else
    echo -e   "${bold}Step10${normal}  => Centreon web already installed                   ${STATUS_OK}"
fi


if [ "$INSTALL_WEB" == "yes" ]
then
  if [ -z "$CENTREON_VER_OLD" ]; 
  then
    post_install 2>>${INSTALL_LOG}
    if [[ $? -ne 0 ]];
    then
      echo -e "${bold}Step11${normal} => Post install                                          ${STATUS_FAIL}"
    else
      echo -e "${bold}Step11${normal} => Post install                                          ${STATUS_OK}"
    fi
  fi
fi


if [ "$INSTALL_WEB" == "yes" ]
then
  widget_install 2>>${INSTALL_LOG}
  if [[ $? -ne 0 ]];
    then
      echo -e "${bold}Step12${normal} => Widgets install                                       ${STATUS_FAIL}"
    else
      echo -e "${bold}Step12${normal} => Widgets install                                       ${STATUS_OK}"
  fi
fi 

if [ "$ADD_NRPE" == "yes" ]
then
  add_check_nrpe 2>>${INSTALL_LOG}
  if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step13${normal} => Nrpe install                                          ${STATUS_FAIL}"
  else
    echo -e "${bold}Step13${normal} => Nrpe install                                          ${STATUS_OK}"
  fi

fi
echo ""
echo "##### Install completed #####" | tee -a ${INSTALL_LOG}
}

# verify version
# parameter $1:new version $2:old version
# return 0:egal 1:update/install 2:newer version installed 
function verify_version () {
   if [ -z "$2" ]; then
     return 1
   fi
   if [[ $1 == $2 ]]
   then
     return 0
   fi
       local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

# maj conf
# parameter $1: name variable $2: old value $3: new value
function maj_conf () {
	/bin/cat /etc/centreon/install_auto.conf | grep "^$1$"
	if [[ $? -ne 0 ]];
	then
	  echo "$1=$3" >> /etc/centreon/install_auto.conf
	else
	  sed -i "s/$1=$2/$1=$3/" /etc/centreon/install_auto.conf
	fi
}

function exist_conf () {
	if [ ! -f /etc/centreon/install_auto.conf ] ;
	then
	  if [ ! -d /etc/centreon ] ;
	  then
	    mkdir /etc/centreon
	  fi
	  touch /etc/centreon/install_auto.conf
	else
          IFS="="
	  while read -r var value
          do
            export "${var}_OLD"="$value"
          done < /etc/centreon/install_auto.conf
	fi 
	
}

#check menu
for i in "$@"
do
  case $i in
    -n=*|--nrpe=*)
      ADD_NRPE="${i#*=}"
      shift # past argument=value
      ;;
    -w=*|--web=*)
      INSTALL_WEB="${i#*=}"
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

# Check NRPE yes/no default no
if [[ $ADD_NRPE =~ ^[yY][eE][sS]|[yY]$ ]]; then
  ADD_NRPE="yes"
else
  ADD_NRPE="no"
fi

# Check Install Web yes/no default yes
if [[ $INSTALL_WEB =~ ^[nN][oO]$ ]]; then
  INSTALL_WEB="no"
else
  INSTALL_WEB="yes"
fi

# Exec main function
exist_conf
main
echo -e ""
echo -e "${bold}Go to http://${ETH0_IP}/centreon to complete the setup${normal} "
echo -e ""
