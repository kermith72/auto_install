#!/bin/bash
# install Nagvis
# v 1.61
# 20/04/2020
# 
#

# Variables
## Versions
VERSION_BATCH="v 1.61"
NAGVIS_VER="1.9.25"
## source script
DIR_SCRIPT=$(cd $( dirname ${BASH_SOURCE[0]}) && pwd )

## Sources URL
BASE_GITHUB="https://github.com/centreon"
NAGVIS_URL="http://www.nagvis.org/share/nagvis-${NAGVIS_VER}.tar.gz"


## Temp install dir
DL_DIR="/usr/local/src"
## Install dir
INSTALL_DIR="/usr/share"
## Log install file
INSTALL_LOG=${DL_DIR}"/nagvis-install.log"

ETH0_IP=$(/sbin/ip route get 8.8.8.8 | /usr/bin/awk 'NR==1 {print $7}')



# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} -n=[yes|no] -v

This program install nagvis for Centreon

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

function nagvis_install () {
  
  apt update >> ${INSTALL_LOG}
  apt install -y graphviz sqlite3 rsync git >> ${INSTALL_LOG}
  
  cd ${DL_DIR}
  if [[ -e nagvis-${NAGVIS_VER}.tar.gz ]] ;
  then
    echo 'File already exist !' | tee -a ${INSTALL_LOG}
  else
    wget ${NAGVIS_URL} -O ${DL_DIR}/nagvis-${NAGVIS_VER}.tar.gz >> ${INSTALL_LOG}
    [ $? != 0 ] && return 1
  fi
  tar xzf nagvis-${NAGVIS_VER}.tar.gz
  cd nagvis-${NAGVIS_VER}
  
  /bin/bash install.sh -q -n /usr/sbin -p ${INSTALL_DIR}/nagvis -u www-data -g www-data -w /etc/apache2/conf-available -a n

}

function nagvis_conf_apache () {
  
  #delete file nagvis.conf
if [ -e /etc/apache2/conf-available/nagvis.conf ] ;
  then
    echo 'File already exist !' | tee -a ${INSTALL_LOG}
  else
    rm /etc/apache2/conf-available/nagvis.conf >> ${INSTALL_LOG}
  fi
  
  #conf apache
  cat > /etc/apache2/conf-available/nagvis.conf <<EOF
# NagVis Apache2 sample configuration file
#
# #############################################################################

Alias /nagvis /usr/share/nagvis/share/

<LocationMatch ^/nagvis/(.*\.php(/.*)?)$>
  ProxyPassMatch fcgi://127.0.0.1:9043/usr/share/nagvis/share/\$1
</LocationMatch>
ProxyTimeout 300

<Directory "/usr/share/nagvis/share">
    DirectoryIndex index.php
    Options Indexes
    AllowOverride all
    Order allow,deny
    Allow from all
    Require all granted
    <IfModule mod_php5.c>
        php_admin_value engine Off
    </IfModule>

    AddType text/plain hbs
</Directory>

RedirectMatch ^/$ /nagvis
EOF

  #conf php-fpm
  cat > /etc/php/7.3/fpm/pool.d/nagvis.conf <<EOF
[nagvis]
user = www-data
group = www-data
listen = 127.0.0.1:9043
listen.allowed_clients = 127.0.0.1
pm = ondemand
pm.max_children = 30
pm.process_idle_timeout = 10s
pm.max_requests = 500
rlimit_files = 4096
php_admin_value[error_log] = /var/log/fpm-php.nagvis.log
php_admin_flag[log_errors] = on
php_value[session.save_handler] = files
php_value[session.save_path]    = /var/lib/centreon/sessions
EOF

 # reload conf apache
 a2enconf nagvis.conf >> ${INSTALL_LOG}
 systemctl restart apache2 php7.3-fpm >> ${INSTALL_LOG}
  
}

function backend_install () {

  cd ${DL_DIR}
  /usr/bin/git clone ${BASE_GITHUB}/centreon-nagvis-backend.git >> ${INSTALL_LOG}

  mv centreon-nagvis-backend/GlobalBackendcentreonbroker.php ${INSTALL_DIR}/nagvis/share/server/core/classes/ >> ${INSTALL_LOG}
  chown www-data: ${INSTALL_DIR}/nagvis/share/server/core/classes/GlobalBackendcentreonbroker.php >> ${INSTALL_LOG}
  chmod 664 ${INSTALL_DIR}/nagvis/share/server/core/classes/GlobalBackendcentreonbroker.php >> ${INSTALL_LOG}
  
  sed -i -e "s/extension_loaded('mysql')/extension_loaded('mysqli')/g" ${INSTALL_DIR}/nagvis/share/server/core/classes/GlobalBackendcentreonbroker.php
  sed -i -e "s/\$row\['has_been_checked'\]/isset(\$e) \&\& \$row\['has_been_checked'\]/g" ${INSTALL_DIR}/nagvis/share/server/core/classes/GlobalBackendcentreonbroker.php

  
  sed -i -e "s/get_error/get_error_nagvis/g" ${INSTALL_DIR}/nagvis/share/server/core/functions/html.php
  sed -i -e "s/debug(/debug_nagvis(/g" ${INSTALL_DIR}/nagvis/share/server/core/ext/php-gettext-1.0.12/gettext.inc
  sed -i -e "s/debug(/debug_nagvis(/g" ${INSTALL_DIR}/nagvis/share/server/core/classes/CoreAuthorisationHandler.php
  sed -i -e "s/debug(/debug_nagvis(/g" ${INSTALL_DIR}/nagvis/share/server/core/classes/GlobalLanguage.php
  sed -i -e "s/debug(/debug_nagvis(/g" ${INSTALL_DIR}/nagvis/share/server/core/classes/CoreAuthHandler.php
  sed -i -e "s/debug(/debug_nagvis(/g" ${INSTALL_DIR}/nagvis/share/server/core/classes/CorePDOHandler.php
  sed -i -e "s/debug(/debug_nagvis(/g" ${INSTALL_DIR}/nagvis/share/server/core/functions/debug.php
  sed -i -e "s/microtime_float(/microtime_float_nagis(/g" ${INSTALL_DIR}/nagvis/share/server/core/functions/debug.php

}

function nagvis_conf () {
	
  #delete demo conf
  rm -f ${INSTALL_DIR}/nagvis/etc/maps/*.cfg >> ${INSTALL_LOG}
  
  #conf nagvis
  cp ${DIR_SCRIPT}/nagvis/nagvis.ini.php ${INSTALL_DIR}/nagvis/etc/nagvis.ini.php  >> ${INSTALL_LOG}
  chown www-data:www-data ${INSTALL_DIR}/nagvis/etc/nagvis.ini.php
  chmod 664 ${INSTALL_DIR}/nagvis/etc/nagvis.ini.php
  
  #delete demo
  rm ${INSTALL_DIR}/nagvis/etc/conf.d/demo.ini.php
  
  #copy map
  cp ${DIR_SCRIPT}/nagvis/general.cfg ${INSTALL_DIR}/nagvis/etc/maps/
  cp ${DIR_SCRIPT}/nagvis/platCentreon.cfg ${INSTALL_DIR}/nagvis/etc/maps/
  chown www-data:www-data ${INSTALL_DIR}/nagvis/etc/maps/general.cfg
  chown www-data:www-data ${INSTALL_DIR}/nagvis/etc/maps/platCentreon.cfg
  chmod 660 ${INSTALL_DIR}/nagvis/etc/maps/general.cfg
  chmod 660 ${INSTALL_DIR}/nagvis/etc/maps/platCentreon.cfg
  
  #copy img
  cp ${DIR_SCRIPT}/nagvis/general.jpg ${INSTALL_DIR}/nagvis/share/userfiles/images/maps
  cp ${DIR_SCRIPT}/nagvis/platCentreon.jpg ${INSTALL_DIR}/nagvis/share/nagvis/userfiles/images/maps
  chown www-data:www-data ${INSTALL_DIR}/nagvis/share/userfiles/images/maps/general.jpg
  chown www-data:www-data ${INSTALL_DIR}/nagvis/share/userfiles/images/maps/platCentreon.jpg
  chmod 664 ${INSTALL_DIR}/nagvis/share/userfiles/images/maps/general.jpg
  chmod 664 ${INSTALL_DIR}/nagvis/share/userfiles/images/maps/platCentreon.jpg

  
  #extract mdp base
  mysql_password=$(/usr/bin/grep -i mysql_passwd /etc/centreon/conf.pm | /usr/bin/cut -f 3 -d " ")
  sed -i -e "s/dbpass=\"centreon\"/dbpass=\"${mysql_password:1:$((${#mysql_password}-3))}\"/g" ${INSTALL_DIR}/nagvis/etc/nagvis.ini.php
  

}

function nagvis_module_install () {
  
  cd ${DL_DIR}
  /usr/bin/git clone ${BASE_GITHUB}/centreon-nagvis.git >> ${INSTALL_LOG}
  
  cd centreon-nagvis
  rm www/modules/centreon-nagvis/sql/install.sql
  cp ${DIR_SCRIPT}/nagvis/install.sql www/modules/centreon-nagvis/sql/install.sql  >> ${INSTALL_LOG}
  sed -i -e "s/nagvis_session/PHPSESSID/g" ${INSTALL_DIR}/nagvis/share/server/core/defines/global.php
  
  mv www/modules/centreon-nagvis ${INSTALL_DIR}/centreon/www/modules/ >> ${INSTALL_LOG}
  	
}

function main () {
  echo "
====================| Nagvis Install details $VERSION_BATCH |=================
                  Nagvis     : ${NAGVIS_VER}
======================================================================
"	
  nagvis_install 2>> ${INSTALL_LOG} 
  if [[ $? -ne 0 ]];
    then
      echo -e "${bold}Step1${normal}  => Nagvis Install                          ${STATUS_FAIL}"
    else
      echo -e "${bold}Step1${normal}  => Nagvis Install                          ${STATUS_OK}"
  fi
  
  nagvis_conf_apache 2>> ${INSTALL_LOG} 
  if [[ $? -ne 0 ]];
    then
      echo -e "${bold}Step2${normal}  => Apache Configuration                         ${STATUS_FAIL}"
    else
      echo -e "${bold}Step2${normal}  => Apache Configuration                          ${STATUS_OK}"
  fi
  
  backend_install 2>> ${INSTALL_LOG} 
  if [[ $? -ne 0 ]];
    then
      echo -e "${bold}Step3${normal}  => Connector-Backend Installation                         ${STATUS_FAIL}"
    else
      echo -e "${bold}Step3${normal}  => Connector-Backend Installation                          ${STATUS_OK}"
  fi
  
  nagvis_conf 2>> ${INSTALL_LOG} 
  if [[ $? -ne 0 ]];
    then
      echo -e "${bold}Step3${normal}  => Nagvis configuration                         ${STATUS_FAIL}"
    else
      echo -e "${bold}Step3${normal}  => Nagvis configuration                          ${STATUS_OK}"
  fi
  
  nagvis_module_install 2>> ${INSTALL_LOG} 
  if [[ $? -ne 0 ]];
    then
      echo -e "${bold}Step3${normal}  => Nagvis Module install                         ${STATUS_FAIL}"
    else
      echo -e "${bold}Step3${normal}  => Nagvis Module install                          ${STATUS_OK}"
  fi
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


#######################################################################
#             PROGRAM
#######################################################################
#check menu# Exec main function
text_params

for i in "$@"
do
  case $i in
    -h|--help)
      show_help
      exit 2
      ;;
    *)
            # unknown option
    ;;
  esac
done

# Exec main function
text_params

# backup old log file...
if [ -e "${INSTALL_LOG}" ] ; then
	mv "${INSTALL_LOG}" "${INSTALL_LOG}.`date +%Y%m%d-%H%M%S`"
fi

main
echo -e ""
echo -e "${bold}Go to http://${ETH0_IP}/nagvis to complete the setup${normal} "
echo -e ""
