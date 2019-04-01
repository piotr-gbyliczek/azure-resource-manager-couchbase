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
  ]
}

module "couchbase-nsg" {
  source              = "Azure/network-security-group/azurerm"
  version             = "1.1.1"
  security_group_name = "${var.short_name}-${var.suffix_nsg}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  location            = "${var.location}"
  custom_rules        = "${var.nsg-custom-rules}"
}

resource "azurerm_storage_account" "couchbase-storage" {
  name                     = "${random_string.unique-string.result}"
  resource_group_name      = "${azurerm_resource_group.resource_group.name}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  location            = "${var.location}"
}

resource "azurerm_storage_container" "couchbase-storage-container" {
  name                  = "extensions"
  resource_group_name   = "${azurerm_resource_group.resource_group.name}"
  storage_account_name  = "${azurerm_storage_account.couchbase-storage.name}"
  container_access_type = "container"
}

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


module "public-ip-couchbase" {
  source = "modules/public-ip"
  public_ip_name = "couchbase-public-ip"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  public_ip_domain_name   = "server-${random_string.unique-string.result}"
}

module "public-ip-syncgateway" {
  source = "modules/public-ip"
  public_ip_name = "syncgateway-public-ip"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  public_ip_domain_name   = "syncgateway-${random_string.unique-string.result}"
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
    admin-ui  = ["8091", "Tcp", "8091","SourceIP"]
  }
}

module "lb-syncgateway" {
  source              = "modules/loadbalancer"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  location            = "${var.location}"
  tags                = "${merge(var.default_tags, map("type","loadbalancer"))}"
  name                = "syncgateway-lb"
  type                = "public"
  public_ip_id        = "${module.public-ip-syncgateway.public_ip_id}"
  subnet_id           = "${element(module.application-subnets.vnet_subnet_names, 0)}"

  lb_port {
    ui  = ["4984", "Tcp", "4984","SourceIP"]
    admin-ui = ["4985", "Tcp", "4985","SourceIP"]
  }
}

module "vmss-couchbase" {
  source = "modules/virtual-machine-scale-set"
  virtual_machine_scale_set_name                = "${var.short_name}-server"
  virtual_machine_scale_set_location            = "${var.location}"
  virtual_machine_scale_set_resource_group      = "${azurerm_resource_group.resource_group.name}"
  virtual_machine_scale_set_load_balancer       = "${module.lb-couchbase.id}"
  virtual_machine_scale_set_vnet                = "${module.application-vnet.id}"

#  automatic_os_upgrade = false
#  upgrade_policy_mode  = "Manual"
#  overprovision        = false

#  sku {
#    #    name     = "Standard_DS12_v2"
#    name     = "Standard_B2ms"
#    tier     = "Standard"
#    capacity = 3
}



/*

resource "azurerm_virtual_machine_scale_set" "vmss-couchbase" {
  name                = "couchbase-server"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"

  automatic_os_upgrade = false
  upgrade_policy_mode  = "Manual"
  overprovision        = false

  sku {
    #    name     = "Standard_DS12_v2"
    name     = "Standard_B2ms"
    tier     = "Standard"
    capacity = 3
  }

  storage_profile_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.6"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  extension {
    name                 = "MSILinuxExtension"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    settings = <<SETTINGS
    {
        "fileUris": [
          "https://${azurerm_storage_account.couchbase-storage.name}.blob.core.windows.net/extensions/util.sh",
          "https://${azurerm_storage_account.couchbase-storage.name}.blob.core.windows.net/extensions/server.sh"
        ],
          "commandToExecute": "bash server.sh 6.0.1 admin securepassword uksouth data,index,query,fts,eventing ${random_string.unique-string.result}"
    }
SETTINGS
  }

  os_profile {
    computer_name_prefix = "couchbase-server"
    admin_username       = "node4"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/node4/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }

  network_profile {
    name                      = "couchbase-server--network-profile"
    primary                   = true
    network_security_group_id = "${module.couchbase-nsg.network_security_group_id}"

    ip_configuration {
      name                                   = "TestIPConfiguration"
      primary                                = true
      subnet_id                              = "${element(module.application-subnets.vnet_subnets, 0)}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.bpepool-couchbase.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${element(azurerm_lb_nat_pool.lbnatpool-couchbase.*.id, count.index)}"]

      public_ip_address_configuration {
        name              = "PublicIpAddress"
        idle_timeout      = 15
        domain_name_label = "couchbase-server-${random_string.unique-string.result}"
      }
    }
  }

  tags = {
    environment = "testing"
  }
}


resource "azurerm_virtual_machine_scale_set" "vmss-syncgateway" {
  name                = "syncgateway-server"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"

  automatic_os_upgrade = false
  upgrade_policy_mode  = "Manual"
  overprovision        = false

  sku {
    name     = "Standard_B2ms"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.6"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  extension {
    name                 = "MSILinuxExtension"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    settings = <<SETTINGS
    {
        "fileUris": [
          "https://${azurerm_storage_account.couchbase-storage.name}.blob.core.windows.net/extensions/syncGateway.sh",
          "https://${azurerm_storage_account.couchbase-storage.name}.blob.core.windows.net/extensions/util.sh"
        ],
          "commandToExecute": "bash syncGateway.sh 2.1.2"
    }
SETTINGS
  }

  os_profile {
    computer_name_prefix = "syncgateway-server"
    admin_username       = "node4"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/node4/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }

  network_profile {
    name                      = "syncgateway-network-profile"
    primary                   = true
    network_security_group_id = "${module.couchbase-nsg.network_security_group_id}"

    ip_configuration {
      name                                   = "TestIPConfiguration"
      primary                                = true
      subnet_id                              = "${element(module.application-subnets.vnet_subnets, 0)}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.bpepool-syncgateway.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${element(azurerm_lb_nat_pool.lbnatpool-syncgateway.*.id, count.index)}"]

      public_ip_address_configuration {
        name              = "PublicIpAddress"
        idle_timeout      = 15
        domain_name_label = "syncgateway-server-${random_string.unique-string.result}"
      }
    }
  }

  tags = {
    environment = "testing"
  }
}
*/
