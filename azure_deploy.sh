#!/usr/bin/bash

source .env

# Create resource group 

##az group create --name "$RG_NAME" --location "$RG_LOCATION" --tags $RG_TAGS

# Create network security group and rules

##az network nsg create --name "$NSG_NAME" --resource-group "$RG_NAME" --tags $NSG_TAGS

##az network nsg rule create --resource-group "$RG_NAME" --nsg-name "$NSG_NAME" --priority 100 --name SSH --protocol Tcp --source-port-ranges '*' --description "SSH" --direction 'inbound' --access 'allow' --destination-port-ranges 22 --source-address-prefixes 'Internet' --destination-address-prefixes '*'
##az network nsg rule create --resource-group "$RG_NAME" --nsg-name "$NSG_NAME" --priority 101 --name ErlangPortMapper --protocol tcp --source-port-ranges '*' --description "Erlang Port Mapper (epmd)" --direction 'inbound' --access 'allow' --destination-port-ranges 4369 --source-address-prefixes 'Internet' --destination-address-prefixes '*'
##az network nsg rule create --resource-group "$RG_NAME" --nsg-name "$NSG_NAME" --priority 102 --name SyncGateway --protocol tcp --source-port-ranges '*' --description "Sync Gateway" --direction 'inbound' --access 'allow' --destination-port-ranges 4984-4985 --source-address-prefixes 'Internet' --destination-address-prefixes '*'
##az network nsg rule create --resource-group "$RG_NAME" --nsg-name "$NSG_NAME" --priority 103 --name Server --protocol tcp --source-port-ranges '*' --description "Server" --direction 'inbound' --access 'allow' --destination-port-ranges 8091-8096 --source-address-prefixes 'Internet' --destination-address-prefixes '*'
##az network nsg rule create --resource-group "$RG_NAME" --nsg-name "$NSG_NAME" --priority 104 --name Index --protocol tcp --source-port-ranges '*' --description "Index" --direction 'inbound' --access 'allow' --destination-port-ranges 9100-9105 --source-address-prefixes 'Internet' --destination-address-prefixes '*'
##az network nsg rule create --resource-group "$RG_NAME" --nsg-name "$NSG_NAME" --priority 105 --name Analytics --protocol tcp --source-port-ranges '*' --description "Analytics" --direction 'inbound' --access 'allow' --destination-port-ranges 9110-9122 --source-address-prefixes 'Internet' --destination-address-prefixes '*'
##az network nsg rule create --resource-group "$RG_NAME" --nsg-name "$NSG_NAME" --priority 106 --name Internal --protocol tcp --source-port-ranges '*' --description "Internal" --direction 'inbound' --access 'allow' --destination-port-ranges 9998-9999 --source-address-prefixes 'Internet' --destination-address-prefixes '*'
##az network nsg rule create --resource-group "$RG_NAME" --nsg-name "$NSG_NAME" --priority 107 --name XDCR --protocol tcp --source-port-ranges '*' --description "XDCR" --direction 'inbound' --access 'allow' --destination-port-ranges 11207-11215 --source-address-prefixes 'Internet' --destination-address-prefixes '*'
##az network nsg rule create --resource-group "$RG_NAME" --nsg-name "$NSG_NAME" --priority 108 --name SSL --protocol tcp --source-port-ranges '*' --description "SSL" --direction 'inbound' --access 'allow' --destination-port-ranges 18091-18096 --source-address-prefixes 'Internet' --destination-address-prefixes '*'
##az network nsg rule create --resource-group "$RG_NAME" --nsg-name "$NSG_NAME" --priority 109 --name NodeDataExchange --protocol tcp --source-port-ranges '*' --description "Node data exchange" --direction 'inbound' --access 'allow' --destination-port-ranges 21100-21299 --source-address-prefixes 'Internet' --destination-address-prefixes '*'

# Create virtual network

##az network vnet create --name $VNET_NAME --address-prefixes $VNET_PREFIX --resource-group $RG_NAME --subnet-name $VNET_SUB_NAME_1 --subnet-prefixes $VNET_SUB_PREFIX_1 --tags $VNET_TAGS


# Create storage account and container for the scripts

##az storage account create --resource-group $RG_NAME -l $RG_LOCATION --name $SACC_NAME --kind $SACC_KIND --sku $SACC_SKU 
##az storage container create --name extensions --account-name $SACC_NAME  --public-access blob

##az storage blob upload --file extensions/server.sh --container-name extensions --account-name $SACC_NAME --name "server.sh"
##az storage blob upload --file extensions/util.sh --container-name extensions --account-name $SACC_NAME --name "util.sh"
##az storage blob upload --file extensions/syncGateway.sh --container-name extensions --account-name $SACC_NAME --name "syncGateway.sh"

# Create scale sets

az vmss create --name $VMSS_NAME_1 --resource-group $RG_NAME --image $VMSS_VM_IMAGE_1 --instance-count $VMSS_INSTANCE_COUNT_1 --admin-username $VMSS_INSTANCE_USERNAME --nsg $NSG_NAME --tags $NSG_TAGS --vm-sku $VMSS_INSTANCE_SIZE_1 --disable-overprovision --data-disk-sizes-gb $VMSS_INSTANCE_DISK_SIZE_1 --public-ip-address-dns-name "$VMSS_NAME_1-$UNIQUE_STRING"

#az vmss stop --name $VMSS_NAME_1 --resource-group $RG_NAME

#az vmss extension set --vmss-name $VMSS_NAME_1 --publisher Microsoft.Azure.Extensions --version 2.0 --name CustomScript --resource-group $RG_NAME --settings '{ \"fileUris\": [\"https://cbstoragetmp.blob.core.windows.net/extensions/server.sh\",\"https://cbstoragetmp.blob.core.windows.net/extensions/util.sh\"], \"commandToExecute\": \"bash server.sh $CB_VERSION $CB_ADMIN_USER $CB_ADMIN_PASS $UNIQUE_STRING $RG_LOCATION" }'

az vmss extension set --vmss-name $VMSS_NAME_1 --publisher Microsoft.Azure.Extensions --version 2.0 --name CustomScript --resource-group $RG_NAME --settings "{ \"fileUris\": [\"https://cbhelpers.blob.core.windows.net/extensions/server.sh\",\"https://cbhelpers.blob.core.windows.net/extensions/util.sh\"], \"commandToExecute\": \"bash server.sh $CB_VERSION $CB_ADMIN_USER $CB_ADMIN_PASS $UNIQUE_STRING $RG_LOCATION\" }" --force-update

#az vmss start --name $VMSS_NAME_1 --resource-group $RG_NAME

az vmss create --name $VMSS_NAME_2 --resource-group $RG_NAME --image $VMSS_VM_IMAGE_2 --instance-count $VMSS_INSTANCE_COUNT_2 --admin-username $VMSS_INSTANCE_USERNAME --nsg $NSG_NAME --tags $NSG_TAGS --vm-sku $VMSS_INSTANCE_SIZE_2 --disable-overprovision --public-ip-address-dns-name $VMSS_NAME_2

az vmss extension set --vmss-name $VMSS_NAME_2 --publisher Microsoft.Azure.Extensions --version 2.0 --name CustomScript --resource-group $RG_NAME --settings "{ \"fileUris\": [\"https://cbhelpers.blob.core.windows.net/extensions/syncGateway.sh\",\"https://cbhelpers.blob.core.windows.net/extensions/util.sh\"], \"commandToExecute\": \"bash syncGateway.sh $SG_VERSION\" }" --force-update
