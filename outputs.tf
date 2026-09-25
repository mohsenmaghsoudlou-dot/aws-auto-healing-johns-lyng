output "website_url" {
  description = "HTTP URL of the Application Load Balancer."
  value       = "http://${module.load_balancer.dns_name}"
}