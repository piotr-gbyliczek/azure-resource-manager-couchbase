resource "azurerm_lb" "loadbalancer" {
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  tags                = "${var.tags}"
  name                = "${var.name}"

  frontend_ip_configuration {
    name                          = "${var.name}PublicIPAddress"
    public_ip_address_id          = "${var.type == "public" ? var.public_ip_id : ""}"
    subnet_id                     = "${var.type == "private" ? var.subnet_id : ""}"
    private_ip_address            = "${var.frontend_private_ip_address}"
    private_ip_address_allocation = "${var.frontend_private_ip_address_allocation}"
  }
}

resource "azurerm_lb_backend_address_pool" "loadbalancer" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.loadbalancer.id}"
  name                = "${var.name}PublicIPAddress"
}

# resource "azurerm_lb_nat_rule" "loadbalancer" {
#   count                          = "${length(var.remote_port)}"
#   resource_group_name            = "${azurerm_resource_group.azlb.name}"
#   loadbalancer_id                = "${azurerm_lb.loadbalancer.id}"
#   name                           = "VM-${count.index}"
#   protocol                       = "tcp"
#   frontend_port                  = "5000${count.index + 1}"
#   backend_port                   = "${element(var.remote_port["${element(keys(var.remote_port), count.index)}"], 1)}"
#   frontend_ip_configuration_name = "${var.frontend_name}"
# }

resource "azurerm_lb_probe" "loadbalancer" {
  count               = "${length(var.lb_port)}"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.loadbalancer.id}"
  name                = "${element(keys(var.lb_port), count.index)}"
  protocol            = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 1)}"
  port                = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 2)}"
  interval_in_seconds = "${var.lb_probe_interval}"
  number_of_probes    = "${var.lb_probe_unhealthy_threshold}"
}

resource "azurerm_lb_rule" "loadbalancer" {
  count                          = "${length(var.lb_port)}"
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.loadbalancer.id}"
  name                           = "${element(keys(var.lb_port), count.index)}"
  protocol                       = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 1)}"
  frontend_port                  = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 0)}"
  backend_port                   = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 2)}"
  frontend_ip_configuration_name = "${var.name}PublicIPAddress"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.loadbalancer.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${element(azurerm_lb_probe.loadbalancer.*.id,count.index)}"
  load_distribution              = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 3)}"
  depends_on                     = ["azurerm_lb_probe.loadbalancer"]
}
