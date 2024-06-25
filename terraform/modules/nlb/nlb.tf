# Terraform AWS Application Load Balancer (ALB)
module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.9.0"

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
      protocol             = "TCP"
      port                 = 25565
      target_type          = "ip"
      deregistration_delay = 10
      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      # ref:https://github.com/terraform-aws-modules/terraform-aws-alb/blob/a1a54c5b0a26919eda7bdd50da6b9eed5fedcc1c/docs/patterns.md#target-group-without-attachment
      create_attachment                 = false
      load_balancing_cross_zone_enabled = false
      health_check = {
        enabled             = true
        interval            = 60
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 50
        protocol            = "TCP"
      }
      tags = local.common_tags
    }
  }
  enable_deletion_protection = false

  tags = local.common_tags
}

resource "null_resource" "send_slack_notification" {
  provisioner "local-exec" {
    command     = "bash send_to_slack.sh https://hooks.slack.com/services/${var.slack_webhook_path} ${module.nlb.dns_name}"
    working_dir = "../scripts/"
  }
}
