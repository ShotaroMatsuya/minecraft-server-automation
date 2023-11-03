resource "aws_cloudwatch_metric_alarm" "task_running_count" {
  actions_enabled     = "true"
  alarm_actions       = [var.sns_topic_arn]
  alarm_name          = "${local.name}-task_running_count"
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = "1"

  dimensions = {
    ClusterName = var.ecs_cluster
    ServiceName = var.ecs_service
  }

  evaluation_periods = "1"
  metric_name        = "RunningTaskCount"
  namespace          = "ECS/ContainerInsights"
  ok_actions         = [var.sns_topic_arn]
  period             = "60"
  statistic          = "Sum"
  threshold          = "1"
  treat_missing_data = "missing"
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  actions_enabled     = "true"
  alarm_actions       = [var.sns_topic_arn]
  alarm_name          = "${local.name}-cpu_utilization"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "1"

  dimensions = {
    "ClusterName" = var.ecs_cluster
    "ServiceName" = var.ecs_service
  }

  evaluation_periods = "1"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/ECS"
  ok_actions         = [var.sns_topic_arn]
  period             = "60"
  statistic          = "Maximum"
  threshold          = "90"
  treat_missing_data = "missing"
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  actions_enabled     = "true"
  alarm_actions       = [var.sns_topic_arn]
  alarm_name          = "${local.name}-memory_utilization"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "1"

  dimensions = {
    ClusterName = var.ecs_cluster
    ServiceName = var.ecs_service
  }

  evaluation_periods = "1"
  metric_name        = "MemoryUtilization"
  namespace          = "AWS/ECS"
  ok_actions         = [var.sns_topic_arn]
  period             = "60"
  statistic          = "Maximum"
  threshold          = "80"
  treat_missing_data = "missing"
}


resource "aws_cloudwatch_metric_alarm" "target_group_health_check" {
  actions_enabled     = "true"
  alarm_name          = "${local.name}-targetgroup_healthy"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/NetworkELB"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "This metric monitors ecs health status"
  ok_actions          = [var.sns_topic_arn]
  alarm_actions       = [var.sns_topic_arn]
  treat_missing_data  = "breaching"

  dimensions = {
    TargetGroup  = var.target_group_arn_suffixes[0]
    LoadBalancer = var.this_lb_arn_suffix
  }
}