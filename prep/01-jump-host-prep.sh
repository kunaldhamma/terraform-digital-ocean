# Author:  James Buckett
# eMail: james.buckett@gmail.com
# Script to install various components onto the jumphost

#!/bin/bash

# Check that you are on jump host and not local host
if [ "$HOSTNAME" = "digital-ocean-droplet" ]; then

# Preparation of the Operating System
sudo apt-get update
sudo apt-get upgrade -y
sudo apt install -y python3-pip -y
sudo apt install -y unzip -y

# doctl - DigitalOcean command-line client
cd ~/ && rm -R ~/doctl
cd ~/ && mkdir doctl && cd doctl
curl -LO https://github.com/digitalocean/doctl/releases/download/v1.46.0/doctl-1.46.0-linux-amd64.tar.gz 
tar -xvf doctl-1.46.0-linux-amd64.tar.gz
sudo mv ~/doctl/doctl /usr/local/bin

# kubectl - Kubernetes command-line client
cd ~/ && rm -R ~/kubectl
cd ~/ && mkdir kubectl && cd kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# kubectx & kubens - Kubernetes Namespace and Cluster helpers
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# kube-ps1 - Kubernetes prompt 
sudo git clone https://github.com/jonmosco/kube-ps1.git /opt/kube-ps1

# Helm 3 - Kubernetes Application Package Manager
cd ~/ && rm -R ~/helm-3
cd ~/ && mkdir helm-3 && cd helm-3
wget https://get.helm.sh/helm-v3.3.1-linux-amd64.tar.gz
tar -zxvf helm-v3.3.1-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
helm repo add stable https://kubernetes-charts.storage.googleapis.com/

# Octant - Real-time Kubernetes Dashboard
cd ~/ && rm -R ~/octant
cd ~/ && mkdir octant && cd octant
curl -LO https://github.com/vmware-tanzu/octant/releases/download/v0.16.1/octant_0.16.1_Linux-64bit.tar.gz
tar -xvf octant_0.16.1_Linux-64bit.tar.gz
sudo mv ./octant_0.16.1_Linux-64bit/octant /usr/local/bin/octant

# Locust - Load Testing Tool
pip3 install locust

clear
echo "01-jump-host-prep.sh complete...rebooting"
sleep 5s

# Reboot Jump Host
reboot

else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi

# End of Script