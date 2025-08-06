# Load the code inside the Compute folder
# This module sets up the compute resources, such as EC2 instances for Kubernetes nodes

module "Compute" {
  source = "./terraform-aws/Compute" # Path to the Compute module

  # Pass the necessary variables to the Compute module
  ssh_key_public    = "${path.module}/../keys/docker.pub" # Path to the public SSH key file
  ssh_key_private   = var.ssh_key_private
  vpc_id            = module.Network.vpc_id
  public_subnet_one = module.Network.public_subnet_one_id   # Pass the public subnet ID from the Network module
  public_subnet_two = [module.Network.public_subnet_two_id] # Pass the public subnet IDs for worker nodes from the Network module
  security_group    = module.Network.security_group_id      # Pass the security group ID from the Network module   
  aws_region        = var.aws_region                        # AWS region where the resources will be created
}


# This module sets up Jenkins for continuous integration and deployment in the Kubernetes cluster


# Load the code inside the Network folder
# This module sets up the network configuration, including VPC, subnets, and security groups
module "Network" {
  source = "./terraform-aws/Network"

}

#Load the code inside the Storage folder
#This module sets up the storage resources, such as S3 buckets for Kubernetes data

module "Storage" {
  source                        = "./terraform-aws/Storage"
  aws_region                    = var.aws_region # AWS region where the resources will be 
  ssh_key_private               = var.ssh_key_private
  k8s_master_dependency         = module.Compute.k8s_master_instance # Dependency for the Kubernetes master node
  k8s_master_eip                = module.Compute.k8s_master_eip      # Elastic IP address of the Kubernetes master node
  fetch_join_command_dependency = module.Compute.fetch_join_command  # Dependency for fetching the join command
  monitoring_dependency         = module.Monitoring                  # Dependency for the monitoring module
}

# Configure the Terraform backend 
terraform {
  backend "s3" {
    bucket = "my-k8s-bucket-1111" # Use the S3 bucket name from the Storage module
    #bucket      = module.Storage.k8s_bucket.bucket       # Use the S3 bucket name from the Storage module
    key = "terraform/tfstate/terraform.tfstate" # Key for the Terraform state file in the S3 bucket
    #use_lockfile = true
    region  = "us-east-1" # AWS region where the S3 bucket and DynamoDB table are located
    encrypt = true        # Enable encryption for the state file in S3
  }
}




# This module sets up the Application Load Balancer (ALB) for the Kubernetes cluster
module "ALB_Controller" {
  source = "./terraform-aws/ALB_Controller" # Path to the ALB Controller module
  # Ensure Compute and Network modules are created before ALB_Controller
  aws_region           = var.aws_region                      # AWS region where the ALB will be created
  vpc_id               = module.Network.vpc_id               # Pass the VPC ID from the Network module
  security_group       = module.Network.security_group_id    # Pass the security group ID from the Network module
  public_subnet_ids    = module.Network.public_subnet_ids    # Pass the public subnet IDs from the Network module
  k8s_worker_instances = module.Compute.k8s_worker_instances # Pass the list of Kubernetes worker instances from the Compute module
}

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

###################################
#Jenkins Module
###################################

# This module sets up Jenkins for continuous integration and deployment in the Kubernetes cluster
module "Jenkins_Compute" {

  source = "./terraform-aws/Jenkins/Jenkins_Compute" # Path to the Jenkins module
  providers = {
    aws = aws
  }
  count                 = var.enable_jenkins ? 1 : 0                         # Enable Jenkins module based on the variable
  jenkins_key_public    = "${path.root}/terraform-aws/keys/jenkins_key.pub"  # Path to the public SSH key file for Jenkins
  jenkins_key_private   = var.jenkins_key_private                            # Path to the private SSH key for Jenkins
  vpc_id                = module.Jenkins_Network[0].jenkins_vpc_id           # Pass the VPC ID from the Network module
  jenkins_sg            = module.Jenkins_Network[0].jenkins_sg_id            # Pass the security group ID from the Network module
  jenkins_public_subnet = module.Jenkins_Network[0].jenkins_public_subnet_id #


}

module "Jenkins_Network" {
  count  = var.enable_jenkins ? 1 : 0                # Enable Jenkins Network module based on the variable
  source = "./terraform-aws/Jenkins/Jenkins_Network" # Path to the Jenkins Network module
}


###############################
#Jenkins Module End
###############################


# This module sets up the IAM roles
module "IAM_Roles" {
  source = "./terraform-aws/IAM_Roles" # Path to the IAM Roles module
}

module "Auto_Scaling" {
  source                          = "./terraform-aws/Auto_Scaling"                        # Path to the Auto Scaling module
  k8s_worker_asg_vpc_id           = module.Network.vpc_id                                 # Pass the VPC ID where the ASG will be created
  k8s_worker_sg_id                = module.Network.security_group_id                      # Pass the required security group ID from the Network module
  k8s_worker_ami_id               = module.Compute.k8s_worker_ami_id                      # Pass the AMI ID for worker nodes from the Compute module
  k8s_worker_instance_iam_profile = module.IAM_Roles.instance_profile_name                # Pass the IAM instance profile for worker nodes
  public_subnet_two               = [module.Network.public_subnet_two_id]                 # Pass the public subnet IDs for worker nodes from the Network module
  sockshop_alb_target_group_arn   = module.ALB_Controller.sockshop_alb_target_group_arn   # Pass the target group ARN for sock-shop application
  prometheus_alb_target_group_arn = module.ALB_Controller.prometheus_alb_target_group_arn # Pass the target group ARN for Prometheus
  grafana_alb_target_group_arn    = module.ALB_Controller.grafana_alb_target_group_arn    # Pass the target
  k8s_worker_ami_dependencies     = module.Compute.k8s_worker_ami_dependencies            # Pass the dependencies for the Kubernetes worker AMI creation
  k8s_master_dependency           = module.Compute.k8s_master_instance
}

