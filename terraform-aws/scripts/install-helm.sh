#!/bin/bash

# This script installs Helm on a Debian-based system.
# It updates the package list, installs necessary dependencies,
# adds the Helm GPG key, adds the Helm repository, and installs Helm.
set -e # Exit immediately if a command exits with a non-zero status.
echo 'Installing Helm on the master node...'
curl -fsSL -o https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 # Download the Helm installation script
chmod 700 get-helm-3                                                                # Make the script executable
sudo ./get-helm-3                                                                   # Run the Helm installation script
helm version                                                                        # Verify the installation by printing the Helm version
