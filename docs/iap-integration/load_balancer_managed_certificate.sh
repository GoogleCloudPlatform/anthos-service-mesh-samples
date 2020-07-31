#!/bin/bash
# [START servicemesh_load_balancer_managed_certificate]
cat <<EOF | kubectl apply -f -
apiVersion: networking.gke.io/v1beta1
kind: ManagedCertificate
metadata:
  name: example-certificate
  namespace: istio-system
spec:
  domains:
    - ${DOMAIN_NAME}
EOF
# [END servicemesh_load_balancer_managed_certificate]
