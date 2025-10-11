variable "project_id" {
  description = "GCP project ID"
  default     = "tf-atlantis-poc"
  type        = string
}

variable "project_prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "atlantis"
}

variable "region" {
  description = "Region to deploy the cluster (e.g. us-central1)"
  default     = "us-central1"
  type        = string
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "atlantis-autopilot-cluster"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "config_sync_repo_url" {
  description = "URL of the Git repository for Config Sync"
  type        = string
  default     = "https://github.com/ukanf/acm-atlantis-poc.git"
}

variable "config_sync_branch" {
  description = "Branch of the Git repository for Config Sync"
  type        = string
  default     = "main"
}