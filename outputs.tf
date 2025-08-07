
output "k8s_master_connection_info" {
  description = "Connection information for the Kubernetes master node"
  value       = module.Compute.k8s_master_connection_info
  # This module should return a map with keys: public_ip, private_ip, dns_name, ssh_command{

}

output "k8s_worker_connection_info" {
  description = "Connection information for the Kubernetes worker nodes"
  value       = module.Compute.k8s_worker_connection_info

  # This module should return a list of maps, each with keys: public_ip, private_ip, dns_name, ssh_command{    
}

output "monitoring_publicip_connection_info" {
  description = "Connection information for the monitoring tools"
  value = {
    prometheus_url = module.Monitoring.prometheus_nodeport_url
    grafana_url    = module.Monitoring.grafana_nodeport_url
  }
 # This module should return a map with keys: prometheus_url, grafana_url, ssh_command{
}

# output of Prometheus UI exposed via NodePort on the master
# output "prometheus_nodeport_url" {
#   description = "Prometheus UI exposed via NodePort on the master node"
#   value       = var.enable_monitoring ? module.Monitoring[0].prometheus_nodeport_url : null

# }

# output "grafana_nodeport_url" {
#   description = "Grafana UI exposed via NodePort on the master node"
#   value       = module.Monitoring.grafana_nodeport_url
# }


output "deployment_app_nodeport_url" {
  description = "Sock-Shop Application UI exopsed via NodePort on the master node"
  value       = module.deployment.deployment_app_nodeport_url

}

output "k8s_alb_dns_name" {
  value = module.ALB_Controller.k8s_alb_dns_name
}

output "Storage_module_status" {
  description = "value indicating Storage module is enabled or disabled"
  value = {
    s3_storage_status     = module.Storage.s3_storage_status
    dynamodb_table_status = module.Storage.dynamodb_table_status
    pvc_localstorage_status = module.Storage.pvc_localstorage_status
  }
}


# output of Jenkins instance information
output "jenkins_instance_info" {
  description = "Connection information for the Jenkins master node"
  value = length(module.Jenkins_Compute) > 0 ? module.Jenkins_Compute[0].jenkins_instance_info : null

  
}

output "Jenkins_module_status" {
  description = "value indicating Jenkins module is enabled or disabled"
  value = var.enable_jenkins ? "ENABLED" : "DISABLED"
}

