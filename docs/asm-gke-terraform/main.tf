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

# [START servicemesh_tf_create_gke_cluster]
resource "google_container_cluster" "cluster" {
  name                = "asm-cluster"
  location            = var.region
  resource_labels     = { mesh_id : "proj-${data.google_project.project.number}" }
  deletion_protection = false # Warning: Do not set deletion_protection to false for production clusters

  enable_autopilot = true
  fleet {
    project = data.google_project.project.name
  }
}

data "google_project" "project" {}

# [END servicemesh_tf_create_gke_cluster]

# [START servicemesh_tf_configure_fleet]
resource "google_project_service" "mesh_api" {
  service = "mesh.googleapis.com"

  disable_dependent_services = true
}

resource "google_gke_hub_feature" "feature" {
  name     = "servicemesh"
  location = "global"

  depends_on = [
    google_project_service.mesh_api
  ]
}

resource "google_gke_hub_feature_membership" "feature_member" {
  location   = "global"
  feature    = google_gke_hub_feature.feature.name
  membership = google_container_cluster.cluster.fleet.0.membership
  membership_location = google_container_cluster.cluster.location
  mesh {
    management = "MANAGEMENT_AUTOMATIC"
  }
}

# [END servicemesh_tf_configure_fleet]
