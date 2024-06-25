
##########################################################
# Terraform AWS Application Load Balancer (ALB) Outputs  #
##########################################################
output "this_lb_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.nlb.id
}

output "this_lb_arn" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.nlb.arn
}

output "this_lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.nlb.dns_name
}

output "this_lb_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch."
  value       = module.nlb.arn_suffix
}

output "this_lb_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records."
  value       = module.nlb.zone_id
}

output "http_tcp_listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created."
  value       = [for listener in module.nlb.listeners : listener.arn]
}

output "http_tcp_listener_ids" {
  description = "The IDs of the TCP and HTTP load balancer listeners created."
  value       = [for listener in module.nlb.listeners : listener.id]
}

output "target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value       = [for tg in module.nlb.target_groups : tg.arn]
}

output "target_group_arn_suffixes" {
  description = "ARN suffixes of our target groups - can be used with CloudWatch."
  value       = [for tg in module.nlb.target_groups : tg.arn_suffix]
}

output "target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = [for tg in module.nlb.target_groups : tg.name]
}
