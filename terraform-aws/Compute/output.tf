output "k8s_master_connection_info" {
  description = "Connection information for the Kubernetes master node"
  value = {
    #public_ip = aws_instance.k8s-master.public_ip
    elastic_ip  = aws_eip.k8s_master_eip.public_ip
    private_ip  = aws_instance.k8s-master.private_ip
    dns_name    = aws_instance.k8s-master.public_dns
    ssh_command = "ssh -i ${var.ssh_key_private} ubuntu@${aws_eip.k8s_master_eip.public_ip}"
    tags = {
      Name = aws_instance.k8s-master.tags["Name"]
    }
  }
}

output "k8s_worker_connection_info" {
  description = "Connection information for the Kubernetes worker nodes"
  value = [
    for idx, instance in aws_instance.k8s-worker : {
      #public_ip = instance.public_ip
      elastic_ip  = aws_eip.k8s_worker_eip[idx].public_ip
      private_ip  = instance.private_ip
      dns_name    = instance.public_dns
      ssh_command = "ssh -i ${var.ssh_key_private} ubuntu@${aws_eip.k8s_worker_eip[idx].public_ip}"
      tags = {
        Name = instance.tags["Name"]
      }
    }
  ]
}


output "k8s_master_eip" {
  description = "Elastic IP address of the Kubernetes master node"
  value       = aws_eip.k8s_master_eip.public_ip
}

output "k8s_master_instance" {
  description = "Instance ID of the Kubernetes master node"
  value       = aws_instance.k8s-master.id
}

output "fetch_join_command" {
  description = "Command to join worker nodes to the Kubernetes cluster"
  value       = null_resource.fetch_join_command.id
}

output "k8s_alb_dns_name" {
  description = "DNS name of the Application Load Balancer (ALB)"
  value       = aws_lb.k8s_alb.dns_name
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets in the Kubernetes VPC"
  value  = var.public_subnet_ids
}
