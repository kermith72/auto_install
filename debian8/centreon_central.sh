#!/bin/bash
# Centreon + engine install script for Debian Jessie
# v 1.12
# 15/04/2018
# Thanks to Remy
#
export DEBIAN_FRONTEND=noninteractive
# Variables
## Versions
VERSION_BATCH="v 1.12"
CLIB_VER="1.4.2"
CONNECTOR_VER="1.1.3"
ENGINE_VER="1.8.1"
PLUGIN_VER="2.2"
BROKER_VER="3.0.14"
CENTREON_VER="2.8.21"
# MariaDB Series
MARIADB_VER='10.0'
## Sources URL
BASE_URL="https://s3-eu-west-1.amazonaws.com/centreon-download/public"
CLIB_URL="${BASE_URL}/centreon-clib/centreon-clib-${CLIB_VER}.tar.gz"
if [[ "$CONNECTOR_VER" == "1.1.3" ]]; then
    CONNECTOR_URL="${BASE_URL}/centreon-connectors/centreon-connectors-${CONNECTOR_VER}.tar.gz"
else
    CONNECTOR_URL="${BASE_URL}/centreon-connectors/centreon-connector-${CONNECTOR_VER}.tar.gz"
fi
ENGINE_URL="${BASE_URL}/centreon-engine/centreon-engine-${ENGINE_VER}.tar.gz"
PLUGIN_URL="https://www.monitoring-plugins.org/download/monitoring-plugins-${PLUGIN_VER}.tar.gz"
BROKER_URL="${BASE_URL}/centreon-broker/centreon-broker-${BROKER_VER}.tar.gz"
CENTREON_URL="${BASE_URL}/centreon/centreon-web-${CENTREON_VER}.tar.gz"
CLAPI_URL="${BASE_URL}/Modules/CLAPI/centreon-clapi-${CLAPI_VER}.tar.gz"
## Sources widgets
WIDGET_HOST_VER="1.6.2"
WIDGET_HOSTGROUP_VER="1.6.0"
WIDGET_SERVICE_VER="1.6.2"
WIDGET_SERVICEGROUP_VER="1.6.0"
WIDGET_GRID_MAP_VER="1.0.0"
WIDGET_TOP_CPU_VER="1.1.1"
WIDGET_TOP_MEMORY_VER="1.1.1"
WIDGET_TACTICAL_OVERVIEW_VER="1.0.1"
WIDGET_HTTP_LOADER_VER="1.0.0"
WIDGET_ENGINE_STATUS_VER="1.0.2"
WIDGET_GRAPH_VER="1.5.2"
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
WIDGET_GRAPH="https://github.com/Centreon-Widgets/centreon-widget-graph-monitoring.git"
## Temp install dir
DL_DIR="/usr/local/src"
## Install dir
INSTALL_DIR="/usr/share"
## Log install file
INSTALL_LOG="/usr/local/src/centreon-install.log"
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
ETH0_IP=`/sbin/ifconfig eth0 | grep 'inet adr:' | cut -d: -f2 | awk '{ print $1}'`
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

echo 'deb http://ftp.fr.debian.org/debian/ jessie non-free' > /etc/apt/sources.list.d/jessie-nonfree.list

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
if [[ -e centreon-connector-${CONNECTOR_VER}.tar.gz ]]
  then
    echo 'File already exist !'
  else
    wget ${CONNECTOR_URL} -O ${DL_DIR}/centreon-connector-${CONNECTOR_VER}.tar.gz
fi

tar xzf centreon-connector-${CONNECTOR_VER}.tar.gz
cd ${DL_DIR}/centreon-connector-${CONNECTOR_VER}/perl/build

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
   -DWITH_STARTUP_DIR=/etc/init.d \
   -DWITH_PKGCONFIG_SCRIPT=1 \
   -DWITH_PKGCONFIG_DIR=/usr/lib/pkgconfig \
   -DWITH_TESTING=0 .
make
make install

chmod +x /etc/init.d/centengine
update-rc.d centengine defaults
}

function monitoring_plugin_install () {
echo "
======================================================================
                     Install Monitoring Plugins
======================================================================
"

apt-get install --force-yes -y libgnutls28-dev libssl-dev libkrb5-dev libldap2-dev libsnmp-dev gawk \
        libwrap0-dev libmcrypt-dev smbclient fping gettext dnsutils  libmysqlclient-dev \
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
--prefix=/usr/lib/centreon/plugins --libexecdir=/usr/lib/centreon/plugins --enable-perl-modules --with-openssl=/usr/bin/openssl \
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
            libnet-telnet-perl libnet-ntp-perl libnet-dns-perl libdbi-perl libdbd-mysql-perl libdbd-pg-perl git-core
git clone https://github.com/centreon/centreon-plugins.git
cd centreon-plugins
chmod +x centreon_plugins.pl
chown -R ${ENGINE_USER}:${ENGINE_GROUP} ${DL_DIR}/centreon-plugins
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

apt-get install -y librrd-dev libqt4-dev libqt4-sql-mysql libgnutls28-dev liblua5.1-dev lsb-release

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

cmake \
    -DWITH_DAEMONS='central-broker;central-rrd' \
    -DWITH_GROUP=${BROKER_GROUP} \
    -DWITH_PREFIX=/usr \
    -DWITH_PREFIX_BIN=/usr/sbin  \
    -DWITH_PREFIX_CONF=/etc/centreon-broker  \
    -DWITH_PREFIX_LIB=/usr/lib/centreon-broker \
    -DWITH_PREFIX_VAR=/var/lib/centreon-broker \
    -DWITH_PREFIX_MODULES=/usr/share/centreon/lib/centreon-broker \
    -DWITH_STARTUP_DIR=/etc/init.d \
    -DWITH_STARTUP_SCRIPT=auto \
    -DWITH_TESTING=0 \
    -DWITH_USER=${BROKER_USER} .
make
make install
update-rc.d cbd defaults

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
PLUGIN_DIR="/usr/lib/centreon/plugins"
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

INSTALL_DIR_NAGIOS="/usr/bin"
CENTREON_ENGINE_USER="${ENGINE_USER}"
MONITORINGENGINE_USER="${CENTREON_USER}"
MONITORINGENGINE_LOG="/var/log/centreon-engine"
MONITORINGENGINE_INIT_SCRIPT="centengine"
MONITORINGENGINE_BINARY="/usr/sbin/centengine"
MONITORINGENGINE_ETC="/etc/centreon-engine"
NAGIOS_PLUGIN="/usr/lib/centreon/plugins"
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
BIN_RRDTOOL="/usr/bin/rrdtool"
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
EOF
}

function centreon_install () {
echo "
======================================================================
                  Install Centreon Web Interface
======================================================================
"
DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes sudo tofrodos bsd-mailx \
  lsb-release libmysqlclient-dev apache2 apache2-mpm-prefork php5 php5-mysql php-pear \
  php5-ldap php5-snmp php5-gd rrdtool librrds-perl libconfig-inifiles-perl libcrypt-des-perl \
  libdigest-hmac-perl libdigest-sha-perl libgd-gd2-perl php5-sqlite php5-intl \
  snmp snmpd snmptrapd libnet-snmp-perl libsnmp-perl snmp-mibs-downloader


# Cleanup to prevent space full on /var
apt-get clean

ln -s /usr/share/mibs/ /usr/share/snmp/mibs

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

service snmpd restart

service snmptrapd restart

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

echo " Generate Centreon template "

./install.sh -i -f ${DL_DIR}/${CENTREON_TMPL}
}

function post_install () {
echo "
=====================================================================
                          Post install
=====================================================================
"
#Modify default config
# Monitoring engine information
sed -i -e "s/share\/centreon-engine/sbin/g" /usr/share/centreon/www/install/var/engines/centreon-engine;
sed -i -e "s/lib64/lib/g" /usr/share/centreon/www/install/var/engines/centreon-engine;
# sed -i -e "s/CENTREONPLUGINS/CENTREON_PLUGINS/g" /usr/share/centreon/www/install/var/engines/centreon-engine;
# Broker module information
sed -i -e "s/lib64\/nagios\/cbmod.so/lib\/centreon-broker\/cbmod.so/g" /usr/share/centreon/www/install/var/brokers/centreon-broker;
# bug Centreon_plugin
# sed -i -e "s/CENTREONPLUGINS/CENTREON_PLUGINS/g" /usr/share/centreon/www/install/steps/functions.php;
sed -i -e "s/centreon_plugins'] = \"\"/centreon_plugins'] = \"\/usr\/lib\/centreon\/plugins\"/g" /usr/share/centreon/www/install/install.conf.php;

# Add mysql config for Centreon
echo '[mysqld]
innodb_file_per_table=1
open_files_limit=32000' > /etc/mysql/conf.d/centreon.cnf

service mysql restart

# add Timezone
VARTIMEZONEP=`echo ${VARTIMEZONE} | sed 's:\/:\\\/:g' `
sed -i -e "s/;date.timezone =/date.timezone = ${VARTIMEZONEP}/g" /etc/php5/apache2/php.ini;

# reload conf apache
a2enconf centreon.conf
service apache2 reload

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
  /usr/bin/git clone -b ${WIDGET_GRAPH_VER} ${WIDGET_GRAPH}
  mv centreon-widget-graph-monitoring/graph-monitoring ${INSTALL_DIR}/centreon/www/widgets/
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
    echo -e "${bold}Step1${normal}  => repo non-free on Jessie Install                       ${STATUS_FAIL}"
  else
    echo -e "${bold}Step1${normal}  => repo non-free on Jessie Install                       ${STATUS_OK}"
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

create_centreon_tmpl >> ${INSTALL_LOG} 2>&1
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step9${normal}  => Centreon template generation                          ${STATUS_FAIL}"
  else
    echo -e "${bold}Step9${normal}  => Centreon template generation                          ${STATUS_OK}"
fi

centreon_install >> ${INSTALL_LOG} 2>&1
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step10${normal}  => Centreon web interface install                        ${STATUS_FAIL}"
  else
    echo -e "${bold}Step10${normal}  => Centreon web interface install                        ${STATUS_OK}"
fi

post_install >> ${INSTALL_LOG} 2>&1
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step11${normal} => Post install                                          ${STATUS_FAIL}"
  else
    echo -e "${bold}Step11${normal} => Post install                                          ${STATUS_OK}"
fi

widget_install >> ${INSTALL_LOG} 2>&1
if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step12${normal} => Widgets install                                       ${STATUS_FAIL}"
  else
    echo -e "${bold}Step12${normal} => Widgets install                                       ${STATUS_OK}"
fi
echo ""
echo "##### Install completed #####" >> ${INSTALL_LOG} 2>&1
}

# Exec main function
main
echo -e ""
echo -e "${bold}Go to http://${ETH0_IP}/centreon to complete the setup${normal} "
echo -e ""
