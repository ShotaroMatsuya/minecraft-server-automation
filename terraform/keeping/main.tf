module "custom_vpc" {
  source                 = "../modules/vpc"
  vpc_name               = "myvpc"
  vpc_cidr_block         = "10.0.0.0/16"
  vpc_availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]
  vpc_public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]

  owners      = local.owners
  environment = local.environment
}

module "custom_iam" {
  source = "../modules/iam"

  owners         = local.owners
  environment    = local.environment
  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id
}

# module "custom_efs" {
#   source                     = "../modules/efs"
#   vpc_id                     = module.custom_vpc.vpc_id
#   azs                        = module.custom_vpc.azs
#   public_subnets             = module.custom_vpc.public_subnets
#   public_subnets_cidr_blocks = module.custom_vpc.public_subnets_cidr_blocks
#   security_group_id          = module.custom_vpc.allow_nfs_sg_group_id

#   owners      = local.owners
#   environment = local.environment
# }

module "custom_sns" {
  source = "../modules/sns"

  owners         = local.owners
  environment    = local.environment
  aws_account_id = var.aws_account_id
}

module "custom_chatbot" {
  source                        = "../modules/chatbot"
  sns_topic_arn                 = module.custom_sns.sns_topic_arn
  chatbot_slack_workspace_id    = var.slack_workspace_id
  chatbot_slack_id              = var.slack_channel_id
  chatbot_notification_role_arn = module.custom_iam.chatbot_notification_role_arn

  owners      = local.owners
  environment = local.environment
}

module "custom_iam_role_for_github" {
  source = "../modules/github"

  account_id  = var.aws_account_id
  github_org  = var.github_org
  github_repo = var.github_repo

  owners      = local.owners
  environment = local.environment
}

module "custom_slash_command" {
  source = "../modules/slash_command"

  github_token = var.github_token
  github_user  = var.github_org
  github_repo  = var.github_repo

  owners      = local.owners
  environment = local.environment

}
