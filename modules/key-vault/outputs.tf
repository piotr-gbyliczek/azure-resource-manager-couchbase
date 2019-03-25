output "key_vault_id" {
  description = ""
  value       = "${azurerm_key_vault.key_vault.id}"
}

output "key_vault_url" {
  description = ""
  value       = "${azurerm_key_vault.key_vault.vault_uri}"
}
