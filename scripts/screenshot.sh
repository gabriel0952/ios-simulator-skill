#!/usr/bin/env bash
# screenshot.sh — Take a screenshot of the simulator
# Usage: ./screenshot.sh [--udid UDID] [--size full|half|quarter]
# Output: base64-encoded PNG + metadata JSON printed to stdout
# Note: base64 is large; redirect to file if needed.

source "$(dirname "$0")/_utils.sh"

UDID=""
SIZE="half"

while [[ $# -gt 0 ]]; do
  case $1 in
    --udid) UDID="$2"; shift 2 ;;
    --size) SIZE="$2"; shift 2 ;;
    *) shift ;;
  esac
done

UDID=$(get_udid "$UDID") || die "No booted simulator found."

TMP=$(mktemp /tmp/sim_screenshot_XXXXXX.png)
trap "rm -f $TMP ${TMP%.png}_resized.png" EXIT

xcrun simctl io "$UDID" screenshot "$TMP" 2>/dev/null || die "Screenshot failed."

case "$SIZE" in
  half)    sips -Z 500 "$TMP" --out "${TMP%.png}_resized.png" &>/dev/null; SRC="${TMP%.png}_resized.png" ;;
  quarter) sips -Z 250 "$TMP" --out "${TMP%.png}_resized.png" &>/dev/null; SRC="${TMP%.png}_resized.png" ;;
  *)       SRC="$TMP" ;;
esac

[[ -f "$SRC" ]] || SRC="$TMP"

B64=$(base64 < "$SRC")
echo "{\"success\": true, \"size_preset\": \"$SIZE\", \"image_base64\": \"$B64\"}"
