#!/bin/bash

set -ex                                 # Exit on error

# Update and install dependencies
apt update && apt upgrade -y
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

# Disable swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/' /etc/fstab

# Load kernel modules
modprobe overlay
modprobe br_netfilter

# Set sysctl params
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system

# Install containerd from official repo
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null

apt update
apt install -y containerd.io

# Configure containerd and start service
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# Optional: make sure Systemd cgroup driver is enabled for containerd (recommended by Kubernetes)
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd
systemctl start containerd
echo "containerd installed and started."

# Add Kubernetes repo
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes components
apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
systemctl enable kubelet
systemctl start kubelet
echo "Kubernetes worker node setup complete."
echo "Please run the kubeadm join command provided by your Kubernetes master node to join this worker node to the cluster."
echo "For example:"
echo "kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash> --ignore-preflight-errors=all"
# Note: The user should replace <master-ip>, <token>, and <hash> with the actual values from their Kubernetes master node.


# Install AWS CLI
# Update packages
sudo apt update

# Install dependencies
sudo apt install -y unzip curl

# Download AWS CLI v2 installer
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unzip installer
unzip awscliv2.zip

# Run install script
sudo ./aws/install

# Verify installation
aws --version

# Clean up
rm awscliv2.zip
sudo rm -rf aws

# Save log file
BucketName="my-k8s-bucket-1111" # Replace with your S3 bucket name
Timestamp=$(date +"%Y%m%d_%H%M%S")

aws s3 cp /var/log/cloud-init.log s3://$BucketName/logs/k8s-worker-logs/cloud-init-$Timestamp.log
aws s3 cp /var/log/cloud-init-output.log s3://$BucketName/logs/k8s-worker-logs/cloud-init-output-$Timestamp.log