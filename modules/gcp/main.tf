data "google_client_config" "config" {}

resource "google_service_account" "vault_secrets_sync_account" {
  account_id  = "gcp-sm-vault-secrets-sync"
  description = "service account for Vault Secrets Sync feature"
}

data "google_iam_policy" "vault_secrets_sync_iam_policy" {
  binding {
    role = "roles/secretmanager.admin"
    members = [
      google_service_account.vault_secrets_sync_account.member,
    ]
  }
}

resource "google_project_iam_member" "vault_secrets_sync_iam_member" {
  project = data.google_client_config.config.project
  role    = "roles/secretmanager.admin"
  member  = google_service_account.vault_secrets_sync_account.member
}

resource "google_service_account_key" "vault_secrets_sync_account_key" {
  service_account_id = google_service_account.vault_secrets_sync_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "vault_secrets_sync_gcp_destination" "gcp" {
  name                 = "my-project"
  namespace            = var.namespace
  project_id           = data.google_client_config.config.project
  credentials          = base64decode(google_service_account_key.vault_secrets_sync_account_key.private_key)
  secret_name_template = "vault-{{ .NamespacePath }}{{ .MountPath }}-{{ .SecretPath }}"
  granularity          = "secret-path"
  custom_tags = {
    "ochestrator" = "terraform"
  }
}

resource "vault_secrets_sync_association" "gcp-test" {
  namespace   = var.namespace
  name        = vault_secrets_sync_gcp_destination.gcp.name
  type        = vault_secrets_sync_gcp_destination.gcp.type
  mount       = var.mount
  secret_name = var.secret_name
}
