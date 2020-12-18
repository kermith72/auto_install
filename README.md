# auto_install
Automated installation of Centreon on Debian with sources

See [the explanation page](https://www.sugarbug.fr/atelier/installations/debian/centreon-install/centreon-install_2004-Buster/)

## tags
git clone https://github.com/kermith72/auto_install.git

cd auto_install

git checkout v1.x

### version 1.58
Update monitoring-plugins 2.3

add template lm-sensors

new scripts for Raspberry OS : centreon_central_raspbian_2004.sh and centreon_poller_raspbian_2004.sh


### version 1.57
new script for centreon_central_2010.sh and centreon_poller_2010.sh

centreon-web 19.10.7, broker 20.04.10, gorgone 20.04.7

add template proxmox


### version 1.56
centreon-engine 20.04.7, broker 20.04.9, gorgone 20.04.6, web 20.04.7

centreon-web 19.10.16

centreon-web 19.04.20

bugfix PHP composer and issue #12

### version 1.55
centreon-engine 20.04.5, broker 20.04.8, gorgone 20.04.4, web 20.04.5

centreon-engine 19.10.15, web 19.10.15

centreon-engine 19.04.18

### version 1.54
centreon-engine 20.04.4, broker 20.04.7, web 20.04.4

new script create_config_initialV8.sh for plugins 20.04.0 (plugin 20200803)

### version 1.53
centreon-engine 19.10.14, broker 19.10.5, engine 19.10.14

### version 1.52
centreon-engine 20.04.2, broker 20.04.4, engine 20.04.1

new script create_config_initialV7.sh for plugins 20.04.0

### version 1.51
new script for centreon_central_2004.sh and centreon_poller_2004.sh

centreon-engine 20.04.1, broker 20.04.2, gorgone 20.04.2

new function update for 24.04.x see [the explanation page](https://www.sugarbug.fr/blog/files/script-auto-maj2.html)

**Warning update 19.10 -> 20.04 not fonctionnal**

### version 1.50
new script for centreon_central_1910.sh and centreon_poller_1910.sh

centreon-engine 19.10.14

new function update for 19.10.x see [the explanation page](https://www.sugarbug.fr/blog/files/script-auto-maj.html)

### version 1.49
new scripts for 20.04.0

centreon-web 20.04.0, engine 20.04, broker 20.04 an new centreon-gorgone 20.04

new script create_config_initialV6.sh for plugins 20.04.0

### version 1.48
update widget for 19.04 and 19.10
See [the explanation page](https://www.sugarbug.fr/atelier/installations/debian/centreon-install/centreon-install_1910-Buster/)

### version 1.47
centreon-web 19.10.10 and 19.04.13, centreon-engine 19.10.13, connector 19.10.1

new script create_config_initialV5.sh for template windows NRPE

### version 1.46
centreon-web 19.10.08, centreon-engine 19.10.12, add template linux-remote

update scripts 19.04 and 18.10 for Debian Stretch, update widget

### version 1.45
centreon-web 19.10.07 & 19.04.10, centreon-broker 19.10.3, centreon-engine 19.10.11

### version 1.44
centreon-web 19.10.6 & 19.04.9, centreon-engine 19.10.10

### version 1.43
centreon-web 19.10.5 & 19.04.8, centreon-engine 19.10.9, clib 19.04.1

new script create_config_initialV5.sh for plugins 20191219 (windows and cisco)

### version 1.42
centreon-web 19.10.4 & 19.04.7, centreon-engine 19.10.8 & 19.04.2, broker 19.10.2, plugins 20191219 

new script create_config_initialV5.sh for plugins 20191219

### version 1.41
centreon-web 19.10.3 & 19.04.6, centreon-engine 19.10.7 

modify script functions for api Rest V2

### version 1.40
bugfix create centcore for send external command to Poller issue #5

### version 1.39
centreon-engine 19.10.6, centreon-broker 19.10.1

add scripts for Raspbian

### version 1.38
centreon-engine 19.10.5, bugfix widget Tactical-overview for centreon 19.10

add check_nrpe for poller for Centreon 19.10

### version 1.37
bug fix statistic engine for centreon 19.10

### version 1.36
centreon-engine 19.10.3, widget service-monitoring 19.10.1 for Buster

### version 1.35
centreon-engine 19.10.1 for Buster

### version 1.34
centreon 19.10 for Buster

plugin Centreon fastpacked 20191016 for 19.04 and bugfix plugin mysql

### version 1.33
update script create_config_initialV4.sh, add debug function

Add scripts for Debian Buster

Add Pack Icônes of Pixelabs (https://pixelabs.fr)

plugin Centreon fastpacked 20191002 for 19.04 and bugfix plugin mysql

### version 1.32
centreon web 19.04.4 for Stretch

centreon web 18.10.7 for Stretch


### version 1.31
centreon engine 19.04.1, web 19.04.3 for Stretch

centreon web 18.10.6 for Stretch


### version 1.30
centreon web 18.10.5 for Stretch

plugin Centreon fastpacked for Stretch, new script create_config_initialV4.sh

### version 1.29
new script centreon_central_1810 and centreon_central_1904

add cgroup centreon

### version 1.28
bux-fix snmp, add check_nrpe for central, new script 3.1 configuration create_config_initialV3.sh

### version 1.27
new script for Debian Stretch, new script configuration create_config_initialV3.sh

centreon web 18.10.4 for Stretch

### version 1.26
bug-fix widgets top10 and scripts php 

### version 1.25
new script create_config_initialV2-1.sh for debian 9

### version 1.24
centreon-widget-service-monitoring 18.10.2

centreon-widget-host-monitoring 18.10.1

### version 1.23
centreon web 18.10.3

### version 1.22
bug-fix _CENTREON_PATH_PLACEHOLDER_ in index.html

bug-fix install poller for Debian 9

bug-fix script create_config_initialV2.sh

### version 1.21
add versionning in centreon-plugins

### version 1.20
add versionning in README - add package for Pear site down

### version 1.19
centreon engine 18.10.0, broker 18.10.1, web 18.10.2

### version 1.18
centreon web 2.8.26

### Version 1.17
centreon web 2.8.25 add files Header

### Version 1.16
centreon web 2.8.24 add perl centreon-plugins

### Version 1.15
centreon engine 1.8.1, broker 3.0.14, web 2.8.24

### Version 1.14
centreon engine 1.8.1, broker 3.0.14, web 2.8.23

### Version 1.13
centreon engine 1.8.1, broker 3.0.14, web 2.8.22

### Version 1.12
centreon engine 1.8.1, broker 3.0.14, web 2.8.21 

### Version 1.11
centreon engine 1.8.1, broker 3.0.13, web 2.8.19

fix poller installation

### Version 1.10
centreon engine 1.8.1, broker 3.0.13, web 2.8.19

### Version 1.09
centreon engine 1.8.1, broker 3.0.13, web 2.8.18

### Version 1.08
centreon engine 1.8.1, broker 3.0.11, web 2.8.17

### Version 1.07
centreon engine 1.8.1, broker 3.0.11, web 2.8.16

### Version 1.06
centreon engine 1.8.0, broker 3.0.10, web 2.8.15

add poller debian strech

### Version 1.05
centreon engine 1.8.0, broker 3.0.10, web 2.8.15

### Version 1.04
centreon engine 1.8.0, broker 3.0.9, web 2.8.14

### Version 1.03
centreon engine 1.7.2, broker 3.0.9, web 2.8.12

### Version 1.02
centreon engine 1.7.2, broker 3.0.8, web 2.8.12

### Version 1.01
centreon engine 1.7.2, broker 3.0.8, web 2.8.9

### Version 1.00
centreon engine 1.7.2, broker 3.0.7, web 2.8.9
