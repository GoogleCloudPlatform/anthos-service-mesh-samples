## Managed Anthos Service Mesh on GKE with Terraform 

This is a general setup using Terraform for the examples in the `docs` folder. 

The following will set up a GKE cluster with Anthos Service Mesh (ASM) with a _Managed Control Plane_ installed . 

The following services will be required for this: 
* container.googleapis.com
* compute.googleapis.com
* cloudresourcemanager.googlesapis.com
* mesh.cloud.googleapis.com

This Terraform setup will enable these APIs for you.

### Prerequisites
* This tutorial is best suited for [Cloud Shell](https://shell.cloud.google.com), which comes ready with the Google Cloud SDK and Terraform.
*  You can follow this setup with either a [new Google Cloud Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project) or a pre-existing Google Cloud Project. It is recommended to create a new Google Cloud Project, for an easier cleanup.

## Quickstart with Terraform
In your Cloud Shell, follow the steps outlined:
### 1.  Clone this repo and cd to this directory
```
git clone https://github.com/GoogleCloudPlatform/anthos-service-mesh-samples
cd docs/setup
```
### 2. Set your Google Cloud Platform `PROJECT_ID`

Set the `PROJECT_ID` environment variable:

To enable the above services, run the following in your terminal
```
export PROJECT_ID="<YOUR_PROJECT_ID>"

gcloud config set project $PROJECT_ID

```
### 3.  Replace the variables in variables.tfvars with your values
```
# In variables.tfvars
project_id = "<YOUR_PROJECT_ID>"
region = "<REGION>"
zones  = ["<ZONE>"]
```

### 6.  Deploy the Terrform module to set up your ASM on the GKE Cluster
```
terraform init
terraform plan 
terraform apply 
```
Enter `yes` to confirm the Terraform apply step.

You will see the following outputs:

 >  asm_revision: The name of the installed managed ASM revision.          
    wait: An output to use when depending on the ASM installation finishing.

`terraform apply` will take 5 minutes to provision on GCP

## Verify Anthos Service Mesh Installation
### 1.  Verify that your GKE Cluster membership to a `Fleet` was successful 
A **[Fleet](https://cloud.google.com/anthos/multicluster-management/fleets)** is the term used to logically organized clusters and other resources, for easier management of multi-clusters projects. 
```
gcloud container hub memberships list --project $PROJECT_ID
```
### 2. Retrieve your GKE Cluster credentials: 
```
gcloud container clusters get-credentials "asm-cluster-1" --region "us-central1" --project $PROJECT_ID
```
### 3. Inspect your `controlplanerevision` Custom Resource 
```
kubectl describe controlplanerevision asm-managed -n istio-system
```
Ensure the following field: 
* `Conditions` :  `Reason` should be `Provisioned`
#### Congrats! You can now have a GKE + ASM cluster provisioned. You can now check out the sample 

## Cleanup
To cleanup the resources from your GCP project, the easiest is to delete the project that you created for this Setup.
### 1. Navigate to this directory
### 2. Run the following:
```
terraform destroy
```
Follow the CLI prompts to input the variable outputs