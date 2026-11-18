# Successful dry run that fails the advisory policy (policies/advisory_marker.rego).
terraform {
  required_version = ">= 1.5.0"
}

locals {
  # Base branch: "base". PR branch: "pr".
  stage = "base"
}

resource "terraform_data" "advisory_marker" {
  input = local.stage
}
