# tf-cloud
This project uses Terraform to manage infrastructure on Google Cloud Platform (GCP).

## Modules

### VPC
Creates a Virtual Private Cloud (VPC) with private subnets.

### NAT
Creates a Network Address Translation (NAT) gateway to allow instances in the private subnets to access the internet.

### Bastion
Creates a bastion host in the private subnets for secure access to instances.

## Usage

1. Clone the repository.
2. Update the `variables.tf` file with your desired values.
3. Run `terraform init` to initialize the configuration.
4. Run `terraform apply` to create the resources.

## IMPORTANT

Check branches for content.