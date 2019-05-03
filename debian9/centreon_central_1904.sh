#!/bin/bash
# Centreon 19.04 + engine install script for Debian Stretch
# v 1.29
# 03/05/2019
# Thanks to Remy
#
export DEBIAN_FRONTEND=noninteractive
# Variables
## Versions
VERSION_BATCH="v 1.29"
CLIB_VER="19.04.0"
CONNECTOR_VER="19.04.0"
ENGINE_VER="19.04.0"
PLUGIN_VER="2.2"
BROKER_VER="19.04.0"
CENTREON_VER="19.04.0"
# MariaDB Series
MARIADB_VER='10.0'
## Sources URL
BASE_URL="https://s3-eu-west-1.amazonaws.com/centreon-download/public"
CLIB_URL="${BASE_URL}/centreon-clib/centreon-clib-${CLIB_VER}.tar.gz"
CONNECTOR_URL="${BASE_URL}/centreon-connectors/centreon-connector-${CONNECTOR_VER}.tar.gz"
ENGINE_URL="${BASE_URL}/centreon-engine/centreon-engine-${ENGINE_VER}.tar.gz"
PLUGIN_URL="https://www.monitoring-plugins.org/download/monitoring-plugins-${PLUGIN_VER}.tar.gz"
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
WIDGET_BASE="https://s3-eu-west-1.amazonaws.com/centreon-download/public/centreon-widgets"
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

function nonfree_install () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
           Add Stretch repo for non-free
======================================================================
" | tee -a ${INSTALL_LOG}

echo 'deb http://ftp.fr.debian.org/debian/ stretch non-free' > /etc/apt/sources.list.d/stretch-nonfree.list

apt-get update  >> ${INSTALL_LOG}
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
cd centreon-clib-${CLIB_VER}/build

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
apt-get install -y libssh2-1-dev libgcrypt11-dev >> ${INSTALL_LOG}

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
cd ${DL_DIR}/centreon-engine-${ENGINE_VER}/build

[ "$SCRIPT_VERBOSE" = true ] && echo "====> Compilation" | tee -a ${INSTALL_LOG}

# add directive compilation
sed -i '32i\set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++98 -fpermissive")' ${DL_DIR}/centreon-engine-${ENGINE_VER}/build/CMakeLists.txt

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

apt-get install --force-yes -y libgnutls28-dev libssl-dev libkrb5-dev libldap2-dev libsnmp-dev gawk \
        libwrap0-dev libmcrypt-dev smbclient fping gettext dnsutils libmodule-build-perl libmodule-install-perl \
        libnet-snmp-perl >> ${INSTALL_LOG}

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
git clone https://github.com/centreon/centreon-plugins.git >> ${INSTALL_LOG}
cd centreon-plugins
chmod +x centreon_plugins.pl
# retrieve last tag
latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
sed -i -e "s/(dev)/$latestTag/g" ${DL_DIR}/centreon-plugins/centreon/plugins/script.pm
chown -R ${ENGINE_USER}:${ENGINE_GROUP} ${DL_DIR}/centreon-plugins
mkdir -p /usr/lib/centreon/plugins
cp -Rp * /usr/lib/centreon/plugins/
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

apt-get install -y libqt4-dev libqt4-sql-mysql libgnutls28-dev lsb-release liblua5.2-dev lsb-release >> ${INSTALL_LOG}

[ "$SCRIPT_VERBOSE" = true ] && echo "
==================   Install rrdtools 1.4.7     =====================
" | tee -a ${INSTALL_LOG}

# package for rrdtools
apt-get install -y libpango1.0-dev libxml2-dev >> ${INSTALL_LOG}

# compile rrdtools
cd ${DL_DIR}
wget http://oss.oetiker.ch/rrdtool/pub/rrdtool-1.4.7.tar.gz >> ${INSTALL_LOG}
[ $? != 0 ] && return 1
tar xzf rrdtool-1.4.7.tar.gz
cd ${DL_DIR}/rrdtool-1.4.7

[ "$SCRIPT_VERBOSE" = true ] && echo "====> Compilation rrdtool" | tee -a ${INSTALL_LOG}

./configure --prefix=/opt/rddtool-broker >> ${INSTALL_LOG}
make >> ${INSTALL_LOG}
make install >> ${INSTALL_LOG}

cp /opt/rddtool-broker/lib/pkgconfig/librrd.pc /usr/lib/pkgconfig/

#create ldconfig file
cat >  /etc/ld.so.conf.d/rrdtool-broker.conf << EOF
# lib rrdtools for Centreon
/opt/rddtool-broker/lib
EOF

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
cd ${DL_DIR}/centreon-broker-${BROKER_VER}/build/

[ "$SCRIPT_VERBOSE" = true ] && echo "====> Compilation broker" | tee -a ${INSTALL_LOG}

# add directive compilation
sed -i '32i\set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++98 -fpermissive")' ${DL_DIR}/centreon-broker-${BROKER_VER}/build/CMakeLists.txt

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
apt-get install apt-transport-https lsb-release ca-certificates -y >> ${INSTALL_LOG}

wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg >> ${INSTALL_LOG}
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" >> /etc/apt/sources.list.d/php.list
apt-get update >> ${INSTALL_LOG}

apt-get install php7.1 php7.1-opcache libapache2-mod-php7.1 php7.1-mysql \
	php7.1-curl php7.1-json php7.1-gd php7.1-mcrypt php7.1-intl php7.1-mbstring \
	php7.1-xml php7.1-zip php7.1-fpm php7.1-readline -y >> ${INSTALL_LOG}
	

DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes php7.1-sqlite3 \
	php-pear sudo tofrodos bsd-mailx lsb-release mariadb-server \
	libconfig-inifiles-perl libcrypt-des-perl php-db php-date \
	libdigest-hmac-perl libdigest-sha-perl libgd-perl php7.1-ldap php7.1-snmp \
	snmp snmpd snmptrapd libnet-snmp-perl libsnmp-perl snmp-mibs-downloader ntp >> ${INSTALL_LOG}


# Cleanup to prevent space full on /var
apt-get clean >> ${INSTALL_LOG}

a2enmod proxy_fcgi setenvif proxy rewrite >> ${INSTALL_LOG}
a2enconf php7.1-fpm >> ${INSTALL_LOG}
a2dismod php7.1 >> ${INSTALL_LOG}
systemctl restart apache2 php7.1-fpm >> ${INSTALL_LOG}


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
PHP_FPM_SERVICE="php7.1-fpm"
PHP_FPM_RELOAD=1
EOF
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

# make lib perl rrd
cd ${DL_DIR}/rrdtool-1.4.7/bindings/perl-shared
perl Makefile.PL >> ${INSTALL_LOG}
make test >> ${INSTALL_LOG}
make install >> ${INSTALL_LOG}

cd ${DL_DIR}

if [[ -e centreon-web-${CENTREON_VER}.tar.gz ]]
  then
    echo 'File already exist!' | tee -a ${INSTALL_LOG}
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

# add DEFAULT_PHP_FPM_SERVICE
#sed -i '$aDEFAULT_PHP_FPM_SERVICE="fpm-php"' ${DL_DIR}/centreon-web-${CENTREON_VER}/varinstall/vars

[ "$SCRIPT_VERBOSE" = true ] && echo " Apply Centreon template " | tee -a ${INSTALL_LOG}

./install.sh -i -f ${DL_DIR}/${CENTREON_TMPL} >> ${INSTALL_LOG} 
}

function post_install () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
=====================================================================
                          Post install
=====================================================================
" | tee -a ${INSTALL_LOG}

# Install composer
[ "$SCRIPT_VERBOSE" = true ] && echo "====> Install Composer" | tee -a ${INSTALL_LOG}
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"  >> ${INSTALL_LOG}
php composer-setup.php --install-dir=/usr/bin --filename=composer  >> ${INSTALL_LOG}
cd ${INSTALL_DIR}/centreon 
composer install --no-dev --optimize-autoloader  >> ${INSTALL_LOG}




#bug fix 
sed -i -e 's/_CENTREON_PATH_PLACEHOLDER_/centreon/g' ${INSTALL_DIR}/centreon/www/index.html
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

# Add mysql config for Centreon
echo '[mysqld]
innodb_file_per_table=1
open_files_limit=32000' > /etc/mysql/conf.d/centreon.cnf

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
sed -i -e "s/;date.timezone =/date.timezone = ${VARTIMEZONEP}/g" /etc/php/7.1/fpm/php.ini


# add node-js
apt-get install curl  >> ${INSTALL_LOG}
curl -sL https://deb.nodesource.com/setup_8.x | bash - >> ${INSTALL_LOG}
apt-get install -y nodejs >> ${INSTALL_LOG}
cp ${DL_DIR}/centreon-web-${CENTREON_VER}/webpack.config.js ${INSTALL_DIR}/centreon
cp ${DL_DIR}/centreon-web-${CENTREON_VER}/.babelrc ${INSTALL_DIR}/centreon
sed -i -e 's/apache/www-data/g' ${INSTALL_DIR}/centreon/package.json

#build javascript dependencies
cd ${INSTALL_DIR}/centreon
npm install >> ${INSTALL_LOG}
npm run build >> ${INSTALL_LOG}
npm prune --production >> ${INSTALL_LOG}


#apply owner
#chown -R www-data: ${INSTALL_DIR}/centreon/www


# reload conf apache
a2enconf centreon.conf >> ${INSTALL_LOG}
systemctl restart apache2 php7.1-fpm >> ${INSTALL_LOG}

## Workarounds
## config:  cannot open '/var/lib/centreon-broker/module-temporary.tmp-1-central-module-output-master-failover'
## (mode w+): Permission denied)
chmod 775 /var/lib/centreon/centplugins
chown ${CENTREON_USER}:${CENTREON_USER} /var/lib/centreon/centplugins


}

##ADDONS

function widget_install() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
=======================================================================
                         Install WIDGETS
=======================================================================
" | tee -a ${INSTALL_LOG}
cd ${DL_DIR}
  wget -qO- ${WIDGET_HOST} | tar -C ${INSTALL_DIR}/centreon/www/widgets --strip-components 1 -xzv >> ${INSTALL_LOG}
  wget -qO- ${WIDGET_HOSTGROUP} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv >> ${INSTALL_LOG}
  wget -qO- ${WIDGET_SERVICE} | tar -C ${INSTALL_DIR}/centreon/www/widgets --strip-components 1 -xzv >> ${INSTALL_LOG}
  wget -qO- ${WIDGET_GRID_MAP} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv >> ${INSTALL_LOG}
  #wget -qO- ${WIDGET_TOP_CPU} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv
  #wget -qO- ${WIDGET_TOP_MEMORY} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv
  /usr/bin/git clone ${WIDGET_TOP_CPU} >> ${INSTALL_LOG}
  mv centreon-widget-live-top10-cpu-usage/live-top10-cpu-usage ${INSTALL_DIR}/centreon/www/widgets/
  /usr/bin/git clone ${WIDGET_TOP_MEMORY} >> ${INSTALL_LOG}
  mv centreon-widget-live-top10-memory-usage/live-top10-memory-usage ${INSTALL_DIR}/centreon/www/widgets/
  wget -qO- ${WIDGET_TACTICAL_OVERVIEW} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv >> ${INSTALL_LOG}
  wget -qO- ${WIDGET_HTTP_LOADER} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv >> ${INSTALL_LOG}
  wget -qO- ${WIDGET_ENGINE_STATUS} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv >> ${INSTALL_LOG}
  wget -qO- ${WIDGET_SERVICEGROUP} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv >> ${INSTALL_LOG}
  wget -qO- ${WIDGET_GRAPH} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv >> ${INSTALL_LOG}
  chown -R ${CENTREON_USER}:${CENTREON_GROUP} ${INSTALL_DIR}/centreon/www/widgets
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
                  Plugin     : ${PLUGIN_VER}
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
                  Plugin     : ${PLUGIN_VER}
                  Broker     : ${BROKER_VER}
                  Centreon   : ${CENTREON_VER}
                  Install dir: ${INSTALL_DIR}
                  Source dir : ${DL_DIR}
======================================================================
"
  fi
text_params

nonfree_install 2>> ${INSTALL_LOG} 
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step1${normal}  => repo non-free on Stretch Install                      ${STATUS_FAIL}"
  else
    echo -e "${bold}Step1${normal}  => repo non-free on Stretch Install                      ${STATUS_OK}"
fi

mariadb_install 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step2${normal}  => MariaDB Install                                       ${STATUS_FAIL}"
  else
    echo -e "${bold}Step2${normal}  => MariaDB Install                                       ${STATUS_OK}"
fi

clib_install 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step3${normal}  => Clib install                                          ${STATUS_FAIL}"
  else
    echo -e "${bold}Step3${normal}  => Clib install                                          ${STATUS_OK}"
fi

centreon_connectors_install 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step4${normal}  => Centreon Perl and SSH connectors install              ${STATUS_FAIL}"
  else
    echo -e "${bold}Step4${normal}  => Centreon Perl and SSH connectors install              ${STATUS_OK}"
fi

centreon_engine_install 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step5${normal}  => Centreon Engine install                               ${STATUS_FAIL}"
  else
    echo -e "${bold}Step5${normal}  => Centreon Engine install                               ${STATUS_OK}"
fi

monitoring_plugin_install 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step6${normal}  => Monitoring plugins install                            ${STATUS_FAIL}"
  else
    echo -e "${bold}Step6${normal}  => Monitoring plugins install                            ${STATUS_OK}"
fi

centreon_plugins_install 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step7${normal}  => Centreon plugins install                              ${STATUS_FAIL}"
  else
    echo -e "${bold}Step7${normal}  => Centreon plugins install                              ${STATUS_OK}"
fi

centreon_broker_install 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step8${normal}  => Centreon Broker install                               ${STATUS_FAIL}"
  else
    echo -e "${bold}Step8${normal}  => Centreon Broker install                               ${STATUS_OK}"
fi

php_fpm_install 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step9${normal}  => Php-fpm install                                       ${STATUS_FAIL}"
  else
    echo -e "${bold}Step9${normal}  => Php-fpm install                                       ${STATUS_OK}"
fi


create_centreon_tmpl 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step10${normal}  => Centreon template generation                          ${STATUS_FAIL}"
  else
    echo -e "${bold}Step10${normal}  => Centreon template generation                          ${STATUS_OK}"
fi

centreon_install 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step11${normal}  => Centreon web interface install                        ${STATUS_FAIL}"
  else
    echo -e "${bold}Step11${normal}  => Centreon web interface install                        ${STATUS_OK}"
fi

post_install 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step12${normal} => Post install                                          ${STATUS_FAIL}"
  else
    echo -e "${bold}Step12${normal} => Post install                                          ${STATUS_OK}"
fi

widget_install 2>>${INSTALL_LOG}
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step13${normal} => Widgets install                                       ${STATUS_FAIL}"
  else
    echo -e "${bold}Step13${normal} => Widgets install                                       ${STATUS_OK}"
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
