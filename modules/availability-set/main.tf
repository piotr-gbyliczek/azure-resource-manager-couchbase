resource "azurerm_availability_set" "as" {
  resource_group_name         = "${var.resource_group_name}"
  location                    = "${var.location}"
  tags                        = "${var.tags}"
  name                        = "${var.name}"
  managed                     = "${var.managed}"
  platform_fault_domain_count = "${var.fault_domain_count}"
}
