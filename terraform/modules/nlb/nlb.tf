# Terraform AWS Application Load Balancer (ALB)
module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.10.0"

  name               = "${local.name}-nlb"
  load_balancer_type = "network"
  vpc_id             = var.vpc_id

  subnets = var.vpc_public_subnet_ids
  # Security Group
  enforce_security_group_inbound_rules_on_private_link_traffic = "off"
  security_group_ingress_rules = {
    app_tcp = {
      from_port   = 25565
      to_port     = 25565
      ip_protocol = "tcp"
      description = "TCP traffic"
      cidr_ipv4   = "0.0.0.0/0"
    },
    map_tcp = {
      from_port   = 8080
      to_port     = 8080
      ip_protocol = "tcp"
      description = "TCP traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = var.vpc_cidr_block
    }
  }
  # HTTP Listener -
  listeners = {
    ex-one = {
      port     = 25565
      protocol = "TCP"
      forward = {
        target_group_key = "ex-target-one"
      }
    },
    ex-two = {
      port     = 8080
      protocol = "TCP"
      forward = {
        target_group_key = "ex-target-two"
      }
    },

  }
  # Target Groups
  target_groups = {
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
        interval            = 30
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "TCP"
      }
    }
    ex-target-two = {
      protocol                          = "TCP"
      port                              = 8080
      target_type                       = "ip"
      deregistration_delay              = 10
      create_attachment                 = false
      load_balancing_cross_zone_enabled = false
    }
  }
  enable_deletion_protection = false

}

resource "null_resource" "send_slack_notification" {
  provisioner "local-exec" {
    command     = "bash send_to_slack.sh https://hooks.slack.com/services/${var.slack_webhook_path} ${module.nlb.dns_name}"
    working_dir = "../scripts/"
  }
}
