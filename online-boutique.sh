#!/bin/bash

sleep 3m

# Online Boutique
BOUTIQUE_LB=$(doctl compute load-balancer list | awk 'FNR == 2 {print $2}')
export BOUTIQUE_LB

# Goldilocks
GOLDILOCKS_LB=$(doctl compute load-balancer list | awk 'FNR == 3 {print $2}')
export GOLDILOCKS_LB

# Update .bashrc
cd ~
echo "export BOUTIQUE_LB=$BOUTIQUE_LB" >> ~/.bashrc
echo "export GOLDILOCKS_LB=$GOLDILOCKS_LB" >> ~/.bashrc

# Update Message of the Day
echo "Reference commands to the various URLs in this tutorial" >> /etc/motd
echo "**********************************************************************************************" >> /etc/motd
echo "* Online Boutique is here: $BOUTIQUE_LB                                                     *" >> /etc/motd
echo "* Octant is here:  $DROPLET_ADDR:8900                                                        *" >> /etc/motd
# echo "* Grafana is here: $GRAFANA_LB                                                               *" >> /etc/motd
echo "* Locust is here: $DROPLET_ADDR:8089                                                         *" >> /etc/motd
echo "* Goldilocks is here: $GOLDILOCKS_LB                                                         *" >> /etc/motd
#echo "* Add this to .bashrc manually 'PS1='[\u@\h \w $(kube_ps1)]\$ '                             *" >> /etc/motd
echo "**********************************************************************************************" >> /etc/motd

# Locust
cd ~/ && rm -R ~/locust
cd ~/ && mkdir locust && cd locust
wget https://raw.githubusercontent.com/jamesbuckett/microservices-metrics-chaos/master/locustfile.py
cd /root/prep
wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/startup-locust.sh
chmod +x startup-locust.sh
cd /etc/systemd/system
wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/locust.service
chmod 755 locust.service
systemctl enable locust.service

# Octant
cd /etc/systemd/system
wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/octant.service
chmod 755 octant.service
systemctl enable octant.service

reboot

#End of Script