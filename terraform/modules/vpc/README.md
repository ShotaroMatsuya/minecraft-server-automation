## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_allow_nfs_sg"></a> [allow\_nfs\_sg](#module\_allow\_nfs\_sg) | terraform-aws-modules/security-group/aws | 4.17.2 |
| <a name="module_fargate_sg"></a> [fargate\_sg](#module\_fargate\_sg) | terraform-aws-modules/security-group/aws | 4.17.2 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.19.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `any` | n/a | yes |
| <a name="input_owners"></a> [owners](#input\_owners) | n/a | `any` | n/a | yes |
| <a name="input_sg_rule_for_alb"></a> [sg\_rule\_for\_alb](#input\_sg\_rule\_for\_alb) | SG inbound rule for ALB | `list(map(any))` | `[]` | no |
| <a name="input_vpc_availability_zones"></a> [vpc\_availability\_zones](#input\_vpc\_availability\_zones) | VPC Availability Zones | `list(string)` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | VPC CIDR Block | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | VPC Name | `string` | n/a | yes |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | VPC Public Subnets | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_allow_nfs_sg_group_id"></a> [allow\_nfs\_sg\_group\_id](#output\_allow\_nfs\_sg\_group\_id) | The ID of the security group |
| <a name="output_allow_nfs_sg_group_name"></a> [allow\_nfs\_sg\_group\_name](#output\_allow\_nfs\_sg\_group\_name) | The name of the security group |
| <a name="output_allow_nfs_sg_group_vpc_id"></a> [allow\_nfs\_sg\_group\_vpc\_id](#output\_allow\_nfs\_sg\_group\_vpc\_id) | The VPC ID |
| <a name="output_azs"></a> [azs](#output\_azs) | A list of availability zones spefified as argument to this module |
| <a name="output_fargate_sg_group_id"></a> [fargate\_sg\_group\_id](#output\_fargate\_sg\_group\_id) | The ID of the security group |
| <a name="output_fargate_sg_group_name"></a> [fargate\_sg\_group\_name](#output\_fargate\_sg\_group\_name) | The name of the security group |
| <a name="output_fargate_sg_group_vpc_id"></a> [fargate\_sg\_group\_vpc\_id](#output\_fargate\_sg\_group\_vpc\_id) | The VPC ID |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of IDs of public subnets |
| <a name="output_public_subnets_cidr_blocks"></a> [public\_subnets\_cidr\_blocks](#output\_public\_subnets\_cidr\_blocks) | List of CIDR Blocks of public subnets |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
