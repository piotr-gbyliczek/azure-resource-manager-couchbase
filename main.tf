resource "azurerm_resource_group" "rgroup" {
  name     = "couchbase-deployment"
  location = "uksouth"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "couchbase-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.rgroup.location}"
  resource_group_name = "${azurerm_resource_group.rgroup.name}"
}

resource "azurerm_subnet" "subnet1" {
  name                 = "couchbase-subnet"
  resource_group_name  = "${azurerm_resource_group.rgroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "couchbase-nsg"
  location            = "${azurerm_resource_group.rgroup.location}"
  resource_group_name = "${azurerm_resource_group.rgroup.name}"
}

resource "azurerm_network_security_rule" "nsg-rule-ssh" {
  name                        = "SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rgroup.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}
resource "azurerm_network_security_rule" "nsg-rule-epm" {
  name                        = "ErlangPortMapper"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "4369"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rgroup.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}
resource "azurerm_network_security_rule" "nsg-rule-sync" {
  name                        = "SyncGateway"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "4984-4985"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rgroup.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}
resource "azurerm_network_security_rule" "nsg-rule-server" {
  name                        = "Server"
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8091-8096"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rgroup.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}
resource "azurerm_network_security_rule" "nsg-rule-index" {
  name                        = "Index"
  priority                    = 104
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9100-9105"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rgroup.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}
resource "azurerm_network_security_rule" "nsg-rule-analytics" {
  name                        = "Analytics"
  priority                    = 105
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9110-9122"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rgroup.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}
resource "azurerm_network_security_rule" "nsg-rule-int" {
  name                        = "Internal"
  priority                    = 106
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9998-9999"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rgroup.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}
resource "azurerm_network_security_rule" "nsg-rule-xdcr" {
  name                        = "XDCR"
  priority                    = 107
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "11207-11215"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rgroup.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}
resource "azurerm_network_security_rule" "nsg-rule-ssl" {
  name                        = "SSL"
  priority                    = 108
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "18091-18096"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rgroup.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}
resource "azurerm_network_security_rule" "nsg-rule-nde" {
  name                        = "NodeDataExchange"
  priority                    = 109
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "21100-21299"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rgroup.name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}

resource "azurerm_public_ip" "public-ip-couchbase" {
  name                = "couchbase-public-ip"
  location            = "${azurerm_resource_group.rgroup.location}"
  resource_group_name = "${azurerm_resource_group.rgroup.name}"
  allocation_method   = "Dynamic"
  domain_name_label   = "couchbase-server"
}

resource "azurerm_lb" "lb-couchbase" {
  name                = "couchbase-lb"
  location            = "${azurerm_resource_group.rgroup.location}"
  resource_group_name = "${azurerm_resource_group.rgroup.name}"

  frontend_ip_configuration {
    name                 = "CouchbasePublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.public-ip-couchbase.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool-couchbase" {
  resource_group_name = "${azurerm_resource_group.rgroup.name}"
  loadbalancer_id     = "${azurerm_lb.lb-couchbase.id}"
  name                = "CouchbaseBackendAddressPool"
}

resource "azurerm_lb_nat_pool" "lbnatpool-couchbase" {
  count                          = 3
  resource_group_name            = "${azurerm_resource_group.rgroup.name}"
  name                           = "ssh"
  loadbalancer_id                = "${azurerm_lb.lb-couchbase.id}"
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "CouchbasePublicIPAddress"
}

resource "azurerm_lb_probe" "probe-couchbase" {
  resource_group_name = "${azurerm_resource_group.rgroup.name}"
  loadbalancer_id     = "${azurerm_lb.lb-couchbase.id}"
  name                = "couchbase-probe-admin-ui"
  port                = 8091
}

resource "azurerm_lb_rule" "rule-couchbase" {
  resource_group_name            = "${azurerm_resource_group.rgroup.name}"
  loadbalancer_id                = "${azurerm_lb.lb-couchbase.id}"
  name                           = "couchbase-rule-admin-ui"
  protocol                       = "tcp"
  frontend_port                  = "8091"
  backend_port                   = "8091"
  frontend_ip_configuration_name = "CouchbasePublicIPAddress"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.bpepool-couchbase.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.probe-couchbase.id}"
}


resource "azurerm_virtual_machine_scale_set" "vmss-couchbase" {
  name                = "couchbase-server"
  location            = "${azurerm_resource_group.rgroup.location}"
  resource_group_name = "${azurerm_resource_group.rgroup.name}"

  automatic_os_upgrade = false
  upgrade_policy_mode  = "Manual"
  overprovision = false

  sku {
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

/*  extension {
    name                 = "MSILinuxExtension"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    settings = <<SETTINGS
    {
        "fileUris": [
          "https://gist.githubusercontent.com/russmckendrick/ce816a1d0b72b3ce84dc83acea48c17a/raw/ab9c4f3c32f5cf0fc545794765de531b6624931a/server.sh",
          "https://gist.githubusercontent.com/russmckendrick/ce816a1d0b72b3ce84dc83acea48c17a/raw/ab9c4f3c32f5cf0fc545794765de531b6624931a/util.sh"
        ],
          "commandToExecute": "bash server.sh 6.0.1 admin securepassword random-string uksouth"
    }
    SETTINGS
  }
*/
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
    name                      = "terraformnetworkprofile"
    primary                   = true
    network_security_group_id = "${azurerm_network_security_group.nsg.id}"

    ip_configuration {
      name                                   = "TestIPConfiguration"
      primary                                = true
      subnet_id                              = "${azurerm_subnet.subnet1.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.bpepool-couchbase.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${element(azurerm_lb_nat_pool.lbnatpool-couchbase.*.id, count.index)}"]
      public_ip_address_configuration {
        name = "PublicIpAddress"
        idle_timeout = 15
        domain_name_label = "couchbase-server"
      }
    }
  }

  tags = {
    environment = "testing"
  }
}


resource "azurerm_public_ip" "public-ip-syncgateway" {
  name                = "syncgateway-public-ip"
  location            = "${azurerm_resource_group.rgroup.location}"
  resource_group_name = "${azurerm_resource_group.rgroup.name}"
  allocation_method   = "Dynamic"
  domain_name_label   = "couchbase-syncgateway"
}

resource "azurerm_lb" "lb-syncgateway" {
  name                = "syncgateway-lb"
  location            = "${azurerm_resource_group.rgroup.location}"
  resource_group_name = "${azurerm_resource_group.rgroup.name}"

  frontend_ip_configuration {
    name                 = "SyncGatewayPublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.public-ip-syncgateway.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool-syncgateway" {
  resource_group_name = "${azurerm_resource_group.rgroup.name}"
  loadbalancer_id     = "${azurerm_lb.lb-syncgateway.id}"
  name                = "SyncGatewayBackendAddressPool"
}

resource "azurerm_lb_nat_pool" "lbnatpool-syncgateway" {
  count                          = 3
  resource_group_name            = "${azurerm_resource_group.rgroup.name}"
  name                           = "ssh"
  loadbalancer_id                = "${azurerm_lb.lb-syncgateway.id}"
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "SyncGatewayPublicIPAddress"
}

resource "azurerm_lb_probe" "probe-syncgateway-ui" {
  resource_group_name = "${azurerm_resource_group.rgroup.name}"
  loadbalancer_id     = "${azurerm_lb.lb-syncgateway.id}"
  name                = "syncgateway-probe-admin-ui"
  port                = 4985
}

resource "azurerm_lb_rule" "rule-syncgateway-ui" {
  resource_group_name            = "${azurerm_resource_group.rgroup.name}"
  loadbalancer_id                = "${azurerm_lb.lb-syncgateway.id}"
  name                           = "syncgateway-rule-admin-ui"
  protocol                       = "tcp"
  frontend_port                  = "4985"
  backend_port                   = "4985"
  frontend_ip_configuration_name = "SyncGatewayPublicIPAddress"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.bpepool-syncgateway.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.probe-syncgateway-ui.id}"
}

resource "azurerm_lb_probe" "probe-syncgateway" {
  resource_group_name = "${azurerm_resource_group.rgroup.name}"
  loadbalancer_id     = "${azurerm_lb.lb-syncgateway.id}"
  name                = "syncgateway-probe"
  port                = 4984
}

resource "azurerm_lb_rule" "rule-syncgateway" {
  resource_group_name            = "${azurerm_resource_group.rgroup.name}"
  loadbalancer_id                = "${azurerm_lb.lb-syncgateway.id}"
  name                           = "syncgateway-rule"
  protocol                       = "tcp"
  frontend_port                  = "4984"
  backend_port                   = "4984"
  frontend_ip_configuration_name = "SyncGatewayPublicIPAddress"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.bpepool-syncgateway.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.probe-syncgateway.id}"
}


resource "azurerm_virtual_machine_scale_set" "vmss-syncgateway" {
  name                = "syncgateway-server"
  location            = "${azurerm_resource_group.rgroup.location}"
  resource_group_name = "${azurerm_resource_group.rgroup.name}"

  automatic_os_upgrade = false
  upgrade_policy_mode  = "Manual"
  overprovision = false

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

/*  extension {
    name                 = "MSILinuxExtension"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    settings = <<SETTINGS
    {
        "fileUris": [
          "https://gist.githubusercontent.com/russmckendrick/ce816a1d0b72b3ce84dc83acea48c17a/raw/ab9c4f3c32f5cf0fc545794765de531b6624931a/syncGateway.sh",
          "https://gist.githubusercontent.com/russmckendrick/ce816a1d0b72b3ce84dc83acea48c17a/raw/ab9c4f3c32f5cf0fc545794765de531b6624931a/util.sh"
        ],
          "commandToExecute": "bash server.sh 6.0.1 admin securepassword random-string uksouth"
    }
    SETTINGS
  }
*/
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
    name                      = "terraformnetworkprofile"
    primary                   = true
    network_security_group_id = "${azurerm_network_security_group.nsg.id}"

    ip_configuration {
      name                                   = "TestIPConfiguration"
      primary                                = true
      subnet_id                              = "${azurerm_subnet.subnet1.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.bpepool-syncgateway.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${element(azurerm_lb_nat_pool.lbnatpool-syncgateway.*.id, count.index)}"]
      public_ip_address_configuration {
        name = "PublicIpAddress"
        idle_timeout = 15
        domain_name_label = "syncgateway-server"
      }
    }
  }

  tags = {
    environment = "testing"
  }
}
