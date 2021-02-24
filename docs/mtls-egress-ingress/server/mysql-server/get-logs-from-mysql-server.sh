DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../set-project-and-cluster-server.sh

kubectl logs -l app=mysql -c istio-proxy -f