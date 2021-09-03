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
kubectl apply -f https://github.com/knative/serving/releases/download/v0.25.0/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/v0.25.0/serving-core.yaml

kubectl apply -f https://github.com/knative/net-kourier/releases/download/v0.25.0/kourier.yaml

kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'

################################################################################
# Knative Ingress Loadbalancer
################################################################################

KNATIVE_LB=$(doctl compute load-balancer list | awk 'FNR == 4 {print $2}')
export KNATIVE_LB

doctl compute domain records create --record-type A --record-name *.knative --record-data $KNATIVE_LB jamesbuckett.com --record-ttl=43200

kubectl patch configmap/config-domain   --namespace knative-serving   --type merge   --patch '{"data":{"knative.jamesbuckett.com":""}}'  

## Hello Example

# Check clean slate
# kn service list

# Deploy first application passing environment variable=TARGET="First"
# kn service create hello-example --image gcr.io/knative-samples/helloworld-go --env TARGET="First" -n ns-knative

# Curl or Browser "First" deployment
# curl http://hello-example.knative.jamesbuckett.com
# Should be: "Hello First!"

# Update Service by passing a new environment variable=TARGET=Second
# kn service update hello-example --env TARGET=Second -n ns-knative

# Both revsions exist aka "First" and Second
# kn revision list

# Curl or Browser Second deployment
# curl http://hello-example.knative.jamesbuckett.com
# Should be: "Hello Second!" 

# Update to a Rust image 
# kn service update hello-example --image gcr.io/knative-samples/helloworld-rust

# Curl or Browser Rust deployment
# curl http://hello-example.knative.jamesbuckett.com
# Should be: "Hello world: Second"

# Split Service
# kn service update hello-example --traffic hello-example-00003=50 --traffic hello-example-00002=50

# Curl or Browser Both deployment
# curl http://hello-example.knative.jamesbuckett.com
# Should be: "Hello Second!" 50%
# Should be: "Hello world: Second" 50% 


else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi

# End of Script
