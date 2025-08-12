variable "owners" {}
variable "environment" {}
locals {
  owners      = var.owners
  environment = var.environment
  name        = "${var.owners}-${var.environment}"
}
variable "account_id" {}
variable "github_org" {}
variable "github_repo" {}

