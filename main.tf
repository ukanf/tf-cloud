provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_secret_manager_secret_version" "tfe_token" {
  provider = google-beta
  project  = var.project_id
  secret   = "agent-pool-management-secret"
  version  = "latest"
}

# module "tfc_agent_mig" {
#   source                 = "./modules/tfc-agent-mig-vm"
#   project_id             = var.project_id
#   region                 = var.region
#   zone                   = var.zone
#   tfc_agent_token        = var.tfc_agent_token
#   instance_template_name = var.instance_template_name
#   mig_name               = var.mig_name
#   tfc_agent_version      = var.tfc_agent_version
#   instance_group_size    = var.instance_group_size
# }

module "tfc_agent_management" {
  source              = "./modules/tfc-agent-management"
  tfe_organization    = var.tfe_organization
  tfe_agent_pool_name = var.tfe_agent_pool_name
}
