# 800 creates with long keys. Each diff line is about 230 chars, so the body is about
# 184k chars, over the 150k-char limit Scalr applies to every VCS. Per-workspace details
# are dropped. range() stops at 1024 elements, so stay at or under that.
terraform {
  required_version = ">= 1.5.0"
}

locals {
  # Base branch: "base". PR branch: "pr".
  stage = "base"
  pad   = join("-", [for i in range(19) : "padding0"])
  keys  = toset([for i in range(800) : format("%04d-%s", i, local.pad)])
}

resource "terraform_data" "big" {
  for_each = local.keys
  input    = local.stage
}
