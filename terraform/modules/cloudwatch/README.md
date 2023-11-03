## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.firelens](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_metric_alarm.cpu_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.target_group_health_check](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.task_running_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ecs_cluster"></a> [ecs\_cluster](#input\_ecs\_cluster) | Name of the cluster. | `string` | n/a | yes |
| <a name="input_ecs_service"></a> [ecs\_service](#input\_ecs\_service) | Name of the service. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `any` | n/a | yes |
| <a name="input_firelens_log_group"></a> [firelens\_log\_group](#input\_firelens\_log\_group) | n/a | `string` | n/a | yes |
| <a name="input_owners"></a> [owners](#input\_owners) | n/a | `any` | n/a | yes |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | ARN of the SNS topic to subscribe to. | `any` | n/a | yes |
| <a name="input_target_group_arn_suffixes"></a> [target\_group\_arn\_suffixes](#input\_target\_group\_arn\_suffixes) | ARN suffixes of our target groups - can be used with CloudWatch. | `any` | n/a | yes |
| <a name="input_this_lb_arn_suffix"></a> [this\_lb\_arn\_suffix](#input\_this\_lb\_arn\_suffix) | ARN suffix of our load balancer - can be used with CloudWatch. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firelens_log_group_name"></a> [firelens\_log\_group\_name](#output\_firelens\_log\_group\_name) | The name of the log group |
