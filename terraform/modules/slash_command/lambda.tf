
module "dispatch_backup_function" {
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "7.7.0"
  function_name          = "dispatch_workflow_from_slack-function"
  description            = "My awsome lambda function"
  handler                = "index.lambda_handler"
  runtime                = "python3.9"
  ephemeral_storage_size = 512
  architectures          = ["x86_64"]
  publish                = true
  timeout                = 360

  recreate_missing_package = false

  source_path = [{
    path             = "${path.module}/fixtures/python3.9"
    pip_requirements = true
  }]
  create_lambda_function_url = true

  environment_variables = {
    GITHUB_TOKEN = var.github_token
    REPO_OWNER   = var.github_user
    REPO_NAME    = var.github_repo
  }
  attach_policy_json = true
  policy_json        = <<-EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "ssm:GetParameter"
      ],
      "Resource": "*"
    }
  ]
}
EOT
}
