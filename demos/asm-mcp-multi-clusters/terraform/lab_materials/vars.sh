
export WORKDIR=~
export PROJECT_ID=$(gcloud info --format='value(config.project)')
export CLUSTER_1=gke-west2-a
export CLUSTER_1_ZONE=us-west2-a
export CLUSTER_2=gke-central1-a
export CLUSTER_2_ZONE=us-central1-a
export CLUSTER_INGRESS=gke-ingress-west1-a
export CLUSTER_INGRESS_ZONE=us-west1-a
export ASM_LABEL=asm-managed
export BANK_OF_ANTHOS_NAMESPACE=bank-of-anthos
export INGRESS_GATEWAY_NAMESPACE=asm-ingress

gcloud config set project ${PROJECT_ID}

ASM_CONTROL_PLANE_METRICS_URL=$(echo "https://console.cloud.google.com/monitoring/metrics-explorer?pageState=%7B%22xyChart%22:%7B%22dataSets%22:%5B%7B%22timeSeriesFilter%22:%7B%22filter%22:%22metric.type%3D%5C%22istio.io%2Fcontrol%2Fproxy_clients%5C%22%20resource.type%3D%5C%22k8s_container%5C%22%20resource.label.%5C%22container_name%5C%22%3D%5C%22cr-asm-managed%5C%22%22,%22minAlignmentPeriod%22:%2260s%22,%22unitOverride%22:%221%22,%22aggregations%22:%5B%7B%22perSeriesAligner%22:%22ALIGN_MEAN%22,%22crossSeriesReducer%22:%22REDUCE_SUM%22,%22groupByFields%22:%5B%22metric.label.%5C%22revision%5C%22%22,%22metric.label.%5C%22proxy_version%5C%22%22%5D%7D,%7B%22crossSeriesReducer%22:%22REDUCE_NONE%22%7D%5D%7D,%22targetAxis%22:%22Y1%22,%22plotType%22:%22LINE%22%7D%5D,%22options%22:%7B%22mode%22:%22COLOR%22%7D,%22constantLines%22:%5B%5D,%22timeshiftDuration%22:%220s%22,%22y1Axis%22:%7B%22label%22:%22y1Axis%22,%22scale%22:%22LINEAR%22%7D%7D,%22isAutoRefresh%22:true,%22timeSelection%22:%7B%22timeRange%22:%221h%22%7D%7D&_ga=2.39844003.1070780175.1650643506-22581792.1650643506")