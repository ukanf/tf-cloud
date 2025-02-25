output "tfe_agent_pool_id" {
  description = "The ID of the created Terraform Enterprise agent pool"
  value       = tfe_agent_pool.agent_pool.id
}

output "tfe_agent_token" {
  description = "The created Terraform Enterprise agent token"
  value       = tfe_agent_token.agent_token.token
  sensitive   = true
}
