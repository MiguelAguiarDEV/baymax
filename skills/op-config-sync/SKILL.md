---
name: op-config-sync
description: Standard workflow for syncing Baymax OpenCode config across machines with validation and rollback.
compatibility: opencode
metadata:
  domain: operations
---

SKILL: CONFIG SYNC

Goal
Synchronize OpenCode configuration safely across multiple PCs.

When to use

- After creating/updating skills, agents, commands, modes, or system docs.

Workflow

1. Validate local state

- Run: `./scripts/doctor.sh`
- Ensure: no sensitive files staged.

2. Sync with remote

- Run: `./scripts/sync.sh pull`

3. Commit and push

- Run: `./scripts/sync.sh push "<message>"`

4. Verify from fresh machine

- Pull latest repo
- Run doctor + OpenCode checks

Safety checks

- Do not commit `.env`, OAuth credentials, private keys, tokens.
- Keep secrets in env vars or local secret stores.

Verification

- `opencode debug config`
- `opencode debug skill`
- `opencode agent list`
- `opencode mcp list`
