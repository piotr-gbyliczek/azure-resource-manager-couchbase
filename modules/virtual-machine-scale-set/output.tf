output "virtual_machine_scale_set_id" {
  value = "${concat(azurerm_virtual_machine_scale_set.vmsslb.*.id,azurerm_virtual_machine_scale_set.vmssag.*.id)}"
}

# output "virtual_machine_scale_set_name" {
#   value = "${azurerm_virtual_machine_scale_set.vmss.name}"
# }

