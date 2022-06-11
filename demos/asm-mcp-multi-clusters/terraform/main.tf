# Additional Variables
data "google_project" "project_id" {
}


# Enable APIS
module "enable_google_apis" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "13.0.0"
  project_id                  = var.gcp_project_id
  activate_apis               = var.apis
  disable_services_on_destroy = false
}

# Create bucket for lab materials
resource "google_storage_bucket" "lab_materials" {
  name          = var.gcp_project_id
  location      = "US"
  force_destroy = true
}

# GKE Clusters
resource "google_container_cluster" "cluster1" {
  name               = var.cluster1
  location           = var.cluster1_location
  initial_node_count = var.cluster_node_count
  resource_labels    = { "mesh_id" : "proj-${data.google_project.project_id.number}" }
  networking_mode    = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "" // use default values
    services_ipv4_cidr_block = "" // use default values
  }

  node_config {
    machine_type = var.machine_type
    labels = {
      mesh_id = "proj-${data.google_project.project_id.number}"
    }
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]

  }

  release_channel {
    channel = var.cluster_channel
  }

  workload_identity_config {
    workload_pool = "${var.gcp_project_id}.svc.id.goog"
  }

  timeouts {
    create = "30m"
    update = "40m"
  }
  depends_on = [
    module.enable_google_apis
  ]
}

resource "google_container_cluster" "cluster2" {
  name               = var.cluster2
  location           = var.cluster2_location
  initial_node_count = var.cluster_node_count
  resource_labels    = { "mesh_id" : "proj-${data.google_project.project_id.number}" }
  networking_mode    = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "" // use default values
    services_ipv4_cidr_block = "" // use default values
  }

  node_config {
    machine_type = var.machine_type
    labels = {
      mesh_id = "proj-${data.google_project.project_id.number}"
    }
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]

  }

  release_channel {
    channel = var.cluster_channel
  }

  workload_identity_config {
    workload_pool = "${var.gcp_project_id}.svc.id.goog"
  }

  timeouts {
    create = "30m"
    update = "40m"
  }
  depends_on = [
    module.enable_google_apis
  ]
}

resource "google_container_cluster" "cluster_ingress" {
  name               = var.cluster_ingress
  location           = var.cluster_ingress_location
  initial_node_count = var.cluster_node_count
  resource_labels    = { "mesh_id" : "proj-${data.google_project.project_id.number}" }
  networking_mode    = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "" // use default values
    services_ipv4_cidr_block = "" // use default values
  }

  node_config {
    machine_type = var.machine_type
    labels = {
      mesh_id = "proj-${data.google_project.project_id.number}"
    }
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]

  }

  release_channel {
    channel = var.cluster_channel
  }

  workload_identity_config {
    workload_pool = "${var.gcp_project_id}.svc.id.goog"
  }

  timeouts {
    create = "30m"
    update = "40m"
  }
  depends_on = [
    module.enable_google_apis
  ]
}

# Hub Membership
resource "google_gke_hub_membership" "cluster1-membership" {
  membership_id = var.cluster1
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.cluster1.id}"
    }
  }
  authority {
    issuer = "https://container.googleapis.com/v1/${google_container_cluster.cluster1.id}"
  }
  depends_on = [
    module.enable_google_apis,
    google_container_cluster.cluster1
  ]
}

resource "google_gke_hub_membership" "cluster2-membership" {
  membership_id = var.cluster2
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.cluster2.id}"
    }
  }
  authority {
    issuer = "https://container.googleapis.com/v1/${google_container_cluster.cluster2.id}"
  }
  depends_on = [
    module.enable_google_apis,
    google_container_cluster.cluster2
  ]
}

resource "google_gke_hub_membership" "cluster_ingress-membership" {
  membership_id = var.cluster_ingress
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.cluster_ingress.id}"
    }
  }
  authority {
    issuer = "https://container.googleapis.com/v1/${google_container_cluster.cluster_ingress.id}"
  }
  depends_on = [
    module.enable_google_apis,
    google_container_cluster.cluster_ingress
  ]
}


# Install GCloud 
resource "null_resource" "install_gcloud" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "rm -rf /root/google-cloud-sdk; curl https://sdk.cloud.google.com > install.sh; bash install.sh --disable-prompts; source /root/google-cloud-sdk/path.bash.inc; gcloud auth activate-service-account --key-file ${var.service_account_key_file}"
  }
}

# Enable ASM Hub Membership 
resource "google_gke_hub_feature" "mesh" {
  name     = "servicemesh"
  project  = var.gcp_project_id
  location = "global"
  provider = google-beta
  depends_on = [
    module.enable_google_apis
  ]
}
# Enable ACM Hub Membership
resource "google_gke_hub_feature" "configmanagement_acm_feature" {
  name     = "configmanagement"
  location = "global"
  provider = google-beta
  depends_on = [
    module.enable_google_apis
  ]
}

# Create Firewall rules 
resource "google_compute_firewall" "rules" {
  project       = var.gcp_project_id
  name          = "firewall-rule"
  network       = "default"
  direction     = "INGRESS"
  priority      = 900
  source_ranges = ["10.0.0.0/8"]
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
}


# Copy lab materials to storage bucket
resource "null_resource" "prepare_lab" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "source /root/google-cloud-sdk/path.bash.inc; chmod +x ${path.module}/sh/prepare-lab.sh; ${path.module}/sh/prepare-lab.sh"
    environment = {
      PROJECT_ID  = var.gcp_project_id
      MODULE_PATH = path.module
    }
  }
  triggers = {
    build_number = "${timestamp()}"
    script_sha1  = sha1(file("${path.module}/sh/prepare-lab.sh")),
  }
  depends_on = [
    null_resource.install_gcloud,
    google_storage_bucket.lab_materials
  ]
}
