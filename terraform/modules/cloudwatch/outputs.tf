output "firelens_log_group_name" {
  description = "The name of the log group"
  value = aws_cloudwatch_log_group.firelens.name
}