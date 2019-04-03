output "application_gateway_id" {
  value = "${azurerm_application_gateway.appgw.id}"
}

output "application_gateway_name" {
  value = "${azurerm_application_gateway.appgw.name}"
}
