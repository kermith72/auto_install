#!/bin/bash
# Centreon 20.04 + engine install script for Raspian Buster
# v 1.58
# 15/12/2020
# Thanks to Remy, Justice81 and Pixelabs
#
export DEBIAN_FRONTEND=noninteractive
# Variables
## Versions
VERSION_BATCH="v 1.58"
CLIB_VER="20.04.0"
CONNECTOR_VER="20.04.0"
ENGINE_VER="20.04.7"
PLUGIN_VER="2.3"
PLUGIN_CENTREON_VER="20201006"
BROKER_VER="20.04.10"
GORGONE_VER="20.04.8" 
CENTREON_VER="20.04.7" 
## Sources URL
BASE_URL="http://files.download.centreon.com/public"
CLIB_URL="${BASE_URL}/centreon-clib/centreon-clib-${CLIB_VER}.tar.gz"
CONNECTOR_URL="${BASE_URL}/centreon-connectors/centreon-connectors-${CONNECTOR_VER}.tar.gz"
ENGINE_URL="${BASE_URL}/centreon-engine/centreon-engine-${ENGINE_VER}.tar.gz"
PLUGIN_URL="https://www.monitoring-plugins.org/download/monitoring-plugins-${PLUGIN_VER}.tar.gz"
PLUGIN_CENTREON_URL="${BASE_URL}/centreon-plugins/centreon-plugins-${PLUGIN_CENTREON_VER}.tar.gz"
BROKER_URL="${BASE_URL}/centreon-broker/centreon-broker-${BROKER_VER}.tar.gz"
CENTREON_URL="${BASE_URL}/centreon/centreon-web-${CENTREON_VER}.tar.gz"
GORGONE_URL="${BASE_URL}/centreon-gorgone/centreon-gorgone-${GORGONE_VER}.tar.gz"
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
GORGONE_USER="centreon-gorgone"
GORGONE_GROUP="centreon-gorgone"
CENTREON_USER="centreon"
CENTREON_GROUP="centreon"
## TMPL file (template install file for Centreon)
CENTREON_TMPL="centreon_install.tmpl"
GORGONE_TMPL="gorgone.tmpl"
ETH0_IP=`/sbin/ip route get 8.8.8.8 | /usr/bin/awk 'NR==1 {print $7}'`
## TimeZone php
VARTIMEZONE="Europe/Paris"
## verbose script
SCRIPT_VERBOSE=false
## nb processor
NB_PROC=`cat /proc/cpuinfo | grep processor | wc -l`
## print update
CHAINE_UPDATE=("newer version installed" "already installed" "install" "update minor" "update major")
## message question
yes="y"
no="n"

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
  RES_COL="64"
  MOVE_TO_COL="\\033[${RES_COL}G"
  COL_RESET=$ESC_SEQ"39;49;00m"
  COL_YELLOW=$ESC_SEQ"33;01m"
  COL_GREEN=$ESC_SEQ"32;01m"
  COL_RED=$ESC_SEQ"31;01m"
  STATUS_FAIL="${MOVE_TO_COL}[$COL_RED${bold}FAIL${normal}$COL_RESET]"
  STATUS_OK="${MOVE_TO_COL}[$COL_GREEN${bold} OK ${normal}$COL_RESET]"
  STATUS_WARNING="${MOVE_TO_COL}[$COL_YELLOW${bold}WARN${normal}$COL_RESET]"
}



function clib_install () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                          Install Clib
======================================================================
" | tee -a ${INSTALL_LOG}
local MAJOUR=$1

apt-get install -y wget cmake python3-pip >> ${INSTALL_LOG}

cd ${DL_DIR}
if [[ -e centreon-clib-${CLIB_VER}.tar.gz ]] ;
  then
    echo 'File already exist !' | tee -a ${INSTALL_LOG}
  else
    wget ${CLIB_URL} -O ${DL_DIR}/centreon-clib-${CLIB_VER}.tar.gz >> ${INSTALL_LOG}
    [ $? != 0 ] && return 1
fi

tar xzf centreon-clib-${CLIB_VER}.tar.gz
cd centreon-clib-${CLIB_VER}
mkdir build
cd build

[ "$SCRIPT_VERBOSE" = true ] && echo "====> Compilation" | tee -a ${INSTALL_LOG}

cmake \
   -DWITH_TESTING=0 \
   -DWITH_PREFIX=/usr \
   -DWITH_SHARED_LIB=1 \
   -DWITH_STATIC_LIB=0 \
   -DWITH_PKGCONFIG_DIR=/usr/lib/pkgconfig .. >> ${INSTALL_LOG}
make -j $NB_PROC  >> ${INSTALL_LOG}
make install >> ${INSTALL_LOG}

}

function centreon_connectors_install () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
               Install Centreon Connectors
======================================================================
" | tee -a ${INSTALL_LOG}
local MAJOUR=$1

apt-get install -y libperl-dev libssh2-1-dev libgcrypt-dev >> ${INSTALL_LOG}
/usr/bin/pip3 install conan >> ${INSTALL_LOG}
/usr/local/bin/conan remote add centreon https://api.bintray.com/conan/centreon/centreon >> ${INSTALL_LOG}

cd ${DL_DIR}
if [[ -e centreon-connectors-${CONNECTOR_VER}.tar.gz ]]
  then
    echo 'File already exist !' | tee -a ${INSTALL_LOG}
  else
    wget ${CONNECTOR_URL} -O ${DL_DIR}/centreon-connectors-${CONNECTOR_VER}.tar.gz >> ${INSTALL_LOG}
    [ $? != 0 ] && return 1
fi

tar xzf centreon-connectors-${CONNECTOR_VER}.tar.gz
cd ${DL_DIR}/centreon-connectors-${CONNECTOR_VER}
mkdir build
cd build

[ "$SCRIPT_VERBOSE" = true ] && echo "====> Compilation" | tee -a ${INSTALL_LOG}

conan install --build=fmt --build=gtest --build=spdlog .. >> ${INSTALL_LOG}

cmake \
 -DWITH_PREFIX=/usr  \
 -DWITH_PREFIX_BINARY=/usr/lib/centreon-connector  \
 -DWITH_CENTREON_CLIB_INCLUDE_DIR=/usr/include \
 -DWITH_TESTING=0 .. >> ${INSTALL_LOG}
make -j $NB_PROC  >> ${INSTALL_LOG}
make install >> ${INSTALL_LOG}


}

function centreon_engine_install () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                    Install Centreon Engine
======================================================================
" | tee -a ${INSTALL_LOG}
local MAJOUR=$1

if [[ $MAJOUR == 2 ]]
then
  groupadd -g 6001 ${ENGINE_GROUP}
  useradd -u 6001 -g ${ENGINE_GROUP} -m -r -d /var/lib/centreon-engine -c "Centreon-engine Admin" -s /bin/bash ${ENGINE_USER}
  #verify permission
  if [ $(ls -ld "/var/lib/centreon-engine" | awk '{print $3}') == "root" ]
  then
    chown ${ENGINE_USER}:${ENGINE_GROUP} /var/lib/centreon-engine
  fi
fi
if [[ $MAJOUR > 2 ]]
then
	echo -e "stop Centreon Engine${STATUS_WARNING}"
	systemctl stop centengine
fi

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
mkdir build
sed -i -e "s/fmt\/6.2.0/fmt\/6.2.0\nopenssl\/1.0.2t\n\n[options]\nopenssl:no_asm=True/g" ${DL_DIR}/centreon-engine-${ENGINE_VER}/conanfile.txt

cd build

[ "$SCRIPT_VERBOSE" = true ] && echo "====> Compilation" | tee -a ${INSTALL_LOG}

CXXFLAGS=-latomic /usr/local/bin/conan install --build=grpc --build=fmt --build=missing .. >> ${INSTALL_LOG}

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
   -DWITH_TESTING=0 .. >> ${INSTALL_LOG}
make -j $NB_PROC  >> ${INSTALL_LOG}
make install >> ${INSTALL_LOG}

if [[ $MAJOUR > 2 ]]
then
	#change right configuration after update
	chmod 775 /etc/centreon-engine/*
fi

systemctl enable centengine.service >> ${INSTALL_LOG}
systemctl daemon-reload >> ${INSTALL_LOG}
}

function monitoring_plugin_install () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                     Install Monitoring Plugins
======================================================================
" | tee -a ${INSTALL_LOG}
local MAJOUR=$1

apt-get install --force-yes -y monitoring-plugins  libgnutls28-dev libssl-dev libkrb5-dev \
        libldap2-dev libsnmp-dev gawk \
        libwrap0-dev libmcrypt-dev smbclient fping gettext dnsutils libmodule-build-perl libmodule-install-perl \
        libnet-snmp-perl >> ${INSTALL_LOG}
        

## override message question with gettext values
yes="$(gettext "y")"
no="$(gettext "n")"

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

make -j $NB_PROC >> ${INSTALL_LOG}
make install >> ${INSTALL_LOG}
}


function centreon_plugins_install() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
=======================================================================
                    Install Centreon Plugins
=======================================================================
" | tee -a ${INSTALL_LOG}
local MAJOUR=$1

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

}

function centreon_broker_install() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                     Install Centreon Broker
======================================================================
" | tee -a ${INSTALL_LOG}
local MAJOUR=$1

if [[ $MAJOUR == 2 ]]
then
  groupadd -g 6002 ${BROKER_GROUP}
  useradd -u 6002 -g ${BROKER_GROUP} -m -r -d /var/lib/centreon-broker -c "Centreon-broker Admin" -s /bin/bash  ${BROKER_USER}
  usermod -aG ${BROKER_GROUP} ${ENGINE_USER}
  #verify permission
  if [ $(ls -ld "/var/lib/centreon-broker" | awk '{print $3}') == "root" ]
  then
    chown ${BROKER_USER}:${BROKER_GROUP} /var/lib/centreon-broker
  fi
fi
if [[ $MAJOUR > 2 ]]
then
      echo -e "stop Centreon Engine${STATUS_WARNING}"
      /bin/systemctl stop centengine
fi

apt-get install git librrd-dev libmariadb-dev libgnutls28-dev lsb-release liblua5.2-dev -y >> ${INSTALL_LOG}

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
sed -i -e "s/grpc\/1.25.0@inexorgame\/stable/grpc\/1.25.0@inexorgame\/stable\nopenssl\/1.0.2t\n\n[options]\nopenssl:no_asm=True/g" ${DL_DIR}/centreon-broker-${BROKER_VER}/conanfile.txt

mkdir build
cd build

[ "$SCRIPT_VERBOSE" = true ] && echo "====> Compilation broker" | tee -a ${INSTALL_LOG}

CXXFLAGS=-latomic /usr/local/bin/conan install --build=grpc --build=fmt --build=missing .. >> ${INSTALL_LOG}

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
    -DWITH_USER=${BROKER_USER} .. >> ${INSTALL_LOG}
make -j 5 >> ${INSTALL_LOG}
make install >> ${INSTALL_LOG}

if [[ -d /var/lib/centreon-broker ]]
  then
    chmod 775 /var/lib/centreon-broker
fi


# Cleanup to prevent space full on /var
apt-get clean >> ${INSTALL_LOG}
}


function centreon_gorgone_install() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                     Install Centreon Gorgone
======================================================================
" | tee -a ${INSTALL_LOG}
local MAJOUR=$1

if [[ $MAJOUR == 2 ]]; then
	
  apt install libzmq3-dev libssh-dev libextutils-makemaker-cpanfile-perl \
            libmodule-build-perl libmodule-install-perl -y >> ${INSTALL_LOG}
	
  [ "$SCRIPT_VERBOSE" = true ] && echo "====> Install ZMQ-LibZMQ4" | tee -a ${INSTALL_LOG}
  cd ${DL_DIR}
  wget http://search.cpan.org/CPAN/authors/id/M/MO/MOSCONI/ZMQ-LibZMQ4-0.01.tar.gz >> ${INSTALL_LOG}
  tar zxf ZMQ-LibZMQ4-0.01.tar.gz 
  cd ZMQ-LibZMQ4-0.01
  sed -i -e "s/tools/.\/tools/g" Makefile.PL
  perl Makefile.PL >> ${INSTALL_LOG}
  make -j $NB_PROC >> ${INSTALL_LOG}
  make install >> ${INSTALL_LOG}
  cd ..
  wget https://cpan.metacpan.org/authors/id/D/DM/DMAKI/ZMQ-Constants-1.04.tar.gz >> ${INSTALL_LOG}
  tar zxf ZMQ-Constants-1.04.tar.gz
  cd ZMQ-Constants-1.04
  perl Makefile.PL >> ${INSTALL_LOG}
  make -j $NB_PROC >> ${INSTALL_LOG}
  make install >> ${INSTALL_LOG}

  [ "$SCRIPT_VERBOSE" = true ] && echo "====> Install lib-ssh" | tee -a ${INSTALL_LOG}
  cd ${DL_DIR}
  /usr/bin/git clone https://github.com/garnier-quentin/perl-libssh.git >> ${INSTALL_LOG}
  cd perl-libssh
  perl Makefile.PL >> ${INSTALL_LOG}
  make -j $NB_PROC >> ${INSTALL_LOG}
  make install >> ${INSTALL_LOG}

  [ "$SCRIPT_VERBOSE" = true ] && echo "
  ==================   Install Gorgone     =====================
  " | tee -a ${INSTALL_LOG}
  apt install libcryptx-perl libschedule-cron-perl libcrypt-cbc-perl \
           libcpanel-json-xs-perl libjson-pp-perl libyaml-perl \
           libyaml-libyaml-perl libdbd-sqlite3-perl libdbd-mysql-perl \
           libapache-dbi-perl libdata-uuid-perl libhttp-daemon-perl \
           libhttp-message-perl libmime-base64-urlsafe-perl \
           libdigest-md5-file-perl libwww-curl-perl libio-socket-ssl-perl \
           libnetaddr-ip-perl libhash-merge-perl -y >> ${INSTALL_LOG}
fi
cd ${DL_DIR}
if [[ -e centreon-gorgone-${GORGONE_VER}.tar.gz ]]
  then
    echo 'File already exist !' | tee -a ${INSTALL_LOG}
  else
    wget ${GORGONE_URL} -O ${DL_DIR}/centreon-gorgone-${GORGONE_VER}.tar.gz >> ${INSTALL_LOG}
    [ $? != 0 ] && return 1
fi

tar xzf centreon-gorgone-${GORGONE_VER}.tar.gz
cd ${DL_DIR}/centreon-gorgone-${GORGONE_VER}

# remplace script install.sh
cp ${DIR_SCRIPT}/libinstall/install_gorgone.sh ${DL_DIR}/centreon-gorgone-${GORGONE_VER}/install.sh >> ${INSTALL_LOG}


[ "$SCRIPT_VERBOSE" = true ] && echo "====> Create template Gorgone" | tee -a ${INSTALL_LOG}
cat > ${DL_DIR}/${GORGONE_TMPL} << EOF
# gorgone template
# deployment paths
GORGONE_LOG="/var/log/centreon-gorgone"
GORGONE_VARLIB="/var/lib/centreon-gorgone"
GORGONE_ETC="/etc/centreon-gorgone"
GORGONE_CONF_FILE="/config.yaml"
GORGONE_BINDIR="/usr/bin/"

# perl related paths
GORGONE_PERL="/usr/share/perl5/"

# system tools paths
INIT_D="/etc/init.d"
CRON_D="/etc/cron.d"
LOGROTATE_D="/etc/logrotate.d"
SYSTEM_D="/etc/systemd/system"
SYSCONFIG="/etc/default"

# user and group
GORGONE_USER="centreon-gorgone"
GORGONE_GROUP="centreon-gorgone"
EOF

./install.sh -i -f ${DL_DIR}/${GORGONE_TMPL} >> ${INSTALL_LOG}

	
}

function create_centreon_tmpl() {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                  Centreon template generation
======================================================================
" | tee -a ${INSTALL_LOG}

cat > ${DL_DIR}/${CENTREON_TMPL} << EOF
#Centreon template
PROCESS_CENTREON_WWW=0
PROCESS_CENTSTORAGE=0
PROCESS_CENTCORE=0
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

GORGONE_VARLIB="/var/lib/centreon-gorgone"
GORGONE_CONFIG="/etc/centreon-gorgone"
GORGONE_USER="centreon-gorgone"
GORGONE_GROUP="centreon-gorgone"
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


# remplace scripts for mode silent
cp ${DIR_SCRIPT}/libinstall/install_web_2004.sh ${DL_DIR}/${PREFIX}${CENTREON_VER}/install.sh >> ${INSTALL_LOG}
cp ${DIR_SCRIPT}/libinstall/CentPluginsTraps_2004.sh ${DL_DIR}/${PREFIX}${CENTREON_VER}/libinstall/CentPluginsTraps.sh >> ${INSTALL_LOG}
cp ${DIR_SCRIPT}/libinstall/functions_2004 ${DL_DIR}/${PREFIX}${CENTREON_VER}/libinstall/functions >> ${INSTALL_LOG}



[ "$SCRIPT_VERBOSE" = true ] && echo " Apply Centreon template " | tee -a ${INSTALL_LOG}

/bin/bash ${DL_DIR}/${PREFIX}${CENTREON_VER}/install.sh -u /etc/centreon -f ${DL_DIR}/${CENTREON_TMPL} >> ${INSTALL_LOG}
 
}

function centreon_install () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
======================================================================
                  Install Centreon Web Interface
======================================================================
" | tee -a ${INSTALL_LOG}
DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes sudo tofrodos bsd-mailx \
  lsb-release apache2  \
  librrds-perl libconfig-inifiles-perl libcrypt-des-perl \
  libdigest-hmac-perl libdigest-sha-perl libcrypt-des-ede3-perl libdbd-sqlite3-perl \
  snmp snmpd snmptrapd libnet-snmp-perl libsnmp-perl snmp-mibs-downloader ntp  >> ${INSTALL_LOG}


# Cleanup to prevent space full on /var
apt-get clean >> ${INSTALL_LOG}

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

service snmpd restart >> ${INSTALL_LOG}

service snmptrapd restart >> ${INSTALL_LOG}

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
usermod -aG ${ENGINE_GROUP} ${CENTREON_USER}
usermod -aG ${BROKER_GROUP} ${CENTREON_USER}
usermod -aG ${CENTREON_GROUP} ${BROKER_USER}
usermod -aG ${BROKER_GROUP} ${ENGINE_USER}

tar xzf centreon-web-${CENTREON_VER}.tar.gz
cd ${DL_DIR}/centreon-web-${CENTREON_VER}


# clean /tmp
rm -rf /tmp/*


# remplace script install.sh
cp ${DIR_SCRIPT}/libinstall/install_web_2004.sh ${DL_DIR}/centreon-web-${CENTREON_VER}/install.sh >> ${INSTALL_LOG}


  [ "$SCRIPT_VERBOSE" = true ] && echo " Apply Centreon template " | tee -a ${INSTALL_LOG}

  /bin/bash ${DL_DIR}/centreon-web-${CENTREON_VER}/install.sh -i -f ${DL_DIR}/${CENTREON_TMPL} >> ${INSTALL_LOG}
 
}

function post_install () {
[ "$SCRIPT_VERBOSE" = true ] && echo "
=====================================================================
                          Post install
=====================================================================
" | tee -a ${INSTALL_LOG}
local MAJOUR=$1

if [[ $MAJOUR == 2 ]]; then
 # install new config

  usermod -aG ${ENGINE_GROUP} centreon-gorgone
  usermod -aG ${BROKER_GROUP} centreon-gorgone
  usermod -aG ${CENTREON_GROUP} centreon-gorgone
  usermod -aG centreon-gorgone ${CENTREON_USER}
  usermod -aG centreon-gorgone ${ENGINE_USER}
  usermod -aG centreon-gorgone ${BROKER_USER}

  # Add /etc/sudoers.d/centreon
echo "## BEGIN: CENTREON SUDO

User_Alias      CENTREON=%centreon
Defaults:CENTREON !requiretty

# centreontrapd
CENTREON   ALL = NOPASSWD: /usr/sbin/service centreontrapd start
CENTREON   ALL = NOPASSWD: /usr/sbin/service centreontrapd stop
CENTREON   ALL = NOPASSWD: /usr/sbin/service centreontrapd restart
CENTREON   ALL = NOPASSWD: /usr/sbin/service centreontrapd reload

# Centreon Engine
CENTREON   ALL = NOPASSWD: /usr/sbin/service centengine start
CENTREON   ALL = NOPASSWD: /usr/sbin/service centengine stop
CENTREON   ALL = NOPASSWD: /usr/sbin/service centengine restart
CENTREON   ALL = NOPASSWD: /usr/sbin/service centengine reload
CENTREON   ALL = NOPASSWD: /usr/sbin/centengine -v *

# Centreon Broker
CENTREON   ALL = NOPASSWD: /usr/sbin/service cbd start
CENTREON   ALL = NOPASSWD: /usr/sbin/service cbd stop
CENTREON   ALL = NOPASSWD: /usr/sbin/service cbd restart
CENTREON   ALL = NOPASSWD: /usr/sbin/service cbd reload

## END: CENTREON SUDO" > /etc/sudoers.d/centreon


  ## Workarounds
  ## config:  cannot open '/var/lib/centreon-broker/module-temporary.tmp-1-central-module-output-master-failover'
  ## (mode w+): Permission denied)
  chown centreon: /var/log/centreon
  chmod 775 /var/log/centreon
  chown ${BROKER_USER}:${BROKER_GROUP} /etc/centreon-broker
  chmod 775 /etc/centreon-broker
  chmod -R 775 /etc/centreon-engine
  chmod 775 /var/lib/centreon-broker
  chown ${CENTREON_USER}:${CENTREON_GROUP} /etc/centreon-broker/*

  ## create cache for gorgone
  mkdir /var/cache/centreon
  chown ${CENTREON_USER}:${CENTREON_GROUP}  /var/cache/centreon
  chmod 775 /var/cache/centreon

  ####usermod -aG ${ENGINE_GROUP} www-data
  usermod -aG ${ENGINE_GROUP} ${CENTREON_USER}
  usermod -aG ${ENGINE_GROUP} ${BROKER_USER}
  chown ${ENGINE_USER}:${ENGINE_GROUP} /var/lib/centreon-engine/
  chmod g-w /var/lib/centreon
  chmod ${CENTREON_USER}:${CENTREON_GROUP} /var/lib/centreon/centplugins

  mkdir /var/log/centreon-broker
  chown ${BROKER_USER}: /var/log/centreon-broker
  chmod 775 /var/log/centreon-broker

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

elif [[ $MAJOUR == 4 ]]; then

  # update major
  ## create cache for gorgone
  mkdir /var/cache/centreon
  chown ${CENTREON_USER}:${CENTREON_GROUP}  /var/cache/centreon
  chmod 775 /var/cache/centreon
  
  chmod -R 775 /etc/centreon-engine


#else
  #
fi
}

##ADDONS

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
================| Centreon Poller Install details $VERSION_BATCH |============
                  Clib       : ${CLIB_VER}
                  Connector  : ${CONNECTOR_VER}
                  Engine     : ${ENGINE_VER}
                  Plugins    : ${PLUGIN_VER} & ${PLUGIN_CENTREON_VER}
                  Broker     : ${BROKER_VER}
                  Gorgone    : ${GORGONE_VER}
                  Centreon   : ${CENTREON_VER}
                  NRPE       : ${NRPE_VERSION}
                  Install dir: ${INSTALL_DIR}
                  Source dir : ${DL_DIR}
======================================================================
"
  else
echo "
================| Centreon Poller Install details $VERSION_BATCH |============
                  Clib       : ${CLIB_VER}
                  Connector  : ${CONNECTOR_VER}
                  Engine     : ${ENGINE_VER}
                  Plugins    : ${PLUGIN_VER} & ${PLUGIN_CENTREON_VER}
                  Broker     : ${BROKER_VER}
                  Gorgone    : ${GORGONE_VER}
                  Centreon   : ${CENTREON_VER}
                  Install dir: ${INSTALL_DIR}
                  Source dir : ${DL_DIR}
======================================================================
"
  fi
text_params

verify_version "$CLIB_VER" "$CLIB_VER_OLD"
MAJ=$?
if [[ ${MAJ} > 1 ]];
  then
    clib_install ${MAJ} 2>>${INSTALL_LOG}
    if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step1${normal}  => Clib ${CHAINE_UPDATE[${MAJ}]}${STATUS_FAIL}"
      else
        echo -e "${bold}Step1${normal}  => Clib ${CHAINE_UPDATE[${MAJ}]}${STATUS_OK}"
        maj_conf "CLIB_VER" "$CLIB_VER_OLD" "$CLIB_VER"
    fi
  else
    echo -e "${bold}Step1${normal}  => Clib ${CHAINE_UPDATE[${MAJ}]}${STATUS_OK}"
fi


verify_version "$CONNECTOR_VER" "$CONNECTOR_VER_OLD"
MAJ=$?
if [[ ${MAJ} > 1 ]];
  then
    centreon_connectors_install ${MAJ} 2>>${INSTALL_LOG}
    if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step2${normal}  => Centreon Perl and SSH connectors ${CHAINE_UPDATE[${MAJ}]}${STATUS_FAIL}"
      else
        echo -e "${bold}Step2${normal}  => Centreon Perl and SSH connectors ${CHAINE_UPDATE[${MAJ}]}${STATUS_OK}"
        maj_conf "CONNECTOR_VER" "$CONNECTOR_VER_OLD" "$CONNECTOR_VER"
    fi
  else
    echo -e  "${bold}Step2${normal}  => Centreon Perl and SSH connectors ${CHAINE_UPDATE[${MAJ}]}${STATUS_OK}"
fi

verify_version "$ENGINE_VER" "$ENGINE_VER_OLD"
MAJ=$?
if [[ ${MAJ} > 1 ]];
  then
    centreon_engine_install ${MAJ} 2>>${INSTALL_LOG}
    if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step3${normal}  => Centreon Engine ${CHAINE_UPDATE[${MAJ}]}${STATUS_FAIL}"
      else
        echo -e "${bold}Step3${normal}  => Centreon Engine ${CHAINE_UPDATE[${MAJ}]}${STATUS_OK}"
        maj_conf "ENGINE_VER" "$ENGINE_VER_OLD" "$ENGINE_VER"
    fi
  else
    echo -e     "${bold}Step3${normal}  => Centreon Engine ${CHAINE_UPDATE[${MAJ}]}${STATUS_OK}"
fi

verify_version "$PLUGIN_VER" "$PLUGIN_VER_OLD"
MAJ=$?
if [[ ${MAJ} > 1 ]];
  then
    monitoring_plugin_install ${MAJ} 2>>${INSTALL_LOG}
    if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step4${normal}  => Monitoring plugins ${CHAINE_UPDATE[${MAJ}]}${STATUS_FAIL}"
      else
        echo -e "${bold}Step4${normal}  => Monitoring plugins ${CHAINE_UPDATE[${MAJ}]}${STATUS_OK}"
        maj_conf "PLUGIN_VER" "$PLUGIN_VER_OLD" "$PLUGIN_VER"    
    fi
  else
    echo -e     "${bold}Step4${normal}  => Monitoring plugins ${CHAINE_UPDATE[${MAJ}]}${STATUS_OK}"
fi

verify_version "$PLUGIN_CENTREON_VER" "$PLUGIN_CENTREON_VER_OLD"
MAJ=$?
if [[ ${MAJ} > 1 ]];
  then
    centreon_plugins_install ${MAJ} 2>>${INSTALL_LOG}
    if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step5${normal}  => Centreon plugins ${CHAINE_UPDATE[${MAJ}]}${STATUS_FAIL}"
      else
        echo -e   "${bold}Step5${normal}  => Centreon plugins ${CHAINE_UPDATE[${MAJ}]}${STATUS_OK}"
        maj_conf "PLUGIN_CENTREON_VER" "$PLUGIN_CENTREON_VER_OLD" "$PLUGIN_CENTREON_VER"    
    fi
  else
    echo -e     "${bold}Step5${normal}  => Centreon plugins ${CHAINE_UPDATE[${MAJ}]}${STATUS_OK}"
fi


verify_version "$BROKER_VER" "$BROKER_VER_OLD"
MAJ=$?
if [[ ${MAJ} > 1 ]];
  then
    centreon_broker_install ${MAJ} 2>>${INSTALL_LOG}
    if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step6${normal}  => Centreon Broker ${CHAINE_UPDATE[${MAJ}]}${STATUS_FAIL}"
      else
        echo -e "${bold}Step6${normal}  => Centreon Broker ${CHAINE_UPDATE[${MAJ}]}${STATUS_OK}"
        maj_conf "BROKER_VER" "$BROKER_VER_OLD" "$BROKER_VER"    
    fi
  else
    echo -e     "${bold}Step6${normal}  => Centreon Broker ${CHAINE_UPDATE[${MAJ}]}${STATUS_OK}"
fi



verify_version "${GORGONE_VER}" "$GORGONE_VER_OLD"
MAJ=$?
if [[ ${MAJ} > 1 ]];
  then
    centreon_gorgone_install ${MAJ} 2>>${INSTALL_LOG}
    if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step7${normal} => Centreon Gorgone ${CHAINE_UPDATE[${MAJ}]}${STATUS_FAIL}"
      else
        echo -e "${bold}Step7${normal} => Centreon Gorgone ${CHAINE_UPDATE[${MAJ}]}${STATUS_OK}"
        maj_conf "GORGONE_VER" "$GORGONE_VER_OLD" "${GORGONE_VER}"    
    fi
  else
    echo -e     "${bold}Step7${normal} => Centreon Gorgone ${CHAINE_UPDATE[${MAJ}]}${STATUS_OK}"
fi



verify_version "$CENTREON_VER" "$CENTREON_VER_OLD"
MAJ=$?
if [[ ${MAJ} > 1 ]];
  then
    if [ -z "$CENTREON_VER_OLD" ]; 
    then
      create_centreon_tmpl ${MAJ} 2>>${INSTALL_LOG}
      if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step8${normal}  => Centreon template generation${STATUS_FAIL}"
      else
        echo -e "${bold}Step8${normal}  => Centreon template generation${STATUS_OK}"
      fi
      
    else 
      create_centreon_tmpl 2>>${INSTALL_LOG}
      echo -e "${bold}Step8${normal}  => Centreon template generation${STATUS_OK}"
  fi
    
  else
    echo -e   "${bold}Step8${normal}  => Centreon template ${CHAINE_UPDATE[${MAJ}]}${STATUS_OK}"
fi


verify_version "$CENTREON_VER" "$CENTREON_VER_OLD"
MAJ=$?
if [[ ${MAJ} > 1 ]];
  then
    if [ -z "$CENTREON_VER_OLD" ]; 
    then
      centreon_install 2>>${INSTALL_LOG}
      if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step9${normal}  => Centreon web interface ${CHAINE_UPDATE[${MAJ}]}${STATUS_FAIL}"
      else
        echo -e "${bold}Step9${normal}  => Centreon web interface ${CHAINE_UPDATE[${MAJ}]}${STATUS_OK}"
        maj_conf "CENTREON_VER" "$CENTREON_VER_OLD" "$CENTREON_VER"    
      fi
    else 
      centreon_maj 2>>${INSTALL_LOG}
      if [[ $? -ne 0 ]];
      then
        echo -e "${bold}Step9${normal}  => Centreon web interface maj${STATUS_FAIL}"
      else
        echo -e "${bold}Step9${normal}  => Centreon web interface maj${STATUS_OK}"
        maj_conf "CENTREON_VER" "$CENTREON_VER_OLD" "$CENTREON_VER"    
      fi
    fi
  else
    echo -e   "${bold}Step9${normal}  => Centreon web ${CHAINE_UPDATE[${MAJ}]}${STATUS_OK}"
fi


if [[ ${MAJ} > 1 ]];
then
  post_install ${MAJ} 2>>${INSTALL_LOG}
  if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step10${normal} => Post install ${CHAINE_UPDATE[${MAJ}]}${STATUS_FAIL}"
  else
    echo -e "${bold}Step10${normal} => Post install ${CHAINE_UPDATE[${MAJ}]}${STATUS_OK}"
  fi
fi



if [ "$ADD_NRPE" == "yes" ]
then
  add_check_nrpe 2>>${INSTALL_LOG}
  if [[ $? -ne 0 ]];
  then
    echo -e "${bold}Step11${normal} => Nrpe install                                          ${STATUS_FAIL}"
  else
    echo -e "${bold}Step11${normal} => Nrpe install                                          ${STATUS_OK}"
  fi

fi
echo ""
echo "##### Install completed #####" | tee -a ${INSTALL_LOG}
}

#----
## make a question with yes/no possiblity
## use "no" response by default
## @param	message to print
## @param 	default response (default to no)
## @return 0 	yes
## @return 1 	no
## @Copyright	Copyright 2008, Guillaume Watteeux
#----
yes_no_default() {
	local message=$1
	local default=${2:-$no}
	local res="not_define"
	while [ "$res" != "$yes" ] && [ "$res" != "$no" ] && [ ! -z "$res" ] ; do
		echo -e "\n$message\n$(gettext "[y/n], default to [$default]:")"
		echo -en "> "
		read res
		[ -z "$res" ] && res="$default"
	done
	if [ "$res" = "$yes" ] ; then
		return 0
	else 
		return 1
	fi
}



# verify version
# parameter $1:new version $2:old version
# return 1->egal 2->install 3->newer version minor installed
# 4->newer version major installed 0->old version 
function verify_version () {
   if [ -z "$2" ]; then
     # new install
     return 2
   fi
   if [[ $1 == $2 ]]
   then
     # already install
     return 1
   fi
   local IFS='.' 
   read -r -a NEWVER <<< $1
   read -r -a ANCVER <<< $2
   if ((10#${NEWVER[0]} > 10#${ANCVER[0]}))
   then
	   # version major
	   return 4
   fi
   if ((10#${NEWVER[0]} < 10#${ANCVER[0]}))
   then
	   #  newer version installed
	   return 0
   fi
   if (((10#${NEWVER[1]} > 10#${ANCVER[1]})) && ((10#${NEWVER[0]} == 10#${ANCVER[0]})))
   then
	   # version major
	   return 4
   fi
   if (((10#${NEWVER[1]} < 10#${ANCVER[1]})) && ((10#${NEWVER[0]} <= 10#${ANCVER[0]})))
   then
	   # newer version installed
	   return 0
   fi
   if ((10#${NEWVER[2]} > 10#${ANCVER[2]}))
   then
	   # version minor
	   return 3
   fi
   return 0
}

# maj conf
# parameter $1: name variable $2: old value $3: new value
function maj_conf () {
	/bin/cat /etc/centreon/install_auto.conf | grep "^$1="  >> ${INSTALL_LOG}
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
	  return 0
	else
	  #bug fix version-delete [0]
      sed -i "s/\[0\]//g" /etc/centreon/install_auto.conf
      IFS="="
	  while read -r var value
          do
            export "${var}_OLD"="$value"
          done < /etc/centreon/install_auto.conf
      return 1
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
text_params
exist_conf
if [[ $? -eq 1 ]]; then
  yes_no_default "$(gettext "Centreon is already installed, do you want to update ?")"
  if [ "$?" -eq 1 ] ; then
      echo -e "Update Centreon cancelled${STATUS_WARNING}"
      exit 0
  #else
    #VERSIONANC=${CENTREON_VER_OLD:0:2}
    #if (( $VERSIONANC < 20 )); then
    #  echo -e "Sorry update Centreon is not possible${STATUS_FAIL}"
    #  exit 0      
    #fi
  fi
fi
# backup old log file...
if [ -e "${INSTALL_LOG}" ] ; then
	mv "${INSTALL_LOG}" "${INSTALL_LOG}.`date +%Y%m%d-%H%M%S`"
fi
main
echo -e ""
echo -e "${bold}Go to http://${ETH0_IP}/centreon to complete the setup${normal} "
echo -e ""
