---
description: Deploy company repo to pre or pro using CI/ECR/Helm (no values commits).
agent: deploy-work
---

# Deploy Work

Usage:

```
/deploy-work pre
/deploy-work pro
```

## What This Command Does

1. Confirms CI success and obtains the SHA.
2. Verifies ECR image push from CI logs.
3. Detects release and namespace from the cluster.
4. Runs `helm upgrade` using `--set image.tag=<SHA>` after confirmation.
5. Guardrail: do not edit or commit `values-pre.yaml` or `values-pro.yaml`.

## Required Inputs

- Target environment: `pre` or `pro`.
- PR ID or branch name (if not obvious).

## Workflow (Pre)

1. CI green on branch/PR.
2. Extract `headSha` from the latest CI run.
3. Verify ECR tags include the SHA.
4. Confirm cluster context and namespace:
   - `kubectl config current-context`
   - `kubectl get ns | rg <ns>`
5. Detect release/namespace:
   - `kubectl get deployments -A | rg <app>`
   - `helm list -A | rg <app>`
6. Ask for explicit confirmation before `helm upgrade`.
7. Confirm and run:
   - `helm upgrade <release> -f <values-pre.yaml> <chart-path> --namespace <ns> --set image.tag=<SHA>`

## Post-Deploy Verification

- `helm status <release> -n <ns>`
- `helm history <release> -n <ns>`
- Record release, namespace, and revision in notes/runbook.

## Workflow (Pro)

1. Merge PR to master.
2. Wait for CI on master.
3. Extract `headSha` and verify ECR tags.
4. Confirm cluster context and namespace:
   - `kubectl config current-context`
   - `kubectl get ns | rg <ns>`
5. Detect release/namespace.
6. Ask for explicit confirmation before `helm upgrade`.
7. Confirm and run:
   - `helm upgrade <release> -f <values-pro.yaml> <chart-path> --namespace <ns> --set image.tag=<SHA>`

## Naturgy Special Case

- `values-pre.yaml` and `values-pro.yaml` in `ci/helm-package-new` only apply to `naturgy-web`.
- If release is `naturgy-web-new` (or `naturgy-web-pre-naturgy-web-new`), use:
  - `./ci/helm-package-new/values-pre.yaml` or `./ci/helm-package-new/values-pro.yaml`.
- Otherwise use `./ci/helm-package/values-*.yaml`.
