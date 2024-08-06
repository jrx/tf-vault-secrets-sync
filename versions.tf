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

provider "google" {}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}