resource "aws_ecs_task_definition" "main" {
  volume {
    name = "data"

    dynamic "efs_volume_configuration" {
      for_each = var.efs_id != null ? [1] : []
      content {
        file_system_id          = var.efs_id
        root_directory          = "/"
        transit_encryption      = "ENABLED"
        transit_encryption_port = 2999

        authorization_config {
          iam = "DISABLED"
        }
      }
    }
  }
  container_definitions = jsonencode(
    [
      {
        cpu : 0,
        environment = var.set_seed_value ? concat(var.container_env, [{ name : "SEED", value : var.seed_value }]) : var.container_env,
        essential : true,
        image : var.mc_image_uri,
        entrypoint = var.set_seed_value ? ["/scripts/entrypoint3.sh"] : (var.set_recovery_point ? ["/scripts/entrypoint2.sh"] : ["/scripts/entrypoint.sh"]),
        command    = var.set_seed_value ? [var.seed_value] : (var.set_recovery_point ? [var.recovery_time] : []),
        logConfiguration : {
          logDriver : "awsfirelens"
        },
        mountPoints = concat(
          [
            {
              containerPath = var.ecs_volume_path,
              sourceVolume  = var.ecs_volume_name
            }
          ],
          var.efs_id != null ? [
            {
              containerPath = var.efs_file_volume_path,
              sourceVolume  = var.efs_file_volume_name
            }
          ] : []
        ),
        name : var.mc_container_name,
        portMappings : [
          {
            containerPort : var.mc_container_port,
            hostPort : var.mc_container_port,
            protocol : "tcp"
          },
          {
            containerPort : 8080,
            hostPort : 8080,
            protocol : "tcp"
          },
        ],
      },
      {
        cpu : 0,
        essential : true,
        firelensConfiguration : {
          options : {
            config-file-type : "file",
            config-file-value : "/fluent-bit/etc/fluent-bit_custom.conf",
            enable-ecs-log-metadata : "true"
          },
          type : "fluentbit"
        },
        image : var.fluentbit_image_uri,
        logConfiguration : {
          logDriver : "awslogs",
          options : {
            awslogs-group : var.firelens_log_group,
            awslogs-region : var.aws_region,
            awslogs-stream-prefix : "firelens"
          }
        },
        mountPoints : [
          {
            containerPath : var.ecs_volume_path,
            sourceVolume : var.ecs_volume_name
          }
        ],
        name : "firelens_log_router",
        user : "0",
      }
  ])

  cpu                      = var.fargate_cpu
  execution_role_arn       = var.task_execution_role_arn
  family                   = local.name
  memory                   = var.fargate_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = var.task_role_arn

  volume {
    name = var.ecs_volume_name
  }
}
