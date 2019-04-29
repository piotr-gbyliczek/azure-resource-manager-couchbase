######################################################################################################
# Local Setup
######################################################################################################

# What is the minimum version of Terraform we need?
terraform {
  required_version = ">= 0.11.0"
}

#################
# If you are not using the Azure CLI then you will need to create a service principle,
# fill the details in secrets.tf file (see sample) which is .gitignored
# For more information on creating the service principle see the following URL;
# https://www.terraform.io/docs/providers/azurerm/auth/service_principal_client_secret.html
#################
# provider "azurerm" {
#   subscription_id = "${var.subscription_id}"
#   client_id       = "${var.client_id}"
#   client_secret   = "${var.client_secret}"
#   tenant_id       = "${var.tenant_id}"
# }

######################################################################################################
# Enviroment Setup
######################################################################################################

#################
# Create the resource group, using a resource here rather
# than a module to allow the group to be created before
# we run anything else.
#################
resource "azurerm_resource_group" "resource_group" {
  name     = "${var.long_name}-${var.suffix_resource-group}"
  location = "${var.location}"
  tags     = "${merge(var.default_tags, map("type","resource"))}"
}

resource "random_string" "unique-string" {
  length  = 20
  special = false
  upper   = false
}

######################################################################################################
# Network Setup
######################################################################################################

#################
# Create the VNET
#################
module "application-vnet" {
  source              = "modules/vnet"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  location            = "${var.location}"
  tags                = "${merge(var.default_tags, map("type","network"))}"
  vnet_name           = "${var.long_name}-${var.suffix_vnet}"
  address_space       = "10.11.0.0/16"
}

#################
# Create the Subnets
#################
module "application-subnets" {
  source              = "modules/subnet"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  location            = "${var.location}"
  tags                = "${var.default_tags}"
  vnet_name           = "${module.application-vnet.vnet_name}"

  subnets = [
    {
      # This will be subnet 1
      name   = "${var.short_name}-app-${var.suffix_subnet}"
      prefix = "10.11.2.0/24"
    },
    {
      # This will be subnet 2
      name   = "${var.short_name}-appgw-${var.suffix_subnet}"
      prefix = "10.11.3.0/24"
    },
  ]
}

#################
# Create the Inital NSG
#################
module "couchbase-nsg" {
  source              = "modules/network-security-group"
  name                = "${var.short_name}-${var.suffix_nsg}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  location            = "${var.location}"
  rules_open          = "${var.nsg-rules-open}"
  rules_locked_down   = "${var.nsg-rules-locked}"
}

######################################################################################################
# Storage Setup
######################################################################################################

#################
# Create the Storage Account
#################
resource "azurerm_storage_account" "couchbase-storage" {
  name                     = "${random_string.unique-string.result}"
  resource_group_name      = "${azurerm_resource_group.resource_group.name}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  location                 = "${var.location}"
}

#################
# Create the Storage Container
#################
resource "azurerm_storage_container" "couchbase-storage-container" {
  name                  = "extensions"
  resource_group_name   = "${azurerm_resource_group.resource_group.name}"
  storage_account_name  = "${azurerm_storage_account.couchbase-storage.name}"
  container_access_type = "container"
}

#################
# Upload the extention scripts
#################
resource "azurerm_storage_blob" "blob1" {
  name                   = "server.sh"
  source                 = "extensions/server.sh"
  type                   = "block"
  resource_group_name    = "${azurerm_resource_group.resource_group.name}"
  storage_account_name   = "${azurerm_storage_account.couchbase-storage.name}"
  storage_container_name = "${azurerm_storage_container.couchbase-storage-container.name}"
}

resource "azurerm_storage_blob" "blob2" {
  name                   = "util.sh"
  source                 = "extensions/util.sh"
  type                   = "block"
  resource_group_name    = "${azurerm_resource_group.resource_group.name}"
  storage_account_name   = "${azurerm_storage_account.couchbase-storage.name}"
  storage_container_name = "${azurerm_storage_container.couchbase-storage-container.name}"
}

resource "azurerm_storage_blob" "blob3" {
  name                   = "syncGateway.sh"
  source                 = "extensions/syncGateway.sh"
  type                   = "block"
  resource_group_name    = "${azurerm_resource_group.resource_group.name}"
  storage_account_name   = "${azurerm_storage_account.couchbase-storage.name}"
  storage_container_name = "${azurerm_storage_container.couchbase-storage-container.name}"
}

######################################################################################################
# Couchbase Cluster
######################################################################################################

module "public-ip-couchbase" {
  source                = "modules/public-ip"
  public_ip_name        = "couchbase-public-ip"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.resource_group.name}"
  public_ip_domain_name = "${var.short_name}-server-${random_string.unique-string.result}"
}

module "lb-couchbase" {
  source              = "modules/loadbalancer"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  location            = "${var.location}"
  tags                = "${merge(var.default_tags, map("type","loadbalancer"))}"
  name                = "couchbase-lb"
  type                = "public"
  public_ip_id        = "${module.public-ip-couchbase.public_ip_id}"
  subnet_id           = "${element(module.application-subnets.vnet_subnet_names, 0)}"

  lb_port {
    admin-ui = ["8091", "Tcp", "8091", "SourceIP"]
    admin-ui-ssl = ["18091", "Tcp", "18091", "SourceIP"]
  }
}

module "vmss-couchbase" {
  source                                             = "modules/virtual-machine-scale-set"
  type                                               = "lb"
  virtual_machine_scale_set_name                     = "${var.short_name}-server"
  virtual_machine_scale_set_location                 = "${var.location}"
  virtual_machine_scale_set_resource_group           = "${azurerm_resource_group.resource_group.name}"
  virtual_machine_scale_set_network_security_group   = "${module.couchbase-nsg.network_security_group_id}"
  virtual_machine_scale_set_load_balancer_backend_id = "${module.lb-couchbase.lb_backend_address_pool_id}"
  virtual_machine_scale_set_vnet                     = "${module.application-vnet.vnet_name}"
  virtual_machine_scale_set_vnet_subnets             = "${module.application-subnets.vnet_subnets[0]}"
  virtual_machine_scale_set_unique_string            = "${random_string.unique-string.result}"

  virtual_machine_scale_set_extension_settings_fileuris = [
    "https://${azurerm_storage_account.couchbase-storage.name}.blob.core.windows.net/extensions/util.sh",
    "https://${azurerm_storage_account.couchbase-storage.name}.blob.core.windows.net/extensions/server.sh",
  ]

  virtual_machine_scale_set_extension_settings_command_to_execute = "bash server.sh ${var.couchbase_version} ${var.couchbase_username} ${var.couchbase_password} ${var.location} data,index,query,fts,eventing ${random_string.unique-string.result}"
  virtual_machine_scale_set_size                                  = 3
  virtual_machine_storage_data_disk_size                          = 32
}

######################################################################################################
# SyncGateway
######################################################################################################
module "public-ip-syncgateway" {
  source                = "modules/public-ip"
  public_ip_name        = "syncgateway-public-ip"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.resource_group.name}"
  public_ip_domain_name = "syncgateway-${random_string.unique-string.result}"
}

module "ag-syncgateway" {
  source              = "modules/application-gateway"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  location            = "${var.location}"
  tags                = "${merge(var.default_tags, map("type","applicationgateway"))}"
  name                = "syncgateway-ag"
  public_ip_id        = "${module.public-ip-syncgateway.public_ip_id}"
  subnet_id           = "${module.application-subnets.vnet_subnets[1]}"

  ag_port {
    ui       = ["4984"]
    admin-ui = ["4985"]
  }
}

module "vmss-syncgateway" {
  source                                           = "modules/virtual-machine-scale-set"
  type                                             = "ag"
  virtual_machine_scale_set_name                   = "${var.short_name}-syncgateway"
  virtual_machine_scale_set_location               = "${var.location}"
  virtual_machine_scale_set_resource_group         = "${azurerm_resource_group.resource_group.name}"
  virtual_machine_scale_set_network_security_group = "${module.couchbase-nsg.network_security_group_id}"
  application_gateway_backend_address_pool_id      = "${module.ag-syncgateway.backend_address_pool}"
  virtual_machine_scale_set_vnet                   = "${module.application-vnet.vnet_name}"
  virtual_machine_scale_set_vnet_subnets           = "${module.application-subnets.vnet_subnets[0]}"
  virtual_machine_scale_set_unique_string          = "${random_string.unique-string.result}"

  virtual_machine_scale_set_extension_settings_fileuris = [
    "https://${azurerm_storage_account.couchbase-storage.name}.blob.core.windows.net/extensions/syncGateway.sh",
    "https://${azurerm_storage_account.couchbase-storage.name}.blob.core.windows.net/extensions/util.sh",
  ]

  virtual_machine_scale_set_extension_settings_command_to_execute = "bash syncGateway.sh 2.1.2"
  virtual_machine_scale_set_size                                  = 2
}

######################################################################################################
# Create the locked down rules and Ansible inv - don't forget to re-run Terraform to lock it down
######################################################################################################
resource "null_resource" "vmss_couchbase_public_ips" {
  triggers {
    build_number = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "bash scripts/get_vmss_publicips.sh '${join(", ", module.vmss-couchbase.virtual_machine_scale_set_id)}' '${var.static_ips}' '${join(", ", module.vmss-syncgateway.virtual_machine_scale_set_id)}'"
  }
}
