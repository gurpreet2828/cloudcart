
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

