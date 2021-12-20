
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START servicemesh_cluster_b_create_kops_cluster]
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
# [END servicemesh_cluster_b_create_kops_cluster]