################################################################################
# Author: James Buckett
# email: james.buckett@gmail.com
# Script to install Gremlin
################################################################################

# tl;dr - Gremlin is a SaaS based Chaos Platform

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
echo "Installing Gremlin..."
sleep 5


cd ~/ && rm -R ~/gremlin
cd && mkdir gremlin && cd gremlin


# Sign-up for Gremlin service
# - Go to this [link](https://app.gremlin.com/signup)
# - Sign Up for an account
# - Login to the Gremlin App using your Company name and sign-on credentials.
# - These were emailed to you when you signed up to start using Gremlin.
# - Top Right click on `Company Settings`
# - Click `Teams` tab
# - CLick on your User
# - Click on Configuration
# - Click the blue Download button to save your certificates to your local computer.
#   - If on Windows download the `certificate.zip` file to c:\Users\<your-name>\Downloads
#   - If on Mac download the `certificate.zip` to the `~/download` directory.
# - The downloaded `certificate.zip` contains both a public-key certificate and a matching private key.
# - Obtain the external IP address of `digital-ocean-droplet`
#   - `doctl compute droplet list | awk 'FNR == 2 {print $3}'`
#   - This is the `Public IPv4` for `digital-ocean-droplet`
# - For Windows use WinSCP to upload `certificate.zip` to `digital-ocean-droplet` to `home/root/gremlin`
#   - Add your private key to WinSCP
#     - Advanced..SSH..Authentication..Private key file
# - For Mac use `scp` to upload `certificate.zip` to `digital-ocean-droplet`
#   - `scp certificate.zip root@<Public IPv4>:/root/gremlin/`
# - Unzip the `certificate.zip` and rename your certificate and key files to `gremlin.cert` and `gremlin.key`

cd ~/gremlin
sudo apt-get install unzip
unzip certificate.zip
mv *.priv_key.pem gremlin.key
mv *.pub_cert.pem gremlin.cert


# Create a namespace and secret for Gremlin
kubectl create ns ns-gremlin
kubectl create secret generic gremlin-team-cert --from-file=./gremlin.cert --from-file=./gremlin.key -n ns-gremlin


# Configure Gremlin
# Let Gremlin know your Gremlin team ID and your Kubernetes cluster name
export GREMLIN_TEAM_ID="changeit"
export GREMLIN_CLUSTER_ID=digital-ocean-cluster


# - Replace `"changeit"` with the value from the [Gremlin page](https://app.gremlin.com/signup)
#   - Obtain `GREMLIN_TEAM_ID` here:
#     - Top Right click on `Company Settings`
#     - Click `Manage Teams` tab
#     - Click on your User
#     - Click on Configuration
#     - Your `Team ID` should be on the top row
#     - Your `Team ID` is your `GREMLIN_TEAM_ID`

# If you have trouble with this section please go [here](https://www.gremlin.com/community/tutorials/how-to-install-and-use-gremlin-with-kubernetes/)

# Add the Gremlin helm chart

helm repo remove gremlin
helm repo add gremlin https://helm.gremlin.com


# Install the Gremlin Kubernetes client
helm install gremlin gremlin/gremlin \
  --namespace ns-gremlin \
  --set gremlin.teamID=$GREMLIN_TEAM_ID \
  --set gremlin.clusterID=$GREMLIN_CLUSTER_ID

else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi

# End of Script