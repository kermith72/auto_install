#!/bin/bash
# Centreon + engine install script for Debian Stretch
# v 1.24
# 15/03/2019
# Thanks to Remy
#
export DEBIAN_FRONTEND=noninteractive
# Variables
## Versions
VERSION_BATCH="v 1.24"
CLIB_VER="18.10.0"
CONNECTOR_VER="18.10.0"
ENGINE_VER="18.10.0"
PLUGIN_VER="2.2"
BROKER_VER="18.10.1"
CENTREON_VER="18.10.3"
# MariaDB Series
MARIADB_VER='10.0'
## Sources URL
BASE_URL="https://s3-eu-west-1.amazonaws.com/centreon-download/public"
CLIB_URL="${BASE_URL}/centreon-clib/centreon-clib-${CLIB_VER}.tar.gz"
CONNECTOR_URL="${BASE_URL}/centreon-connectors/centreon-connectors-${CONNECTOR_VER}.tar.gz"
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
WIDGET_TOP_CPU_VER="1.1.1"
WIDGET_TOP_MEMORY_VER="1.1.1"
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
WIDGET_TOP_CPU="${WIDGET_BASE}/centreon-widget-live-top10-cpu/centreon-widget-live-top10-cpu-usage-${WIDGET_TOP_CPU_VER}.tar.gz"
WIDGET_TOP_MEMORY="${WIDGET_BASE}/centreon-widget-live-top10-memory/centreon-widget-live-top10-memory-usage-${WIDGET_TOP_MEMORY_VER}.tar.gz"
WIDGET_TACTICAL_OVERVIEW="${WIDGET_BASE}/centreon-widget-tactical-overview/centreon-widget-tactical-overview-${WIDGET_TACTICAL_OVERVIEW_VER}.tar.gz"
WIDGET_HTTP_LOADER="${WIDGET_BASE}/centreon-widget-httploader/centreon-widget-httploader-${WIDGET_HTTP_LOADER_VER}.tar.gz"
WIDGET_ENGINE_STATUS="${WIDGET_BASE}/centreon-widget-engine-status/centreon-widget-engine-status-${WIDGET_ENGINE_STATUS_VER}.tar.gz"
WIDGET_GRAPH="${WIDGET_BASE}/centreon-widget-graph-monitoring/centreon-widget-graph-monitoring-${WIDGET_GRAPH_VER}.tar.gz"
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
echo "
======================================================================
           Add Jessie repo for non-free
======================================================================
"

echo 'deb http://ftp.fr.debian.org/debian/ stretch non-free' > /etc/apt/sources.list.d/jessie-nonfree.list

apt-get update
}


function mariadb_install() {
echo "
======================================================================
                        Install MariaDB
======================================================================
"

apt-get install -y mariadb-server
}

function clib_install () {
echo "
======================================================================
                          Install Clib
======================================================================
"

apt-get install -y build-essential cmake

cd ${DL_DIR}
if [[ -e centreon-clib-${CLIB_VER}.tar.gz ]] ;
  then
    echo 'File already exist !'
  else
    wget ${CLIB_URL} -O ${DL_DIR}/centreon-clib-${CLIB_VER}.tar.gz
fi

tar xzf centreon-clib-${CLIB_VER}.tar.gz
cd centreon-clib-${CLIB_VER}/build

# add directive compilation
sed -i '32i\set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++98 -fpermissive")' ${DL_DIR}/centreon-clib-${CLIB_VER}/build/CMakeLists.txt

cmake \
   -DWITH_TESTING=0 \
   -DWITH_PREFIX=/usr \
   -DWITH_SHARED_LIB=1 \
   -DWITH_STATIC_LIB=0 \
   -DWITH_PKGCONFIG_DIR=/usr/lib/pkgconfig .
make
make install

}

function centreon_connectors_install () {
echo "
======================================================================
               Install Centreon Perl and SSH connectors
======================================================================
"
apt-get install -y libperl-dev

cd ${DL_DIR}
if [[ -e centreon-connectors-${CONNECTOR_VER}.tar.gz ]]
  then
    echo 'File already exist !'
  else
    wget ${CONNECTOR_URL} -O ${DL_DIR}/centreon-connectors-${CONNECTOR_VER}.tar.gz
fi

tar xzf centreon-connectors-${CONNECTOR_VER}.tar.gz
cd ${DL_DIR}/centreon-connector-${CONNECTOR_VER}/perl/build

# add directive compilation
sed -i '27i\set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++98 -fpermissive")' ${DL_DIR}/centreon-connector-${CONNECTOR_VER}/perl/build/CMakeLists.txt

cmake \
 -DWITH_PREFIX=/usr  \
 -DWITH_PREFIX_BINARY=/usr/lib/centreon-connector  \
 -DWITH_CENTREON_CLIB_INCLUDE_DIR=/usr/include \
 -DWITH_TESTING=0 .
make
make install

# install Centreon SSH Connector
apt-get install -y libssh2-1-dev libgcrypt11-dev

# Cleanup to prevent space full on /var
apt-get clean

cd ${DL_DIR}/centreon-connector-${CONNECTOR_VER}/ssh/build

# add directive compilation
sed -i '27i\set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++98 -fpermissive")' ${DL_DIR}/centreon-connector-${CONNECTOR_VER}/ssh/build/CMakeLists.txt


cmake \
 -DWITH_PREFIX=/usr  \
 -DWITH_PREFIX_BINARY=/usr/lib/centreon-connector  \
 -DWITH_CENTREON_CLIB_INCLUDE_DIR=/usr/include \
 -DWITH_TESTING=0 .
make
make install
}

function centreon_engine_install () {
echo "
======================================================================
                    Install Centreon Engine
======================================================================
"

groupadd -g 6001 ${ENGINE_GROUP}
useradd -u 6001 -g ${ENGINE_GROUP} -m -r -d /var/lib/centreon-engine -c "Centreon-engine Admin" -s /bin/bash ${ENGINE_USER}

apt-get install -y libcgsi-gsoap-dev zlib1g-dev libssl-dev libxerces-c-dev

# Cleanup to prevent space full on /var
apt-get clean

cd ${DL_DIR}
if [[ -e centreon-engine-${ENGINE_VER}.tar.gz ]]
  then
    echo 'File already exist !'
  else
    wget ${ENGINE_URL} -O ${DL_DIR}/centreon-engine-${ENGINE_VER}.tar.gz
fi

tar xzf centreon-engine-${ENGINE_VER}.tar.gz
cd ${DL_DIR}/centreon-engine-${ENGINE_VER}/build

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
   -DWITH_TESTING=0 .
make
make install

systemctl enable centengine.service
systemctl daemon-reload
}

function monitoring_plugin_install () {
echo "
======================================================================
                     Install Monitoring Plugins
======================================================================
"

apt-get install --force-yes -y libgnutls28-dev libssl-dev libkrb5-dev libldap2-dev libsnmp-dev gawk \
        libwrap0-dev libmcrypt-dev smbclient fping gettext dnsutils libmodule-build-perl libmodule-install-perl \
        libnet-snmp-perl

# Cleanup to prevent space full on /var
apt-get clean

cd ${DL_DIR}
if [[ -e monitoring-plugins-${PLUGIN_VER}.tar.gz ]]
  then
    echo 'File already exist !'
  else
    wget --no-check-certificate ${PLUGIN_URL} -O ${DL_DIR}/monitoring-plugins-${PLUGIN_VER}.tar.gz
fi

tar xzf monitoring-plugins-${PLUGIN_VER}.tar.gz
cd ${DL_DIR}/monitoring-plugins-${PLUGIN_VER}

./configure --with-nagios-user=${ENGINE_USER} --with-nagios-group=${ENGINE_GROUP} \
--prefix=/usr/lib/nagios/plugins --libexecdir=/usr/lib/nagios/plugins --enable-perl-modules --with-openssl=/usr/bin/openssl \
--enable-extra-opts

make
make install
}


function centreon_plugins_install() {
echo "
=======================================================================
                    Install Centreon Plugins
=======================================================================
"
cd ${DL_DIR}
DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes libxml-libxml-perl libjson-perl libwww-perl libxml-xpath-perl \
            libxml-simple-perl libdatetime-perl libdate-manip-perl \
            libnet-telnet-perl libnet-ntp-perl libnet-dns-perl libdbi-perl libdbd-mysql-perl libdbd-pg-perl git-core
git clone https://github.com/centreon/centreon-plugins.git
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
echo "
======================================================================
                     Install Centreon Broker
======================================================================
"

groupadd -g 6002 ${BROKER_GROUP}
useradd -u 6002 -g ${BROKER_GROUP} -m -r -d /var/lib/centreon-broker -c "Centreon-broker Admin" -s /bin/bash  ${BROKER_USER}
usermod -aG ${BROKER_GROUP} ${ENGINE_USER}

apt-get install -y libqt4-dev libqt4-sql-mysql libgnutls28-dev lsb-release liblua5.2-dev lsb-release

# package for rrdtools
apt-get install -y libpango1.0-dev libxml2-dev

# compile rrdtools
cd ${DL_DIR}
wget http://oss.oetiker.ch/rrdtool/pub/rrdtool-1.4.7.tar.gz
tar xzf rrdtool-1.4.7.tar.gz
cd ${DL_DIR}/rrdtool-1.4.7
./configure --prefix=/opt/rddtool-broker
make
make install

cp /opt/rddtool-broker/lib/pkgconfig/librrd.pc /usr/lib/pkgconfig/

#create ldconfig file
cat >  /etc/ld.so.conf.d/rrdtool-broker.conf << EOF
# lib rrdtools for Centreon
/opt/rddtool-broker/lib
EOF

# Cleanup to prevent space full on /var
apt-get clean

cd ${DL_DIR}
if [[ -e centreon-broker-${BROKER_VER}.tar.gz ]]
  then
    echo 'File already exist !'
  else
    wget ${BROKER_URL} -O ${DL_DIR}/centreon-broker-${BROKER_VER}.tar.gz
fi

tar xzf centreon-broker-${BROKER_VER}.tar.gz
cd ${DL_DIR}/centreon-broker-${BROKER_VER}/build/

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
    -DWITH_USER=${BROKER_USER} .
make
make install
systemctl enable cbd.service
systemctl daemon-reload

if [[ -d /var/log/centreon-broker ]]
  then
    echo "Directory already exist!"
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
apt-get clean
}

function php_fpm_install() {
echo "
======================================================================
                     Install Php-fpm
======================================================================
"
apt-get install apt-transport-https lsb-release ca-certificates -y

wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" >> /etc/apt/sources.list.d/php.list
apt-get update

apt-get install php7.1 php7.1-opcache libapache2-mod-php7.1 php7.1-mysql \
	php7.1-curl php7.1-json php7.1-gd php7.1-mcrypt php7.1-intl php7.1-mbstring \
	php7.1-xml php7.1-zip php7.1-fpm php7.1-readline -y
	

DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes php7.1-sqlite3 \
	php-pear sudo tofrodos bsd-mailx lsb-release mariadb-server \
	libconfig-inifiles-perl libcrypt-des-perl php-db php-date \
	libdigest-hmac-perl libdigest-sha-perl libgd-perl php7.1-ldap php7.1-snmp \
	snmp snmpd snmptrapd libnet-snmp-perl libsnmp-perl snmp-mibs-downloader


# Cleanup to prevent space full on /var
apt-get clean

a2enmod proxy_fcgi setenvif proxy rewrite
a2enconf php7.1-fpm
a2dismod php7.1
systemctl restart apache2 php7.1-fpm

#install composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --install-dir=/usr/bin --filename=composer


}

function create_centreon_tmpl() {
echo "
======================================================================
                  Centreon template generation
======================================================================
"
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
NAGIOS_GROUP="${CENTREON_USER}"
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
echo "
======================================================================
                  Install Centreon Web Interface
======================================================================
"


echo "# This file controls the activity of snmpd

# Don\'t load any MIBs by default.
# You might comment this lines once you have the MIBs downloaded.
export MIBDIRS=/usr/share/mibs
export MIBS=ALL

# snmpd control (yes means start daemon).
SNMPDRUN=yes

# snmpd options (use syslog, close stdin/out/err).
SNMPDOPTS='-LS4d -Lf /dev/null -u snmp -g snmp -I -smux,mteTrigger,mteTriggerConf -p /run/snmpd.pid'" > /etc/default/snmpd

echo "# This file controls the activity of snmptrapd

# snmptrapd control (yes means start daemon).  As of net-snmp version
# 5.0, master agentx support must be enabled in snmpd before snmptrapd
# can be run.  See snmpd.conf(5) for how to do this.
TRAPDRUN=yes

# snmptrapd options (use syslog).
TRAPDOPTS='-On -Lsd -p /run/snmptrapd.pid'" > /etc/default/snmptrapd

sed -i -e "s/view   systemonly/#view   systemonly/g" /etc/snmp/snmpd.conf;
sed -i -e "s/#rocommunity public  localhost/rocommunity public  localhost/g" /etc/snmp/snmpd.conf;
sed -i -e "s/rocommunity public  default    -V systemonly/# rocommunity public  default    -V systemonly/g" /etc/snmp/snmpd.conf;
sed -i -e "s/defaultMonitors/#defaultMonitors/g" /etc/snmp/snmpd.conf;
sed -i -e "s/linkUpDownNotifications/#linkUpDownNotifications/g" /etc/snmp/snmpd.conf;

sed -i -e "s/mibs/#mibs/g" /etc/snmp/snmp.conf;

systemctl restart snmpd snmptrapd restart

# make lib perl rrd
cd ${DL_DIR}/rrdtool-1.4.7/bindings/perl-shared
perl Makefile.PL
make test
make install

cd ${DL_DIR}

if [[ -e centreon-web-${CENTREON_VER}.tar.gz ]]
  then
    echo 'File already exist!'
  else
    wget ${CENTREON_URL} -O ${DL_DIR}/centreon-web-${CENTREON_VER}.tar.gz
fi

groupadd -g 6000 ${CENTREON_GROUP}
useradd -u 6000 -g ${CENTREON_GROUP} -m -r -d /var/lib/centreon -c "Centreon Web user" -s /bin/bash ${CENTREON_USER}
usermod -aG ${CENTREON_GROUP} ${ENGINE_USER}

tar xzf centreon-web-${CENTREON_VER}.tar.gz
cd ${DL_DIR}/centreon-web-${CENTREON_VER}


# clean /tmp
rm -rf /tmp/*

# add DEFAULT_PHP_FPM_SERVICE
sed -i '$aDEFAULT_PHP_FPM_SERVICE="fpm-php"' ${DL_DIR}/centreon-web-${CENTREON_VER}/varinstall/vars

# remplace script functions

rm ${DL_DIR}/centreon-web-${CENTREON_VER}/libinstall/functions
rm ${DL_DIR}/centreon-web-${CENTREON_VER}/libinstall/CentWeb.sh
rm ${DL_DIR}/centreon-web-${CENTREON_VER}/libinstall/CentPluginsTraps.sh
cp ${DIR_SCRIPT}/libinstall/functions ${DL_DIR}/centreon-web-${CENTREON_VER}/libinstall/functions
cp ${DIR_SCRIPT}/libinstall/CentWeb.sh ${DL_DIR}/centreon-web-${CENTREON_VER}/libinstall/CentWeb.sh
cp ${DIR_SCRIPT}/libinstall/CentPluginsTraps.sh ${DL_DIR}/centreon-web-${CENTREON_VER}/libinstall/CentPluginsTraps.sh
chmod +x ${DL_DIR}/centreon-web-${CENTREON_VER}/libinstall/functions
chmod +x ${DL_DIR}/centreon-web-${CENTREON_VER}/libinstall/CentWeb.sh
chmod +x ${DL_DIR}/centreon-web-${CENTREON_VER}/libinstall/CentPluginsTraps.sh

echo " Generate Centreon template "

 ./install.sh -i -f ${DL_DIR}/${CENTREON_TMPL}
}

function post_install () {
echo "
=====================================================================
                          Post install
=====================================================================
"

#add directory vendor
mkdir /usr/share/centreon/vendor
cp -r ${DL_DIR}/centreon-web-${CENTREON_VER}/vendor/* ${INSTALL_DIR}/centreon/vendor/

#bug fix 
sed -i -e 's/@CENTREON_ETC@/\/etc\/centreon/g' ${INSTALL_DIR}/centreon/config/centreon.config.php
sed -i -e 's/@CENTREON_LOG@/\/var\/log\/centreon/g' ${INSTALL_DIR}/centreon/config/centreon.config.php
sed -i -e 's/@CENTREON_VARLIB@/\/var\/lib\/centreon/g' ${INSTALL_DIR}/centreon/config/centreon.config.php

sed -i -e 's/@PHP_BIN@/\/usr\/bin\/php/g' ${INSTALL_DIR}/centreon/bin/centreon

sed -i -e 's/@PHP_BIN@/\/usr\/bin\/php/g' ${INSTALL_DIR}/centreon/cron/centreon-backup.pl

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

# Add mysql config for Centreon
echo '[mysqld]
innodb_file_per_table=1' > /etc/mysql/conf.d/centreon.cnf

# Modifiy config systemd
sed -i -e "s/LimitNOFILE=16364/LimitNOFILE=32000/g" /lib/systemd/system/mariadb.service;

systemctl daemon-reload
systemctl restart mysql

/usr/bin/mysql <<EOF
use mysql;
update user set plugin='' where user='root';
flush privileges;
EOF

# add Timezone
VARTIMEZONEP=`echo ${VARTIMEZONE} | sed 's:\/:\\\/:g' `
sed -i -e "s/;date.timezone =/date.timezone = ${VARTIMEZONEP}/g" /etc/php/7.1/fpm/php.ini

# modify listen fpm
sed -i -e 's/listen = \/run\/php\/php7.1-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php/7.1/fpm/pool.d/www.conf

# add node-js
apt-get install curl
curl -sL https://deb.nodesource.com/setup_8.x | bash -
apt-get install -y nodejs

#copy json file
cp ${DL_DIR}/centreon-web-${CENTREON_VER}/package* ${INSTALL_DIR}/centreon/

#build javascript dependencies
cd ${INSTALL_DIR}/centreon
npm install
npm run build
npm prune --production

#remove _CENTREON_PATH_PLACEHOLDER_
sed -i -e 's/_CENTREON_PATH_PLACEHOLDER_/centreon/g' ${INSTALL_DIR}/centreon/www/index.html

#create htaccess file
cat >  ${INSTALL_DIR}/centreon/www/.htaccess << EOF
RewriteRule ^index\.html$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.html [L]
ErrorDocument 404 /centreon/index.html
EOF

#apply owner
chown -R www-data: ${INSTALL_DIR}/centreon/www


cat > /etc/apache2/conf-available/centreon.conf << EOF
#
# Section add by Centreon Install Setup
#

Alias /centreon /usr/share/centreon/www/

<LocationMatch ^/centreon/(.*\.php(/.*)?)\$>
  ProxyPassMatch fcgi://127.0.0.1:9000/usr/share/centreon/www/\$1
</LocationMatch>

<Directory "/usr/share/centreon/www">
    DirectoryIndex index.php
    Options Indexes
    AllowOverride all
    Order allow,deny
    Allow from all
    Require all granted
</Directory>

RedirectMatch ^/\$ /centreon
EOF


# reload conf apache
a2enconf centreon.conf
systemctl restart apache2 php7.1-fpm

## Workarounds
## config:  cannot open '/var/lib/centreon-broker/module-temporary.tmp-1-central-module-output-master-failover'
## (mode w+): Permission denied)
chmod 775 /var/lib/centreon-broker/


usermod -aG ${ENGINE_GROUP} www-data
usermod -aG ${ENGINE_GROUP} ${CENTREON_USER}
usermod -aG ${ENGINE_GROUP} ${BROKER_USER}
chown ${ENGINE_USER}:${ENGINE_GROUP} /var/lib/centreon-engine/

}

##ADDONS

function widget_install() {
echo "
=======================================================================
                         Install WIDGETS
=======================================================================
"
cd ${DL_DIR}
  wget -qO- ${WIDGET_HOST} | tar -C ${INSTALL_DIR}/centreon/www/widgets --strip-components 1 -xzv
  wget -qO- ${WIDGET_HOSTGROUP} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv
  wget -qO- ${WIDGET_SERVICE} | tar -C ${INSTALL_DIR}/centreon/www/widgets --strip-components 1 -xzv
  wget -qO- ${WIDGET_GRID_MAP} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv
  wget -qO- ${WIDGET_TOP_CPU} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv
  wget -qO- ${WIDGET_TOP_MEMORY} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv
  wget -qO- ${WIDGET_TACTICAL_OVERVIEW} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv
  wget -qO- ${WIDGET_HTTP_LOADER} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv
  wget -qO- ${WIDGET_ENGINE_STATUS} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv
  wget -qO- ${WIDGET_SERVICEGROUP} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv
  wget -qO- ${WIDGET_GRAPH} | tar -C ${INSTALL_DIR}/centreon/www/widgets/ --strip-components 1 -xzv
  chown -R ${CENTREON_USER}:${CENTREON_GROUP} ${INSTALL_DIR}/centreon/www/widgets
}



function main () {
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
text_params

nonfree_install >> ${INSTALL_LOG} 2>&1
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step1${normal}  => repo non-free on Stretch Install                       ${STATUS_FAIL}"
  else
    echo -e "${bold}Step1${normal}  => repo non-free on Stretch Install                       ${STATUS_OK}"
fi

mariadb_install > ${INSTALL_LOG} 2>&1
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step2${normal}  => MariaDB Install                                       ${STATUS_FAIL}"
  else
    echo -e "${bold}Step2${normal}  => MariaDB Install                                       ${STATUS_OK}"
fi

clib_install >> ${INSTALL_LOG} 2>&1
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step3${normal}  => Clib install                                          ${STATUS_FAIL}"
  else
    echo -e "${bold}Step3${normal}  => Clib install                                          ${STATUS_OK}"
fi

centreon_connectors_install >> ${INSTALL_LOG} 2>&1
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step4${normal}  => Centreon Perl and SSH connectors install              ${STATUS_FAIL}"
  else
    echo -e "${bold}Step4${normal}  => Centreon Perl and SSH connectors install              ${STATUS_OK}"
fi

centreon_engine_install >> ${INSTALL_LOG} 2>&1
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step5${normal}  => Centreon Engine install                               ${STATUS_FAIL}"
  else
    echo -e "${bold}Step5${normal}  => Centreon Engine install                               ${STATUS_OK}"
fi

monitoring_plugin_install >> ${INSTALL_LOG} 2>&1
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step6${normal}  => Monitoring plugins install                            ${STATUS_FAIL}"
  else
    echo -e "${bold}Step6${normal}  => Monitoring plugins install                            ${STATUS_OK}"
fi

centreon_plugins_install >> ${INSTALL_LOG} 2>&1
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step7${normal}  => Centreon plugins install                              ${STATUS_FAIL}"
  else
    echo -e "${bold}Step7${normal}  => Centreon plugins install                              ${STATUS_OK}"
fi

centreon_broker_install >> ${INSTALL_LOG} 2>&1
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step8${normal}  => Centreon Broker install                               ${STATUS_FAIL}"
  else
    echo -e "${bold}Step8${normal}  => Centreon Broker install                               ${STATUS_OK}"
fi

php_fpm_install >> ${INSTALL_LOG} 2>&1
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step9${normal}  => Php-fpm install                               ${STATUS_FAIL}"
  else
    echo -e "${bold}Step9${normal}  => Php-fpm install                               ${STATUS_OK}"
fi


create_centreon_tmpl >> ${INSTALL_LOG} 2>&1
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step10${normal}  => Centreon template generation                          ${STATUS_FAIL}"
  else
    echo -e "${bold}Step10${normal}  => Centreon template generation                          ${STATUS_OK}"
fi

centreon_install >> ${INSTALL_LOG} 2>&1
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step11${normal}  => Centreon web interface install                        ${STATUS_FAIL}"
  else
    echo -e "${bold}Step11${normal}  => Centreon web interface install                        ${STATUS_OK}"
fi

post_install >> ${INSTALL_LOG} 2>&1
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step12${normal} => Post install                                          ${STATUS_FAIL}"
  else
    echo -e "${bold}Step12${normal} => Post install                                          ${STATUS_OK}"
fi

widget_install >> ${INSTALL_LOG} 2>&1
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step13${normal} => Widgets install                                       ${STATUS_FAIL}"
  else
    echo -e "${bold}Step13${normal} => Widgets install                                       ${STATUS_OK}"
fi
echo ""
echo "##### Install completed #####" >> ${INSTALL_LOG} 2>&1
}

# Exec main function
main
echo -e ""
echo -e "${bold}Go to http://${ETH0_IP}/centreon to complete the setup${normal} "
echo -e ""
