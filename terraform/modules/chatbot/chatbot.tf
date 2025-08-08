############################################################################
# Chatbot
############################################################################
# Using native AWS Chatbot resource with updated AWS provider
resource "aws_chatbot_slack_channel_configuration" "chatbot_slack_configuration" {
  configuration_name = "${local.name}-chatbot"
  iam_role_arn       = var.chatbot_notification_role_arn
  slack_channel_id   = var.chatbot_slack_id
  slack_team_id      = var.chatbot_slack_workspace_id
  sns_topic_arns     = [var.sns_topic_arn]

  guardrail_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  tags = local.common_tags
}

