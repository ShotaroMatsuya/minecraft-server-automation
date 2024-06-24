
variable "log_group_name" {
  type        = string
  description = "The name of cloudwatch log group to apply subscription filter via lambda"
}

variable "log_group_arn" {
  type        = string
  description = "The ARN of cloudwatch log group to apply subscription filter via lambda"
}

variable "filter_patterns" {
  description = "List of filter patterns for creating subscription filters"
  type        = list(string)
  default = [
    "{ ($.log = \"<*\") }",
    "{ ($.log = \"ERROR*\") }",
  ]
}

variable "sns_topic_arn" {
  type        = string
  description = "The ARN of the SNS topic, as a more obvious property (clone of id)"
}

variable "slack_webhook_url" {
  type        = string
  description = "webhook url for sending notification to specific slack channel"
  sensitive   = true
}

variable "sns_kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key to use for encryption"
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
