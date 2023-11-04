module "user_action_filter_function" {
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "4.1.1"
  function_name          = "user-action-filter-function"
  description            = "My awsome lambda function"
  handler                = "index.lambda_handler"
  runtime                = "python3.9"
  ephemeral_storage_size = 512
  architectures          = ["x86_64"]
  publish                = true
  timeout                = 360

  source_path = ["${path.module}/fixtures/python3.9/index.py"]

  environment_variables = {
    SNS_TOPIC_ARN = var.sns_topic_arn
    ALARM_SUBJECT = "【UserEvent Notification】"
    WEB_HOOK_URL  = var.slack_webhook_url
  }
  attach_policy_json = true
  policy_json        = <<-EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Action": [
        "SNS:Publish"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
  EOT
}

# CloudwatchLogsからLogの実行を許可
resource "aws_lambda_permission" "log_permission" {
  action        = "lambda:InvokeFunction"
  function_name = module.user_action_filter_function.lambda_function_arn
  principal     = "logs.ap-northeast-1.amazonaws.com"
  source_arn    = var.log_group_arn
}
