resource "aws_cloudwatch_log_subscription_filter" "user-action_subscription" {
  for_each        = { for index, pattern in var.filter_patterns : index => pattern }
  name            = "user-action-subscription-${each.key}"
  log_group_name  = var.log_group_name
  filter_pattern  = each.value
  destination_arn = module.user_action_filter_function.lambda_function_arn
  distribution    = "ByLogStream"
}
