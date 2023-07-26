resource "aws_sns_topic" "main" {
  name                                     = "${local.name}-sns-topic"
  application_success_feedback_sample_rate = "0"
  content_based_deduplication              = "false"
  display_name                             = "Reserved for notifications from AWS Chatbot to Slack"
  fifo_topic                               = "false"
  firehose_success_feedback_sample_rate    = "0"
  http_success_feedback_sample_rate        = "0"
  lambda_success_feedback_sample_rate      = "0"

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
