resource "null_resource" "kube_state_metrics" {
  depends_on = [
    var.k8s_master_dependency,
    var.fetch_join_command_dependency,
    null_resource.install_helm,
    null_resource.install_prometheus,
    null_resource.install_grafana,
    var.deployment_app_dependency
  ]
  connection {
    type        = "ssh"
    host        = var.k8s_master_eip
    user        = "ubuntu"
    private_key = file(var.ssh_key_private)
  }
  #..................................................
  #Installation of grafana in Kubernetes using Helm
  #.................................................

  # Create a directory named scripts in master node

  # provisioner "remote-exec" {
  #   inline = [
  #     "echo 'Creating directory for scripts on master node...'",
  #     "sudo mkdir -p /home/ubuntu/cloudcart/scripts",                # Create a directory for scripts if it doesn't exist
  #     "sudo chmod -R u+rxw /home/ubuntu/cloudcart/scripts/",         # Ensure the directory is writable
  #     "sudo chown -R ubuntu:ubuntu /home/ubuntu/cloudcart/scripts/", # Change ownership to the ubuntu user
  #     "echo 'Directory created successfully!'"
  #   ]

  # }
  # #copy the script local machine to naster EC2 node
  # provisioner "file" {
  #   source      = "/home/administrator/cloudcart/terraform-aws/scripts/install_grafana.sh"
  #   destination = "/home/ubuntu/cloudcart/scripts/install_grafana.sh"
  # }

  # #Install the grafana on master node
  # provisioner "remote-exec" {
  #   inline = [
  #     "echo 'installing Grafana...'",
  #     "set -ex",
  #     "sudo chmod -R u+rxw /home/ubuntu/cloudcart/scripts/install_grafana.sh",
  #     "sudo chown -R ubuntu:ubuntu /home/ubuntu/cloudcart/scripts/install_grafana.sh",
  #     "sudo sh /home/ubuntu/cloudcart/scripts/install_grafana.sh",
  #     "helm list -A",
  #     "echo 'grafana installed successfully'"

  #   ]

  # }


  #..............................................
  #...Installation of Grafana using manifest files
  #.............................................
  provisioner "remote-exec" {
    inline = [
      "echo 'Creating directory for kube-state-metrics manifests...'",
      "sudo mkdir -p /home/ubuntu/cloudcart/deploy-sock-shop/Monitoring",
      "sudo chmod -R u+rxw /home/ubuntu/cloudcart/deploy-sock-shop/Monitoring",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/cloudcart/deploy-sock-shop/Monitoring",
      "echo 'Directory setup complete for kube-state-metrics: /home/ubuntu/cloudcart/deploy-sock-shop/Monitoring'"
    ]

  }

  #Copy the yaml files from local machine to master EC2 instance
  provisioner "local-exec" {
    command = <<EOT
   echo "copy entire prometheus yaml files from loacl to master node"
   scp -o StrictHostKeyChecking=no -i ${var.ssh_key_private} -r /home/administrator/cloudcart/deploy-sock-shop/monitoring-app/kube-state-metrics ubuntu@${var.k8s_master_eip}:/home/ubuntu/cloudcart/deploy-sock-shop/Monitoring
   EOT

  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Applying kube-state-metrics.....'",
      "set -ex", # Enable debug mode to print commands and their arguments as they are executed
      "sudo chmod -R u+rxw /home/ubuntu/cloudcart/deploy-sock-shop/Monitoring/kube-state-metrics",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/cloudcart/deploy-sock-shop/Monitoring/kube-state-metrics",
      "ls -l /home/ubuntu/cloudcart/deploy-sock-shop/Monitoring/kube-state-metrics",
      "kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -",
      "kubectl apply -f /home/ubuntu/cloudcart/deploy-sock-shop/Monitoring/kube-state-metrics",
      "kubectl get pods -n monitoring",
      "echo 'Grafana installation completed.'"
    ]
  }
}
