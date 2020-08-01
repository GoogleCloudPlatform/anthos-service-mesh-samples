#!/bin/bash

# [START servicemesh_rctoken_istio_ingress_gateway]
cat <<EOF | kubectl apply -f -
apiVersion: "security.istio.io/v1beta1"
kind: "RequestAuthentication"
metadata:
  name: "ingressgateway-jwt-policy"
  namespace: "istio-system"
spec:
  selector:
    matchLabels:
      app: istio-ingressgateway
  jwtRules:
  - issuer: "https://cloud.google.com/iap"
    jwksUri: "https://www.gstatic.com/iap/verify/public_key-jwk"
    audiences:
    - $RCTOKEN_AUD
    fromHeaders:
    - name: ingress-authorization
      prefix: "Istio "
    outputPayloadToHeader: "verified-jwt"
    forwardOriginalToken: true
# [END servicemesh_rctoken_istio_ingress_gateway]
