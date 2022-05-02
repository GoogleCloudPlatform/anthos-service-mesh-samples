#Terraform providers to use
terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "3.90.1"
    }
  }
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
