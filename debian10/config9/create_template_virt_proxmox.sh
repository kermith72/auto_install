#!/bin/bash
# create_template_virt_proxmox.sh
# version 1.00
# 07/12/2020


create_cmd_virt_proxmox() {
       
  # Commandes  	
	

  # cmd_virt_proxmox_node
  exist_object CMD cmd_virt_proxmox_node
  [ $? -ne 0 ] && exec_clapi CMD ADD "cmd_virt_proxmox_node;check;\$CENTREONPLUGINS\$/centreon_proxmox_ve_restapi.pl --plugin apps::proxmox::ve::restapi::plugin --mode=node-usage --hostname=\$HOSTADDRESS\$ --api-username='\$_HOSTPROXMOXUSERNAME\$' --api-password='\$_HOSTPROXMOXPASSWORD\$' --proto='\$_HOSTPROXMOXPROTO\$' --port='\$_HOSTPROXMOXPORT\$' --realm='\$_HOSTPROXMOXREALM\$' \$_HOSTPROXMOXOPTIONS\$ --filter-name='\$_SERVICEFILTERNAME\$' --warning-cpu='\$_SERVICEWARNINGCPU\$' --critical-cpu='\$_SERVICECRITICALCPU\$' --warning-memory='\$_SERVICEWARNINGMEMORY\$' --critical-memory='\$_SERVICECRITICALMEMORY\$' --warning-swap='\$_SERVICEWARNINGSWAP\$' --critical-swap='\$_SERVICECRITICALSWAP\$' --warning-fs='\$_SERVICEWARNINGFS\$' --critical-fs='\$_SERVICECRITICALFS\$' \$_SERVICEOPTIONS\$"
  # cmd_virt_proxmox_storage
  exist_object CMD cmd_virt_proxmox_storage 
  [ $? -ne 0 ] && exec_clapi CMD ADD "cmd_virt_proxmox_storage;check;\$CENTREONPLUGINS\$/centreon_proxmox_ve_restapi.pl --plugin apps::proxmox::ve::restapi::plugin --mode=storage-usage --hostname=\$HOSTADDRESS\$ --api-username='\$_HOSTPROXMOXUSERNAME\$' --api-password='\$_HOSTPROXMOXPASSWORD\$' --proto='\$_HOSTPROXMOXPROTO\$' --port='\$_HOSTPROXMOXPORT\$' --realm='\$_HOSTPROXMOXREALM\$' \$_HOSTPROXMOXOPTIONS\$ --filter-name='\$_SERVICEFILTERNAME\$' --warning-storage='\$_SERVICEWARNINGSTORAGE\$' --critical-storage='\$_SERVICECRITICALSTORAGE\$' \$_SERVICEOPTIONS\$"

  # cmd_virt_proxmox_version
  exist_object CMD cmd_virt_proxmox_version
  [ $? -ne 0 ] && exec_clapi CMD ADD "cmd_virt_proxmox_version;check;\$CENTREONPLUGINS\$/centreon_proxmox_ve_restapi.pl --plugin apps::proxmox::ve::restapi::plugin --mode=version --hostname=\$HOSTADDRESS\$ --api-username='\$_HOSTPROXMOXUSERNAME\$' --api-password='\$_HOSTPROXMOXPASSWORD\$' --proto='\$_HOSTPROXMOXPROTO\$' --port='\$_HOSTPROXMOXPORT\$' --realm='\$_HOSTPROXMOXREALM\$' \$_HOSTPROXMOXOPTIONS\$ \$_SERVICEOPTIONS\$"

  # cmd_virt_proxmox_vm
  exist_object CMD cmd_virt_proxmox_vm
  [ $? -ne 0 ] && exec_clapi CMD ADD "cmd_virt_proxmox_vm;check;\$CENTREONPLUGINS\$/centreon_proxmox_ve_restapi.pl --plugin apps::proxmox::ve::restapi::plugin --mode=vm-usage --hostname=\$HOSTADDRESS\$ --api-username='\$_HOSTPROXMOXUSERNAME\$' --api-password='\$_HOSTPROXMOXPASSWORD\$' --proto='\$_HOSTPROXMOXPROTO\$' --port='\$_HOSTPROXMOXPORT\$' --realm='\$_HOSTPROXMOXREALM\$' \$_HOSTPROXMOXOPTIONS\$ --filter-name='\$_SERVICEFILTERNAME\$' --warning-cpu='\$_SERVICEWARNINGCPU\$' --critical-cpu='\$_SERVICECRITICALCPU\$' --warning-memory='\$_SERVICEWARNINGMEMORY\$' --critical-memory='\$_SERVICECRITICALMEMORY\$' --warning-traffic-in='\$_SERVICEWARNINGTRAFFICIN\$' --critical-traffic-in='\$_SERVICECRITICALTRAFFICIN\$' --warning-traffic-out='\$_SERVICEWARNINGTRAFFICOUT\$' --critical-traffic-out='\$_SERVICECRITICALTRAFFICOUT\$' --warning-read-iops='\$_SERVICEWARNINGREADIOPS\$' --critical-read-iops='\$_SERVICECRITICALREADIOPS\$' --warning-write-iops='\$_SERVICEWARNINGWRITEIOPS\$' --critical-write-iops='\$_SERVICECRITICALWRITEIOPS\$' \$_SERVICEOPTIONS\$"


}

create_stpl_virt_proxmox() {

  ## node
  #stpl_virt_proxmox_node
  exist_object STPL stpl_virt_proxmox_node
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_virt_proxmox_node;node-usage;service-generique-actif"
    exec_clapi STPL setparam "stpl_virt_proxmox_node;check_command;cmd_virt_proxmox_node"
    exec_clapi STPL setmacro "stpl_virt_proxmox_node;FILTERNAME;'.*'"
    exec_clapi STPL setmacro "stpl_virt_proxmox_node;WARNINGCPU;80"
    exec_clapi STPL setmacro "stpl_virt_proxmox_node;CRITICALCPU;90"
    exec_clapi STPL setmacro "stpl_virt_proxmox_node;WARNINGMEMORY;80"
    exec_clapi STPL setmacro "stpl_virt_proxmox_node;CRITICALMEMORY;90"
    exec_clapi STPL setmacro "stpl_virt_proxmox_node;WARNINGSWAP;50"
    exec_clapi STPL setmacro "stpl_virt_proxmox_node;CRITICALSWAP;70"
    exec_clapi STPL setmacro "stpl_virt_proxmox_node;WARNINGFS;80"
    exec_clapi STPL setmacro "stpl_virt_proxmox_node;CRITICALFS;90"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_virt_proxmox_node;icon_image;Other/cluster.png"
  fi


  ## storage
  #stpl_virt_proxmox_storage
  exist_object STPL stpl_virt_proxmox_storage
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_virt_proxmox_storage;storage-usage;service-generique-actif"
    exec_clapi STPL setparam "stpl_virt_proxmox_storage;check_command;cmd_virt_proxmox_storage"
    exec_clapi STPL setmacro "stpl_virt_proxmox_storage;FILTERNAME;'.*'"
    exec_clapi STPL setmacro "stpl_virt_proxmox_storage;WARNINGSTORAGE;80"
    exec_clapi STPL setmacro "stpl_virt_proxmox_storage;CRITICALSTORAGE;90"
    exec_clapi STPL setparam "stpl_virt_proxmox_storage;graphtemplate;Storage"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_virt_proxmox_storage;icon_image;Hardware/disque.png"
  fi

  ## version
  #stpl_virt_proxmox_version
  exist_object STPL stpl_virt_proxmox_version
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_virt_proxmox_version;version;service-generique-actif"
    exec_clapi STPL setparam "stpl_virt_proxmox_version;check_command;cmd_virt_proxmox_version"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_virt_proxmox_version;icon_image;Other/info3.png"
  fi
  
  ## vm
  #stpl_virt_proxmox_vm
  exist_object STPL stpl_virt_proxmox_vm
  if [ $? -ne 0 ]
  then
    exec_clapi STPL add "stpl_virt_proxmox_vm;vm-usage;service-generique-actif"
    exec_clapi STPL setparam "stpl_virt_proxmox_vm;check_command;cmd_virt_proxmox_vm"
    exec_clapi STPL setmacro "stpl_virt_proxmox_vm;FILTERNAME;'.*'"
    exec_clapi STPL setmacro "stpl_virt_proxmox_vm;WARNINGCPU;80"
    exec_clapi STPL setmacro "stpl_virt_proxmox_vm;CRITICALCPU;90"
    exec_clapi STPL setmacro "stpl_virt_proxmox_vm;WARNINGMEMORY;85"
    exec_clapi STPL setmacro "stpl_virt_proxmox_vm;CRITICALMEMORY;90"
    exec_clapi STPL setmacro "stpl_virt_proxmox_vm;OPTION;--use-name"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi STPL setparam "stpl_virt_proxmox_vm;icon_image;Hardware/vm.png"
  fi

}

create_virt_proxmox () {
  
  ##htpl_virt_proxmox
  exist_object HTPL htpl_virt_proxmox
  if [ $? -ne 0 ]
  then
    exec_clapi HTPL add "htpl_virt_proxmox;htpl_virt_proxmox;;;;"
    exec_clapi HTPL setmacro "htpl_virt_proxmox;PROXMOXPROTO;https"
    exec_clapi HTPL setmacro "htpl_virt_proxmox;PROXMOXPORT;8006"
    exec_clapi HTPL setmacro "htpl_virt_proxmox;PROXMOXREALM;pam"
    exec_clapi HTPL setmacro "htpl_virt_proxmox;PROXMOXUSERNAME;"
    exec_clapi HTPL setmacro "htpl_virt_proxmox;PROXMOXPASSWORD;"
    exec_clapi HTPL setmacro "htpl_virt_proxmox;PROXMOXOPTIONS;"
    exec_clapi STPL addhost "stpl_virt_proxmox_node;htpl_virt_proxmox"
    exec_clapi STPL addhost "stpl_virt_proxmox_storage;htpl_virt_proxmox"
    exec_clapi STPL addhost "stpl_virt_proxmox_version;htpl_virt_proxmox"
    exec_clapi STPL addhost "stpl_virt_proxmox_vm;htpl_virt_proxmox"
    exec_clapi HTPL addtemplate "htpl_virt_proxmox;generic-host"
    [ "$ADD_ICONE" == "yes" ] && exec_clapi HTPL setparam "htpl_virt_proxmox;icon_image;OS/proxmox.png"
  fi
}
