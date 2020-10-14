# Author:  James Buckett
# eMail: james.buckett@gmail.com
# Script to start Locust and Octant

#!/bin/bash

# Start Locust in a background process with Public IP and Users populated
cd /root/locust
locust --host="http://${BOUTIQUE_LB}" -u "${USERS:-10}" &

# Start Octant in a background process 
octant & 
