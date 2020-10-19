# Terraform to support the Tutorial on Microservices, Observability and Chaos on Digital Ocean 

![image](https://user-images.githubusercontent.com/18049790/87522892-c6cfa300-c6b8-11ea-8d9b-fcabac5fd4b9.png)

```diff
- This is a work in progress and not complete -
```

The Terraform takes 9 minutes and the post build tasks take 11 minutes for a total of 20 minutes time.

## Disclaimer
* Opinions expressed here are solely my own and do not express the views or opinions of JPMorgan Chase.
* Any third-party trademarks are the intellectual property of their respective owners and any mention herein is for referential purposes only. 

## 1. Introduction

### 1.1 Agenda
* Use Terraform to perform the following 
  * Deploy an Ubuntu jump host on Digital Ocean with SSH access
  * Deploy a Kubernetes cluster on Digital Ocean 
  * Install command line tools and utilities on the jump host
    * kubectl
    * doctl 
    * kubectx
    * kubens 
    * Helm 3
    * Octant 
    * Locust
  * Install applications and utilities on the custer
    * metrics server 
    * Online Boutique 
    * Loki
    * Chaos Mesh
    * Kubernetes GraphQL
    * Vertical Pod Autoscaler and Goldilocks 

The final state should be a setup similar to the diagram below in about 20 minutes.

![image](https://user-images.githubusercontent.com/18049790/96423109-76259400-122b-11eb-8b44-2390379f5429.png)

## 2. Pre-requisites

Follow the steps on this [website](https://www.digitalocean.com/community/tutorials/how-to-use-terraform-with-digitalocean)
* Prerequisites
* Step 1 — Configuring your Environment
* Step 2 — Installing Terraform

Install current version of Terraform
```
cd ~/ && rm -R ~/terraform
cd ~/ && mkdir terraform && cd terraform
curl -O https://releases.hashicorp.com/terraform/0.13.0/terraform_0.13.0_linux_amd64.zip
unzip terraform_0.13.0_linux_amd64.zip
sudo mv ./terraform /usr/local/bin/terraform
```


At the end of Step 2 continue here:

Clone this repository.

Change into the directory.

Check the version of Kubernetes
* `doctl kubernetes options versions`
* Check this version against `version = "1.18.3-do.0"`
* Ensure they are the same 
* If not edit `microservices-metrics-chaos.tf` with the updated version.

## 3. Initialize Terraform

`terraform init`

`terraform 0.13upgrade .`

`terraform init`

### 3.1 Build the Infrastructure ~9 minutes

```
terraform plan \
  -var "do_token=${DO_PAT}" \
  -var "pub_key=$HOME/.ssh/id_rsa.pub" \
  -var "pvt_key=$HOME/.ssh/id_rsa" \
  -var "ssh_fingerprint=${DO_SSH_FINGERPRINT}"
```

```
terraform apply \
  -var "do_token=${DO_PAT}" \
  -var "pub_key=$HOME/.ssh/id_rsa.pub" \
  -var "pvt_key=$HOME/.ssh/id_rsa" \
  -var "ssh_fingerprint=${DO_SSH_FINGERPRINT}"
```

Get the IP of digital-ocean-droplet
* `doctl compute droplet list | awk 'FNR == 2 {print $3}'`


View state of infrastructure
* `terraform show terraform.tfstate`

## 4. Preparing the Jump Host and Cluster ~11 minutes

### 4.1 Prepare the Jump Host ~5 minutes
* This script prepares the jump host and installs some utilities
* On `digital-ocean-droplet` run the following:
```
cd ~/ && rm -R ~/prep
clear
cd ~/ && mkdir prep && cd prep
wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/prep/01-jump-host-prep.sh
chmod +x 01-jump-host-prep.sh
./01-jump-host-prep.sh
```

* The virtual machine will reboot at the end of this script.
* Wait for the virtual machine to be available before continuing 

### 4.2 Prepare the Kubernetes Cluster ~2 minutes
* This script installs software onto the Kubernetes cluster
* On `digital-ocean-droplet` run the following:
```
cd prep
wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/prep/02-cluster-prep.sh
chmod +x 02-cluster-prep.sh
vi 02-cluster-prep.sh
```

Update this line 'doctl auth init --access-token "xxx"' in `02-cluster-prep.sh` with your own Access Token.

```
./02-cluster-prep.sh
```

* The virtual machine will reboot at the end of this script.
* Wait for the virtual machine to be available before continuing 

### 4.3 Post Install Tasks ~4 minutes
* This script applies post install tasks to the jump host
* On `digital-ocean-droplet` run the following:
```
cd prep
rm cluster-prep.sh
wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/prep/03-post-install-prep.sh
chmod +x 03-post-install-prep.sh
./03-post-install-prep.sh
```
You should see a message of the day on `digital-ocean-droplet` with information:
`x.x.x.x` represent your IP values
```
Reference URLs in this tutorial
**********************************************************************************************
* Real-time Kubernetes Dashboard - Octant is here:  x.x.x.x:8900
* Sample Microservices Application - Online Boutique is here: x.x.x.x.xip.io
* Distributed Log Aggregation - Loki is here: x.x.x.x.xip.io
* Chaos Engineering Platfom - Chaos Mesh  is here: x.x.x.x:2333
* Vertical Pod Autoscaler recommendations - Goldilocks is here: x.x.x.x.xip.io
* Load Testing Tool - Locust is here: x.x.x.x:8089
* Locust values are Spawn:500 & URL: x.x.x.x
* Start Locust & Octant in another shell : sh /root/locust/startup-locust.sh
**********************************************************************************************
```

## 5. Setup and Testing

### 5.1 Loki

####  Loki Setup
Username: `admin` 
* Obtain the password: 
```
kubectl get secret --namespace ns-loki loki-release-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```
#### Loki Dashboards 

* Left side look for + sign...`Import`
  * Import this dashboard: `12019`
  * Import this dashboard: `10000`
  * Import this dashboard: `1471`

### 5.2 Kubernetes GraphQL 
* Simple setup for converting Kubernetes API server into [GraphQL API](https://github.com/onelittlenightmusic/kubernetes-graphql)


Query list pods
```
kubectl get pods --namespace ns-microservices-demo -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.startTime}{"\n"}{end}'
```

Get pods with labels


### 5.3 Gremlin 

#### Install Gremlin

Create a gremlin directory
```
cd ~/ && rm -R ~/gremlin
cd && mkdir gremlin && cd gremlin
```

Signup for Gremlin service
* Go to this [link](https://app.gremlin.com/signup)
* Sign Up for an account
* Login to the Gremlin App using your Company name and sign-on credentials. 
* These were emailed to you when you signed up to start using Gremlin.
* Top Right click on `Company Settings`
* Click `Teams` tab
* CLick on your User
* Click on Configuration
* Click the blue Download button to save your certificates to your local computer. 
  * If on Windows download the `certificate.zip` file to c:\Users\<your-name>\Downloads
  * If on Mac download the `certificate.zip` to the `~/download` directory.
* The downloaded `certificate.zip` contains both a public-key certificate and a matching private key.
* Obtain the external IP address of `digital-ocean-droplet`
  * `doctl compute droplet list | awk 'FNR == 2 {print $3}'`
  * This is the `Public IPv4` for `digital-ocean-droplet`
* For Windows use WinSCP to upload `certificate.zip` to `digital-ocean-droplet` to `home/root/gremlin`
  * Add your private key to WinSCP 
    * Advanced..SSH..Authentication..Private key file
* For Mac use `scp` to upload `certificate.zip` to `digital-ocean-droplet`
  * `scp certificate.zip root@<Public IPv4>:/root/gremlin/`

* Unzip the `certificate.zip` and rename your certificate and key files to `gremlin.cert` and `gremlin.key`
```
cd ~/gremlin
sudo apt-get install unzip
unzip certificate.zip
mv *.priv_key.pem gremlin.key
mv *.pub_cert.pem gremlin.cert
```
Create a namespace and secret for Gremlin
```
k create ns ns-gremlin
k create secret generic gremlin-team-cert --from-file=./gremlin.cert --from-file=./gremlin.key -n ns-gremlin
```

#### Configure Gremlin

Let Gremlin know your Gremlin team ID and your Kubernetes cluster name
```
export GREMLIN_TEAM_ID="changeit"
export GREMLIN_CLUSTER_ID=digital-ocean-cluster
```

* Replace `"changeit"` with the value from the [Gremlin page](https://app.gremlin.com/signup) 
  * Obtain `GREMLIN_TEAM_ID` here: 
    * Top Right click on `Company Settings`
    * Click `Manage Teams` tab
    * Click on your User
    * Click on Configuration
    * Your `Team ID` should be on the top row
    * Your `Team ID` is your `GREMLIN_TEAM_ID`

If you have trouble with this section please go [here](https://www.gremlin.com/community/tutorials/how-to-install-and-use-gremlin-with-kubernetes/)

Add the Gremlin helm chart
```
helm repo remove gremlin
helm repo add gremlin https://helm.gremlin.com
```

Install the Gremlin Kubernetes client
```
helm install gremlin gremlin/gremlin \
  --namespace ns-gremlin \
  --set gremlin.teamID=$GREMLIN_TEAM_ID \
  --set gremlin.clusterID=$GREMLIN_CLUSTER_ID
```


## 6. Clean Up Everything 
* This script deletes all assets on Digital Ocean
* Only run this when you are done with the tutorial and cluster
* On `digital-ocean-droplet` run the following:
```
cd ~/ && rm -R ~/clean-up
clear
cd ~/ && mkdir clean-up && cd clean-up
wget wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/prep/04-clean-up.sh
chmod +x 04-clean-up.sh
sh 04-clean-up.sh
```

Or use the Terraform method to tear down the infrastructure

### 3.4 Tear down the Infrastructure
* Only use this if you want to use Terraform to tear down the deployment.
* Alternativly use the 

```
terraform plan -destroy -out=terraform.tfplan \
  -var "do_token=${DO_PAT}" \
  -var "pub_key=$HOME/.ssh/id_rsa.pub" \
  -var "pvt_key=$HOME/.ssh/id_rsa" \
  -var "ssh_fingerprint=$DO_SSH_FINGERPRINT"
  ```

`terraform apply terraform.tfplan`

```diff
- Check the Digital Ocean page for any artifacts that were not deleted and delete them from the Digital Ocean page. -
```

*End of Section*

