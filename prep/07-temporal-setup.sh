################################################################################
# Author: James Buckett
# email: james.buckett@gmail.com
# Script to install Temporal
################################################################################

# To install from digital-ocean-droplet
# wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/prep/07-temporal-setup.sh
# chmod +x 07-temporal-setup.sh
# ./07-temporal-setup.sh

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
echo "Installing Temporal..."
# watch -n 1 kubectl get all -n  ns-temporal
sleep 5

mkdir temporal

cd temporal

git clone https://github.com/temporalio/helm-charts.git

helm repo update

helm dependencies update

helm install \
    --set server.replicaCount=1 \
    --set cassandra.config.cluster_size=1 \
    --set prometheus.enabled=false \
    --set grafana.enabled=false \
    --set elasticsearch.enabled=false \
    --set kafka.enabled=false \
    --namespace=ns-temporal \
    --create-namespace \
    temporaltest . --timeout 15m

    clear
echo "Installed Temporal..."
sleep 5

else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi

# End of Script