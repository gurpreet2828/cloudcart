resource "aws_ami_from_instance" "k8s_worker_ami" {
  depends_on              = [null_resource.install-k8s-worker, aws_instance.k8s-worker, aws_instance.k8s-master]  # Ensure the instance is created before creating the AMI
  name                    = "k8s-worker-ami"
  source_instance_id      = aws_instance.k8s-worker[0].id # Instance ID of the Kubernetes worker node
  snapshot_without_reboot = true                          # Create the AMI without rebooting the instance
 

  tags = {
    Name      = "K8S Worker AMI"
    CreatedBy = "Terraform"
  }
  description = "AMI for Kubernetes worker nodes"
}


resource "null_resource" "delete_ami_on_worker_destroy" {
  triggers = {
    ami_id = aws_ami_from_instance.k8s_worker_ami.id
  }

  provisioner "local-exec" {
    when    = destroy
    command = "aws ec2 deregister-image --image-id ${self.triggers.ami_id}"
  }
}
