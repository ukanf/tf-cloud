package terraform.policy.debug_things

deny[msg] {
    msg := sprintf("Input: '%v'", [input.plan])
}
