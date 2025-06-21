# This Terraform configuration file sets up an AWS environment for a Kubernetes cluster with a master node and multiple worker nodes.
# It uses variables for configuration, creates EC2 instances, and allocates Elastic IPs for each node.
## The configuration is modular, allowing for easy adjustments and scalability.


provider "aws" {
  region = var.aws_region # Use the AWS region from a variable
}
variable "Ubuntu_ami" {
  default     = "ami-020cba7c55df1f615" # Default Ubuntu AMI ID, can be overridden
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
  ami                         = var.Ubuntu_ami                # Use the Ubuntu AMI from SSM Parameter Store
  instance_type               = var.master_instance_type      # Use the instance type from a variable
  key_name                    = aws_key_pair.aws_key.key_name # Use the key pair created above
  vpc_security_group_ids      = [var.security_group]          # Use the security group ID from a variable
  associate_public_ip_address = true                          # Associate a public IP address
  subnet_id                   = var.public_subnet_one         # Use the subnet ID from a variable
  user_data                   = file("/home/administrator/cloudcart/terraform-aws/scripts/install-k8s-master.sh")
  tags = {
    Name = "k8s-master"
  }

  #
  root_block_device {
    volume_size           = var.master_disk_size # Size of the root volume in GB, defined in a variable
    volume_type           = "gp3"                # Use General Purpose SSD for the root volume
    delete_on_termination = true                 # Delete the volume when the instance is terminated
  }

}


# Allocate Elastic IPs for the master node 
resource "aws_eip" "k8s_master_eip" {
  instance = aws_instance.k8s-master.id # Allocate an Elastic IP for the master node

  tags = {
    Name = "k8s-master-eip"
  }
}

resource "null_resource" "fetch_join_command" {
  depends_on = [aws_instance.k8s-master] # Ensure the master node is created before fetching the join command

  # Provisioner to fetch the join command from the master node 
  provisioner "remote-exec" {
  connection {

    type        = "ssh"
    host        = aws_eip.k8s_master_eip.public_ip # Connect to the master node's elastic IP
    user        = "ubuntu"                         # Use the default user for Ubuntu instances
    private_key = file(var.ssh_key_private)        # Path to your private SSH key file
  }
    # Fetch the join command from the master node and save it to a file
    inline = [
      # Wait until admin.conf exists
      "while [ ! -f /etc/kubernetes/admin.conf ]; do echo 'Waiting for kubeadm init...'; sleep 10; done",
      # Wait until kubeadm command works
      "until sudo kubeadm token list >/dev/null 2>&1; do echo 'Waiting for kubeadm to be ready...'; sleep 5; done",
      "echo 'Fetching join command from the master node...'",
      # Create the join command and save it to a file
      "sudo kubeadm token create --print-join-command | sed 's/^/sudo /; s/$/ --ignore-preflight-errors=all/' | sudo tee /home/ubuntu/join_command.sh > /dev/null",
      # Ensure the join command file is readable
      "sudo chmod u+rxw /home/ubuntu/join_command.sh",
      # Change ownership to the ubuntu user
      "sudo chown ubuntu:ubuntu /home/ubuntu/join_command.sh",
      "echo 'Join command saved to /home/ubuntu/join_command.sh'",
      "ls -lt /home/ubuntu/", # List the file to confirm it exists
      # Display the contents of the join command file
      "cat /home/ubuntu/join_command.sh",
      "echo 'Join command fetched successfully!'"
    ]
  }

  # Copy the join command file from the master node to the local machine
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i ${var.ssh_key_private} ubuntu@${aws_eip.k8s_master_eip.public_ip}:/home/ubuntu/join_command.sh /home/administrator/cloudcart/terraform-aws/scripts/join_command.sh"
   
  }
}

# Create the worker nodes for the Kubernetes cluster
resource "aws_instance" "k8s-worker" {                                                                            # Ensure the join command is fetched before creating worker nodes
  count                       = var.worker_count                                                                  # Number of worker nodes to create
  ami                         = var.Ubuntu_ami                                                                    #Use the Ubuntu AMI from SSM Parameter Store
  instance_type               = var.worker_instance_type                                                          # Use the instance type from a variable
  key_name                    = aws_key_pair.aws_key.key_name                                                     # Use the key pair created above
  vpc_security_group_ids      = [var.security_group]                                                              # Use the security group ID from a variable
  associate_public_ip_address = true                                                                              # Associate a public IP address
  subnet_id                   = var.public_subnet_two[count.index % length(var.public_subnet_two)]                # Use the subnet ID from a variable, assuming multiple subnets for workers
  user_data                   = file("/home/administrator/cloudcart/terraform-aws/scripts/install-k8s-worker.sh") # User data script to initialize the worker nodes

  tags = {
    Name = "k8s-worker-${count.index + 1}" # Unique name for each worker node
  }
  root_block_device {
    volume_size           = var.worker_disk_size # Size of the root volume in GB, defined in a variable
    volume_type           = "gp3"                # Use General Purpose SSD for the root volume
    delete_on_termination = true                 # Delete the volume when the instance is terminated
  }

}
# Allocate Elastic IPs for each worker node
resource "aws_eip" "k8s_worker_eip" {
  count    = var.worker_count # Allocate Elastic IPs for each worker node
  instance = aws_instance.k8s-worker[count.index].id

  tags = {
    Name = "k8s-worker-eip-${count.index + 1}" # Unique name for each worker node's EIP
  }
}

#push the join command to each worker node
resource "null_resource" "fetch_worker_join_command" {
  depends_on = [null_resource.fetch_join_command] # Ensure the join command is fetched before executing this resource
  count = var.worker_count # Ensure the join command is fetched for each worker node

  connection {
    type        = "ssh"
    host        = aws_eip.k8s_worker_eip[count.index].public_ip # Connect to each worker node's elastic IP
    user        = "ubuntu"                                      # Use the default user for Ubuntu instances
    private_key = file(var.ssh_key_private)                     # Path to your private SSH key file
  }
  
  # Provisioner to execute the join command on each worker node
  provisioner "file" {
    source      = "/home/administrator/cloudcart/terraform-aws/scripts/join_command.sh" # Path to the join command file
    destination = "/home/ubuntu/join_command.sh" # Destination path on the worker node
  }
  provisioner "remote-exec" {
    inline = [
      "echo 'Executing join command on worker node...'",
      "sudo chmod u+rxw /home/ubuntu/join_command.sh", # make the join command executable
      "sudo chown ubuntu:ubuntu /home/ubuntu/join_command.sh", # Change ownership to the ubuntu user
      "sudo sh /home/ubuntu/join_command.sh"            # Execute the join command to join the worker node to the cluster
    ]
  }
}