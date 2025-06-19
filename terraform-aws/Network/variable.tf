variable "aws_region" {
  description = "The AWS region to deploy resources includes VPC, subnets, and security groups."
  type        = string
  default     = "us-east-1" # Default region, can be overridden  
}
