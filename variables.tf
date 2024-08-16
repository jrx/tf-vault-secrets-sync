variable "vault-parent-namespace" {
  type    = string
  default = ""
}

variable "vault-tenant-namespace" {
  default = "tenant-1"
}

variable "secret-mount" {
  type    = string
  default = "secret"
}

variable "secret-path" {
  default = "database/dev"
}

variable "aws" {
  type        = bool
  description = "Enable Secrets Sync to AWS"
  default     = false
}

variable "aws_region" {
  default = "eu-north-1"
}

variable "gcp" {
  type        = bool
  description = "Enable Secrets Sync to GCP"
  default     = false
}

variable "azure" {
  type        = bool
  description = "Enable Secrets Sync to Azure"
  default     = false
}