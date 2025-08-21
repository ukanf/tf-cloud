resource "google_access_context_manager_access_policy" "policy" {
  parent = "organizations/${var.organization_id}"
  title  = var.policy_title
}

resource "google_access_context_manager_service_perimeter" "perimeter" {
  parent        = google_access_context_manager_access_policy.policy.name
  name          = var.perimeter_name
  title         = var.perimeter_title
  status {
    resources = var.resources
    restricted_services = var.restricted_services
  }
}
