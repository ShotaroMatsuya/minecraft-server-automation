data "aws_vpc" "myvpc" {
  id = "vpc-0e5468f3c81240453"
}

data "aws_security_group" "fargate_sg" {
  id = "sg-021594a535f976e96"
}

data "aws_iam_role" "task_role" {
  name = "ecs_tasks-minecraft-test-role"
}

data "aws_iam_role" "task_execution_role" {
  name = "minecraft-test-ecs_tasks_execution-role"
}

data "aws_efs_file_system" "my_efs" {
  file_system_id = "fs-0f3060484a112498b"
}

data "aws_sns_topic" "my_sns" {
  name = "${local.name}-sns-topic"
}

data "aws_subnets" "my_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.myvpc.id]
  }
}


module "custom_domain" {
  source = "../modules/domain"
  nlb_dns_name           = module.custom_nlb.nlb_dns_name
  nlb_zone_id            = module.custom_nlb.this_lb_zone_id

  owners      = local.owners
  environment = local.environment
}

module "custom_nlb" {
  source                 = "../modules/nlb"
  vpc_id                 = data.aws_vpc.myvpc.id
  vpc_availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]
  vpc_public_subnet_ids  = data.aws_subnets.my_subnets.ids

  owners      = local.owners
  environment = local.environment
}

module "custom_ecs" {
  source = "../modules/ecs"

  cluster_settings = {
    "name" : "containerInsights",
    "value" : "enabled"
  }
  fargate_cpu               = 2048
  fargate_memory            = 4096
  mc_image_uri              = "itzg/minecraft-server"
  fluentbit_image_uri       = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/minecraft/fluentbit"
  mc_container_name         = "minecraft"
  mc_container_port         = 25565
  firelens_log_group        = module.custom_cloudwatch.firelens_log_group_name
  ecs_volume_name           = "log-volume"
  ecs_volume_path           = "/data/logs"
  efs_file_volume_name      = "data"
  efs_file_volume_path      = "/data"
  nlb_target_group_arns     = module.custom_nlb.target_group_arns
  fargate_security_group_id = data.aws_security_group.fargate_sg.id
  public_subnets_ids        = data.aws_subnets.my_subnets.ids
  task_role_arn             = data.aws_iam_role.task_role.arn
  task_execution_role_arn   = data.aws_iam_role.task_execution_role.arn
  efs_id                    = data.aws_efs_file_system.my_efs.id

  owners         = local.owners
  environment    = local.environment
  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id
}

module "custom_cloudwatch" {
  source             = "../modules/cloudwatch"
  firelens_log_group = "/aws/ecs/minecraft-firelens-logs"
  sns_topic_arn      = data.aws_sns_topic.my_sns.arn
  ecs_cluster        = module.custom_ecs.ecs_cluster_name
  ecs_service        = module.custom_ecs.ecs_service_name

  owners      = local.owners
  environment = local.environment
}