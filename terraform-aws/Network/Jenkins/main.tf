data "aws_availability_zones" "azs" {
  state = "available"
}


resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = "10.0.0.0/16" # Define the CIDR block for the VPC
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default" # Use default tenancy for instances
  tags = {
    Name = "jenkins-vpc"
  }
}

resource "aws_subnet" "jenkins_public_subnet" {
  vpc_id                  = aws_vpc.jenkins_vpc.id # Create the first public subnet in the VPC
  cidr_block              = "10.0.3.0/24"
  availability_zone       = data.aws_availability_zones.azs.names[0] # Use the first availability zone
  map_public_ip_on_launch = true                                     # Automatically assign public IPs to instances in this subnet
  tags = {
    Name = "jenkins-public-subnet"
  }
}

resource "aws_internet_gateway" "jenkins_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id # Attach the internet gateway to the VPC

  tags = {
    Name = "jenkins-igw"
  }
}



resource "aws_route_table" "jenkins_public_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id # Create a route table for public subnets

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_igw.id
  }

  tags = {
    Name = "jenkins-public-rt"
  }
}

resource "aws_route_table_association" "jenkins_public_rta" {
  subnet_id      = aws_subnet.jenkins_public_subnet.id # Associate the public subnet with the route table
  route_table_id = aws_route_table.jenkins_public_rt.id
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    from_port   = 0 # Jenkins default port
    to_port     = 0
    protocol    = "-1"          # All protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow all inbound traffic
    description = "Allow all inbound traffic"
  }

  egress {
    from_port   = 0 # Allow all outbound traffic
    to_port     = 0
    protocol    = "-1"          # All protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }
  tags = {
    Name = "jenkins-security-group"
  }
}

