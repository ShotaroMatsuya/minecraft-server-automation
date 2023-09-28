###########################
# VPC Output Values       #
###########################
# VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# VPC CIDR blocks
output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# VPC Public Subnets
output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

# VPC Pubolic Subnets CIDR Blocks
output "public_subnets_cidr_blocks" {
  description = "List of CIDR Blocks of public subnets"
  value = module.vpc.public_subnets_cidr_blocks
}

# VPC AZs
output "azs" {
  description = "A list of availability zones spefified as argument to this module"
  value       = module.vpc.azs
}

#########################################
# Fargate ECS Security Group Outputs    #
#########################################
output "fargate_sg_group_id" {
  description = "The ID of the security group"
  value       = module.fargate_sg.security_group_id
}
output "fargate_sg_group_vpc_id" {
  description = "The VPC ID"
  value       = module.fargate_sg.security_group_vpc_id
}
output "fargate_sg_group_name" {
  description = "The name of the security group"
  value       = module.fargate_sg.security_group_name
}

###################################
# EFS Security Group Outputs      #
###################################
output "allow_nfs_sg_group_id" {
  description = "The ID of the security group"
  value       = module.allow_nfs_sg.security_group_id
}
output "allow_nfs_sg_group_vpc_id" {
  description = "The VPC ID"
  value       = module.allow_nfs_sg.security_group_vpc_id
}
output "allow_nfs_sg_group_name" {
  description = "The name of the security group"
  value       = module.allow_nfs_sg.security_group_name
}
