# ----------------------------
# Enable required APIs
# ----------------------------
resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "kubernetes_api" {
  service = "container.googleapis.com"
  disable_on_destroy = false
}

# ----------------------------
# VPC Network
# ----------------------------
resource "google_compute_network" "vpc" {
  depends_on = [google_project_service.compute_api, google_project_service.kubernetes_api]
  name                    = "${var.project_prefix}-vpc"
  auto_create_subnetworks = false
  description             = "VPC for GKE Autopilot and Atlantis"
}


# ----------------------------
# Subnetwork
# ----------------------------
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_prefix}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  description   = "Subnetwork for GKE Autopilot cluster"
}

# ----------------------------
# GKE Autopilot Cluster
# ----------------------------
resource "google_container_cluster" "autopilot" {
  name     = var.cluster_name
  location = var.region
  deletion_protection = false

  enable_autopilot = true

  release_channel {
    channel = "REGULAR"
  }

  network    = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.subnet.self_link

  ip_allocation_policy {}
}

resource "google_gke_hub_membership" "membership" {
  membership_id = var.cluster_name
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/projects/${var.project_id}/locations/${var.region}/clusters/${google_container_cluster.autopilot.name}"
    }
  }
}

resource "google_gke_hub_feature" "configmanagement" {
  name     = "configmanagement"
  location = var.region
}

resource "google_gke_hub_feature_membership" "configmanagement" {
  feature    = google_gke_hub_feature.configmanagement.name
  membership = google_gke_hub_membership.membership.name
  location   = var.region

  configmanagement {
    config_sync {
      source_format = "unstructured"
      enabled = true
      git {
        sync_repo   = var.config_sync_repo_url
        sync_branch = var.config_sync_branch
        policy_dir  = "rendered/${var.cluster_name}"
        secret_type = "none"
      }
    }
  }
}


