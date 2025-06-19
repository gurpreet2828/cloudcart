terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" # Get the provider from HashiCorp's registry
      version = "~> 5.0"        # Use version 5.0 or any newer version within 5.x (not 6.x)
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
  source            = "./terraform-aws/Compute"
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