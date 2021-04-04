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

![image](https://user-images.githubusercontent.com/18049790/96455039-3d97b180-124f-11eb-80bc-2a72df451592.png)

## 2. Pre-requisites

Follow the steps on this [website](https://www.digitalocean.com/community/tutorials/how-to-use-terraform-with-digitalocean)
* Prerequisites
* Step 1 — Configuring your Environment
* Step 2 — Installing Terraform

Install current version of Terraform
```
cd ~/ && rm -R ~/terraform
cd ~/ && mkdir terraform && cd terraform
curl -O https://releases.hashicorp.com/terraform/0.14.9/terraform_0.14.9_linux_amd64.zip
unzip terraform_0.14.9_linux_amd64.zip
sudo mv ./terraform /usr/local/bin/terraform
```


At the end of Step 2 continue here:

Clone this repository.

Change into the directory.

Check the version of Kubernetes
* `doctl kubernetes options versions`
* Check this version against `version = "1.19.6-do.0"`
* Ensure they are the same 
* If not edit `microservices-metrics-chaos.tf` with the updated version.

## 3. Initialize Terraform

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
rm 02-cluster-prep.sh
wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/prep/03-post-install-prep.sh
chmod +x 03-post-install-prep.sh
./03-post-install-prep.sh
```
You should see a message of the day on `digital-ocean-droplet` with information:
`x.x.x.x` represent your IP values
```
Reference URLs in this tutorial
**********************************************************************************************
* Real-time Kubernetes Dashboard - Octant is here: 165.232.164.222:8900 
* Sample Microservices Application - Online Boutique is here: demo.jamesbuckett.com 
* Chaos Engineering Platform - Chaos Mesh is here: chaos.jamesbuckett.com 
* Vertical Pod Autoscaler recommendations - Goldilocks is here: vpa.jamesbuckett.com 
* Distributed Log Aggregation - Loki is here: loki.jamesbuckett.com 
* Loki User:  admin   Loki Password: 5IcULwlPmXyMoayYk67aLxkkut3RzT3tqOgWg8QB
* Load Testing Tool - Locust is here: 165.232.164.222:8089 
* To start Locust & Octant, open another shell and execute: sh /root/locust/startup-locust.sh 
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
  * Import this dashboard: `12611`
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

### 5.3 Chaos Mesh
* Chaos Mesh is a Cloud Native Computing Foundation (CNCF) hosted project. 
* It is a cloud-native Chaos Engineering platform that orchestrates chaos on Kubernetes environments. 
* At the current stage, it has the following components:
  * Chaos Operator: the core component for chaos orchestration. 
    * Fully open sourced.
  * Chaos Dashboard: a Web UI for managing, designing, monitoring Chaos Experiments; under development.

Example Hypothesis
* Given an application is highly available on Kubernetes
* When there is a Kubernetes pod outage
* Then there is no impact on application functionality

Example Experiment
* Validate the health of the application through the landing page URL
* Disrupt the  `frontend` micro-service instances
* Validate the health of the application through the landing page URL
* Thus implying that the application functionality is not impacted

#### Experiment Part #1
* Scale Deployment `frontend`  to just one container to service requests: 
  * `kubectl scale --replicas=1 deployment.apps/frontend`

Create an Experiment to test resilience of `frontend` micro-service:

In Chaos Mesh dashboard: 
* New Experiment
  * Name: `frontend-pod-failure`
  * Namespace: `ns-microservices-demo`
  * Label: `app:frontend`
    * Next
* Label Selectors: `app:frontend`
* Affected Pods Preview: frontend-*
* Pod Lifecycle
* Action: Pod Failure
* Finish

Observe that the Online Boutique application is no longer rendering the landing page.

#### Experiment Part #2
Go to the Chaos Mesh dashboard and pause the `frontend-pod-failure` experiment.
* Experiments
* Next to your `frontend-pod-failure` experiment hit the  
* Pause button

Scale Deployment `frontend`  to three containers to service requests: 
* `kubectl scale --replicas=3 deployment.apps/frontend`
* In Octanct verify `frontend` is 3/3

Restart the experiment

Observe that the Online Boutique application is rendering the landing page.

<!--
##### Network Chaos Example

```
apiVersion: chaos-mesh.org/v1alpha1
kind: NetworkChaos
metadata:
  name: web-show-network-delay
spec:
  action: delay # the specific chaos action to inject
  mode: one # the mode to run chaos action; supported modes are one/all/fixed/fixed-percent/random-max-percent
  selector: # pods where to inject chaos actions
    namespaces:
      - default
    labelSelectors:
      "app": "web-show"  # the label of the pod for chaos injection
  delay:
    latency: "10ms"
  duration: "30s" # duration for the injected chaos experiment
  scheduler: # scheduler rules for the running time of the chaos experiments about pods.
    cron: "@every 60s"
```
--->

### 5.4 Gremlin 

#### Install Gremlin

Create a gremlin directory
```
cd ~/ && rm -R ~/gremlin
cd && mkdir gremlin && cd gremlin
```

Sign-up for Gremlin service
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

### 5.5 Argo

```
argo submit -n argo --watch https://raw.githubusercontent.com/argoproj/argo/master/examples/hello-world.yaml
argo list -n argo
argo get -n argo @latest
argo logs -n argo @latest
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
./04-clean-up.sh
```

Or use the Terraform method to tear down the infrastructure

### 3.4 Tear down the Infrastructure
* Only use this if you want to use Terraform to tear down the deployment.
* Alternatively use the 

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

