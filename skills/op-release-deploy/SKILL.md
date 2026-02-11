---
name: op-release-deploy
description: Safe release workflow from commit and PR gates to CI validation and Helm upgrade with explicit rollback controls.
compatibility: opencode
metadata:
  domain: operations
---

SKILL: RELEASE + DEPLOY (SAFE)

Goal
Standardize release execution from code commit to cluster rollout with explicit safety gates.

When to use

- Deploying to pre/prod environments.
- Rolling out commit-hash-tagged images through Helm.
- Requiring reproducible and auditable release steps.

Flow

1. Pre-flight checks

- Ensure working tree is in expected state.
- Confirm target environment (`pre` or `prod`), release name, namespace, chart path, and values file.
- Confirm cluster context and namespace access.

2. Commit + PR

- Prefer using:
  - `./scripts/release-pipeline.sh --env <pre|prod> --commit-message "<msg>" [flags...]`
- The script handles commit/push + PR create/reuse automatically.
- Commit message and PR title must follow conventional commits.
- Reference format guide: `docs/commit-pr-format.md`.

3. CI/CD gate

- The pipeline waits for required checks automatically using:
  - `gh pr checks <pr-number> --watch`
- Do not deploy if checks are failing or pending without explicit override approval.

4. Resolve deploy image tag

- Use immutable commit SHA tags; avoid mutable tags like `latest`.
- Pipeline auto-resolves hash with `--hash-source`:
  - default: `pr`
  - `pr` (PR head SHA)
  - `base` (latest SHA from target branch)
  - `branch` (current local branch HEAD)

5. Helm safe upgrade

- Pipeline auto-detects chart metadata where possible:
  - chart path (search `**/Chart.yaml`)
  - values file (environment-aware selection)
  - release name + namespace (values + cluster lookup)
- Final deploy uses:
  - `./scripts/helm-safe-upgrade.sh ...`
- Direct use still available:
  - `./scripts/helm-safe-upgrade.sh --release <release> --chart <chart-path> --namespace <namespace> --values <values-file> --image-tag <sha> [--dry-run]`

6. Verify rollout

- `helm status <release> -n <namespace>`
- `kubectl rollout status deployment/<name> -n <namespace>` (if applicable)
- Validate service health/readiness.

7. Rollback (if needed)

- Use Helm history and rollback:
  - `helm history <release> -n <namespace>`
  - `helm rollback <release> <revision> -n <namespace> --wait --timeout 10m`

Safer Helm baseline

- `--atomic`
- `--wait`
- `--timeout`
- `--cleanup-on-fail`
- `--history-max`
- `--create-namespace` when appropriate
- `--set-string image.tag=<sha>`

Rules

- Prod deploy always requires explicit confirmation.
- If security impact is material or uncertain, invoke `@security-reviewer` before prod rollout.
- Do not skip CI/CD gates silently.

Example

```bash
./scripts/release-pipeline.sh \
  --env prod \
  --commit-message "chore(release): deploy catalog service" \
  --base-branch main \
  --create-namespace \
  --hash-source base
```
