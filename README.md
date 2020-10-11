# Terraform to support the Tutorial on Microservices, Observability and Chaos on Digital Ocean 

![image](https://user-images.githubusercontent.com/18049790/87522892-c6cfa300-c6b8-11ea-8d9b-fcabac5fd4b9.png)

```diff
- This is a work in progress and not complete -
```

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

## Build the Infrastructure

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


### jump-host-prep.sh ~5 minutes
On `digital-ocean-droplet`
```
cd ~/ && rm -R ~/prep
clear
cd ~/ && mkdir prep && cd prep
wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/jump-host-prep.sh
chmod +x jump-host-prep.sh
sh jump-host-prep.sh
```

The virtual machine will reboot at the end of this script.

Wait for the virtual machine to be available before continuing 

### cluster-prep.sh ~2 minutes

```
cd prep
wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/cluster-prep.sh
chmod +x cluster-prep.sh
vi cluster-prep.sh
```

Update this line 'doctl auth init --access-token "xxx"' in `cluster-prep.sh` with your own Access Token.

```
sh cluster-prep.sh
```

The virtual machine will reboot at the end of this script.

Wait for the virtual machine to be available before continuing 

### online-boutique.sh ~4 minutes

```
cd prep
rm cluster-prep.sh
wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/online-boutique.sh
chmod +x online-boutique.sh
sh online-boutique.sh
```

## Clean Up Everything

Run this to download a clean-up.sh script
```
cd ~/ && rm -R ~/clean-up
clear
cd ~/ && mkdir clean-up && cd clean-up
wget https://raw.githubusercontent.com/jamesbuckett/microservices-metrics-chaos/master/clean-up.sh
chmod +x clean-up.sh
sh clean-up.sh
```

*End of Section*

