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
  type = string
}

variable "fluentbit_image_uri" {
  type = string
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

variable "efs_id" {
  description = "The ID that identifies the file system (e.g., `fs-ccfc0d65`)"
}

# iam
variable "task_execution_role_arn" {
  description = "The ARN of ecs task execution role"
}
variable "task_role_arn" {
  description = "The ARN of ecs task role"
}

########################################
# Define Local Values in Terraform     #
########################################

variable "owners" {}
variable "environment" {}
variable "aws_region" {}
variable "aws_account_id" {}

locals {
  owners      = var.owners
  environment = var.environment
  name        = "${var.owners}-${var.environment}"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
}
