output "nlb_target_group_arns" {
  value = module.custom_nlb.target_group_arns
}

output "target_group_arn_suffixes" {
  value = module.custom_nlb.target_group_arn_suffixes
}

output "ecs_task_definition" {
  value     = module.custom_ecs.aws_ecs_task_definition_json
  sensitive = true
}
