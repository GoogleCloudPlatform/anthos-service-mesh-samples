## Using Config Connector to provision Managed Anthos Service Mesh

### Set up your Config Controller Instance
Set your project ID
```
export PROJECT_ID = <your_project_id>
```

Set your gcloud config project value

```
gcloud config set project $PROJECT_ID 
```

Create a Config Cluster
```
gcloud services enable serviceusage.googleapis.com
```

Enable the APIs for using Config Controller
```
gcloud services enable krmapihosting.googleapis.com \
    container.googleapis.com \
    cloudresourcemanager.googleapis.com
```

Create a Config Controller instance
```
gcloud anthos config controller create CONFIG_CONTROLLER_NAME \
    --location=LOCATION
```
- Replace `CONFIG_CONTROLLER_NAME` and `LOCATION` (for example `us-east1`) with your values

Get the credentials of your Config Controller instance
```
gcloud anthos config controller get-credentials CONFIG_CONTROLLER_NAME \
    --location LOCATION
```

Set the permissions for Config Controller 
```
export SA_EMAIL="$(kubectl get ConfigConnectorContext -n config-control \
    -o jsonpath='{.items[0].spec.googleServiceAccount}' 2> /dev/null)"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member "serviceAccount:${SA_EMAIL}" \
    --role "roles/owner" \
    --project "${PROJECT_ID}"
```

----
