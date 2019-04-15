######################################################################################################
# Azure
######################################################################################################

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

variable "nsg-rules-open" {
  description = "open network security rules for couchbase deployment"
  type        = "list"
  default     = []
}

variable "nsg-rules-locked" {
  description = "locked down network security rules for couchbase deployment"
  type        = "list"
  default     = []
}

variable "nsg-rules-groups" {
  description = "network security rules associated to application security groups for couchbase deployment"
  type        = "list"
  default     = []
}

variable "static_ips" {
  description = "List of static IP addresses"
  default     = ""
}

######################################################################################################
# Couchbase
######################################################################################################

variable "couchbase_version" {
  default = "6.0.1"
}

variable "couchbase_username" {
  default = "admin"
}

variable "couchbase_password" {
  default = "securepassword"
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

variable "suffix_asg" {
  default = "asg"
}

#################
# Containers
#################

variable "suffix_container-registry" {
  default = "registry"
}
