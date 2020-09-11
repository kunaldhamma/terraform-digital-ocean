# Online Boutique
BOUTIQUE_LB=$(doctl compute load-balancer list | awk 'FNR == 2 {print $2}')
export BOUTIQUE_LB

# Update .bashrc
cd ~
echo "export BOUTIQUE_LB=$BOUTIQUE_LB" >> ~/.bashrc

# Update Message of the Day
echo "Reference commands to the various URLs in this tutorial" >> /etc/motd
echo "*************************************************************************************" >> /etc/motd
echo "* Online Boutique is here: echo $BOUTIQUE_LB                                        *" >> /etc/motd
echo "* Octant is here: echo $DROPLET_ADDR:8900                                           *" >> /etc/motd
echo "* Grafana is here: echo $GRAFANA_LB                                                 *" >> /etc/motd
echo "* Locust is here: echo $DROPLET_ADDR:8089                                           *" >> /etc/motd
echo "* Start in another shell : octant &                                                 *" >> /etc/motd
echo "* Start in another shell: locust --host="http://${BOUTIQUE_LB}" -u "${USERS:-10}" & *" >> /etc/motd
#echo "* Add this to .bashrc manually 'PS1='[\u@\h \w $(kube_ps1)]\$ '                     *" >> /etc/motd
echo "*************************************************************************************" >> /etc/motd
