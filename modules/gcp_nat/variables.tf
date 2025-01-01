variable "vpc_id" {
  description = "The VPC network ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "region" {
  description = "The region where the NAT gateway will be created"
  type        = string
}
