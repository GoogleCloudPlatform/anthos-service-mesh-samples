resource "google_container_cluster" "cluster" {
  name                    = "my-cluster"
  location                = var.zone
  initial_node_count      = 1
  provider                = google-beta
  resource_labels = { mesh_id : "proj-${data.google_project.project.number}" }
  workload_identity_config {
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
  }
}
data "google_project" "project" {
  project_id = var.project_id
}
resource "google_gke_hub_membership" "membership" {
  membership_id = "my-membership"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.cluster.id}"
    }
  }
  provider = google-beta
}

resource "google_gke_hub_feature" "feature" {
  name     = "servicemesh"
  location = "global"

  provider = google-beta
}

resource "google_gke_hub_feature_membership" "feature_member" {
  location   = "global"
  feature    = google_gke_hub_feature.feature.name
  membership = google_gke_hub_membership.membership.membership_id
  mesh {
    management = "MANAGEMENT_AUTOMATIC"
  }
  provider = google-beta
}