# Canary Testing 

### Introduction 
In this example, we will learn how to Traffic Split to performa Canary deployment on [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/)..

In this sample, `productcatalogservice-v2` introduces a 3-second
[latency](https://github.com/GoogleCloudPlatform/microservices-demo/tree/main/src/productcatalogservice#latency-injection) into all server requests. We’ll show how to use Cloud Operations and ASM together to
view the latency difference between the existing `productcatalog` deployment and the slower v2 deployment.

