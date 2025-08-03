variable "ubuntu_ami" {
  description = "AMI ID for Ubuntu 24.04 in the specified AWS region"
  type        = string
  default     = "ami-020cba7c55df1f615" # Default AMI ID, can be overridden

}

variable "aws_region" {
  description = "AWS region where the resources will be created"
  type        = string
  default     = "us-east-1" # Default region, can be overridden
}

variable "master_az" {
  description = "availability zone of master node ebs volume"
  type        = string
  default     = "us-east-1a"
}

variable "master_instance_type" {
  description = "EC2 instance with Ubuntu 24.04, serving as a Kubernetes node"
  type        = string
  default     = "t3.large" # Default instance type, can be overridden
}
variable "worker_instance_type" {
  description = "EC2 instance type for worker nodes in the Kubernetes cluster"
  type        = string
  default     = "t3.large" # Default instance type for worker nodes, can be overridden
}
variable "worker_count" {
  description = "Number of worker nodes to create"
  type        = number
  default     = 2 # Default number of worker nodes
}

variable "master_disk_size" {
  description = "Size of the disk for the master node in GB"
  type        = number
  default     = 30 # Default disk size for the master node, can be overridden
}

variable "master_ebs_volume_size" {
  description = "Size of the EBS volume for the master node in GB"
  type        = number
  default     = 50

}


variable "worker_disk_size" {
  description = "Size of the disk for worker nodes in GB"
  type        = number
  default     = 30 # Default disk size for worker nodes, can be overridden
}

variable "ssh_key_public" {
  description = "Path to the public SSH key file for accessing the instances"
  type        = string
  #default    = "/home/administrator/.ssh/docker.pub" # Default path to the public SSH key
}
variable "ssh_key_private" {
  description = "Path to the private SSH key file for accessing the instances"
  type        = string
  default     = "/home/administrator/.ssh/docker" # Default path to the private SSH key

}
variable "security_group" {
  description = "Security group ID for the instances"
  type        = string
  default     = "sg-12345678" # Default security group ID, can be overridden

}

variable "public_subnet_one" {
  description = "ID of the first public subnet for the master node"
  type        = string
  default     = "subnet-12345678" # Default subnet ID, can be overridden

}
variable "public_subnet_two" {
  description = "List of IDs of public subnets for worker nodes"
  type        = list(string)
  default     = ["subnet-23456789", "subnet-34567890"] # Default subnet IDs for worker nodes, can be overridden
}

variable "vpc_id" {
  description = "ID of the VPC where the resources will be created"
  type        = string
  default     = "vpc-12345678" # Default VPC ID, can be overridden

} 

variable "instance_profile_name" {
  description = "Name of the IAM instance profile for EC2 instances to access S3"
  type        = string
  default     = "EC2S3UploadInstanceProfile" # Default instance profile name, can be overridden
}