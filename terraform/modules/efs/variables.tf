variable "owners" {}
variable "environment" {}
locals {
  owners      = var.owners
  environment = var.environment
  name        = "${var.owners}-${var.environment}"
}
variable "vpc_id" {
  type = string
}
variable "azs" {
  type = list(string)
}
variable "public_subnets" {
  type = list(string)
}
variable "public_subnets_cidr_blocks" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}


