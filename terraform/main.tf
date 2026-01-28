terraform {
  required_version = ">= 1.5"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }

  # GCS backend for Terraform state
  # Backend storage created by: ./scripts/setup-terraform-backend.sh
  
  backend "gcs" {
    bucket = "charged-thought-485008-q7-tfstate"
    prefix = "digitalbank/terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# These providers depend on the GKE cluster being created first
# They will be configured after the cluster is available
provider "kubernetes" {
  host  = length(google_container_cluster.primary.endpoint) > 0 ? "https://${google_container_cluster.primary.endpoint}" : null
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = length(google_container_cluster.primary.master_auth) > 0 ? base64decode(
    google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  ) : null
}

provider "helm" {
  kubernetes {
    host  = length(google_container_cluster.primary.endpoint) > 0 ? "https://${google_container_cluster.primary.endpoint}" : null
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = length(google_container_cluster.primary.master_auth) > 0 ? base64decode(
      google_container_cluster.primary.master_auth[0].cluster_ca_certificate
    ) : null
  }
}

data "google_client_config" "default" {}
