DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$DIR/../set-project-and-cluster-client.sh

kubectl delete --ignore-not-found=true secret httpbin-server-certs httpbin-ca-certs -n mesh-external
kubectl delete --ignore-not-found=true secret httpbin-client-certs httpbin-ca-certs
kubectl delete --ignore-not-found=true secret httpbin-client-certs httpbin-ca-certs -n istio-system

kubectl delete --ignore-not-found=true service httpbin-external
kubectl delete --ignore-not-found=true virtualservice vs-alias
kubectl delete --ignore-not-found=true gateway istio-egressgateway-httpbin
kubectl delete --ignore-not-found=true serviceentry httpbin-serviceentry
kubectl delete --ignore-not-found=true virtualservice direct-httpbin-through-egress-gateway
kubectl delete --ignore-not-found=true destinationrule originate-mtls-for-httpbin
kubectl delete --ignore-not-found=true destinationrule egressgateway-for-httpbin
kubectl delete --ignore-not-found=true svc sleep
kubectl delete --ignore-not-found=true deployment sleep