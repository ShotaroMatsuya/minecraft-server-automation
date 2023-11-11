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

variable "aws_account_id" {
  description = "Account ID in which AWS Resoruces to be created"
  type        = string
  sensitive   = true
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

variable "env_files" {
  description = "A list of files to be passed to ECS as environment variables."
  type        = list(string)
  sensitive   = true
}

variable "WEBHOOK_PATH" {
  sensitive = true
}

variable "set_recovery_point" {
  description = "Whether to retrieve world data from a specific recovery point when restoring"
  type        = bool
  default     = false
}

variable "recovery_time" {
  description = "Specify backup file creation time when set_recover_point is true"
  type        = string
}

locals {
  owners      = var.owners
  environment = var.environment
  name        = "${var.owners}-${var.environment}"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }

  merged_decoded_yaml = merge([for f in var.env_files : yamldecode(file(f))]...)
  updated_list        = { for k, v in local.merged_decoded_yaml : k => v if k != "FILTERING_STRINGS" }
  container_env       = [for var_name, val in local.updated_list : { name = var_name, value = val }]

  filtering_strings = lookup(local.merged_decoded_yaml, "FILTERING_STRINGS")
  formatted_strings = [for word in local.filtering_strings : format("($.log = \"%s\")", word)]
  combined_string   = join(" || ", local.formatted_strings)
}
