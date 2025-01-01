output "bastion_instance_id" {
  value = google_compute_instance.bastion.id
}

output "bastion_ip" {
  value = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}
