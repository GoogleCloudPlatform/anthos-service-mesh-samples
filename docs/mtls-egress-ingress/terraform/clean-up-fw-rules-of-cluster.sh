#!/bin/bash

x=1
max=5

while [ $x -le $max ]
do
  echo "Deleting GKE FW-rules for the $x out of $max times."
  gcloud compute firewall-rules list --filter="name=example-vpc" \
    --format="value(name)" | xargs -I {} gcloud compute firewall-rules delete {} -q
  x=$(( $x + 1 ))
  echo "Sleeping for 5 seconds now."
  sleep 5
done
