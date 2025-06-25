# This Terraform script installs Prometheus on an AWS EC2 instance using a remote script.

resource "null_resource" "install_prometheus" {
  depends_on = [
    var.k8s_master_dependency,
    var.fetch_join_command_dependency,
  null_resource.install_helm]

  connection {
    type        = "ssh"
    host        = var.k8s_master_eip
    user        = "ubuntu"
    private_key = file(var.ssh_key_private)
  }


  # creates the directory on master node if not exits
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/cloudcart/scripts",
      "sudo chmod u+rxw -R /home/ubuntu/cloudcart/scripts",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/cloudcart/scripts",
    ]

  }

  #Copy the install_prometheus.sh from local machine to master EC2 instance
  provisioner "file" {
    source      = "/home/administrator/cloudcart/terraform-aws/scripts/install_prometheus.sh"
    destination = "/home/ubuntu/cloudcart/scripts/install_prometheus.sh"

  }

  # Install Prometheus on master EC2 node
  provisioner "remote-exec" {
    inline = [
      "echo 'Installing Prometheus...'",
      "set -ex", # Enable debug mode to print commands and their arguments as they are executed
      "sudo chmod u+rxw /home/ubuntu/cloudcart/scripts/install_prometheus.sh",
      "sudo chown ubuntu:ubuntu /home/ubuntu/cloudcart/scripts/install_prometheus.sh",
      "sudo sh /home/ubuntu/cloudcart/scripts/install_prometheus.sh",
      "helm list -A",
      "echo 'Prometheus installation completed.'"
    ]
  }

}
