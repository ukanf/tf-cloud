variable "tfe_organization" {
  description = "The name of the Terraform Enterprise organization"
  type        = string
}

variable "tfe_agent_pool_name" {
  description = "The name of the Terraform Enterprise agent pool"
  type        = string
}

variable "tfe_agent_token_description" {
  description = "The description for the Terraform Enterprise agent token"
  type        = string
  default     = "Agent token for TFC agent pool"
}
