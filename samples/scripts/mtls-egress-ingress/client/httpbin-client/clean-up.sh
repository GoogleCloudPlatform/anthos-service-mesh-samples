
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

# [START servicemesh_httpbin_client_clean_up]
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$DIR/../set-project-and-cluster-client.sh

kubectl delete --ignore-not-found=true secret httpbin-server-certs httpbin-ca-certs -n mesh-external
kubectl delete --ignore-not-found=true secret httpbin-client-certs httpbin-ca-certs
kubectl delete --ignore-not-found=true secret httpbin-client-certs httpbin-ca-certs -n istio-system

kubectl delete --ignore-not-found=true service httpbin-external
kubectl delete --ignore-not-found=true virtualservice vs-alias
kubectl delete --ignore-not-found=true gateway istio-egressgateway-httpbin
kubectl delete --ignore-not-found=true serviceentry httpbin-serviceentry
kubectl delete --ignore-not-found=true virtualservice direct-httpbin-through-egress-gateway
kubectl delete --ignore-not-found=true destinationrule originate-mtls-for-httpbin
kubectl delete --ignore-not-found=true destinationrule egressgateway-for-httpbin
kubectl delete --ignore-not-found=true svc sleep
kubectl delete --ignore-not-found=true deployment sleep
# [END servicemesh_httpbin_client_clean_up]