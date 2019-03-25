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
  type = "list"
  default  = []
}
