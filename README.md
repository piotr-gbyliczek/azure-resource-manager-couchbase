# ops-customer-whitespace-couchbase-deployment
fork of https://github.com/couchbase-partners/azure-resource-manager-couchbase


*Azure scripts require .env file with following details :*
```
RG_NAME='deployment_name'
RG_LOCATION='azure_region'
RG_TAGS='tag1=value1 tag2=value2'

NSG_NAME='nsg_name'
NSG_TAGS=''

VNET_NAME='vnet_name'
VNET_PREFIX='10.0.0.0/8'
VNET_SUB_NAME_1='subnet_1'
VNET_SUB_PREFIX_1='10.0.0.0/16'
VNET_TAGS=''

VMSS_NAME_1='set_name'
VMSS_VM_IMAGE_1='OpenLogic:CentOS:7.6:7.6.20181219'
VMSS_INSTANCE_SIZE_1='Standard_B1ms'
VMSS_INSTANCE_COUNT_1=3
VMSS_INSTANCE_DISK_SIZE_1=20

VMSS_NAME_2='set_name'
VMSS_VM_IMAGE_2='OpenLogic:CentOS:7.6:7.6.20181219'
VMSS_INSTANCE_SIZE_2='Standard_B1ms'
VMSS_INSTANCE_COUNT_2=2

VMSS_INSTANCE_USERNAME='admin_user_name'

CB_VERSION='6.0.1'
CB_ADMIN_USER='admin'
CB_ADMIN_PASS='securepassword'
SG_VERSION='2.1.2'
UNIQUE_STRING='random-string'

SACC_NAME='cbhelpers'
SACC_KIND='StorageV2'
SACC_SKU='Standard_ZRS'
```
