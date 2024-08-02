terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
  }
}

provider "vault" {}

provider "aws" {
  region                      = var.aws_region
  skip_requesting_account_id  = var.aws ? false : true
  skip_credentials_validation = var.aws ? false : true
}
