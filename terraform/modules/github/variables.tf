variable "owners" {}
variable "environment" {}
locals {
  name = "${var.owners}-${var.environment}"
}
variable "account_id" {}
variable "github_org" {}
variable "github_repo" {}

