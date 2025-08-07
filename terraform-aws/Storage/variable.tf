
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

variable "ssh_key_private" {
  description = "Path to the private SSH key for accessing the instances"
  type        = string
  default     = "/home/administrator/.ssh/docker" # Change this to your private key path
}

# This variable is used to create PVCs for local storage in Kubernetes
variable "k8s_master_eip" {
  description = "Elastic IP address of the Kubernetes master node"
  type        = string
  default     = ""
}

variable "k8s_master_dependency" {
  description = "Dependency for the Kubernetes master node"
  type        = string
  default     = ""
}

variable "fetch_join_command_dependency" {
  description = "Dependency for fetching the join command"
  type        = string
  default     = ""
}


# variable used for PVC Storage
variable "monitoring_dependency" {
  description = "Dependency for the monitoring module"
  type        = any
}


variable "enable_s3" {
  description = "Enable S3 storage"
  type        = bool
  default     = true
}

variable "enable_pvc_localstorage" {
  description = "Enable PVC local storage provisioning"
  type        = bool
  default     = true
}

variable "enable_dynamodb" {
  description = "Enable DynamoDB for state locking"
  type        = bool
  default     = false
}

variable "compute_dependency" {
  description = "Dependency for Compute Module"
  type = any
  
}