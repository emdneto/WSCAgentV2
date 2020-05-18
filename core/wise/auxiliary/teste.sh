#!/bin/bash
#
# Wan Slice Controller Agent - Access Network
# Fill the create, or delete yml files with the info about the ssids that you want to manage,
# and then run the script with one of the following options:
#
# 1 -> Create
# 2 -> Delete
#
# Example:
# ./WSCAgentAN.sh 1

# Import the auxiliary functions
source /usr/share/wise/auxiliary/common_all.sh
source /usr/share/wise/auxiliary/specific_an.sh


readonly SSID_LIMIT=8
readonly SSID_USED=$(uci show wireless | grep -c "wifi-iface")
readonly SSID_AVAILABLE=$((SSID_LIMIT - SSID_USED))
readonly NETWORK_NETMASK="255.255.255.0"
readonly OP=$1
readonly YAML_FILE=$2
# ------------------------------------------ Create ------------------------------------------ #
if [ "$OP" -eq "1" ]
then
  # Parsing yaml file to bash
  eval $(parse_yaml $YAML_FILE)

  if [ "$SSID_AVAILABLE" -gt 0 ]
  then

    wlan_name="w_$ssid_bridge_name"
    search_interface $ssid_bridge_name
    # Gets the exit status(return) of the search_interface()
    ssid_existence=$?    
    # Condition to verify the value of ssid_existence
    if [ "$ssid_existence" -eq "1" ] # TO DO: eliminate this comparison by only using the function return as a bool
    then
      echo -e "#----OK----#\nThe following Wifi Slice Part with SSID will be created: $ssid_name\n"

      configure_network $wlan_name $ssid_bridge_name $gateway_ip_address $NETWORK_NETMASK
      configure_ssid $wlan_name $ssid_name
      create_veth $ssid_port_name $ctrl_port_name

      reload_wifi

      configure_bridge_int $ctrl_bridge_name $ctrl_port_name $of_port
      set_qos_bridge_int $ctrl_port_name $bw_rate $bw_burst

      configure_dhcp $wlan_name $gateway_ip_range_start $gateway_ip_range_stop $gateway_ip_range_lease >> /dev/null
      configure_firewall $wlan_name

      configure_bridge_ssid $ssid_bridge_name $gateway_mac_address $wlan_name $ssid_port_name

      # Save and reload services to apply changes
      save_changes
      reload_wifi
      reload_dhcp

      echo -e "#----OK----#\nThe Wifi Slice Part with SSID was successfully created.\n"
    else
      echo -e "#----Error----#\nThe following Wifi Slice Part with SSID already exists: $ssid_name\nSkipping it's creation...\n"
      exit 1
    fi
  else
    echo "#----Error----#\nThere are no SSIDs available to be created."
    exit 1
    fi


# ------------------------------------------ Update ------------------------------------------ #
elif [ "$OP" -eq "2" ]
then
  # Parsing yaml file to bash
  eval $(parse_yaml $YAML_FILE)

  echo -e "#----OK----#\nThe Wifi Slice Part will be updated.\n"

  set_qos_bridge_int $ctrl_port_name $bw_rate $bw_burst

  save_changes
  echo -e "#----OK----#\nThe Wifi Slice Part was successfully updated.\n"


# ------------------------------------------ Delete ------------------------------------------ #
elif [ "$OP" -eq "3" ]
then
  # Parsing yaml file to bash
  eval $(parse_yaml $YAML_FILE)

  wlan_name="w_$ssid_bridge_name"

  search_interface $ssid_bridge_name
  # Gets the exit status(return) of the search_interface()
  ssid_existence=$?

  # Condition to verify the value of ssid_existence
  if [ "$ssid_existence" -eq 0 ]
  then
    echo -e "#----OK----#\nThe following Wifi Slice Part with SSID will be deleted: $ssid_name\n"

    delete_bridge_port $ctrl_bridge_name $ctrl_port_name
    delete_bridge $ssid_bridge_name
    delete_veth $ctrl_port_name

    delete_network_config $wlan_name
    delete_ssid $wlan_name
    delete_dhcp $wlan_name
    delete_firewall $wlan_name

    # Save and reload services to apply changes
    save_changes
    reload_wifi
    reload_dhcp

    echo -e "#----OK----#\nThe Wifi Slice Part with SSID was successfully deleted.\n"
  else
    echo -e "#----Error----#\nThe following Wifi Slice Part with SSID doesn't exist: $ssid_name\nSkipping it's deletion...\n"
  fi
else
  echo -e "#----Invalid option----#\nThe input must be:\n1 -> Create\n2 -> Update\n3 -> Delete\n"
fi
