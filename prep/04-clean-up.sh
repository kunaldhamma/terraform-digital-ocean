# Author:  James Buckett
# email: james.buckett@gmail.com
# Script to delete all Digital Ocean assests 

#!/bin/bash

clear

printf "%s\n" "Starting clean up on Digital Ocean...."
sleep 5s
# Kubernetes

doctl kubernetes cluster delete digital-ocean-cluster -f

printf "%s\n" "digital-ocean-cluster deleted"

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

# Virtual Machine

# Volumes

doctl compute volume list | awk 'FNR == 2 {print $1}' | xargs doctl compute volume delete -f

printf "%s\n" "digital-ocean-droplet volume deleted"

doctl compute droplet delete digital-ocean-droplet -f

printf "%s\n" "digital-ocean-droplet deleted"

printf "%s\n" "Done with clean up on Digital Ocean...."