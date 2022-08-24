## `Shared`

This folder is dedicated for having the sample applications manifests and Gateway for the Anthos Service Mesh tutorials. The goal of this folder is localize the setup needed for trying out Anthos Service Mesh.

---

## Online Boutique 
The [online-boutique/kubernetes-manifests.yaml](base/all/kubernetes-manifests.yaml) file contains the definition for all the Kubernetes resources required to deploy the [Online Boutique] (https://github.com/GoogleCloudPlatform/microservices-demo) sample application.

### Basic Quickstart 
_Note: This quickstart is for Anthos Service Mesh. The steps outlined below are written for deploying the sample application with Anthos Service Mesh._

1. Follow the steps in this [README.md](../quickstarts/terraform-asm-mcp/README.md) to deploy a GKE Autopilot cluster with Anthos Service Mesh.

1. To deploy the sample application, first create the namespace `onlineboutique`. 
```
kubectl create namespace onlineboutique
```
1. Enable auto-injection in the `onlineboutique` namespace
```
kubectl lable namespace onlineboutique istio-injection=enabled istio.io/rev-
```
1. Deploy Online Boutique in the `onlineboutique` namespace
```
kubectl apply -f online-boutique/kubernetes-manifests.yaml
```
1. Create a namespace for your Gateway 
```
kubectl create namespace asm-ingress
```
1. Enable auto-injection in the `asm-ingress` namespace
```
kubectl label namespace asm-ingress istio-injection=enabled istio.io/rev-
```
1. Deploy your Gateway
```
kubectl apply -f shared/asm-ingress-gateway/ -n asm-ingress
```
1. Obtain the `EXTERNAL-IP` of your gateway
```
kubectl get svc -n asm-ingress
```
1. Access Online Boutique using the `EXTERNAL-IP` from your web browser

## Contributing

To contribute to the source code of Online Boutique itself, please visit the [Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo) repo

For contributions in this repo, please open a pull request against the `main` branch