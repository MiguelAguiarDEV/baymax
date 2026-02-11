#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

MODE="symlink"
DRY_RUN=false
FORCE=false
PROVIDERS_CSV="opencode,codex,gemini,antigravity,claudecode"

OPENCODE_HOME="${OPENCODE_HOME:-$HOME/.config/opencode}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
GEMINI_HOME="${GEMINI_HOME:-$HOME/.gemini}"
ANTIGRAVITY_HOME="${ANTIGRAVITY_HOME:-$GEMINI_HOME/antigravity}"
CLAUDECODE_HOME="${CLAUDECODE_HOME:-$HOME/.claude}"

SKILLS_ACTIVE_FILE="$ROOT_DIR/skills/ACTIVE_SKILLS.txt"
AGENTS_ACTIVE_FILE="$ROOT_DIR/agents/ACTIVE_AGENTS.txt"

declare -a SKILLS=()
declare -a AGENTS=()
declare -a COMMANDS=()

usage() {
  cat <<'EOF'
Usage: ./scripts/install-providers.sh [options]

Install Baymax skills/agents/commands to multiple provider homes.

Options:
  --providers <csv>    Providers to install (default: opencode,codex,gemini,antigravity,claudecode)
  --mode <type>        Install mode: symlink | copy (default: symlink)
  --dry-run            Print actions without writing changes
  --force              Replace existing destinations when needed
  --list               List providers and destination roots, then exit
  -h, --help           Show help

Environment overrides:
  OPENCODE_HOME        (default: ~/.config/opencode)
  CODEX_HOME           (default: ~/.codex)
  GEMINI_HOME          (default: ~/.gemini)
  ANTIGRAVITY_HOME     (default: ~/.gemini/antigravity)
  CLAUDECODE_HOME      (default: ~/.claude)

Examples:
  ./scripts/install-providers.sh
  ./scripts/install-providers.sh --providers codex,gemini --mode copy
  ./scripts/install-providers.sh --providers antigravity,claudecode --dry-run
EOF
}

log() {
  printf '[install-providers] %s\n' "$*"
}

warn() {
  printf '[install-providers][warn] %s\n' "$*" >&2
}

err() {
  printf '[install-providers][error] %s\n' "$*" >&2
}

run() {
  if [[ "$DRY_RUN" == "true" ]]; then
    printf '[dry-run] %s\n' "$*"
    return 0
  fi
  "$@"
}

exists_path() {
  local path="$1"
  [[ -e "$path" || -L "$path" ]]
}

same_realpath() {
  local a="$1"
  local b="$2"
  python3 - "$a" "$b" <<'PY'
import os
import sys

a = sys.argv[1]
b = sys.argv[2]

if not (os.path.exists(a) or os.path.islink(a)):
    print("0")
    raise SystemExit(0)
if not (os.path.exists(b) or os.path.islink(b)):
    print("0")
    raise SystemExit(0)

print("1" if os.path.realpath(a) == os.path.realpath(b) else "0")
PY
}

ensure_dir() {
  local dir="$1"
  run mkdir -p "$dir"
}

remove_path() {
  local path="$1"
  run rm -rf "$path"
}

install_item() {
  local src="$1"
  local dst="$2"

  if [[ ! -e "$src" && ! -L "$src" ]]; then
    warn "Source missing, skipping: $src"
    return 0
  fi

  if [[ "$(same_realpath "$src" "$dst")" == "1" ]]; then
    log "Already linked/same path: $dst"
    return 0
  fi

  if exists_path "$dst"; then
    if [[ "$FORCE" != "true" ]]; then
      warn "Destination exists (use --force to replace): $dst"
      return 0
    fi
    remove_path "$dst"
  fi

  ensure_dir "$(dirname "$dst")"
  if [[ "$MODE" == "symlink" ]]; then
    run ln -s "$src" "$dst"
  else
    run cp -a "$src" "$dst"
  fi
}

write_gemini_toml() {
  local src_md="$1"
  local dst_toml="$2"
  local fallback_description="$3"

  if [[ "$DRY_RUN" == "true" ]]; then
    printf '[dry-run] render %s -> %s\n' "$src_md" "$dst_toml"
    return 0
  fi

  python3 - "$src_md" "$dst_toml" "$fallback_description" "$FORCE" <<'PY'
from pathlib import Path
import re
import sys

src = Path(sys.argv[1])
dst = Path(sys.argv[2])
fallback = sys.argv[3]
force = sys.argv[4].lower() == "true"

if not src.exists():
    raise SystemExit(f"source missing: {src}")

text = src.read_text(encoding="utf-8")
description = fallback

frontmatter_match = re.match(r"^---\n(.*?)\n---\n", text, flags=re.DOTALL)
if frontmatter_match:
    block = frontmatter_match.group(1)
    desc_match = re.search(r"^description:\s*(.+)$", block, flags=re.MULTILINE)
    if desc_match:
        description = desc_match.group(1).strip().strip('"').strip("'")

description = description.replace('"', '\\"')
prompt_body = text.replace('"""', '\\"""')
rendered = f'description = "{description}"\nprompt = """\n{prompt_body}\n"""\n'

if dst.exists() and not force:
    previous = dst.read_text(encoding="utf-8")
    if previous == rendered:
        print(f"unchanged: {dst}")
        raise SystemExit(0)

dst.parent.mkdir(parents=True, exist_ok=True)
dst.write_text(rendered, encoding="utf-8")
print(f"written: {dst}")
PY
}

load_active_list() {
  local file="$1"
  local -n out_array="$2"

  if [[ ! -f "$file" ]]; then
    err "Active list file not found: $file"
    exit 1
  fi

  out_array=()
  while IFS= read -r line; do
    local trimmed="$line"
    trimmed="${trimmed#"${trimmed%%[![:space:]]*}"}"
    trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
    [[ -z "$trimmed" ]] && continue
    [[ "${trimmed:0:1}" == "#" ]] && continue
    out_array+=("$trimmed")
  done < "$file"
}

load_commands() {
  mapfile -t COMMANDS < <(
    python3 - "$ROOT_DIR" <<'PY'
from pathlib import Path
import sys

root = Path(sys.argv[1])
for path in sorted((root / "commands").glob("*.md")):
    print(path.stem)
PY
  )
}

list_providers() {
  cat <<EOF
Providers and roots:
  - opencode:    $OPENCODE_HOME
  - codex:       $CODEX_HOME
  - gemini:      $GEMINI_HOME
  - antigravity: $ANTIGRAVITY_HOME
  - claudecode:  $CLAUDECODE_HOME
EOF
}

install_opencode() {
  log "Installing provider: opencode ($OPENCODE_HOME)"
  ensure_dir "$OPENCODE_HOME"

  local entries=(
    "AGENTS.md"
    "opencode.json"
    "agents"
    "commands"
    "skills"
    "scripts"
    "docs"
    "modes"
  )

  local entry
  for entry in "${entries[@]}"; do
    install_item "$ROOT_DIR/$entry" "$OPENCODE_HOME/$entry"
  done
}

install_codex() {
  log "Installing provider: codex ($CODEX_HOME)"
  ensure_dir "$CODEX_HOME/skills"
  ensure_dir "$CODEX_HOME/vendor_imports/opencode-baymax/agents"
  ensure_dir "$CODEX_HOME/vendor_imports/opencode-baymax/commands"

  local skill
  for skill in "${SKILLS[@]}"; do
    install_item "$ROOT_DIR/skills/$skill" "$CODEX_HOME/skills/$skill"
  done

  local agent
  for agent in "${AGENTS[@]}"; do
    install_item "$ROOT_DIR/agents/$agent.md" "$CODEX_HOME/vendor_imports/opencode-baymax/agents/$agent.md"
  done

  local cmd
  for cmd in "${COMMANDS[@]}"; do
    install_item "$ROOT_DIR/commands/$cmd.md" "$CODEX_HOME/vendor_imports/opencode-baymax/commands/$cmd.md"
  done

  install_item "$ROOT_DIR/AGENTS.md" "$CODEX_HOME/vendor_imports/opencode-baymax/AGENTS.md"
}

install_gemini() {
  log "Installing provider: gemini ($GEMINI_HOME)"
  ensure_dir "$GEMINI_HOME/skills"
  ensure_dir "$GEMINI_HOME/commands"

  local skill
  for skill in "${SKILLS[@]}"; do
    install_item "$ROOT_DIR/skills/$skill" "$GEMINI_HOME/skills/$skill"
  done

  local cmd
  for cmd in "${COMMANDS[@]}"; do
    write_gemini_toml \
      "$ROOT_DIR/commands/$cmd.md" \
      "$GEMINI_HOME/commands/baymax-$cmd.toml" \
      "Baymax command $cmd"
  done

  local agent
  for agent in "${AGENTS[@]}"; do
    write_gemini_toml \
      "$ROOT_DIR/agents/$agent.md" \
      "$GEMINI_HOME/commands/baymax-agent-$agent.toml" \
      "Baymax agent $agent"
  done
}

install_antigravity() {
  log "Installing provider: antigravity ($ANTIGRAVITY_HOME)"
  ensure_dir "$ANTIGRAVITY_HOME/.agent/skills"
  ensure_dir "$ANTIGRAVITY_HOME/.agent/workflows"

  local skill
  for skill in "${SKILLS[@]}"; do
    install_item \
      "$ROOT_DIR/skills/$skill/SKILL.md" \
      "$ANTIGRAVITY_HOME/.agent/skills/baymax-$skill"
  done

  local cmd
  for cmd in "${COMMANDS[@]}"; do
    install_item \
      "$ROOT_DIR/commands/$cmd.md" \
      "$ANTIGRAVITY_HOME/.agent/workflows/baymax-$cmd.md"
  done

  local agent
  for agent in "${AGENTS[@]}"; do
    install_item \
      "$ROOT_DIR/agents/$agent.md" \
      "$ANTIGRAVITY_HOME/.agent/workflows/baymax-agent-$agent.md"
  done
}

install_claudecode() {
  log "Installing provider: claudecode ($CLAUDECODE_HOME)"
  ensure_dir "$CLAUDECODE_HOME/commands"

  local skill
  for skill in "${SKILLS[@]}"; do
    install_item \
      "$ROOT_DIR/skills/$skill/SKILL.md" \
      "$CLAUDECODE_HOME/commands/baymax-skill-$skill.md"
  done

  local cmd
  for cmd in "${COMMANDS[@]}"; do
    install_item \
      "$ROOT_DIR/commands/$cmd.md" \
      "$CLAUDECODE_HOME/commands/baymax-cmd-$cmd.md"
  done

  local agent
  for agent in "${AGENTS[@]}"; do
    install_item \
      "$ROOT_DIR/agents/$agent.md" \
      "$CLAUDECODE_HOME/commands/baymax-agent-$agent.md"
  done
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --providers)
        PROVIDERS_CSV="${2:-}"
        shift 2
        ;;
      --mode)
        MODE="${2:-}"
        shift 2
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --force)
        FORCE=true
        shift
        ;;
      --list)
        list_providers
        exit 0
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
}

validate_args() {
  if [[ "$MODE" != "symlink" && "$MODE" != "copy" ]]; then
    err "Invalid --mode: $MODE (use symlink|copy)"
    exit 1
  fi
}

main() {
  parse_args "$@"
  validate_args

  load_active_list "$SKILLS_ACTIVE_FILE" SKILLS
  load_active_list "$AGENTS_ACTIVE_FILE" AGENTS
  load_commands

  IFS=',' read -r -a providers <<< "$PROVIDERS_CSV"
  local provider
  for provider in "${providers[@]}"; do
    provider="${provider#"${provider%%[![:space:]]*}"}"
    provider="${provider%"${provider##*[![:space:]]}"}"
    case "$provider" in
      opencode)
        install_opencode
        ;;
      codex)
        install_codex
        ;;
      gemini)
        install_gemini
        ;;
      antigravity)
        install_antigravity
        ;;
      claudecode)
        install_claudecode
        ;;
      "")
        ;;
      *)
        err "Unknown provider: $provider"
        exit 1
        ;;
    esac
  done

  log "Completed. mode=$MODE dry_run=$DRY_RUN force=$FORCE"
}

main "$@"
