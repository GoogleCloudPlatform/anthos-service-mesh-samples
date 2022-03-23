### Setup 
This is a general setup for the examples in the `docs` folder. 
This setup uses `Terraform` to setup your GKE clusters with ASM installed. 

Note: the following will setup an environment for a single cluster.

The following services will be required for this: 
* container.googleapis.com
* compute.googleapis.com
* cloudresourcemanager.googlesapis.com

To enable the above services, run the following in your terminal
```
gcloud config set project "<YOUR_PROJECT_ID>"

gcloud --project="<YOUR_PROJECT_ID>" services enable \
container.googleapis.com \
compute.googleapis.com \
cloudresourcemanager.googleapis.com

```

### Setup Terraform authentication
```
gcloud auth application-default login --no-browser
```