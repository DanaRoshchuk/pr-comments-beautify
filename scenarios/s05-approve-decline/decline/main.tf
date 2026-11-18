# Clean dry run: 2 resources to create, no findings.
terraform {
  required_version = ">= 1.5.0"
}

locals {
  # Base branch: "base". PR branch: "pr".
  stage = "pr"
}

resource "terraform_data" "first" {
  input = local.stage
}

resource "terraform_data" "second" {
  input = local.stage
}
