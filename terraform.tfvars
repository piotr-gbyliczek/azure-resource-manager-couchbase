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

nsg-custom-rules = [
  {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    description                = "SSH"
  },
  {
    name                       = "ErlangPortMapper"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "4369"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    description                = "ErlangPortMapper"
  },
  {
    name                       = "SyncGateway"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "4984-4985"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    description                = "SyncGateway"
  },
  {
    name                       = "Server"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8091-8096"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    description                = "Server"
  },
  {
    name                       = "Index"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9100-9105"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    description                = "Index"
  },
  {
    name                       = "Analytics"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9110-9122"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    description                = "Analytics"
  },
  {
    name                       = "Internal"
    priority                   = 106
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9998-9999"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    description                = "Internal"
  },
  {
    name                       = "XDCR"
    priority                   = 107
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "11207-11215"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    description                = "XDCR"
  },
  {
    name                       = "SSL"
    priority                   = 108
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "18091-18096"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    description                = "SSL"
  },
  {
    name                       = "NodeDataExchange"
    priority                   = 109
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "21100-21299"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    description                = "Node Data Exchange"
  },
]
