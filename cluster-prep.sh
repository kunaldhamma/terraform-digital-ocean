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
. ~/.bashrc

/etc/motd

echo "Reference commands to the various URLs in this tutorial" >> /etc/motd
echo "****************************************************" >> /etc/motd
echo "* Online Boutique is here: echo $BOUTIQUE_LB       *" >> /etc/motd
echo "* Octant is here: echo $DROPLET_ADDR:8900          *" >> /etc/motd
echo "* Grafana is here: echo $GRAFANA_LB                *" >> /etc/motd
echo "* Locust is here: echo $DROPLET_ADDR:8089          *" >> /etc/motd
echo "****************************************************"  >> /etc/motd

printf "%s\n" "Add this to .bashrc manually 'PS1='[\u@\h \w $(kube_ps1)]\$ '"

# Start Locust

#FRONTEND_ADDR=$(kubectl -n ns-contour get service contour-release | awk 'FNR == 2 {print $4}')
#export $FRONTEND_ADDR
#~/locust/locust --host="http://${FRONTEND_ADDR}" -u "${USERS:-10}" &
# echo "Locust is here: "
# doctl compute droplet list | awk 'FNR == 2 {print $3}'
# echo "Port 8089"

# Start Octant 

# DROPLET_ADDR=$(doctl compute droplet list | awk 'FNR == 2 {print $3}')
# export $DROPLET_ADDR
octant & 

#echo "PS1='[\u@\h \w $(kube_ps1)]\$ '" >>~/.bashrc

#End of Script