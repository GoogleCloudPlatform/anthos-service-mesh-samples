The following scripts can be used for troubleshooting your setup

```
export CERTS_ROOT="../certs"

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')

# url of the external service
export SERVICE_URL="$INGRESS_HOST.nip.io"

export MYSQL_SECURE_PORT="16443"

################ GET LOGS ################
# get logs for istio-egressgateway
kubectl logs -n istio-system -l app=istio-egressgateway -f

# get logs for istio-proxy running inside sleep
kubectl logs -l app=sleep -c istio-proxy -f

################ ATTACH ################
# attach to sleep pod
kubectl exec -it "$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name})" -c sleep -- /bin/sh

# attach to istio-egressgateway
kubectl exec -it -n istio-system "$(kubectl get pod -n istio-system -l app=istio-egressgateway -o jsonpath={.items..metadata.name})" \
  -- /bin/bash

################ CURL ################
# curl with certs from istio-egressgateway
kubectl exec -it -n istio-system "$(kubectl get pod -n istio-system -l app=istio-egressgateway -o jsonpath={.items..metadata.name})" \
 -- curl -v \
 --cacert /etc/istio/httpbin-ca-certs/ca-chain.cert.pem \
 --cert /etc/istio/httpbin-client-certs/tls.crt \
 --key /etc/istio/httpbin-client-certs/tls.key \
 https://$SERVICE_URL/status/418

# curl without certificat
kubectl exec -it "$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name})" -c sleep \
  -- curl -v http://$SERVICE_URL/status/418

# curl via alias
kubectl exec -it "$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name})" -c sleep \
  -- curl -v httpbin-external/status/418

# curl from local with the certificates
curl https://$SERVICE_URL/status/418 \
  --cacert $CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem \
  --cert $CERTS_ROOT/4_client/certs/$SERVICE_URL.cert.pem \
  --key $CERTS_ROOT/4_client/private/$SERVICE_URL.key.pem

curl https://$SERVICE_URL:$MYSQL_SECURE_PORT \
  --cacert $CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem \
  --cert $CERTS_ROOT/4_client/certs/$SERVICE_URL.cert.pem \
  --key $CERTS_ROOT/4_client/private/$SERVICE_URL.key.pem

echo "curl -vvv https://$SERVICE_URL:$MYSQL_SECURE_PORT \
  --cacert $CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem \
  --cert $CERTS_ROOT/4_client/certs/$SERVICE_URL.cert.pem \
  --key $CERTS_ROOT/4_client/private/$SERVICE_URL.key.pem"

echo "curl -vvv https://$SERVICE_URL:$MYSQL_SECURE_PORT \
  --cacert /etc/istio/mysql-ca-certs/ca-chain.cert.pem \
  --cert /etc/istio/mysql-client-certs/tls.crt \
  --key /etc/istio/mysql-client-certs/tls.key"

kubectl --context gke_jsolarz-sandbox_us-central1-c_client-cluster run -it \
  --image=mysql:5.6 mysql-client --restart=Never --rm -- /bin/bash

kubectl --context gke_jsolarz-sandbox_us-central1-c_client-cluster run -it \
  --image=mysql:5.6 mysql-client --restart=Never --rm -- mysql -h 35.239.250.140.nip.io -pyougottoknowme
```