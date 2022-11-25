resource "google_container_cluster" "cluster_1" {
  name             = "cluster-1"
  location         = "us-central1"
  enable_autopilot = true
  provider         = google-beta
  resource_labels  = { mesh_id : "proj-${data.google_project.project.number}" }
  ip_allocation_policy {
  }
  node_pool_auto_config {
    network_tags {
      tags = ["node-pool-tag-1"]
    }
  }
}
resource "google_container_cluster" "cluster_2" {
  name     = "cluster-2"
  location = "us-central1"

  enable_autopilot = true
  provider         = google-beta
  resource_labels  = { mesh_id : "proj-${data.google_project.project.number}" }
  ip_allocation_policy {
  }
  node_pool_auto_config {
    network_tags {
      tags = ["node-pool-tag-2"]
    }

  }
}
data "google_project" "project" {
  project_id = var.project_id
}
resource "google_gke_hub_membership" "membership_1" {
  membership_id = "my-membership-1"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.cluster_1.id}"
    }
  }
  provider = google-beta
}
resource "google_gke_hub_membership" "membership_2" {
  membership_id = "my-membership-2"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.cluster_2.id}"
    }
  }
  provider = google-beta
}

resource "google_gke_hub_feature" "feature" {
  name     = "servicemesh"
  location = "global"

  provider = google-beta
}

resource "google_gke_hub_feature_membership" "feature_member_1" {
  location   = "global"
  feature    = google_gke_hub_feature.feature.name
  membership = google_gke_hub_membership.membership_1.membership_id
  mesh {
    management = "MANAGEMENT_AUTOMATIC"
  }
  provider = google-beta
}
resource "google_gke_hub_feature_membership" "feature_member_2" {
  location   = "global"
  feature    = google_gke_hub_feature.feature.name
  membership = google_gke_hub_membership.membership_2.membership_id
  mesh {
    management = "MANAGEMENT_AUTOMATIC"
  }
  provider = google-beta
}

resource "google_compute_firewall" "cross-cluster-rules" {
  project     = data.google_project.project.project_id
  name        = "multicluster-rules"
  network     = "default"
  description = "Allow for cross cluster communication"
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "esp"
  }
  allow {
    protocol = "ah"
  }
  allow {
    protocol = "sctp"
  }

  ## need to figure out how to pull the node network tags from the node pools

  target_tags   = [google_container_cluster.cluster_1.node_pool_auto_config[0].network_tags[0].tags[0], google_container_cluster.cluster_2.node_pool_auto_config[0].network_tags[0].tags[0]]
  priority      = 900
  source_ranges = [google_container_cluster.cluster_1.cluster_ipv4_cidr, google_container_cluster.cluster_2.cluster_ipv4_cidr]
}