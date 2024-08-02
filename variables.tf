variable "ns-1" {
  default = "tenant-1"
}

variable "ns-2" {
  default = "tenant-2"
}

variable "secret-name" {
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
