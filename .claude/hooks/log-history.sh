#!/usr/bin/env bash
set -u
EVENT="${1:-${CLAUDE_HOOK_EVENT:-unknown}}"
LOG_DIR="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/history-$(date +%Y-%m-%d).log"

TS="$(date -Iseconds)"
PAYLOAD="$(cat)"

if command -v jq >/dev/null 2>&1 && [ -n "$PAYLOAD" ]; then
  COMPACT="$(printf '%s' "$PAYLOAD" | jq -c . 2>/dev/null || printf '%s' "$PAYLOAD" | tr '\n' ' ')"
else
  COMPACT="$(printf '%s' "$PAYLOAD" | tr '\n' ' ')"
fi

printf '%s [%s] %s\n' "$TS" "$EVENT" "$COMPACT" >> "$LOG_FILE"
exit 0
