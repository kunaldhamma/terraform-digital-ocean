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
echo ********************************************************************************************** >> /etc/motd
echo * Online Boutique is here: 139.59.194.152                                                    * >> /etc/motd
echo * Octant is here:  139.59.251.92:8900                                                        * >> /etc/motd
echo * Grafana is here:                                                                           * >> /etc/motd
echo * Locust is here: 139.59.251.92:8089                                                         * >> /etc/motd
echo * Goldilocks is here: 159.89.209.188                                                         * >> /etc/motd
echo * Start in another shell : octant &                                                          * >> /etc/motd
echo * Start in another shell: ./locust/locust --host=http://139.59.194.152 -u 10 &               * >> /etc/motd
echo ********************************************************************************************* >> /etc/motd

#octant & 
#~/locust/locust --host="http://${BOUTIQUE_LB}" -u "${USERS:-10}" &

reboot

#End of Script