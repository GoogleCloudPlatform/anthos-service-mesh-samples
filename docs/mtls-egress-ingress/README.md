[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/vhamburger/anthos-service-mesh-samples/docs&mtls-egress-ingress=README.md&cloudshell_workspace=mtls-egress-ingress/)

*“Copyright 2021 Google LLC. This software is provided as-is, without warranty or representation for any use or purpose.*
*Your use of it is subject to your agreements with Google.”*  
# Mutual-TLS encryption in ASM (via Egress and Ingress)

The following repository should help in setting up mTLS between two clusters via encryption at Egress / Ingress 
gateway.

## Before you begin
 
 - It is best to use a fresh project, especially to test this solution. This will simplify cleanup procedure as well.
   (delete the project once you are done).
 - If you use your local machine
   - Install and initialize the [Cloud SDK](https://cloud.google.com/sdk/docs/quickstarts) (the gcloud command-line tool).
   - Install `git` command line tool.
   - Install `terraform` command line tool.

 - Setup you environment to have PROJECT_ID, REGION and ZONE
   ```
   export PROJECT_ID=YOUR_PROJECT_ID
   export REGION=GCP_REGION
   export ZONE=GCP_ZONE
 
   gcloud config set project ${PROJECT_ID}
   gcloud config set compute/region ${REGION}
   gcloud config set compute/zone ${ZONE}
   ```
 - Enable the APIs needed for the tutorial:
   ```
   gcloud services enable \
     anthos.googleapis.com \
     anthosgke.googleapis.com \
     anthosaudit.googleapis.com \
     compute.googleapis.com \
     container.googleapis.com \
     cloudresourcemanager.googleapis.com \
     serviceusage.googleapis.com \
     stackdriver.googleapis.com \
     monitoring.googleapis.com \
     logging.googleapis.com \
     cloudtrace.googleapis.com \
     meshca.googleapis.com \
     meshtelemetry.googleapis.com \
     meshconfig.googleapis.com \
     iamcredentials.googleapis.com \
     gkeconnect.googleapis.com \
     gkehub.googleapis.com
    ```
  This will enable the Anthos APIs in your Project.
  Running this will create Anthos PAYG costs as describe here: https://cloud.google.com/anthos/pricing
  Deleting all Anthos clusters or the entire project itself will stop charges.

### Alternatives

The deployment of mutial TLS via Ingress <> Egress Gateways was tested with GKE, Anthos on AWS and 
Anthos attached cluster EKS K8s 1.16 as well if you want to have another setup you will need the following.

Setup requirements: 
 - Two Anthos clusters with external internet access 
 - ASM installed on both clusters (tested with version ASM 1.6 - Istio 1.6.8)
   - [Egress via egress gateways](https://cloud.google.com/service-mesh/docs/enable-optional-features#egress_gateways) via optional features enabled
   - [Direct Envoy to stdout](https://cloud.google.com/service-mesh/docs/enable-optional-features#direct_envoy_to_stdout) via optional features enabled 
 - If you want to use an Anthos on AWS cluster, follow 
   [Install GKE on AWS prerequisites](https://cloud.google.com/anthos/gke/docs/aws/how-to/prerequisites#anthos_gke_command-line_tool) / installation.

Note: The KOPS installation used in this solution is for demo purposes and, at the time of writing this, 
not necissarily fully supported by Anthos Service Mesh.
The installation section will use pre-defined scrips from within this repository. If you do not want to use the automatically created 
K8s clusters (GKE and KOPs), these scripts will not work. That means you need to apply the yamls manually and also edit them to include the needed information 
such as the HOST URL (nip.io). 

## Installation

Depending on if you already have two Anthos GKE clusters with ASM installed or not you can skip the next step.

### Client / Server cluster setup via Terraform

1. Change into the terraform folder
   ```
   cd terraform
   ```

1. Create a terraform.tfvars file (based on the environment variables you created before)
   ```
   cat << EOF > terraform.tfvars
   project_id = "${PROJECT_ID}"
   region = "${REGION}"
   zones = ["${ZONE}"]
   EOF
   ```
   This command is using the earlie set environment variables. You may check the created terraform.tfvars file before proceeding, just in 
   case to prevent erros. 

1. Run Terraform to setup client / server cluster. The Command will create two K8s clusters in your project. One is a GKE Cluster and a "native
   GCP Citizen", the other is a KOPs cluster, using GCE VMs to setup. The clusters will be created automatically and registerd into GKE HUB. This means
   both of them will appear under your GKE Clusters menu in the Cloud Console.  

   ```
   terraform init
   terraform plan
   
   terraform apply --auto-approve
   
   cd ..
   ```
Applying the terraform will probably take around 20 Minutes. It will setup everything needed to proceeed with the next steps. For easiness our two clusters
are running in the same project. In order to bring in some friction, the GKE Cluster will run in a differen VPC then the KOPs cluster. That means that nodes in 
those cluster cannot directly communicate with each other (no routing setup either). This is to simulate a different environment. Clusters could also be on two 
different clouds (like AWS or Azure). The procedure would be the same as described here to set it up. 

### ASM Configuration

In the following sections we fill showcase mTLS encryption for both HTTP and TCP endpoints.

As the FQDN name for the Ingress Gateway we use [nip.io](nip.io). Which gives us the possibility to resolve the
Ingress IP as DNS name e.g. 192.168.0.1.nip.io resolves to 192.168.0.1. 
This trick is needed since certificates will requrie FQDN 
names to be issued to. Cert creation with pure IP adresses will not work. It might look strange, but the nip.io address is actually a 
proper globally resolveable DNS entry - and it comes with zero cost!

First you need to create the certificates for client / server endpoints. The following command will:

 - Clone a [git repository](https://github.com/nicholasjackson/mtls-go-example). 
 - Use the repository to start key file generation.
 - Generation a new directory (./certs) with the keys will be created. 

The create-keys.sh command will also do the repo cloing once executed, simply run:

```
./create-keys.sh
```

Make sure you pick a secure password when running, even though this is only for testing. 


*Note:*
Client / Server certificates will be created with [mtls-go-example](https://github.com/nicholasjackson/mtls-go-example)
and are expected to be in a fixed location. If you have already your own certificates you need to copy them in the right 
locations.

```
./certs/2_intermediate/certs/ca-chain.cert.pem
./certs/4_client/private/<YOUR_SERVICE_URL>.key.pem
./certs/4_client/certs/<YOUR_SERVICE_URL>.cert.pem 
``` 

### Create client / server (HTTP & MySQL)

#### HTTP encryption with HttpBin   

In the following sections you will deploy a httpbin server on the server cluster and a sleeper pod (curl capable) on the client 
cluster. Encrypted communication (HTTPS) will happen transparently for client / server via Egress / Ingress Gateways.

##### Create the server side

```
cd server/httpbin-server
./create-server.sh
```               

After running the above command you should see two test calls for httpbin/status/418 e.g. the Teapod service resulting in
a output like this.

```
    -=[ teapot ]=-

       _...._
     .'  _ _ `.
    | ."` ^ `". _,
    \_;`"---"`|//
      |       ;/
      \_     _/
        `"""`
```

Now as a final check see if the sidecar proxy was injected properly into the server.

Run using the kubeconfig of the generated kops cluster
```
kubectl --kubeconfig "../../terraform/server-kubeconfig" get pods -n default
```

You should see output similar to this:

```
NAME                       READY   STATUS    RESTARTS   AGE
httpbin-779c54bf49-4tg9h   2/2     Running   0          71s
```

Go back to the root directory.

```
cd ../..
```               

##### Create the client side

The client creates a sleeper pod (`image: tutum/curl) that calls the httpbin server side.

```
cd client/httpbin-client
./create-client.sh
```               

Go back to the root directory.

```
cd ../..
```     

The `create-client.sh` command automatically runs some checks that the setup works. E.g. 
`curl -v http://${SERVICE_URL}/status/418` from the "sleeper" pod.

If you want to test for yourself you can connect to the sleeper pod (make sure your cluster context is set to the client cluster).

```
kubectl exec deploy/sleep -it -- /bin/bash
```

Once you have connected to the sleeper pod you can also run a check via it's alias name

```
curl -v http://httpbin-external/status/418
```

Exit from the sleeper pod

```
exit
```

### Bonus / Troubleshooting

To peek behind the curtain on what's actually going on between client and server you can use the following helper scripts:

#### Client

Show the proxy logs of the sleeper pod:

`client/httpbin-client/get-logs-from-sleep-proxy.sh`

Show the logs of the egress proxy:

`client/get-logs-from-egress.sh`

#### Server

Show the logs of the ingress proxy:

`server/get-logs-from-ingress.sh`


#### TCP encryption with MySQL

##### Create the server side.
This section describes on how to transparentyl add encrypton between a mysql client, running on the client cluster and 
a mysql DB, running on the server cluster. Client and DB are unaware of encryption and accept connections on the standard mysql port (3306).
To begin, start with installing the mysql DB onot the server cluster:

```
cd server/mysql-server
./create-server.sh
```               

Now as a final check see if the sidecar proxy was injected properly into the server:
```
kubectl --kubeconfig "../../terraform/server-kubeconfig" get pods -n default
```

You should see output similar to this:
```
NAME                       READY   STATUS    RESTARTS   AGE
mysql-5bf4c56867-sjs7m   2/2     Running   0          71s
```
The "2/2" means that there are actually 2 containers running in that pod. If you want to do further cecks that this is the porxy container,
you could use the following command:
```
kubectl --kubeconfig "../../terraform/server-kubeconfig" describe pod -l app=mysql
```

The output will look similar to this. 

```
...  
Containers:
  mysql:
      Container ID:   docker://175c29c47e6816986be02d3b912ec1000d36bd2d241f1ff7e1f9794b5a73654b
      Image:          mysql:5.6
      Image ID:       docker-pullable://mysql@sha256:51d59639d9a864ec302008c81d6909c532eff8b946993ef6448c086ba7917e82
      Port:           3306/TCP
      Host Port:      0/TCP
      State:          Running
        Started:      Thu, 07 Jan 2021 22:52:03 +0100
      Ready:          True
      Restart Count:  0
      Requests:
        cpu:  100m
      Environment:
        MYSQL_ROOT_PASSWORD:  yougottoknowme
      Mounts:
        /var/lib/mysql from mysql-persistent-storage (rw)
        /var/run/secrets/kubernetes.io/serviceaccount from default-token-5msqg (ro)
    istio-proxy:
      Container ID:  docker://3b67b4d04fd36f67f38e56fdabd52232c6ddc5ad4351873737f285b751b191b6
      Image:         gcr.io/gke-release/asm/proxyv2:1.6.11-asm.1
      Image ID:      docker-pullable://gcr.io/gke-release/asm/proxyv2@sha256:3d690b4bb3f3b8c7069ae650cfac23b433d6de16121e136b6d55e7e891cb1f3e
      Port:          15090/TCP
      Host Port:     0/TCP
...
```
At the "Containers" section (cut out), you will notice that there is a second container called "istio-proxy". This is 
the automatically injected Envoy proxy. 

Go back to the root directory.

```
cd ../..
```         

After running the above command you should 

##### Create the client side.
```
cd client/mysql-client
./create-client.sh
```   

##### Test the mysql communication

###### Test the client side
Once the ASM setup has been completed, it is time to thest the functionality. This can be easiyl done
by starting a mysql client container in the default namespace. However, before the tests we need to 
read out the fqdn of our mysql server. This is best done by inspecting the Service Entry, created earlier:
````
kubectl get se
````
You should see an output similar to this:
```
NAME             HOSTS                     LOCATION        RESOLUTION   AGE
mysql-external   [35.239.250.140.nip.io]   MESH_EXTERNAL   DNS          56s
```
Note the HOSTS field - this is our FQDN for the mysql DB Server. Since we are using nip.io for this solution, you 
will see the public IP address in front of .nip.io. Normally this would be something linke mysql.acme.com or similar. 

Now, that we know the MySQL FQDN we can start a container and us the DB connection:

```
kubectl run -it --image=mysql:5.6 mysql-client --restart=Never --rm -- /bin/bash
```
Once the container has started we are presented with a shell which should look something like this:
```
root@mysql-client:/# 
```
To connect to our MySQL server, run the following command (remember to use the HOST FQDN from the earlier query):

```
mysql -pyougottoknowme -h 35.239.250.140.nip.io
```

If all is well, this should greet us with the following dialog:

```
Warning: Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 7
Server version: 5.6.50 MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
```

Once we are in, lets create a database and some records. Anyhow, this means the established connection between these two clusters 
using a mysql protocul via standard ports (3306) is already encrypted. This is transparent to the mysql protocol though!
Use these commands to write to your MySQL DB:
```
CREATE DATABASE encrypted;
USE encrypted;
CREATE TABLE message (id INT, content VARCHAR(20));
INSERT INTO message (id,content) VALUES(1,"Crypto Hi");
```

This should have added a database with a new table calld "messages". Within this table we left our "mark" by inserting the "Crypto Hi" enty.
To fiew your entry, issue the following command:

```
SELECT * FROM message;

mysql> SELECT * FROM message;
+------+-----------+
| id   | content   |
+------+-----------+
|    1 | Crypto Hi |
+------+-----------+
1 row in set (0.00 sec)
EXIT;
```
Now we know the client can communicate with the sever. To be 100% sure it is the server we have added the DB to, we can do a reverse proof. 
Lets log into the server pod directly and check the database locally.
First we need to close the client. To leave mysql client pod type `exit` followed by CTRL-C to close the container connection.

###### Test the server side
To see the mysql container on the server side run the following command:

```
kubectl --kubeconfig "../../terraform/server-kubeconfig" get pods -n default
NAME                     READY   STATUS    RESTARTS   AGE
mysql-757844b949-9lzst   2/2     Running   0          57m
```
Note the name, it is needed for the connect command. 

To log into the container shell directly use this (your DB pod will have a different name!):

```
kubectl --kubeconfig "../../terraform/server-kubeconfig" exec mysql-757844b949-9lzst -ti -- /bin/bash
```

Once you are in the terminal, just use the good old MySQL commandline to query the local database:

```
mysql -pyougottoknowme
USE use encrypted;
SELECT * from message;
+------+-----------+
| id   | content   |
+------+-----------+
|    1 | Crypto Hi |
+------+-----------+
1 row in set (0.00 sec)

EXIT;
exit
```
Good - so now we connected locally (no -h for host) to the mysql DB and checked the newly created DB, table and record. 
All looks good. 

##### Bonus: final encryption test
Fine, we have witnessed that it works when using a pod in the default namespace with Istio injeciton enabled. But
what about a pod that has no istio sidecare injection. Can we reach the DB from such a container too? (spoiler alert: No)

Here is how to test this:
```
kubectl create ns unencrypted
kubectl run -it --image=mysql:5.6 mysql-client -n unencrypted --restart=Never --rm -- /bin/bash
```

Once you are on the shell, try connectiong to the Database:
```
mysql -pyougottoknowme -h 35.239.250.140.nip.io
Warning: Using a password on the command line interface can be insecure.
ERROR 2003 (HY000): Can't connect to MySQL server on '35.239.250.140.nip.io' (110)
```
You see that a connection is not possible. The Server is not even responding. Now you might think this is because this pod 
from this "unsecure" namespace cannot resolve the FQDN of the DB host, but this is actually not the case:
```
resolveip 35.239.250.140.nip.io
IP address of 35.239.250.140.nip.io is 35.239.250.140
```

As we see, the nip.io service is resolved fine to its real IP. 
This means, since our "unsecure" pod has no istio sidecar proxy deployed, which would allow it to use the gateway which takes
care of encapsulating the mysql call in an encrypted communication, the MySQL server cannot be reached. 
You can exit the pod - notice it will be deleted automatically once you exit the shell. 


#### MySQL Summary

After concluding these steps you have successfully:
- Created two K8s Clusters (Server and Client Side)
- Setup ASM on both clusters with different mesh internal certificates
- Setup Ingress (Server) and Egress (Client) Gateways using pre-created Certificates
- Create and setup destination rules, service entrys and gateway patechs to ensure an encrypted
  communication between client and server cluster. Fully transparent for the client (mysql standard port 3306)
- Tested communication from outside the mesh ("unencrypted") which led to failure (as expected!)

The beauty about this solution is that this works between two service meshes, but also between a service mesh and another 
provider which supports mTLS encryption. Those could be payment, financial services or other transactions which require extra tight security.
The Certificate for these connections can be handled outside of the mesh - this means fewer changes if Certs need to be renewed. 

This concludes this Readme - enjoy using this examplary repo for your own testing, learning and success with Anthos Service Mesh!
