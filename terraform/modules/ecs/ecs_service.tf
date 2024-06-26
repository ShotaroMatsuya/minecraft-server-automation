resource "aws_ecs_service" "main" {
  cluster = aws_ecs_cluster.main.id

  deployment_circuit_breaker {
    enable   = "true"
    rollback = "true"
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  desired_count                      = "1"
  enable_ecs_managed_tags            = "false"
  enable_execute_command             = "true"
  health_check_grace_period_seconds  = "60"
  launch_type                        = "FARGATE"

  load_balancer {
    container_name   = var.mc_container_name
    container_port   = var.mc_container_port
    target_group_arn = element(var.nlb_target_group_arns, 0)
  }
  load_balancer {
    container_name   = var.mc_container_name
    container_port   = 8080
    target_group_arn = element(var.nlb_target_group_arns, 1)
  }

  name = "${local.name}-service"

  network_configuration {
    assign_public_ip = "true"
    security_groups  = [var.fargate_security_group_id]
    subnets          = var.public_subnets_ids
  }

  platform_version    = "LATEST"
  scheduling_strategy = "REPLICA"
  task_definition     = aws_ecs_task_definition.main.family

  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [
    aws_ecs_task_definition.main
  ]
  provisioner "local-exec" {
    command     = "echo Destroy time prov `date` >> destroy-time-prov.txt"
    working_dir = "../local-exec-output-files/"
    when        = destroy
    #on_failure = continue
  }
}
