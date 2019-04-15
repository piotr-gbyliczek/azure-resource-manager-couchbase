resource "azurerm_application_gateway" "network" {
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  tags                = "${var.tags}"
  name                = "${var.name}"

  sku {
    name     = "${var.sku_name}"
    tier     = "${var.sku_tier}"
    capacity = "${var.sku_capacity}"
  }

  gateway_ip_configuration {
    name      = "${var.name}GatewayIPConfig"
    subnet_id = "${var.subnet_id}"
  }

  frontend_port {
    name = "${element(keys(var.ag_port), 0)}FrontEndPort"
    port = "${element(var.ag_port["${element(keys(var.ag_port), 0)}"], 0)}"
  }

  frontend_port {
    name = "${element(keys(var.ag_port), 1)}FrontEndPort"
    port = "${element(var.ag_port["${element(keys(var.ag_port), 1)}"], 0)}"
  }

  frontend_ip_configuration {
    name                 = "${var.name}PublicIPAddress"
    public_ip_address_id = "${var.public_ip_id}"
  }

  backend_address_pool {
    name = "${var.name}AppGateWayBackEndAddressPool"
  }

  backend_http_settings {
    name                  = "${element(keys(var.ag_port), 0)}HttpSettings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = "${element(var.ag_port["${element(keys(var.ag_port), 0)}"], 0)}"
    protocol              = "Http"
    request_timeout       = 1
  }

  backend_http_settings {
    name                  = "${element(keys(var.ag_port), 1)}HttpSettings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = "${element(var.ag_port["${element(keys(var.ag_port), 1)}"], 0)}"
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = "${element(keys(var.ag_port), 0)}HttpListener"
    frontend_ip_configuration_name = "${var.name}PublicIPAddress"
    frontend_port_name             = "${element(keys(var.ag_port), 0)}FrontEndPort"
    protocol                       = "Http"
  }

  http_listener {
    name                           = "${element(keys(var.ag_port), 1)}HttpListener"
    frontend_ip_configuration_name = "${var.name}PublicIPAddress"
    frontend_port_name             = "${element(keys(var.ag_port), 1)}FrontEndPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "${element(keys(var.ag_port), 0)}"
    rule_type                  = "Basic"
    http_listener_name         = "${element(keys(var.ag_port), 0)}HttpListener"
    backend_address_pool_name  = "${var.name}AppGateWayBackEndAddressPool"
    backend_http_settings_name = "${element(keys(var.ag_port), 0)}HttpSettings"
  }

  request_routing_rule {
    name                       = "${element(keys(var.ag_port), 1)}"
    rule_type                  = "Basic"
    http_listener_name         = "${element(keys(var.ag_port), 1)}HttpListener"
    backend_address_pool_name  = "${var.name}AppGateWayBackEndAddressPool"
    backend_http_settings_name = "${element(keys(var.ag_port), 1)}HttpSettings"
  }
}
