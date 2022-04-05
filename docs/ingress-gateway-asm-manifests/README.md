# Deploy an Ingress Gateway with a specific ASM channel with Kustomize

```
ASM_VERSION=asm-managed-rapid
sed -i "s/ASM_VERSION/${ASM_VERSION}/g" for-asm-channel/kustomization.yaml
kubectl apply -k .
```