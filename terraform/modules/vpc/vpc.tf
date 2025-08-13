# Create VPC Terraform Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.9.0"

  # VPC Basic Details
  name                 = "${local.name}-${var.vpc_name}"
  cidr                 = var.vpc_cidr_block
  azs                  = var.vpc_availability_zones
  public_subnets       = var.vpc_public_subnets
  enable_dns_hostnames = true


  # Additional Tags to Subnets
  public_subnet_tags = {
    Type = "Public Subnets"
  }
}
