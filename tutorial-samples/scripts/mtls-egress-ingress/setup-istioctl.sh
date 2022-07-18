
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

# [START servicemesh_mtls_egress_ingress_setup_istioctl]
ASM_VERSION="1.6.11-asm.1"

uname_out="$(uname -s)"
case "${uname_out}" in
    Linux*)     OS=linux-amd64;;
    Darwin*)    OS=osx;;
    *)          exit;
esac

SUFFIX=${ASM_VERSION}-${OS}

curl -LO https://storage.googleapis.com/gke-release/asm/istio-${SUFFIX}.tar.gz
tar xzf istio-${SUFFIX}.tar.gz

cd istio-${ASM_VERSION}
export PATH=$PWD/bin:$PATH

# [END servicemesh_mtls_egress_ingress_setup_istioctl]