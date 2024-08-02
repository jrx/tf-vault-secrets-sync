data "aws_caller_identity" "current" {}

locals {
  my_email = split("/", data.aws_caller_identity.current.arn)[2]
}

data "aws_iam_policy" "demo_user_permissions_boundary" {
  name = "DemoUser"
}

resource "aws_iam_user" "vault_mount_user" {
  name                 = "demo-${local.my_email}"
  permissions_boundary = data.aws_iam_policy.demo_user_permissions_boundary.arn
  force_destroy        = true
}

resource "aws_iam_user_policy_attachment" "vault_mount_user" {
  user       = aws_iam_user.vault_mount_user.name
  policy_arn = data.aws_iam_policy.demo_user_permissions_boundary.arn
}

resource "aws_iam_access_key" "vault_mount_user" {
  user = aws_iam_user.vault_mount_user.name
}

data "aws_iam_role" "vault_target_iam_role" {
  name = "vault-assumed-role-credentials-demo"
}

resource "time_sleep" "wait" {
  create_duration = "10s"
  depends_on      = [aws_iam_access_key.vault_mount_user]
}

resource "vault_secrets_sync_aws_destination" "aws" {
  name                 = "my-account"
  namespace            = var.namespace
  access_key_id        = aws_iam_access_key.vault_mount_user.id
  secret_access_key    = aws_iam_access_key.vault_mount_user.secret
  region               = var.aws_region
  secret_name_template = "vault/{{ .NamespacePath }}{{ .MountPath }}/{{ .SecretPath }}"
  granularity          = "secret-path"
  custom_tags = {
    "ochestrator" = "terraform"
    "owner"       = "demo-${local.my_email}"
  }

  depends_on = [time_sleep.wait]
}

resource "vault_secrets_sync_association" "aws-test" {
  namespace   = var.namespace
  name        = vault_secrets_sync_aws_destination.aws.name
  type        = vault_secrets_sync_aws_destination.aws.type
  mount       = var.mount
  secret_name = var.secret_name
}