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


variable "backend_address_pool_name" {
  description = "backend address pool name"
  default = ""
}

variable "frontend_port_name" {
  description = "frontend port name"
  default = ""
  }

variable "frontend_ip_configuration_name" {
  description = "frontend port name"
  default = ""
  }
variable "http_setting_name" {
  description = "frontend port name"
  default = ""
  }

variable "listener_name" {
  description = "frontend port name"
  default = ""
  }

variable "request_routing_rule_name"  {
  description = "frontend port name"
  default = ""
}    
