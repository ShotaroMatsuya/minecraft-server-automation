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
| [aws_route53_record.apps_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.mydomain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `any` | n/a | yes |
| <a name="input_nlb_dns_name"></a> [nlb\_dns\_name](#input\_nlb\_dns\_name) | DNS Name of nlb to register in route53 | `string` | n/a | yes |
| <a name="input_nlb_zone_id"></a> [nlb\_zone\_id](#input\_nlb\_zone\_id) | nlb zone id to register in route53 | `string` | n/a | yes |
| <a name="input_owners"></a> [owners](#input\_owners) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mydomain_name"></a> [mydomain\_name](#output\_mydomain\_name) | The Hosted Zone name of the desired Hosted Zone. |
| <a name="output_mydomain_zoneid"></a> [mydomain\_zoneid](#output\_mydomain\_zoneid) | The Hosted Zone id of the desired Hosted Zone |
