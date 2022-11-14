/**
 * Copyright 2022 Google LLC
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
  version                 = "~> 23.0"
  project_id              = var.project_id
  name                    = "asm-cluster"
  release_channel         = var.gke_channel
  region                  = var.region
  zones                   = [var.zone]
  network                 = var.vpc
  subnetwork              = var.subnet_name
  ip_range_pods           = ""
  ip_range_services       = ""
  config_connector        = false
  enable_private_endpoint = false
  enable_private_nodes    = false
  master_ipv4_cidr_block  = "172.16.0.0/28"
  cluster_resource_labels = { "mesh_id" : "proj-${data.google_project.project.number}" }
  depends_on = [
    module.enable_google_apis
  ]
}
module "enable_google_apis" {
  source     = "terraform-google-modules/project-factory/google//modules/project_services"
  version    = "14.0.0"
  project_id = var.project_id
  activate_apis = [
    "cloudapis.googleapis.com",
    "compute.googleapis.com",
    "anthos.googleapis.com",
    "mesh.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
  disable_services_on_destroy = false
}