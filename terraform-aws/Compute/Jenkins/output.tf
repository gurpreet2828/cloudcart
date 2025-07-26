output "jenkins_instance_info" {
  description = "Connection information for the Jenkins master node"
  value = {
    elastic_ip  = aws_eip.jenkins_eip.public_ip
    jenkins_url = "http://${aws_eip.jenkins_eip.public_ip}:8080"
    private_ip  = aws_instance.jenkins_instance.private_ip
    dns_name    = aws_instance.jenkins_instance.public_dns
    ssh_command = "ssh -i ${var.jenkins_key_private} ubuntu@${aws_eip.jenkins_eip.public_ip}"
    tags = {
      Name = aws_instance.jenkins_instance.tags["Name"]
    }
  }
}

output "jenkins_eip" {
  description = "Elastic IP address of the Jenkins instance"
  value       = aws_eip.jenkins_eip.public_ip
}

output "jenkins_instance_id" {
  description = "Instance ID of the Jenkins instance"
  value       = aws_instance.jenkins_instance.id
}

