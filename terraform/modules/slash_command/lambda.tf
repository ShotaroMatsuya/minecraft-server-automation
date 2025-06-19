
module "dispatch_backup_function" {
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "7.21.1"
  function_name          = "dispatch_workflow_from_slack-function"
  description            = "My awsome lambda function"
  handler                = "index.lambda_handler"
  runtime                = "python3.9"
  ephemeral_storage_size = 512
  architectures          = ["x86_64"]
  publish                = true
  timeout                = 360

  recreate_missing_package = true

  source_path = [{
    path             = "${path.module}/fixtures/python3.9"
    pip_requirements = true
  }]
  create_lambda_function_url = true

  environment_variables = {
    GITHUB_TOKEN     = var.github_token
    REPO_OWNER       = var.github_user
    REPO_NAME        = var.github_repo
    S3_BUCKET_NAME   = var.s3_bucket_name
    ECS_CLUSTER_NAME = "${local.name}-cluster"
    ECS_SERVICE_NAME = "${local.name}-service"
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
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::${var.s3_bucket_name}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::${var.s3_bucket_name}/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeTaskDefinition",
        "ecs:RegisterTaskDefinition",
        "ecs:UpdateService",
        "ecs:DescribeServices",
        "ecs:ListTaskDefinitions",
        "elasticloadbalancing:DescribeTargetHealth"
      ],
      "Resource": "*"
    },
    {
      "Action": [
          "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": [
          "arn:aws:iam::${var.aws_account_id}:role/${local.name}-ecs_tasks_execution-role",
          "arn:aws:iam::${var.aws_account_id}:role/ecs_tasks-${local.name}-role"
      ]
    }
  ]
}
EOT
}
