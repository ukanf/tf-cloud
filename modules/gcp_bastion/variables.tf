variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_id" {
  description = "A private subnet ID for the bastion"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the bastion host"
  type        = string
}
