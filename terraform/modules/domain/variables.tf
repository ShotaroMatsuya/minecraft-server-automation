variable "nlb_dns_name" {
  description = "DNS Name of nlb to register in route53"
  type        = string
  sensitive   = true
}

variable "nlb_zone_id" {
  description = "nlb zone id to register in route53"
  type        = string
  sensitive   = true
}

variable "acm_certificate_arn" {
  description = "ACM Certificate ARN for CloudFront"
  type        = string
}


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
