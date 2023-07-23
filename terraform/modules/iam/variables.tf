########################################
# Define Local Values in Terraform     #
########################################

variable "owners" {}
variable "environment" {}
variable "aws_region" {}
variable "aws_account_id" {}

locals {
  owners      = var.owners
  environment = var.environment
  name        = "${var.owners}-${var.environment}"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
}
