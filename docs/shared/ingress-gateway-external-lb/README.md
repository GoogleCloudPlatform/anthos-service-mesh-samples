## Set up an external load balancer with an ASM Ingress Gateway 

Follow the guide [here](https://cloud.google.com/service-mesh/docs/external-lb-gateway) for a more detailed explanation.

 This [`ingress-gateway.yaml`](./ingress-gateway.yaml) configures the following resources in the cluster:

- A Kubernetes `ServiceAccount`
- A `Role` with read access to `Secrets`
- A `RoleBinding` associating the created `Role` to the `ServiceAccount`
- A `Deployment` of the **istio-proxy** container configured to run as the **ingress gateway** configuration using the `ServiceAccount` that was created
- A Kubernetes `Service` of type `NodePort` exposing the ingress gateway `Deployment`
- A `PodDisruptionBudget` on the ingress gateway `Deployment` to allow at most 1 `Pod` to be unavailable
- A `HorizontalPodAutoscaler` on the ingress gateway `Deployment` to ensure that the average CPU utilization of the `Pods` is within 80%

