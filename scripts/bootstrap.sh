#!/usr/bin/env bash
set -euo pipefail

REPO_URL_DEFAULT="https://github.com/MiguelAguiarDEV/opencode-baymax-config.git"
TARGET_DEFAULT="$HOME/.config/opencode"
BRANCH_DEFAULT="main"

REPO_URL="${REPO_URL:-$REPO_URL_DEFAULT}"
TARGET_DIR="${TARGET_DIR:-$TARGET_DEFAULT}"
BRANCH="${BRANCH:-$BRANCH_DEFAULT}"
RUN_DOCTOR=true

log() {
  printf '[bootstrap] %s\n' "$*"
}

warn() {
  printf '[bootstrap][warn] %s\n' "$*" >&2
}

usage() {
  cat <<'EOF'
Usage: ./scripts/bootstrap.sh [options]

Options:
  --repo <url>       Repository URL (default: current Baymax repo)
  --target <path>    Install path (default: ~/.config/opencode)
  --branch <name>    Git branch to checkout (default: main)
  --no-doctor        Skip post-install doctor checks
  -h, --help         Show this help

Examples:
  ./scripts/bootstrap.sh
  ./scripts/bootstrap.sh --target ~/.config/opencode
  ./scripts/bootstrap.sh --repo https://github.com/<user>/<repo>.git
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO_URL="$2"
      shift 2
      ;;
    --target)
      TARGET_DIR="$2"
      shift 2
      ;;
    --branch)
      BRANCH="$2"
      shift 2
      ;;
    --no-doctor)
      RUN_DOCTOR=false
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      warn "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

mkdir -p "$(dirname "$TARGET_DIR")"

if [[ -d "$TARGET_DIR/.git" ]]; then
  ORIGIN_URL="$(git -C "$TARGET_DIR" remote get-url origin 2>/dev/null || true)"
  if [[ -n "$ORIGIN_URL" ]]; then
    log "Existing git repo found at $TARGET_DIR"
    log "Pulling latest changes from origin/$BRANCH"
    git -C "$TARGET_DIR" fetch origin "$BRANCH"
    git -C "$TARGET_DIR" checkout "$BRANCH"
    git -C "$TARGET_DIR" pull --ff-only origin "$BRANCH"
  else
    BACKUP_DIR="${TARGET_DIR}.backup.$(date +%Y%m%d-%H%M%S)"
    warn "Directory exists without valid origin remote. Backing up to $BACKUP_DIR"
    mv "$TARGET_DIR" "$BACKUP_DIR"
    git clone --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR"
  fi
elif [[ -e "$TARGET_DIR" ]]; then
  BACKUP_DIR="${TARGET_DIR}.backup.$(date +%Y%m%d-%H%M%S)"
  warn "Path exists and is not a git repo. Backing up to $BACKUP_DIR"
  mv "$TARGET_DIR" "$BACKUP_DIR"
  git clone --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR"
else
  log "Cloning $REPO_URL -> $TARGET_DIR"
  git clone --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR"
fi

log "Install complete at: $TARGET_DIR"

if [[ "$RUN_DOCTOR" == "true" ]]; then
  if [[ -x "$TARGET_DIR/scripts/doctor.sh" ]]; then
    log "Running doctor checks"
    "$TARGET_DIR/scripts/doctor.sh"
  else
    warn "Doctor script not found or not executable: $TARGET_DIR/scripts/doctor.sh"
  fi
fi

cat <<EOF

Next steps:
  1) opencode mcp auth notion
  2) opencode mcp auth vercel
  3) export GITHUB_MCP_PAT="\$(gh auth token)"
  4) npx -y @dguido/google-workspace-mcp auth
  5) opencode mcp list

EOF
