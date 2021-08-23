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

# Contour Integration

kubectl --namespace contour-external get service envoy

doctl compute domain records create jamesbuckett.com --record-type CNAME --record-name *.knative --record-data www. --record-ttl=43200

kubectl patch configmap/config-domain   --namespace knative-serving   --type merge   --patch '{"data":{"knative.jamesbuckett.com":""}}'

## Hello World

# kn service create hello-example --image gcr.io/knative-samples/helloworld-go --env TARGET="First" -n ns-knative

# kn service update hello-example --env TARGET=Second -n ns-knative

# kn revision list

# kn revision describe 

# kn service update hello-example --image gcr.io/knative-samples/helloworld-rust

# Split Service
# kn service update hello-example --traffic hello-example-bqbbr-2=50 --traffic hello-example-nfwgx-3=50


else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi

# End of Script
