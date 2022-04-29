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
  source                  = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version                 = "~> 16.0"
  project_id              = var.project_id
  name                    = local.cluster_type
  regional                = false
  region                  = var.region
  zones                   = [var.zone]
  release_channel         = "REGULAR"
  ip_range_pods           = "${var.subnet_name}-pod-cidr"
  ip_range_services       = "${var.subnet_name}-svc1-cidr"
  network_policy          = false
  cluster_resource_labels = { "mesh_id" : "proj-${data.google_project.project.number}" }
  identity_namespace      = "${var.project_id}.svc.id.goog"
  node_pools = [
    {
      name         = "asm-node-pool"
      autoscaling  = false
      auto_upgrade = true
      node_count   = 3
      machine_type = "e2-standard-4"
    },
  ]
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
  source            = "terraform-google-modules/kubernetes-engine/google//modules/asm"
  project_id        = module.enable_google_apis.project_id
  cluster_name      = module.gke.name
  cluster_location  = module.gke.location
  multicluster_mode = "connected"
  enable_cni        = true
}