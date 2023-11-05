## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_user_action_filter_function"></a> [user\_action\_filter\_function](#module\_user\_action\_filter\_function) | terraform-aws-modules/lambda/aws | 4.1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_subscription_filter.user-action_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_lambda_permission.log_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `any` | n/a | yes |
| <a name="input_filter_patterns"></a> [filter\_patterns](#input\_filter\_patterns) | List of filter patterns for creating subscription filters | `list(string)` | <pre>[<br>  "{ ($.log = \"<*\") }",<br>  "{ ($.log = \"ERROR*\") }"<br>]</pre> | no |
| <a name="input_log_group_arn"></a> [log\_group\_arn](#input\_log\_group\_arn) | The ARN of cloudwatch log group to apply subscription filter via lambda | `string` | n/a | yes |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | The name of cloudwatch log group to apply subscription filter via lambda | `string` | n/a | yes |
| <a name="input_owners"></a> [owners](#input\_owners) | n/a | `any` | n/a | yes |
| <a name="input_slack_webhook_url"></a> [slack\_webhook\_url](#input\_slack\_webhook\_url) | webhook url for sending notification to specific slack channel | `string` | n/a | yes |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | The ARN of the SNS topic, as a more obvious property (clone of id) | `string` | n/a | yes |

## Outputs

No outputs.
