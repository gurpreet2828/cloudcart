output "prometheus_nodeport_url" {
  value = "http://${var.k8s_master_eip}:1030"
  description = "Prometheus UI exposed via NodePort on the master node"
}

output "grafana_nodeport_url" {
  description = "Grafana UI exopsed via NodePort on the master node"
  value = "http://${var.k8s_master_eip}:1031"
  
}