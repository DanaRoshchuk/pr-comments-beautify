# Fails the soft-mandatory policy (policies/soft_marker.rego).
# Apply run stops in "Waiting for policy override".
terraform {
  required_version = ">= 1.5.0"
}

locals {
  # Base branch: "base". PR branch: "pr".
  stage = "base"
}

resource "terraform_data" "soft_marker" {
  input = local.stage
}
