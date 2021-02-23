DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$DIR/../set-project-and-cluster-client.sh

# todo cleanup cleanup.sh :D
kubectl delete --ignore-not-found=true secret mysql-client-certs mysql-ca-certs
kubectl delete --ignore-not-found=true secret mysql-client-certs mysql-ca-certs -n istio-system

kubectl delete --ignore-not-found=true gateway istio-egressgateway-mysql
kubectl delete --ignore-not-found=true destinationrule egressgateway-for-mysql

kubectl delete --ignore-not-found=true virtualservice direct-mysql-through-egress-gateway
kubectl delete --ignore-not-found=true destinationrule originate-mtls-for-mysql

kubectl delete --ignore-not-found=true serviceentry mysql-external