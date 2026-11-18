# Only an output changes. Checks the gap where the table says "no changes".
terraform {
  required_version = ">= 1.5.0"
}

locals {
  # Base branch: "base". PR branch: "pr".
  stage = "base"
}

output "stage" {
  value = local.stage
}
