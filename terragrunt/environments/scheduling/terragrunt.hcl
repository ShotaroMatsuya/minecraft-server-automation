# Include the root terragrunt.hcl configuration
include "root" {
  path = find_in_parent_folders()
}

# Read the root terragrunt.hcl to access local variables
locals {
  # Read root configuration
  root_config = read_terragrunt_config(find_in_parent_folders())

  # Extract module versions from root config
  module_versions = local.root_config.locals.module_versions
  aws_region      = local.root_config.locals.aws_region
}

# Terraform source configuration
terraform {
  source = "../../../terraform//scheduling"
}

# Dependencies - scheduling depends on keeping resources
dependencies {
  paths = ["../keeping"]
}

# Environment-specific inputs
inputs = {
  # AWS configuration
  aws_region     = local.aws_region
  aws_account_id = get_env("AWS_ACCOUNT_ID", "123456789012") # Set your account ID

  # Service tag for scheduling environment
  service     = "scheduling"
  owners      = "minecraft"

  # Scheduling-specific settings
  minecraft_server_enable = true
  auto_scaling_enabled    = true
}

# Override remote state key for scheduling environment
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "minecraft-backend"
    key            = "state/scheduling/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "minecraft-statelocking"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
