#!/bin/bash

set -ex
export KUBECONFIG=/etc/kubernetes/admin.conf
echo 'Installing Helm on the master node...'

helm repo add grafana https://grafana.github.io/helm-charts
helm repo list
helm repo update
# Check if the 'monitoring' namespace exists, if not, create it
kubectl get namespace monitoring >/dev/null 2>&1 || kubectl create namespace monitoring 
helm search repo grafana/grafana
# Install grafana using Helm
helm install my-grafana grafana/grafana --namespace monitoring \
  --set service.type=NodePort \
  --set service.nodePort=1031
echo "Grafana installed successfully in 'monitoring' namespace."