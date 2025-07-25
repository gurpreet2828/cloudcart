# # This Terraform script installs Prometheus on an AWS EC2 instance using a remote script.

# resource "null_resource" "install_monitoring_tools" {
#   depends_on = [
#     var.k8s_master_dependency,
#     var.fetch_join_command_dependency,
#   null_resource.install_helm,
#   var.deployment_app_dependency]

#   connection {
#     type        = "ssh"
#     host        = var.k8s_master_eip
#     user        = "ubuntu"
#     private_key = file(var.ssh_key_private)
#   }

#   #................................................
#   #...Installing of Prometheus in Kubernetes using Helm
#   #................................................

#   # provisioner "remote-exec" {
#   #   inline = [
#   #     "echo 'creating directory for saving scripts...'",
#   #     "set -ex",
#   #     "sudo mkdir -p /home/ubuntu/cloudcart/scripts",
#   #     "sudo chmod u+rxw /home/ubuntu/cloudcart/scripts",
#   #     "sudo chown ubuntu:ubuntu /home/ubuntu/cloudcart/scripts",
#   #     "echo 'Script directed ccreated with read-write permission on master node...'"
#   #   ]
#   # }

#   # provisioner "file" {
#   #   source      = "/home/administrator/cloudcart/terraform-aws/scripts/install_prometheus.sh"
#   #   destination = "/home/ubuntu/cloudcart/scripts/install_prometheus.sh"

#   # }

#   # #Install Prometheus on master EC2 node
#   # provisioner "remote-exec" {
#   #   inline = [
#   #     "echo 'Installing Prometheus...'",
#   #     "set -ex", # Enable debug mode to print commands and their arguments as they are executed
#   #     "sudo chmod u+rxw /home/ubuntu/cloudcart/scripts/install_prometheus.sh",
#   #     "sudo chown ubuntu:ubuntu /home/ubuntu/cloudcart/scripts/install_prometheus.sh",
#   #     "sudo sh /home/ubuntu/cloudcart/scripts/install_prometheus.sh",
#   #     "helm list -A",
#   #     "echo 'Prometheus installation completed.'"
#   #   ]
#   # }

#   # ---------------------------------------------
#   # Installation of Prometheus Using Manifest Files
#   # ---------------------------------------------

#   provisioner "remote-exec" {
#     inline = [
#       "sudo mkdir -p /home/ubuntu/cloudcart/deploy-sock-shop/Monitoring",
#       "sudo chmod u+rxw -R /home/ubuntu/cloudcart/deploy-sock-shop/Monitoring",
#       "sudo chown -R ubuntu:ubuntu /home/ubuntu/cloudcart/deploy-sock-shop/Monitoring",
#     ]

#   }

#   #Copy the yaml files from local machine to master EC2 instance
#   provisioner "local-exec" {
#     command = <<EOT
#    echo "copy entire prometheus yaml files from loacl to master node"
#    scp -o StrictHostKeyChecking=no -i ${var.ssh_key_private} -r /home/administrator/cloudcart/deploy-sock-shop/monitoring-app/manifests-monitoring ubuntu@${var.k8s_master_eip}:/home/ubuntu/cloudcart/deploy-sock-shop/Monitoring
#    EOT

#   }

#   provisioner "remote-exec" {
#     inline = [
#       "echo 'Installing Prometheus...'",
#       "set -ex", # Enable debug mode to print commands and their arguments as they are executed
#       # "sudo chmod -R u+rxw /home/ubuntu/cloudcart/deploy-sock-shop/Monitoring/manifests-monitoring",
#       "sudo chown -R ubuntu:ubuntu /home/ubuntu/cloudcart/deploy-sock-shop/Monitoring/manifests-monitoring",
#       "ls -l /home/ubuntu/cloudcart/deploy-sock-shop/Monitoring/manifests-monitoring",
#       #"kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -",
#       #"kubectl apply -f /home/ubuntu/cloudcart/deploy-sock-shop/Monitoring/manifests-monitoring",
#       #"kubectl get pods -n monitoring",
#       "echo 'Monitoring tools installation completed.'"
#     ]
#   }
# }




