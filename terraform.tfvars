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

]
nsg-rules-groups = [  
  {
    name                       = "ErlangPortMapper-asg"
    priority                   = 301
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "4369"
    application_security_group_ids = "${azurerm_application_security_group.couchbase-asg.id}"
    destination_address_prefix = "*"
    description                = "ErlangPortMapper-asg"
  },
  {
    name                       = "SyncGateway-asg"
    priority                   = 302
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    application_security_group_ids = "${azurerm_application_security_group.couchbase-asg.id}"
    destination_port_range     = "4984-4985"
    destination_address_prefix = "*"
    description                = "SyncGateway-asg"
  },
  {
    name                       = "Server-asg"
    priority                   = 303
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    application_security_group_ids = "${azurerm_application_security_group.couchbase-asg.id}"
    destination_port_range     = "8091-8096"
    destination_address_prefix = "*"
    description                = "Server-asg"
  },
  {
    name                       = "Index-asg"
    priority                   = 304
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    application_security_group_ids = "${azurerm_application_security_group.couchbase-asg.id}"
    destination_port_range     = "9100-9105"
    destination_address_prefix = "*"
    description                = "Index-asg"
  },
  {
    name                       = "Analytics-asg"
    priority                   = 305
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    application_security_group_ids = "${azurerm_application_security_group.couchbase-asg.id}"
    destination_port_range     = "9110-9122"
    destination_address_prefix = "*"
    description                = "Analytics-asg"
  },
  {
    name                       = "Internal-asg"
    priority                   = 306
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    application_security_group_ids = "${azurerm_application_security_group.couchbase-asg.id}"
    destination_port_range     = "9998-9999"
    destination_address_prefix = "*"
    description                = "Internal-asg"
  },
  {
    name                       = "XDCR-asg"
    priority                   = 307
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    application_security_group_ids = "${azurerm_application_security_group.couchbase-asg.id}"
    destination_port_range     = "11207-11215"
    destination_address_prefix = "*"
    description                = "XDCR-asg"
  },
  {
    name                       = "SSL-asg"
    priority                   = 308
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    application_security_group_ids = "${azurerm_application_security_group.couchbase-asg.id}"
    destination_port_range     = "18091-18096"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
    description                = "SSL-asg"
  },
  {
    name                       = "NodeDataExchange-asg"
    priority                   = 309
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    application_security_group_ids = "${azurerm_application_security_group.couchbase-asg.id}"
    destination_port_range     = "21100-21299"
    destination_address_prefix = "*"
    description                = "Node Data Exchange-asg"
  },
]
nsg-rules-locked = [
    {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = "83.166.165.252/32,83.244.243.48/28"
    destination_address_prefix = "*"
    description                = "SSH"
  },
  {
    name                       = "ErlangPortMapper"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "4369"
    source_address_prefix      = "Internet"
    source_address_prefixes    = "83.166.165.252/32,83.244.243.48/28"
    destination_address_prefix = "*"
    description                = "ErlangPortMapper"
  },
  {
    name                       = "SyncGateway"
    priority                   = 111
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "4984-4985"
    source_address_prefix      = "Internet"
    source_address_prefixes    = "83.166.165.252/32,83.244.243.48/28"
    destination_address_prefix = "*"
    description                = "SyncGateway"
  },
  {
    name                       = "Server"
    priority                   = 112
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8091-8096"
    source_address_prefix      = "Internet"
    source_address_prefixes    = "83.166.165.252/32,83.244.243.48/28"
    destination_address_prefix = "*"
    description                = "Server"
  },
  {
    name                       = "Index"
    priority                   = 113
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9100-9105"
    source_address_prefix      = "Internet"
    source_address_prefixes    = "83.166.165.252/32,83.244.243.48/28"
    destination_address_prefix = "*"
    description                = "Index"
  },
  {
    name                       = "Analytics"
    priority                   = 114
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9110-9122"
    source_address_prefix      = "Internet"
    source_address_prefixes    = "83.166.165.252/32,83.244.243.48/28"
    destination_address_prefix = "*"
    description                = "Analytics"
  },
  {
    name                       = "Internal"
    priority                   = 115
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9998-9999"
    source_address_prefix      = "Internet"
    source_address_prefixes    = "83.166.165.252/32,83.244.243.48/28"
    destination_address_prefix = "*"
    description                = "Internal"
  },
  {
    name                       = "XDCR"
    priority                   = 116
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "11207-11215"
    source_address_prefix      = "Internet"
    source_address_prefixes    = "83.166.165.252/32,83.244.243.48/28"
    destination_address_prefix = "*"
    description                = "XDCR"
  },
  {
    name                       = "SSL"
    priority                   = 117
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "18091-18096"
    source_address_prefix      = "Internet"
    source_address_prefixes    = "83.166.165.252/32,83.244.243.48/28"
    destination_address_prefix = "*"
    description                = "SSL"
  },
  {
    name                       = "NodeDataExchange"
    priority                   = 118
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "21100-21299"
    source_address_prefix      = "Internet"
    source_address_prefixes    = "83.166.165.252/32,83.244.243.48/28"
    destination_address_prefix = "*"
    description                = "Node Data Exchange"
  },
  {
    name                       = "Nginx"
    priority                   = 119
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = "83.166.165.252/32,83.244.243.48/28"
    destination_address_prefix = "*"
    description                = "NginX"
  },
  {
    name                       = "Nginx - ssl"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = "83.166.165.252/32,83.244.243.48/28"
    destination_address_prefix = "*"
    description                = "NginX SSL port"
  },
  {
    name                       = "nginxgatewayproxy"
    priority                   = 121
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "18100"
    source_address_prefixes    = "83.166.165.252/32,83.244.243.48/28"
    destination_address_prefix = "*"
    description                = "NginX SyncGateway proxy"
  },
]
