variable "aws_region" {
  description = "AWS region where the resources will be created"
  type        = string
  default     = "us-east-1" # Default AWS region, can be overridden
}

variable "jenkins_key_public" {
  description = "Path to the public SSH key file for accessing the Jenkins instance"
  type        = string
  default     = "~/.ssh/jenkins_key.pub" # Default path to the public SSH key
}

variable "jenkins_key_private" {
  description = "Path to the private SSH key file for accessing the Jenkins instance"
  type        = string
  default     = "/home/administrator/.ssh/jenkins_key" # Default path to the private SSH key
}

variable "jenkins_ami" {
    description = "AMI ID for the Jenkins instance"
    type        = string
    default     = "ami-020cba7c55df1f615" # Example AMI, replace with your desired AMI
}

variable "jenkins_instance_type" {
  description = "value for the instance type of the Jenkins instance"
  type        = string
  default     = "t3.medium" # Example instance type, replace with your desired type
}

variable "jenkins_disk_size" {
  description = "Size of the root block device for the Jenkins instance in GB"
  type        = number
  default     = 20 # Default size, can be adjusted as needed
}

variable "vpc_id" {
  description = "VPC ID where the Jenkins instance will be deployed"
  type        = string
}

variable "jenkins_public_subnet" {
  description = "Subnet ID for the Jenkins instance"
  type        = string
}

variable "jenkins_sg" {
  description = "Security group ID for the Jenkins instance"
  type        = string
  default     = "sg-123456789" # Example security group ID, replace with your desired security group
}

