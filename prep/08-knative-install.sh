################################################################################
# Author: James Buckett
# email: james.buckett@gmail.com
# Script to install Knative
# Create your first Knative app
# Link : https://opensource.com/article/20/11/knative
# Link : https://knative.dev/docs/admin/install/serving/install-serving-with-yaml/
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

# Contour Installation
kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress.class":"contour.ingress.networking.knative.dev"}}'
echo "Contour and patched..."
sleep 5

doctl compute domain records create jamesbuckett.com --record-type CNAME --record-name *.knative --record-data www. --record-ttl=43200

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
