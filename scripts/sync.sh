#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/sync.sh status
  ./scripts/sync.sh pull
  ./scripts/sync.sh push "commit message"
  ./scripts/sync.sh publish "commit message"

Commands:
  status   Show git status and recent commits
  pull     Pull latest changes from origin/main
  push     Commit local changes and push
  publish  doctor + pull --rebase + push
EOF
}

guard_secret_files() {
  local staged
  staged="$(git -C "$ROOT_DIR" diff --cached --name-only)"
  if printf '%s\n' "$staged" | grep -E '(^|/)(\.env(\..*)?|credentials\.json|tokens\.json|id_rsa|id_ed25519|.*\.(pem|key|p12|pfx))$' >/dev/null 2>&1; then
    echo "[sync][error] Staged files look sensitive. Aborting push." >&2
    printf '%s\n' "$staged" | grep -E '(^|/)(\.env(\..*)?|credentials\.json|tokens\.json|id_rsa|id_ed25519|.*\.(pem|key|p12|pfx))$' >&2 || true
    exit 1
  fi
}

status() {
  git -C "$ROOT_DIR" status --short --branch
  echo
  git -C "$ROOT_DIR" log --oneline -n 5
}

pull() {
  git -C "$ROOT_DIR" pull --ff-only origin main
}

push_changes() {
  local msg="${1:-}"
  if [[ -z "$msg" ]]; then
    echo "[sync][error] Missing commit message" >&2
    usage
    exit 1
  fi

  git -C "$ROOT_DIR" add .

  if [[ -z "$(git -C "$ROOT_DIR" diff --cached --name-only)" ]]; then
    echo "[sync] No staged changes. Nothing to commit."
    exit 0
  fi

  guard_secret_files

  git -C "$ROOT_DIR" commit -m "$msg"
  git -C "$ROOT_DIR" push origin main
}

publish() {
  local msg="${1:-}"
  if [[ -x "$ROOT_DIR/scripts/doctor.sh" ]]; then
    "$ROOT_DIR/scripts/doctor.sh"
  fi
  git -C "$ROOT_DIR" pull --rebase origin main
  push_changes "$msg"
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

CMD="$1"
shift || true

case "$CMD" in
  status)
    status
    ;;
  pull)
    pull
    ;;
  push)
    push_changes "$*"
    ;;
  publish)
    publish "$*"
    ;;
  -h|--help)
    usage
    ;;
  *)
    echo "[sync][error] Unknown command: $CMD" >&2
    usage
    exit 1
    ;;
esac
