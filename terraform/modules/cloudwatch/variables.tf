variable "owners" {}
variable "environment" {}
locals {
  owners      = var.owners
  environment = var.environment
  name        = "${var.owners}-${var.environment}"
}
variable "firelens_log_group" {
  type = string
}

variable "ecs_cluster" {
  type        = string
  description = "Name of the cluster."
}
variable "ecs_service" {
  type        = string
  description = "Name of the service."
}

variable "target_group_arn_suffixes" {
  description = "ARN suffixes of our target groups - can be used with CloudWatch."
}

variable "this_lb_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch."
}


variable "sns_topic_arn" {
  description = "ARN of the SNS topic to subscribe to."
}

