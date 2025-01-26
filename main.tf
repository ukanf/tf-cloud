provider "google" {
  project = var.project_id
  region  = var.region
}

module "tfc_agent_mig" {
  source                 = "./modules/tfc-agent-mig-vm"
  project_id             = var.project_id
  region                 = var.region
  zone                   = var.zone
  tfc_agent_token        = var.tfc_agent_token
  instance_template_name = var.instance_template_name
  mig_name               = var.mig_name
  tfc_agent_version      = var.tfc_agent_version
  instance_group_size    = var.instance_group_size
}
