#!/bin/bash

# This script installs Helm on a Debian-based system.
# It updates the package list, installs necessary dependencies,
# adds the Helm GPG key, adds the Helm repository, and installs Helm.
set -ex # Exit immediately if a command exits with a non-zero status.
echo 'Installing Helm on the master node...'
#!/bin/bash

set -ex
echo 'Installing Helm on the master node...'

# Download the Helm install script
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

# Make the script executable
chmod 700 get_helm.sh

# Run the install script
./get_helm.sh

# Check Helm version to verify installation
helm version

                                                    
