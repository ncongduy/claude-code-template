#!/usr/bin/env bash
set -u
PAYLOAD="$(cat)"
PROMPT="$(printf '%s' "$PAYLOAD" | jq -r '.prompt // ""')"

# shellcheck source=sensitive-patterns.sh
. "${BASH_SOURCE[0]%/*}/sensitive-patterns.sh"

HIT=""
while IFS= read -r TOKEN; do
  [ -z "$TOKEN" ] && continue
  TOKEN="${TOKEN#@}"
  if printf '%s' "$TOKEN" | grep -qiE "$DENY_RE"; then
    HIT="$TOKEN"
    break
  fi
done < <(printf '%s' "$PROMPT" | grep -oE '@[^[:space:]]+' || true)

if [ -n "$HIT" ]; then
  jq -nc --arg reason "Access to sensitive file blocked: $HIT" '{
    decision: "block",
    reason: $reason
  }'
fi
exit 0
