variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1" # Default region, can be overridden

}

variable "ssh_key_private" {
  description = "Path to the private SSH key for accessing the instances"
  type        = string
  default     = "~/.ssh/docker" # Default path, can be overridden

}
variable "k8s_master_dependency" {
  description = "Dependency for the Kubernetes master node to ensure it is created before installing monitoring tools"
  type        = any
  default     = null
}
variable "k8s_master_eip" {
  description = "Elastic IP address of the Kubernetes master node"
  type        = string
  default     = null # Default value, can be overridden
}

variable "jenkins_key_private" {
  description = "Path to the private SSH key file for accessing the Jenkins instance"
  type        = string
  default     = "/home/administrator/.ssh/jenkins_key" # Default path to the private SSH key
  
}