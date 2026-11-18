# Apply once on the base branch first. On the PR branch the plan replaces "swap" and
# deletes "gone[0]", which gives the destructive-changes finding.
terraform {
  required_version = ">= 1.5.0"
}

locals {
  # Base branch: "base". PR branch: "pr".
  stage = "base"
}

resource "terraform_data" "keep" {
  input = "unchanged"
}

resource "terraform_data" "swap" {
  triggers_replace = local.stage
}

resource "terraform_data" "gone" {
  count = local.stage == "base" ? 1 : 0
  input = "removed on the PR branch"
}
