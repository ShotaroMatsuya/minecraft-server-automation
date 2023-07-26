resource "aws_cloudwatch_log_group" "firelens" {
  name              = var.firelens_log_group
  retention_in_days = 14
}

