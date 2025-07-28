#!/bin/bash
set -ex  # Exit on error and print commands

# -------------------------
# 1. Install Java 21 (for Jenkins)
# -------------------------
sudo apt update -y && sudo apt install -y wget gnupg2 software-properties-common

# Add Java 21 PPA and install
sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt update -y
sudo apt install -y openjdk-21-jdk fontconfig openjdk-21-jre
java -version

# -------------------------
# 2. Install Jenkins
# -------------------------
# Create the keyrings directory if it doesn't exist
sudo mkdir -p /etc/apt/keyrings

# Add Jenkins GPG key
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add Jenkins repository
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
    | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt-get update -y
sudo apt-get install -y jenkins

# Enable and start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins

# -------------------------
# 3. Install Terraform
# -------------------------
# Add HashiCorp GPG key and repo
wget -O- https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

# Install Terraform
sudo apt update && sudo apt install -y terraform
terraform -version

# Optional: Enable Terraform autocomplete
if [ -f ~/.bashrc ]; then
    terraform -install-autocomplete
fi

# -------------------------
# 4. Final system update (optional)
# -------------------------
sudo apt-get upgrade -y