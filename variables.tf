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

variable "jenkins_key_private" {
  description = "Path to the private SSH key file for accessing the Jenkins instance"
  type        = string
  default     = "~/.ssh/jenkins_key" 
  
}

# enable_jenkins variable to control the deployment of Jenkins
variable "enable_jenkins" {
  description = "Flag to enable or disable the Jenkins module"
  type        = bool
  default     = false 
}


