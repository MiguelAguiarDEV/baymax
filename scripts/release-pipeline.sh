#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/release-pipeline.sh \
    --env <pre|prod> \
    --commit-message "<msg>" \
    [--base-branch main] \
    [--pr-title "<title>"] \
    [--pr-body "<body>"] \
    [--pr-body-file <path>] \
    [--chart <chart-path>] \
    [--values <values-file>] \
    [--release <release-name>] \
    [--namespace <namespace>] \
    [--image-tag <sha>] \
    [--hash-source pr|base|branch] \
    [--timeout 10m] \
    [--history-max 20] \
    [--create-namespace] \
    [--helm-dry-run] \
    [--no-deploy] \
    [--allow-new-release]

What it does:
1) Commit + push branch
2) Create PR (or reuse existing PR from current branch)
3) Wait for CI checks to finish (`gh pr checks --watch`)
4) Resolve immutable image tag (commit hash)
5) Auto-detect chart/values/release/namespace where possible
6) Execute safe Helm upgrade via ./scripts/helm-safe-upgrade.sh
EOF
}

log() {
  printf '[release-pipeline] %s\n' "$*"
}

err() {
  printf '[release-pipeline][error] %s\n' "$*" >&2
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    err "Missing command: $cmd"
    exit 1
  fi
}

is_conventional_commit() {
  local message="$1"
  [[ "$message" =~ ^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-zA-Z0-9._/-]+\))?(!)?:[[:space:]].+ ]]
}

ensure_conventional_commit() {
  local message="$1"
  local field_name="$2"
  if ! is_conventional_commit "$message"; then
    err "$field_name must follow Conventional Commits format."
    err "Expected: type(scope): summary"
    err "Example: feat(catalog): add dynamic pricing rule"
    exit 1
  fi
}

read_file_content() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    err "File not found: $file"
    exit 1
  fi
  cat "$file"
}

to_abs_path() {
  local value="$1"
  if [[ "$value" = /* ]]; then
    printf '%s\n' "$value"
  else
    printf '%s\n' "$ROOT_DIR/$value"
  fi
}

to_rel_path() {
  local abs_path="$1"
  python3 - "$ROOT_DIR" "$abs_path" <<'PY'
from pathlib import Path
import sys
root = Path(sys.argv[1]).resolve()
target = Path(sys.argv[2]).resolve()
try:
    print(target.relative_to(root).as_posix())
except ValueError:
    print(target.as_posix())
PY
}

yaml_get_first() {
  local file="$1"
  local paths_csv="$2"
  python3 - "$file" "$paths_csv" <<'PY'
import sys
from pathlib import Path
import yaml

file_path = Path(sys.argv[1])
paths = [p for p in sys.argv[2].split(",") if p]
if not file_path.is_file():
    raise SystemExit(1)

try:
    data = yaml.safe_load(file_path.read_text(encoding="utf-8"))
except Exception:
    data = None

def resolve(obj, path):
    cur = obj
    for part in path.split("."):
        if not isinstance(cur, dict) or part not in cur:
            return None
        cur = cur[part]
    return cur

if isinstance(data, dict):
    for path in paths:
        value = resolve(data, path)
        if value is None:
            continue
        if isinstance(value, (str, int, float)):
            text = str(value).strip()
            if text:
                print(text)
                raise SystemExit(0)
print("")
PY
}

chart_name_from_chart_yaml() {
  local chart_yaml="$1"
  python3 - "$chart_yaml" <<'PY'
import sys
from pathlib import Path
import yaml

path = Path(sys.argv[1])
if not path.is_file():
    print("")
    raise SystemExit(0)

try:
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
except Exception:
    print("")
    raise SystemExit(0)

if isinstance(data, dict):
    name = str(data.get("name", "")).strip()
    print(name)
else:
    print("")
PY
}

select_chart_path() {
  if [[ -n "$CHART" ]]; then
    local abs_chart
    abs_chart="$(to_abs_path "$CHART")"
    if [[ ! -d "$abs_chart" ]]; then
      err "Chart path not found: $CHART"
      exit 1
    fi
    CHART="$(to_rel_path "$abs_chart")"
    return
  fi

  mapfile -t chart_files < <(cd "$ROOT_DIR" && rg --files -g '**/Chart.yaml')
  if [[ ${#chart_files[@]} -eq 0 ]]; then
    err "No Chart.yaml found. Provide --chart explicitly."
    exit 1
  fi

  if [[ ${#chart_files[@]} -eq 1 ]]; then
    CHART="$(dirname "${chart_files[0]}")"
    return
  fi

  local preferred=""
  local candidate
  for candidate in "${chart_files[@]}"; do
    case "$candidate" in
      ci/helm-package/Chart.yaml)
        preferred="$candidate"
        break
        ;;
      */helm/*/Chart.yaml|helm/*/Chart.yaml|*/chart/*/Chart.yaml|chart/*/Chart.yaml)
        if [[ -z "$preferred" ]]; then
          preferred="$candidate"
        fi
        ;;
    esac
  done

  if [[ -n "$preferred" ]]; then
    CHART="$(dirname "$preferred")"
    return
  fi

  err "Multiple Chart.yaml files found and no safe default."
  printf '%s\n' "${chart_files[@]}" >&2
  err "Provide --chart explicitly."
  exit 1
}

select_values_file() {
  if [[ -n "$VALUES_FILE" ]]; then
    local abs_values
    abs_values="$(to_abs_path "$VALUES_FILE")"
    if [[ ! -f "$abs_values" ]]; then
      err "Values file not found: $VALUES_FILE"
      exit 1
    fi
    VALUES_FILE="$(to_rel_path "$abs_values")"
    return
  fi

  local chart_abs
  chart_abs="$(to_abs_path "$CHART")"
  shopt -s nullglob
  local all_values=("$chart_abs"/values*.yaml "$chart_abs"/values*.yml)
  shopt -u nullglob

  if [[ ${#all_values[@]} -eq 0 ]]; then
    err "No values files found under chart path: $CHART"
    exit 1
  fi

  local tokens=()
  case "$ENVIRONMENT" in
    prod)
      tokens=(prod pro production)
      ;;
    pre)
      tokens=(pre stage staging stg qa uat dev)
      ;;
    *)
      tokens=("$ENVIRONMENT")
      ;;
  esac

  local token
  local selected=""
  for token in "${tokens[@]}"; do
    local variant
    for variant in \
      "$chart_abs/values-$token.yaml" \
      "$chart_abs/values-$token.yml" \
      "$chart_abs/values.$token.yaml" \
      "$chart_abs/values.$token.yml" \
      "$chart_abs/values_${token}.yaml" \
      "$chart_abs/values_${token}.yml"; do
      if [[ -f "$variant" ]]; then
        selected="$variant"
        break
      fi
    done
    if [[ -n "$selected" ]]; then
      break
    fi
  done

  if [[ -z "$selected" && -f "$chart_abs/values.yaml" ]]; then
    selected="$chart_abs/values.yaml"
  fi

  if [[ -z "$selected" && ${#all_values[@]} -eq 1 ]]; then
    selected="${all_values[0]}"
  fi

  if [[ -z "$selected" ]]; then
    err "Could not auto-detect values file under $CHART. Provide --values."
    printf '%s\n' "${all_values[@]}" >&2
    exit 1
  fi

  VALUES_FILE="$(to_rel_path "$selected")"
}

find_release_in_cluster() {
  local chart_name="$1"
  local namespace="$2"
  python3 - "$chart_name" "$namespace" <<'PY'
import json
import subprocess
import sys

chart_name = sys.argv[1]
namespace = sys.argv[2]
if not chart_name or not namespace:
    print("")
    raise SystemExit(0)

try:
    out = subprocess.check_output(
        ["helm", "list", "-n", namespace, "-o", "json"],
        text=True,
        stderr=subprocess.DEVNULL,
    )
except Exception:
    print("")
    raise SystemExit(0)

try:
    data = json.loads(out)
except Exception:
    print("")
    raise SystemExit(0)

if not isinstance(data, list):
    print("")
    raise SystemExit(0)

matches = []
for item in data:
    if not isinstance(item, dict):
        continue
    chart = str(item.get("chart", ""))
    name = str(item.get("name", ""))
    if chart.startswith(chart_name + "-") and name:
        matches.append(name)

matches = sorted(set(matches))
if len(matches) == 1:
    print(matches[0])
else:
    print("")
PY
}

find_namespace_for_release() {
  local release="$1"
  python3 - "$release" <<'PY'
import json
import subprocess
import sys

release = sys.argv[1]
if not release:
    print("")
    raise SystemExit(0)

try:
    out = subprocess.check_output(
        ["helm", "list", "-A", "-o", "json"],
        text=True,
        stderr=subprocess.DEVNULL,
    )
except Exception:
    print("")
    raise SystemExit(0)

try:
    data = json.loads(out)
except Exception:
    print("")
    raise SystemExit(0)

if not isinstance(data, list):
    print("")
    raise SystemExit(0)

namespaces = sorted(
    {
        str(item.get("namespace", "")).strip()
        for item in data
        if isinstance(item, dict) and str(item.get("name", "")).strip() == release
    }
)
namespaces = [ns for ns in namespaces if ns]
if len(namespaces) == 1:
    print(namespaces[0])
else:
    print("")
PY
}

select_release_and_namespace() {
  local chart_abs chart_name chart_yaml values_abs
  chart_abs="$(to_abs_path "$CHART")"
  chart_yaml="$chart_abs/Chart.yaml"
  values_abs="$(to_abs_path "$VALUES_FILE")"
  chart_name="$(chart_name_from_chart_yaml "$chart_yaml")"

  if [[ -z "$NAMESPACE" ]]; then
    NAMESPACE="$(yaml_get_first "$values_abs" "namespace,global.namespace,targetNamespace")"
  fi

  if [[ -z "$RELEASE" ]]; then
    RELEASE="$(yaml_get_first "$values_abs" "releaseName,global.releaseName,fullnameOverride,nameOverride")"
  fi

  if [[ -z "$NAMESPACE" && -n "$RELEASE" ]]; then
    NAMESPACE="$(find_namespace_for_release "$RELEASE")"
  fi

  if [[ -z "$RELEASE" && -n "$NAMESPACE" ]]; then
    RELEASE="$(find_release_in_cluster "$chart_name" "$NAMESPACE")"
  fi

  if [[ -z "$RELEASE" && "$ALLOW_NEW_RELEASE" == true && -n "$chart_name" ]]; then
    RELEASE="$chart_name"
    log "Release not found in cluster; using chart name fallback: $RELEASE"
  fi

  if [[ -z "$NAMESPACE" ]]; then
    err "Could not auto-detect namespace. Provide --namespace."
    exit 1
  fi

  if [[ -z "$RELEASE" ]]; then
    err "Could not auto-detect release name. Provide --release or use --allow-new-release."
    exit 1
  fi
}

resolve_pr_metadata() {
  local branch="$1"
  if gh pr view "$branch" --json number,url,state >/dev/null 2>&1; then
    PR_NUMBER="$(gh pr view "$branch" --json number --jq '.number')"
    PR_URL="$(gh pr view "$branch" --json url --jq '.url')"
    return
  fi

  if [[ -z "$PR_TITLE" ]]; then
    PR_TITLE="$(git -C "$ROOT_DIR" log -1 --pretty=%s)"
  fi
  ensure_conventional_commit "$PR_TITLE" "PR title"

  if [[ -n "$PR_BODY_FILE" ]]; then
    local body_file_abs
    body_file_abs="$(to_abs_path "$PR_BODY_FILE")"
    PR_BODY="$(read_file_content "$body_file_abs")"
  fi

  if [[ -z "$PR_BODY" ]]; then
    local template_file="$ROOT_DIR/.github/pull_request_template.md"
    if [[ -f "$template_file" ]]; then
      PR_BODY="$(read_file_content "$template_file")"
    fi
  fi

  if [[ -z "$PR_BODY" ]]; then
    PR_BODY="Automated release PR created by scripts/release-pipeline.sh"
  fi

  gh pr create \
    --base "$BASE_BRANCH" \
    --head "$branch" \
    --title "$PR_TITLE" \
    --body "$PR_BODY" >/dev/null

  PR_NUMBER="$(gh pr view "$branch" --json number --jq '.number')"
  PR_URL="$(gh pr view "$branch" --json url --jq '.url')"
}

wait_for_ci_checks() {
  local pr_number="$1"
  log "Waiting for PR checks to complete (PR #$pr_number)..."
  gh pr checks "$pr_number" --watch
}

resolve_image_tag() {
  if [[ -n "$IMAGE_TAG" ]]; then
    return
  fi

  local source="$HASH_SOURCE"
  if [[ -z "$source" ]]; then
    source="pr"
  fi

  case "$source" in
    pr)
      IMAGE_TAG="$(gh pr view "$PR_NUMBER" --json headRefOid --jq '.headRefOid[:12]')"
      ;;
    base)
      git -C "$ROOT_DIR" fetch origin "$BASE_BRANCH" --quiet
      IMAGE_TAG="$(git -C "$ROOT_DIR" rev-parse --short=12 "origin/$BASE_BRANCH")"
      ;;
    branch)
      IMAGE_TAG="$(git -C "$ROOT_DIR" rev-parse --short=12 HEAD)"
      ;;
    *)
      err "Invalid --hash-source: $source (use pr|base|branch)"
      exit 1
      ;;
  esac
}

commit_and_push() {
  local branch
  branch="$(git -C "$ROOT_DIR" rev-parse --abbrev-ref HEAD)"
  if [[ -z "$branch" || "$branch" == "HEAD" ]]; then
    err "Detached HEAD is not supported for release pipeline."
    exit 1
  fi

  if [[ -n "$(git -C "$ROOT_DIR" status --porcelain)" ]]; then
    if [[ -z "$COMMIT_MESSAGE" ]]; then
      err "Working tree has changes. Provide --commit-message."
      exit 1
    fi
    ensure_conventional_commit "$COMMIT_MESSAGE" "Commit message"
    log "Committing changes..."
    git -C "$ROOT_DIR" add -A
    if [[ -n "$(git -C "$ROOT_DIR" diff --cached --name-only)" ]]; then
      git -C "$ROOT_DIR" commit -m "$COMMIT_MESSAGE"
    fi
  fi

  log "Pushing branch: $branch"
  git -C "$ROOT_DIR" push -u origin "$branch"
  CURRENT_BRANCH="$branch"
}

print_summary() {
  cat <<EOF

[release-pipeline] Summary
- Environment: $ENVIRONMENT
- Branch: $CURRENT_BRANCH
- PR: #$PR_NUMBER ($PR_URL)
- Chart: $CHART
- Values: $VALUES_FILE
- Release: $RELEASE
- Namespace: $NAMESPACE
- Image tag: $IMAGE_TAG
EOF
}

ENVIRONMENT=""
BASE_BRANCH="main"
COMMIT_MESSAGE=""
PR_TITLE=""
PR_BODY=""
PR_BODY_FILE=""
CHART=""
VALUES_FILE=""
RELEASE=""
NAMESPACE=""
IMAGE_TAG=""
HASH_SOURCE=""
TIMEOUT="10m"
HISTORY_MAX="20"
CREATE_NAMESPACE=false
HELM_DRY_RUN=false
NO_DEPLOY=false
ALLOW_NEW_RELEASE=false

CURRENT_BRANCH=""
PR_NUMBER=""
PR_URL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)
      ENVIRONMENT="${2:-}"
      shift 2
      ;;
    --base-branch)
      BASE_BRANCH="${2:-}"
      shift 2
      ;;
    --commit-message)
      COMMIT_MESSAGE="${2:-}"
      shift 2
      ;;
    --pr-title)
      PR_TITLE="${2:-}"
      shift 2
      ;;
    --pr-body)
      PR_BODY="${2:-}"
      shift 2
      ;;
    --pr-body-file)
      PR_BODY_FILE="${2:-}"
      shift 2
      ;;
    --chart)
      CHART="${2:-}"
      shift 2
      ;;
    --values)
      VALUES_FILE="${2:-}"
      shift 2
      ;;
    --release)
      RELEASE="${2:-}"
      shift 2
      ;;
    --namespace)
      NAMESPACE="${2:-}"
      shift 2
      ;;
    --image-tag)
      IMAGE_TAG="${2:-}"
      shift 2
      ;;
    --hash-source)
      HASH_SOURCE="${2:-}"
      shift 2
      ;;
    --timeout)
      TIMEOUT="${2:-}"
      shift 2
      ;;
    --history-max)
      HISTORY_MAX="${2:-}"
      shift 2
      ;;
    --create-namespace)
      CREATE_NAMESPACE=true
      shift
      ;;
    --helm-dry-run)
      HELM_DRY_RUN=true
      shift
      ;;
    --no-deploy)
      NO_DEPLOY=true
      shift
      ;;
    --allow-new-release)
      ALLOW_NEW_RELEASE=true
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

if [[ "$ENVIRONMENT" != "pre" && "$ENVIRONMENT" != "prod" ]]; then
  err "--env must be one of: pre | prod"
  usage
  exit 1
fi

require_cmd git
require_cmd gh
require_cmd rg
require_cmd python3

if [[ "$NO_DEPLOY" == false ]]; then
  require_cmd helm
fi

commit_and_push
resolve_pr_metadata "$CURRENT_BRANCH"
wait_for_ci_checks "$PR_NUMBER"
resolve_image_tag

if [[ "$NO_DEPLOY" == true ]]; then
  print_summary
  log "Skipping deploy (--no-deploy)."
  exit 0
fi

select_chart_path
select_values_file
select_release_and_namespace
print_summary

HELM_CMD=(
  "$ROOT_DIR/scripts/helm-safe-upgrade.sh"
  --release "$RELEASE"
  --chart "$CHART"
  --namespace "$NAMESPACE"
  --values "$VALUES_FILE"
  --image-tag "$IMAGE_TAG"
  --timeout "$TIMEOUT"
  --history-max "$HISTORY_MAX"
)

if [[ "$CREATE_NAMESPACE" == true ]]; then
  HELM_CMD+=(--create-namespace)
fi
if [[ "$HELM_DRY_RUN" == true ]]; then
  HELM_CMD+=(--dry-run)
fi

log "Running Helm safe upgrade..."
"${HELM_CMD[@]}"
log "Release pipeline completed."
