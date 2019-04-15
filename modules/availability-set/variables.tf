variable "resource_group_name" {
  description = "The name of the resource group we want to use"
  default     = ""
}

variable "location" {
  description = "The location/region where we are crrating the resource"
  default     = ""
}

variable "tags" {
  description = "The tags to associate the resource we are creating"
  type        = "map"
  default     = {}
}

# Everything below is for the module

variable "name" {
  description = "Name of the availability set to create"
  default     = ""
}

variable "managed" {
  description = "Is the availability set managed?"
  default     = "false"
}

variable "fault_domain_count" {
  description = "No. of fault domains"
  default     = "3"
}