variable "aws_region" {
  description = "AWS region where the resources will be created"
  type        = string
  default     = "us-east-1" # Change this to your preferred region
}


# This variable is used to set the environment for tagging resources
variable "environment" {
  description = "Environment for tagging resources (e.g., dev, staging, prod)"
  type        = string
  default     = "dev" # Change this to your desired environment
}
