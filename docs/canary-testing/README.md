# Canary Testing 

## Introduction 
In this example, we will learn how to Traffic Split to performa Canary deployment on [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/)..

In this sample, `productcatalogservice-v2` introduces a 3-second
[latency](https://github.com/GoogleCloudPlatform/microservices-demo/tree/main/src/productcatalogservice#latency-injection) into all server requests. We’ll show how to use Cloud Operations and ASM together to
view the latency difference between the existing `productcatalog` deployment and the slower v2 deployment.

## Prerequisites 
Ensure that you have the prerequisites for running ASM on your GCP Project
https://cloud.google.com/service-mesh/docs/unified-install/anthos-service-mesh-prerequisites
## Setup


## Deploy the sample app
```
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/main/release/kubernetes-manifests.yaml
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/main/release/istio-manifests.yaml
kubectl delete serviceentry allow-egress-google-metadata
kubectl delete serviceentry allow-egress-googleapis
kubectl patch deployments/productcatalogservice -p '{"spec":{"template":{"metadata":{"labels":{"version":"v1"}}}}}'
```
