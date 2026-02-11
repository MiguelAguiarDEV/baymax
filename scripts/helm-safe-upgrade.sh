#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/helm-safe-upgrade.sh \
    --release <name> \
    --chart <chart-path> \
    --namespace <namespace> \
    --values <values-file> \
    --image-tag <sha> \
    [--timeout 10m] \
    [--history-max 20] \
    [--create-namespace] \
    [--dry-run]

Example:
  ./scripts/helm-safe-upgrade.sh \
    --release husqvarna-catalogo-2026 \
    --chart ./ci/helm-package \
    --namespace husqvarna \
    --values ./ci/helm-package/values-pro.yaml \
    --image-tag 3f72a9d1f2ab \
    --create-namespace
EOF
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[helm-safe-upgrade][error] Missing command: $cmd" >&2
    exit 1
  fi
}

RELEASE=""
CHART=""
NAMESPACE=""
VALUES_FILE=""
IMAGE_TAG=""
TIMEOUT="10m"
HISTORY_MAX="20"
CREATE_NAMESPACE=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --release)
      RELEASE="${2:-}"
      shift 2
      ;;
    --chart)
      CHART="${2:-}"
      shift 2
      ;;
    --namespace)
      NAMESPACE="${2:-}"
      shift 2
      ;;
    --values)
      VALUES_FILE="${2:-}"
      shift 2
      ;;
    --image-tag)
      IMAGE_TAG="${2:-}"
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
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[helm-safe-upgrade][error] Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$RELEASE" || -z "$CHART" || -z "$NAMESPACE" || -z "$VALUES_FILE" || -z "$IMAGE_TAG" ]]; then
  echo "[helm-safe-upgrade][error] Missing required arguments." >&2
  usage
  exit 1
fi

require_cmd helm

if [[ ! -d "$CHART" ]]; then
  echo "[helm-safe-upgrade][error] Chart path not found: $CHART" >&2
  exit 1
fi

if [[ ! -f "$VALUES_FILE" ]]; then
  echo "[helm-safe-upgrade][error] Values file not found: $VALUES_FILE" >&2
  exit 1
fi

echo "[helm-safe-upgrade] Linting chart..."
helm lint "$CHART" -f "$VALUES_FILE"

HELM_ARGS=(
  upgrade
  --install
  "$RELEASE"
  "$CHART"
  --namespace "$NAMESPACE"
  -f "$VALUES_FILE"
  --set-string "image.tag=$IMAGE_TAG"
  --atomic
  --wait
  --timeout "$TIMEOUT"
  --cleanup-on-fail
  --history-max "$HISTORY_MAX"
)

if [[ "$CREATE_NAMESPACE" == true ]]; then
  HELM_ARGS+=(--create-namespace)
fi

if [[ "$DRY_RUN" == true ]]; then
  HELM_ARGS+=(--dry-run)
  echo "[helm-safe-upgrade] Executing dry-run upgrade..."
else
  echo "[helm-safe-upgrade] Executing safe upgrade..."
fi

echo "[helm-safe-upgrade] Command: helm ${HELM_ARGS[*]}"
helm "${HELM_ARGS[@]}"

echo "[helm-safe-upgrade] Done."
