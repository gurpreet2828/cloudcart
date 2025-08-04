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

output "k8s_worker_instances" {
  description = "List of instance IDs for the Kubernetes worker nodes"
  value       = [for instance in aws_instance.k8s-worker : instance.id]
}

output "fetch_join_command" {
  description = "Command to join worker nodes to the Kubernetes cluster"
  value       = null_resource.fetch_join_command.id
}

output "k8s_worker_ami_id" {
  description = "AMI ID for the Kubernetes worker nodes"
  value       = aws_ami_from_instance.k8s_worker_ami.id
}