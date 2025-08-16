variable "aws_region" {
  description = "The AWS region where the resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "k8s_master_dependency" {
  description = "Dependency for the Kubernetes master node to ensure it is created before installing monitoring tools."
  type        = any
  default     = null

}

variable "fetch_join_command_dependency" {
  description = "Dependency for fetching the join command to ensure it is available before installing monitoring tools."
  type        = any
  default     = null

}

variable "k8s_master_eip" {
  description = "Elastic IP address of the Kubernetes master node."
  type        = string
  default     = ""

}

variable "ssh_key_private" {
  description = "Path to the private SSH key file for accessing the instances."
  type        = string
  default     = "/home/administrator/.ssh/k8s-key"
}

variable "compute_dependency" {
  description = "deployment of app depends on compute module"
  type        = any

}