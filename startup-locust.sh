#!/bin/bash

cd ~/locust
locust --host="http://${BOUTIQUE_LB}" -u "${USERS:-10}"
