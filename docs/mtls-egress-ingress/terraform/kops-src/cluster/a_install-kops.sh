
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

# [START servicemesh_cluster_a_install_kops]
#!/bin/bash

## Terraform vars
export PROJECT='${project}'
##

uname_out="$(uname -s)"
echo -e "Installing kOps for OS $uname_out"

case $uname_out in
Darwin*) 
    echo "Installing kOps for MacOs now"
    curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-darwin-amd64
    chmod +x ./kops
    # mv ./kops /tmp/
    echo "Done downloading"
    ;;
Linux*)
    echo "Installing kOps for Linux now"
    curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
    chmod +x ./kops
    # sudo mv ./kops /tmp/
    echo "Done downloading kops"
    ;;
*) 
    echo "Oh snap! It seems kOps is not yet available for your OS: $uname_out"
    exit 1
    ;;
esac

echo "Generating kops bucket"
gsutil mb gs://$PROJECT-kops-clusters




# [END servicemesh_cluster_a_install_kops]