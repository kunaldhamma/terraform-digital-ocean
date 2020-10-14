# Author:  James Buckett
# eMail: james.buckett@gmail.com
# Script to setup post-install tasks

#!/bin/bash

# Wait for the Load Balancers to  provision
sleep 4m

# Online Boutique - Export the Public IP address of Online Boutique 
BOUTIQUE_LB=$(doctl compute load-balancer list | awk 'FNR == 2 {print $2}')
export BOUTIQUE_LB

# Goldilocks - Export the Public IP address of Golidilocks 
GOLDILOCKS_LB=$(doctl compute load-balancer list | awk 'FNR == 3 {print $2}')
export GOLDILOCKS_LB

# Loki - Export the Public IP address of Loki and display the password to login
LOKI_LB=$(doctl compute load-balancer list | awk 'FNR == 4 {print $2}')
export LOKI_LB
LOKI_PWD=$(kubectl get secret --namespace ns-loki loki-release-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo)
export LOKI_PWD

# Chaos Mesh - Export the Public IP address of Chaos Mesh
CHAOSMESH_LB=$(doctl compute load-balancer list | awk 'FNR == 5 {print $2}')
export CHAOSMESH_LB
# Scale deployment.apps/frontend to 3 replicas for Chaos Experiments 
kubectl scale deployment.apps/frontend --replicas=3 -n ns-microservices-demo

# Update .bashrc
cd ~
echo "export BOUTIQUE_LB=$BOUTIQUE_LB" >> ~/.bashrc
echo "export GOLDILOCKS_LB=$GOLDILOCKS_LB" >> ~/.bashrc
echo "export LOKI_LB=$LOKI_LB" >> ~/.bashrc
echo "export CHAOSMESH_LB=$CHAOSMESH_LB" >> ~/.bashrc

# Update Message of the Day
echo "Reference URLs in this tutorial" >> /etc/motd
echo "**********************************************************************************************" >> /etc/motd
echo "* Sample Microservices Application - Online Boutique is here: $BOUTIQUE_LB " >> /etc/motd
echo "* Real-time Kubernetes Dashboard - Octant is here:  $DROPLET_ADDR:8900 " >> /etc/motd
echo "* Vertical Pod Autoscaler recommendations - Goldilocks is here: $GOLDILOCKS_LB " >> /etc/motd
echo "* Distributed Log Aggregation - Loki is here: $LOKI_LB  " >> /etc/motd
echo "* Loki User:  admin   Loki Password: $LOKI_PWD"
echo "* Chaos Engineering Platfom - Chaos Mesh  is here: $CHAOSMESH_LB:2333  " >> /etc/motd
echo "* Load Testing Tool - Locust is here: $DROPLET_ADDR:8089 " >> /etc/motd
echo "* Locust values are Spawn:500 & URL: $BOUTIQUE_LB " >> /etc/motd                      
echo "* Start Locust & Octant in another shell : sh /root/locust/startup-locust.sh " >> /etc/motd      
#echo "* Add this to .bashrc manually 'PS1='[\u@\h \w $(kube_ps1)]\$ '                             *" >> /etc/motd
echo "**********************************************************************************************" >> /etc/motd

# Locust - Setup Locust
cd ~/ && rm -R ~/locust
cd ~/ && mkdir locust && cd locust
wget https://raw.githubusercontent.com/jamesbuckett/microservices-metrics-chaos/master/locustfile.py
wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/startup-locust.sh
chmod +x startup-locust.sh

# Locust Service - Not Working
# cd /etc/systemd/system
# wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/locust.service
# chmod 755 locust.service
# systemctl enable locust.service

# Octant Service - Not working
#cd /etc/systemd/system
#wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/octant.service
#chmod 755 octant.service
#echo Environment="OCTANT_ACCEPTED_HOSTS=$DROPLET_ADDR" >> octant.service
#systemctl enable octant.service

reboot

#End of Script