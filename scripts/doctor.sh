#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STRICT=false

log() {
  printf '[doctor] %s\n' "$*"
}

warn() {
  printf '[doctor][warn] %s\n' "$*" >&2
}

err() {
  printf '[doctor][error] %s\n' "$*" >&2
}

usage() {
  cat <<'EOF'
Usage: ./scripts/doctor.sh [--strict]

Checks:
  - required project files/directories
  - required command availability
  - OpenCode config resolution
  - MCP status snapshot

Options:
  --strict   Exit non-zero on warnings
  -h, --help Show help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict)
      STRICT=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      err "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

failures=0
warnings=0

require_path() {
  local path="$1"
  if [[ ! -e "$ROOT_DIR/$path" ]]; then
    err "Missing required path: $path"
    failures=$((failures + 1))
  else
    log "OK path: $path"
  fi
}

require_cmd() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    log "OK command: $cmd"
  else
    warn "Command missing: $cmd"
    warnings=$((warnings + 1))
  fi
}

require_path "opencode.json"
require_path "AGENTS.md"
require_path "agents"
require_path "skills"
require_path "commands"
require_path "modes"
require_path "system"
require_path "scripts/bootstrap.sh"
require_path "scripts/doctor.sh"
require_path "scripts/scaffold.sh"
require_path "scripts/sync.sh"
require_path "scripts/install-providers.sh"
require_path "scripts/validate-skill-tags.py"

require_cmd git
require_cmd opencode
require_cmd npx
require_cmd python3

if command -v opencode >/dev/null 2>&1; then
  if opencode debug config >/dev/null 2>&1; then
    log "OK opencode debug config"
  else
    warn "opencode debug config failed"
    warnings=$((warnings + 1))
  fi

  log "MCP status snapshot:"
  if command -v bash >/dev/null 2>&1; then
    if ! bash -ic 'opencode mcp list'; then
      warn "opencode mcp list failed"
      warnings=$((warnings + 1))
    fi
  elif ! opencode mcp list; then
    warn "opencode mcp list failed"
    warnings=$((warnings + 1))
  fi
fi

if [[ -z "${GITHUB_MCP_PAT:-}" ]]; then
  if command -v bash >/dev/null 2>&1; then
    if ! bash -ic '[[ -n "${GITHUB_MCP_PAT:-}" ]]' >/dev/null 2>&1; then
      warn "GITHUB_MCP_PAT is not set (GitHub MCP may fail)"
      warnings=$((warnings + 1))
    fi
  else
    warn "GITHUB_MCP_PAT is not set (GitHub MCP may fail)"
    warnings=$((warnings + 1))
  fi
fi

if command -v python3 >/dev/null 2>&1; then
  if python3 "$ROOT_DIR/scripts/validate-skill-tags.py" >/dev/null 2>&1; then
    log "OK skill tag report"
  else
    warn "skill tag validation reported issues"
    warnings=$((warnings + 1))
  fi
fi

log "Summary: failures=$failures warnings=$warnings"

if [[ "$STRICT" == "true" && $warnings -gt 0 ]]; then
  exit 1
fi

if [[ $failures -gt 0 ]]; then
  exit 1
fi

exit 0
