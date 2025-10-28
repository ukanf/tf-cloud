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

resource "google_project_service" "gke_hub_api" {
  service = "gkehub.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "acm_api" {
  service = "anthosconfigmanagement.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "artifact_registry_api" {
  service = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

# ----------------------------
# VPC Network
# ----------------------------
resource "google_compute_network" "vpc" {
  depends_on = [google_project_service.compute_api, google_project_service.kubernetes_api, google_project_service.gke_hub_api, google_project_service.acm_api]
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
  region        = var.cluster_region
  network       = google_compute_network.vpc.id
  description   = "Subnetwork for GKE Autopilot cluster"
}

# ----------------------------
# GKE Autopilot Cluster
# ----------------------------
resource "google_container_cluster" "autopilot" {
  depends_on = [
    google_project_service.compute_api,
    google_project_service.kubernetes_api,
    google_project_service.gke_hub_api,
    google_project_service.acm_api
  ]
  name     = var.cluster_name
  location = var.cluster_region
  deletion_protection = false
  enable_autopilot = true

  release_channel {
    channel = "REGULAR"
  }

  network    = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.subnet.self_link

  ip_allocation_policy {}
}

# ----------------------------
# Fleet Membership
# ----------------------------
resource "google_gke_hub_membership" "membership" {
  depends_on = [
    google_project_service.compute_api,
    google_project_service.kubernetes_api,
    google_project_service.gke_hub_api,
    google_project_service.acm_api
  ]
  membership_id = var.cluster_name
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/projects/${var.project_id}/locations/${var.cluster_region}/clusters/${google_container_cluster.autopilot.name}"
    }
  }
}

resource "google_gke_hub_feature" "configmanagement" {
  depends_on = [
    google_project_service.compute_api,
    google_project_service.kubernetes_api,
    google_project_service.gke_hub_api,
    google_project_service.acm_api
  ]
  name     = "configmanagement"
  location = "global"
}

resource "google_gke_hub_feature_membership" "configmanagement" {
  depends_on = [
    google_project_service.compute_api,
    google_project_service.kubernetes_api,
    google_project_service.gke_hub_api,
    google_project_service.acm_api
  ]
  feature    = google_gke_hub_feature.configmanagement.name
  membership = google_gke_hub_membership.membership.name
  location   = "global"

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

// ...existing code...

// ...existing code...

# ----------------------------
# Artifact Registry Service Account
# ----------------------------
resource "google_service_account" "artifact_registry_pusher" {
  account_id   = "${var.project_prefix}-artifact-pusher"
  display_name = "Artifact Registry Image Pusher"
}

resource "google_project_iam_member" "artifact_registry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.artifact_registry_pusher.email}"
}

# ####### We will create the key manually
# resource "google_service_account_key" "artifact_registry_pusher_key" {
#   service_account_id = google_service_account.artifact_registry_pusher.name
#   keepers = {
#     service_account_email = google_service_account.artifact_registry_pusher.email
#   }
# }
