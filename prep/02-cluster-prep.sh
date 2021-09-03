################################################################################
# Author: James Buckett
# email: james.buckett@gmail.com
# Script to install various components onto the cluster
################################################################################

#!/bin/bash

################################################################################
# Check that you are on jump host and not local host
################################################################################
if [ "$HOSTNAME" = "digital-ocean-droplet" ]; then


################################################################################
# doctl - DigitalOcean command-line client authorize access to the Kubernetes Cluster
################################################################################
doctl auth init --access-token "xxx"
doctl kubernetes cluster kubeconfig save digital-ocean-cluster

kubectl config use-context do-sgp1-digital-ocean-cluster

################################################################################
# Clear any previous installations
################################################################################

rm /root/prep/02-cluster-prep.sh

kubectl delete ns ns-metrics-server
kubectl delete ns ns-microservices-demo
kubectl delete ns projectcontour

helm repo remove grafana
helm uninstall loki-release
kubectl delete ns ns-loki

helm repo remove chaos-mesh 
helm uninstall chaos-mesh-release
kubectl delete ns ns-chaos-mesh

helm repo remove kubernetes-graphql  
helm uninstall kubernetes-graphql-release
kubectl delete ns ns-graphql 

helm repo remove fairwinds-stable
helm uninstall vpa-release
kubectl delete ns ns-vpa
kubectl delete ns ns-goldilocks

kubectl delete ns ns-argo

helm dependencies update

clear

################################################################################
# Stop the script on errors
################################################################################
set -euo pipefail
set -o nounset
set -o errexit

################################################################################
# metrics server - container resource metrics
################################################################################

clear
echo "Installing metrics-server..."
# watch -n 1 kubectl get all -n ns-metrics-server
sleep 5

# kubectl create ns ns-metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl wait -n kube-system deploy metrics-server --for condition=Available --timeout=90s

clear
echo "Installed metrics-server..."
sleep 5


################################################################################
# Contour - Ingress
################################################################################

# Knative with Contour Ingress
# kubectl apply -f https://github.com/knative/net-contour/releases/download/v0.24.0/contour.yaml
# kubectl apply -f https://github.com/knative/net-contour/releases/download/v0.24.0/net-contour.yaml
# kubectl patch configmap/config-network \
#   --namespace knative-serving \
#   --type merge \
#  --patch '{"data":{"ingress.class":"contour.ingress.networking.knative.dev"}}'

# Regular Contour 
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml


################################################################################
# Octant Load Balancer - octant.jamesbuckett.com
################################################################################
doctl compute load-balancer create \
    --name digitalocean-loadbalancer \
    --region sgp1 \
    --tag-name digital-ocean-droplet \
    --forwarding-rules entry_protocol:http,entry_port:80,target_protocol:http,target_port:8900


################################################################################
# Online Boutique - Sample Microservices Application
################################################################################

clear
echo "Installing Micro-services Demo..."
# watch -n 1 kubectl get all -n  ns-microservices-demo
sleep 5

kubectl create ns ns-demo
kubectl apply -n ns-demo -f "https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/prep/complete-demo.yaml"
kubectl apply -n ns-demo -f "https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/prep/hpa-demo.yaml"
kubectl wait -n ns-demo deploy frontend --for condition=Available --timeout=90s

# Microservices Ingress
kubectl apply -f "https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/ingress/ingress-demo.yml"

clear
echo "Installed metrics-server..."
echo "Installed Micro-services Demo..."
sleep 5

################################################################################
# Loki -  Distributed Log Aggregation
################################################################################

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

clear
echo "Installing Loki/Prometheus/Grafana..."
# watch -n 1 kubectl get all -n   ns-loki
sleep 5

# helm upgrade \
# --install loki grafana/loki-stack  
# --set grafana.enabled=true,prometheus.enabled=true,prometheus.alertmanager.persistentVolume.enabled=false,prometheus.server.persistentVolume.enabled=false,loki.persistence.enabled=true,loki.persistence.storageClassName=standard,loki.persistence.size=5Gi

helm upgrade \
--install loki-release grafana/loki-stack -f  "https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/values/loki-values.yml" \
--namespace=ns-loki \
--create-namespace \
--wait

# Loki Ingress
kubectl apply -f "https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/ingress/ingress-loki.yml"

clear
echo "Installed metrics-server..."
echo "Installed Micro-services Demo..."
echo "Installed Loki/Prometheus/Grafana..."
sleep 5

################################################################################
# Chaos Mesh - Chaos Engineering Platfom
# Link: https://pingcap.com/blog/Chaos-Mesh-1.0-Chaos-Engineering-on-Kubernetes-Made-Easier
################################################################################

helm repo add chaos-mesh https://charts.chaos-mesh.org

clear
echo "Installing Chaos Mesh..."
# watch -n 1 kubectl get all -n  ns-chaos
sleep 5

helm upgrade \
--install chaos-mesh-release chaos-mesh/chaos-mesh \
--set dashboard.create=true \
--set dashboard.securityMode=false \
--set chaosDaemon.hostNetwork=true \
--namespace=ns-chaos \
--create-namespace \
--wait

# # Chaos Mesh Ingress
kubectl apply -f "https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/ingress/ingress-chaos.yml"

clear
echo "Installed metrics-server..."
echo "Installed Micro-services Demo..."
echo "Installed Loki/Prometheus/Grafana..."
echo "Installed Chaos Mesh..."
sleep 5


################################################################################
# Vertical Pod Autoscaler and Goldilocks - Vertical Pod Autoscaler recommendations
# Link: https://learnk8s.io/setting-cpu-memory-limits-requests
################################################################################

helm repo add fairwinds-stable https://charts.fairwinds.com/stable
helm repo update

clear
echo "Installing Vertical Pod Autoscaler..."
# watch -n 1 kubectl get all -n  ns-vpa
sleep 5

helm upgrade \
--install vpa-release fairwinds-stable/vpa \
--namespace=ns-vpa \
--create-namespace \
--wait

clear
echo "Installing Vertical Pod Autoscaler UI..."
# watch -n 1 kubectl get all -n  ns-goldilocks
sleep 5

# Goldilocks scans pods for resource limits and creates reports with recommended resources.

helm upgrade \
--install goldilocks-release fairwinds-stable/goldilocks \
--set dashboard.service.type=ClusterIP \
--namespace=ns-goldilocks \
--create-namespace \
--wait

# VPA Ingress
kubectl apply -f "https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/ingress/ingress-vpa.yml"

# watch -n 1 kubectl get all -n  ns-goldilocks

kubectl label namespace default goldilocks.fairwinds.com/enabled=true
kubectl label namespace kube-node-lease goldilocks.fairwinds.com/enabled=true
kubectl label namespace kube-public goldilocks.fairwinds.com/enabled=true
kubectl label namespace kube-system goldilocks.fairwinds.com/enabled=true
kubectl label namespace ns-chaos goldilocks.fairwinds.com/enabled=true
kubectl label namespace ns-loki  goldilocks.fairwinds.com/enabled=true
kubectl label namespace ns-goldilocks goldilocks.fairwinds.com/enabled=true
kubectl label namespace ns-demo goldilocks.fairwinds.com/enabled=true
kubectl label namespace ns-vpa goldilocks.fairwinds.com/enabled=true

clear
echo "Installed metrics-server..."
echo "Installed Micro-services Demo..."
echo "Installed Loki/Prometheus/Grafana..."
echo "Installed Chaos Mesh..."
echo "Installed Vertical Pod Autoscaler..."
sleep 5


################################################################################
# Export the Public IP where Octant can be located
################################################################################
DROPLET_ADDR=$(doctl compute droplet list | awk 'FNR == 2 {print $3}')
export DROPLET_ADDR


################################################################################
# Update .bashrc
################################################################################
cd ~
# echo "source <(kubectl completion bash)" >>~/.bashrc
echo "alias cls='clear'" >> ~/.bashrc
echo "alias k='kubectl'" >> ~/.bashrc
echo "alias kga='kubectl get all'" >> ~/.bashrc
echo "KUBE_PS1_SYMBOL_ENABLE=false" >>~/.bashrc
echo "source /opt/kube-ps1/kube-ps1.sh" >>~/.bashrc
echo "export DROPLET_ADDR=$DROPLET_ADDR" >> ~/.bashrc
echo "export OCTANT_ACCEPTED_HOSTS=$DROPLET_ADDR" >> ~/.bashrc
echo "export OCTANT_DISABLE_OPEN_BROWSER=1" >> ~/.bashrc
echo "export OCTANT_LISTENER_ADDR=0.0.0.0:8900" >> ~/.bashrc
clear

clear
echo "Installed metrics-server..."
echo "Installed Micro-services Demo..."
echo "Installed Loki/Prometheus/Grafana..."
echo "Installed Chaos Mesh..."
echo "Installed Vertical Pod Autoscaler..."
echo " "
echo "02-cluster-prep.sh complete...rebooting"
sleep 5s

################################################################################
# Reboot Jump Host
################################################################################
sudo reboot

else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi

# End of Script