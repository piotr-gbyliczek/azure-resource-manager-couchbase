resource "azurerm_virtual_machine_scale_set" "vmsslb" {
  count               = "${var.type == "lb" ? 1 : 0}"
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
    managed_disk_type = "${var.virtual_machine_storage_managed_disk_type}"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = "${var.virtual_machine_storage_data_disk_size}"
  }

  extension {
    name                 = "MSILinuxExtension"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    settings = <<SETTINGS
      {
          "fileUris": [
             "${var.virtual_machine_scale_set_extension_settings_fileuris[0]}",
             "${var.virtual_machine_scale_set_extension_settings_fileuris[1]}"
           ],
          "commandToExecute": "${var.virtual_machine_scale_set_extension_settings_command_to_execute}"
      }
SETTINGS
  }

  os_profile {
    computer_name_prefix = "${var.virtual_machine_scale_set_name}"
    admin_username       = "${var.os_admin_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = "${var.virtual_machine_set_os_password_authentication_disable}"

    ssh_keys {
      path     = "/home/${var.os_admin_username}/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }

  network_profile {
    name                      = "${var.virtual_machine_scale_set_name}-network-profile"
    primary                   = true
    network_security_group_id = "${var.virtual_machine_scale_set_network_security_group}"

    ip_configuration {
      name                                   = "${var.virtual_machine_scale_set_name}-IPConfiguration"
      primary                                = true
      subnet_id                              = "${var.virtual_machine_scale_set_vnet_subnets}"
      load_balancer_backend_address_pool_ids = ["${var.virtual_machine_scale_set_load_balancer_backend_id}"]

      # application_gateway_backend_address_pool_ids = ["${var.type == "ag" ? var.application_gateway_backend_address_pool_id : ""}"]

      public_ip_address_configuration {
        name              = "PublicIpAddress"
        idle_timeout      = 15
        domain_name_label = "${var.virtual_machine_scale_set_name}-${var.virtual_machine_scale_set_unique_string}"
      }
    }
  }
}

resource "azurerm_virtual_machine_scale_set" "vmssag" {
  count               = "${var.type == "ag" ? 1 : 0}"
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
    managed_disk_type = "${var.virtual_machine_storage_managed_disk_type}"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = "${var.virtual_machine_storage_data_disk_size}"
  }

  extension {
    name                 = "MSILinuxExtension"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    settings = <<SETTINGS
      {
          "fileUris": [
             "${var.virtual_machine_scale_set_extension_settings_fileuris[0]}",
             "${var.virtual_machine_scale_set_extension_settings_fileuris[1]}"
           ],
          "commandToExecute": "${var.virtual_machine_scale_set_extension_settings_command_to_execute}"
      }
SETTINGS
  }

  os_profile {
    computer_name_prefix = "${var.virtual_machine_scale_set_name}"
    admin_username       = "${var.os_admin_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = "${var.virtual_machine_set_os_password_authentication_disable}"

    ssh_keys {
      path     = "/home/${var.os_admin_username}/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }

  network_profile {
    name                      = "${var.virtual_machine_scale_set_name}-network-profile"
    primary                   = true
    network_security_group_id = "${var.virtual_machine_scale_set_network_security_group}"

    ip_configuration {
      name                                         = "${var.virtual_machine_scale_set_name}-IPConfiguration"
      primary                                      = true
      subnet_id                                    = "${var.virtual_machine_scale_set_vnet_subnets}"
      application_gateway_backend_address_pool_ids = ["${var.application_gateway_backend_address_pool_id}"]

      public_ip_address_configuration {
        name              = "PublicIpAddress"
        idle_timeout      = 15
        domain_name_label = "${var.virtual_machine_scale_set_name}-${var.virtual_machine_scale_set_unique_string}"
      }
    }
  }
}
