#!/bin/bash

set -e

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

# Add Docker repository
# Use the architecture from dpkg and the Ubuntu release codename
# Note: The `lsb_release -cs` command retrieves the codename of the Ubuntu release (e.g., "jammy" for 22.04)

mkdir -p /etc/apt/keyrings # Create directory for Docker GPG key
# Download Docker GPG key and convert to keyring format
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null

apt update                                           # Update package index
apt install -y docker-ce docker-ce-cli containerd.io # Install Docker packages

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Add Kubernetes repo
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes components
apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
systemctl enable kubelet

echo "Kubernetes worker node setup complete."
echo "Please run the kubeadm join command provided by your Kubernetes master node to join this worker node to the cluster."
echo "For example:"
echo "kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash> --ignore-preflight-errors=all"
# Note: The user should replace <master-ip>, <token>, and <hash> with the actual values from their Kubernetes master node.

