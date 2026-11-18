version = "v1"

policy "always_pass" {
  enabled           = true
  enforcement_level = "hard-mandatory"
}

policy "advisory_marker" {
  enabled           = true
  enforcement_level = "advisory"
}

policy "soft_marker" {
  enabled           = true
  enforcement_level = "soft-mandatory"
}
