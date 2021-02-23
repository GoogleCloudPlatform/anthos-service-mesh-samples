#
SERVER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

gcloud config set project ${PROJECT_ID}

export KUBECONFIG="${SERVER_DIR}/../terraform/server-kubeconfig"