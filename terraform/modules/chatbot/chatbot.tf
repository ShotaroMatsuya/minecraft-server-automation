############################################################################
# Chatbot
############################################################################
# https://github.com/waveaccounting/terraform-aws-chatbot-slack-configuration
module "chatbot_slack_configuration" {
  source  = "waveaccounting/chatbot-slack-configuration/aws"
  version = "1.1.0"

  configuration_name = "${local.name}-chatbot"
  guardrail_policies = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  iam_role_arn       = var.chatbot_notification_role_arn
  slack_channel_id   = var.chatbot_slack_id
  slack_workspace_id = var.chatbot_slack_workspace_id
  sns_topic_arns     = [var.sns_topic_arn]
  user_role_required = false
  tags               = local.common_tags
}

