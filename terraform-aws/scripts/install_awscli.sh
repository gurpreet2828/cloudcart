#! /bin/bash

# Install AWS CLI
# Update packages
apt update -y

# Install dependencies
apt install -y unzip curl

# Download AWS CLI v2 installer
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unzip installer
unzip awscliv2.zip

# Run install script
./aws/install

# Verify installation
echo "Installation complete, verifying installed tools..."

which aws
aws --version