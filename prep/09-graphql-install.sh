################################################################################
# Author: James Buckett
# email: james.buckett@gmail.com
# Script to install GraphQL
################################################################################

################################################################################

#- Simple setup for converting Kubernetes API server into [GraphQL API]
# (https://github.com/onelittlenightmusic/kubernetes-graphql)
# Query list pods
# kubectl get pods --namespace ns-microservices-demo -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.startTime}{"\n"}{end}'
# Get pods with labels
################################################################################

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
echo "Installing GraphQL..."
sleep 5