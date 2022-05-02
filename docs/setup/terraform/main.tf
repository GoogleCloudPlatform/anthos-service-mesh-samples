# Resource to create Fleet memebership for the GKE cluster
resource "google_gke_hub_membership" "membership" {
  provider      = google-beta
  
  membership_id = "membership-hub-${module.gke.name}"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${module.gke.cluster_id}"
    }
  }
  depends_on = [module.gke.name, module.enabled_google_apis.activate_apis] 
}

# Module to install ASM on the GKE cluster
module "asm" {
  source = "git::https://github.com/terraform-google-modules/terraform-google-kubernetes-engine.git//modules/asm?ref=v20.0.0"
  cluster_name     = module.gke.name
  cluster_location = var.region
  project_id = module.enabled_google_apis.project_id
  enable_cni = var.enable_cni
}
