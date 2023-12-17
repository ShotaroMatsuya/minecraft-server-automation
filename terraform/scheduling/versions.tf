# Terraform Block
terraform {
  required_version = "~> 1.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "minecraft-backend"
    key    = "state/scheduling/terraform.tfstate"
    region = "ap-northeast-1"
    # For State Locking
    dynamodb_table = "minecraft-statelocking"
  }
}

# Provider Block
provider "aws" {
  region = var.aws_region
}
