#!/usr/bin/env bash
# type_text.sh — Type text into the focused field
# Usage: ./type_text.sh <text> [--udid UDID]
# Requires: idb

source "$(dirname "$0")/_utils.sh"

TEXT="${1:-}"; shift 1 2>/dev/null || true
UDID=""

while [[ $# -gt 0 ]]; do
  case $1 in --udid) UDID="$2"; shift 2 ;; *) shift ;; esac
done

[[ -z "$TEXT" ]] && die "Usage: type_text.sh <text> [--udid UDID]"

UDID=$(get_udid "$UDID") || die "No booted simulator found."

if command -v idb &>/dev/null; then
  idb --udid "$UDID" ui text "$TEXT" 2>&1
  python3 -c "import json,sys; print(json.dumps({'success':True,'action':'type_text','text':sys.argv[1]}))" "$TEXT"
else
  die "idb not found. Install: brew install idb-companion && pip install fb-idb"
fi
