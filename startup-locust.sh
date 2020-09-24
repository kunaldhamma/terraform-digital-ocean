#!/bin/bash

cd /root/locust
locust --host="http://${BOUTIQUE_LB}" -u "${USERS:-10}"
