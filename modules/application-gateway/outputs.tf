output "application_gateway_id" {
  value = "${azurerm_application_gateway.network.id}"
}

# output "application_gateway_backend_http_settings" {
#   value = "${azurerm_application_gateway.network.backend_http_settings}"
# }

output "backend_address_pool" {
  value = "${azurerm_application_gateway.network.backend_address_pool.0.id}"
}
