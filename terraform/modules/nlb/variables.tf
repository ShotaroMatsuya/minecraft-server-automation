############################
# VPC Input Variables      #
############################
# VPC Name

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

# VPC Availability Zones
variable "vpc_availability_zones" {
  description = "VPC Availability Zones"
  type        = list(string)
}

# VPC Public Subnets
variable "vpc_public_subnet_ids" {
  description = "VPC Public Subnet ids"
  type        = list(string)
}

variable "slack_webhook_path" {
  description = "Webhook url for notification of nlb_dns address to slack ch when creation completion"
  type        = string
  sensitive = true
}

# variable "loadbalancer_sg_group_id" {
#   description = "SG group ID for alb"
#   type        = string
# }

#####################################################
# Terraform AWS Application Load Balancer Variables #
# Place holder file for AWS ALB Variables           #
#####################################################
variable "owners" {}
variable "environment" {}

locals {
  owners      = var.owners
  environment = var.environment
  name        = "${var.owners}-${var.environment}"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
}
