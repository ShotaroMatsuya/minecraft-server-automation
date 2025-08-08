output "chatbot_configuration_arn" {
  description = "The ARN of the Chatbot Slack configuration"
  value       = aws_chatbot_slack_channel_configuration.chatbot_slack_configuration.chat_configuration_arn
}

output "chatbot_stack_id" {
  description = "The unique identifier for the configuration."
  value       = aws_chatbot_slack_channel_configuration.chatbot_slack_configuration.configuration_name
}
