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
echo "* Start in another shell : octant &                                                          *" >> /etc/motd
echo "* Start in another shell: ./locust/locust --host="http://${BOUTIQUE_LB}" -u "${USERS:-10}" &                *" >> /etc/motd
#echo "* Add this to .bashrc manually 'PS1='[\u@\h \w $(kube_ps1)]\$ '                             *" >> /etc/motd
echo "**********************************************************************************************" >> /etc/motd

touch /etc/rc.local 
sudo chmod a+x /etc/rc.local
echo "#!/bin/bash" >> /etc/rc.local 
echo "octant &" >> /etc/rc.local
echo "~/locust/locust --host="http://${BOUTIQUE_LB}" -u '${USERS:-10}' &" >> /etc/rc.local 

reboot

#End of Script