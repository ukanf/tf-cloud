# ----------------------------
# Enable required APIs
# ----------------------------
resource "google_project_service" "compute_api" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "kubernetes_api" {
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "gke_hub_api" {
  service            = "gkehub.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "acm_api" {
  service            = "anthosconfigmanagement.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "artifact_registry_api" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

# # ----------------------------
# # VPC Network
# # ----------------------------
# resource "google_compute_network" "vpc" {
#   depends_on = [google_project_service.compute_api, google_project_service.kubernetes_api, google_project_service.gke_hub_api, google_project_service.acm_api]
#   name                    = "${var.project_prefix}-vpc"
#   auto_create_subnetworks = false
#   description             = "VPC for GKE Autopilot and Atlantis"
# }


# # ----------------------------
# # Subnetwork
# # ----------------------------
# resource "google_compute_subnetwork" "subnet" {
#   name          = "${var.project_prefix}-subnet"
#   ip_cidr_range = var.subnet_cidr
#   region        = var.cluster_region
#   network       = google_compute_network.vpc.id
#   description   = "Subnetwork for GKE Autopilot cluster"
# }

# # ----------------------------
# # GKE Autopilot Cluster
# # ----------------------------
# resource "google_container_cluster" "autopilot" {
#   depends_on = [
#     google_project_service.compute_api,
#     google_project_service.kubernetes_api,
#     google_project_service.gke_hub_api,
#     google_project_service.acm_api
#   ]
#   name     = var.cluster_name
#   location = var.cluster_region
#   deletion_protection = false
#   enable_autopilot = true

#   release_channel {
#     channel = "REGULAR"
#   }

#   network    = google_compute_network.vpc.self_link
#   subnetwork = google_compute_subnetwork.subnet.self_link

#   ip_allocation_policy {}
# }

# # ----------------------------
# # GKE Cluster
# # ----------------------------

module "gke" {
  source             = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version            = "41.0.1"
  project_id         = var.project_id
  name               = var.cluster_name
  region             = var.cluster_region
  zones              = [var.cluster_zone]
  initial_node_count = 1
  network            = "default"
  subnetwork         = "default"
  ip_range_pods      = ""
  ip_range_services  = ""
  deletion_protection = false
  grant_registry_access = true
  registry_project_ids = ["tf-atlantis-poc"]
}


# # ----------------------------
# # Fleet Membership
# # ----------------------------
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
      resource_link = "//container.googleapis.com/projects/${var.project_id}/locations/${var.cluster_region}/clusters/${module.gke.name}"
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
      enabled       = true
      oci {
        sync_repo = "us-central1-docker.pkg.dev/tf-atlantis-poc/atlantis-docker/my-cluster-1@sha256:32f11dc46fea2291aeff56ae7dfd321977c9382ec6e4dff91b3403cf9b6cddd0"
        secret_type = "gcpserviceaccount"
        gcp_service_account_email = google_service_account.config_management.email
      }
    }
  }
}

# ----------------------------
# Workload Identity Pool
# ----------------------------
# Create Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-pool"
  display_name             = "GitHub Actions Pool"
  description             = "Identity pool for GitHub Actions"
}
# if you are getting a 409 - check if the pool already exists or was delete: gcloud iam workload-identity-pools list --location="global" --show-deleted
# if deleted:
# 1. undelete it: gcloud iam workload-identity-pools undelete github-pool --location="global"
# 2. import it: terraform import google_iam_workload_identity_pool.github_pool projects/122834034033/locations/global/workloadIdentityPools/github-pool
# OR create a new one...

# Create Workload Identity Provider
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Actions Provider"
  
  attribute_mapping = {
    "google.subject"           = "assertion.sub"
    "attribute.actor"          = "assertion.actor"
    "attribute.repository"     = "assertion.repository"
    "attribute.workflow"       = "assertion.workflow"
    "attribute.workflow_ref"   = "assertion.ref"
  }
  
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_condition = "assertion.repository=='ukanf/acm-atlantis-poc'"
}
# Well, another 409??
# Check if it exists and was deleted.. gcloud iam workload-identity-pools providers list   --workload-identity-pool="github-pool"   --location="global"   --show-deleted
# undelete: gcloud iam workload-identity-pools providers undelete github-provider --workload-identity-pool="github-pool" --location="global"
# import: terraform import google_iam_workload_identity_pool_provider.github_provider projects/122834034033/locations/global/workloadIdentityPools/github-pool/providers/github-provider
# OR create a new one


# Allow authentications from the workload identity provider to impersonate the service account
resource "google_service_account_iam_member" "workload_identity_user_pusher" {
  service_account_id = google_service_account.artifact_registry_pusher.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/ukanf/acm-atlantis-poc"
}

# Allow authentications from the workload identity provider to impersonate the service account
resource "google_service_account_iam_member" "workload_identity_user_deployer" {
  service_account_id = google_service_account.deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/ukanf/acm-atlantis-poc"
}

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

# ----------------------------
# Deployer Service Account
# ----------------------------
resource "google_service_account" "deployer" {
  account_id   = "${var.project_prefix}-deployer"
  display_name = "Deployer"
}

resource "google_project_iam_member" "deployer_deploy_kubernetes" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

# Allow the deployer to create tokens
resource "google_project_iam_member" "deployer_token_creator" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

# ----------------------------
# Config Management Service Account
# ----------------------------
resource "google_service_account" "config_management" {
  account_id   = "${var.project_prefix}-config-mgmt"
  display_name = "Config Management System Service Account"
}

# Allow Config Management to read from Artifact Registry
resource "google_project_iam_member" "config_management_artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.config_management.email}"
}

# Allow Config Management K8s SA to impersonate this GSA
resource "google_service_account_iam_member" "config_management_workload_identity" {
  service_account_id = google_service_account.config_management.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[config-management-system/root-reconciler]"
}

# ----------------------------
# Artifact Registry Docker Repository
# ----------------------------
resource "google_artifact_registry_repository" "docker_repo" {
  provider      = google
  location      = var.cluster_region
  repository_id = "${var.project_prefix}-docker"
  description   = "Docker repository for ${var.project_prefix}"
  format        = "DOCKER"
}

# ####### We will create the key manually
# resource "google_service_account_key" "artifact_registry_pusher_key" {
#   service_account_id = google_service_account.artifact_registry_pusher.name
#   keepers = {
#     service_account_email = google_service_account.artifact_registry_pusher.email
#   }
# }
