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

provider "helm" {
  kubernetes {
    host  = "https://${data.google_container_cluster.my_cluster.endpoint}"
    token = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
    )
  }
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.64.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0.1"
    }
  }

  required_version = "~> 0.14"
}