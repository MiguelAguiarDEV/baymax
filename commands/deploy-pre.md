---
description: Create pre-environment deploy runbook with safe Helm upgrade
agent: release-manager
subtask: true
---
Build a PRE deploy runbook for this release:

$ARGUMENTS

Requirements:
- include commit/PR/CI gate sequence
- resolve image tag from merged commit SHA
- use safe Helm upgrade parameters
- include rollback plan
