The following scripts can be used for troubleshooting your setup

```
# get logs of ingressgateway
kubectl logs -n istio-system "$(kubectl get pod -l istio=ingressgateway \
-n istio-system -o jsonpath='{.items[0].metadata.name}')" -f

# get logs from httpbin server
kubectl logs -l app=httpbin -c istio-proxy -f

# get logs from mysql server
kubectl logs -l app=mysql -c istio-proxy -f

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')

SERVICE_URL="$INGRESS_HOST.nip.io"
# connect to mysql server
kubectl run -it --image=mysql:5.6 mysql-client --restart=Never --rm -- mysql -h $SERVICE_URL -pyougottoknowme

echo hello | openssl s_client -connect $SERVICE_URL:3306

export CERTS_ROOT="../../httpbin-certs"
curl https://httpbin-mutual-tls.jeremysolarz.app:16443 \
  --cacert $CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem \
  --cert $CERTS_ROOT/4_client/certs/httpbin-mutual-tls.jeremysolarz.app.cert.pem \
  --key $CERTS_ROOT/4_client/private/httpbin-mutual-tls.jeremysolarz.app.key.pem

export CERTS_ROOT="../../mysql-certs"
curl https://mysql-mutual-tls.jeremysolarz.app:13306 \
  --cacert $CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem \
  --cert $CERTS_ROOT/4_client/certs/mysql-mutual-tls.jeremysolarz.app.cert.pem \
  --key $CERTS_ROOT/4_client/private/mysql-mutual-tls.jeremysolarz.app.key.pem

export CERTS_ROOT="../../mysql-eks-certs"
curl https://mysql-mutual-tls-eks.jeremysolarz.app:13306 \
  --cacert $CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem \
  --cert $CERTS_ROOT/4_client/certs/mysql-mutual-tls-eks.jeremysolarz.app.cert.pem \
  --key $CERTS_ROOT/4_client/private/mysql-mutual-tls-eks.jeremysolarz.app.key.pem

# mysql -hmysql-mutual-tls.jeremysolarz.app -pyougottoknowme

## server
create database remote_connection;
use remote_connection;
create table hello_world(text varchar(255));
insert into hello_world(text) values('hello terasky');
insert into hello_world(text) values('hello mambu');

## client
use remote_connection; select * from hello_world;


kubectl --context gke_jsolarz-sandbox_us-central1-c_server-cluster apply -f - <<EOF
apiVersion: "authentication.istio.io/v1alpha1"
kind: "Policy"
metadata:
  name: mysql-nomtls-authn
spec:
  targets:
  - name: mysql    # The name of *your* K8s Service
EOF

kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: mysql-nomtls-peerauthn
spec:
  selector:
    matchLabels:
      app: mysql     # The label of *your* K8s Service
  mtls:
    mode: DISABLE
EOF

kubectl --context gke_jsolarz-sandbox_us-central1-c_server-cluster exec -it -n istio-system \
  "$(kubectl get --context gke_jsolarz-sandbox_us-central1-c_server-cluster pod -l istio=ingressgateway \
  -n istio-system -o jsonpath='{.items[0].metadata.name}')" -- /bin/bash

```