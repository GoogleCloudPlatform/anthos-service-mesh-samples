#!/bin/bash
# [START servicemesh_load_balancer_ingress]
cat <<EOF | kubectl create -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: example-ingress
  namespace: istio-system
  annotations:
    kubernetes.io/ingress.global-static-ip-name: example-static-ip
    networking.gke.io/managed-certificates: example-certificate
spec:
  backend:
    serviceName: istio-ingressgateway
    servicePort: 80
EOF
# [END servicemesh_load_balancer_ingress]
