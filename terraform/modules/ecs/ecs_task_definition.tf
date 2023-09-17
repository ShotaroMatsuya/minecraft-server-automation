resource "aws_ecs_task_definition" "main" {
  volume {
    name = "data"
    efs_volume_configuration {
      file_system_id     = var.efs_id
      root_directory     = "/"
      transit_encryption = "DISABLED"

      authorization_config {
        iam = "DISABLED"
      }
    }
  }
  container_definitions = jsonencode(
    [
      {
        cpu : 0,
        environment : [
          { name : "EULA", value : "TRUE" }
        ],
        essential : true,
        image : var.mc_image_uri,
        logConfiguration : {
          logDriver : "awsfirelens"
        },
        mountPoints : [
          {
            containerPath : var.ecs_volume_path,
            sourceVolume : var.ecs_volume_name
          },
          {
            containerPath : var.efs_file_volume_path
            sourceVolume : var.efs_file_volume_name
          },
        ],
        name : var.mc_container_name,
        portMappings : [{
          containerPort : var.mc_container_port,
          hostPort : var.mc_container_port,
          protocol : "tcp"
        }],
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
