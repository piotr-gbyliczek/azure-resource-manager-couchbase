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

# Everything below is for the application gateway module
variable "name" {
  description = "Name of the load balancer"
  default     = ""
}

variable "public_ip_id" {
  description = "ID of the public ip address which should be assigned to the load balancer"
  default     = ""
}

variable "subnet_id" {
  description = "ID of the subnet where the load balancer should be placed"
  default     = ""
}

variable "ag_port" {
  description = "Protocols to be used for lb health probes and rules. [frontend_port, protocol, backend_port]"
  default     = {}
}

variable "sku_name" {
  description = ""
  default     = "Standard_Small"
}

variable "sku_tier" {
  description = ""
  default     = "Standard"
}

variable "sku_capacity" {
  description = ""
  default     = "2"
}
