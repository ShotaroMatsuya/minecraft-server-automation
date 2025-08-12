variable "owners" {}
variable "environment" {}
locals {
  name = "${var.owners}-${var.environment}"
}
variable "chatbot_slack_id" {
  description = "The ID of the Slack channel. To get the ID, open Slack, right click on the channel name in the left pane, then choose Copy Link. The channel ID is the 9-character string at the end of the URL. For example, ABCBBLZZZ."
  sensitive   = true
}

variable "chatbot_slack_workspace_id" {
  description = "The ID of the Slack workspace authorized with AWS Chatbot. To get the workspace ID, you must perform the initial authorization flow with Slack in the AWS Chatbot console. Then you can copy and paste the workspace ID from the console. For more details, see steps 1-4 in [Setting Up AWS Chatbot with Slack](https://docs.aws.amazon.com/chatbot/latest/adminguide/setting-up.html#Setup_intro) in the AWS Chatbot User Guide."
  sensitive   = true
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic to subscribe to."
}

variable "chatbot_notification_role_arn" {
  description = "The ARN of chatbot notification only role"
}


