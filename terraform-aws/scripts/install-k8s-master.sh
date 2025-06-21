#!/bin/bash

set -e # Exit on error
exec >>/var/log/install-k8s-master.log # Redirect stdout to a log file
exec 2>&1 # Redirect stderr to stdout

# Check if the script is run as root, If not, re-run with sudo

if [ "$EUID" -ne 0 ]; then # Check if the script is run as root
  echo "If you are not logged in as root, please run the script with sudo."
  exec sudo bash "$0" "$@" # Re-run the script with sudo
fi
echo "Running as root, proceeding with Kubernetes Control Plane setup on Ubuntu 24.04"

# Update and install dependencies
apt update && apt upgrade -y
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common
echo "Installing dependencies completed."

# Disable swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/' /etc/fstab
echo "Swap disabled."

# Load required kernel modules
modprobe overlay
modprobe br_netfilter
echo "Kernel modules loaded."


# Set up sysctl parameters
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system
echo "Sysctl parameters set."


# Install Docker
#mkdir -p /etc/apt/keyrings # Create directory for Docker GPG key
# Download Docker GPG key and convert to keyring format
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
#echo "Docker GPG key added."
# Add Docker repository
# Use the architecture from dpkg and the Ubuntu release codename
# Note: The `lsb_release -cs` command retrieves the codename of the Ubuntu release (e.g., "jammy" for 22.04)
#echo \
 # "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  #$(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null

#apt update                                           # Update package index
#apt install -y docker-ce docker-ce-cli containerd.io # Install Docker packages
#echo "Docker installation completed."

# Enable and start Docker
#systemctl enable docker
#systemctl start docker

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

echo "containerd installed and started."

# Add Kubernetes repo
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
echo "Kubernetes repository added."

# Install Kubernetes components
apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
systemctl enable kubelet
echo "Kubernetes components installed."

# Create kubeadm config
cat <<EOF >/root/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: "1.32.0"
networking:
  podSubnet: "192.168.0.0/16"
apiServer:
  extraArgs:
    service-node-port-range: "1024-1233"
EOF
echo "Kubeadm configuration file created at /root/kubeadm-config.yaml"

# Initialize Kubernetes
kubeadm init --config=/root/kubeadm-config.yaml --ignore-preflight-errors=all

# Setup kubectl for ubuntu user
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config

# Install Calico network plugin
su - ubuntu -c "kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml"

# Done
echo " Kubernetes Control Plane setup completed on Ubuntu 24.04"
echo " You can now use kubectl to manage your cluster."
echo "To add worker nodes, run the kubeadm join command shown above on each node."
echo "create token for worker nodes using: kubeadm token create --print-join-command"

# Note: The kubeadm join command for worker nodes should be executed separately.
# To get the join command, run the following command on the master node:
# kubeadm token create --print-join-command
