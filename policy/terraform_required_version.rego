package terraform.policy

required_version = input.terraform.required_version
required_version = input.required_version

deny[msg] {
  required := required_version
  not version_gte(required, "1.19.1")
  msg := sprintf("Terraform required_version must be >= 1.19.1, found: %v", [required])
}

version_gte(version, min_version) {
  # Remove leading '=' or '>=' or whitespace
  clean := trim(trim(trim(version, "="), ">="), " ")
  # Split by '.'
  v := split(clean, ".")
  m := split(min_version, ".")
  # Compare major, minor, patch
  not less_than(v, m)
}

less_than(v, m) {
  some i
  v[i] != m[i]
  to_number(v[i]) < to_number(m[i])
}
