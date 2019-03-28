resource "azurerm_virtual_machine_scale_set" "vmss" {
  name                = "${var.virtual_machine_scale_set_name}"
  location            = "${var.virtual_machine_scale_set_location}"
  resource_group_name = "${var.virtual_machine_scale_set_resource_group}"

  automatic_os_upgrade = "${var.automatic_os_upgrade}"
  upgrade_policy_mode  = "${var.upgrade_policy_mode}"
  overprovision        = "${var.overprovision}"

  sku {
    name     = "${var.sku_name}"
    tier     = "${var.sku_tier}"
    capacity = "${var.virtual_machine_scale_set_size}"
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
