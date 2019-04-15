variable "virtual_machine_scale_set_name" {
  description = "virtual machine scale set name"
  default     = ""
}

variable "virtual_machine_scale_set_location" {
  description = "virtual macine scale set location"
  default     = ""
}

variable "virtual_machine_scale_set_resource_group" {
  description = "virtual machine scale set resource group"
  default     = ""
}

variable "virtual_machine_scale_set_load_balancer" {
  description = "virtual machine scale set load balancer"
  default     = ""
}

variable "virtual_machine_scale_set_load_balancer_backend_id" {
  description = "virtual machine scale set load balancer backend ids"
  default     = ""
}

variable "application_gateway_backend_address_pool_id" {
  description = "virtual machine scale set application gateway backend ids"
  default     = ""
}

variable "type" {
  description = "is this a load balancer (lb) or application gateway (ag)?"
  default     = "lb"
}

variable "virtual_machine_scale_set_vnet" {
  description = "virtual machine scale set virtual network"
  default     = ""
}

variable "virtual_machine_scale_set_vnet_subnets" {
  description = "virtual machine scale set virtual network subnets"
  default     = ""
}

variable "virtual_machine_scale_set_network_security_group" {
  description = "virtual machine scale set network security group"
}

variable "virtual_machine_scale_set_application_security_group" {
  description = "virtual machine scale set application security group"
  default = ""
  }

variable "virtual_machine_scale_set_storage_account" {
  description = "storage account for the extension scripts"
  default     = ""
}

variable "virtual_machine_scale_set_unique_string" {
  description = "unique string appended to domain name"
  default     = ""
}

variable "automatic_os_upgrade" {
  description = "automatic os upgrade boolean"
  default     = false
}

variable "upgrade_policy_mode" {
  description = "upgrade policy mode"
  default     = "Manual"
}

variable "overprovision" {
  description = "overprovision boolean"
  default     = false
}

variable "sku_name" {
  description = "SKU name"
  default     = "Standard_B2ms"
}

variable "sku_tier" {
  description = "SKU tier"
  default     = "Standard"
}

variable "os_admin_username" {
  description = "Admin username for the OS"
  default     = "admin-user"
}

variable "virtual_machine_scale_set_size" {
  description = "Number of virtual machines in the scale set"
  default     = 3
}

variable "virtual_machine_storage_managed_disk_type" {
  description = "The type of disk used by virtual machines in the scale set"
  default     = "Standard_LRS"
}

variable "virtual_machine_storage_data_disk_size" {
  description = "Size of the data disk used by virtual machine in the scale set (GB)"
  default     = "10"
}

variable "virtual_machine_set_os_password_authentication_disable" {
  description = "OS Profile password authentication disable boolean"
  default     = true
}

variable "virtual_machine_scale_set_extension_settings_command_to_execute" {
  description = "virtual_machine_scale_set_extension settings command to run"
  default     = ""
}

variable "virtual_machine_scale_set_extension_settings_fileuris" {
  description = "virtual_machine_scale_set_extension settings URIs of the files to execute"
  type        = "list"
}