#!/usr/bin/env bash
# swipe.sh — Swipe gesture on the simulator
# Usage: ./swipe.sh <x1> <y1> <x2> <y2> [--duration 0.3] [--udid UDID]
# Example (scroll down): ./swipe.sh 196 600 196 200

source "$(dirname "$0")/_utils.sh"

X1="${1:-}"; Y1="${2:-}"; X2="${3:-}"; Y2="${4:-}"; shift 4 2>/dev/null || true
UDID=""; DURATION="0.3"

while [[ $# -gt 0 ]]; do
  case $1 in
    --udid) UDID="$2"; shift 2 ;;
    --duration) DURATION="$2"; shift 2 ;;
    *) shift ;;
  esac
done

[[ -z "$X1" || -z "$Y1" || -z "$X2" || -z "$Y2" ]] && die "Usage: swipe.sh <x1> <y1> <x2> <y2> [--duration D] [--udid UDID]"

UDID=$(get_udid "$UDID") || die "No booted simulator found."

if command -v idb &>/dev/null; then
  idb --udid "$UDID" ui swipe "$X1" "$Y1" "$X2" "$Y2" "$DURATION" 2>&1
  echo "{\"success\": true, \"action\": \"swipe\", \"from\": [$X1,$Y1], \"to\": [$X2,$Y2]}"
else
  die "idb not found. Install: brew install idb-companion && pip install fb-idb"
fi
