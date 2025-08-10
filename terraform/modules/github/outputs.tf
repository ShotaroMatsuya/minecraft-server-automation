output "openid_connect_provider_arn" {
  description = "ARN of the GitHub Actions OpenID Connect provider"
  value       = data.aws_iam_openid_connect_provider.github_actions.arn
}

output "openid_connect_provider_url" {
  description = "URL of the GitHub Actions OpenID Connect provider"
  value       = data.aws_iam_openid_connect_provider.github_actions.url
}

output "openid_connect_provider_client_id_list" {
  description = "Client ID list of the GitHub Actions OpenID Connect provider"
  value       = data.aws_iam_openid_connect_provider.github_actions.client_id_list
}

output "openid_connect_provider_thumbprint_list" {
  description = "Thumbprint list of the GitHub Actions OpenID Connect provider"
  value       = data.aws_iam_openid_connect_provider.github_actions.thumbprint_list
}