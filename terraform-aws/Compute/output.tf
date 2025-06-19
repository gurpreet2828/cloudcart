output "k8s_master_connection_info" {
  description = "Connection information for the Kubernetes master node"
  value = {
    public_ip  = aws_instance.k8s-master.public_ip
    private_ip = aws_instance.k8s-master.private_ip
    dns_name   = aws_instance.k8s-master.public_dns
    ssh_command = "ssh -i ${var.ssh_key_private} ubuntu@${aws_instance.k8s-master.public_ip}"
  }
}


output "k8s_worker_connection_info" {
  description = "Connection information for the Kubernetes worker nodes"
  value = [
    for instance in aws_instance.k8s-worker : {
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
      dns_name   = instance.public_dns
      ssh_command = "ssh -i ${var.ssh_key_private} ubuntu@${instance.public_ip}"
    }
  ]
}
   