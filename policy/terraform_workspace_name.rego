package terraform.policy

deny[msg] {
  ws := input.workspace
  not allowed_workspace(ws)
  msg := sprintf("Workspace name '%v' is not allowed. Must be one of: tf-cloud-dev, tf-cloud-uat, tf-cloud-prd", [ws])
}

allowed_workspace(ws) {
  ws == "tf-cloud-dev"
}
allowed_workspace(ws) {
  ws == "tf-cloud-uat"
}
allowed_workspace(ws) {
  ws == "tf-cloud-prd"
}
