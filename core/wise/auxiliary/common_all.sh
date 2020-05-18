#!/bin/bash
#
# This file keeps the common functions used by the Access Network, Data Center and DC WSC Agents.
# The functions are classified in the follwing types:
#
# Auxiliary -> Function to help the parsing of yaml files and to check if an interface exists.
# Network and OVS -> Functions responsible for the management of Network and OVS bridges configuration.
#
# ------------------------ Auxiliary ------------------------ #
#
## Parses an input yaml file to bash, creating variables
## named as the keys in the yaml file and with an underscore as a prefix
parse_yaml()
{
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

search_interface()
{
  local interface=$1
  ifconfig $interface >> /dev/null 2>> /dev/null
  if [ "$?" -eq "0" ]
  then
    return 0
  else
    return 1
  fi
}

reload_network()
{
  /etc/init.d/network reload
}

# ---------------------- Network, OVS and Veth -------------------- #

## Parameters: br_int, pt_bt_int, of_pt
configure_bridge_int()
{
  local br_int=$1
  local pt_br_int=$2
  local of_pt=$3
  ovs-vsctl add-port $br_int $pt_br_int -- set Interface $pt_br_int ofport_request=$of_pt
}

## Parameters: pt_br_int, bw_rate, bw_burst
set_qos_bridge_int()
{
  local pt_br_int=$1
  local bw_rate=$2
  local bw_burst=$3
  ovs-vsctl set interface $pt_br_int ingress_policing_rate=$bw_rate
  ovs-vsctl set interface $pt_br_int ingress_policing_burst=$bw_burst
}

## Parameters: br_name, port_name
delete_bridge_port()
{
  local br_name=$1
  local port_name=$2
  ovs-vsctl del-port $br_name $port_name
}

## Parameters: br_name
delete_bridge()
{
  local br_name=$1
  ovs-vsctl del-br $br_name
}

## Parameters: veth_br_ssid, veth_br_int
create_veth()
{
  local veth_br_ssid=$1
  local veth_br_int=$2
  ip link add $veth_br_ssid type veth peer name $veth_br_int
  ip link set $veth_br_ssid up && ip link set $veth_br_int up
}

## Parameters: veth_name
delete_veth()
{
  local veth_name=$1
  ip link delete $veth_name
}