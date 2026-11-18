package terraform

import input.tfplan as tfplan

deny[reason] {
    r := tfplan.resource_changes[_]
    r.name == "soft_marker"
    reason := sprintf("S41351 soft-mandatory: %s needs an override", [r.address])
}
