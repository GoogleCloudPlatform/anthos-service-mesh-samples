# Canary Testing 

## Introduction 
Canary Testing is integral with testing when completing upgrades on your cluster.

* In the `canary-service/` folder, we will learn how to Traffic Split to perform a Canary service deployment on [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/) with [Anthos Service Mesh](https://cloud.google.com/service-mesh/docs/overview).
<!-- * In `canary-cp`, we will learn how to safely complete a Control Plane Canary upgrade with ASM  -->
Anthos Service Mesh is Google's fully managed Istio-compliant service mesh. This means that Istio's APIs work with ASM.


In this sample, `productcatalogservice-v2` introduces a 3-second
[latency](https://github.com/GoogleCloudPlatform/microservices-demo/tree/main/src/productcatalogservice#latency-injection) into all server requests. We’ll show how to use Cloud Operations and ASM together to
view the latency difference between the existing `productcatalog` deployment and the slower v2 deployment.

## Prerequisites 
Ensure that you have the prerequisites for running ASM on your GCP Project
https://cloud.google.com/service-mesh/docs/unified-install/anthos-service-mesh-prerequisites
## Setup
There are various methods for setting up your environment with Anthos Service Mesh. For this tutorial, the quickest method is to follow the steps in the `/docs/terraform-asm-mcp` folder in this repo, where you will use **Terraform** to setup the following: 
* a GKE Cluster 
* Anthos Service Mesh with the Managed Control Plane

Make sure you run the [Verify Anthos Service Mesh Installation](https://github.com/GoogleCloudPlatform/anthos-service-mesh-samples/tree/main/docs/terraform-asm-mcp#verify-anthos-service-mesh-installation) before proceeding to the next portion of this tutorial.
## Deploy the sample app 
For this tutorial we will deploy the microservice-demo app. Run the following
```
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/main/release/kubernetes-manifests.yaml
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/main/release/istio-manifests.yaml
kubectl delete serviceentry allow-egress-google-metadata
kubectl delete serviceentry allow-egress-googleapis
```
Add a label `version=v1` to the `productcatalog` deployment by running the following
```
kubectl patch deployments/productcatalogservice -p '{"spec":{"template":{"metadata":{"labels":{"version":"v1"}}}}}'
```
### View your services
Run the following and make sure that your pods are running, with `2/2` in the colunn. This ensures that the pods have been successfully injected with the Envoy proxy
```
kubectl get pods
```
You can also view the sample app by going to the output of the following command to get the `EXTERNAL_IP`
```
kubectl get svc -n istio-system istio-ingressgateway
```

## Deploy v2 of `productcatalog`

Change into the `canary-service` directory
```
cd canary-testing/canary-service
```
Create a DestinationRule for `productcatalogservice`. 
```
kubectl apply -f destination.yaml
```
Deploy a v2 of your `productcatalog`. This `productcatalog` introduces a [latency](canary-service/productcatalog-v2.yaml) in the response time of 3 seconds
```
kubeclt apply -f productcatalog-v2.yaml
```
Check your pods 
```
kubectl get pods
```
Your output should be similar to the following 
```
TO DO FILL IN
```
Check the frontend with your `EXTERNAL_IP`, and you should note that the frontend loads slower periodically.

## Explore in the Anthos Service Mesh UI