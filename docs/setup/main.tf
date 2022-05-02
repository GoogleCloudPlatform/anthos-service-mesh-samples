/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  cluster_type = "simple-zonal-asm"
}
resource "null_resource" "previous" {}

resource "time_sleep" "wait_120_seconds" {
  depends_on = [null_resource.previous]

  create_duration = "120s"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

data "google_project" "project" {
  project_id = var.project_id
}

module "gke" {
  depends_on              = [time_sleep.wait_120_seconds, module.asm-vpc]
  source                  = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version                 = "~> 16.0"
  project_id              = var.project_id
  name                    = local.cluster_type
  release_channel         = var.gke_channel
  region                  = var.region
  zones                   = [var.zone]
  network                 = var.vpc
  subnetwork              = var.subnet_name
  ip_range_pods           = "${var.subnet_name}-pod-cidr"
  ip_range_services       = "${var.subnet_name}-svc1-cidr"
  config_connector        = true
  enable_private_endpoint = false
  enable_private_nodes    = true
  master_ipv4_cidr_block  = "172.16.0.0/28"
  cluster_resource_labels = { "mesh_id" : "proj-${data.google_project.project.number}" }
}
module "workload_identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version             = "~> 16.0.1"
  gcp_sa_name         = "cnrmsa"
  cluster_name        = module.gke.name
  name                = "cnrm-controller-manager"
  location            = var.zone
  use_existing_k8s_sa = true
  annotate_k8s_sa     = false
  namespace           = "cnrm-system"
  project_id          = module.enable_google_apis.project_id
  roles               = ["roles/owner"]
}
module "asm-vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 3.0"

  project_id   = var.project_id
  network_name = var.vpc
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name   = var.subnet_name
      subnet_ip     = var.subnet_ip
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    "${var.subnet_name}" = [
      {
        range_name    = "${var.subnet_name}-pod-cidr"
        ip_cidr_range = var.pod_cidr
      },
      {
        range_name    = "${var.subnet_name}-svc1-cidr"
        ip_cidr_range = var.svc1_cidr
      },
      {
        range_name    = "${var.subnet_name}-svc2-cidr"
        ip_cidr_range = var.svc2_cidr
      },
    ]
  }

  firewall_rules = [{
    name        = "allow-all-10"
    description = "Allow Pod to Pod connectivity"
    direction   = "INGRESS"
    ranges      = ["10.0.0.0/8"]
    allow = [{
      protocol = "tcp"
      ports    = ["0-65535"]
    }]
  }]
}
module "enable_google_apis" {
  source     = "terraform-google-modules/project-factory/google//modules/project_services"
  version    = "11.2.3"
  project_id = var.project_id
  activate_apis = [
    "cloudapis.googleapis.com",
    "compute.googleapis.com",
    "anthos.googleapis.com",
    "mesh.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
  disable_services_on_destroy = false
  depends_on                  = [null_resource.previous]

}

resource "google_gke_hub_membership" "membership" {
  provider = google-beta

  membership_id = "membership-${module.gke.name}"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${module.gke.cluster_id}"
    }
  }
  depends_on = [module.gke.name, module.enable_google_apis]
}
resource "null_resource" "enable_mesh" {
  provisioner "local-exec" {
    when    = create
    command = "echo y | gcloud container hub mesh enable --project ${var.project_id}"
  }

  depends_on = [module.enable_google_apis]
}

module "asm" {
  source           = "git::https://github.com/terraform-google-modules/terraform-google-kubernetes-engine.git//modules/asm?ref=v20.0.0"
  project_id       = module.enable_google_apis.project_id
  cluster_name     = module.gke.name
  cluster_location = var.region
  enable_cni       = true
}