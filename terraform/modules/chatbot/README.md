## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_chatbot_slack_configuration"></a> [chatbot\_slack\_configuration](#module\_chatbot\_slack\_configuration) | waveaccounting/chatbot-slack-configuration/aws | 1.1.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_chatbot_notification_role_arn"></a> [chatbot\_notification\_role\_arn](#input\_chatbot\_notification\_role\_arn) | The ARN of chatbot notification only role | `any` | n/a | yes |
| <a name="input_chatbot_slack_id"></a> [chatbot\_slack\_id](#input\_chatbot\_slack\_id) | The ID of the Slack channel. To get the ID, open Slack, right click on the channel name in the left pane, then choose Copy Link. The channel ID is the 9-character string at the end of the URL. For example, ABCBBLZZZ. | `any` | n/a | yes |
| <a name="input_chatbot_slack_workspace_id"></a> [chatbot\_slack\_workspace\_id](#input\_chatbot\_slack\_workspace\_id) | The ID of the Slack workspace authorized with AWS Chatbot. To get the workspace ID, you must perform the initial authorization flow with Slack in the AWS Chatbot console. Then you can copy and paste the workspace ID from the console. For more details, see steps 1-4 in [Setting Up AWS Chatbot with Slack](https://docs.aws.amazon.com/chatbot/latest/adminguide/setting-up.html#Setup_intro) in the AWS Chatbot User Guide. | `any` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `any` | n/a | yes |
| <a name="input_owners"></a> [owners](#input\_owners) | n/a | `any` | n/a | yes |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | ARN of the SNS topic to subscribe to. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_chatbot_configuration_arn"></a> [chatbot\_configuration\_arn](#output\_chatbot\_configuration\_arn) | The ARN of the Chatbot Slack configuration |
| <a name="output_chatbot_stack_id"></a> [chatbot\_stack\_id](#output\_chatbot\_stack\_id) | The unique identifier for the stack. |
