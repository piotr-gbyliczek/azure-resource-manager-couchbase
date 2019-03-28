variable "virtual_machine_scale_set_name" {
  description = "virtual machine scale set name"
  default = ""
}

variable "virtual_machine_scale_set_location" {
  description = "virtual macine scale set location"
  default = ""
}

variable "virtual_machine_scale_set_resource_group" {
  description = "virtual machine scale set resource group"
  default = ""
}

variable "automatic_os_upgrade" {
  description = "automatic os upgrade boolean"
  default = false
}

variable "upgrade_policy_mode" {
  description = "upgrade policy mode"
  default = "Manual"
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

variable "virtual_machine_scale_set_size" {
  description = "Number of virtuial machines in the scale set"
  default = 3
}
