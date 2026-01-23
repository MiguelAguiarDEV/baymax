#!/bin/bash
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "[Memory Save] jq is required" >&2
  exit 1
fi

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [ -z "$repo_root" ]; then
  echo "[Memory Save] No git repo found" >&2
  exit 1
fi

memory_file="$repo_root/config/opencode/memory.json"
if [ ! -f "$memory_file" ]; then
  echo "[Memory Save] No memory.json found" >&2
  exit 1
fi

if ! jq -e . "$memory_file" >/dev/null 2>&1; then
  echo "[Memory Save] Invalid JSON in memory.json" >&2
  exit 1
fi

pattern='(sk-[A-Za-z0-9_-]{10,}|ghp_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|(^|[^A-Za-z])(api[_-]?key|token|password|secret)([^A-Za-z]|$)|-----BEGIN|bearer[[:space:]]+[A-Za-z0-9._-]+|@[A-Za-z0-9.-]+\.[A-Za-z]{2,})'
if grep -Eqi "$pattern" "$memory_file"; then
  echo "[Memory Save] BLOCKED: possible sensitive data in memory.json" >&2
  exit 1
fi

cd "$repo_root"
if git diff --quiet -- "$memory_file" && git ls-files --error-unmatch "$memory_file" >/dev/null 2>&1; then
  echo "[Memory Save] No changes to commit" >&2
  exit 0
fi

if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
  echo "[Memory Save] No upstream configured for auto-push" >&2
  exit 1
fi

git add "$memory_file"
git commit -m "chore: update memory" -- "$memory_file" >/dev/null

GIT_TERMINAL_PROMPT=0 git push
