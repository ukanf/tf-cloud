# ...existing code...

# Default values
variable "defaults" {
  default = {
    vpc_cidr             = "10.0.0.0/16"
    private_subnets      = ["10.0.3.0/24", "10.0.4.0/24"]
    bastion_instance_type = "e2-micro"
    region               = "us-central1"
  }
}

module "vpc" {
  source = "./modules/gcp_vpc"

  vpc_cidr        = var.vpc_cidr
  private_subnets = var.private_subnets
}

module "nat" {
  source = "./modules/gcp_nat"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  region             = var.region
}

module "bastion" {
  source = "./modules/gcp_bastion"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  instance_type      = var.bastion_instance_type
}

# ...existing code...
