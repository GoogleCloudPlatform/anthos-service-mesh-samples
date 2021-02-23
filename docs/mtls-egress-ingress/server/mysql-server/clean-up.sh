DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../set-project-and-cluster-server.sh

kubectl delete --ignore-not-found=true -n istio-system secret mysql-credential

# todo remove ingress patch
kubectl delete --ignore-not-found=true gateway mysql-gateway
kubectl delete --ignore-not-found=true virtualservice mysql-virtual-service

kubectl delete --ignore-not-found=true service mysql
kubectl delete --ignore-not-found=true deploy mysql
kubectl delete --ignore-not-found=true pvc mysql-pv-claim
