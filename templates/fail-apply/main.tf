# Plan succeeds, apply fails. A failed create-time provisioner taints the resource, so the
# next plan replaces it and the next apply fails the same way. Repeat runs stay repeatable.
terraform {
  required_version = ">= 1.5.0"
}

locals {
  # Base branch: "base". PR branch: "pr".
  stage = "base"
}

resource "terraform_data" "breaks_on_apply" {
  input = local.stage

  provisioner "local-exec" {
    command = "echo 'S41351 planned apply failure' >&2; exit 1"
  }
}
