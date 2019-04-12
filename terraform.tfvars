#################
# Resource group and location information
#################
long_name = "couchbase-deployment"

short_name = "couchbase"

location = "uksouth"

#################
# Default tags
#################

default_tags = {
  project     = "couchbase"
  environment = "test"
  costcenter  = "whitespace"
  deployed_by = "node4"
}

nsg-rules-open = [
  {
    name                       = "OpenAccess"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    description                = "Open access for initial setup"
  },
]
nsg-rules-groups = [  

]
nsg-rules-locked = [

]
