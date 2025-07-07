output "deployment_app_nodeport_url" {
  description = "Sock-Shop Application UI exopsed via NodePort on the master node"
  value = "http://${var.k8s_master_eip}:1050"
  
}

output "deployment_app" {
  description = "resource for deployment sock-shop application"
  value = null_resource.deployment_app.id
  
}