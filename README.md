# claude-code-template

A starter project for [Claude Code](https://docs.claude.com/claude-code) with four hooks pre-wired:

| Hook | Behavior |
|------|----------|
| `Notification` | Desktop alert when Claude is waiting on you. |
| `Stop` | Desktop alert when Claude finishes a task. |
| `PreToolUse` (Read / Grep / Glob) | Denies access to `.env*`, `*.pem`, `*.key`, `id_rsa`, `id_ed25519`, `*.p12`, `*.pfx`. |
| `UserPromptSubmit` / `PreToolUse` / `PostToolUse` / `Notification` / `Stop` | Append a timestamped JSONL entry to `.claude/logs/history-YYYY-MM-DD.log`. |

## Use it

```bash
git clone <this-repo> my-project
cd my-project
claude
```

The hooks fire automatically — no extra setup beyond the dependencies below.

## Dependencies

- `jq` — JSON parsing inside the scripts.
- `notify-send` (libnotify) — desktop notifications.
- `canberra-gtk-play` (libcanberra) — notification sound.

```bash
# Debian/Ubuntu
sudo apt install jq libnotify-bin libcanberra-gtk-module
```

On macOS, swap `notify-send` for `osascript -e 'display notification ...'` and `canberra-gtk-play` for `afplay`.

## Layout

```
.claude/
├── settings.json              # wires all hooks
├── hooks/
│   ├── notify-input.sh        # Notification → desktop alert
│   ├── notify-complete.sh     # Stop → desktop alert
│   ├── block-sensitive.sh     # PreToolUse → deny secret-file reads
│   └── log-history.sh         # all events → JSONL log
└── logs/                      # committed; one file per day
```

## Customising the deny list

Edit the `DENY_RE` regex in `.claude/hooks/block-sensitive.sh`. Each alternative is a POSIX ERE pattern; add a new `|...` clause and re-test:

```bash
echo '{"tool_name":"Read","tool_input":{"file_path":"secrets.json"}}' \
  | .claude/hooks/block-sensitive.sh
```

Expect a `permissionDecision: "deny"` JSON blob on stdout when the path matches.

## Logs are committed by design

`.claude/logs/` is **not** gitignored. Strip the directory before pushing this repo anywhere public — prompts and tool inputs end up in those files.
