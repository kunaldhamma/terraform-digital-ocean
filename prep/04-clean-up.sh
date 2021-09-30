################################################################################
# Author: James Buckett
# email: james.buckett@gmail.com
# Script to delete all Digital Ocean assests 
################################################################################

#!/bin/bash

clear

################################################################################
# List Artifacts
################################################################################

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

printf "%s\n" "Digital Ocean DNS Records"
doctl compute domain records list jamesbuckett.com
echo " " 

sleep 5

################################################################################
# Check that you are on jump host and not local host
################################################################################
if [ "$HOSTNAME" = "digital-ocean-droplet" ]; then

clear
printf "%s\n" "Starting clean up on Digital Ocean...."
echo " "
sleep 5s


################################################################################
# Kubernetes
################################################################################
doctl kubernetes cluster delete digital-ocean-cluster -f
printf "%s\n" "digital-ocean-cluster deleted"
echo " "


################################################################################
# Load Balancers
################################################################################
for i in {0..2}
do
   doctl compute load-balancer list | awk 'FNR == 2 {print $1}' | xargs doctl compute load-balancer delete -f
done

printf "%s\n" "digital-ocean-loadbalancers deleted"
echo " "


################################################################################
# Volumes
################################################################################
for i in {0..2}
do
doctl compute volume-action detach | awk 'FNR == 2 {print $1}' | xargs doctl compute volume delete -f
done

for i in {0..2}
do
   doctl compute volume list | awk 'FNR == 2 {print $1}' | xargs doctl compute volume delete -f
done

printf "%s\n" "digital-ocean-droplet volume deleted"
echo " "


################################################################################
# DNS Records 
################################################################################
for i in {0..5}
do
doctl compute domain records list jamesbuckett.com  | awk 'FNR == 6 {print $1}' | xargs doctl compute domain records delete jamesbuckett.com -f
done

# Demo Microservice
# Loki
# Chaos
# VPA
# Octant
# Knative


################################################################################
# Virtual Machine
################################################################################
doctl compute droplet delete digital-ocean-droplet -f
printf "%s\n" "digital-ocean-droplet deleted"
echo " "

printf "%s\n" "Done with clean up on Digital Ocean...."
echo " "

else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi

# End of Script