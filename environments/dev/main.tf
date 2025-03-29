module "example" {
  source      = "../../modules/example-module"
  project_id  = var.project_id
  region      = var.region
}
