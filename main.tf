# resource "vault_generic_endpoint" "activate" {
#   path                 = "sys/activation-flags/secrets-sync/activate"
#   disable_read         = true
#   disable_delete       = true
#   ignore_absent_fields = true
#   data_json            = <<EOT
# {}
# EOT
# }

resource "vault_namespace" "tenant_namespace" {
  path = var.vault-tenant-namespace
}

resource "vault_mount" "tenant_mount" {
  namespace = vault_namespace.tenant_namespace.path_fq
  path      = var.secret-mount
  type      = "kv"
  options = {
    version = "2"
  }
}

resource "vault_kv_secret_v2" "tenant_secret" {
  namespace = vault_namespace.tenant_namespace.path_fq
  mount     = vault_mount.tenant_mount.path
  name      = var.secret-path
  data_json = jsonencode(
    {}
  )

  lifecycle {
    ignore_changes = [
      data_json
    ]
  }
}

module "aws" {
  source = "./modules/aws"
  count  = var.aws ? 1 : 0

  aws_region  = var.aws_region
  namespace   = vault_namespace.tenant_namespace.path_fq
  mount       = vault_mount.tenant_mount.path
  secret_name = vault_kv_secret_v2.tenant_secret.name
}

module "gcp" {
  source = "./modules/gcp"
  count  = var.gcp ? 1 : 0

  namespace   = vault_namespace.tenant_namespace.path_fq
  mount       = vault_mount.tenant_mount.path
  secret_name = vault_kv_secret_v2.tenant_secret.name
}

module "azure" {
  source = "./modules/azure"
  count  = var.azure ? 1 : 0

  namespace   = vault_namespace.tenant_namespace.path_fq
  mount       = vault_mount.tenant_mount.path
  secret_name = vault_kv_secret_v2.tenant_secret.name
}