#!/usr/bin/env bash
# Sourced by block-sensitive.sh and block-sensitive-prompt.sh.
# Extended-regex (grep -E) pattern. Matches sensitive file paths.
DENY_RE='(^|/)\.env($|\.|/)|\.pem($|[^a-zA-Z])|\.key($|[^a-zA-Z])|(^|/)id_rsa($|[._/])|(^|/)id_ed25519($|[._/])|\.p12($|[^a-zA-Z])|\.pfx($|[^a-zA-Z])'
