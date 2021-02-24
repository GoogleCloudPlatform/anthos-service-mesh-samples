DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../set-project-and-cluster-server.sh

kubectl delete --ignore-not-found=true gateway gateway-mutual
kubectl delete --ignore-not-found=true virtualservice virtual-service
kubectl delete --ignore-not-found=true -n istio-system secret httpbin-credential \
  httpbin-credential-cacert

kubectl delete --ignore-not-found=true sa httpbin
kubectl delete --ignore-not-found=true service httpbin
kubectl delete --ignore-not-found=true deploy httpbin