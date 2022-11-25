## Managed Anthos Service Mesh on GKE with Terraform 

This is a general setup of a single cluster with Anthos Service Mesh using the native [GKE Hub Terraform resource](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/gke_hub_feature) for the examples in the `docs` folder.

The following will set up a GKE cluster with Anthos Service Mesh (ASM) with a _Managed Control Plane_ installed. 

The following services will be required for this: 
* `mesh.googleapis.com`

### Prerequisites
* This tutorial is best suited for [Cloud Shell](https://shell.cloud.google.com), which comes ready with the Google Cloud SDK and Terraform.
*  You can follow this setup with either a [new Google Cloud Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project) or a pre-existing Google Cloud Project. It is recommended to create a new Google Cloud Project, for an easier cleanup.

## Quickstart with Terraform
In your Cloud Shell, follow the steps outlined:

### 1. Enable the APIs listed above
```
gcloud services enable mesh.googleapis.com
```
### 2.  Clone this repo and cd to this directory
```
git clone https://github.com/GoogleCloudPlatform/anthos-service-mesh-samples
cd anthos-service-mesh-samples/docs/asm-gke-terraform
```
### 3. Set your Google Cloud Platform `PROJECT_ID`

Set the `PROJECT_ID` environment variable:

To enable the above services, run the following in your terminal
```
export PROJECT_ID="<YOUR_PROJECT_ID>"
gcloud config set project $PROJECT_ID
```
### 4.  Create a `variables.tfvars` to set your project ID for Terraform
Run the following command to create a `variables.tfvars` file
```
echo "project_id = \"$PROJECT_ID\"" > terraform.tfvars
```

### 5.  Deploy the Terrform module to set up your ASM on the GKE Cluster
```
terraform init
terraform plan 
terraform apply 
```
Enter `yes` to confirm the Terraform apply step.

`terraform apply` will take a few minutes to provision on GCP

## Verify Anthos Service Mesh Installation
### 1.  Verify that your GKE Cluster membership to a `Fleet` was successful 
A **[Fleet](https://cloud.google.com/anthos/multicluster-management/fleets)** is the term used to logically organized clusters and other resources, for easier management of multi-clusters projects. 
```
gcloud container fleet memberships list --project $PROJECT_ID
```

### 2. Inspect your `controlplanerevision` Custom Resource 
Run the command to check that the Anthos Service Mesh Control Plane has been succesfully enabled in your cluster
```
gcloud container fleet mesh describe
```
The output should be similar to the following. Note that the `description` is set to `Revision(s) ready for use: asm-managed`
```
createTime: '2022-05-03T14:50:35.332895806Z'
membershipStates:
  projects/33137280258/locations/global/memberships/membership-asm-cluster:
    servicemesh:
      controlPlaneManagement:
        state: DISABLED
    state:
      code: OK
      description: 'Revision(s) ready for use: asm-managed.'
      updateTime: '2022-05-03T15:21:29.315122643Z'
name: projects/christineskim-tf-2/locations/global/features/servicemesh
resourceState:
  state: ACTIVE
spec: {}
updateTime: '2022-05-03T15:21:35.952390991Z'
```
### 3. Retrieve your GKE Cluster credentials and review the control plane state: 
```
gcloud container clusters get-credentials "asm-cluster" --region "us-central1" --project $PROJECT_ID
```
Look at the status of your `controlplanerevision` CRD with the following command: 
```
kubectl get controlplanerevisions -n istio-system
```
The output should be similar to: 
```
NAME          RECONCILED   STALLED   AGE
asm-managed   True         False     29m
```
### Congrats! You can now have a GKE + ASM cluster provisioned. 
Look at the other tutorials in this repo to further try out Anthos Service Mesh's capabilities!

## Cleanup
To cleanup the resources from your GCP project, the easiest is to delete the project that you created for this setup.
### 1. Navigate to this directory
### 2. Run the following:
```
terraform destroy
```
Follow the CLI prompts to input the variable outputs