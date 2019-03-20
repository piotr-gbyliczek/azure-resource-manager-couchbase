resource "azurerm_resource_group" "cbtest" {
  name     = "cbtest"
  location = "uksouth"
}

resource "azurerm_virtual_network" "cbtest" {
  name                = "acctvn"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.cbtest.location}"
  resource_group_name = "${azurerm_resource_group.cbtest.name}"
}

resource "azurerm_subnet" "cbtest" {
  name                 = "acctsub"
  resource_group_name  = "${azurerm_resource_group.cbtest.name}"
  virtual_network_name = "${azurerm_virtual_network.cbtest.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "cbtest" {
  name                = "cbtest"
  location            = "${azurerm_resource_group.cbtest.location}"
  resource_group_name = "${azurerm_resource_group.cbtest.name}"
  allocation_method   = "Static"
}

resource "azurerm_lb" "cbtest" {
  name                = "cbtest"
  location            = "${azurerm_resource_group.cbtest.location}"
  resource_group_name = "${azurerm_resource_group.cbtest.name}"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.cbtest.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  resource_group_name = "${azurerm_resource_group.cbtest.name}"
  loadbalancer_id     = "${azurerm_lb.cbtest.id}"
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_nat_pool" "lbnatpool" {
  count                          = 3
  resource_group_name            = "${azurerm_resource_group.cbtest.name}"
  name                           = "ssh"
  loadbalancer_id                = "${azurerm_lb.cbtest.id}"
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_probe" "cbtest" {
  resource_group_name = "${azurerm_resource_group.cbtest.name}"
  loadbalancer_id     = "${azurerm_lb.cbtest.id}"
  name                = "cb-probe"
  port                = 8091
}

resource "azurerm_lb_rule" "cbtest" {
  resource_group_name            = "${azurerm_resource_group.cbtest.name}"
  loadbalancer_id                = "${azurerm_lb.cbtest.id}"
  name                           = "cbtest_lb-rule"
  protocol                       = "tcp"
  frontend_port                  = "8091"
  backend_port                   = "8091"
  frontend_ip_configuration_name = "PublicIPAddress"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.bpepool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.cbtest.id}"
}

resource "azurerm_network_security_group" "cbtest" {
  name                = "acceptanceTestSecurityGroup1"
  location            = "${azurerm_resource_group.cbtest.location}"
  resource_group_name = "${azurerm_resource_group.cbtest.name}"
}

resource "azurerm_network_security_rule" "cbtest" {
  name                        = "allin"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.cbtest.name}"
  network_security_group_name = "${azurerm_network_security_group.cbtest.name}"
}

resource "azurerm_virtual_machine_scale_set" "cbtest" {
  name                = "mytestscaleset-1"
  location            = "${azurerm_resource_group.cbtest.location}"
  resource_group_name = "${azurerm_resource_group.cbtest.name}"

  automatic_os_upgrade = false
  upgrade_policy_mode  = "Manual"

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
          "https://gist.githubusercontent.com/russmckendrick/ce816a1d0b72b3ce84dc83acea48c17a/raw/ab9c4f3c32f5cf0fc545794765de531b6624931a/server.sh",
          "https://gist.githubusercontent.com/russmckendrick/ce816a1d0b72b3ce84dc83acea48c17a/raw/ab9c4f3c32f5cf0fc545794765de531b6624931a/util.sh"
        ],
          "commandToExecute": "bash server.sh 6.0.1 admin securepassword 2.1.2 random-string"
    }
    SETTINGS
  }

  os_profile {
    computer_name_prefix = "testvm"
    admin_username       = "myadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/myadmin/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }

  network_profile {
    name                      = "terraformnetworkprofile"
    primary                   = true
    network_security_group_id = "${azurerm_network_security_group.cbtest.id}"

    ip_configuration {
      name                                   = "TestIPConfiguration"
      primary                                = true
      subnet_id                              = "${azurerm_subnet.cbtest.id}"
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.bpepool.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${element(azurerm_lb_nat_pool.lbnatpool.*.id, count.index)}"]
    }
  }

  tags = {
    environment = "testing"
  }
}
