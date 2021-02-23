DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../../server/set-project-and-cluster-server.sh

# !!! WARNING - DO NOT MOVE !!!
# get Ingress IP from server side
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

unset KUBECONFIG

$DIR/../set-project-and-cluster-client.sh

$DIR/./clean-up.sh

# folder where certificates are stored created by mtls-go-example
CERTS_ROOT="$DIR/../../certs"

# url of the external service
SERVICE_URL="$INGRESS_HOST.nip.io"

sed "s/SERVICE_URL/$SERVICE_URL/" gateway-destinationrule-to-egressgateway.yaml.tmpl > gateway-destinationrule-to-egressgateway.yaml
sed "s/SERVICE_URL/$SERVICE_URL/" httpbin-external.yaml.tmpl > httpbin-external.yaml

sed "s/SERVICE_URL/$SERVICE_URL/" service-entry.yaml.tmpl > service-entry.yaml
sed "s/SERVICE_URL/$SERVICE_URL/" virtualservice-destinationrule-from-egressgateway.yaml.tmpl > virtualservice-destinationrule-from-egressgateway.yaml

# we just have a sleep.yaml.tmpl file to ignore *.yaml
sed "s/SERVICE_URL/$SERVICE_URL/" sleep.yaml.tmpl > sleep.yaml

kubectl apply -f httpbin-external.yaml

# add the service entry to the istio registry
kubectl apply -f service-entry.yaml

kubectl create secret tls httpbin-client-certs \
  --key $CERTS_ROOT/4_client/private/${SERVICE_URL}.key.pem \
  --cert $CERTS_ROOT/4_client/certs/${SERVICE_URL}.cert.pem
kubectl create secret generic httpbin-ca-certs \
  --from-file=$CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem

kubectl apply -f sleep.yaml

sleep 10
export SOURCE_POD=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name})
echo $SOURCE_POD

sleep 4
kubectl exec -it $SOURCE_POD -c sleep -- curl -v \
  --cacert /etc/httpbin-ca-certs/ca-chain.cert.pem \
  --cert /etc/httpbin-client-certs/tls.crt \
  --key /etc/httpbin-client-certs/tls.key https://${SERVICE_URL}/status/418

kubectl create secret -n istio-system generic client-credential \
  --from-file=tls.key=$CERTS_ROOT/4_client/private/${SERVICE_URL}.key.pem \
  --from-file=tls.crt=$CERTS_ROOT/4_client/certs/${SERVICE_URL}.cert.pem \
  --from-file=ca.crt=$CERTS_ROOT/2_intermediate/certs/ca-chain.cert.pem

sleep 30

# setup routing for the mysql service inside the mesh
kubectl apply -f gateway-destinationrule-to-egressgateway.yaml

# now activate the virtualservice that does the routing from the pod to the egress-gateway and from the
# egress gateway outside, additionally tell the egress gateway to use the certificates mounted before for
# the outbound traffic (via the destination rule)
kubectl apply -f virtualservice-destinationrule-from-egressgateway.yaml

kubectl exec -it $SOURCE_POD -c sleep -- curl -v http://${SERVICE_URL}/status/418