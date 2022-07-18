
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

# [START servicemesh_mysql_server_clean_up]
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../set-project-and-cluster-server.sh

kubectl delete --ignore-not-found=true -n istio-system secret mysql-credential

# todo remove ingress patch
kubectl delete --ignore-not-found=true gateway mysql-gateway
kubectl delete --ignore-not-found=true virtualservice mysql-virtual-service

kubectl delete --ignore-not-found=true service mysql
kubectl delete --ignore-not-found=true deploy mysql
kubectl delete --ignore-not-found=true pvc mysql-pv-claim

# [END servicemesh_mysql_server_clean_up]