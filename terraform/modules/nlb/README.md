## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_nlb"></a> [nlb](#module\_nlb) | terraform-aws-modules/alb/aws | 8.7.0 |

## Resources

| Name | Type |
|------|------|
| [null_resource.send_slack_notification](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `any` | n/a | yes |
| <a name="input_owners"></a> [owners](#input\_owners) | #################################################### Terraform AWS Application Load Balancer Variables # Place holder file for AWS ALB Variables           # #################################################### | `any` | n/a | yes |
| <a name="input_slack_webhook_path"></a> [slack\_webhook\_path](#input\_slack\_webhook\_path) | Webhook url for notification of nlb\_dns address to slack ch when creation completion | `string` | n/a | yes |
| <a name="input_vpc_availability_zones"></a> [vpc\_availability\_zones](#input\_vpc\_availability\_zones) | VPC Availability Zones | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |
| <a name="input_vpc_public_subnet_ids"></a> [vpc\_public\_subnet\_ids](#input\_vpc\_public\_subnet\_ids) | VPC Public Subnet ids | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_http_tcp_listener_arns"></a> [http\_tcp\_listener\_arns](#output\_http\_tcp\_listener\_arns) | The ARN of the TCP and HTTP load balancer listeners created. |
| <a name="output_http_tcp_listener_ids"></a> [http\_tcp\_listener\_ids](#output\_http\_tcp\_listener\_ids) | The IDs of the TCP and HTTP load balancer listeners created. |
| <a name="output_nlb_dns_name"></a> [nlb\_dns\_name](#output\_nlb\_dns\_name) | DNS Name of nlb to register in route53 |
| <a name="output_target_group_arn_suffixes"></a> [target\_group\_arn\_suffixes](#output\_target\_group\_arn\_suffixes) | ARN suffixes of our target groups - can be used with CloudWatch. |
| <a name="output_target_group_arns"></a> [target\_group\_arns](#output\_target\_group\_arns) | ARNs of the target groups. Useful for passing to your Auto Scaling group. |
| <a name="output_target_group_attachments"></a> [target\_group\_attachments](#output\_target\_group\_attachments) | ARNs of the target group attachment IDs. |
| <a name="output_target_group_names"></a> [target\_group\_names](#output\_target\_group\_names) | Name of the target group. Useful for passing to your CodeDeploy Deployment Group. |
| <a name="output_this_lb_arn"></a> [this\_lb\_arn](#output\_this\_lb\_arn) | The ID and ARN of the load balancer we created. |
| <a name="output_this_lb_arn_suffix"></a> [this\_lb\_arn\_suffix](#output\_this\_lb\_arn\_suffix) | ARN suffix of our load balancer - can be used with CloudWatch. |
| <a name="output_this_lb_dns_name"></a> [this\_lb\_dns\_name](#output\_this\_lb\_dns\_name) | The DNS name of the load balancer. |
| <a name="output_this_lb_id"></a> [this\_lb\_id](#output\_this\_lb\_id) | The ID and ARN of the load balancer we created. |
| <a name="output_this_lb_zone_id"></a> [this\_lb\_zone\_id](#output\_this\_lb\_zone\_id) | The zone\_id of the load balancer to assist with creating DNS records. |
