#!/bin/bash
set -ex # Exit on error and print commands

# Install dependencies
sudo apt update -y && sudo apt install -y wget gnupg2 
# Install Java 21
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt update -y
sudo apt install -y openjdk-21-jdk
sudo apt install fontconfig openjdk-21-jre
java -version

# Create the keyrings directory if it doesn't exist
sudo mkdir -p /etc/apt/keyrings

# Download and save the Jenkins GPG key
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add the Jenkins repo, specifying the keyring for signed packages
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package lists
sudo apt-get update -y

# Install Jenkins
sudo apt-get install -y jenkins
jenkins_version=$(jenkins --version)

# Start and enable Jenkins service
sudo systemctl start jenkins
sudo systemctl enable jenkins