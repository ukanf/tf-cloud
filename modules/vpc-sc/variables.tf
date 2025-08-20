variable "organization_id" {
  description = "The ID of the GCP organization"
  type        = string
}

variable "policy_title" {
  description = "The title of the access policy"
  type        = string
}

variable "perimeter_name" {
  description = "The name of the service perimeter"
  type        = string
}

variable "perimeter_title" {
  description = "The title of the service perimeter"
  type        = string
}

variable "resources" {
  description = "The list of resources to include in the service perimeter"
  type        = list(string)
}

variable "restricted_services" {
  description = "The list of restricted services for the service perimeter"
  type        = list(string)
}
