################################################################################
# Author: James Buckett
# email: james.buckett@gmail.com
# Script to setup post-install tasks
################################################################################

#!/bin/bash

################################################################################
# Check that you are on jump host and not local host
################################################################################
if [ "$HOSTNAME" = "digital-ocean-droplet" ]; then


################################################################################
# Clear any previous installations
################################################################################
cd ~/ && rm -R ~/locust
clear


################################################################################
# Stop the script on errors
################################################################################
set -euo pipefail


################################################################################
# Wait for the Load Balancers to  provision
################################################################################
echo "Sleeping for two minutes to let Load Balancers settle..."
sleep 2m

################################################################################
# Contour Ingress - Export the Public IP address of Contour Ingress 
################################################################################

# The host names, like "demo.jamesbuckett.com" are CNAME records 
# to the "do.jamesbuckett.com" A record  

INGRESS_LB=$(doctl compute load-balancer list | awk 'FNR == 2 {print $2}')
export INGRESS_LB

doctl compute domain records create --record-type A --record-name www --record-data $INGRESS_LB jamesbuckett.com --record-ttl=43200

doctl compute domain records create jamesbuckett.com --record-type CNAME --record-name demo --record-data www. --record-ttl=43200
doctl compute domain records create jamesbuckett.com --record-type CNAME --record-name loki --record-data www. --record-ttl=43200
doctl compute domain records create jamesbuckett.com --record-type CNAME --record-name vpa --record-data www. --record-ttl=43200
doctl compute domain records create jamesbuckett.com --record-type CNAME --record-name chaos --record-data www. --record-ttl=43200
doctl compute domain records create jamesbuckett.com --record-type CNAME --record-name argo --record-data www. --record-ttl=43200


################################################################################
# Online Boutique - Export the Public IP address of Online Boutique 
################################################################################
# BOUTIQUE_LB=$(doctl compute load-balancer list | awk 'FNR == 2 {print $2}')
# export BOUTIQUE_LB


################################################################################
# Loki - Export the Public IP address of Loki and display the password to login
################################################################################
# LOKI_LB=$(doctl compute load-balancer list | awk 'FNR == 3 {print $2}')
# export LOKI_LB
LOKI_PWD=$(kubectl get secret --namespace ns-loki loki-release-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo)
export LOKI_PWD


################################################################################
# Chaos Mesh - Export the Public IP address of Chaos Mesh
################################################################################
# CHAOSMESH_LB=$(doctl compute load-balancer list | awk 'FNR == 4 {print $2}')
# export CHAOSMESH_LB
# Scale deployment.apps/frontend to 3 replicas for Chaos Experiments 
kubectl scale deployment.apps/frontend --replicas=3 -n ns-microservices-demo


################################################################################
# Goldilocks - Export the Public IP address of Golidilocks 
################################################################################
# GOLDILOCKS_LB=$(doctl compute load-balancer list | awk 'FNR == 5 {print $2}')
# export GOLDILOCKS_LB


################################################################################
# Argo - Export the Public IP address of Argo
################################################################################
# ARGO_LB=$(doctl compute load-balancer list | awk 'FNR == 6 {print $2}')
# export ARGO_LB


################################################################################
# Update .bashrc
################################################################################
cd ~
cp .bashrc .bashrc-original
# echo "export BOUTIQUE_LB=$BOUTIQUE_LB" >> ~/.bashrc
# echo "export GOLDILOCKS_LB=$GOLDILOCKS_LB" >> ~/.bashrc
# echo "export LOKI_LB=$LOKI_LB" >> ~/.bashrc
# echo "export LOKI_PWD=$LOKI_PWD" >> ~/.bashrc
# echo "export CHAOSMESH_LB=$CHAOSMESH_LB" >> ~/.bashrc


################################################################################
# Update Message of the Day
################################################################################
echo "Reference URLs in this tutorial" >> /etc/motd
echo "**********************************************************************************************" >> /etc/motd
echo "* Real-time Kubernetes Dashboard - Octant is here: $DROPLET_ADDR:8900 " >> /etc/motd
echo "* Sample Microservices Application - Online Boutique is here: demo.jamesbuckett.com " >> /etc/motd
echo "* Chaos Engineering Platfom - Chaos Mesh is here: chaos.jamesbuckett.com " >> /etc/motd
echo "* Vertical Pod Autoscaler recommendations - Goldilocks is here: vpa.jamesbuckett.com " >> /etc/motd
echo "* Workflow Tool - Argo is here: argo.jamesbuckett.com " >> /etc/motd
echo "* Distributed Log Aggregation - Loki is here: loki.jamesbuckett.com " >> /etc/motd
echo "* Loki User:  admin   Loki Password: $LOKI_PWD" >> /etc/motd
echo "* Load Testing Tool - Locust is here: $DROPLET_ADDR:8089 " >> /etc/motd
echo "* Locust values are Spawn:500 & URL: $BOUTIQUE_LB " >> /etc/motd                      
echo "* To start Locust & Octant, open another shell and execute: sh /root/locust/startup-locust.sh " >> /etc/motd      
#echo "* Add this to .bashrc manually PS1='[\u@\h \w $(kube_ps1)]\$ '                             *" >> /etc/motd
echo "**********************************************************************************************" >> /etc/motd


################################################################################
# Locust - Setup Locust
################################################################################
cd ~/ && mkdir locust && cd locust
wget https://raw.githubusercontent.com/jamesbuckett/microservices-metrics-chaos/master/locustfile.py
wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/service/startup-locust.sh
chmod +x startup-locust.sh


################################################################################
# Under Development
################################################################################
# Locust Service - Not Working
# cd /etc/systemd/system
# wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/service/locust.service
# chmod 755 locust.service
# systemctl enable locust.service

# Octant Service - Not working
#cd /etc/systemd/system
#wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/service/octant.service
#chmod 755 octant.service
#echo Environment="OCTANT_ACCEPTED_HOSTS=$DROPLET_ADDR" >> octant.service
#systemctl enable octant.service

# Docker (required by Waypoint)
# sudo apt update -y
# sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
# sudo apt update -y
# apt-cache policy docker-ce
# sudo apt install docker-ce -y
# sudo systemctl status docker
# docker login --username=jamesbuckett 

# Hashicorp Waypoint
# clear
# echo "Installing Waypoint..."
# cd ~/ && mkdir waypoint && cd waypoint

# curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
# sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
# sudo apt-get update && sudo apt-get install waypoint

# git clone https://github.com/hashicorp/waypoint-examples.git
# cd waypoint-examples/docker/nodejs

# waypoint install --platform=kubernetes -accept-tos
# waypoint init
#waypoint up


################################################################################
# Clear terminal history
################################################################################
history -c

clear
echo " "
echo " "
echo "03-post-install-prep.sh complete...rebooting"
sleep 5s

# Reboot Jump Host
sudo reboot

else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi

# End of Script