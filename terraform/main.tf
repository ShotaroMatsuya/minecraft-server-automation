module "custom_vpc" {
  source                 = "./modules/vpc"
  vpc_name               = "myvpc"
  vpc_cidr_block         = "10.0.0.0/16"
  vpc_availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]
  vpc_public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  nlb_dns_name           = module.custom_nlb.nlb_dns_name
  nlb_zone_id            = module.custom_nlb.this_lb_zone_id

  owners      = local.owners
  environment = local.environment
}

module "custom_iam" {
  source = "./modules/iam"

  owners         = local.owners
  environment    = local.environment
  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id
}

module "custom_nlb" {
  source                 = "./modules/nlb"
  vpc_id                 = module.custom_vpc.vpc_id
  vpc_availability_zones = module.custom_vpc.azs
  vpc_public_subnet_ids  = module.custom_vpc.public_subnets

  owners      = local.owners
  environment = local.environment
}

module "custom_ecs" {
  source = "./modules/ecs"
  depends_on = [
    module.custom_vpc,
    module.custom_efs
  ]
  cluster_settings = {
    "name" : "containerInsights",
    "value" : "enabled"
  }
  fargate_cpu               = 1024
  fargate_memory            = 2048
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
  fargate_security_group_id = module.custom_vpc.fargate_sg_group_id
  public_subnets_ids        = module.custom_vpc.public_subnets
  task_execution_role_arn   = module.custom_iam.ecs_task_execution_role_arn
  task_role_arn             = module.custom_iam.ecs_task_role_arn
  efs_id                    = module.custom_efs.efs_id

  owners         = local.owners
  environment    = local.environment
  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id
}

module "custom_efs" {
  source                     = "./modules/efs"
  vpc_id                     = module.custom_vpc.vpc_id
  azs                        = module.custom_vpc.azs
  public_subnets             = module.custom_vpc.public_subnets
  public_subnets_cidr_blocks = module.custom_vpc.public_subnets_cidr_blocks
  security_group_id          = module.custom_vpc.allow_nfs_sg_group_id

  owners      = local.owners
  environment = local.environment
}

module "custom_cloudwatch" {
  source             = "./modules/cloudwatch"
  firelens_log_group = "/aws/ecs/minecraft-firelens-logs"
  sns_topic_arn      = module.custom_sns.sns_topic_arn
  ecs_cluster        = module.custom_ecs.ecs_cluster_name
  ecs_service        = module.custom_ecs.ecs_service_name

  owners      = local.owners
  environment = local.environment
}

module "custom_sns" {
  source = "./modules/sns"

  owners      = local.owners
  environment = local.environment
  aws_account_id = var.aws_account_id
}

module "custom_chatbot" {
  source                        = "./modules/chatbot"
  sns_topic_arn                 = module.custom_sns.sns_topic_arn
  chatbot_slack_workspace_id    = var.slack_workspace_id
  chatbot_slack_id              = var.slack_channel_id
  chatbot_notification_role_arn = module.custom_iam.chatbot_notification_role_arn

  owners      = local.owners
  environment = local.environment
}
