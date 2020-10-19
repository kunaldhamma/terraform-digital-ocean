# Terraform to support the Tutorial on Microservices, Observability and Chaos on Digital Ocean 

![image](https://user-images.githubusercontent.com/18049790/87522892-c6cfa300-c6b8-11ea-8d9b-fcabac5fd4b9.png)

```diff
- This is a work in progress and not complete -
```

The Terraform takes 9 minutes and the post build tasks take 11 minutes for a total of 20 minutes time.

## Disclaimer
* Opinions expressed here are solely my own and do not express the views or opinions of JPMorgan Chase.
* Any third-party trademarks are the intellectual property of their respective owners and any mention herein is for referential purposes only. 

## Pre-requisites

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

## Initialize Terraform

`terraform init`

`terraform 0.13upgrade .`

`terraform init`

## Build the Infrastructure ~9 minutes

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

## Get the IP of digital-ocean-droplet
* `doctl compute droplet list | awk 'FNR == 2 {print $3}'`


## View state of infrastructure

`terraform show terraform.tfstate`

## Tear down the Infrastructure

```
terraform plan -destroy -out=terraform.tfplan \
  -var "do_token=${DO_PAT}" \
  -var "pub_key=$HOME/.ssh/id_rsa.pub" \
  -var "pvt_key=$HOME/.ssh/id_rsa" \
  -var "ssh_fingerprint=$DO_SSH_FINGERPRINT"
  ```

`terraform apply terraform.tfplan`

```diff
- This step does not delete the Load Balancers that are provisioned as part of the tutorial -
```

## Preparing the Jump Host and Cluster ~11 minutes


### 01-jump-host-prep.sh ~5 minutes
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

### 02-cluster-prep.sh ~2 minutes
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

### 03-post-install-prep.sh ~4 minutes
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

## Clean Up Everything - 04-clean-up.sh
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

Check the Digital Ocean page for any artifacts that were not deleted and delete them from the Digital Ocean page.




*End of Section*

