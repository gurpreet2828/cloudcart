
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


# output of Prometheus UI exposed via NodePort on the master
output "prometheus_nodeport_url" {
  description = "Prometheus UI exposed via NodePort on the master node"
  value       = module.Monitoring.prometheus_nodeport_url

}

output "grafana_nodeport_url" {
  description = "Grafana UI exposed via NodePort on the master node"
  value       = module.Monitoring.grafana_nodeport_url
}

output "deployment_app_nodeport_url" {
  description = "Sock-Shop Application UI exopsed via NodePort on the master node"
  value       = module.deployment.deployment_app_nodeport_url

}
