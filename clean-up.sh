#!/bin/bash

clear

printf "%s\n" "Starting clean up on Digital Ocean...."

# Kubernetes

doctl kubernetes cluster delete digital-ocean-cluster -f

printf "%s\n" "digital-ocean-cluster deleted"

# Virtual Machine

doctl compute droplet delete digital-ocean-droplet -f

printf "%s\n" "digital-ocean-droplet deleted"

# Volumes

doctl compute volume list | awk 'FNR == 2 {print $1}' | xargs doctl compute volume delete -f

printf "%s\n" "digital-ocean-droplet volume deleted"

# Load Balancers

doctl compute load-balancer list | awk 'FNR == 2 {print $1}' | xargs doctl compute load-balancer delete -f

doctl compute load-balancer list | awk 'FNR == 2 {print $1}' | xargs doctl compute load-balancer delete -f

doctl compute load-balancer list | awk 'FNR == 2 {print $1}' | xargs doctl compute load-balancer delete -f

doctl compute load-balancer list | awk 'FNR == 2 {print $1}' | xargs doctl compute load-balancer delete -f

printf "%s\n" "digital-ocean-loadbalancers deleted"

printf "%s\n" "Done with clean up on Digital Ocean...."