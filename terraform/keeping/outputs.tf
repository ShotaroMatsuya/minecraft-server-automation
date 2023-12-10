output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.custom_vpc.vpc_id
}

output "fargate_sg_group_id" {
  description = "The ID of the security group"
  value       = module.custom_vpc.fargate_sg_group_id
}


output "ecs_task_role" {
  description = "The name of ecs task role"
  value       = module.custom_iam.ecs_task_role_name
}

output "ecs_task_execution_role" {
  description = "The name of ecs task execution role"
  value       = module.custom_iam.ecs_task_execution_role_name
}

# output "lambda_endpoint_url" {
#   description = "used when triggering lambda from slash cmd in slack"
#   value       = module.custom_slash_command.lambda_function_url
# }

# output "efs_id" {
#   description = "The ID that identifies the file system (e.g., `fs-ccfc0d65`)"
#   value       = module.custom_efs.efs_id
# }
