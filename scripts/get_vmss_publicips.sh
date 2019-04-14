#!/bin/bash

vmsid=$1
static_ips=$(echo "$2" | sed 's;/;\\/;g')

ips=$(az vmss list-instance-public-ips --ids $vmsid --query '[].ipAddress' | jq -c ".")

full_ips=$(echo $ips | sed 's/"//g' | sed 's/\[//g' | sed 's/\]//g')
echo $full_ips,$static_ips

cat scripts/rules_locked.tfvars.template | sed "s/^\(.*source_address_prefixes.*=\).*$/\1 \"$full_ips,$static_ips\"/g" > rules_locked.tfvars