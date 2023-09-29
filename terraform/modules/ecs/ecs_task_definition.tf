resource "aws_ecs_task_definition" "main" {
  volume {
    name = "data"

    dynamic "efs_volume_configuration" {
      for_each = var.enable_efs ? [1] : []
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
        environment : [
          { name : "EULA", value : "TRUE" },
          { name : "OP_PERMISSION_LEVEL", value : "4" },
          { name : "DIFFICULTY", value : "hard" },
          { name : "MAX_PLAYERS", value : "4" },
          { name : "ENABLE_COMMAND_BLOCK", value : "true" },
          { name : "OPS", value : "2cffa334-b882-41ba-8e83-0bb4cb0d8769" },
          { name : "HARDCORE", value : "true" }
        ],
        essential : true,
        image : var.mc_image_uri,
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
          var.enable_efs ? [
            {
              containerPath = var.efs_file_volume_path,
              sourceVolume  = var.efs_file_volume_name
            }
          ] : []
        ),
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
