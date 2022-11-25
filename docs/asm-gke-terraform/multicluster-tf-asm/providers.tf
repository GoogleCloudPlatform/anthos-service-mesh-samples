terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.44.0"
    }
  }
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
