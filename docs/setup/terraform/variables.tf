#Variables subsitution
variable "project_id" {
  type        = string
  description = "The GCP project where the cluster will be created"
}

variable "region" {
  type        = string
  description = "The GCP region where the cluster will be created"
  default = "us-central1"
}

variable "zone" {
  type        = string
  description = "The GCP zone in the region where the cluster will be created"
  default     = "us-central1-c"
}

variable "vpc" {
  type        = string
  description = "The VPC network where the cluster will be created"
  default     = "asm-tutorial"
}

variable "subnet_name" {
  type        = string
  description = "The subnet where the cluster will be created"
  default = "subnet-01"
}

variable "subnet_ip" {
  type    = string
  default = "10.0.0.0/20"
}

variable "pod_cidr" {
  type        = string
  description = "CIDR range for Pods"
  default = "10.10.0.0/20"
}

variable "svc1_cidr" {
  type        = string
  description = "CIDR range for services"
  default = "10.100.0.0/24"
}

variable "svc2_cidr" {
  type        = string
  description = "CIDR range for services"
  default = "10.100.1.0/24"
}

variable "gke_channel" {
  type = string
  default = "REGULAR"
}

variable "enable_cni" {
  type = bool
  default = "true"
}
