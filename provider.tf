# https://registry.terraform.io/providers/hashicorp/google/latest/docs
provider "google" {
  project = "tf-poc-gke"
  region  = "us-central1"
}

# https://www.terraform.io/language/settings/backends/gcs
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}