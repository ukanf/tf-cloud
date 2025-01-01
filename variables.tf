variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "A list of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "bastion_instance_type" {
  description = "The instance type for the bastion host"
  type        = string
  default     = "e2-micro"
}

variable "region" {
  description = "The region where resources will be created"
  type        = string
  default     = "us-central1"
}
