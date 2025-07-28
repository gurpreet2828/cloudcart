#!/bin/bash
set -ex # Exit on error and print commands

# Install dependencies
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
# Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
# Update package lists and install Terraform
sudo apt update && sudo apt install -y terraform
# Verify installation
terraform -version

# Create a .bashrc file if it doesn't exist
touch ~/.bashrc
# Add Terraform autocomplete to .bashrc
terraform -install-autocomplete
