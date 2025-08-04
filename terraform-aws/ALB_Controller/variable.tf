variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1" # Default region can be changed as needed
  
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be deployed"
  type        = string
}

variable "security_group" {
  description = "The security group to associate with the ALB"
  type        = string
  
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "k8s_worker_instances" {
  description = "List of Kubernetes worker instances"
  type        = list(string)

}