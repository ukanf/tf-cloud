output "cluster_name" {
  description = "The name of the autopilot cluster"
  value       = google_container_cluster.autopilot_cluster.name
}

output "cluster_endpoint" {
  description = "The endpoint of the autopilot cluster"
  value       = google_container_cluster.autopilot_cluster.endpoint
}
