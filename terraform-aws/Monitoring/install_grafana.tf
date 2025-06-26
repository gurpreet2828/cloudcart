resource "null_resource" "install_grafana" {
  depends_on = [
    var.k8s_master_dependency,
    var.fetch_join_command_dependency,
    null_resource.install_helm,
    null_resource.install_prometheus
  ]
  connection {
    type        = "ssh"
    host        = var.k8s_master_eip
    user        = "ubuntu"
    private_key = file(var.ssh_key_private)
  }
  # Create a directory named scripts in master node
  provisioner "remote-exec" {
    inline = [
      "echo 'Creating directory for scripts on master node...'",
      "sudo mkdir -p /home/ubuntu/cloudcart/scripts",                # Create a directory for scripts if it doesn't exist
      "sudo chmod -R u+rxw /home/ubuntu/cloudcart/scripts/",         # Ensure the directory is writable
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/cloudcart/scripts/", # Change ownership to the ubuntu user
      "echo 'Directory created successfully!'"
    ]

  }
  #copy the script local machine to naster EC2 node
  provisioner "file" {
    source = "/home/administrator/cloudcart/terraform-aws/scripts/install_grafana.sh"
    destination = "/home/ubuntu/cloudcart/scripts/install_grafana.sh"
  }

#Install the grafana on master node
  provisioner "remote-exec" {
    inline = [ 
      "echo 'installing Grafana...'",
      "set -ex",
      "sudo chmod -R u+rxw /home/ubuntu/cloudcart/scripts/install_grafana.sh",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/cloudcart/scripts/install_grafana.sh",
      "sudo sh /home/ubuntu/cloudcart/scripts/install_grafana.sh",
      "helm list -A",
      "echo 'grafana installed successfully'"

     ]
    
  }
}
