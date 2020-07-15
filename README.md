# Terraform to support the Tutorial on Microservices, Observability and Chaos on Digital Ocean 

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

At the end of Step 2 continue here:

Clone this repository.

Change into the directory.

## Initialize Terraform

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

## Get the IP of `digital-ocean-droplet`
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

*End of Section*

