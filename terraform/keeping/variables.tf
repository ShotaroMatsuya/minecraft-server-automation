# Input Variables
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
}
# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
}
# Owners
variable "owners" {
  description = "username who created this resource"
  type        = string
}

variable "service" {
  description = "Service type (keeping or scheduling)"
  type        = string
}

variable "aws_account_id" {
  description = "Account ID in which AWS Resoruces to be created"
  type        = string
}

variable "slack_workspace_id" {
  description = "The ID of the Slack workspace authorized with AWS Chatbot. To get the workspace ID, you must perform the initial authorization flow with Slack in the AWS Chatbot console. Then you can copy and paste the workspace ID from the console. For more details, see steps 1-4 in [Setting Up AWS Chatbot with Slack](https://docs.aws.amazon.com/chatbot/latest/adminguide/setting-up.html#Setup_intro) in the AWS Chatbot User Guide."
  type        = string
  sensitive   = true
}

variable "slack_channel_id" {
  description = "The ID of the Slack channel. To get the ID, open Slack, right click on the channel name in the left pane, then choose Copy Link. The channel ID is the 9-character string at the end of the URL. For example, ABCBBLZZZ."
  type        = string
  sensitive   = true
}

variable "github_org" {
  description = "github organization name"
  type        = string
}

variable "github_repo" {
  description = "github repository name"
  type        = string
}

variable "github_token" {
  description = "github token"
  type        = string
  sensitive   = true
}

variable "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
  sensitive   = true
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

locals {
  owners      = var.owners
  environment = var.environment
  service     = var.service
  name        = "${var.owners}-${var.environment}"
  common_tags = {
    owners  = local.owners
    service = local.service
  }
}
