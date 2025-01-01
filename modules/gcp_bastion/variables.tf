variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs"
  type        = list(string)
}

variable "instance_type" {
  description = "The instance type for the bastion host"
  type        = string
}
