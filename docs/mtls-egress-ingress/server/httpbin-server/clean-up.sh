
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

# [START servicemesh_httpbin_server_clean_up]
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../set-project-and-cluster-server.sh

kubectl delete --ignore-not-found=true gateway gateway-mutual
kubectl delete --ignore-not-found=true virtualservice virtual-service
kubectl delete --ignore-not-found=true -n istio-system secret httpbin-credential \
  httpbin-credential-cacert

kubectl delete --ignore-not-found=true sa httpbin
kubectl delete --ignore-not-found=true service httpbin
kubectl delete --ignore-not-found=true deploy httpbin
# [END servicemesh_httpbin_server_clean_up]