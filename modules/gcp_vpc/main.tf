resource "google_compute_network" "vpc" {
  name                    = "custom-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private" {
  count         = length(var.private_subnets)
  name          = "private-subnetwork-${count.index}"
  ip_cidr_range = var.private_subnets[count.index]
  region        = "us-central1"
  network       = google_compute_network.vpc.name
}
