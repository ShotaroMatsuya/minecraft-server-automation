# Terraform AWS Application Load Balancer (ALB)
module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.2.0"

  name               = "${local.name}-nlb"
  load_balancer_type = "network"
  vpc_id             = var.vpc_id

  subnets = var.vpc_public_subnet_ids
  # security_groups = [var.loadbalancer_sg_group_id]
  # HTTP Listener -
  listeners = {
    ex-one = {
      port     = 25565
      protocol = "TCP"
      forward = {
        target_group_key = "ex-target-one"
      }
    }
  }
  # Target Groups
  target_groups = {
    # ECS service Target Group - TG Index = 0
    ex-target-one = {
      backend_protocol     = "TCP"
      backend_port         = 25565
      target_type          = "ip"
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 20
        protocol            = "TCP"
      }
      tags = local.common_tags
    }
  }

  tags = local.common_tags
}

resource "null_resource" "send_slack_notification" {
  provisioner "local-exec" {
    command     = "bash send_to_slack.sh https://hooks.slack.com/services/${var.slack_webhook_path} ${module.nlb.lb_dns_name}"
    working_dir = "../scripts/"
  }
}
