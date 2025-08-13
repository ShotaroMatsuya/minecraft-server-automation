resource "aws_ecs_cluster" "main" {
  name = "${local.name}-cluster"

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
