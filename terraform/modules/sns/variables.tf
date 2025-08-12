variable "owners" {}
variable "environment" {}
locals {
  owners      = var.owners
  environment = var.environment
  name        = "${var.owners}-${var.environment}"
}
variable "aws_account_id" {}

