resource "random_id" "project_suffix" {
  byte_length = 4
}

locals {
  full_project_name = "${var.project_prefix}-${random_id.project_suffix.hex}"
}

# ----------------------------
# Enable required APIs
# ----------------------------
module "project-factory" {
  # doc: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/latest?tab=inputs
  source          = "terraform-google-modules/project-factory/google"
  version         = "18.1.0"
  billing_account = var.billing_account_id
  name            = local.full_project_name
  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "gkehub.googleapis.com",
    "anthosconfigmanagement.googleapis.com",
    "artifactregistry.googleapis.com"
  ]
  auto_create_network = true
  deletion_policy     = "DELETE"
}

module "gke" {
  # doc: 
  depends_on            = [module.project-factory]
  source                = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version               = "41.0.1"
  project_id            = module.project-factory.project_id
  name                  = var.cluster_name
  region                = var.cluster_region
  zones                 = [var.cluster_zone]
  initial_node_count    = 1
  network               = "default"
  subnetwork            = "default"
  ip_range_pods         = ""
  ip_range_services     = ""
  deletion_protection   = false
  
  # Disable automatic registry access and handle it separately because the module itself cant handle the dependecy :/
  grant_registry_access = false
  create_service_account = true
}


# # ----------------------------
# # Fleet Membership
# # ----------------------------
resource "google_gke_hub_membership" "membership" {
  project       = module.project-factory.project_id
  membership_id = var.cluster_name

  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/projects/${module.project-factory.project_id}/locations/${var.cluster_region}/clusters/${module.gke.name}"
    }
  }
}

resource "google_gke_hub_feature" "configmanagement" {
  project  = module.project-factory.project_id
  name     = "configmanagement"
  location = "global"
}

resource "google_gke_hub_feature_membership" "configmanagement" {
  project    = module.project-factory.project_id
  feature    = google_gke_hub_feature.configmanagement.name
  membership = google_gke_hub_membership.membership.name
  location   = "global"

  configmanagement {
    config_sync {
      source_format = "unstructured"
      enabled       = true
      oci {
        sync_repo                 = "us-central1-docker.pkg.dev/atlantis-f7bdb7e5/atlantis-docker/my-cluster-1@sha256:b4901b682a5982f006d6727ef5710cb2aa0bf55dd1b42524e6df7d7c11c12578"
        secret_type               = "gcpserviceaccount"
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
  project                   = module.project-factory.project_id
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Identity pool for GitHub Actions"
}
# if you are getting a 409 - check if the pool already exists or was delete: gcloud iam workload-identity-pools list --location="global" --show-deleted
# if deleted:
# 1. undelete it: gcloud iam workload-identity-pools undelete github-pool --location="global"
# 2. import it: terraform import google_iam_workload_identity_pool.github_pool projects/122834034033/locations/global/workloadIdentityPools/github-pool
# OR create a new one...

# Create Workload Identity Provider
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project                            = module.project-factory.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Actions Provider"

  attribute_mapping = {
    "google.subject"         = "assertion.sub"
    "attribute.actor"        = "assertion.actor"
    "attribute.repository"   = "assertion.repository"
    "attribute.workflow"     = "assertion.workflow"
    "attribute.workflow_ref" = "assertion.ref"
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
  project      = module.project-factory.project_id
  account_id   = "${var.project_prefix}-artifact-pusher"
  display_name = "Artifact Registry Image Pusher"
}

resource "google_project_iam_member" "artifact_registry_writer" {
  project = module.project-factory.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.artifact_registry_pusher.email}"
}

# ----------------------------
# Deployer Service Account
# ----------------------------
resource "google_service_account" "deployer" {
  project      = module.project-factory.project_id
  account_id   = "${var.project_prefix}-deployer"
  display_name = "Deployer"
}

resource "google_project_iam_member" "deployer_deploy_kubernetes" {
  project = module.project-factory.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

# Allow the deployer to create tokens
resource "google_project_iam_member" "deployer_token_creator" {
  project = module.project-factory.project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

# ----------------------------
# Config Management Service Account
# ----------------------------
resource "google_service_account" "config_management" {
  project      = module.project-factory.project_id
  account_id   = "${var.project_prefix}-config-mgmt"
  display_name = "Config Management System Service Account"
}

# Allow Config Management to read from Artifact Registry
resource "google_project_iam_member" "config_management_artifact_reader" {
  project = module.project-factory.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.config_management.email}"
}

# Allow Config Management K8s SA to impersonate this GSA
resource "google_service_account_iam_member" "config_management_workload_identity" {
  depends_on = [ module.gke ]
  service_account_id = google_service_account.config_management.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${module.project-factory.project_id}.svc.id.goog[config-management-system/root-reconciler]"
}

# ----------------------------
# GKE Service Account Registry Access
# ----------------------------
resource "google_project_iam_member" "gke_registry_access" {
  depends_on = [module.gke, module.project-factory]
  project    = module.project-factory.project_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${module.gke.service_account}"
}

# ----------------------------
# Artifact Registry Docker Repository
# ----------------------------
resource "google_artifact_registry_repository" "docker_repo" {
  project       = module.project-factory.project_id
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
