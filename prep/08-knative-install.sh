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
set -o nounset
set -o errexit

clear
echo "Installing Knative..."
sleep 5

################################################################################
# Knative - Event Driven
################################################################################

# Check version here: https://github.com/knative/serving/releases

kubectl apply -f https://github.com/knative/serving/releases/download/v0.26.0/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/v0.26.0/serving-core.yaml

kubectl apply -f https://github.com/knative/net-kourier/releases/download/v0.26.0/kourier.yaml

kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'

################################################################################
# Knative Ingress Loadbalancer
################################################################################

# This did not work suspect the Load Balancer was not ready yet, try putting in a sleep

sleep 120

KNATIVE_LB=$(kubectl describe service kourier -n kourier-system | awk '/Ingress:/{print $3 }')
export KNATIVE_LB

doctl compute domain records create --record-type A --record-name *.knative --record-data $KNATIVE_LB jamesbuckett.com --record-ttl=43200

kubectl patch configmap/config-domain   --namespace knative-serving   --type merge   --patch '{"data":{"knative.jamesbuckett.com":""}}'  

else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi

# End of Script
