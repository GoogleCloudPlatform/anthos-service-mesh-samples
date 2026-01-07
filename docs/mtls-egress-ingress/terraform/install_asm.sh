
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

# [START servicemesh_terraform_install_asm]
#!/bin/bash

uname_out="$(uname -s)"
case "${uname_out}" in
    Linux*)     OS=linux-amd64;;
    Darwin*)    OS=osx;;
    *)          echo "Oh snap! It seems ASM is not yet available for your OS: $uname_out"; exit1;
esac

ASM_SUFFIX=${ASM_VERSION}-${OS}

uname_out="$(uname -s)"
echo -e "Installing ASM for OS $uname_out into $TERRAFORM_ROOT"

echo "Downloading ASM installation files"
gcloud storage cp gs://gke-release/asm/istio-${ASM_SUFFIX}.tar.gz $TERRAFORM_ROOT/
echo "Done downloading"
echo "Unpacking download and preparing install"
tar xzf $TERRAFORM_ROOT/istio-${ASM_SUFFIX}.tar.gz

# Installing ASM
echo "Preparing istio installation"
cd istio-${ASM_VERSION}
kubectl create namespace istio-system
# Create webhook version
echo "Creating webhook for version asm-${ASM_REVISION}"
cat <<EOF > $TERRAFORM_ROOT/istiod-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: istiod
  namespace: istio-system
  labels:
    istio.io/rev: asm-${ASM_REVISION}
    app: istiod
    istio: pilot
    release: istio
spec:
  ports:
    - port: 15010
      name: grpc-xds # plaintext
      protocol: TCP
    - port: 15012
      name: https-dns # mTLS with k8s-signed cert
      protocol: TCP
    - port: 443
      name: https-webhook # validation and injection
      targetPort: 15017
      protocol: TCP
    - port: 15014
      name: http-monitoring # prometheus stats
      protocol: TCP
  selector:
    app: istiod
    istio.io/rev: asm-${ASM_REVISION}
EOF
# Run istioctl isntallation
echo "Installing istio into the cluster"
bin/istioctl install --set profile=asm-multicloud --set revision=asm-${ASM_REVISION} -f "$TERRAFORM_ROOT/../$TYPE/features.yaml" -y
kubectl apply -f $TERRAFORM_ROOT/istiod-service.yaml
# Inject sidecare proxies
kubectl label namespace default istio-injection- istio.io/rev=asm-${ASM_REVISION} --overwrite
echo "Done installing istio into the cluster"

# [END servicemesh_terraform_install_asm]