# Install ASM with a specific ASM channel with Kustomize

```
ASM_VERSION=asm-managed-rapid
ASM_CHANNEL=rapid
sed -i 's/ASM_VERSION/${ASM_VERSION}/g;s/ASM_CHANNEL/${ASM_CHANNEL}/g' for-asm-channel/kustomization.yaml
kubectl apply -k .
```

Optionally, you could also deploy a default `deny` `AuthorizationPolicy` and mTLS `STRICT` for the entire Mesh:
```
kustomize edit add resource with-strict-mtls
kustomize edit add with-default-deny-authorization-policy
kubectl apply -k .
```