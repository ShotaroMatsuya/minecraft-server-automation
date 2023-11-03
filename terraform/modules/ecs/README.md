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
| [aws_ecs_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | n/a | `any` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `any` | n/a | yes |
| <a name="input_cluster_settings"></a> [cluster\_settings](#input\_cluster\_settings) | Configuration block(s) with cluster settings. For example, this can be used to enable CloudWatch Container Insights for a cluster | `map(string)` | n/a | yes |
| <a name="input_container_env"></a> [container\_env](#input\_container\_env) | Mapping Environment Variable Files to ECS | `any` | n/a | yes |
| <a name="input_ecs_volume_name"></a> [ecs\_volume\_name](#input\_ecs\_volume\_name) | n/a | `string` | n/a | yes |
| <a name="input_ecs_volume_path"></a> [ecs\_volume\_path](#input\_ecs\_volume\_path) | n/a | `string` | n/a | yes |
| <a name="input_efs_file_volume_name"></a> [efs\_file\_volume\_name](#input\_efs\_file\_volume\_name) | n/a | `string` | n/a | yes |
| <a name="input_efs_file_volume_path"></a> [efs\_file\_volume\_path](#input\_efs\_file\_volume\_path) | n/a | `string` | n/a | yes |
| <a name="input_efs_id"></a> [efs\_id](#input\_efs\_id) | The ID that identifies the file system (e.g., `fs-ccfc0d65`) | `string` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `any` | n/a | yes |
| <a name="input_fargate_cpu"></a> [fargate\_cpu](#input\_fargate\_cpu) | Fargate Cpu allocation | `number` | n/a | yes |
| <a name="input_fargate_memory"></a> [fargate\_memory](#input\_fargate\_memory) | Fargate Memory allocation | `number` | n/a | yes |
| <a name="input_fargate_security_group_id"></a> [fargate\_security\_group\_id](#input\_fargate\_security\_group\_id) | The ID of the security group | `any` | n/a | yes |
| <a name="input_firelens_log_group"></a> [firelens\_log\_group](#input\_firelens\_log\_group) | n/a | `string` | n/a | yes |
| <a name="input_fluentbit_image_uri"></a> [fluentbit\_image\_uri](#input\_fluentbit\_image\_uri) | n/a | `string` | n/a | yes |
| <a name="input_mc_container_name"></a> [mc\_container\_name](#input\_mc\_container\_name) | n/a | `string` | n/a | yes |
| <a name="input_mc_container_port"></a> [mc\_container\_port](#input\_mc\_container\_port) | n/a | `number` | n/a | yes |
| <a name="input_mc_image_uri"></a> [mc\_image\_uri](#input\_mc\_image\_uri) | n/a | `string` | n/a | yes |
| <a name="input_nlb_target_group_arns"></a> [nlb\_target\_group\_arns](#input\_nlb\_target\_group\_arns) | ARNs of the target groups. Useful for passing to your Auto Scaling group. | `any` | n/a | yes |
| <a name="input_owners"></a> [owners](#input\_owners) | n/a | `any` | n/a | yes |
| <a name="input_public_subnets_ids"></a> [public\_subnets\_ids](#input\_public\_subnets\_ids) | List of IDs of public subnets | `any` | n/a | yes |
| <a name="input_recovery_time"></a> [recovery\_time](#input\_recovery\_time) | Specify the time to restore | `string` | `null` | no |
| <a name="input_set_recovery_point"></a> [set\_recovery\_point](#input\_set\_recovery\_point) | Whether to restore data from a backup at a specific date and time | `bool` | `false` | no |
| <a name="input_task_execution_role_arn"></a> [task\_execution\_role\_arn](#input\_task\_execution\_role\_arn) | The ARN of ecs task execution role | `any` | n/a | yes |
| <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn) | The ARN of ecs task role | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_ecs_main_task_definition_arn"></a> [aws\_ecs\_main\_task\_definition\_arn](#output\_aws\_ecs\_main\_task\_definition\_arn) | Full ARN of the Main Task Definition (including both family and revision). |
| <a name="output_aws_ecs_main_task_definition_revision"></a> [aws\_ecs\_main\_task\_definition\_revision](#output\_aws\_ecs\_main\_task\_definition\_revision) | Revision of the task in a particular family. |
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | ARN that identifies the cluster |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | Name of the cluster. |
| <a name="output_ecs_service_associated_alb_iam"></a> [ecs\_service\_associated\_alb\_iam](#output\_ecs\_service\_associated\_alb\_iam) | ARN of IAM role used for ELB. |
| <a name="output_ecs_service_disired_count"></a> [ecs\_service\_disired\_count](#output\_ecs\_service\_disired\_count) | Number of instances of the task definition. |
| <a name="output_ecs_service_id"></a> [ecs\_service\_id](#output\_ecs\_service\_id) | ARN that identifies the service. |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | Name of the service. |
