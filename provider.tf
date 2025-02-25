provider "tfe" {
  hostname = "app.terraform.io"
  token    = data.google_secret_manager_secret_version.tfe_token.secret_data
}
