resource "tfe_agent_pool" "agent_pool" {
  organization = var.tfe_organization
  name         = var.tfe_agent_pool_name
}

resource "tfe_agent_token" "agent_token" {
  agent_pool_id = tfe_agent_pool.agent_pool.id
  description   = var.tfe_agent_token_description
}
