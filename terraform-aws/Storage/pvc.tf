resource "null_resource" "pvc_localstorage" {
  count = var.enable_pvc_localstorage ? 1 : 0 # Create the resource only if enable_pvc_localstorage is true
  depends_on = [
    var.k8s_master_dependency,
    var.fetch_join_command_dependency,
    var.monitoring_dependency
  ]
  connection {
    type        = "ssh"
    host        = var.k8s_master_eip
    user        = "ubuntu"
    private_key = file(var.ssh_key_private)
  }

  provisioner "remote-exec" {
    inline = [
      "set -ex",
      "echo 'installing local storage provisioner...'",
      "kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml",
      "kubectl patch storageclass local-path -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"true\"}}}'",
      "kubectl get storageclass",
      "echo 'Local storage provisioner installed successfully.'",
      "sudo mkdir -p /home/ubuntu/cloudcart/deploy-sock-shop/pvc_storage",
      "sudo chmod -R u+rxw /home/ubuntu/cloudcart/deploy-sock-shop/pvc_storage",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/cloudcart/deploy-sock-shop/pvc_storage",
      "echo 'Directory setup complete for pvc storage: /home/ubuntu/cloudcart/deploy-sock-shop/pvc_storage'"
    ]
  }

  provisioner "local-exec" {
    command = <<EOT
      set -ex
      echo "Copy PVC manifest to remote instance"
      scp -i ${var.ssh_key_private} -o StrictHostKeyChecking=no -r ${path.root}/deploy-sock-shop/pvc_storage ubuntu@${var.k8s_master_eip}:/home/ubuntu/cloudcart/deploy-sock-shop
      echo "PVC manifest copied successfully"   
    EOT
  }


  provisioner "remote-exec" {
    inline = [
      "set -ex",
      "sudo chmod -R u+rxw /home/ubuntu/cloudcart/deploy-sock-shop/pvc_storage/",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/cloudcart/deploy-sock-shop/pvc_storage",
      "[ -f /home/ubuntu/cloudcart/deploy-sock-shop/pvc_storage/grafana-pvc-localstorage.yaml ] || (echo 'Missing grafana PVC' && exit 1)",
      "[ -f /home/ubuntu/cloudcart/deploy-sock-shop/pvc_storage/prometheus-pvc-localstorage.yaml ] || (echo 'Missing prometheus PVC' && exit 1)",
      "ls -lta /home/ubuntu/cloudcart/deploy-sock-shop/pvc_storage",
      "echo 'Applying PVC manifests for local storage...'",
      "kubectl apply -f /home/ubuntu/cloudcart/deploy-sock-shop/pvc_storage/grafana-pvc-localstorage.yaml -n monitoring",
      "kubectl apply -f /home/ubuntu/cloudcart/deploy-sock-shop/pvc_storage/prometheus-pvc-localstorage.yaml -n monitoring",
      "kubectl get pvc -n monitoring",
      "echo 'PVC for local storage created successfully.'"
    ]
  }
}
