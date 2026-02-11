#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/scaffold.sh skill <name> [description]
  ./scripts/scaffold.sh agent <name> [description]
  ./scripts/scaffold.sh command <name> [description]
  ./scripts/scaffold.sh mode <name> [description]

Examples:
  ./scripts/scaffold.sh skill release-checklist "Release process checklist"
  ./scripts/scaffold.sh agent qa-orchestrator "QA planning specialist"
  ./scripts/scaffold.sh command release-plan "Generate release plan"
  ./scripts/scaffold.sh mode research-mode "Read-only research mode"
EOF
}

slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/--+/-/g'
}

if [[ $# -lt 2 ]]; then
  usage
  exit 1
fi

TYPE="$1"
RAW_NAME="$2"
DESCRIPTION="${3:-Auto-generated component}"
NAME="$(slugify "$RAW_NAME")"

if [[ -z "$NAME" ]]; then
  echo "[scaffold][error] Invalid name after slugify: $RAW_NAME" >&2
  exit 1
fi

create_skill() {
  local dir="$ROOT_DIR/skills/$NAME"
  local file="$dir/SKILL.md"
  mkdir -p "$dir"
  if [[ -e "$file" ]]; then
    echo "[scaffold][error] Skill already exists: $file" >&2
    exit 1
  fi
  cat > "$file" <<EOF
---
name: $NAME
description: $DESCRIPTION
compatibility: opencode
metadata:
  domain: custom
---

SKILL: ${NAME^^}

Purpose
- Define the workflow outcome.

When to use
- ...

Inputs
- ...

Steps
1) ...
2) ...
3) ...

Verification
- ...

Safety
- No secret leakage
- Confirmation required for side effects
EOF
  echo "[scaffold] Created skill: skills/$NAME/SKILL.md"
}

create_agent() {
  local file="$ROOT_DIR/agents/$NAME.md"
  if [[ -e "$file" ]]; then
    echo "[scaffold][error] Agent already exists: $file" >&2
    exit 1
  fi
  cat > "$file" <<EOF
---
description: $DESCRIPTION
mode: subagent
temperature: 0.2
permission:
  external_directory:
    "{env:HOME}/.config/opencode/AGENTS.md": allow
    "{env:HOME}/.config/opencode/skills/*": allow
    "{env:HOME}/.config/opencode/agents/*": allow
    "{env:HOME}/.config/opencode/commands/*": allow
    "*": ask
tools:
  skill: true
  write: false
  edit: false
  patch: false
  bash: false
---

You are $NAME.

Responsibilities
- ...

Output contract
- Summary
- Decisions
- Risks
- Next steps
EOF
  echo "[scaffold] Created agent: agents/$NAME.md"
}

create_command() {
  local file="$ROOT_DIR/commands/$NAME.md"
  if [[ -e "$file" ]]; then
    echo "[scaffold][error] Command already exists: $file" >&2
    exit 1
  fi
  cat > "$file" <<EOF
---
description: $DESCRIPTION
agent: planner
subtask: true
---
Handle this request:

\$ARGUMENTS
EOF
  echo "[scaffold] Created command: commands/$NAME.md"
}

create_mode() {
  local file="$ROOT_DIR/modes/$NAME.md"
  if [[ -e "$file" ]]; then
    echo "[scaffold][error] Mode already exists: $file" >&2
    exit 1
  fi
  cat > "$file" <<EOF
---
temperature: 0.2
tools:
  read: true
  glob: true
  grep: true
  write: false
  edit: false
  patch: false
  bash: false
---
You are in $NAME mode.

$DESCRIPTION
EOF
  echo "[scaffold] Created mode: modes/$NAME.md"
}

case "$TYPE" in
  skill)
    create_skill
    ;;
  agent)
    create_agent
    ;;
  command)
    create_command
    ;;
  mode)
    create_mode
    ;;
  *)
    echo "[scaffold][error] Invalid type: $TYPE" >&2
    usage
    exit 1
    ;;
esac

echo "[scaffold] Done. Run ./scripts/doctor.sh and then ./scripts/sync.sh push \"<message>\""
