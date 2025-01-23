resource "google_container_cluster" "autopilot_cluster" {
  name               = "autopilot-cluster"
  location           = var.region
  network            = var.vpc_id
  subnetwork         = var.nodes_subnet_id
  initial_node_count = 1
  enable_autopilot   = true

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "100.0.0.0/21" # Example CIDR range for pods
    services_ipv4_cidr_block = "100.0.8.0/26" # Example CIDR range for services
  }

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "10.0.0.0/24"
      display_name = "VMs in 10.0.0.0/24"
    }
  }
}

resource "google_gke_hub_feature" "config_sync" {
  name     = "configmanagement"
  location = "global"
}

resource "google_gke_hub_membership" "autopilot_cluster_membership" {
  membership_id = "basic"
  endpoint {
    gke_cluster {
      resource_link = google_container_cluster.autopilot_cluster.id
    }
  }
}

resource "google_gke_hub_feature_membership" "config_sync_membership" {
  feature    = "configmanagement"
  membership = google_gke_hub_membership.autopilot_cluster_membership.id
  location   = "global"
  configmanagement {
    config_sync {
      git {
        sync_repo   = var.config_sync_repo
        sync_branch = var.config_sync_branch
        policy_dir  = "config-sync"
        secret_type = "ssh"
      }
    }
  }
}


# # Separately Managed Node Pool
# resource "google_container_node_pool" "primary_nodes" {
#   name     = google_container_cluster.autopilot_cluster.name
#   location = var.region
#   cluster  = google_container_cluster.autopilot_cluster.name

#   # version    = data.google_container_engine_versions.gke_version.release_channel_latest_version["STABLE"]
#   node_count = 1

#   node_config {
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/logging.write",
#       "https://www.googleapis.com/auth/monitoring",
#     ]

#     machine_type = "n1-standard-1"
#     metadata = {
#       disable-legacy-endpoints = "true"
#     }
#   }
# }