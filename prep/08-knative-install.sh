################################################################################
# Author: James Buckett
# email: james.buckett@gmail.com
# Script to install Knative
# Create your first Knative app
# Link : https://opensource.com/article/20/11/knative
# Link : https://knative.dev/docs/admin/install/serving/install-serving-with-yaml/
################################################################################

# To install from digital-ocean-droplet
# wget https://raw.githubusercontent.com/jamesbuckett/terraform-digital-ocean/master/prep/08-knative-install.sh
# chmod +x 08-knative-install.sh
# ./08-knative-install.sh

#!/bin/bash

################################################################################
# Check that you are on jump host and not local host
################################################################################
if [ "$HOSTNAME" = "digital-ocean-droplet" ]; then

################################################################################
# Stop the script on errors
################################################################################
set -euo pipefail
set -o nounset
set -o errexit

clear
echo "Installing Knative..."
sleep 5

################################################################################
# Knative - Event Driven
################################################################################
kubectl apply -f https://github.com/knative/serving/releases/download/v0.25.0/serving-crds.yaml
kubectl apply -f https://github.com/knative/serving/releases/download/v0.25.0/serving-core.yaml

kubectl apply -f https://github.com/knative/net-kourier/releases/download/v0.25.0/kourier.yaml

kubectl patch configmap/config-network \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'

################################################################################
# Knative Ingress Loadbalancer
################################################################################

# This did not work suspect the Load Balancer was not ready yet, try putting in a sleep
sleep 60

KNATIVE_LB=$(doctl compute load-balancer list | awk 'FNR == 4 {print $2}')
export KNATIVE_LB

doctl compute domain records create --record-type A --record-name *.knative --record-data $KNATIVE_LB jamesbuckett.com --record-ttl=43200

kubectl patch configmap/config-domain   --namespace knative-serving   --type merge   --patch '{"data":{"knative.jamesbuckett.com":""}}'  

## Hello Example

# Check clean slate
# kn service list

# Create Knative namespace
kubectl create ns ns-knative

# Deployments

# Deploy first application passing environment variable=TARGET="Heart Shaped Cookie"
# kn service create cookie-as-a-service --image gcr.io/knative-samples/helloworld-go --env TARGET="Heart Shaped Cookie" -n ns-knative

# Curl or Browser "Heart Shaped Cookie"
# curl http://cookie-as-a-service.knative.jamesbuckett.com
# Should be: "Hello Heart Shaped Cookie!"

# Update Service by passing a new environment variable=TARGET="Dimond Shaped Cookie"
# kn service update cookie-as-a-service --env TARGET="Dimond Shaped Cookie" -n ns-knative

# Both revsions exist aka "Heart Shaped Cookie" and "Dimond Shaped Cookie"
# kn revision list

# Curl or Browser "Dimond Shaped Cookie"
# curl http://cookie-as-a-service.knative.jamesbuckett.com
# Should be: "Hello Dimond Shaped Cookie!" 

# Update to a Rust image 
# kn service update cookie-as-a-service --image gcr.io/knative-samples/helloworld-rust

# Curl or Browser Rust deployment
# curl http://hello-example.knative.jamesbuckett.com
# Should be: "Hello world: Second"

# Split Service
# kn service update cookie-as-a-service --traffic cookie-as-a-service-00001=50 --traffic cookie-as-a-service-00002=50

# Curl or Browser Both deployment
# curl http://cookie-as-a-service.ns-knative.knative.jamesbuckett.com
# Should be: "Hello Dimond Shaped Cookie!" 50%
# Should be: "Hello Heart Shaped Cookie!" 50% 

# kn revision describe hello-example-00003
# Conditions:
#   OK TYPE                  AGE REASON - OK gives the quick summary about whether the news is good or bad.
#   ++ Ready                  8h - The Ready condition, for example, surfaces the result of an underlying Kubernetes readiness probe.
#   ++ ContainerHealthy       8h - 
#   ++ ResourcesAvailable     8h
#    I Active                 8h NoTraffic - “As of 8 hours ago, the Active condition has an Informational status due to NoTraffic.”

# When the Active condition gives NoTraffic as a reason, that means there are no active instances of the Revision running.
# kn route list
# curl http://hello-example.ns-knative.knative.jamesbuckett.com

# kubectl get configuration hello-example -o json | jq '.status'
# {
#   "conditions": [
#     {
#       "lastTransitionTime": "2021-09-04T00:41:22Z",
#       "status": "True",
#       "type": "Ready"
#     }
#   ],
#   "latestCreatedRevisionName": "hello-example-00003",
#   "latestReadyRevisionName": "hello-example-00003",
#   "observedGeneration": 3 # Three generations aka deployments
# }

# Used for debugging 
# latestCreatedRevisionName and latestReadyRevisionName are the same here, but need not be. 
# Simply creating the Revision record doesn’t guarantee that some actual software is up and running. 
# These two fields make the distinction. 
# In practice, it allows you to spot the process of a Revision being acted on by lower-level controllers.
# Should be the same if new Revision is created

# kubectl describe configuration hello-example

# Name:         hello-example
# Namespace:    ns-knative
# Labels:       serving.knative.dev/service=hello-example
#               serving.knative.dev/serviceUID=e6c6d7f2-3b23-408d-b538-580f900b1725
# Annotations:  serving.knative.dev/creator: james.buckett@gmail.com                  # Annotations are key-value metadata attached to the records.
#               serving.knative.dev/lastModifier: james.buckett@gmail.com
#               serving.knative.dev/routes: hello-example
# API Version:  serving.knative.dev/v1
# Kind:         Configuration
# Metadata:
#   Creation Timestamp:  2021-09-04T00:38:42Z
#   Generation:          3                                                            # The generation is visible here under Metadata.
#   Managed Fields:
#     API Version:  serving.knative.dev/v1
#     Fields Type:  FieldsV1
#     fieldsV1:
#       f:metadata:
#         f:annotations:
#           .:
#           f:serving.knative.dev/creator:
#           f:serving.knative.dev/lastModifier:
#           f:serving.knative.dev/routes:
#         f:labels:
#           .:
#           f:serving.knative.dev/service:
#           f:serving.knative.dev/serviceUID:
#         f:ownerReferences:
#           .:
#           k:{"uid":"e6c6d7f2-3b23-408d-b538-580f900b1725"}:
#             .:
#             f:apiVersion:
#             f:blockOwnerDeletion:
#             f:controller:
#             f:kind:
#             f:name:
#             f:uid:
#       f:spec:
#         .:
#         f:template:
#           .:
#           f:metadata:
#             .:
#             f:annotations:
#               .:
#               f:client.knative.dev/updateTimestamp:
#               f:client.knative.dev/user-image:
#             f:creationTimestamp:
#           f:spec:
#             .:
#             f:containerConcurrency:
#             f:containers:
#             f:enableServiceLinks:
#             f:timeoutSeconds:
#       f:status:
#         .:
#         f:conditions:
#         f:latestCreatedRevisionName:
#         f:latestReadyRevisionName:
#         f:observedGeneration:
#     Manager:    controller
#     Operation:  Update
#     Time:       2021-09-04T00:39:13Z
#   Owner References:
#     API Version:           serving.knative.dev/v1
#     Block Owner Deletion:  true
#     Controller:            true
#     Kind:                  Service
#     Name:                  hello-example
#     UID:                   e6c6d7f2-3b23-408d-b538-580f900b1725
#   Resource Version:        200808
#   UID:                     0c75d3dc-1d52-4ad2-972e-60399ac6fc69
# Spec:
#   Template:
#     Metadata:
#       Annotations:
#         client.knative.dev/updateTimestamp:  2021-09-04T00:40:40Z
#         client.knative.dev/user-image:       gcr.io/knative-samples/helloworld-rust
#       Creation Timestamp:                    <nil>
#     Spec:                                                                                   # spec.template.spec
#       Container Concurrency:  0
#       Containers:
#         Env:
#           Name:   TARGET
#           Value:  Second
#         Image:    gcr.io/knative-samples/helloworld-rust
#         Name:     user-container
#         Readiness Probe:
#           Success Threshold:  1
#           Tcp Socket:
#             Port:  0
#         Resources:
#       Enable Service Links:  false
#       Timeout Seconds:       300
# Status:                                                                                     # Status
#   Conditions:
#     Last Transition Time:        2021-09-04T00:41:22Z
#     Status:                      True
#     Type:                        Ready
#   Latest Created Revision Name:  hello-example-00003
#   Latest Ready Revision Name:    hello-example-00003
#   Observed Generation:           3
# Events:                          <none>                                                     # Events

else
    echo "You are not on the jump host : digital-ocean-droplet"
    exit
fi

# End of Script
