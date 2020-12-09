# Author:  James Buckett
# email: james.buckett@gmail.com
# Script to delete all Digital Ocean assests 

#!/bin/bash

clear

printf "%s\n" "Listing current Digital Ocean Artifacts..."
echo " "

printf "%s\n" "Digital Ocean Kubernetes Clusters"
doctl kubernetes cluster list
echo " "

printf "%s\n" "Digital Ocean Load Balancers"
doctl compute load-balancer list
echo " "

printf "%s\n" "Digital Ocean Volumes"
doctl compute volume list
echo " "

printf "%s\n" "Digital Ocean Droplets"
doctl compute droplet list
echo " "

sleep 5

# Check that you are on jump host and not local host
if [ "$HOSTNAME" = "digital-ocean-droplet" ]; then

clear
printf "%s\n" "Starting clean up on Digital Ocean...."
echo " "
sleep 5s

# Kubernetes
doctl kubernetes cluster delete digital-ocean-cluster -f
printf "%s\n" "digital-ocean-cluster deleted"
echo " "

# Load Balancers

# Online Boutique
doctl compute load-balancer list | awk 'FNR == 2 {print $1}' | xargs doctl compute load-balancer delete -f

# Loki 
doctl compute load-balancer list | awk 'FNR == 2 {print $1}' | xargs doctl compute load-balancer delete -f

# Chaos Mesh
doctl compute load-balancer list | awk 'FNR == 2 {print $1}' | xargs doctl compute load-balancer delete -f

# Goldilocks
doctl compute load-balancer list | awk 'FNR == 2 {print $1}' | xargs doctl compute load-balancer delete -f

printf "%s\n" "digital-ocean-loadbalancers deleted"
echo " "

# Volumes
doctl compute volume list | awk 'FNR == 2 {print $1}' | xargs doctl compute volume delete -f
doctl compute volume list | awk 'FNR == 2 {print $1}' | xargs doctl compute volume delete -f
doctl compute volume list | awk 'FNR == 2 {print $1}' | xargs doctl compute volume delete -f
printf "%s\n" "digital-ocean-droplet volume deleted"
echo " "

# Virtual Machine
doctl compute droplet delete digital-ocean-droplet -f
printf "%s\n" "digital-ocean-droplet deleted"
echo " "

printf "%s\n" "Done with clean up on Digital Ocean...."
echo " "

else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi

#End of Script