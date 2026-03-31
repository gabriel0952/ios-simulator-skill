#!/usr/bin/env bash
# launch_app.sh — Launch an installed app by bundle ID
# Usage: ./launch_app.sh <bundle_id> [--udid UDID]

source "$(dirname "$0")/_utils.sh"

BUNDLE="${1:-}"; shift 1 2>/dev/null || true
UDID=""
while [[ $# -gt 0 ]]; do
  case $1 in --udid) UDID="$2"; shift 2 ;; *) shift ;; esac
done

[[ -z "$BUNDLE" ]] && die "Usage: launch_app.sh <bundle_id> [--udid UDID]"
UDID=$(get_udid "$UDID") || die "No booted simulator found."

OUT=$(xcrun simctl launch "$UDID" "$BUNDLE" 2>&1)
if [[ $? -eq 0 ]]; then
  echo "{\"success\": true, \"message\": \"Launched $BUNDLE\", \"output\": \"$OUT\"}"
else
  die "$OUT"
fi
