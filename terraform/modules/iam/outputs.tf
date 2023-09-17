
output "ecs_task_role_arn" {
  description = "The ARN of ecs task role"
  value       = aws_iam_role.main_ecs_tasks.arn
}

output "ecs_task_execution_role_arn" {
  description = "The ARN of ecs task execution role"
  value       = aws_iam_role.task_execution_role.arn
}

output "chatbot_notification_role_arn" {
  description = "The ARN of chatbot notification only role"
  value = aws_iam_role.chatbot-notification-only.arn
}