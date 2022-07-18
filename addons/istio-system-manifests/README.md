# Deploy Mesh-wide resources in `istio-system` namespace with Kustomize

Create the `istio-system` namespace:
```
kubectl apply -k .
```

Optionally, you could also deploy a default `deny` `AuthorizationPolicy` and mTLS `STRICT` for the entire Mesh:
```
kustomize edit add resource with-strict-mtls
kustomize edit add with-default-deny-authorization-policy
kubectl apply -k .
```