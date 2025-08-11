# Create VPC Terraform Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  # VPC Basic Details
  name                 = "${local.name}-${var.vpc_name}"
  cidr                 = var.vpc_cidr_block
  azs                  = var.vpc_availability_zones
  public_subnets       = var.vpc_public_subnets
  enable_dns_hostnames = true

  tags     = local.common_tags
  vpc_tags = local.common_tags

  # Additional Tags to Subnets
  public_subnet_tags = {
    Type = "Public Subnets"
  }
}
