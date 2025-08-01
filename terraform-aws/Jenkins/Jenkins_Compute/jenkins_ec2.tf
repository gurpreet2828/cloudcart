resource "aws_key_pair" "aws_jenkins_key" {
  key_name   = "jenkins_key"
  public_key = file("${path.root}/terraform-aws/keys/jenkins_key.pub")

  tags = {
    Name = "Jenkins_Key_Pair"
  }
}


resource "aws_instance" "jenkins_instance" {
  ami                         = var.jenkins_ami
  instance_type               = var.jenkins_instance_type
  key_name                    = aws_key_pair.aws_jenkins_key.key_name
  subnet_id                   = var.jenkins_public_subnet
  vpc_security_group_ids      = [var.jenkins_sg]
  associate_public_ip_address = true
  user_data = file("${path.root}/terraform-aws/scripts/install_jenkins_terraform.sh") # Path to the user data script for Jenkins installation
  #user_data = file("terraform-aws/scripts/install_jenkins_terraform.sh")
  tags = {
    Name = "Jenkins_Instance"
  }

  root_block_device {
    volume_size           = var.jenkins_disk_size
    volume_type           = "gp3"
    delete_on_termination = true
    tags = {
      Name = "Jenkins_Instance_Root_volume"
    }
  }
}
resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins_instance.id

  tags = {
    Name = "Jenkins_EIP"
  }
}


resource "null_resource" "jenkins_instance_ready" {
  depends_on = [aws_instance.jenkins_instance, aws_eip.jenkins_eip]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.jenkins_key_private)
    host        = aws_eip.jenkins_eip.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Jenkins instance is ready!'",
      "bash -c 'until command -v java >/dev/null 2>&1; do echo Waiting for java...; sleep 5; done'",
      "bash -c 'until systemctl is-active --quiet jenkins; do echo 'Waiting...'; sleep 10; done'",
      "bash -c 'until command -v terraform >/dev/null 2>&1; do echo Waiting for terraform...; sleep 5; done'",
      "java -version",
      "jenkins --version",
      "terraform -version",
      "echo 'Jenkins is installed and running!'",

    ]
  }
}
