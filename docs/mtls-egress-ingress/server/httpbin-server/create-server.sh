DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../set-project-and-cluster-server.sh

$DIR/./clean-up.sh

# folder where certificates are stored created by mtls-go-example
CERTS_ROOT="$DIR/../../certs"

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')

# url of the external service
SERVICE_URL="$INGRESS_HOST.nip.io"

kubectl apply -f httpbin.yaml

kubectl create -n istio-system secret generic httpbin-credential \
--from-file=tls.key=$CERTS_ROOT/3_application/private/${SERVICE_URL}.key.pem \
--from-file=tls.crt=$CERTS_ROOT/3_application/certs/${SERVICE_URL}.cert.pem \
--from-file=ca.crt=$CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem

kubectl create -n istio-system secret generic httpbin-credential-cacert \
--from-file=cacert=$CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem

sed "s/SERVICE_URL/$SERVICE_URL/" virtual-service.yaml.tmpl > virtual-service.yaml
sed "s/SERVICE_URL/$SERVICE_URL/" gateway-mutual.yaml.tmpl > gateway-mutual.yaml

kubectl apply -f virtual-service.yaml
kubectl apply -f gateway-mutual.yaml


sleep 30
# jsolarz-sanbox
curl -v -HHost:${SERVICE_URL} --resolve \
  "${SERVICE_URL}:$SECURE_INGRESS_PORT:$INGRESS_HOST" \
  --cacert $CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem \
  --cert $CERTS_ROOT/4_client/certs/${SERVICE_URL}.cert.pem \
  --key $CERTS_ROOT/4_client/private/${SERVICE_URL}.key.pem \
  "https://${SERVICE_URL}:$SECURE_INGRESS_PORT/status/418"

sleep 15
# external
curl -v --cacert $CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem \
  --cert $CERTS_ROOT/4_client/certs/${SERVICE_URL}.cert.pem \
  --key $CERTS_ROOT/4_client/private/${SERVICE_URL}.key.pem \
  "https://${SERVICE_URL}/status/418"