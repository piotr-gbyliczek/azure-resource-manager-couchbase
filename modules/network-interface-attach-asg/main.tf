resource "azurerm_network_interface_application_security_group_association" "application_security_group" {
  ip_configuration_name         = "${var.name}-ip"
  network_interface_id          = "${var.nic}"
  application_security_group_id = "${var.asg}"
}
