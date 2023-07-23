# Terraform AWS Application Load Balancer (ALB)
module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.6.1"

  name               = "${local.name}-nlb"
  load_balancer_type = "network"
  vpc_id             = var.vpc_id

  subnets = var.vpc_public_subnet_ids
  # security_groups = [var.loadbalancer_sg_group_id]
  # HTTP Listener -
  http_tcp_listeners = [
    {
      port     = 25565
      protocol = "TCP"
    }
  ]
  # Target Groups
  target_groups = [
    # ECS service Target Group - TG Index = 0
    {
      backend_protocol     = "TCP"
      backend_port         = 25565
      target_type          = "ip"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 6
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "TCP"
      }
      tags = local.common_tags
    }
  ]

  tags = local.common_tags
}
