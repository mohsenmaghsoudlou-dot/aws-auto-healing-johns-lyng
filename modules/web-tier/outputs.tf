output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group managing the web instances."
  value       = aws_autoscaling_group.web.name
}
