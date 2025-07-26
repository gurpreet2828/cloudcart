
# This Terraform configuration sets up a basic AWS VPC with public subnets and an internet gateway for a Kubernetes cluster.
# This file is part of the Terraform AWS Network module for setting up a VPC and public subnets for a Kubernetes cluster.
# It includes the creation of a VPC, internet gateway, route tables, public subnets, and a security group.
# Ensure you have the necessary variables defined in a separate variables.tf file.
# Ensure you have the necessary provider and data source configurations in place.


provider "aws" {
  region = var.aws_region # Use the AWS region from a variable
}
data "aws_availability_zones" "azs" {
  state = "available"
}

module "jenkins" {
  source = "./Jenkins"
}

resource "aws_vpc" "k8s_vpc" {
  cidr_block           = "10.0.0.0/16" # Define the CIDR block for the VPC
  enable_dns_hostnames = true          # Enable DNS hostnames in the VPC
  enable_dns_support   = true          # Enable DNS support in the VPC
  instance_tenancy     = "default"     # Use default tenancy for instances

  tags = {
    Name = "k8s-vpc"
  }
}

resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id # Attach the internet gateway to the VPC

  tags = {
    Name = "k8s-igw"
  }
}
resource "aws_route_table" "k8s_public_rt" {
  vpc_id = aws_vpc.k8s_vpc.id # Create a route table for public subnets

  route {
    cidr_block = "0.0.0.0/0"                     # Route all traffic to the internet
    gateway_id = aws_internet_gateway.k8s_igw.id # Use the internet gateway created above
  }
  tags = {
    Name = "k8s-public-rt"
  }
}

resource "aws_route_table_association" "k8s_public_rta_one" {
  subnet_id      = aws_subnet.k8s_public_subnet_one.id # Associate the first public subnet with the route table
  route_table_id = aws_route_table.k8s_public_rt.id    # Use the route table created above
}

resource "aws_route_table_association" "k8s_public_rta_two" {
  subnet_id      = aws_subnet.k8s_public_subnet_two.id # Associate the second public subnet with the route table
  route_table_id = aws_route_table.k8s_public_rt.id
}

resource "aws_subnet" "k8s_public_subnet_one" {
  vpc_id                  = aws_vpc.k8s_vpc.id                       # Create the first public subnet in the VPC
  cidr_block              = "10.0.1.0/24"                            # Define the CIDR block for the subnet
  availability_zone       = data.aws_availability_zones.azs.names[0] # Use the first availability zone
  map_public_ip_on_launch = true                                     # Automatically assign public IPs to instances in this subnet
  tags = {
    Name = "k8s-public-subnet-one"
  }

}

resource "aws_subnet" "k8s_public_subnet_two" {
  vpc_id                  = aws_vpc.k8s_vpc.id                       # Create the second public subnet in the VPC
  cidr_block              = "10.0.2.0/24"                            # Define the CIDR block for the subnet
  availability_zone       = data.aws_availability_zones.azs.names[1] # Use the second availability zone
  map_public_ip_on_launch = true                                     # Automatically assign public IPs to instances in this subnet
  tags = {
    Name = "k8s-public-subnet-two"
  }

}

resource "aws_security_group" "k8s_sg" {
  vpc_id      = aws_vpc.k8s_vpc.id                      # Create a security group in the VPC
  name        = "k8s-security-group"                    # Name of the security group
  description = "Security group for Kubernetes cluster" # Description of the security group

  ingress {
    from_port   = 0                                 # Allow all inbound traffic
    to_port     = 0                                 # All ports
    protocol    = "-1"                              # All protocols
    cidr_blocks = ["0.0.0.0/0"]                     # Allow access from anywhere 
    description = "Allow all traffic from anywhere" # Description of the rule
  }

  egress {
    from_port   = 0 # Allow all outbound traffic
    to_port     = 0
    protocol    = "-1"                         # All protocols
    cidr_blocks = ["0.0.0.0/0"]                # Allow access to anywhere
    description = "Allow all outbound traffic" # Description of the rule
  }

  tags = {
    Name = "k8s-security-group"
  }
}

