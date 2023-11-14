# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "google_container_cluster" "cluster" {
  name                = "asm-cluster"
  location            = var.zone
  initial_node_count  = 1
  resource_labels     = { mesh_id : "proj-${data.google_project.project.number}" }
  deletion_protection = false # Warning: Do not set deletion_protection to false for production clusters
  workload_identity_config {
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
  }
  node_config {
    machine_type = "e2-standard-4"
  }
  depends_on = [
    google_project_service.project
  ]
}

data "google_project" "project" {}

resource "google_gke_hub_membership" "membership" {
  membership_id = "my-membership"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.cluster.id}"
    }
  }
}

resource "google_gke_hub_feature" "feature" {
  name     = "servicemesh"
  location = "global"

  depends_on = [
    google_project_service.project
  ]
}

resource "google_gke_hub_feature_membership" "feature_member" {
  location   = "global"
  feature    = google_gke_hub_feature.feature.name
  membership = google_gke_hub_membership.membership.membership_id
  mesh {
    management = "MANAGEMENT_AUTOMATIC"
  }
}

resource "google_project_service" "project" {
  service = "mesh.googleapis.com"

  disable_dependent_services = true
}
