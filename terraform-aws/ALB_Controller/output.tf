output "k8s_alb_dns_name" {
  description = "DNS name of the Application Load Balancer (ALB)"
  value       = aws_lb.k8s_alb.dns_name
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets in the Kubernetes VPC"
  value       = var.public_subnet_ids
}

output "k8s_worker_instances" {
  description = "List of Kubernetes worker instances"
  value       = var.k8s_worker_instances
}

output "sockshop_alb_target_group_arn" {
  description = "ARN of the target group for the sock-shop application"
  value       = aws_lb_target_group.sockshop_alb_target_group.arn
}

output "prometheus_alb_target_group_arn" {
  description = "ARN of the target group for Prometheus"
  value       = aws_lb_target_group.prometheus_alb_target_group.arn
}

output "grafana_alb_target_group_arn" {
  description = "ARN of the target group for Grafana"
  value       = aws_lb_target_group.grafana_alb_target_group.arn
}