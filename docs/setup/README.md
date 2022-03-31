### Setup 
This is a general setup for the examples in the `docs` folder. 
This setup uses `Terraform` to setup your GKE clusters with ASM installed. 

Note: the following will setup an environment for a single cluster.

The following services will be required for this: 
* container.googleapis.com
* compute.googleapis.com
* cloudresourcemanager.googlesapis.com
* mesh.cloud.googleapis.com

You can follow this setup with either a new Google Cloud Project or a pre-existing Google Cloud Project
### 1.  Clone this repo and cd to this directory
```
git clone https://github.com/GoogleCloudPlatform/anthos-service-mesh-samples
cd docs/setup
```
### 2.  Authenticate yourself with `gcloud`
```
gcloud auth application-default login --no-browser
```
### 3. **[Create a Google Cloud Platform project](https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project)** or use an existing project. 
Set the `PROJECT_ID` environment variable and ensure the Google Kubernetes Engine and Cloud Operations APIs are enabled.

To enable the above services, run the following in your terminal
```
gcloud config set project "<YOUR_PROJECT_ID>"

gcloud --project="<YOUR_PROJECT_ID>" services enable \
container.googleapis.com \
compute.googleapis.com \
cloudresourcemanager.googleapis.com \
mesh.cloud.googleapis.com

```

### 4.  Update the variables in `variables.tfvars` with variables specific to your environment
```
# variables.tfvars file
project_id        = "<YOUR_PROJECT_ID>"
region            = "<REGION>" # ex: "us-east1"
zones             = ["ZONE"]   # ex: ["us-east1-b"]
...

```

### 5.  Deploy the Terrform module to set up your ASM on the GKE Cluster
```
terraform init
terraform plan --var-file="variables.tfvars"
terraform apply --var-file="variables.tfvars"
```

### 6.  Deploy the Terrform module to set up your ASM on the GKE Cluster
> *Note*: When prompted to confirm the Terraform plan, type 'Yes' and enter


You will see the following outputs:

 >  asm_revision: The name of the installed managed ASM revision.          
    wait: An output to use when depending on the ASM installation finishing.

`terraform apply` will take 5 minutes to provision on GCP
### 7.  Verify that your ASM + GKE Cluster are running
Check that your cluster is running with ASM installed
```
kubectl get pods -A
```
You should see an output similar to the following:
```
NAMESPACE     NAME                                                             READY   STATUS    RESTARTS   AGE
kube-system   event-exporter-gke-5479fd58c8-zbstj                              2/2     Running   0          23h
kube-system   fluentbit-gke-5nfnp                                              2/2     Running   0          23h
kube-system   fluentbit-gke-kzfbk                                              2/2     Running   0          23h
kube-system   fluentbit-gke-ttmvh                                              2/2     Running   0          23h
kube-system   gke-metadata-server-97z84                                        1/1     Running   0          23h
kube-system   gke-metadata-server-p6w8n                                        1/1     Running   0          23h
kube-system   gke-metadata-server-v87q6                                        1/1     Running   0          23h
kube-system   gke-metrics-agent-bl5sk                                          1/1     Running   0          23h
kube-system   gke-metrics-agent-j92hk                                          1/1     Running   0          23h
kube-system   gke-metrics-agent-vkwbt                                          1/1     Running   0          23h
kube-system   istio-cni-node-2xdrz                                             2/2     Running   0          23h
kube-system   istio-cni-node-krthc                                             2/2     Running   0          23h
kube-system   istio-cni-node-nw4xz                                             2/2     Running   0          23h
kube-system   konnectivity-agent-autoscaler-ddccb8b95-lsv27                    1/1     Running   0          23h
kube-system   konnectivity-agent-f844bf4db-fl5kv                               1/1     Running   0          23h
kube-system   konnectivity-agent-f844bf4db-ldjbs                               1/1     Running   0          23h
kube-system   konnectivity-agent-f844bf4db-s92qn                               1/1     Running   0          23h
kube-system   kube-dns-697dc8fc8b-rzzf8                                        4/4     Running   0          23h
kube-system   kube-dns-697dc8fc8b-z55ls                                        4/4     Running   0          23h
kube-system   kube-dns-autoscaler-844c9d9448-wmgk6                             1/1     Running   0          23h
kube-system   kube-proxy-gke-simple-zonal-asm-cl-asm-node-pool-37045628-2c3c   1/1     Running   0          23h
kube-system   kube-proxy-gke-simple-zonal-asm-cl-asm-node-pool-37045628-97d4   1/1     Running   0          23h
kube-system   kube-proxy-gke-simple-zonal-asm-cl-asm-node-pool-37045628-lcjl   1/1     Running   0          23h
kube-system   l7-default-backend-69fb9fd9f9-dswkm                              1/1     Running   0          23h
kube-system   metrics-server-v0.4.5-bbb794dcc-ngnl4                            2/2     Running   0          23h
kube-system   netd-54nxz                                                       1/1     Running   0          23h
kube-system   netd-lgglg                                                       1/1     Running   0          23h
kube-system   netd-nr4vv                                                       1/1     Running   0          23h
kube-system   pdcsi-node-dtfbv                                                 2/2     Running   0          23h
kube-system   pdcsi-node-dxc5f                                                 2/2     Running   0          23h
kube-system   pdcsi-node-qfbm2                                                 2/2     Running   0          23h
```

#### Congrats! You can now have a GKE + ASM cluster provisioned. You can now check out the sample 
---
### Cleanup
To cleanup the resources from your GCP project, 
### 1. Navigate to this directory
### 2. Run the following:
```
terraform destroy
```
Follow the CLI prompts to input the variable outputs 

> *Note*: When prompted to confirm the Terraform destroy, type 'Yes' and enter. It may take a few minutes to finish.