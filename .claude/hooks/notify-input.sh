#!/usr/bin/env bash
PAYLOAD="$(cat)"
MSG="$(printf '%s' "$PAYLOAD" | jq -r '.message // "Claude needs your attention"' 2>/dev/null || echo "Claude needs your attention")"
notify-send -a 'Claude Code' -u critical -i dialog-question 'Claude Code' "$MSG" >/dev/null 2>&1 &
canberra-gtk-play -i bell >/dev/null 2>&1 &
exit 0
