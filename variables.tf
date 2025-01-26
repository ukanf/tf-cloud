variable "project_id" {
  description = "The project ID to deploy resources"
  type        = string
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone to deploy resources"
  type        = string
  default     = "us-central1-a"
}

variable "tfc_agent_token" {
  description = "The token for the TFC agent"
  type        = string
  sensitive   = true
}

variable "instance_template_name" {
  description = "The name of the instance template"
  type        = string
}

variable "mig_name" {
  description = "The name of the managed instance group"
  type        = string
}

variable "agent_version" {
  description = "The version of the TFC agent"
  type        = string
}

variable "instance_group_size" {
  description = "The size of the instance group"
  type        = number
}
