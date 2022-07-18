
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

# [START servicemesh_terraform_clean_up_fw_rules_of_cluster]
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

# [END servicemesh_terraform_clean_up_fw_rules_of_cluster]