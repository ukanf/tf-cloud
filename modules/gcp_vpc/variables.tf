variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "private_subnets" {
  description = "A list of private subnet CIDR blocks"
  type        = list(string)
}
