output "public_subnet_one_id" {
  value       = aws_subnet.k8s_public_subnet_one.id
  description = "ID of the first public subnet in the Kubernetes VPC"
}

output "public_subnet_two_id" {
  value       = aws_subnet.k8s_public_subnet_two.id
  description = "ID of the second public subnet in the Kubernetes VPC"
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets in the Kubernetes VPC"
  value       = [
    aws_subnet.k8s_public_subnet_one.id, 
    aws_subnet.k8s_public_subnet_two.id
  ]
}

output "vpc_id" {
  value       = aws_vpc.k8s_vpc.id
  description = "ID of the Kubernetes VPC"
}

output "public_route_table_id" {
  value       = aws_route_table.k8s_public_rt.id
  description = "ID of the public route table associated with the Kubernetes VPC"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.k8s_igw.id
  description = "ID of the internet gateway attached to the Kubernetes VPC"
}

output "security_group_id" {
  value       = aws_security_group.k8s_sg.id
  description = "value of the security group for the Kubernetes cluster"
}

output "aws_region" {
  value       = var.aws_region
  description = "The AWS region where the Kubernetes VPC and resources are deployed"
}
output "availability_zones" {
  value       = data.aws_availability_zones.azs.names
  description = "List of availability zones in the AWS region"
}

