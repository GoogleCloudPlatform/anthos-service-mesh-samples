DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/./set-project-and-cluster-server.sh

kubectl logs -n istio-system "$(kubectl get pod -l istio=ingressgateway \
-n istio-system -o jsonpath='{.items[0].metadata.name}')" -f