package terraform

import input.tfplan as tfplan

deny[reason] {
    r := tfplan.resource_changes[_]
    r.name == "advisory_marker"
    reason := sprintf("S41351 advisory: %s is not allowed", [r.address])
}
