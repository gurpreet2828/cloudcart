# This Terraform configuration file sets up an AWS environment for a Kubernetes cluster with a master node and multiple worker nodes.
# It uses variables for configuration, creates EC2 instances, and allocates Elastic IPs for each node.
## The configuration is modular, allowing for easy adjustments and scalability.


provider "aws" {
  region = var.aws_region # Use the AWS region from a variable
}

#create a key pair for SSH access to the instances
resource "aws_key_pair" "aws_key" {
  key_name = "k8s"
  # public_key = file(var.ssh_key_public) # Path to your public SSH key file
  public_key = file("${path.module}/../keys/docker.pub") # Path to your public SSH key file
}

# This Terraform configuration sets up the compute resources for a Kubernetes cluster on AWS.
# It creates a master node and multiple worker nodes, each with an Elastic IP for external access.
# Ensure you have the necessary variables defined in a separate variables.tf file.

#-----------------------------------------------------------------------
# This resource creates an EC2 instance for the Kubernetes master node.
#----------------------------------------------------------------------
resource "aws_instance" "k8s-master" {
  ami                         = var.ubuntu_ami                # Use the Ubuntu AMI from SSM Parameter Store
  instance_type               = var.master_instance_type      # Use the instance type from a variable
  key_name                    = aws_key_pair.aws_key.key_name # Use the key pair created above
  vpc_security_group_ids      = [var.security_group]          # Use the security group ID from a variable
  associate_public_ip_address = false                         # Associate a public IP address
  subnet_id                   = var.public_subnet_one         # Use the subnet ID from a variable
  # This script installs necessary packages and configures the Kubernetes master node
  user_data = file("terraform-aws/scripts/install-k8s-master.sh")
  tags = {
    Name = "k8s-master"
  }

  # This block defines the root volume for the master node
  root_block_device {
    volume_size           = var.master_disk_size # Size of the root volume in GB, defined in a variable
    volume_type           = "gp3"                # Use General Purpose SSD for the root volume
    delete_on_termination = true                 # Delete the volume when the instance is terminated
    tags = {
      Name = "k8s-master-root-volume"
    }
  }

}

# Allocate an Elastic IP for the Kubernetes master node
resource "aws_eip" "k8s_master_eip" {
  instance = aws_instance.k8s-master.id

  tags = {
    Name = "k8s-master-eip"
  }
}

# Creating EBS volume for the master node
resource "aws_ebs_volume" "k8s_master_ebs_volume" {
  availability_zone = var.master_az
  size              = var.master_ebs_volume_size
  type              = "gp3"
  encrypted         = true
  tags = {
    Name = "k8s-master-ebs-volume"
  }
}

resource "aws_volume_attachment" "master_attach_volume" {
  instance_id  = aws_instance.k8s-master.id
  device_name  = "/dev/xvdf"
  volume_id    = aws_ebs_volume.k8s_master_ebs_volume.id
  force_detach = true


}

resource "null_resource" "mount_ebs_ec2" {
  depends_on = [aws_volume_attachment.master_attach_volume]

  connection {
    type        = "ssh"
    host        = aws_eip.k8s_master_eip.public_ip
    user        = "ubuntu"
    private_key = file(var.ssh_key_private)
    #private_key = var.ssh_key_private # Path to your private SSH key file for github actions
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/nvme1n1",
      "sudo mkdir -p /mnt/data",
      "sudo mount /dev/nvme1n1 /mnt/data",
      "echo '/dev/nvme1n1 /mnt/data ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab"
    ]
  }
}

# Fetch the join command from the master node and save it to a file
resource "null_resource" "fetch_join_command" {
  depends_on = [aws_instance.k8s-master] # Ensure the master node is created before fetching the join command


  # This resource fetches the join command from the master node and saves it to a file on the local machine
  # It uses SSH to connect to the master node and execute commands to retrieve the join command
  connection {

    type        = "ssh"
    host        = aws_eip.k8s_master_eip.public_ip # Connect to the master node's elastic IP
    user        = "ubuntu"                         # Use the default user for Ubuntu instances
    private_key = file(var.ssh_key_private)        # Path to your private SSH key file
    # private_key = file("/home/administrator/.ssh/docker") # Path to your private SSH key file
  }

  # Provisioner to fetch the join command from the master node 
  provisioner "remote-exec" {
    inline = [
      # Wait until kubeadm init has completed
      "while [ ! -f /etc/kubernetes/admin.conf ]; do echo 'Waiting for kubeadm init...'; sleep 10; done",
      # Wait until kubeadm command works
      "until sudo kubeadm token list >/dev/null 2>&1; do echo 'Waiting for kubeadm to be ready...'; sleep 5; done",
      "kubectl version",   # Check the Kubernetes version to confirm kubeadm is ready
      "kubeadm version",   # Check the kubeadm version to confirm it's working
      "kubelet --version", # Display cluster information to confirm the master node is set up
      "echo 'Kubernetes master node is ready! Fetching join command...'",
      "sudo mkdir -p /home/ubuntu/cloudcart/scripts/", # Create a directory for scripts if it doesn't exist
      # Create the join command and save it to a file
      "sudo kubeadm token create --print-join-command | sed 's/^/sudo /; s/$/ --ignore-preflight-errors=all/' | sudo tee /home/ubuntu/cloudcart/scripts/join_command.sh > /dev/null",
      # Ensure the join command file is readable
      "sudo chmod u+rxw /home/ubuntu/cloudcart/scripts/join_command.sh",
      # Change ownership to the ubuntu user
      "sudo chown ubuntu:ubuntu /home/ubuntu/cloudcart/scripts/join_command.sh",
      "echo 'Join command saved to /home/ubuntu/cloudcart/scripts/join_command.sh'",
      "ls -lt /home/ubuntu/cloudcart/scripts/join_command.sh", # List the file to confirm it exists
      # Display the contents of the join command file
      "cat /home/ubuntu/cloudcart/scripts/join_command.sh",
      "echo 'Join command fetched successfully!'"
    ]
  }
  #copy the join command file to the local machine
  provisioner "local-exec" {
    command = <<EOT
    sudo mkdir -p /home/administrator/cloudcart/terraform-aws/scripts
    echo 'Copying join command to local machine...'
    scp -i ${var.ssh_key_private} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${aws_eip.k8s_master_eip.public_ip}:/home/ubuntu/cloudcart/scripts/join_command.sh /home/administrator/cloudcart/terraform-aws/scripts/join_command.sh
    echo 'Join command copied successfully!'
  EOT
  }
}

resource "null_resource" "prepare_join_script" {
  depends_on = [null_resource.fetch_join_command]
  provisioner "local-exec" {
    command = <<EOT
      echo 'Setting permissions for local join_command.sh...'
      set -ex
      if [ -f /home/administrator/cloudcart/terraform-aws/scripts/join_command.sh ]; then
        sudo chown $(whoami):$(whoami) /home/administrator/cloudcart/terraform-aws/scripts/join_command.sh
        sudo chmod u+rxw /home/administrator/cloudcart/terraform-aws/scripts/join_command.sh
      else
        echo 'join_command.sh not found!'
        exit 1
      fi
      echo 'Read Write permission set for join_command.sh'
    EOT
  }
}

#-----------------------------------------------------------------------
# This resource creates multiple EC2 instances for the Kubernetes worker nodes.
#-----------------------------------------------------------------------
resource "aws_instance" "k8s-worker" {                                                             # Ensure the join command is fetched before creating worker nodes
  count                       = var.worker_count                                                   # Number of worker nodes to create
  ami                         = var.ubuntu_ami                                                     #Use the Ubuntu AMI from SSM Parameter Store
  instance_type               = var.worker_instance_type                                           # Use the instance type from a variable
  key_name                    = aws_key_pair.aws_key.key_name                                      # Use the key pair created above
  vpc_security_group_ids      = [var.security_group]                                               # Use the security group ID from a variable
  associate_public_ip_address = true                                                               # Associate a public IP address
  subnet_id                   = var.public_subnet_two[count.index % length(var.public_subnet_two)] # Use the subnet ID from a variable, assuming multiple subnets for workers
  user_data                   = file("terraform-aws/scripts/install-k8s-worker.sh")                # User data script to initialize the worker nodes

  tags = {
    Name = "k8s-worker-${count.index + 1}" # Unique name for each worker node
  }

  # This block defines the root volume for each worker node
  root_block_device {
    volume_size           = var.worker_disk_size # Size of the root volume in GB, defined in a variable
    volume_type           = "gp3"                # Use General Purpose SSD for the root volume
    delete_on_termination = true                 # Delete the volume when the instance is terminated
    tags = {
      Name = "k8s-worker_root_volume-${count.index + 1}"
    }
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


#------------------------------------------------------------------------
# This resource fetches the join command from local machine and copies it to each worker node
#------------------------------------------------------------------------
resource "null_resource" "fetch_worker_join_command" {
  depends_on = [null_resource.fetch_join_command, null_resource.prepare_join_script] # Ensure the join command is fetched from the master node to local machine before executing this resource
  count      = var.worker_count

  connection {
    type        = "ssh"
    host        = aws_eip.k8s_worker_eip[count.index].public_ip # Connect to each worker node's elastic IP
    user        = "ubuntu"                                      # Use the default user for Ubuntu instances
    private_key = file(var.ssh_key_private)                     # Path to your private SSH key file
  }

  #create a directory for scripts if it doesn't exist
  provisioner "remote-exec" {
    inline = [
      "echo 'Creating directory for scripts on worker node...'",
      "sudo mkdir -p /home/ubuntu/cloudcart/scripts",                # Create a directory for scripts if it doesn't exist
      "sudo chmod -R u+rxw /home/ubuntu/cloudcart/scripts/",         # Ensure the directory is writable
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/cloudcart/scripts/", # Change ownership to the ubuntu user
      "echo 'Directory created successfully!'"
    ]
  }

  # Copy the join command file to each worker node
  provisioner "file" {
    source      = "/home/administrator/cloudcart/terraform-aws/scripts/join_command.sh" # Path to the join command file                                                        # Create the directory if it doesn't exist
    destination = "/home/ubuntu/cloudcart/scripts/join_command.sh"                      # Destination path on the worker node
  }

  # Execute the join command on each worker node to join it to the cluster
  provisioner "remote-exec" {
    inline = [
      "echo 'Executing join command on worker node...'",
      "set -ex",
      "sudo chmod -R u+rxw /home/ubuntu/cloudcart/scripts/join_command.sh",         # Ensure the directory is writable
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/cloudcart/scripts/join_command.sh", # Change ownership to the ubuntu user                                                # Exit on error
      "sudo sh /home/ubuntu/cloudcart/scripts/join_command.sh",                     # Execute the join command to join the worker node to the cluster
      "echo 'Worker node joined to the cluster successfully!'"
    ]
  }
}


# This resource verifies that the worker nodes have successfully joined the Kubernetes cluster.
resource "null_resource" "verify_worker_nodes" {
  depends_on = [aws_instance.k8s-worker, aws_instance.k8s-master, null_resource.fetch_join_command, null_resource.fetch_worker_join_command] # Ensure master and worker nodes are created before verifying

  connection {
    type        = "ssh"
    host        = aws_eip.k8s_master_eip.public_ip # Connect to the first worker node's elastic IP
    user        = "ubuntu"                         # Use the default user for Ubuntu instances
    private_key = file(var.ssh_key_private)        # Path to your private SSH key file
  }

  # This provisioner verifies that the worker nodes have successfully joined the Kubernetes cluster
  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for all nodes to be Ready...'",
      "for i in $(seq 1 30); do",          # try up to 30 times
      "  NOT_READY=$(kubectl get nodes | grep -v 'Ready' | wc -l)",
      "  if [ \"$NOT_READY\" -eq 0 ]; then",
      "    echo 'All nodes are Ready!'",
      "    exit 0",                       # success, exit loop
      "  fi",
      "  echo \"$NOT_READY nodes not ready yet. Waiting 10 seconds...\"",
      "  sleep 10",
      "done",
      "echo 'Timeout waiting for nodes to be Ready'",
      "kubectl get nodes -o wide", # Display the status of all nodes
      "echo 'Not all nodes are Ready after 5 minutes!'",
      "exit 1"                           # fail after timeout
     
    ]
  }
}
