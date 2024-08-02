# resource "vault_generic_endpoint" "activate" {
#   path                 = "sys/activation-flags/secrets-sync/activate"
#   disable_read         = true
#   disable_delete       = true
#   ignore_absent_fields = true
#   data_json            = <<EOT
# {}
# EOT
# }

resource "vault_namespace" "admin" {
  path = "admin"
}

resource "vault_namespace" "ns-1" {
  namespace = vault_namespace.admin.path
  path      = var.ns-1
}

resource "vault_mount" "ns-1" {
  namespace = vault_namespace.ns-1.path_fq
  path      = "secret"
  type      = "kv"
  options = {
    version = "2"
  }
}

resource "vault_kv_secret_v2" "ns-1" {
  namespace = vault_namespace.ns-1.path_fq
  mount     = vault_mount.ns-1.path
  name      = "database/dev"
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
  namespace   = vault_namespace.ns-1.path_fq
  mount       = vault_mount.ns-1.path
  secret_name = vault_kv_secret_v2.ns-1.name
}
