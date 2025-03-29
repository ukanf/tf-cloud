terraform {
  backend "gcs" {
    bucket = "your-terraform-state-bucket"
    prefix = "tf-cloud/state"
  }
}
