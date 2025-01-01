variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "private_subnets" {
  description = "A list of private subnet CIDR blocks"
  type        = list(string)
}

variable "bastion_instance_type" {
  description = "The instance type for the bastion host"
  type        = string
}

variable "region" {
  description = "The region where resources will be created"
  type        = string
}
