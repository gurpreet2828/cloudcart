variable "worker_instance_type" {
  description = "Instance type for the worker nodes"
  type        = string
  default     = "t3.large" # Default instance type for worker nodes, can be overridden
}

variable "worker_disk_size" {
  description = "Disk size for the worker nodes"
  type        = number
  default     = 30 # Default disk size for worker nodes in GB
}

variable "k8s_worker_sg_id" {
  description = "Security group ID for Kubernetes worker nodes"
  type        = string
}

variable "public_subnet_two" {
  description = "List of public subnets for Kubernetes worker nodes"
  type        = list(string)
  default     = [] # Default to an empty list, should be set in the module call
}

variable "k8s_worker_ami_id" {
  description = "AMI ID for Kubernetes worker nodes"
  type        = string
}

variable "k8s_worker_instance_iam_profile" {
  description = "IAM instance profile for Kubernetes worker nodes"
  type        = string
}

variable "k8s_worker_asg_vpc_id" {
  description = "VPC ID where the Kubernetes worker ASG will be created"
  type        = string

}

variable "sockshop_alb_target_group_arn" {
  description = "ARN of the target group for the sock-shop application"
  type        = string
}

variable "prometheus_alb_target_group_arn" {
  description = "ARN of the target group for Prometheus"
  type        = string
}

variable "grafana_alb_target_group_arn" {
  description = "ARN of the target group for Grafana"
  type        = string
}

variable "k8s_worker_asg_policy_name" {
  description = "Name of the auto scaling policy for Kubernetes worker ASG"
  type        = string
  default     = "k8s-worker-asg-policy" # Default name for the ASG policy
}

variable "k8s_worker_ami_dependencies" {
  description = "Dependencies for the Kubernetes worker AMI creation"
  type        = list(any)
  default     = [] # Default to an empty list, can be set in the module call
}

variable "k8s_master_dependency" {
  description = "Dependency for the Kubernetes master node to ensure it is created before installing monitoring tools."
  type        = any
  default     = null

}