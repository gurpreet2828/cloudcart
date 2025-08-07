# This file is part of the Terraform AWS Auto Scaling module for managing auto scaling groups and related resources

data "template_file" "user_data" {
  template = <<EOF
#!/bin/bash
set -ex

# Update system and install prerequisites
apt-get update -y

# Enable IP forwarding for Kubernetes networking
echo "Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo "Checking installation...."
aws --version
kubectl version --client
kubeadm version
kubelet --version

# Download join command from S3
echo "Downloading join command script from S3..."
aws s3 cp s3://my-k8s-bucket-1111/terraform-aws/scripts/join_command.sh /home/ubuntu/cloudcart/scripts/join_command.sh

# Ensure permissions
sudo chmod +x /home/ubuntu/cloudcart/scripts/join_command.sh
sudo chown ubuntu:ubuntu /home/ubuntu/cloudcart/scripts/join_command.sh

# Execute the join command script
sudo bash /home/ubuntu/cloudcart/scripts/join_command.sh
EOF
}



resource "aws_launch_template" "k8s_worker_launch_template" {
  depends_on    = [var.k8s_worker_ami_dependencies, var.k8s_master_dependency] # Ensure the AMI is created before the launch template
  name_prefix   = "k8s-worker-ami-launch-template"
  description   = "Launch template for Kubernetes worker nodes with AMI from instance for auto scaling"
  image_id      = var.k8s_worker_ami_id
  instance_type = var.worker_instance_type # Specify the instance type for the worker nodes
  key_name      = "k8s"                    # Key pair for SSH access to the worker nodes

  user_data = base64encode(data.template_file.user_data.rendered) # Use the user data script for initialization

  tags = {
    Name      = "K8S-Worker-ami-launch-template"
    CreatedBy = "Terraform"
    project   = "Cloudcart"
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name      = "K8S-Worker-ami-launch-template-instance"
      CreatedBy = "Terraform"
      project   = "Cloudcart"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name      = "K8S-Worker-ami-launch-template-volume"
      CreatedBy = "Terraform"
      project   = "Cloudcart"
    }
  }

  network_interfaces {
    associate_public_ip_address = true                     # Associate a public IP address for the worker nodes
    security_groups             = [var.k8s_worker_sg_id]   # Use the security group for worker nodes
    subnet_id                   = var.public_subnet_two[0] # Use the first public subnet for worker nodes
  }

  block_device_mappings {
    device_name = "/dev/xvda" # Device name for the root volume
    ebs {
      volume_size           = var.worker_disk_size # Size of the disk for worker nodes in GB
      volume_type           = "gp3"                # General Purpose SSD
      delete_on_termination = true                 # Delete the volume when the instance is terminated
    }
  }

  lifecycle {
    create_before_destroy = true # Ensure the launch template is created before destroying the old one
  }
  iam_instance_profile {
    name = var.k8s_worker_instance_iam_profile # IAM instance profile for worker nodes
  }
}









