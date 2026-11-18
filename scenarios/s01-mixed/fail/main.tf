# Plan fails on the PR branch. Set stage to "fixed" in a later commit to make it pass.
terraform {
  required_version = ">= 1.5.0"
}

locals {
  # Base branch: "base". PR branch: "pr". Fix commit: "fixed".
  stage = "pr"
}

resource "terraform_data" "guarded" {
  input = local.stage

  lifecycle {
    precondition {
      condition     = local.stage != "pr"
      error_message = "S41351 planned failure: stage is pr."
    }
  }
}
