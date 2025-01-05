variable "vpc_id" {
  description = "The ID of the VPC where the cluster will be deployed"
  type        = string
}

variable "nodes_subnet_id" {
  description = "Private subnet ID for nodes"
  type        = string
}

variable "services_subnet_id" {
  description = "Private subnet ID for services"
  type        = string
}

variable "pods_subnet_id" {
  description = "Private subnet ID for pods"
  type        = string
}

variable "region" {
  description = "The region where the cluster will be deployed"
  type        = string
}
