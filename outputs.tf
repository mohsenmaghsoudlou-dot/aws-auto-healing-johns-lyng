output "website_url" {
  description = "HTTP URL of the Application Load Balancer."
  value       = "http://${module.load_balancer.dns_name}"
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name used for health and replacement checks."
  value       = module.web_tier.autoscaling_group_name
}

output "target_group_arn" {
  description = "Target group ARN used to inspect instance health."
  value       = module.load_balancer.target_group_arn
}