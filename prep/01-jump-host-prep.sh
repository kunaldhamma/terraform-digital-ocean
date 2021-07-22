################################################################################
# Author: James Buckett
# email: james.buckett@gmail.com
# Script to install various components onto the jumphost
################################################################################

#!/bin/bash

################################################################################
# Check that you are on jump host and not local host
################################################################################
if [ "$HOSTNAME" = "digital-ocean-droplet" ]; then

################################################################################
# Clear any previous installations
################################################################################
cd ~/ && rm -R ~/doctl
cd ~/ && rm -R ~/kubectl
cd ~/ && rm -R ~/helm-3
cd ~/ && rm -R ~/octant
rm -R /opt/kubectx
rm /usr/local/bin/kubectx
rm /usr/local/bin/kubens

################################################################################
# Stop the script on errors
################################################################################
set -euo pipefail

################################################################################
# Preparation of the Operating System
################################################################################
clear
echo "Updating the Operating System and installing Python..."
sudo apt-get update
sudo apt-get upgrade -y
sudo apt install -y python3-pip -y
sudo apt install -y unzip -y
clear
echo "Updated the Operating System and installed Python..."
sleep 5


################################################################################
# doctl - DigitalOcean command-line client
################################################################################
clear
echo "Installing the Digital Ocean Command Line Interface..."
cd ~/ && mkdir doctl && cd doctl
curl -LO https://github.com/digitalocean/doctl/releases/download/v1.60.0/doctl-1.60.0-linux-amd64.tar.gz 
tar -xvf doctl-1.60.0-linux-amd64.tar.gz
sudo mv ~/doctl/doctl /usr/local/bin
clear
echo "Updated the Operating System and installed Python..."
echo "Installed the Digital Ocean Command Line Interface..."
sleep 5


################################################################################
# Kubernetes  Commad Line
################################################################################
clear
echo "Installing the Kubernetes Command Line Interface,..."
cd ~/ && mkdir kubectl && cd kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl


################################################################################
# Kubernetes Utilities
################################################################################
clear
echo "Installing Kubernetes Utilities..."

# k9s
curl -sS https://webinstall.dev/k9s | bash
# arkade
curl -sSLf https://dl.get-arkade.dev/ | sudo sh 
# kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

clear
echo "Updated the Operating System and installed Python..."
echo "Installed the Digital Ocean Command Line Interface..."
echo "Installed the Kubernetes Command Line Interface..."
echo "Installed the Kubernetes Utilities..."
sleep 5


################################################################################
# kubectx & kubens - Kubernetes Namespace and Cluster helpers
################################################################################
clear
echo "Installing kubectx and kubens..."
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
clear
echo "Updated the Operating System and installed Python..."
echo "Installed the Digital Ocean Command Line Interface..."
echo "Installed the Kubernetes Command Line Interface..."
echo "Installed the Kubernetes Utilities..."
echo "Installed kubectx and kubens..."
sleep 5


################################################################################
# kube-ps1 - Kubernetes prompt 
################################################################################
sudo git clone https://github.com/jonmosco/kube-ps1.git /opt/kube-ps1


################################################################################
# Helm 3 - Kubernetes Application Package Manager
################################################################################
clear
echo "Installing Helm 3..."
cd ~/ && mkdir helm-3 && cd helm-3
wget https://get.helm.sh/helm-v3.6.1-linux-amd64.tar.gz
tar -zxvf helm-v3.6.1-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
helm repo add stable https://charts.helm.sh/stable
clear
echo "Updated the Operating System and installed Python..."
echo "Installed the Digital Ocean Command Line Interface..."
echo "Installed the Kubernetes Command Line Interface..."
echo "Installed the Kubernetes Utilities..."
echo "Installed kubectx and kubens..."
echo "Installed Helm 3..."
sleep 5

################################################################################
# Octant - Real-time Kubernetes Dashboard
################################################################################
clear
echo "Installing Octant..."
cd ~/ && mkdir octant && cd octant
curl -LO https://github.com/vmware-tanzu/octant/releases/download/v0.21.0/octant_0.21.0_Linux-64bit.tar.gz
tar -xvf octant_0.21.0_Linux-64bit.tar.gz
sudo mv ./octant_0.21.0_Linux-64bit/octant /usr/local/bin/octant

clear
echo "Updated the Operating System and installed Python..."
echo "Installed the Digital Ocean Command Line Interface..."
echo "Installed the Kubernetes Command Line Interface..."
echo "Installed the Kubernetes Utilities..."
echo "Installed kubectx and kubens..."
echo "Installed Helm 3..."
echo "Installed Octant..."
sleep 5


################################################################################
# Locust - Load Testing Tool
################################################################################
clear
echo "Installing Locust..."
pip3 install locust
clear
echo "Updated the Operating System and installed Python..."
echo "Installed the Digital Ocean Command Line Interface..."
echo "Installed the Kubernetes Command Line Interface..."
echo "Installed the Kubernetes Utilities..."
echo "Installed kubectx and kubens..."
echo "Installed Helm 3..."
echo "Installed Octant..."
echo "Installed Locust..."
sleep 5


clear
echo "Updated the Operating System and installed Python..."
echo "Installed the Digital Ocean Command Line Interface..."
echo "Installed the Kubernetes Command Line Interface..."
echo "Installed the Kubernetes Utilities..."
echo "Installed kubectx and kubens..."
echo "Installed Helm 3..."
echo "Installed Octant..."
echo "Installed Locust..."
echo " "
echo "01-jump-host-prep.sh complete...rebooting"
sleep 5s

# Reboot Jump Host
sudo reboot

else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi

# End of Script
