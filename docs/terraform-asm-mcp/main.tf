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

module "asm" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/asm"
  version             = "~> 29.0"
  project_id          = module.enable_google_apis.project_id
  cluster_name        = module.gke.name
  cluster_location    = var.region
  channel             = var.asm_channel
  enable_cni          = true
  enable_mesh_feature = true
}