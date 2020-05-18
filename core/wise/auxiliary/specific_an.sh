#!/bin/bash
#
# This file keeps the specific functions used by the Access Network Agent.
# The functions are classified in the follwing types:
#
# Auxiliary -> Functions to save and apply changes.
# Network, SSID and OVS -> Functions responsible for the management of Network, SSID and OVS bridges configurations.
# Services -> Functions responsible for configure DHCP and Firewall.
#
# ------------------------ Auxiliary ------------------------ #
#
## Parses an input yaml file to bash, creating variables
## named as the keys in the yaml file and with an underscore as a prefix

save_changes()
{
  uci commit
}

reload_wifi()
{
  wifi reload
}

reload_dhcp()
{
  /etc/init.d/dnsmasq reload
}

# ----------------- Network, SSID and OVS ----------------- #

## Parameters: network_name, bridge_name, ip_addr, netmask
configure_network()
{
  local network_name=$1
  local bridge_name=$2
  local ip_addr=$3
  local netmask=$4
  uci batch << EOL
  set network.$network_name=interface
  set network.$network_name.ifname=$bridge_name
  set network.$network_name.proto=static
  set network.$network_name.ipaddr=$ip_addr
  set network.$network_name.netmask=$netmask
EOL
}

## Parameters: config_name
delete_network_config()
{
  local config_name=$1
  uci delete network.$config_name
}

## Parameters: br_ssid, mac_addr, wlan_interface, ssid_pt
configure_bridge_ssid()
{
  local br_ssid=$1
  local mac_addr=$2
  local wlan_interface=$3
  local ssid_pt=$4
  ovs-vsctl add-br $br_ssid -- set-fail-mode $br_ssid standalone
  ovs-vsctl set bridge $br_ssid other-config:hwaddr=$mac_addr
  ip link set $br_ssid up
  ovs-vsctl add-port $br_ssid $ssid_pt
  ovs-vsctl add-port $br_ssid $wlan_interface
}

## Parameters: wifi_name, ssid_name
configure_ssid()
{
  local wifi_name=$1
  local ssid_name=$2
  local wlan_interface=$wifi_name
  local net_name=$wifi_name
  uci batch << EOL
  set wireless.$wifi_name=wifi-iface
  set wireless.$wifi_name.device=radio0
  set wireless.$wifi_name.ifname=$wlan_interface
  set wireless.$wifi_name.mode=ap
  set wireless.$wifi_name.network=$net_name
  set wireless.$wifi_name.ssid=$ssid_name
  set wireless.$wifi_name.encryption=none
EOL
  reload_wifi
}

## Parameters: wifi_name
delete_ssid()
{
  local wifi_name=$1
  uci delete wireless.$wifi_name
}


# --------------------- Services(Firewall and DHCP) --------------------- #

# Configure DHCP for SSID network
# Parameters: dhcp_name, dhcp_start, dhcp_limit, dhcp_lease
configure_dhcp()
{
  local dhcp_name=$1
  local dhcp_start=$2
  local dhcp_limit=$3
  local dhcp_lease=$4
  local net_name=$dhcp_name
  uci batch << EOL
  set dhcp.$dhcp_name=dhcp
  set dhcp.$dhcp_name.interface=$net_name
  set dhcp.$dhcp_name.start=$dhcp_start
  set dhcp.$dhcp_name.limit=$dhcp_limit
  set dhcp.$dhcp_name.leasetime=$dhcp_lease
EOL
}

## Parameters: dhcp_name
delete_dhcp()
{
  local dhcp_name=$1
  uci delete dhcp.$dhcp_name
}

# Configure the SSID's firewall zone and DHCP rule
# Parameters: net_name
configure_firewall()
{
  local net_name=$1
  local prefix_name=$1
  local zone_name="$prefix_name"_zone
  local rule_name="$prefix_name"_rule_dhcp
  uci batch << EOL
  set firewall.$zone_name=zone
  set firewall.$zone_name.name=$zone_name
  set firewall.$zone_name.network=$net_name
  set firewall.$zone_name.input=ACCEPT
  set firewall.$zone_name.forward=ACCEPT
  set firewall.$zone_name.output=ACCEPT
EOL
  # Allow DHCP SSID -> Router
  uci batch << EOL
  set firewall.$rule_name=rule
  set firewall.$rule_name.name='Allow DHCP request'
  set firewall.$rule_name.src=$net_name
  set firewall.$rule_name.src_port=68
  set firewall.$rule_name.dest_port=67
  set firewall.$rule_name.proto=udp
  set firewall.$rule_name.target=ACCEPT
EOL
}

delete_firewall()
{
  local prefix_name=$1
  local zone_name="$prefix_name"_zone
  local rule_name="$prefix_name"_rule_dhcp
  uci delete firewall."$wlan_name"_zone
  uci delete firewall."$wlan_name"_rule_dhcp
}
