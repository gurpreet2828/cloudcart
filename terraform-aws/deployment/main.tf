resource "null_resource" "deployment_app" {
  depends_on = [
    var.k8s_master_dependency,
    var.fetch_join_command_dependency

  ]
  connection {
    type        = "ssh"
    host        = var.k8s_master_eip
    user        = "ubuntu"
    private_key = file(var.ssh_key_private)
  }
  provisioner "remote-exec" {
    inline = [
      "echo '-----Creating directory for application deployment on master node-----'",
      "sudo mkdir -p /home/ubuntu/cloudcart/deploy-sock-shop/kubernetes",               # Create a directory for application deployment if it doesn't exist
      "sudo chmod -R u+rxw /home/ubuntu/cloudcart/deploy-sock-shop/kubernetes",         # Ensure the directory is writable
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/cloudcart/deploy-sock-shop/kubernetes", # Change ownership to the ubuntu user
      "echo '---Directory created successfully!---'"
    ]

  }

  # Copy the manifest file for the deployment application from local machine to master Node
  provisioner "file" {
    source      = "${path.module}/../../deploy-sock-shop/kubernetes/sock-shop-full-deployment.yaml"
    destination = "/home/ubuntu/cloudcart/deploy-sock-shop/kubernetes/sock-shop-full-deployment.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "set -ex",
      "echo 'Deploying sock-shop application.....'",
      "sudo chown ubuntu:ubuntu /home/ubuntu/cloudcart/deploy-sock-shop/kubernetes/sock-shop-full-deployment.yaml",
      "sudo chmod u+rxw /home/ubuntu/cloudcart/deploy-sock-shop/kubernetes/sock-shop-full-deployment.yaml",
      "kubectl apply -f /home/ubuntu/cloudcart/deploy-sock-shop/kubernetes/sock-shop-full-deployment.yaml",
      "echo 'Watching pods come up in sock-shop namespace...'",
      "kubectl get pods -n sock-shop --watch &", # run watch in background
      "WATCH_PID=$!",                            # capture PID of background job
      "sleep 10",
      "echo 'Waiting for sock-shop pods to be ready...'",
      "kubectl wait --for=condition=Ready pods --all --namespace=sock-shop --timeout=300s",
      "kill $WATCH_PID || true", # cleanup background watch safely
      "echo 'Final pod status:'", 
      "kubectl get pods -n sock-shop",
      "echo 'All sock-shop pods are ready and sock-shop application deployed...'"
    ]

  }
}


