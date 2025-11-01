# output "kubeconfig_command" {
#   value = "gcloud container clusters get-credentials ${google_container_cluster.autopilot.name} --region ${var.cluster_region} --project ${var.project_id}"
# }
# output "cluster_endpoint" {
#   value = google_container_cluster.autopilot.endpoint
# }

# output "cluster_name" {
#   value = google_container_cluster.autopilot.name
# }


output "workload_identity_provider" {
  value       = google_iam_workload_identity_pool_provider.github_provider.name
  description = "Workload Identity Provider ID for GitHub Actions"
}

output "service_account_email" {
  value       = google_service_account.artifact_registry_pusher.email
  description = "Service Account email for GitHub Actions"
}

output "workload_identity_provider_name" {
  value = "projects/${module.project-factory.project_id}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_pool.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.github_provider.workload_identity_pool_provider_id}"
}