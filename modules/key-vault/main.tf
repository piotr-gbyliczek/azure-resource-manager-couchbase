data "azurerm_client_config" "current" {}

# data "azurerm_azuread_service_principal" "sp" {
#   application_id = "${var.sp_id}"
# }

resource "azurerm_key_vault" "key_vault" {
  resource_group_name         = "${var.resource_group_name}"
  location                    = "${var.location}"
  tags                        = "${var.tags}"
  name                        = "mckendricktesting"
  enabled_for_disk_encryption = true
  tenant_id                   = "${data.azurerm_client_config.current.tenant_id}"

  sku {
    name = "standard"
  }

  access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "b4ec2b5d-c84f-4c7f-9159-27102e77c086"

    key_permissions = [
      "get",
      "list",
    ]

    secret_permissions = [
      "get",
      "list",
    ]
  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}
