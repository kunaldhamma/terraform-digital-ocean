# Author:  James Buckett
# email: james.buckett@gmail.com
# Script to install various components onto the cluster

#!/bin/bash

# Check that you are on jump host and not local host
if [ "$HOSTNAME" = "digital-ocean-droplet" ]; then

# doctl - DigitalOcean command-line client authorize access to the Kubernetes Cluster
doctl auth init --access-token "xxx"
doctl kubernetes cluster kubeconfig save digital-ocean-cluster

kubectl config use-context do-sgp1-digital-ocean-cluster

# metrics server - container resource metrics
kubectl delete ns ns-metrics-server
clear
echo "Installing metrics-server..."
echo "watch -n 1 kubectl get all -n ns-metrics-server"
sleep 5

kubectl create ns ns-metrics-server
kubectl apply -f "https://raw.githubusercontent.com/jamesbuckett/kubernetes-tools/master/components.yaml"
kubectl wait -n ns-metrics-server deploy metrics-server --for condition=Available --timeout=90s

# Contour - Ingress
# helm uninstall contour-release
# helm upgrade --install contour-release stable/contour \
# --set service.loadBalancerType=LoadBalancer \
# --namespace=ns-contour \
# --create-namespace \
# --wait

# NGINX Ingress - Ingress 
# helm uninstall nginx-release
# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# helm repo update
# helm  upgrade install nginx-release ingress-nginx/ingress-nginx \
#--namespace=ns-nginx \
#--create-namespace \
#--wait

# Online Boutique - Sample Microservices Application
# First External Load Balancer
kubectl delete ns ns-microservices-demo
clear
echo "Installing Micro-services Demo..."
echo "watch -n 1 kubectl get all -n  ns-microservices-demo"
sleep 5

kubectl create ns ns-microservices-demo
kubectl apply -n ns-microservices-demo -f "https://raw.githubusercontent.com/jamesbuckett/microservices-metrics-chaos/master/complete-demo.yaml"
kubectl wait -n ns-microservices-demo deploy frontend --for condition=Available --timeout=90s

# Gremlin - Managed Chaos Engineering Platfom
# helm repo remove gremlin
# helm repo add gremlin https://helm.gremlin.com
# helm repo update

# Loki -  Distributed Log Aggregation
# Second External Load Balancer
helm repo remove loki
helm repo add loki https://grafana.github.io/loki/charts
helm repo update

helm uninstall loki-release
kubectl delete ns ns-loki

clear
echo "Installing Loki/Prometheus/Grafana..."
echo "watch -n 1 kubectl get all -n   ns-loki"
sleep 5

helm upgrade \
--install loki-release loki/loki-stack -f  "https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/values/loki-values.yml" \
--namespace=ns-loki \
--create-namespace \
--wait

# Chaos Mesh - Chaos Engineering Platfom
# Third External Load Balancer
#Link: https://pingcap.com/blog/Chaos-Mesh-1.0-Chaos-Engineering-on-Kubernetes-Made-Easier
helm repo remove chaos-mesh 
helm repo add chaos-mesh https://charts.chaos-mesh.org
helm repo update
curl -sSL https://mirrors.chaos-mesh.org/v1.0.0/crd.yaml | kubectl apply -f -

helm uninstall chaos-mesh-release
kubectl delete ns ns-chaos-mesh

clear
echo "Installing Chaos Mesh..."
echo "watch -n 1 kubectl get all -n  ns-chaos-mesh"
sleep 5

helm upgrade \
--install chaos-mesh-release chaos-mesh/chaos-mesh \
--set dashboard.create=true \
--set chaosDaemon.hostNetwork=true \
--namespace=ns-chaos-mesh \
--create-namespace \
--wait

# Set Chaos Mesh to external LoadBalancer
kubectl patch service/chaos-dashboard -p '{"spec":{"type":"LoadBalancer"}}' --namespace=ns-chaos-mesh
sleep 30s

# Chaos Ingress
# kubectl apply -f "https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/ingress/ingress-chaos.yml"

# GraphQL - Convert Kubernetes API server into GraphQL API
# https://github.com/onelittlenightmusic/kubernetes-graphql
helm repo remove kubernetes-graphql  
helm repo add kubernetes-graphql https://onelittlenightmusic.github.io/kubernetes-graphql/helm-chart
helm repo update

helm uninstall kubernetes-graphql-release
kubectl delete ns ns-graphql 

clear
echo "Installing GraphQL..."
echo "watch -n 1 kubectl get all -n  ns-graphql"
sleep 5

helm upgrade \
--install kubernetes-graphql-release kubernetes-graphql/kubernetes-graphql \
--set kubernetes-api-proxy.serviceAccount.create=true \
--set kubernetes-api-proxy.serviceAccount.clusterWide=true \
--set graphql-mesh.ingress.enabled=true \
--namespace=ns-graphql  \
--create-namespace 
# --wait

# Vertical Pod Autoscaler and Goldilocks - Vertical Pod Autoscaler recommendations
# Fourth External Load Balancer
# Link: https://learnk8s.io/setting-cpu-memory-limits-requests
helm repo remove fairwinds-stable
helm repo add fairwinds-stable https://charts.fairwinds.com/stable
helm repo update

helm uninstall vpa-release
kubectl delete ns ns-vpa
kubectl delete ns ns-goldilocks

clear
echo "Installing Vertical Pod Autoscaler..."
echo "watch -n 1 kubectl get all -n  ns-vpa"
sleep 5

helm upgrade \
--install vpa-release fairwinds-stable/vpa \
--namespace=ns-vpa \
--create-namespace 
# --wait

clear
echo "Installing Vertical Pod Autoscaler UI..."
echo "watch -n 1 kubectl get all -n  ns-goldilocks"
sleep 5

helm upgrade \
--install goldilocks-release fairwinds-stable/goldilocks \
--set dashboard.service.type=LoadBalancer \
--namespace=ns-goldilocks \
--create-namespace 
# --wait

# watch -n 1 kubectl get all -n  ns-goldilocks

kubectl label namespace default goldilocks.fairwinds.com/enabled=true
kubectl label namespace kube-node-lease goldilocks.fairwinds.com/enabled=true
kubectl label namespace kube-public goldilocks.fairwinds.com/enabled=true
kubectl label namespace kube-system goldilocks.fairwinds.com/enabled=true
kubectl label namespace ns-chaos-mesh goldilocks.fairwinds.com/enabled=true
kubectl label namespace ns-loki  goldilocks.fairwinds.com/enabled=true
kubectl label namespace ns-goldilocks goldilocks.fairwinds.com/enabled=true
kubectl label namespace ns-metrics-server goldilocks.fairwinds.com/enabled=true
kubectl label namespace ns-microservices-demo goldilocks.fairwinds.com/enabled=true
kubectl label namespace ns-vpa goldilocks.fairwinds.com/enabled=true
kubectl label namespace ns-graphql  goldilocks.fairwinds.com/enabled=true

# Export the Public IP where Octant can be located
DROPLET_ADDR=$(doctl compute droplet list | awk 'FNR == 2 {print $3}')
export DROPLET_ADDR

# Update .bashrc
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
echo " "
echo " "
echo "02-cluster-prep.sh complete...rebooting"
sleep 5s

# Reboot Jump Host
sudo reboot

else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi

#End of Script