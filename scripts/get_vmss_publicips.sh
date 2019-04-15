#!/bin/bash

vmsid=$1
static_ips=$(echo "$2" | sed 's;/;\\/;g')

######################################################################################################
# This part of the script gets the public IP addresses of the VMSS and also the IPs we have configured in Terraform
######################################################################################################

ips=$(az vmss list-instance-public-ips --ids $vmsid --query '[].ipAddress' | jq -c ".")
full_ips=$(echo $ips | sed 's/"//g' | sed 's/\[//g' | sed 's/\]//g')
echo $full_ips,$static_ips
cat scripts/rules_locked.tfvars.template | sed "s/^\(.*source_address_prefixes.*=\).*$/\1 \"$full_ips,$static_ips\"/g" > rules_locked.tfvars

######################################################################################################
# This part of the script generates the Ansible inventory - it not pretty but works :)
######################################################################################################

cat scripts/inventory.template > ansible/inventory
az vmss list-instance-public-ips --ids $vmsid -o yaml | grep -E "fqdn|ipAddress" | sed 's/^.*fqdn: //g' | sed 's/^.*ipAddress: /ansible_host=/g' | sed 's/^\(^.*ansible_host.*$\)/\1 ansible_user=admin-user/g' | sed 'N;s/\n/ /' >> ansible/inventory