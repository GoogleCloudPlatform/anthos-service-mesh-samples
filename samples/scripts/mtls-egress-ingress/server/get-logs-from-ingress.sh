
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

# [START servicemesh_server_get_logs_from_ingress]
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/./set-project-and-cluster-server.sh

kubectl logs -n istio-system "$(kubectl get pod -l istio=ingressgateway \
-n istio-system -o jsonpath='{.items[0].metadata.name}')" -f
# [END servicemesh_server_get_logs_from_ingress]