# pr-comments-beautify

Terraform fixtures for testing the Scalr PR comment layout: summary table, failure callout and
per-workspace sections. Scenario numbers match the testing checklist.

## Layout

- `templates/`: one source template per behaviour. No workspace points here.
- `scenarios/<scenario>/<workspace>/main.tf`: copies of the templates, one directory per
  workspace. A PR that touches one scenario folder triggers only that scenario's workspaces.
- `policies/`: OPA policy group (one always-pass, one advisory, one soft-mandatory).

Every `main.tf` has `stage = "base"` on `main`. A scenario PR changes it to `"pr"` in that
scenario's folder only:

```bash
sed -i '' 's/stage = "base"/stage = "pr"/' scenarios/s01-mixed/*/main.tf
```

## Shared setup

- Workspaces: VCS-driven, branch `main`, working directory `scenarios/<scenario>/<workspace>`,
  default trigger (changes in the working directory). Terraform 1.5+ or OpenTofu 1.6+.
- VCS provider: PR comments on. PR applies on for s05, s07, s08 (`/scalr apply`).
- Policy group: OPA, VCS path `policies/`, OPA version 0.x (the rego uses pre-1.0 syntax). Link
  it to every environment you use. Workspaces without a marker resource show "✅ 1 passed".

| Template | Plan | Apply |
|---|---|---|
| `ok` | 2 to create | succeeds |
| `fail-plan` | fails with "S41351 planned failure" while `stage = "pr"`, passes with `"fixed"` | n/a |
| `fail-apply` | 1 to create (a replace on reruns) | fails with "S41351 planned apply failure", every time |
| `advisory` | 1 to create, advisory policy fails | n/a |
| `soft-policy` | 1 to create, soft-mandatory policy fails | stops at Waiting for policy override |
| `destroy` | after a base apply: 1 replace, 1 delete | n/a |
| `cost` | 1 `aws_instance` (m5.large) with mock credentials | never apply |
| `big` | 800 creates with long keys, about 180k chars of diff | n/a |
| `outputs-only` | 1 output, no resources | n/a |

## Scenarios

| # | VCS | Workspaces (name: working dir) | Extra setup | Steps |
|---|---|---|---|---|
| 1, 2 | GitLab (1), Azure DevOps (2) | `ok-a`, `ok-b`, `fail`: `s01-mixed/*` | | PR flipping `s01-mixed` |
| 3 | any | `cost`: `s03-cost/cost` | Infracost integration shared with env1. For the `–` value, use any workspace in an env without the integration: a zero-cost run with an estimate shows `$0.00` | PR flipping `s03-cost` |
| 4 | any | `ok-a`, `ok-b`, `ok-c`: `s04-height/*`; `ok`: `s04-single/ok` | | One PR for `s04-height`, one for `s04-single` |
| 5, 10 | GitLab for 5, any for 10 | `approve`, `decline`: `s05-approve-decline/*` | Auto-apply off on both | PR, comment `/scalr apply`, copy the approve command from `approve`'s section and the decline command from `decline`'s section |
| 6 | any | `advisory`, `destroy`: `s06-findings/*` | Before the PR, queue a run on `destroy` from `main` and apply it (3 resources) | PR flipping `s06-findings` |
| 7 | any | `soft`: `s07-soft/soft` | | PR, then `/scalr apply` (or merge) |
| 8 | any | `waiting`, `fail-apply`: `s08-quota-hidden/*` | Account limit on runs per PR comment set to 1. Auto-apply off on `waiting`, on for `fail-apply` | PR, then `/scalr apply`. Reset the limit afterwards |
| 9 | any | `fail-a`, `fail-b`, `fail-c`: `s09-quota-more/*` | Account limit on runs per PR comment set to 2 | PR flipping `s09-quota-more`. Reset the limit afterwards |
| 11 | any | `network` in env1: `s11-same-name/env1`; `network` in env2: `s11-same-name/env2` | Same workspace name in two environments | PR flipping `s11-same-name` |
| 12 | GitHub and GitLab | reuse s01 | | After the s01 report with `fail` expanded, push a commit setting `stage = "fixed"` in `s01-mixed/fail/main.tf` |
| 13 | GitLab, Azure DevOps | `ok`: `s13-pipe/ok` | Workspace and environment names that contain a pipe, e.g. `team\|prod` | PR flipping `s13-pipe`. The run fails at init because of the pipe in the name; only the table layout matters here |
| 14 | Azure DevOps | `big`: `s14-big/big` | | PR flipping `s14-big` |
| Gap | any | `outputs`: `gap-outputs/outputs` | | PR flipping `gap-outputs`; read the Changes cell and the section summary |

The runs-per-comment limit is account-wide, so run s08 and s09 one at a time and on their own.

## Notes

- `cost` downloads the AWS provider on the runner. It plans without AWS access because creating
  an `aws_instance` makes no API calls at plan time. A negative cost delta needs real AWS
  credentials: apply a bigger instance on `main`, then shrink it in the PR.
- `fail-apply` uses a `local-exec` provisioner (`/bin/sh`). If a runner blocks provisioners, the
  apply fails for that reason instead, which still covers scenario 8.
- `big`: comments over 150,000 chars are truncated on every VCS, so `big` truncates on GitHub
  too.
