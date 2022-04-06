# Install Online Boutique apps with Sidecars, ServiceAccounts and AuthorizationPolicies with Kustomize

_Note: The [base/all/kubernetes-manifests.yaml](base/all/kubernetes-manifests.yaml) file contains the definition for all the Kubernetes resources required to deploy the Online Boutique (https://github.com/GoogleCloudPlatform/microservices-demo) sample application._

```
NAMESPACE=onlineboutique
ASM_VERSION=asm-managed-rapid
ASM_CHANNEL=rapid
INGRESS_GATEWAY_NAMESPACE=asm-ingress
INGRESS_GATEWAY_NAME=asm-ingressgateway
sed -i "s/ONLINEBOUTIQUE_NAMESPACE/${NAMESPACE}/g" base/for-namespace/kustomization.yaml
sed -i "s/ONLINEBOUTIQUE_NAMESPACE/${NAMESPACE}/g;s/ASM_VERSION/${ASM_VERSION}/g" base/for-asm-channel/kustomization.yaml
sed -i "s/ONLINEBOUTIQUE_NAMESPACE/${NAMESPACE}/g" authorization-policies/for-namespace/kustomization.yaml
sed -i "s/ONLINEBOUTIQUE_NAMESPACE/${NAMESPACE}/g;s/INGRESS_GATEWAY_NAMESPACE/${INGRESS_GATEWAY_NAMESPACE}/g;s/INGRESS_GATEWAY_NAME/${INGRESS_GATEWAY_NAME}/g" authorization-policies/for-ingress-gateway/kustomization.yaml
sed -i "s/ONLINEBOUTIQUE_NAMESPACE/${ONLINEBOUTIQUE_NAMESPACE}/g" sidecars/for-namespace/kustomization.yaml
kustomize edit set namespace $NAMESPACE
kubectl apply -k .
```

Optionally, you could also update the `spec.hosts` for the Online Boutique `VirtualService` (instead of the default '*' value):
```
HOST_NAME=your-host-name.com
sed -i "s/HOST_NAME/${HOST_NAME}/g" base/for-virtualservice-host/kustomization.yaml
kustomize edit add component base/for-virtualservice-host
kubectl apply -k .
```

Optionally, you could also replace the in-cluster `redis` database by Memorystore (redis) for the `cartservice` app:
```
REDIS_IP=0.0.0.0
REDIS_PORT=6379
sed -i "s/REDIS_IP/${REDIS_IP}/g;s/REDIS_PORT/${REDIS_PORT}/g" for-memorystore/kustomization.yaml
kustomize edit add component base/for-memorystore
kustomize edit add component sidecars/for-memorystore
kustomize edit add component service-accounts/for-memorystore
kustomize edit add component authorization-policies/for-memorystore
kubectl apply -k .
```