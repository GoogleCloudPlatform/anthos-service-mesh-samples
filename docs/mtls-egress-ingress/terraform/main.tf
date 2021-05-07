/**
 * Copyright 2018 Google LLC
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

terraform {
  required_version = ">= 0.13.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version =  ">= 3.52.0"
    }
  }
}
     
provider "google" {
  region  = var.region
}

locals {
  client_cluster_name   = "client-cluster"
  client_cluster_subnet = "client-cluster-subnet"

  server_cluster_name   = "server-cluster"
  server_cluster_subnet = "server-cluster-subnet"

  # the vpc_name is currently hardcoded in the FW destroy
  # due to no variable usage in provisioners
  vpc_name              = "example-vpc"
}

data "google_project" "project" {
  project_id = var.project_id
}

module "vpc" {

  source = "terraform-google-modules/network/google"

  project_id = var.project_id
  network_name = local.vpc_name

  subnets = [
    {
      subnet_name = local.client_cluster_subnet
      subnet_ip = "10.10.0.0/16"
      subnet_region = var.region
    },
    {
      subnet_name = local.server_cluster_subnet
      subnet_ip = "10.20.0.0/16"
      subnet_region = var.region
    }
  ]

  secondary_ranges = {
    "${local.client_cluster_subnet}" = [
      {
        range_name    = "${local.client_cluster_subnet}-pods"
        ip_cidr_range = "192.168.0.0/21"
      },
      {
        range_name    = "${local.client_cluster_subnet}-services"
        ip_cidr_range = "192.168.8.0/21"
      }
    ]

    "${local.server_cluster_subnet}" = [
      {
        range_name    = "${local.server_cluster_subnet}-pods"
        ip_cidr_range = "192.168.16.0/21"
      },
      {
        range_name    = "${local.server_cluster_subnet}-services"
        ip_cidr_range = "192.168.24.0/21"
      }
    ]
  }

}

# client cluster

module "client-cluster" {
  source                  = "terraform-google-modules/kubernetes-engine/google//"
  project_id              = var.project_id
  name                    = local.client_cluster_name
  regional                = false
  region                  = var.region
  zones                   = var.zones
  release_channel         = "REGULAR"
  network                 = module.vpc.network_name
  subnetwork              = length(module.vpc.subnets_names) > 0 ? module.vpc.subnets_names[0] : local.client_cluster_subnet
  ip_range_pods           = "${local.client_cluster_subnet}-pods"
  ip_range_services       = "${local.client_cluster_subnet}-services"
  network_policy          = false
  cluster_resource_labels = { "mesh_id" : "proj-${data.google_project.project.number}" }
  node_pools = [
    {
      name         = "asm-node-pool"
      autoscaling  = false
      auto_upgrade = true
      # ASM requires minimum 4 nodes and e2-standard-4
      node_count   = 4
      machine_type = "e2-standard-4"
    },
  ]
}

resource "null_resource" "client-cluster-asm" {

  depends_on = [module.client-cluster]

  provisioner "local-exec" {
    command = <<EOF
unset KUBECONFIG
../client/set-project-and-cluster-client.sh
./install_asm.sh
EOF
    environment = {
      PROJECT_ID = var.project_id
      ZONE = var.zones[0]
      TYPE = "client"
      TERRAFORM_ROOT = abspath(path.root)
      ASM_VERSION    = "1.9.3-asm.2"
      ASM_REVISION   = "193-2"
    }
  }
}

data "google_client_config" "default" {
}

# destroy gke fw rules, otherwise you can not delete the vpc
resource "null_resource" "delete_gke_fw_rules" {

  depends_on = [module.vpc]

  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
gcloud compute firewall-rules list --filter='name=example_vpc' \
  --format='value(name)' | xargs -I {} gcloud compute firewall-rules delete {} -q
EOF
  }
}

# kOps / Server Cluster
data "template_file" "install-kops" {
    template = file("kops-src/cluster/a_install-kops.sh")
    vars = {
       project = var.project_id
    }
} 

data "template_file" "kops-create" {
    template = file("kops-src/cluster/b_create-kops-cluster.sh")
    vars = {
      project = var.project_id
      zone = var.zones[0]
      kops-gce = var.kops-gce
    }
}
data "template_file" "kops-register" {
    template = file("kops-src/cluster/c_register.sh")
    vars = {
      project = var.project_id
      location = path.root 
    }
  } 

# When = destroy - delete bucket
resource "null_resource" "kops-cluster-destroy" {
  triggers = {
    prdestroy = var.project_id
  }
  provisioner "local-exec" {
    when = destroy
    command = <<EOF
./kops delete cluster server-cluster.k8s.local --yes --state=gs://${self.triggers.prdestroy}-kops-clusters
gcloud container hub memberships delete server-cluster --quiet
gsutil rm -r gs://${self.triggers.prdestroy}-kops-clusters
EOF
  }
}

resource "local_file" "kops-install" {
  depends_on = [data.template_file.install-kops]
  # render install file with TF vars
  # TODO use Terraform path variables to render / local-exec files e.g. file("${path.module}/hello.txt")
  content     = data.template_file.install-kops.rendered
  filename = "/tmp/install-kops.sh"
  # download and deploy kops
  provisioner "local-exec" {
    command = "/tmp/install-kops.sh"
  }
}

resource "local_file" "kops-create-cluster" {
  depends_on = [data.template_file.kops-create, local_file.kops-install]
  # render create script with TF vars
  content     = data.template_file.kops-create.rendered
  filename = "/tmp/create-kops-cluster.sh"
# download and deploy kops
  provisioner "local-exec" {
    command = "/tmp/create-kops-cluster.sh"
  }
}

resource "time_sleep" "wait_for_kops_startup" {
  depends_on = [local_file.kops-create-cluster]

  create_duration = "4m"
}

resource "local_file" "kops-register-cluster" {
  depends_on = [time_sleep.wait_for_kops_startup, data.template_file.kops-register, local_file.kops-create-cluster]
  # render register script with TF vars
  content     = data.template_file.kops-register.rendered
  filename = "/tmp/register.sh"
  # download and deploy kops
  provisioner "local-exec" {
    command = "/tmp/register.sh"
  }
}

resource "null_resource" "server-cluster-asm" {

  depends_on = [local_file.kops-register-cluster]

  provisioner "local-exec" {
    command = <<EOF
export KUBECONFIG="$TERRAFORM_ROOT/server-kubeconfig"
./install_asm.sh
unset KUBECONFIG
EOF
    environment = {
      PROJECT_ID = var.project_id
      ZONE = var.zones[0]
      TYPE = "server"
      TERRAFORM_ROOT = abspath(path.root)
      ASM_VERSION    = "1.9.3-asm.2"
      ASM_REVISION   = "193-2"
    }
  }
}

# output the token into output vars
data "local_file" "kops_token" {
  depends_on = [local_file.kops-register-cluster]
  filename = "server-cluster-ksa.token"
}
