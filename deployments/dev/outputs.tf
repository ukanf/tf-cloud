# output "kubeconfig_command" {
#   value = "gcloud container clusters get-credentials ${google_container_cluster.autopilot.name} --region ${var.cluster_region} --project ${var.project_id}"
# }
# output "cluster_endpoint" {
#   value = google_container_cluster.autopilot.endpoint
# }

# output "cluster_name" {
#   value = google_container_cluster.autopilot.name
# }