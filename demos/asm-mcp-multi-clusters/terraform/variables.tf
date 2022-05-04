variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID to apply this config to."
}
variable "gcp_region" {
  type        = string
  description = "The GCP region to apply this config to."
}
variable "gcp_zone" {
  type        = string
  description = "The GCP zone to apply this config to."
}
variable "gcp_user_id" {
  type        = string
  description = "User Id"
}

variable "cluster1" {
  type        = string
  description = "Name of Cluster 1"
  default     = "gke-west2-a"
}

variable "cluster2" {
  type        = string
  description = "Name of Cluster 2"
  default     = "gke-central1-a"
}

variable "cluster_ingress" {
  type        = string
  description = "Name of Ingress Cluster"
  default     = "gke-ingress-west1-a"
}

variable "machine_type" {
  type        = string
  description = "Kubernetes Cluster Node Type"
  default     = "e2-standard-4"
}

variable "cluster1_location" {
  type        = string
  description = "Location of Cluster 1"
  default     = "us-west2-a"
}

variable "cluster2_location" {
  type        = string
  description = "Location of Cluster 2"
  default     = "us-central1-a"
}

variable "cluster_ingress_location" {
  type        = string
  description = "Location of Ingress Cluster"
  default     = "us-west1-a"
}

variable "cluster_node_count" {
  type        = number
  description = "Number of nodes in the GKE Cluster"
  default     = 4
}

variable "service_account_key_file" {
  type        = string
  description = "key file location"
}

variable "apis" {
  description = "List of Google Cloud APIs to be enabled for this lab"
  type        = list(string)
  default = [
    "anthos.googleapis.com",
    "anthosconfigmanagement.googleapis.com",
    "container.googleapis.com",
    "stackdriver.googleapis.com",
    "monitoring.googleapis.com",
    "cloudtrace.googleapis.com",
    "logging.googleapis.com",
    "meshca.googleapis.com",
    "meshtelemetry.googleapis.com",
    "meshconfig.googleapis.com",
    "multiclustermetering.googleapis.com",
    "multiclusteringress.googleapis.com",
    "multiclusterservicediscovery.googleapis.com",
    "iamcredentials.googleapis.com",
    "iam.googleapis.com",
    "gkeconnect.googleapis.com",
    "gkehub.googleapis.com",
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}
