# Install Online Boutique apps with `Sidecars`, `ServiceAccounts` and `AuthorizationPolicies` with Kustomize

_Note: The [base/all/kubernetes-manifests.yaml](base/all/kubernetes-manifests.yaml) file contains the definition for all the Kubernetes resources required to deploy the Online Boutique (https://github.com/GoogleCloudPlatform/microservices-demo) sample application._

## Quickstart

This sample will deploy the Online Boutique sample application with Kustomize. 
To get started, run the following command to set the variables:

```
NAMESPACE=onlineboutique
INGRESS_GATEWAY_NAMESPACE=asm-ingress
INGRESS_GATEWAY_NAME=asm-ingressgateway
```
Using `sed`, run the following to set namespace in the kustomize YAML files
```
sed -i "s/ONLINEBOUTIQUE_NAMESPACE/${NAMESPACE}/g" base/for-namespace/kustomization.yaml
sed -i "s/ONLINEBOUTIQUE_NAMESPACE/${NAMESPACE}/g" authorization-policies/for-namespace/kustomization.yaml
sed -i "s/ONLINEBOUTIQUE_NAMESPACE/${NAMESPACE}/g;s/INGRESS_GATEWAY_NAMESPACE/${INGRESS_GATEWAY_NAMESPACE}/g;s/INGRESS_GATEWAY_NAME/${INGRESS_GATEWAY_NAME}/g" authorization-policies/for-ingress-gateway/kustomization.yaml
sed -i "s/ONLINEBOUTIQUE_NAMESPACE/${ONLINEBOUTIQUE_NAMESPACE}/g" sidecars/for-namespace/kustomization.yaml
```
Lastly run the following to set the value of the namespace field in the kustomization file, and to apply the resources.
```
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

## Contributing 
For improvements to this sample submit your pull requests to the main branch
