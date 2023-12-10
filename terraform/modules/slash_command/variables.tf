variable "github_token" {
  type        = string
  description = "Github token"
  sensitive   = true
}

variable "github_user" {
  type        = string
  description = "repository owner name"
}

variable "github_repo" {
  type        = string
  description = "repository name"
}

variable "owners" {}
variable "environment" {}

locals {
  owners      = var.owners
  environment = var.environment
  name        = "${var.owners}-${var.environment}"
  common_tags = {
    owners      = local.owners
    environment = local.environment
  }
}
