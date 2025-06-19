# This Terraform configuration file sets up an AWS environment for a Kubernetes cluster with a master node and multiple worker nodes.
# It uses variables for configuration, creates EC2 instances, and allocates Elastic IPs for each node.
## The configuration is modular, allowing for easy adjustments and scalability.

#
provider "aws" {
  region = var.aws_region # Use the AWS region from a variable
}
variable "Ubuntu_ami" {
  default = "ami-020cba7c55df1f615" # Default Ubuntu AMI ID, can be overridden
  description = "The Ubuntu AMI ID to use for the EC2 instances."
  type        = string

}

#create a key pair for SSH access to the instances
resource "aws_key_pair" "aws_key" { #
  key_name   = "k8s"
  public_key = file(var.ssh_key_public) # Path to your public SSH key file
}

# This Terraform configuration sets up the compute resources for a Kubernetes cluster on AWS.
# It creates a master node and multiple worker nodes, each with an Elastic IP for external access.
# Ensure you have the necessary variables defined in a separate variables.tf file.

# Create the master node for the Kubernetes cluster
resource "aws_instance" "k8s-master" {
  ami           = var.Ubuntu_ami # Use the Ubuntu AMI from SSM Parameter Store
  instance_type = var.master_instance_type                # Use the instance type from a variable
  tags = {
    Name = "k8s-master"
  }
  key_name                    = aws_key_pair.aws_key.key_name # Use the key pair created above
  vpc_security_group_ids      = [var.security_group]          # Use the security group ID from a variable
  associate_public_ip_address = true                          # Associate a public IP address
  subnet_id                   = var.public_subnet_one         # Use the subnet ID from a variable

}

# Create the worker nodes for the Kubernetes cluster
resource "aws_instance" "k8s-worker" {
  count         = var.worker_count                        # Number of worker nodes to create
  ami           = var.Ubuntu_ami #Use the Ubuntu AMI from SSM Parameter Store
  instance_type = var.worker_instance_type                # Use the instance type from a variable
  tags = {
    Name = "k8s-worker-${count.index+1}" # Unique name for each worker node
  }
  key_name                    = aws_key_pair.aws_key.key_name      # Use the key pair created above
  vpc_security_group_ids      = [var.security_group]               # Use the security group ID from a variable
  associate_public_ip_address = true                               # Associate a public IP address
  subnet_id                   = var.public_subnet_two[count.index % length(var.public_subnet_two)] # Use the subnet ID from a variable, assuming multiple subnets for workers

}

# Allocate Elastic IPs for the master node 
resource "aws_eip" "k8s_master_eip" {
  instance = aws_instance.k8s-master.id # Allocate an Elastic IP for the master node

  tags = {
    Name = "k8s-master-eip"
  }
}

# Allocate Elastic IPs for each worker node
resource "aws_eip" "k8s_worker_eip" {
  count    = var.worker_count # Allocate Elastic IPs for each worker node
  instance = aws_instance.k8s-worker[count.index].id 

  tags = {
    Name = "k8s-worker-eip-${count.index+1}" # Unique name for each worker node's EIP
  }
}