#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  config-lifecycle.sh --entity <entity> --id <id> [--env prod|stage|dev] [--updated <json-file>] [--artifacts-root <dir>]

Supported entities:
  device-config
  config-template
  view
  teleop-view
  module-configuration
USAGE
}

ENTITY=""
RESOURCE_ID=""
ENV_NAME="prod"
UPDATED_FILE=""
ARTIFACTS_ROOT=".formant-admin-artifacts"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --entity)
      ENTITY="${2:-}"
      shift 2
      ;;
    --id)
      RESOURCE_ID="${2:-}"
      shift 2
      ;;
    --env)
      ENV_NAME="${2:-}"
      shift 2
      ;;
    --updated)
      UPDATED_FILE="${2:-}"
      shift 2
      ;;
    --artifacts-root)
      ARTIFACTS_ROOT="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$ENTITY" || -z "$RESOURCE_ID" ]]; then
  usage
  exit 1
fi

if [[ "$ENV_NAME" != "prod" && "$ENV_NAME" != "stage" && "$ENV_NAME" != "dev" ]]; then
  echo "Invalid --env value: $ENV_NAME" >&2
  exit 1
fi

if ! command -v formant >/dev/null 2>&1; then
  echo "formant CLI not found on PATH" >&2
  exit 1
fi

if [[ -n "$UPDATED_FILE" && ! -f "$UPDATED_FILE" ]]; then
  echo "Updated file not found: $UPDATED_FILE" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required for lifecycle artifacts" >&2
  exit 1
fi

ENV_FLAG=""
if [[ "$ENV_NAME" == "stage" ]]; then
  ENV_FLAG="--stage"
elif [[ "$ENV_NAME" == "dev" ]]; then
  ENV_FLAG="--dev"
fi

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
BUNDLE_DIR="$ARTIFACTS_ROOT/$TIMESTAMP-$ENTITY-$RESOURCE_ID"
mkdir -p "$BUNDLE_DIR"

write_meta() {
  local phase="$1"
  jq -n \
    --arg phase "$phase" \
    --arg entity "$ENTITY" \
    --arg id "$RESOURCE_ID" \
    --arg env "$ENV_NAME" \
    --arg timestamp "$TIMESTAMP" \
    --arg updated_file "$UPDATED_FILE" \
    '{phase:$phase, entity:$entity, id:$id, env:$env, timestamp:$timestamp, updatedFile:$updated_file}' \
    > "$BUNDLE_DIR/meta.json"
}

normalize_json() {
  local input="$1"
  local output="$2"
  jq -S . "$input" > "$output"
}

fetch_before() {
  case "$ENTITY" in
    device-config)
      formant device config "$RESOURCE_ID" --json ${ENV_FLAG} > "$BUNDLE_DIR/before.raw.json"
      jq '.config.document // .document // .config // .' "$BUNDLE_DIR/before.raw.json" > "$BUNDLE_DIR/before.json"
      ;;
    config-template)
      formant config-template get "$RESOURCE_ID" --json ${ENV_FLAG} > "$BUNDLE_DIR/before.json"
      ;;
    view)
      formant view get "$RESOURCE_ID" --json ${ENV_FLAG} > "$BUNDLE_DIR/before.json"
      ;;
    teleop-view)
      formant teleop-view get "$RESOURCE_ID" --json ${ENV_FLAG} > "$BUNDLE_DIR/before.json"
      ;;
    module-configuration)
      formant module-configuration get "$RESOURCE_ID" --json ${ENV_FLAG} > "$BUNDLE_DIR/before.json"
      ;;
    *)
      echo "Unsupported entity: $ENTITY" >&2
      exit 1
      ;;
  esac
}

apply_update() {
  case "$ENTITY" in
    device-config)
      jq '.config.document // .document // .config // .' "$UPDATED_FILE" > "$BUNDLE_DIR/after.request.json"
      formant device apply-config "$RESOURCE_ID" --file "$BUNDLE_DIR/after.request.json" ${ENV_FLAG} > "$BUNDLE_DIR/apply-result.json"
      ;;
    config-template)
      cp "$UPDATED_FILE" "$BUNDLE_DIR/after.request.json"
      formant config-template update "$RESOURCE_ID" --file "$BUNDLE_DIR/after.request.json" ${ENV_FLAG} > "$BUNDLE_DIR/apply-result.json"
      ;;
    view)
      cp "$UPDATED_FILE" "$BUNDLE_DIR/after.request.json"
      formant view update "$RESOURCE_ID" --file "$BUNDLE_DIR/after.request.json" ${ENV_FLAG} > "$BUNDLE_DIR/apply-result.json"
      ;;
    teleop-view)
      cp "$UPDATED_FILE" "$BUNDLE_DIR/after.request.json"
      formant teleop-view update "$RESOURCE_ID" --file "$BUNDLE_DIR/after.request.json" ${ENV_FLAG} > "$BUNDLE_DIR/apply-result.json"
      ;;
    module-configuration)
      cp "$UPDATED_FILE" "$BUNDLE_DIR/after.request.json"
      formant module-configuration update "$RESOURCE_ID" --file "$BUNDLE_DIR/after.request.json" ${ENV_FLAG} > "$BUNDLE_DIR/apply-result.json"
      ;;
    *)
      echo "Unsupported entity: $ENTITY" >&2
      exit 1
      ;;
  esac
}

fetch_after_live() {
  case "$ENTITY" in
    device-config)
      formant device config "$RESOURCE_ID" --json ${ENV_FLAG} > "$BUNDLE_DIR/after.live.raw.json"
      jq '.config.document // .document // .config // .' "$BUNDLE_DIR/after.live.raw.json" > "$BUNDLE_DIR/after.live.json"
      ;;
    config-template)
      formant config-template get "$RESOURCE_ID" --json ${ENV_FLAG} > "$BUNDLE_DIR/after.live.json"
      ;;
    view)
      formant view get "$RESOURCE_ID" --json ${ENV_FLAG} > "$BUNDLE_DIR/after.live.json"
      ;;
    teleop-view)
      formant teleop-view get "$RESOURCE_ID" --json ${ENV_FLAG} > "$BUNDLE_DIR/after.live.json"
      ;;
    module-configuration)
      formant module-configuration get "$RESOURCE_ID" --json ${ENV_FLAG} > "$BUNDLE_DIR/after.live.json"
      ;;
    *)
      echo "Unsupported entity: $ENTITY" >&2
      exit 1
      ;;
  esac
}

write_rollback_script() {
  local rollback_path="$BUNDLE_DIR/rollback.sh"
  cat > "$rollback_path" <<ROLLBACK
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
BEFORE_PATH="\$SCRIPT_DIR/before.json"
ENTITY="$ENTITY"
RESOURCE_ID="$RESOURCE_ID"
ENV_NAME="$ENV_NAME"
ENV_FLAG=""
if [[ "\$ENV_NAME" == "stage" ]]; then
  ENV_FLAG="--stage"
elif [[ "\$ENV_NAME" == "dev" ]]; then
  ENV_FLAG="--dev"
fi

case "\$ENTITY" in
  device-config)
    formant device apply-config "\$RESOURCE_ID" --file "\$BEFORE_PATH" \$ENV_FLAG
    ;;
  config-template)
    formant config-template update "\$RESOURCE_ID" --file "\$BEFORE_PATH" \$ENV_FLAG
    ;;
  view)
    formant view update "\$RESOURCE_ID" --file "\$BEFORE_PATH" \$ENV_FLAG
    ;;
  teleop-view)
    formant teleop-view update "\$RESOURCE_ID" --file "\$BEFORE_PATH" \$ENV_FLAG
    ;;
  module-configuration)
    formant module-configuration update "\$RESOURCE_ID" --file "\$BEFORE_PATH" \$ENV_FLAG
    ;;
  *)
    echo "Unsupported entity: \$ENTITY" >&2
    exit 1
    ;;
esac
ROLLBACK
  chmod +x "$rollback_path"
}

fetch_before
normalize_json "$BUNDLE_DIR/before.json" "$BUNDLE_DIR/before.normalized.json"

if [[ -n "$UPDATED_FILE" ]]; then
  apply_update
  fetch_after_live
  normalize_json "$BUNDLE_DIR/after.live.json" "$BUNDLE_DIR/after.normalized.json"
  diff -u "$BUNDLE_DIR/before.normalized.json" "$BUNDLE_DIR/after.normalized.json" > "$BUNDLE_DIR/changes.diff" || true
  write_meta "applied"
else
  write_meta "snapshot-only"
fi

write_rollback_script

cat <<OUT
Lifecycle artifact bundle created:
  $BUNDLE_DIR

Key files:
  before.json
  before.normalized.json
  rollback.sh
OUT

if [[ -n "$UPDATED_FILE" ]]; then
  cat <<OUT
  after.request.json
  apply-result.json
  after.live.json
  after.normalized.json
  changes.diff
OUT
fi
