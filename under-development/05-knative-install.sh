# Author:  James Buckett
# eMail: james.buckett@gmail.com
# Script to install Knative

# Create your first Knative app
# Link : https://opensource.com/article/20/11/knative

#!/bin/bash

# Check that you are on jump host and not local host
if [ "$HOSTNAME" = "digital-ocean-droplet" ]; then

# Knative CLI install
clear
echo "Installing Knative CLI..."
cd ~/ && rm -R ~/knative
cd ~/ && mkdir knative && cd knative
git clone https://github.com/knative/client.git
cd knative/client/hack
./build.sh -f
sudo cp kn /usr/local/bin
echo "kn version"
sleep 5

# Knative Installation
echo "Installing Knative Serving..."
export KNATIVE="0.17.2"
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
export KOURIER="0.17.0"
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

kubectl get service kourier -n kourier-system

else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi