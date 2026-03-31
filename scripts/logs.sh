#!/usr/bin/env bash
# logs.sh — Stream recent simulator device logs
# Usage: ./logs.sh [--lines 50] [--severity error|warning|info] [--bundle com.example.app] [--udid UDID]

source "$(dirname "$0")/_utils.sh"

UDID=""; LINES=50; SEVERITY=""; BUNDLE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --udid)     UDID="$2"; shift 2 ;;
    --lines)    LINES="$2"; shift 2 ;;
    --severity) SEVERITY="$2"; shift 2 ;;
    --bundle)   BUNDLE="$2"; shift 2 ;;
    *) shift ;;
  esac
done

UDID=$(get_udid "$UDID") || die "No booted simulator found."

CMD=(xcrun simctl spawn "$UDID" log show --last 2m --style compact)
[[ -n "$BUNDLE" ]] && CMD+=(--predicate "subsystem CONTAINS \"$BUNDLE\" OR process CONTAINS \"$BUNDLE\"")

RESULT=$("${CMD[@]}" 2>/dev/null | tail -n "$LINES")

if [[ -n "$SEVERITY" ]]; then
  case "$SEVERITY" in
    error|warning|info|debug) ;;
    *) echo "{\"success\": false, \"error\": \"Invalid severity: $SEVERITY. Use: error, warning, info, debug\"}"; exit 1 ;;
  esac
  RESULT=$(echo "$RESULT" | grep -iF "$SEVERITY" || true)
fi

echo "$RESULT"
