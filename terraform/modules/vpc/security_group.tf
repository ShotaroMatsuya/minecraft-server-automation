# VPC Security Group Terraform Module
# Security Group for ECS fargate container
module "fargate_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name        = "${local.name}-fargate-sg"
  description = "Security group with Ingress from other containers in the same security group"
  vpc_id      = module.vpc.vpc_id

  egress_rules = ["all-all"]
  tags         = local.common_tags
  # Open for self (rule or from_port+to_port+protocol+description)
  ingress_with_self = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "Ingress from other containers in the same security group"
      self        = true
    }
  ]
  # Open for security group id (rule or from_port+to_port+protocol+description)
  ingress_with_cidr_blocks = [
    {
      from_port   = 25565
      to_port     = 25565
      protocol    = 6
      description = "Ingress from the public NLB"
      cidr_blocks = "10.0.0.0/16"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = 6
      description = "Ingress from the public NLB"
      cidr_blocks = "10.0.0.0/16"
    },

  ]
}

# module "allow_nfs_sg" {
#   source      = "terraform-aws-modules/security-group/aws"
#   version     = "5.1.2"
#   description = "EFS security group"
#   tags        = local.common_tags
#   name        = "${local.name}-allow-nfs-sg"
#   vpc_id      = module.vpc.vpc_id

#   egress_rules = ["all-all"]
#   ingress_with_source_security_group_id = [
#     {
#       from_port                = "2049"
#       to_port                  = "2049"
#       protocol                 = "TCP"
#       source_security_group_id = module.fargate_sg.security_group_id
#     }
#   ]
# }
