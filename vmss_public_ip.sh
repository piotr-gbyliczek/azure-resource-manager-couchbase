#!/usr/bin/bash

resourcegroupname=$1
vmssname=$2
static_ips='83.244.243.48\/28'

ips=$(az vmss list-instance-public-ips --resource-group $resourcegroupname --name $vmssname --query '[].ipAddress' | jq -c ".")

full_ips=$(echo $ips | sed 's/"//g' | sed 's/\[//g' | sed 's/\]//g')
echo $full_ips,$static_ips

cat rules_locked.tfvars.template | sed "s/^\(.*source_address_prefixes.*=\).*$/\1 \"$full_ips,$static_ips\"/g" > rules_locked.tfvars

echo "run terraform apply -var-file=\"rules_locked.tfvars\"" 


