# Root terragrunt.hcl
# This file contains global configuration shared across all environments

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "minecraft-backend"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "minecraft-statelocking"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Generate an AWS provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
# Terraform Block
terraform {
  required_version = ">= 1.9.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.8"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# Provider Block
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Owner       = var.owners
      Environment = var.environment
      Service     = var.service
    }
  }
}
EOF
}

# Common locals for version management
locals {
  # Module versions - centralized management
  module_versions = {
    lambda = "8.0.1"
    vpc    = "5.8.1"
    alb    = "9.10.0"
  }


  # AWS configuration
  aws_region = "ap-northeast-1"
}
