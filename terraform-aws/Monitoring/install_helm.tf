# This Terraform configuration installs Helm on the Kubernetes master node.


resource "null_resource" "install_helm" {
  depends_on = [
    var.k8s_master_dependency,         # Ensure the Kubernetes master node is ready
    var.fetch_join_command_dependency, # Ensure the join command is fetched
    var.deployment_app_dependency
  ]
  connection {
    type        = "ssh"
    host        = var.k8s_master_eip        # Connect to the master node's elastic IP
    user        = "ubuntu"                  # Use the default user for Ubuntu instances
    private_key = file(var.ssh_key_private) # Path to your private SSH key file
  }

  #Create a directory for scripts if it doesn't exist
  provisioner "remote-exec" {
    inline = [
      "echo 'Creating directory for scripts on master node...'",
      "sudo mkdir -p /home/ubuntu/cloudcart/scripts",                # Create a directory for scripts if it doesn't exist
      "sudo chmod -R u+rxw /home/ubuntu/cloudcart/scripts/",         # Ensure the directory is writable
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/cloudcart/scripts/", # Change ownership to the ubuntu user
      "echo 'Directory created successfully!'"
    ]
  }


  #Copy the install_helm.sh script from local machine to master EC2 instance

  provisioner "file" {
    source      = "${path.module}/../scripts/install_helm.sh" # Path to the Helm installation script
    destination = "/home/ubuntu/cloudcart/scripts/install_helm.sh"                      # Destination path on the master node
  }

  # Execute the Helm installation script on the master node
  provisioner "remote-exec" {
    inline = [
      "echo 'Installing Helm on the master node...'",
      "set -e",                                                                  # Exit on error,
      "sudo chmod u+rxw /home/ubuntu/cloudcart/scripts/install_helm.sh",         # Make the script executable
      "sudo chown ubuntu:ubuntu /home/ubuntu/cloudcart/scripts/install_helm.sh", # Change ownership to the ubuntu user
      "sudo sh /home/ubuntu/cloudcart/scripts/install_helm.sh",                  # Run the script to install Helm
      "helm version",                                                            # Check the Helm version to confirm installation
      "echo 'Helm installed successfully!'",

    ]

  }
}
