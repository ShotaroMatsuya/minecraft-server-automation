variable "owners" {}
variable "environment" {}
locals {
  name = "${var.owners}-${var.environment}"
}
##########################
# ECS Input Variables    #
# ECS Cluster Name       #
##########################
variable "cluster_settings" {
  description = "Configuration block(s) with cluster settings. For example, this can be used to enable CloudWatch Container Insights for a cluster"
  type        = map(string)
}

variable "fargate_cpu" {
  type        = number
  description = "Fargate Cpu allocation"
}

variable "fargate_memory" {
  type        = number
  description = "Fargate Memory allocation"
}

variable "mc_image_uri" {
  type      = string
  sensitive = true
}

variable "fluentbit_image_uri" {
  type      = string
  sensitive = true
}

variable "mc_container_name" {
  type = string
}

variable "mc_container_port" {
  type = number
}

variable "firelens_log_group" {
  type = string
}

variable "ecs_volume_name" {
  type = string
}

variable "ecs_volume_path" {
  type = string
}

variable "efs_file_volume_name" {
  type = string
}

variable "efs_file_volume_path" {
  type = string
}

# nlb target group arns
variable "nlb_target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
}
# security group
variable "fargate_security_group_id" {
  description = "The ID of the security group"
}
# subnets
variable "public_subnets_ids" {
  description = "List of IDs of public subnets"
}

variable "container_env" {
  description = "Mapping Environment Variable Files to ECS"
  sensitive   = true
}

variable "efs_id" {
  description = "The ID that identifies the file system (e.g., `fs-ccfc0d65`)"
  type        = string
  default     = null
}

# iam
variable "task_execution_role_arn" {
  description = "The ARN of ecs task execution role"
}
variable "task_role_arn" {
  description = "The ARN of ecs task role"
}

variable "set_recovery_point" {
  description = "Whether to restore data from a backup at a specific date and time"
  type        = bool
  default     = false
}

variable "recovery_time" {
  description = "Specify the time to restore"
  type        = string
  default     = null
}

variable "set_seed_value" {
  description = "Whether to set the seed value when restoring"
  type        = bool
  default     = false
}

variable "seed_value" {
  description = "Specify the seed value when set_seed_value is true"
  type        = string
  default     = ""
}

########################################
# Define Local Values in Terraform     #
########################################

variable "aws_region" {}
variable "aws_account_id" {}

