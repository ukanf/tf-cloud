package terraform.policies.workspace_name_test

import data.terraform.policies.workspace_name
import rego.v1

test_deny_disallowed_workspace if {
    test_input := {"run": {"workspace": {"name": "not-allowed"}}}
    count(workspace_name.deny) == 1 with input as test_input
}

test_allow_allowed_workspace_dev if {
    test_input := {"run": {"workspace": {"name": "tf-cloud-dev"}}}
    count(workspace_name.deny) == 0 with input as test_input
}

test_allow_allowed_workspace_uat if {
    test_input := {"run": {"workspace": {"name": "tf-cloud-uat"}}}
    count(workspace_name.deny) == 0 with input as test_input
}

test_allow_allowed_workspace_prd if {
    test_input := {"run": {"workspace": {"name": "tf-cloud-prd"}}}
    count(workspace_name.deny) == 0 with input as test_input
}

test_deny_missing_workspace if {
    test_input := {"run": {"workspace": {}}}
    count(workspace_name.deny) == 1 with input as test_input
}
