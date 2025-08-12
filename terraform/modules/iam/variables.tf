variable "owners" {}
variable "environment" {}
locals {
  owners      = var.owners
  environment = var.environment
  name        = "${var.owners}-${var.environment}"
}
########################################
# Define Local Values in Terraform     #
########################################

variable "aws_region" {}
variable "aws_account_id" {}

