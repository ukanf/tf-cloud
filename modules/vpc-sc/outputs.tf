output "policy_id" {
  description = "The ID of the access policy"
  value       = google_access_context_manager_access_policy.policy.name
}

output "perimeter_id" {
  description = "The ID of the service perimeter"
  value       = google_access_context_manager_service_perimeter.perimeter.name
}
