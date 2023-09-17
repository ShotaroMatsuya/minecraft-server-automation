resource "aws_sns_topic" "main" {
  name                                     = "${local.name}-sns-topic"
  application_success_feedback_sample_rate = "0"
  content_based_deduplication              = "false"
  display_name                             = "Reserved for notifications from AWS Chatbot to Slack"
  fifo_topic                               = "false"
  firehose_success_feedback_sample_rate    = "0"
  http_success_feedback_sample_rate        = "0"
  lambda_success_feedback_sample_rate      = "0"
  kms_master_key_id = aws_kms_key.for_encrypt_sns_topic.id

  policy = <<POLICY
{
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Action": [
        "SNS:GetTopicAttributes",
        "SNS:SetTopicAttributes",
        "SNS:AddPermission",
        "SNS:RemovePermission",
        "SNS:DeleteTopic",
        "SNS:Subscribe",
        "SNS:ListSubscriptionsByTopic",
        "SNS:Publish",
        "SNS:Receive"
      ],
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Resource": "*",
      "Sid": "__default_statement_ID"
    },
    {
      "Action": "sns:Publish",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Resource": "*",
      "Sid": "__default_statement_ID2"
    }
  ],
  "Version": "2008-10-17"
}
POLICY

  tags = local.common_tags
}

resource "aws_sns_topic_subscription" "main" {
  endpoint             = "https://global.sns-api.chatbot.amazonaws.com"
  protocol             = "https"
  raw_message_delivery = "false"
  topic_arn            = aws_sns_topic.main.arn
}

resource "aws_kms_key" "for_encrypt_sns_topic" {
  description         = "sns topic暗号化用"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.policy_for_encrypt_sns_topic.json
}


resource "aws_kms_alias" "for_encrypt_sns_topic_alias" {
  name          = "alias/guardduty/for_encrypt_sns_topic"
  target_key_id = aws_kms_key.for_encrypt_sns_topic.key_id
}

data "aws_iam_policy_document" "policy_for_encrypt_sns_topic" {
  version = "2012-10-17"

  # defaultでついてくるルートアカウントに対する権限設定
  statement {
    sid    = "Enable Root User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:root"]
    }

    actions = [
      "kms:*"
    ]

    resources = [
      "*",
    ]
  }
}