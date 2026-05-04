#!/usr/bin/env bash
set -u
PAYLOAD="$(cat)"
TOOL="$(printf '%s' "$PAYLOAD" | jq -r '.tool_name // ""')"

case "$TOOL" in
  Read)
    FIELDS_JQ='[.tool_input.file_path] | map(select(. != null and . != ""))'
    ;;
  Grep)
    FIELDS_JQ='[.tool_input.path, .tool_input.glob, .tool_input.pattern] | map(select(. != null and . != ""))'
    ;;
  Glob)
    FIELDS_JQ='[.tool_input.path, .tool_input.pattern] | map(select(. != null and . != ""))'
    ;;
  *)
    exit 0
    ;;
esac

# shellcheck source=sensitive-patterns.sh
. "${BASH_SOURCE[0]%/*}/sensitive-patterns.sh"

# Check each candidate field independently so a non-sensitive sibling field
# (e.g. Grep pattern) can't dilute a match on a sensitive path.
HIT=""
while IFS= read -r FIELD; do
  [ -z "$FIELD" ] && continue
  if printf '%s' "$FIELD" | grep -qiE "$DENY_RE"; then
    HIT="$FIELD"
    break
  fi
done < <(printf '%s' "$PAYLOAD" | jq -r "$FIELDS_JQ"' | .[]')

if [ -n "$HIT" ]; then
  jq -nc --arg reason "Access to sensitive file blocked: $HIT" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
fi
exit 0
