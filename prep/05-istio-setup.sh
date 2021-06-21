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
# Istio - Service Mesh
# Link: https://blog.alexellis.io/a-bit-of-istio-before-tea-time/ 
################################################################################

################################################################################
# Stop the script on errors
################################################################################
set -euo pipefail

clear
echo "Installing Istio..."
# watch -n 1 kubectl get all -n  ns-istio
sleep 5

arkade install istio

kubectl create namespace ns-istio-sample

kubectl label namespace ns-istio-sample istio-injection=enabled

kubectl config set-context --current --namespace=ns-istio-sample

kubectl label namespace ns-istio goldilocks.fairwinds.com/enabled=true

# Istio Ingress
kubectl apply -f "https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/ingress/ingress-istio.yml"

doctl compute domain records create jamesbuckett.com --record-type CNAME --record-name istio --record-data www. --record-ttl=43200

# BookInfo Sample Application
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.9/samples/bookinfo/platform/kube/bookinfo.yaml 

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.10/samples/addons/kiali.yaml

sleep 10

# If this error below occurs run this command again 
# MonitoringDashboard" in version "monitoring.kiali.io/v1alpha1"
# unable to recognize "https://raw.githubusercontent.com/istio/istio/release-1.10/samples/addons/kiali.yaml": no matches for kind "
# kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.10/samples/addons/kiali.yaml


clear
echo "Installed Istio..."
sleep 5

else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi

# End of Script