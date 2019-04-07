output "application_gateway_id" {
  value = "${azurerm_application_gateway.gateway.id}"
}

output "application_gateway_backend_http_settings" {
  value = "${azurerm_application_gateway.gateway.backend_http_settings}"
}

output "application_gateway_backend_address_pool " {
  value = "${azurerm_application_gateway.gateway.backend_address_pool }"
}
