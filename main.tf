# Load the code inside the Compute folder
# This module sets up the compute resources, such as EC2 instances for Kubernetes nodes
module "Compute" {
  source = "./terraform-aws/Compute" # Path to the Compute module

  # Pass the necessary variables to the Compute module
  ssh_key_public    = "${path.module}/../keys/docker.pub" # Path to the public SSH key file
  ssh_key_private   = var.ssh_key_private
  vpc_id            = module.Network.vpc_id
  public_subnet_ids = module.Network.public_subnet_ids      # Pass the public subnet IDs from the Network module
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

#Load the code inside the Storage folder
#This module sets up the storage resources, such as S3 buckets for Kubernetes data

module "Storage" {
  source = "./terraform-aws/Storage"
  #aws_region = var.aws_region # AWS region where the resources will be 

  ssh_key_private               = var.ssh_key_private
  k8s_master_dependency         = module.Compute.k8s_master_instance # Dependency for the Kubernetes master node
  k8s_master_eip                = module.Compute.k8s_master_eip      # Elastic IP address of the Kubernetes master node
  fetch_join_command_dependency = module.Compute.fetch_join_command  # Dependency for fetching the join command
  monitoring_dependency         = module.Monitoring                  # Dependency for the monitoring module
}


terraform {
  backend "s3" {
    bucket = "my-k8s-bucket-1111" # Use the S3 bucket name from the Storage module
    #bucket      = module.Storage.k8s_bucket.bucket       # Use the S3 bucket name from the Storage module
    key          = "terraform/tfstate/terraform.tfstate" # Key for the Terraform state file in the S3 bucket
    use_lockfile = true
    region       = "us-east-1" # AWS region where the S3 bucket and DynamoDB table are located
    encrypt      = true        # Enable encryption for the state file in S3
  }
}

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
