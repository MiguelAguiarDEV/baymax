#!/bin/bash
set -euo pipefail

input=$(cat)

if ! printf '%s' "$input" | jq -e . >/dev/null 2>&1; then
  echo "[Hook] Invalid JSON payload" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "[Hook] jq is required for memory persistence" >&2
  exit 1
fi

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [ -z "$repo_root" ]; then
  echo "[Hook] No git repo found for memory persistence" >&2
  exit 1
fi

memory_file="$repo_root/config/opencode/memory.json"
tool=$(printf '%s' "$input" | jq -r '.tool // ""')
tool_input=$(printf '%s' "$input" | jq -c '.tool_input // {}')

pattern='(sk-[A-Za-z0-9_-]{10,}|ghp_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|api[_-]?key|token|password|secret|-----BEGIN|bearer[[:space:]]+[A-Za-z0-9._-]+|@[A-Za-z0-9.-]+\.[A-Za-z]{2,})'
if printf '%s' "$tool_input" | grep -Eqi "$pattern"; then
  echo "[Hook] BLOCKED: possible sensitive data in memory payload" >&2
  exit 1
fi

if [ ! -f "$memory_file" ]; then
  echo '{"entries":[]}' > "$memory_file"
fi

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
entry=$(jq -n --arg ts "$timestamp" --arg tool "$tool" --argjson payload "$tool_input" '{timestamp:$ts, tool:$tool, payload:$payload}')

if printf '%s' "$entry" | grep -Eqi "$pattern"; then
  echo "[Hook] BLOCKED: possible sensitive data in memory entry" >&2
  exit 1
fi

scratch=$(mktemp)
trap 'rm -f "$scratch"' EXIT

jq --argjson entry "$entry" '.entries += [$entry]' "$memory_file" > "$scratch" \
  || printf '%s\n' '{"entries":[]}' | jq --argjson entry "$entry" '.entries += [$entry]' > "$scratch"
mv "$scratch" "$memory_file"

cd "$repo_root"
if git diff --quiet -- "$memory_file" && git ls-files --error-unmatch "$memory_file" >/dev/null 2>&1; then
  exit 0
fi

git add "$memory_file"
git commit -m "chore: update memory" -- "$memory_file" >/dev/null

if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
  echo "[Hook] No upstream configured for auto-push" >&2
  exit 1
fi

GIT_TERMINAL_PROMPT=0 git push
