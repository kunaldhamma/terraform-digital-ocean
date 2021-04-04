################################################################################
# Author: James Buckett
# email: james.buckett@gmail.com
# Script to install various components onto the cluster
################################################################################

#!/bin/bash

# Check that you are on jump host and not local host
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

################################################################################
# metrics server - container resource metrics
################################################################################

clear
echo "Installing metrics-server..."
echo "watch -n 1 kubectl get all -n ns-metrics-server"
sleep 5

# kubectl create ns ns-metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# kubectl apply -f "https://raw.githubusercontent.com/jamesbuckett/kubernetes-tools/master/components.yaml"
kubectl wait -n kube-system deploy metrics-server --for condition=Available --timeout=90s

pause
clear
echo "Installed metrics-server..."
sleep 5

################################################################################
# Contour - Ingress
################################################################################

kubectl apply -f https://projectcontour.io/quickstart/contour.yaml

# helm uninstall contour-release
# helm upgrade --install contour-release stable/contour \
# --set service.loadBalancerType=LoadBalancer \
# --namespace=ns-contour \
# --create-namespace \
# --wait

################################################################################
# Online Boutique - Sample Microservices Application
################################################################################

clear
echo "Installing Micro-services Demo..."
# watch -n 1 kubectl get all -n  ns-microservices-demo
sleep 5

kubectl create ns ns-microservices-demo
kubectl apply -n ns-microservices-demo -f "https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/prep/complete-demo.yaml"
kubectl wait -n ns-microservices-demo deploy frontend --for condition=Available --timeout=90s

# Microservices Ingress
kubectl apply -f "https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/ingress/ingress-demo.yml"

clear
echo "Installed metrics-server..."
echo "Installed Micro-services Demo..."
sleep 5

################################################################################
# Gremlin - Managed Chaos Engineering Platfom
# helm repo remove gremlin
# helm repo add gremlin https://helm.gremlin.com
# helm repo update
################################################################################

################################################################################
# Loki -  Distributed Log Aggregation
################################################################################

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

clear
echo "Installing Loki/Prometheus/Grafana..."
# watch -n 1 kubectl get all -n   ns-loki
sleep 5

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
helm repo update
curl -sSL https://mirrors.chaos-mesh.org/v1.0.0/crd.yaml | kubectl apply -f -

clear
echo "Installing Chaos Mesh..."
# watch -n 1 kubectl get all -n  ns-chaos-mesh
sleep 5

helm upgrade \
--install chaos-mesh-release chaos-mesh/chaos-mesh \
--set dashboard.create=true \
--set dashboard.securityMode=false \
--set chaosDaemon.hostNetwork=true \
--namespace=ns-chaos-mesh \
--create-namespace \
--wait

# Chaos Mesh Ingress
kubectl apply -f "https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/ingress/ingress-chaos.yml"
# kubectl patch service/chaos-dashboard -p '{"spec":{"type":"LoadBalancer"}}' --namespace=ns-chaos-mesh

clear
echo "Installed metrics-server..."
echo "Installed Micro-services Demo..."
echo "Installed Loki/Prometheus/Grafana..."
echo "Installed Chaos Mesh..."
sleep 5

################################################################################
# GraphQL - Convert Kubernetes API server into GraphQL API
# https://github.com/onelittlenightmusic/kubernetes-graphql
# helm repo add kubernetes-graphql https://onelittlenightmusic.github.io/kubernetes-graphql/helm-chart
# helm repo update

# clear
# echo "Installing GraphQL..."
# echo "watch -n 1 kubectl get all -n  ns-graphql"
# sleep 5

# helm upgrade \
# --install kubernetes-graphql-release kubernetes-graphql/kubernetes-graphql \
# --set kubernetes-api-proxy.serviceAccount.create=true \
# --set kubernetes-api-proxy.serviceAccount.clusterWide=true \
# --set graphql-mesh.ingress.enabled=true \
# --namespace=ns-graphql  \
# --create-namespace 
# # --wait

# clear
# echo "Installed metrics-server..."
# echo "Installed Micro-services Demo..."
# echo "Installed Loki/Prometheus/Grafana..."
# echo "Installed Chaos Mesh..."
# echo "Installed GraphQL..."
# sleep 5
################################################################################

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
echo "watch -n 1 kubectl get all -n  ns-goldilocks"
sleep 5


helm install goldilocks fairwinds-stable/goldilocks --namespace goldilocks

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
kubectl label namespace ns-chaos-mesh goldilocks.fairwinds.com/enabled=true
kubectl label namespace ns-loki  goldilocks.fairwinds.com/enabled=true
kubectl label namespace ns-goldilocks goldilocks.fairwinds.com/enabled=true
kubectl label namespace ns-microservices-demo goldilocks.fairwinds.com/enabled=true
kubectl label namespace ns-vpa goldilocks.fairwinds.com/enabled=true
# kubectl label namespace ns-graphql  goldilocks.fairwinds.com/enabled=true
# kubectl label namespace ns-metrics-server goldilocks.fairwinds.com/enabled=true

pause
clear
echo "Installed metrics-server..."
echo "Installed Micro-services Demo..."
echo "Installed Loki/Prometheus/Grafana..."
echo "Installed Chaos Mesh..."
# echo "Installed GraphQL..."
echo "Installed Vertical Pod Autoscaler..."
sleep 5

################################################################################
# Export the Public IP where Octant can be located
################################################################################
DROPLET_ADDR=$(doctl compute droplet list | awk 'FNR == 2 {print $3}')
export DROPLET_ADDR

################################################################################
# Argo - Cloud Native Workflow
################################################################################
# kubectl create ns ns-argo
# kubectl apply -n ns-argo -f https://raw.githubusercontent.com/argoproj/argo-workflows/stable/manifests/quick-start-postgres.yaml
# kubectl wait -n ns-argo deploy argo-server --for condition=Available --timeout=90s

# kubectl patch svc argo-server -n ns-argo -p '{"spec": {"type": "LoadBalancer"}}'
# ports:
#     - name: https # Use http or https
#        protocol: TCP
#        port: 8080
#        targetPort: 8080

# Argo Ingress
# kubectl apply -f "https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/ingress/ingress-argo.yml"

# pause
# clear
# echo "Installed metrics-server..."
# echo "Installed Micro-services Demo..."
# echo "Installed Loki/Prometheus/Grafana..."
# echo "Installed Chaos Mesh..."
# echo "Installed GraphQL..."
# echo "Installed Vertical Pod Autoscaler..."
# echo "Installed Argo..."
# sleep 5

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
# echo "Installed GraphQL..."
echo "Installed Vertical Pod Autoscaler..."
# echo "Installed Argo..."
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