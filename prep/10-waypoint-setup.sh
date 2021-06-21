################################################################################
# Author: James Buckett
# email: james.buckett@gmail.com
# Script to install Hashicorp Waypoint
################################################################################

# tl;dr - As Terraform is to infrastructure, Waypoint is to applications

# To install from digital-ocean-droplet
# wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/prep/10-waypoint-setup.sh
# chmod +x 10-waypoint-setup.sh
# ./10-waypoint-setup.sh

#!/bin/bash

################################################################################
# Check that you are on jump host and not local host
################################################################################
if [ "$HOSTNAME" = "digital-ocean-droplet" ]; then

################################################################################
# Stop the script on errors
################################################################################
set -euo pipefail

clear
echo "Installing Hashicorp Waypoint..."
sleep 5

################################################################################
# Docker
################################################################################
clear
echo "Installing Docker for Hashicorp Waypoint..."
sudo apt update -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update -y
apt-cache policy docker-ce
sudo apt install docker-ce -y
sudo systemctl status docker
docker login --username=jamesbuckett 

################################################################################
# Hashicorp Waypoint
################################################################################
clear
echo "Installing Hashicorp Waypoint..."
cd ~/ && mkdir waypoint && cd waypoint

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install waypoint

git clone https://github.com/hashicorp/waypoint-examples.git
cd waypoint-examples/docker/nodejs

waypoint install --platform=kubernetes -accept-tos
waypoint init
waypoint up

else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi

# End of Script