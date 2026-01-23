---
description: Validate and push current memory.json to git.
agent: build
---

# Memory Save Command

Usage:

```
/memory-save
```

## What This Command Does

1. Validates `config/opencode/memory.json` as JSON.
2. Scans for sensitive patterns (tokens, keys, emails).
3. Commits only `memory.json` if changed.
4. Pushes to the configured upstream.

## Notes

- Requires `jq` and a git repo with upstream configured.
- If no changes exist, it does nothing.
- If secrets are detected, it aborts.
- Follow the memory policy: only save important decisions and conventions.

## Implementation

This command should execute:

```
~/.config/opencode/hooks/memory-persistence/save-memory.sh
```
