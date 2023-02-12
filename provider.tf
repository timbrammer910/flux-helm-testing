provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "provider" {}

data "google_container_cluster" "my_cluster" {
  name     = "${var.project_id}-cluster"
  location = var.region
  depends_on = [
    google_container_cluster.cluster,
  ]
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.my_cluster.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
  )
}

provider "kubectl" {
  host                   = "https://${data.google_container_cluster.my_cluster.endpoint}"
  cluster_ca_certificate = base64decode(
      data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
    )
  token                  = data.google_client_config.provider.access_token
  load_config_file       = false
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 0.22.3"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }

  required_version = "~> 1.2.2"
}