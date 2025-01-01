# resource "google_compute_network" "custom_network" {
#   name                    = "custom-network"
#   auto_create_subnetworks = false
# }

# resource "google_compute_subnetwork" "custom_subnetwork" {
#   name          = "custom-subnetwork"
#   ip_cidr_range = "10.0.0.0/24"
#   region        = "us-central1"
#   network       = google_compute_network.custom_network.name
# }

# resource "google_compute_router" "custom_router" {
#   name    = "custom-router"
#   network = google_compute_network.custom_network.name
#   region  = "us-central1"
# }

# resource "google_compute_router_nat" "custom_nat" {
#   name                               = "custom-nat"
#   router                             = google_compute_router.custom_router.name
#   region                             = "us-central1"
#   nat_ip_allocate_option             = "AUTO_ONLY"
#   source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
# }

resource "google_compute_instance" "bastion" {
  name         = "bastion"
  machine_type = var.instance_type
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = element(var.private_subnet_ids, 0)
    access_config {}
  }

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      sudo apt update -y
      sudo apt install -y kubectl google-cloud-sdk-gke-gcloud-auth-plugin
    EOT
  }

  tags = ["bastion-allow-ssh-in"]
}

resource "google_compute_firewall" "allow_ssh_bastion" {
  name    = "allow-ssh-bastion-in"
  network = var.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["bastion-allow-ssh-in"]

  source_ranges = ["35.235.240.0/20"]
}

# module "beta_autopilot_private_cluster" {
#   source              = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
#   project_id          = "<your-project-id>"
#   name                = "autopilot-cluster"
#   region              = "us-central1"
#   network             = google_compute_network.custom_network.name
#   subnetwork          = google_compute_subnetwork.custom_subnetwork.name
#   ip_range_pods       = "10.1.0.0/16"
#   ip_range_services   = "10.2.0.0/20"
#   enable_private_nodes = true
# }