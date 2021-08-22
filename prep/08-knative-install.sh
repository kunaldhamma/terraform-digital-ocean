################################################################################
# Author: James Buckett
# email: james.buckett@gmail.com
# Script to install Knative
# Create your first Knative app
# Link : https://opensource.com/article/20/11/knative
################################################################################

# To install from digital-ocean-droplet
# wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/prep/08-knative-install.sh
# chmod +x 08-knative-install.sh
# ./08-knative-install.sh

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
echo "Installing Knative..."
sleep 5

# Knative CLI install
clear
echo "Installing Knative CLI..."
cd ~/ && rm -R ~/knative
cd ~/ && mkdir knative && cd knative
wget https://storage.googleapis.com/knative-nightly/client/latest/kn-linux-amd64
chmod +x kn-linux-amd64
mv kn-linux-amd64 kn
sudo cp kn /usr/local/bin
kn version
echo "Knative CLI installed..."
sleep 5

# Knative Installation
echo "Installing Knative Serving..."
export KNATIVE="0.25.0"

kubectl delete namespace knative-serving
clear
kubectl create namespace knative-serving
kubectl apply -f https://github.com/knative/serving/releases/download/v$KNATIVE/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/v$KNATIVE/serving-core.yaml
kubectl wait -n knative-serving deploy controller --for condition=Available --timeout=90s
echo "Knative serving installed...."
sleep 5

# Kourier Installation
echo "Installing Kourier..."
export KOURIER="0.25.0"
kubectl delete namespace kourier-system
kubectl create namespace kourier-system
kubectl apply -f https://github.com/knative/net-kourier/releases/download/v$KOURIER/kourier.yaml
kubectl wait -n kourier-system deploy 3scale-kourier-gateway --for condition=Available --timeout=90s

kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'
echo "Kourier installed and patched..."
sleep 5

KOURIER_IP=$(kubectl get service kourier -n kourier-system | awk 'FNR == 2 {print $4}' )
export KOURIER_IP
kubectl patch configmap -n knative-serving config-domain -p "{\"data\": {\"$KOURIER_IP.nip.io\": \"\"}}"

## Hello World
kubectl create namespace ns-kn-hello-world
kn service create hello --image gcr.io/knative-samples/helloworld-go --namespace ns-kn-hello-world

kubectl run busybox -i --tty --image=busybox --restart=Never -- sh

# kn service delete hello --namespace  ns-kn-hello-world

else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi

# End of Script
