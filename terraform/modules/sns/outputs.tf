output "sns_topic_arn" {
  description = "The ARN of the SNS topic, as a more obvious property (clone of id)"
  value       = aws_sns_topic.main.arn
}
output "sns_subscription_arn" {
  description = "ARN of the subscription."
  value       = aws_sns_topic_subscription.main.arn
}