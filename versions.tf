terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
  }
}

provider "vault" {}

provider "aws" {
  region = var.aws_region
}