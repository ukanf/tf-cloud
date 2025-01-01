output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "private_subnet_ids" {
  value = google_compute_subnetwork.private[*].id
}
