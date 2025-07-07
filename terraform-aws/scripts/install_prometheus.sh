#!/bin/bash
# This script installs Prometheus on a Kubernetes cluster using Helm.
set -ex # Exit on error and print commands
export KUBECONFIG=/etc/kubernetes/admin.conf

echo "Installing Prometheus on the Kubernetes cluster..."

echo "Adding Prometheus Helm repo..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
# Check if the 'monitoring' namespace exists, if not, create it
kubectl get namespace monitoring >/dev/null 2>&1 || kubectl create namespace monitoring 
# Install Prometheus using Helm and expose node port outside the K8s infra
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set nameOverride=prometheus \
  --set fullnameOverride=prometheus \
  --set prometheus.service.type=NodePort \
  --set prometheus.service.nodePort=1030
echo "Prometheus installed successfully in 'monitoring' namespace."
