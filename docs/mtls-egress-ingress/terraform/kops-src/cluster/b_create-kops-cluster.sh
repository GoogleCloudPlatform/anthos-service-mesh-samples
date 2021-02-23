#!/bin/bash

## TF vars
export PROJECT='${project}'
export GCPZONE='${zone}'
export KOPS_FEATURE_FLAGS='${kops-gce}'
###
# Make those eventually configurable - but for now they are fixed

#source ../env-vars
echo "Installing and running kops cluster now"
./kops create cluster server-cluster.k8s.local --cloud gce --zones $GCPZONE --state "gs://$PROJECT-kops-clusters/"/ --project=$PROJECT --node-count=4
#echo "Cluster object has been created:"
echo "Starting cluster instances now"
./kops update cluster server-cluster.k8s.local --yes --state "gs://$PROJECT-kops-clusters"/