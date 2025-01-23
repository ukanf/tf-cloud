locals {
  vpc_cidr        = "10.0.0.0/16"
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
  # bastion, cluster nodes, cluster services, cluster pods
  bastion_instance_type = "e2-micro"
  region                = "us-central1"
}

module "vpc" {
  source = "./modules/gcp_vpc"

  vpc_cidr        = local.vpc_cidr
  private_subnets = local.private_subnets
}

module "nat" {
  source = "./modules/gcp_nat"

  vpc_id = module.vpc.vpc_id
  region = local.region
}

module "bastion" {
  source = "./modules/gcp_bastion"

  vpc_id            = module.vpc.vpc_id
  private_subnet_id = element(module.vpc.private_subnet_ids, 0)
  instance_type     = local.bastion_instance_type
}

module "gcp_autopilot" {
  source = "./modules/gcp_autopilot"

  vpc_id             = module.vpc.vpc_id
  nodes_subnet_id    = element(module.vpc.private_subnet_ids, 1)
  services_subnet_id = element(module.vpc.private_subnet_ids, 2)
  pods_subnet_id     = element(module.vpc.private_subnet_ids, 3)
  region             = local.region
  config_sync_repo   = "https://github.com/ukanf/anthos-sync.git"
  config_sync_branch = "main"
}


