module "vpc_sc" {
  source              = "./modules/vpc-sc"
  organization_id     = "your-organization-id" // Replace with your organization ID
  policy_title        = "example-policy"
  perimeter_name      = "example-perimeter"
  perimeter_title     = "Example Perimeter"
  resources           = ["projects/${var.project_id}"]
  restricted_services = ["storage.googleapis.com"]
}
