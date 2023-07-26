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


variable "sns_topic_arn" {
  description = "ARN of the SNS topic to subscribe to."
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
