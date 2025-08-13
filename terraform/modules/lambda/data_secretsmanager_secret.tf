data "aws_secretsmanager_secret" "github_app_secret" {
  name = "minecraft-test/creeper-action-secret"
}

output "github_app_secret_arn" {
  value = data.aws_secretsmanager_secret.github_app_secret.arn
}
