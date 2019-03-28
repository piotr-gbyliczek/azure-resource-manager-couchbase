variable "resource_group_name" {
  description = "Name of the resource group we will be creating"
  default     = ""
}

variable "location" {
  description = "Which region in Azure are we launching the resources"
  default     = ""
}

variable "default_tags" {
  description = "The defaults tags, we will be adding to the these"
  type        = "map"
  default     = {}
}

variable "nsg-custom-rules" {
  description = "network security rules for couchbase deployment"
  type        = "list"
  default     = []
}

######################################################################################################
# Dictionary
######################################################################################################

variable "long_name" {
  default = ""
}

variable "short_name" {
  default = ""
}

#################
# General
#################

variable "suffix_resource-group" {
  default = "rg"
}

variable "suffix_availability-set" {
  default = "as"
}

#################
# Compute
#################

variable "suffix_virtual-machine" {
  default = "vm"
}

#################
# Networking
#################

variable "suffix_vnet" {
  default = "vnet"
}

variable "suffix_subnet" {
  default = "sub"
}

variable "suffix_nic" {
  default = "nic"
}

variable "suffix_public-ip" {
  default = "pip"
}

variable "suffix_load-balancer" {
  default = "lb"
}

variable "suffix_app-gateway" {
  default = "agw"
}

variable "suffix_network-watcher" {
  default = "nwatcher"
}

variable "suffix_nsg" {
  default = "nsg"
}

#################
# Containers
#################

variable "suffix_container-registry" {
  default = "registry"
}
