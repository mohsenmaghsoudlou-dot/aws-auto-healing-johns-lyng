output "dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "security_group_id" {
  description = "Security group ID of the Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "target_group_arn" {
  description = "ARN of the target group for the web instances."
  value       = aws_lb_target_group.web.arn
}