#!/bin/bash
# =================================================================
# US_271 Book IP
# BNPP Multi Cloud Orchestration
# Input Params:
#   --ipamip - the IP Address or FQHN of the Infoblox Server
#   --user - the Userid to run commands on the Infoblox Server
#   --password - The password of the Infoblox User
#   --hostname - The hostname of the system to add to Infoblox database
#   --domain - The DNS domain to add register the hostname in
#   --network - The Subnetname in 0.0.0.0/24 format
#   --networkarray - a list of subnets in 0.0.0.0/24 format
# =================================================================

# set -x

# Get script parameters
while test $# -gt 0; do
  [[ $1 =~ ^-u|--user ]] && { PARAM_USER="${2}"; shift 2; continue; };
  [[ $1 =~ ^-p|--password ]] && { PARAM_PASSWORD="${2}"; shift 2; continue; };
  [[ $1 =~ ^-i|--ipamip ]] && { PARAM_IPAMIP="${2}"; shift 2; continue; };
  [[ $1 =~ ^-h|--hostname ]] && { PARAM_HOSTNAME="${2}"; shift 2; continue; };
  [[ $1 =~ ^-d|--domain ]] && { PARAM_DOMAIN="${2}"; shift 2; continue; };
  [[ $1 =~ ^-n|--network ]] && { PARAM_NETWORK="${2}"; shift 2; continue; };
  [[ $1 =~ ^-s|--dns ]] && { PARAM_DNS="${2}"; shift 2; continue; };
  [[ $1 =~ ^-m|--networkarray ]] && { PARAM_NETWORKARRAY="${2}"; shift 2; continue; };
  break;
done

if [ $PARAM_NETWORK != "" ] then
  if [ $PARAM_NETWORKARRAY != "" ] then
    # Error Can't have network array and network parmams
    echo "The --network and --networkarray parameters are mutually incompatible:" >&2
    exit 1
  else
    networks="mono"
    subnetNamelock=$(echo $PARAM_NETWORK | tr '/' '_')
  fi
else
  if [ PARAM_NETWORKARRAY != "" ] then
    networks="multi"
    subnetNamelock=$(echo $PARAM_NETWORKARRAY | tr '/' '_')
  else
    # Error either network or networkarray is needed
    echo "Either the --network or --networkarray parameter is required:" >&2
    exit 1
  fi
fi

ls /opt/BNPP/Infoblox/lock/$subnetNamelock.lock

if [ $? != 0 ] then
  echo "No Lock file found"
fi

address="fixed"

if [ $address == "null" ]; then
  error=`echo $curerespo | jq -r '.text'`
  if [ "$error" == "null" ]; then
    error=$curerespo
  fi
  echo "The request to retrieve an IP address from Infoblox failed. Error message: $error" >&2
  exit 1
fi

#echo $address
#echo $host
#echo $short_host
#echo $domain

return_result="{\"ipaddress\": \"${address}\", \"hostname\": \"${short_host}\",\"domain\": \"${domain}\"}"

echo $return_result
