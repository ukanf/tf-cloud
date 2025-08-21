package terraform.policies.workspace_name

import rego.v1

default workspace_name := "<missing>"

workspace_name := name if {
    name := input.run.workspace.name
}

deny contains msg if {
    not regex.match("^(tf-cloud-dev|tf-cloud-uat|tf-cloud-prd)$", workspace_name)
    msg := sprintf("Workspace name '%v' is not allowed. Must be one of: tf-cloud-dev, tf-cloud-uat, tf-cloud-prd", [workspace_name])
}
