output "ecs_cluster_id" {
  description = "ARN that identifies the cluster"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_name" {
  description = "Name of the cluster."
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_id" {
  description = "ARN that identifies the service."
  value       = aws_ecs_service.main.id
}

output "ecs_service_disired_count" {
  description = "Number of instances of the task definition."
  value       = aws_ecs_service.main.desired_count
}

output "ecs_service_associated_alb_iam" {
  description = "ARN of IAM role used for ELB."
  value       = aws_ecs_service.main.iam_role
}

output "ecs_service_name" {
  description = "Name of the service."
  value       = aws_ecs_service.main.name
}

output "aws_ecs_main_task_definition_arn" {
  description = "Full ARN of the Main Task Definition (including both family and revision)."
  value       = aws_ecs_task_definition.main.arn
}

output "aws_ecs_main_task_definition_revision" {
  description = "Revision of the task in a particular family."
  value       = aws_ecs_task_definition.main.revision
}

/*
output "aws_cloudwatch_firelens_log_group_id" {
  value = aws_cloudwatch_log_group.firelens.id
}
*/
