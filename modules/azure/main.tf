data "azurerm_client_config" "current" {}

resource "random_id" "keyvault_name" {
  byte_length = 3
}

resource "azurerm_resource_group" "vault" {
  name     = "jrx-dev-secrets-sync"
  location = var.azure_location
}


data "azuread_client_config" "current" {}

resource "azuread_application" "secrets-sync-sp" {
  display_name = "secrets-sync-sp"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "secrets-sync-sp" {
  client_id                    = azuread_application.secrets-sync-sp.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "time_rotating" "example" {
  rotation_days = 7
}

resource "azuread_service_principal_password" "secrets-sync-sp" {
  service_principal_id = azuread_service_principal.secrets-sync-sp.id
  rotate_when_changed = {
    rotation = time_rotating.example.id
  }
}

resource "azurerm_key_vault" "example" {
  name                        = "jrx-dev-kv-${random_id.keyvault_name.hex}"
  location                    = azurerm_resource_group.vault.location
  resource_group_name         = azurerm_resource_group.vault.name
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Purge",
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azuread_service_principal.secrets-sync-sp.object_id
    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Purge",
    ]
  }

}

resource "vault_secrets_sync_azure_destination" "azure-kv" {
  name                 = "my-kv"
  namespace            = var.namespace
  key_vault_uri        = azurerm_key_vault.example.vault_uri
  client_id            = azuread_service_principal.secrets-sync-sp.client_id
  client_secret        = azuread_service_principal_password.secrets-sync-sp.value
  tenant_id            = data.azurerm_client_config.current.tenant_id
  secret_name_template = "vault-{{ .NamespacePath }}{{ .MountPath }}-{{ .SecretPath }}"
  granularity          = "secret-path"
  custom_tags = {
    "ochestrator" = "terraform"
  }
}

resource "vault_secrets_sync_association" "azure-kv-test" {
  namespace   = var.namespace
  name        = vault_secrets_sync_azure_destination.azure-kv.name
  type        = vault_secrets_sync_azure_destination.azure-kv.type
  mount       = var.mount
  secret_name = var.secret_name
}
