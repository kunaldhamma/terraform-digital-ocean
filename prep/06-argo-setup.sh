################################################################################
# Author: James Buckett
# email: james.buckett@gmail.com
# Script to install Istio
################################################################################

#!/bin/bash

################################################################################
# Check that you are on jump host and not local host
################################################################################
if [ "$HOSTNAME" = "digital-ocean-droplet" ]; then

################################################################################
# Clear any previous installations
################################################################################
cd ~/ && rm -R ~/argo

################################################################################
# Stop the script on errors
################################################################################
set -euo pipefail

################################################################################
# Argo CLI
################################################################################
clear
echo "Installing Argo CLI..."
cd ~/ && mkdir argo && cd argo
curl -sLO https://github.com/argoproj/argo/releases/download/v3.0.1/argo-linux-amd64.gz
gunzip argo-linux-amd64.gz
chmod +x argo-linux-amd64
mv ./argo-linux-amd64 /usr/local/bin/argo
argo version
sleep 5

################################################################################
# Argo - Cloud Native Workflow
################################################################################
kubectl create ns ns-argo
kubectl apply -n ns-argo -f https://raw.githubusercontent.com/argoproj/argo-workflows/stable/manifests/quick-start-postgres.yaml
kubectl wait -n ns-argo deploy argo-server --for condition=Available --timeout=90s

# kubectl patch svc argo-server -n ns-argo -p '{"spec": {"type": "LoadBalancer"}}'
# ports:
#     - name: https # Use http or https
#        protocol: TCP
#        port: 8080
#        targetPort: 8080

kubectl label namespace ns-argo goldilocks.fairwinds.com/enabled=true

# Argo Ingress
kubectl apply -f "https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/ingress/ingress-argo.yml"

doctl compute domain records create jamesbuckett.com --record-type CNAME --record-name argo --record-data www. --record-ttl=43200

clear
echo "Installed Argo..."
sleep 5

else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi

# End of Script