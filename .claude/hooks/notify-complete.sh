#!/usr/bin/env bash
cat >/dev/null
notify-send -a 'Claude Code' -i dialog-information 'Claude Code' 'Task complete' >/dev/null 2>&1 &
canberra-gtk-play -i complete >/dev/null 2>&1 &
exit 0
