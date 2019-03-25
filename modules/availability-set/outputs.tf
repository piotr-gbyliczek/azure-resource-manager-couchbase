output "as_id" {
  description = "The id of the newly created availability set"
  value       = "${azurerm_availability_set.as.id}"
}
