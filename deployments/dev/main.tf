terraform {
  required_version = ">= 1.0.0"
}

output "current_workspace" {
  value = terraform.workspace
}
