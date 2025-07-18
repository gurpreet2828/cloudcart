# this is the main Terraform configuration file for setting up a Kubernetes cluster on AWS.
# It includes modules for compute resources, network configuration, storage, monitoring and application deployment.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Get the provider from HashiCorp's registry
      version = "~> 6.0"        # Use version 6.0 or any newer version within 6.x (not 7.x)
    }
  }
  required_version = ">= 1.0" # Require Terraform CLI version 1.0 or newer to run this configuration
}


provider "aws" {
  region = var.aws_region # Use the AWS region from a variable
}

# Load the code inside the Compute folder
# This module sets up the compute resources, such as EC2 instances for Kubernetes nodes
module "Compute" {
  source = "./terraform-aws/Compute" # Path to the Compute module

  # Pass the necessary variables to the Compute module
  ssh_key_public = "${path.module}/../keys/docker.pub" # Path to the public SSH key file
  ssh_key_private = var.ssh_key_private
  public_subnet_one = module.Network.public_subnet_one_id   # Pass the public subnet ID from the Network module
  public_subnet_two = [module.Network.public_subnet_two_id] # Pass the public subnet IDs for worker nodes from the Network module
  security_group    = module.Network.security_group_id      # Pass the security group ID from the Network module   
  aws_region        = var.aws_region                        # AWS region where the resources will be created  
}

# Load the code inside the Network folder
# This module sets up the network configuration, including VPC, subnets, and security groups
module "Network" {
  source = "./terraform-aws/Network"
}

# Load the code inside the Storage folder
# This module sets up the storage resources, such as S3 buckets for Kubernetes data
/*
module "Storage" {

  source     = "./terraform-aws/Storage"
  aws_region = var.aws_region # AWS region where the resources will be created
}
*/
# this module sets up monitoring tools for the Kubernetes cluster
# It includes tools like Prometheus and Grafana for monitoring the cluster's performance and health
module "Monitoring" {
  source                        = "./terraform-aws/Monitoring"       # Path to the Monitoring module
  aws_region                    = var.aws_region                     # AWS region where the monitoring tools will be installed
  ssh_key_private               = var.ssh_key_private                # Path to the private SSH key for accessing the instances
  k8s_master_dependency         = module.Compute.k8s_master_instance # Dependency for the Kubernetes master node
  k8s_master_eip                = module.Compute.k8s_master_eip      # Elastic IP address of the Kubernetes master node
  fetch_join_command_dependency = module.Compute.fetch_join_command  # Dependency for fetching the join command
  deployment_app_dependency     = module.deployment.deployment_app   #dependency on sock-shop application
}


# This module sets up the deployment of applications on the Kubernetes cluster
module "deployment" {
  source                        = "./terraform-aws/deployment"
  aws_region                    = var.aws_region
  ssh_key_private               = var.ssh_key_private
  k8s_master_dependency         = module.Compute.k8s_master_instance
  k8s_master_eip                = module.Compute.k8s_master_eip
  fetch_join_command_dependency = module.Compute.fetch_join_command
}
