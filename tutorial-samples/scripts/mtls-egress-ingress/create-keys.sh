
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

# [START servicemesh_mtls_egress_ingress_create_keys]
. ./server/set-project-and-cluster-server.sh

INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

rm -rf certs
mkdir certs
[ ! -d mtls-go-example ]  && git clone https://github.com/nicholasjackson/mtls-go-example.git
cd mtls-go-example
# delete old certs
rm -rf 1_root 2_intermediate 3_application 4_client
echo "Please enter a password for your security keys: "
read SECURE_PASSWORD

if [[ -z "$SECURE_PASSWORD" ]]; then
   printf '%s\n' "Please provide a password."
   exit 1
fi

yes | ./generate.sh $INGRESS_HOST.nip.io $SECURE_PASSWORD

mv 1_root ../certs
mv 2_intermediate ../certs
mv 3_application ../certs
mv 4_client ../certs
# [END servicemesh_mtls_egress_ingress_create_keys]