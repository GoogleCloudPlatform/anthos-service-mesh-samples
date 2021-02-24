DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$DIR/../set-project-and-cluster-client.sh

kubectl logs -l app=sleep -c istio-proxy -f