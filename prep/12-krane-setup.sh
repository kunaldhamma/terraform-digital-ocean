################################################################################
# Author: James Buckett
# email: james.buckett@gmail.com
# Script to install Krane
################################################################################

################################################################################
# Krane is a simple Kubernetes RBAC static analysis tool. 
# It identifies potential security risks in K8s RBAC design and makes suggestions on how to mitigate them. 
# Krane dashboard presents current RBAC security posture and lets you navigate through its definition.
# Link: https://github.com/appvia/krane
################################################################################

# To install from digital-ocean-droplet
# wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/prep/12-krane-setup.sh
# chmod +x 12-krane-setup.sh
# ./12-krane-setup.sh

#!/bin/bash

################################################################################
# Check that you are on jump host and not local host
################################################################################
if [ "$HOSTNAME" = "digital-ocean-droplet" ]; then

################################################################################
# Stop the script on errors
################################################################################
set -euo pipefail

clear
echo "Installing Krane..."
sleep 5

git clone https://github.com/appvia/krane.git

kubectl apply -f /root/krane/k8s/one-time/prerequisites.yaml

cd krane

kubectl create \
  --context do-sgp1-digital-ocean-cluster \
  --namespace krane \
  -f k8s/redisgraph-service.yaml \
  -f k8s/redisgraph-deployment.yaml \
  -f k8s/krane-service.yaml \
  -f k8s/krane-deployment.yaml

else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi

# End of Script