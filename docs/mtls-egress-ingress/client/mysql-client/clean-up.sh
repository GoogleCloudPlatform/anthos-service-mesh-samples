
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

# [START servicemesh_mysql_client_clean_up]
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$DIR/../set-project-and-cluster-client.sh

# todo cleanup cleanup.sh :D
kubectl delete --ignore-not-found=true secret mysql-client-certs mysql-ca-certs
kubectl delete --ignore-not-found=true secret mysql-client-certs mysql-ca-certs -n istio-system

kubectl delete --ignore-not-found=true gateway istio-egressgateway-mysql
kubectl delete --ignore-not-found=true destinationrule egressgateway-for-mysql

kubectl delete --ignore-not-found=true virtualservice direct-mysql-through-egress-gateway
kubectl delete --ignore-not-found=true destinationrule originate-mtls-for-mysql

kubectl delete --ignore-not-found=true serviceentry mysql-external
# [END servicemesh_mysql_client_clean_up]