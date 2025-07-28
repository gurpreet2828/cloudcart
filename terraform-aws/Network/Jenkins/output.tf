output "jenkins_vpc_id" {
  value = aws_vpc.jenkins_vpc.id
  
}

output "jenkins_public_subnet_id" {
  value = aws_subnet.jenkins_public_subnet.id
  
}

output "jenkins_sg_id" {
  value = aws_security_group.jenkins_sg.id
}

