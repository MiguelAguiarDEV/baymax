---
description: Create production deploy runbook with strict gates and rollback
agent: release-manager
subtask: true
---
Build a PROD deploy runbook for this release:

$ARGUMENTS

Requirements:
- explicit prod confirmation gate
- CI/CD checks must be green
- immutable image tag from commit SHA
- safe Helm upgrade parameters
- post-deploy verification and rollback criteria
