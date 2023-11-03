# Terraform Block
terraform {
  required_version = "~> 1.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.59.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.0"
    }
  }
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "minecraft-backend"
    key    = "state/keeping/terraform.tfstate"
    region = "ap-northeast-1"
    # For State Locking
    dynamodb_table = "minecraft-statelocking"
  }
}

# Provider Block
provider "aws" {
  region = var.aws_region
}
# Create a Null Resource and provisioners
resource "null_resource" "name" {
  # Local Exec Provisioner: local-exec provisioner (Create-Time Provisioner - Triggered during Create Resource)
  provisioner "local-exec" {
    command     = "echo VPC created on `date` and VPC ID: ${module.custom_vpc.vpc_id} >> creation-time-vpc-id.txt"
    working_dir = "../local-exec-output-files/"
  }
}
