variable "owners" {}
variable "environment" {}
locals {
  name = "${var.owners}-${var.environment}"
}
variable "aws_account_id" {}

