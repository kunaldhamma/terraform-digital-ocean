#!/bin/bash

# doctl
doctl auth init --access-token "xxx"
doctl kubernetes cluster kubeconfig save digital-ocean-cluster

kubectl config use-context do-sgp1-digital-ocean-cluster

# metrics server
kubectl create namespace ns-metrics-server
kubectl apply -f "https://raw.githubusercontent.com/jamesbuckett/kubernetes-tools/master/components.yaml"

# Contour
# kubectl create namespace ns-contour
# helm upgrade --install contour-release stable/contour --namespace ns-contour --set service.loadBalancerType=LoadBalancer

# Loki
# kubectl create ns ns-loki
# helm repo remove loki
# helm repo add loki https://grafana.github.io/loki/charts
# helm repo update
# helm upgrade --install loki-release loki/loki-stack -f  "https://raw.githubusercontent.com/jamesbuckett/microservices-metrics-docker-desktop/master/values.yaml" -n ns-loki

# Online Boutique
kubectl create namespace ns-microservices-demo
kubectl apply -n ns-microservices-demo -f "https://raw.githubusercontent.com/jamesbuckett/microservices-metrics-chaos/master/complete-demo.yaml"

# Locust
cd ~/ && rm -R ~/locust
cd ~/ && mkdir locust && cd locust
wget https://raw.githubusercontent.com/jamesbuckett/microservices-metrics-chaos/master/locustfile.py

# Gremlin
helm repo remove gremlin
helm repo add gremlin https://helm.gremlin.com

# Octant
DROPLET_ADDR=$(doctl compute droplet list | awk 'FNR == 2 {print $3}')
export DROPLET_ADDR

# VPA and Goldilocks
helm repo remove fairwinds-stable
helm repo add fairwinds-stable https://charts.fairwinds.com/stable
helm install vpa-release fairwinds-stable/vpa --namespace ns-vpa --create-namespace
helm install goldilocks-release --namespace ns-goldilocks fairwinds-stable/goldilocks --set dashboard.service.type=LoadBalancer --create-namespace
kubectl label namespace ns-microservices-demo goldilocks.fairwinds.com/enabled=true

# Update .bashrc
cd ~
# echo "source <(kubectl completion bash)" >>~/.bashrc
echo "alias cls='clear'" >> ~/.bashrc
echo "alias k='kubectl'" >> ~/.bashrc
echo "alias kga='kubectl get all'" >> ~/.bashrc
echo "KUBE_PS1_SYMBOL_ENABLE=false" >>~/.bashrc
echo "source /opt/kube-ps1/kube-ps1.sh" >>~/.bashrc
# echo "export BOUTIQUE_LB=$BOUTIQUE_LB" >> ~/.bashrc
echo "export DROPLET_ADDR=$DROPLET_ADDR" >> ~/.bashrc
echo "export OCTANT_ACCEPTED_HOSTS=$DROPLET_ADDR" >> ~/.bashrc
echo "export OCTANT_DISABLE_OPEN_BROWSER=1" >> ~/.bashrc
echo "export OCTANT_LISTENER_ADDR=0.0.0.0:8900" >> ~/.bashrc

reboot

#End of Script